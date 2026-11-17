local Spawner = {}
local RunService = game:GetService("RunService")
local Data
local Economy
local Factory
local Events
local BaseManager
local active = {}
local random = Random.new()

local function chooseRarity()
	local total = 0
	for _, rarity in pairs(Data.Rarities) do total += rarity.weight end
	local roll = random:NextNumber(0, total)
	for name, rarity in pairs(Data.Rarities) do
		roll -= rarity.weight
		if roll <= 0 then return name, rarity end
	end
	return "Common", Data.Rarities.Common
end

local function chooseMutation()
	for _, mutation in ipairs(Data.Mutations) do
		if random:NextNumber() < mutation.chance then return mutation end
	end
	return nil
end

function Spawner.Init(data, economy, characterFactory, events, bases, shrinePrompt)
	Data, Economy, Factory, Events, BaseManager = data, economy, characterFactory, events, bases
	if shrinePrompt then
		shrinePrompt.Triggered:Connect(function(player)
			local state = Economy.States[player]
			if not state then return end
			if state.cash < Data.RebirthCost then
				Events.Feedback:FireClient(player, "message", "NEED $" .. Data.RebirthCost .. " TO REBIRTH")
				return
			end
			state.cash = 0
			state.rebirths += 1
			state.multiplier = 1 + state.rebirths * Data.RebirthMultiplierStep
			state.income = 0
			if state.carried then state.carried.model:Destroy(); state.carried = nil end
			for _, item in ipairs(state.placed) do item.model:Destroy(); item.pad:SetAttribute("Occupied", false) end
			state.placed = {}
			Economy.Sync(player)
			Events.Feedback:FireClient(player, "message", "REBIRTH! INCOME MULTIPLIER x" .. state.multiplier)
		end)
	end

	RunService.Heartbeat:Connect(function(dt)
		for index = #active, 1, -1 do
			local entry = active[index]
			if entry.model.Parent and not entry.caught then
				entry.progress += dt * 12
				entry.model:PivotTo(CFrame.new(-74 + entry.progress, 9.5, 0))
				if entry.progress >= 148 then entry.model:Destroy(); table.remove(active, index) end
			end
		end
		for player, state in pairs(Economy.States) do
			if state.carried and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				state.carried.model:PivotTo(player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3.5, -3))
			end
		end
	end)

	task.spawn(function()
		while true do
			task.wait(3.5)
			local rarityName, rarity = chooseRarity()
			local definition
			local candidates = {}
			for _, character in ipairs(Data.Cast) do if character.rarity == rarityName then table.insert(candidates, character) end end
			definition = candidates[random:NextInteger(1, #candidates)]
			local mutation = chooseMutation()
			local income = rarity.incomePerSecond * (mutation and mutation.multiplier or 1)
			local model, prompt = Factory.Build(definition, rarity, mutation, income, "Buy $" .. math.floor(rarity.price * (mutation and mutation.multiplier or 1)))
			model:PivotTo(CFrame.new(-74, 9.5, 0))
			model.Parent = workspace.BazaarWorld
			local entry = { model = model, progress = 0, caught = false }
			table.insert(active, entry)
			prompt.Triggered:Connect(function(player)
				local state = Economy.States[player]
				local cost = math.floor(rarity.price * (mutation and mutation.multiplier or 1))
				if not state or state.carried or state.cash < cost or entry.caught then
					if state and state.cash < cost then Events.Feedback:FireClient(player, "message", "NOT ENOUGH CASH") end
					return
				end
				state.cash -= cost
				state.carried = { model = model, income = income, name = definition.name, rarity = rarityName, mutation = mutation and mutation.name }
				prompt.Enabled = false
				entry.caught = true
				model:SetAttribute("OwnerUserId", 0)
				Events.Feedback:FireClient(player, "owned", definition.name)
				Events.Feedback:FireClient(player, "cash", income)
				Economy.Sync(player)
				Events.Feedback:FireClient(player, "message", definition.name .. " caught! Bring it to a base pad.")
			end)
			task.delay(18, function()
				if model.Parent and not entry.caught then model:Destroy() end
				for i, value in ipairs(active) do if value == entry then table.remove(active, i); break end end
			end)
		end
	end)
end

return Spawner
