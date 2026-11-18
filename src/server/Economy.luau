local Economy = {Players = {}}

function Economy.Init(data, events)
	Economy.Data = data
	Economy.Events = events
end

function Economy.AddPlayer(player)
	Economy.Players[player] = {cash = Economy.Data.StartCash, placed = {}, rebirths = 0, multiplier = 1, speedTier = 0}
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	for _, key in ipairs({"Cash", "$/s", "Rebirths"}) do
		local value = Instance.new("NumberValue")
		value.Name = key
		value.Parent = stats
	end
	stats.Parent = player
	Economy.Sync(player)
end

-- Recompute income from the current display pads before publishing the stats.
function Economy.Sync(player)
	local state = Economy.Players[player]
	local rate = 0
	for _, item in pairs(state.placed) do
		rate += Economy.Data.Income(item.definition, item.mutation)
	end
	state.rate = rate * state.multiplier
	local stats = player.leaderstats
	stats.Cash.Value = state.cash
	stats["$/s"].Value = state.rate
	stats.Rebirths.Value = state.rebirths
	player:SetAttribute("Multiplier", state.multiplier)
	player:SetAttribute("SpeedTier", state.speedTier)
end

function Economy.ApplySpeed(player)
	local state = Economy.Players[player]
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if state and humanoid then
		local shop = Economy.Data.SpeedShop
		humanoid.WalkSpeed = shop.BaseWalkSpeed + shop.SpeedPerTier * state.speedTier
	end
end

function Economy.Spend(player, cost)
	local state = Economy.Players[player]
	if not state or state.cash < cost then return false end
	state.cash -= cost
	Economy.Sync(player)
	return true
end

function Economy.BuySpeed(player)
	local state = Economy.Players[player]
	if not state then return end
	local shop = Economy.Data.SpeedShop
	local tier = state.speedTier + 1
	local feedback = Economy.Events.Feedback
	if tier > shop.SpeedMaxTier then
		feedback:FireClient(player, "Speed is maxed out!")
		return
	end
	local cost = shop.Cost(tier)
	if state.cash < cost then
		feedback:FireClient(player, ("Speed tier %d costs $%d"):format(tier, cost))
		return
	end
	state.cash -= cost
	state.speedTier = tier
	Economy.ApplySpeed(player)
	Economy.Sync(player)
	feedback:FireClient(player, ("Speed tier %d · WalkSpeed %d"):format(tier, shop.BaseWalkSpeed + shop.SpeedPerTier * tier))
end

-- Each payout uses the per-second rate cached by Sync.
function Economy.Start()
	task.spawn(function()
		while task.wait(1) do
			for player, state in pairs(Economy.Players) do
				if state.rate > 0 then
					state.cash += state.rate
					Economy.Sync(player)
					Economy.Events.Income:FireClient(player, state.rate)
				end
			end
		end
	end)
end

return Economy
