-- Feed the conveyor, sell catches, follow carriers, and process shrine rebirths.

local Spawner = {}
local RunService = game:GetService("RunService")
local Data
local Economy
local Factory
local Events
local BaseManager
local active = {}
local random = Random.new()

local function rollRarity()
    local total = 0
    for _, rarity in pairs(Data.Rarities) do total += rarity.weight end
    local roll = random:NextNumber(0, total)
    for name, rarity in pairs(Data.Rarities) do
        roll -= rarity.weight
        if roll <= 0 then
            return name, rarity
        end
    end
    return "Common", Data.Rarities.Common
end

local function rollMutation()
    for _, mutation in ipairs(Data.Mutations) do
        if random:NextNumber() < mutation.chance then
            return mutation
        end
    end
    return nil
end

function Spawner.Init(data, economy, characterFactory, events, bases, shrinePrompt)
    Data, Economy, Factory, Events, BaseManager = data, economy, characterFactory, events, bases
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
            account.multiplier = 1 + account.rebirths * Data.RebirthMultiplierStep
            account.income = 0
            if account.carried then
                account.carried.model:Destroy(); account.carried = nil
            end
            for _, item in ipairs(account.placed) do item.model:Destroy(); item.pad:SetAttribute("Occupied", false) end
            account.placed = {}
            Economy.Sync(player)
            Events.Feedback:FireClient(player, "message", "REBIRTH! INCOME MULTIPLIER x" .. state.multiplier)
        end)
    end

    RunService.Heartbeat:Connect(function(dt)
        for index = #active, 1, -1 do
            local entry = active[index]
            if entry.model.Parent and not entry.caught then
                entry.progress += dt * 12
                entry.model:PivotTo(CFrame.new(-74 + entry.progress, 9.6, 0) * CFrame.Angles(0, math.rad(-90), 0))
                if entry.progress >= 148 then
                    entry.model:Destroy(); table.remove(active, index)
                end
            end
        end
        for player, account in pairs(Economy.States) do
            if account.carried and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local characterRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                local look = characterRoot.CFrame.LookVector
                local yaw = math.atan2(-look.X, -look.Z)
                account.carried.model:PivotTo(CFrame.new(characterRoot.Position + Vector3.new(0, 4.3, 0)) * CFrame.Angles(0, yaw, 0))
            end
        end
    end)

    task.spawn(function()
        while true do
            task.wait(3.5)
            local ok, err = pcall(function()
            local rarityName, rarity = rollRarity()
            local definition
            local candidates = {}
            for _, character in ipairs(Data.Cast) do if character.rarity == rarityName then table.insert(candidates, character) end end
            definition = candidates[random:NextInteger(1, #candidates)]
            local mutation = rollMutation()
            local income = rarity.incomePerSecond * (mutation and mutation.multiplier or 1)
            local model, prompt = Factory.Build(definition, rarity, mutation, income, "Buy $" .. math.floor(rarity.price * (mutation and mutation.multiplier or 1)))
            model:PivotTo(CFrame.new(-74, 9.6, 0) * CFrame.Angles(0, math.rad(-90), 0))
            model.Parent = workspace.BazaarWorld
            local entry = { model = model, progress = 0, caught = false }
            table.insert(active, entry)
            prompt.Triggered:Connect(function(player)
                local account = Economy.States[player]
                local cost = math.floor(rarity.price * (mutation and mutation.multiplier or 1))
                if not account or account.carried or account.cash < cost or entry.caught then
                    if account and account.cash < cost then
                        Events.Feedback:FireClient(player, "message", "NOT ENOUGH CASH")
                    end
                    return
                end
                account.cash -= cost
                account.carried = { model = model, income = income, name = definition.name, rarity = rarityName, mutation = mutation and mutation.name }
                prompt.Enabled = false
                entry.caught = true
                model:SetAttribute("OwnerUserId", 0)
                Events.Feedback:FireClient(player, "owned", definition.name)
                Events.Feedback:FireClient(player, "cash", income)
                Economy.Sync(player)
                Events.Feedback:FireClient(player, "message", "GOT IT! FOLLOW THE LIGHT PILLAR TO YOUR SHOP - IT PLACES ITSELF WHEN YOU ARRIVE")
            end)
            task.delay(18, function()
                if model.Parent and not entry.caught then
                    model:Destroy()
                end
                for i, value in ipairs(active) do if value == entry then table.remove(active, i); break end end
            end)
            end)
            if not ok then
                warn("Brainrot spawn failed:", err)
            end
        end
    end)
end

return Spawner
