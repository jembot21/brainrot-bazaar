local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Spawner = {}

local Data = nil
local Economy = nil
local Factory = nil
local Events = nil
local BaseManager = nil
local active = {}
local random = Random.new()

local function rollRarity()
	local totalWeight = 0
	for _, rData in Data.Rarities do
		totalWeight += rData.weight
	end

	local roll = random:NextNumber(0, totalWeight)
	for rName, rData in Data.Rarities do
		if roll <= rData.weight then
			return rName, rData
		end
		roll -= rData.weight
	end
	return "Common", Data.Rarities.Common
end

local function rollMutation()
	for _, mutation in Data.Mutations do
		if random:NextNumber() < mutation.chance then
			return mutation
		end
	end
	return nil
end

function Spawner.Init(dataModule, economyModule, characterFactory, eventsTable, baseManagerModule, shrinePrompt)
	Data = dataModule
	Economy = economyModule
	Factory = characterFactory
	Events = eventsTable
	BaseManager = baseManagerModule

	if shrinePrompt then
		shrinePrompt.Triggered:Connect(function(player)
			local account = Economy.States[player]
			if not account then
				return
			end

			if account.cash < Data.RebirthCost then
				Events.Feedback:FireClient(player, "message", "NEED $" .. Data.RebirthCost .. " TO REBIRTH")
				return
			end

			account.cash = 0
			account.rebirths += 1
			account.multiplier = 1 + (account.rebirths * Data.RebirthMultiplierStep)
			account.income = 0

			if account.carried and account.carried.model then
				account.carried.model:Destroy()
				account.carried = nil
			end

			for _, placedItem in account.placed do
				if placedItem.model then
					placedItem.model:Destroy()
				end
				if placedItem.pad then
					placedItem.pad:SetAttribute("Occupied", false)
				end
			end
			account.placed = {}

			Economy.Sync(player)
			Events.Feedback:FireClient(player, "message", "REBIRTH! INCOME MULTIPLIER x" .. account.multiplier)
		end)
	end

	RunService.Heartbeat:Connect(function(dt)
		for i = #active, 1, -1 do
			local entry = active[i]
			if entry.model and entry.model.Parent and not entry.caught then
				entry.progress += dt * 12
				entry.model:PivotTo(CFrame.new(-74 + entry.progress, 9.6, 0) * CFrame.Angles(0, math.rad(-90), 0))
				if entry.progress >= 148 then
					entry.model:Destroy()
					table.remove(active, i)
				end
			elseif not entry.model or not entry.model.Parent then
				table.remove(active, i)
			end
		end

		for player, account in Economy.States do
			if account.carried and account.carried.model and account.carried.model.Parent then
				local char = player.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				if root then
					local look = root.CFrame.LookVector
					local yaw = math.atan2(-look.X, -look.Z)
					account.carried.model:PivotTo(CFrame.new(root.Position + Vector3.new(0, 4.3, 0)) * CFrame.Angles(0, yaw, 0))
				end
			end
		end
	end)

	task.spawn(function()
		while true do
			task.wait(3.5)
			local success, err = pcall(function()
				local world = Workspace:FindFirstChild("BazaarWorld")
				if not world then
					return
				end

				local rarityName, rarity = rollRarity()
				local candidates = {}
				for _, castMember in Data.Cast do
					if castMember.rarity == rarityName then
						table.insert(candidates, castMember)
					end
				end
				if #candidates == 0 then
					candidates = Data.Cast
				end

				local definition = candidates[random:NextInteger(1, #candidates)]
				local mutation = rollMutation()
				local mult = mutation and mutation.multiplier or 1
				local income = math.floor(rarity.incomePerSecond * mult)
				local cost = math.floor(rarity.price * mult)

				local model, prompt = Factory.Build(definition, rarity, mutation, income, "Buy $" .. cost)
				model:PivotTo(CFrame.new(-74, 9.6, 0) * CFrame.Angles(0, math.rad(-90), 0))
				model.Parent = world

				local entry = {
					model = model,
					progress = 0,
					caught = false,
				}
				table.insert(active, entry)

				prompt.Triggered:Connect(function(player)
					local account = Economy.States[player]
					if not account or entry.caught then
						return
					end

					if account.carried then
						Events.Feedback:FireClient(player, "message", "ALREADY CARRYING A MASCOT!")
						return
					end

					if account.cash < cost then
						Events.Feedback:FireClient(player, "message", "NOT ENOUGH CASH")
						return
					end

					account.cash -= cost
					entry.caught = true
					prompt.Enabled = false
					model:SetAttribute("OwnerUserId", 0)

					account.carried = {
						model = model,
						income = income,
						name = definition.name,
						rarity = rarityName,
						mutation = mutation and mutation.name or nil,
					}

					Events.Feedback:FireClient(player, "owned", definition.name)
					Events.Feedback:FireClient(player, "cash", income)
					Economy.Sync(player)
					Events.Feedback:FireClient(player, "message", "GOT IT! FOLLOW THE LIGHT PILLAR TO YOUR SHOP - IT PLACES ITSELF WHEN YOU ARRIVE")
				end)

				task.delay(18, function()
					if model and model.Parent and not entry.caught then
						model:Destroy()
						for idx = #active, 1, -1 do
							if active[idx] == entry then
								table.remove(active, idx)
								break
							end
						end
					end
				end)
			end)

			if not success then
				warn("Brainrot spawn failed:", err)
			end
		end
	end)
end

return Spawner
