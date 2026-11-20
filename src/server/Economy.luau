local Players = game:GetService("Players")
local D = require(game.ReplicatedStorage.Shared.BrainrotData)
local E = { States = {} }

function E.Sync(player)
    local account = E.States[player]
    if not account then
        return
    end

    account.CashStat.Value = math.floor(account.Cash)
    player:SetAttribute("Cash", math.floor(account.Cash))
    player:SetAttribute("SpeedTier", account.Speed)
    player:SetAttribute("Rebirths", account.Rebirths)
    player:SetAttribute("IncomeMultiplier", 1 + account.Rebirths * D.RebirthBonus)
end

function E.AddPlayer(player)
    if E.States[player] then
        return
    end

    local leaderboard = Instance.new("Folder")
    leaderboard.Name = "leaderstats"
    leaderboard.Parent = player
    local cashValue = Instance.new("IntValue")
    cashValue.Name = "Cash"
    cashValue.Parent = leaderboard

    E.States[player] = {
        Cash = D.StartCash,
        Speed = 0,
        Rebirths = 0,
        CashStat = cashValue,
    }
    E.Sync(player)
    player.CharacterAdded:Connect(function(character)
        local avatarHumanoid = character:WaitForChild("Humanoid", 10)
        local account = E.States[player]
        if avatarHumanoid and account then
            avatarHumanoid.WalkSpeed = 16 + account.Speed * D.SpeedStep
        end
    end)
end

function E.Credit(player, amount)
    local account = E.States[player]
    if not account or amount ~= amount or amount < 0 or amount == math.huge then
        return false
    end

    account.Cash += amount
    E.Sync(player)
    return true
end

function E.Spend(player, amount)
    local account = E.States[player]
    if not account or amount ~= amount or amount < 0 or amount == math.huge or account.Cash < amount then
        return false
    end

    account.Cash -= amount
    E.Sync(player)
    return true
end

function E.Penalize(player)
    local account = E.States[player]
    if account then
        E.Spend(player, account.Cash * D.CaughtPenalty)
    end
end

function E.Sell(player, item)
    return E.Credit(player, D.Price(item) * D.SellRatio)
end

function E.BuySpeed(player)
    local account = E.States[player]
    if not account or account.Speed >= D.SpeedTiers then
        return false
    end
    if not E.Spend(player, D.SpeedCost(account.Speed + 1)) then
        return false
    end

    account.Speed += 1
    local avatarHumanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if avatarHumanoid then
        avatarHumanoid.WalkSpeed = 16 + account.Speed * D.SpeedStep
    end
    E.Sync(player)
    return true
end

function E.Rebirth(player)
    local account = E.States[player]
    if not account or not E.Spend(player, D.RebirthCost) then
        return false
    end

    account.Rebirths += 1
    E.Sync(player)
    return true
end

function E.Start(base)
    Players.PlayerAdded:Connect(E.AddPlayer)
    Players.PlayerRemoving:Connect(function(player)
        E.States[player] = nil
    end)
    for _, participant in ipairs(Players:GetPlayers()) do
        E.AddPlayer(participant)
    end

    task.spawn(function()
        while true do
            task.wait(1)
            for participant, account in pairs(E.States) do
                local earnings = 0
                for _, placedItem in ipairs(base.GetPlaced(participant)) do
                    earnings += D.Income(placedItem)
                end
                earnings *= 1 + account.Rebirths * D.RebirthBonus
                participant:SetAttribute("IncomePerSecond", earnings)
                if earnings > 0 then
                    E.Credit(participant, earnings)
                end
            end
        end
    end)
end

return E
