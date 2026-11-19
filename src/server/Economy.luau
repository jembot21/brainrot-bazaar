local Players = game:GetService("Players")
local Data = require(game:GetService("ReplicatedStorage").Shared.BrainrotData)

local Economy = {}
local states = {}
local remotes
local getPlaced = function()
	return {}
end

local function publish(player)
	local state = states[player]
	if not state then
		return
	end
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		leaderstats.Cash.Value = math.floor(state.Cash)
		leaderstats.Rebirths.Value = state.Rebirths
	end
	player:SetAttribute("Cash", math.floor(state.Cash))
	player:SetAttribute("SpeedTier", state.SpeedTier)
	player:SetAttribute("Rebirths", state.Rebirths)
	if remotes and remotes.CashChanged then
		remotes.CashChanged:FireClient(player, math.floor(state.Cash), state.Rebirths, state.SpeedTier)
	end
end

local function addPlayer(player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = Data.StartCash
	cash.Parent = stats
	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = 0
	rebirths.Parent = stats
	states[player] = { Cash = Data.StartCash, Rebirths = 0, SpeedTier = 0 }
	publish(player)
end

function Economy.Start(remoteFolder, placedProvider)
	remotes = remoteFolder
	getPlaced = placedProvider or getPlaced
	Players.PlayerAdded:Connect(addPlayer)
	Players.PlayerRemoving:Connect(function(player)
		states[player] = nil
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		if not states[player] then
			addPlayer(player)
		end
	end
	if remotes.BuySpeed then
		remotes.BuySpeed.OnServerEvent:Connect(function(player)
			Economy.BuySpeed(player)
		end)
	end
	if remotes.Rebirth then
		remotes.Rebirth.OnServerEvent:Connect(function(player)
			Economy.Rebirth(player)
		end)
	end
	task.spawn(function()
		while true do
			task.wait(1)
			for player, state in pairs(states) do
				if player.Parent == Players then
					local baseIncome = 0
					for _, brainrot in ipairs(getPlaced(player)) do
						if brainrot and brainrot.Parent then
							baseIncome += brainrot:GetAttribute("Income") or 0
						end
					end
					state.Cash += baseIncome * Data.IncomeMultiplier(state.Rebirths)
					publish(player)
				end
			end
		end
	end)
end

function Economy.GetCash(player)
	local state = states[player]
	return state and math.floor(state.Cash) or 0
end

function Economy.GetState(player)
	return states[player]
end

function Economy.AddCash(player, amount)
	local state = states[player]
	if not state then
		return false
	end
	state.Cash = math.max(0, state.Cash + amount)
	publish(player)
	return true
end

function Economy.TrySpend(player, amount)
	local state = states[player]
	if not state or amount < 0 or state.Cash < amount then
		return false
	end
	state.Cash -= amount
	publish(player)
	return true
end

function Economy.BuySpeed(player)
	local state = states[player]
	if not state or state.SpeedTier >= Data.SpeedTiers then
		return false
	end
	local tier = state.SpeedTier + 1
	local cost = Data.SpeedCost(tier)
	if not Economy.TrySpend(player, cost) then
		if remotes.Toast then remotes.Toast:FireClient(player, "Need $" .. cost .. " for the next speed tier.") end
		return false
	end
	state.SpeedTier = tier
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = 16 + tier * Data.SpeedPerTier
	end
	publish(player)
	if remotes.Toast then remotes.Toast:FireClient(player, "Speed upgraded to tier " .. tier .. "!") end
	return true
end

function Economy.Rebirth(player)
	local state = states[player]
	if not state then
		return false
	end
	if not Economy.TrySpend(player, Data.RebirthCost) then
		if remotes.Toast then remotes.Toast:FireClient(player, "Rebirth costs $" .. Data.RebirthCost .. ".") end
		return false
	end
	state.Rebirths += 1
	state.SpeedTier = 0
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then humanoid.WalkSpeed = 16 end
	publish(player)
	if remotes.Toast then remotes.Toast:FireClient(player, "Rebirth complete! Income multiplier increased.") end
	return true
end

function Economy.SellValue(price)
	return math.floor(price * Data.SellMultiplier + 0.5)
end

function Economy.ApplyCaughtPenalty(player)
	local state = states[player]
	if not state then return end
	local loss = math.floor(state.Cash * Data.CaughtCashLoss + 0.5)
	state.Cash = math.max(0, state.Cash - loss)
	publish(player)
	if remotes.Caught then remotes.Caught:FireClient(player, loss) end
end

return Economy
