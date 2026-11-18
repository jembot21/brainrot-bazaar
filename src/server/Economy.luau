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

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"

	local cashVal = Instance.new("IntValue")
	cashVal.Name = "Cash"
	cashVal.Value = math.floor(account.cash)
	cashVal.Parent = leaderstats

	local incomeVal = Instance.new("IntValue")
	incomeVal.Name = "$/s"
	incomeVal.Value = math.floor(account.income)
	incomeVal.Parent = leaderstats

	local rebirthsVal = Instance.new("IntValue")
	rebirthsVal.Name = "Rebirths"
	rebirthsVal.Value = account.rebirths
	rebirthsVal.Parent = leaderstats

	leaderstats.Parent = player

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
			for player, account in pairs(Economy.States) do
				local totalIncome = 0
				for _, placed in ipairs(account.placed) do
					totalIncome += (placed.income or 0)
				end
				account.income = totalIncome * account.multiplier
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
