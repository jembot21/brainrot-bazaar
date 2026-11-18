local Economy = {}

Economy.States = {}

function Economy.InitPlayer(player)
	local account = {
		cash = 150,
		placed = {},
		rebirths = 0,
		multiplier = 1,
		carried = nil,
		plot = nil,
		income = 0,
	}
	Economy.States[player] = account

	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	local cashVal = leaderstats:FindFirstChild("Cash")
	if not cashVal then
		cashVal = Instance.new("IntValue")
		cashVal.Name = "Cash"
		cashVal.Parent = leaderstats
	end

	local incomeVal = leaderstats:FindFirstChild("$/s")
	if not incomeVal then
		incomeVal = Instance.new("IntValue")
		incomeVal.Name = "$/s"
		incomeVal.Parent = leaderstats
	end

	local rebirthsVal = leaderstats:FindFirstChild("Rebirths")
	if not rebirthsVal then
		rebirthsVal = Instance.new("IntValue")
		rebirthsVal.Name = "Rebirths"
		rebirthsVal.Parent = leaderstats
	end

	Economy.Sync(player)
	return account
end

function Economy.Sync(player)
	local account = Economy.States[player]
	if not account then
		return
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local cashVal = leaderstats:FindFirstChild("Cash")
		if cashVal then
			cashVal.Value = math.floor(account.cash)
		end
		local incomeVal = leaderstats:FindFirstChild("$/s")
		if incomeVal then
			incomeVal.Value = math.floor(account.income)
		end
		local rebirthsVal = leaderstats:FindFirstChild("Rebirths")
		if rebirthsVal then
			rebirthsVal.Value = account.rebirths
		end
	end

	player:SetAttribute("Cash", math.floor(account.cash))
	player:SetAttribute("Income", math.floor(account.income))
	player:SetAttribute("Multiplier", account.multiplier)
	player:SetAttribute("Rebirths", account.rebirths)
end

function Economy.AddCash(player, amount)
	local account = Economy.States[player]
	if not account then
		return false
	end
	account.cash += amount
	Economy.Sync(player)
	return true
end

function Economy.StartIncomeTick()
	task.spawn(function()
		while true do
			task.wait(1)
			for player, account in Economy.States do
				local total = 0
				for _, item in account.placed do
					total += (item.income or 0)
				end
				account.income = total * account.multiplier
				account.cash += account.income
				Economy.Sync(player)
			end
		end
	end)
end

function Economy.RemovePlayer(player)
	Economy.States[player] = nil
end

return Economy
