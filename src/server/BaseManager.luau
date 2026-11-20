local Players = game:GetService("Players")
local D = require(game.ReplicatedStorage.Shared.BrainrotData)
local Factory = require(script.Parent.CharacterFactory)
local B = { Assignments = {}, Carried = {} }
local world, economy, remote

local function toast(player, message)
    remote:FireClient(player, "Toast", message)
end

local function aliveNear(player, part)
    local avatar = player.Character
    local pivot = avatar and avatar:FindFirstChild("HumanoidRootPart")
    local humanoid = avatar and avatar:FindFirstChildOfClass("Humanoid")
    return pivot and humanoid and humanoid.Health > 0
        and (pivot.Position - part.Position).Magnitude <= 14
end

local function prompt(part, text, callback)
    local interaction = Instance.new("ProximityPrompt")
    interaction.ActionText = text
    interaction.ObjectText = part.Name
    interaction.HoldDuration = 0.4
    interaction.MaxActivationDistance = 11
    interaction.RequiresLineOfSight = false
    interaction.Parent = part
    interaction.Triggered:Connect(function(player)
        if aliveNear(player, part) then
            callback(player)
        end
    end)
    return interaction
end

function B.GetPlaced(player)
    local items = {}
    local home = B.Assignments[player]
    if home then
        for _, occupied in pairs(home.Slots) do
            table.insert(items, occupied.Item)
        end
    end
    return items
end

function B.IsHome(player, position)
    local home = B.Assignments[player]
    return home ~= nil
        and math.abs(position.X - home.Center.X) <= 27
        and math.abs(position.Z - home.Center.Z) <= 24
end

function B.Drop(player)
    local held = B.Carried[player]
    if held then
        held.Model:Destroy()
        B.Carried[player] = nil
    end
    player:SetAttribute("Carrying", "")
end

function B.Give(player, item)
    if B.Carried[player] or not B.Assignments[player] then
        return false
    end

    local avatar = player.Character
    local skull = avatar and avatar:FindFirstChild("Head")
    local humanoid = avatar and avatar:FindFirstChildOfClass("Humanoid")
    if not skull or not humanoid or humanoid.Health <= 0 then
        return false
    end

    local creature = Factory.Create(item)
    creature.Parent = world.Folder
    creature:PivotTo(skull.CFrame * CFrame.new(0, 3.5, 0))
    for _, piece in ipairs(creature:GetDescendants()) do
        if piece:IsA("BasePart") then
            piece.Anchored = false
            piece.Massless = true
            local attachment = Instance.new("WeldConstraint")
            attachment.Part0 = skull
            attachment.Part1 = piece
            attachment.Parent = piece
        end
    end
    B.Carried[player] = { Item = item, Model = creature }
    player:SetAttribute("Carrying", D.Species[item.Species].Name)
    return true
end

local function place(plot, index, item)
    local platform = plot.Pads[index]
    local creature = Factory.Create(item)
    creature.Parent = world.Folder
    creature:PivotTo(CFrame.new(platform.Position + Vector3.new(0, 2, 0)))
    local occupied = {
        Item = item,
        Model = creature,
        Unlock = os.clock() + D.PadLock,
    }
    plot.Slots[index] = occupied
    platform.Color = Color3.fromRGB(244, 135, 103)
    task.delay(D.PadLock, function()
        if plot.Slots[index] == occupied then
            platform.Color = Color3.fromRGB(113, 236, 158)
        end
    end)
end

function B.Fuse(player)
    local home = B.Assignments[player]
    if not home then
        return
    end

    local bySpecies = {}
    for padIndex, occupied in pairs(home.Slots) do
        local speciesId = occupied.Item.Species
        bySpecies[speciesId] = bySpecies[speciesId] or {}
        table.insert(bySpecies[speciesId], padIndex)
    end
    for speciesId, padIndices in pairs(bySpecies) do
        local rarity = D.Species[speciesId].Tier
        if #padIndices >= D.FusionCount and rarity < #D.Tiers then
            local upgradedId
            for speciesIndex, definition in ipairs(D.Species) do
                if definition.Tier == rarity + 1 then
                    upgradedId = speciesIndex
                    break
                end
            end
            for consumed = 1, D.FusionCount do
                local padIndex = padIndices[consumed]
                home.Slots[padIndex].Model:Destroy()
                home.Slots[padIndex] = nil
            end
            place(home, padIndices[1], { Species = upgradedId, Mutation = "Normal" })
            toast(player, "Fusion! Three duplicates became " .. D.Species[upgradedId].Name .. ".")
            remote:FireClient(player, "Purchase")
            return
        end
    end
    toast(player, "Place 3 of the same species on your pads. Mythics are already the highest tier.")
end

local function assign(player)
    if B.Assignments[player] then
        return
    end

    for _, home in ipairs(world.Plots) do
        if not home.Owner then
            home.Owner = player
            B.Assignments[player] = home
            player:SetAttribute("Plot", home.Index)
            home.Floor:SetAttribute("Owner", player.Name)

            local function spawned(avatar)
                B.Drop(player)
                local pivot = avatar:WaitForChild("HumanoidRootPart", 10)
                if pivot and B.Assignments[player] == home then
                    avatar:PivotTo(CFrame.new(home.Center + Vector3.new(0, 5, 0)))
                end
                local humanoid = avatar:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.Died:Connect(function()
                        B.Drop(player)
                    end)
                end
            end

            player.CharacterAdded:Connect(spawned)
            if player.Character then
                task.spawn(spawned, player.Character)
            end
            return
        end
    end
    toast(player, "All eight plots are occupied. A plot will be assigned when one opens.")
end

function B.Start(w, e, r)
    world = w
    economy = e
    remote = r

    for _, home in ipairs(world.Plots) do
        home.Slots = {}
        for padIndex, platform in ipairs(home.Pads) do
            prompt(platform, "Place / pick up / steal", function(player)
                local occupied = home.Slots[padIndex]
                if occupied then
                    if B.Carried[player] then
                        toast(player, "Your hands are full.")
                        return
                    end
                    if player ~= home.Owner and os.clock() < occupied.Unlock then
                        toast(player, "Locked for " .. math.ceil(occupied.Unlock - os.clock()) .. " seconds.")
                        return
                    end
                    if B.Give(player, occupied.Item) then
                        occupied.Model:Destroy()
                        home.Slots[padIndex] = nil
                        platform.Color = Color3.fromRGB(237, 207, 112)
                    end
                elseif player == home.Owner and B.Carried[player] then
                    local heldItem = B.Carried[player].Item
                    B.Drop(player)
                    place(home, padIndex, heldItem)
                    toast(player, "Placed! Protected from stealing for 60 seconds.")
                elseif player == home.Owner then
                    toast(player, "Buy a creature at the belt, then bring it here.")
                end
            end)
        end
    end

    prompt(world.FusionStand, "Fuse duplicates", B.Fuse)
    prompt(world.SellStand, "Sell carried for 90%", function(player)
        local held = B.Carried[player]
        if held then
            economy.Sell(player, held.Item)
            B.Drop(player)
            remote:FireClient(player, "Purchase")
        end
    end)
    prompt(world.SpeedStand, "Buy next speed tier", function(player)
        toast(player, economy.BuySpeed(player) and "Speed upgraded!" or "Need more cash, or speed is maxed.")
    end)

    Players.PlayerAdded:Connect(assign)
    Players.PlayerRemoving:Connect(function(player)
        B.Drop(player)
        local home = B.Assignments[player]
        if home then
            for _, occupied in pairs(home.Slots) do
                occupied.Model:Destroy()
            end
            home.Slots = {}
            home.Owner = nil
            home.Floor:SetAttribute("Owner", nil)
            for _, platform in ipairs(home.Pads) do
                platform.Color = Color3.fromRGB(237, 207, 112)
            end
            B.Assignments[player] = nil
            task.defer(function()
                for _, participant in ipairs(Players:GetPlayers()) do
                    if participant ~= player then
                        assign(participant)
                    end
                end
            end)
        end
    end)
    for _, participant in ipairs(Players:GetPlayers()) do
        assign(participant)
    end
end

return B
