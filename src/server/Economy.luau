local Economy = {}
Economy.States = {}

function Economy.InitPlayer(player)
	local state = { cash = 150, placed = {}, rebirths = 0, multiplier = 1, carried = nil, plot = nil, income = 0 }
	Economy.States[player] = state
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	for _, name in ipairs({ "Cash", "$/s", "Rebirths" }) do
		local value = Instance.new("IntValue")
		value.Name = name
		value.Parent = leaderstats
	end
	Economy.Sync(player)
	return state
end

function Economy.Sync(player)
	local state = Economy.States[player]
	if not state then return end
	local stats = player:FindFirstChild("leaderstats")
	if stats then
		stats.Cash.Value = math.floor(state.cash)
		stats["$/s"].Value = math.floor(state.income)
		stats.Rebirths.Value = state.rebirths
	end
	player:SetAttribute("Cash", math.floor(state.cash))
	player:SetAttribute("Income", math.floor(state.income))
	player:SetAttribute("Multiplier", state.multiplier)
	player:SetAttribute("Rebirths", state.rebirths)
end

function Economy.AddCash(player, amount)
	local state = Economy.States[player]
	if not state then return false end
	state.cash += amount
	Economy.Sync(player)
	return true
end

function Economy.StartIncomeTick()
	task.spawn(function()
		while true do
			task.wait(1)
			for player, state in pairs(Economy.States) do
				local income = 0
				for _, brainrot in ipairs(state.placed) do
					income += brainrot.income
				end
				state.income = income * state.multiplier
				state.cash += state.income
				Economy.Sync(player)
			end
		end
	end)
end

function Economy.RemovePlayer(player)
	Economy.States[player] = nil
end

return Economy
