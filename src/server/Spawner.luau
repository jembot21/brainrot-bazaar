local RunService = game:GetService("RunService")

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
	for _, r in pairs(Data.Rarities) do
		totalWeight += r.weight
	end

	local remainingRoll = random:NextNumber(0, totalWeight)
	for name, r in pairs(Data.Rarities) do
		remainingRoll -= r.weight
		if remainingRoll <= 0 then
			return name, r
		end
	end

	return "Common", Data.Rarities.Common
end

local function rollMutation()
	for _, mut in ipairs(Data.Mutations) do
		if random:NextNumber() < mut.chance then
			return mut
		end
	end
	return nil
end

function Spawner.Init(data, economy, characterFactory, events, bases, shrinePrompt)
	Data = data
	Economy = economy
	Factory = characterFactory
	Events = events
	BaseManager = bases

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

			for _, placed in ipairs(account.placed) do
				if placed.pad then
					placed.pad:SetAttribute("Occupied", false)
				end
				if placed.model then
					placed.model:Destroy()
				end
			end
			account.placed = {}

			Economy.Sync(player)
			Events.Feedback:FireClient(player, "message", "REBIRTH! INCOME MULTIPLIER x" .. account.multiplier)
		end)
	end

	-- Heartbeat conveyor movement & carried head tracking
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
			end
		end

		for player, account in pairs(Economy.States) do
			if account.carried and account.carried.model and player.Character then
				local root = player.Character:FindFirstChild("HumanoidRootPart")
				if root then
					local look = root.CFrame.LookVector
					local yaw = math.atan2(-look.X, -look.Z)
					account.carried.model:PivotTo(CFrame.new(root.Position + Vector3.new(0, 4.3, 0)) * CFrame.Angles(0, yaw, 0))
				end
			end
		end
	end)

	-- Spawner loop
	task.spawn(function()
		while true do
			task.wait(3.5)
			local success, err = pcall(function()
				local rarityName, rarity = rollRarity()
				local candidates = {}
				for _, castMember in ipairs(Data.Cast) do
					if castMember.rarity == rarityName then
						table.insert(candidates, castMember)
					end
				end

				if #candidates == 0 then
					return
				end

				local definition = candidates[random:NextInteger(1, #candidates)]
				local mutation = rollMutation()
				local mutMultiplier = mutation and mutation.multiplier or 1
				local income = rarity.incomePerSecond * mutMultiplier
				local cost = math.floor(rarity.price * mutMultiplier)

				local model, prompt = Factory.Build(definition, rarity, mutation, income, "Buy $" .. cost)
				model:PivotTo(CFrame.new(-74, 9.6, 0) * CFrame.Angles(0, math.rad(-90), 0))
				model.Parent = workspace.BazaarWorld

				local entry = {
					model = model,
					progress = 0,
					caught = false,
				}
				table.insert(active, entry)

				prompt.Triggered:Connect(function(player)
					local account = Economy.States[player]
					if not account or account.carried or entry.caught or account.cash < cost then
						if account and account.cash < cost then
							Events.Feedback:FireClient(player, "message", "NOT ENOUGH CASH")
						end
						return
					end

					account.cash -= cost
					account.carried = {
						model = model,
						income = income,
						name = definition.name,
						rarity = rarityName,
						mutation = mutation and mutation.name or nil,
					}
					prompt.Enabled = false
					entry.caught = true
					model:SetAttribute("OwnerUserId", 0)

					Events.Feedback:FireClient(player, "owned", definition.name)
					Events.Feedback:FireClient(player, "cash", income)
					Economy.Sync(player)
					Events.Feedback:FireClient(player, "message", "GOT IT! FOLLOW THE LIGHT PILLAR TO YOUR SHOP - IT PLACES ITSELF WHEN YOU ARRIVE")
				end)

				task.delay(18, function()
					if model and model.Parent and not entry.caught then
						model:Destroy()
						local idx = table.find(active, entry)
						if idx then
							table.remove(active, idx)
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
