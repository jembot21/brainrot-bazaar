local RunService = game:GetService("RunService")
local D = require(game.ReplicatedStorage.Shared.BrainrotData)
local Factory = require(script.Parent.CharacterFactory)
local S = {}

function S.Start(world, economy, base, remote)
    local randomSource = Random.new()
    local listings = {}
    local spawnElapsed = 4

    local function spawnOffer()
        local merchandise = D.Roll(randomSource)
        local creature = Factory.Create(merchandise)
        creature.Parent = world.Folder
        local listing = {
            Model = creature,
            Item = merchandise,
            X = -51,
            Busy = false,
        }
        creature:PivotTo(CFrame.new(-51, 4.5, 0))

        local cost = D.Price(merchandise)
        local interaction = Instance.new("ProximityPrompt")
        interaction.ActionText = "Buy $" .. cost
        interaction.ObjectText = D.Species[merchandise.Species].Name
        interaction.MaxActivationDistance = 11
        interaction.RequiresLineOfSight = false
        interaction.HoldDuration = 0.3
        interaction.Parent = creature.PrimaryPart
        interaction.Triggered:Connect(function(player)
            local pivot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if listing.Busy or not creature.Parent or not pivot
                or (pivot.Position - creature.PrimaryPart.Position).Magnitude > 14 then
                return
            end
            if base.Carried[player] then
                remote:FireClient(player, "Toast", "Place or sell your carried creature first.")
                return
            end
            if not base.Assignments[player] then
                return
            end

            listing.Busy = true
            if economy.Spend(player, cost) then
                if base.Give(player, merchandise) then
                    creature:Destroy()
                    remote:FireClient(player, "Purchase")
                    remote:FireClient(player, "Toast", "Carry it home! Place it on an empty pad to earn income.")
                else
                    economy.Credit(player, cost)
                    listing.Busy = false
                end
            else
                remote:FireClient(player, "Toast", "You need $" .. cost .. ".")
                listing.Busy = false
            end
        end)
        table.insert(listings, listing)
    end

    RunService.Heartbeat:Connect(function(deltaTime)
        spawnElapsed += deltaTime
        if spawnElapsed >= 4 then
            spawnElapsed = 0
            if #listings < 10 then
                spawnOffer()
            end
        end

        for listingIndex = #listings, 1, -1 do
            local listing = listings[listingIndex]
            if not listing.Model.Parent then
                table.remove(listings, listingIndex)
            else
                listing.X += deltaTime * 3
                if listing.X > 53 then
                    listing.Model:Destroy()
                    table.remove(listings, listingIndex)
                else
                    listing.Model:PivotTo(CFrame.new(listing.X, 4.5, 0))
                end
            end
        end
    end)
end

return S
