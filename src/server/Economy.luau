-- Own session balances and publish replicated wallet and income values.

local Economy = {}
Economy.States = {}

function Economy.InitPlayer(player)
    local account = { cash = 150, placed = {}, rebirths = 0, multiplier = 1, carried = nil, plot = nil, income = 0 }
    Economy.States[player] = account
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player
    for _, name in ipairs({ "Cash", "$/s", "Rebirths" }) do
        local value = Instance.new("IntValue")
        value.Name = name
        value.Parent = leaderstats
    end
    Economy.Sync(player)
    return account
end

function Economy.Sync(player)
    local account = Economy.States[player]
    if not account then
        return
    end
    local stats = player:FindFirstChild("leaderstats")
    if stats then
        stats.Cash.Value = math.floor(account.cash)
        stats["$/s"].Value = math.floor(account.income)
        stats.Rebirths.Value = account.rebirths
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
                local income = 0
                for _, brainrot in ipairs(account.placed) do
                    income += brainrot.income
                end
                account.income = income * account.multiplier
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
