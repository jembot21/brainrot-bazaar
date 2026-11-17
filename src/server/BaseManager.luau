-- Manage shop ownership, placement, security, theft, and recovery below the plaza.

local BaseManager = {}
local RunService = game:GetService("RunService")
local economy
local feedback
local plots

function BaseManager.Init(economyModule, _characterFactory, remote, worldData)
    economy, feedback, plots = economyModule, remote, worldData.plots
    for _, plot in ipairs(plots) do
        local sign = plot:FindFirstChild("OwnerSign")
        local prompt = sign and sign:FindFirstChild("BaseLockPrompt")
        if prompt then
            prompt.Triggered:Connect(function(player)
                local account = economy.States[player]
                if not account or account.plot ~= plot then
                    return
                end
                local lockedUntil = plot:GetAttribute("LockedUntil") or 0
                if os.time() < lockedUntil then
                    plot:SetAttribute("LockedUntil", 0)
                    feedback:FireClient(player, "message", "BASE UNLOCKED")
                else
                    plot:SetAttribute("LockedUntil", os.time() + 60)
                    feedback:FireClient(player, "message", "BASE LOCKED FOR 60 SECONDS")
                end
            end)
        end
        for _, pad in ipairs(plot.Pads:GetChildren()) do
            pad.Touched:Connect(function(hit) BaseManager.OnPadTouched(plot, pad, hit) end)
        end
    end
    local wrongShopWarningAt = {}
    local rescuedAt = {}
    task.spawn(function()
        while true do
            task.wait(0.15)
            for _, plot in ipairs(plots) do
                local beacon = plot:FindFirstChild("HomeBeacon")
                if beacon then
                    beacon.Transparency = 1
                end
            end
            for player, account in pairs(economy.States) do
                if account.plot then
                    local beacon = account.plot:FindFirstChild("HomeBeacon")
                    if beacon then
                        beacon.Transparency = 0.55
                    end
                end
                local characterRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if characterRoot and characterRoot.Position.Y < -2 then
                    local now = os.clock()
                    if now - (rescuedAt[player] or -math.huge) >= 2 then
                        local plotX, plotZ = player:GetAttribute("PlotX"), player:GetAttribute("PlotZ")
                        local target = CFrame.new(0, 11, 0)
                        if plotX ~= nil and plotZ ~= nil then
                            target = CFrame.new(plotX, 11, plotZ)
                        elseif account.plot then
                            local index = account.plot:GetAttribute("PlotIndex")
                            if index then
                                local angle = (index - 1) * math.pi / 4
                                target = CFrame.new(math.cos(angle) * 82, 11, math.sin(angle) * 82)
                            end
                        end
                        player.Character:PivotTo(target)
                        rescuedAt[player] = now
                        feedback:FireClient(player, "message", "BACK TO YOUR BASE!")
                    end
                end
                if account.carried and account.plot and characterRoot then
                    local beacon = account.plot:FindFirstChild("HomeBeacon")
                    if beacon then
                        beacon.Transparency = 0.25
                    end
                    local placed = false
                    local nearestPad
                    local nearestDistance = math.huge
                    for _, pad in ipairs(account.plot.Pads:GetChildren()) do
                        if not pad:GetAttribute("Occupied") then
                            local delta = characterRoot.Position - pad.Position
                            local distance = Vector2.new(delta.X, delta.Z).Magnitude
                            if distance <= 8.5 and math.abs(delta.Y) <= 12 and distance < nearestDistance then
                                nearestPad = pad
                                nearestDistance = distance
                            end
                        end
                    end
                    if nearestPad then
                        BaseManager.OnPadTouched(account.plot, nearestPad, characterRoot)
                        placed = true
                    end
                    if not placed then
                        for _, pad in ipairs(account.plot.Pads:GetChildren()) do
                            if not pad:GetAttribute("Occupied") then
                                local delta = characterRoot.Position - pad.Position
                                if Vector2.new(delta.X, delta.Z).Magnitude <= 6.5 and math.abs(delta.Y) <= 5 then
                                    BaseManager.OnPadTouched(account.plot, pad, characterRoot)
                                    placed = true
                                    break
                                end
                            end
                        end
                    end
                    if not placed then
                        local now = os.clock()
                        for _, otherPlot in ipairs(plots) do
                            if otherPlot ~= account.plot then
                                for _, pad in ipairs(otherPlot.Pads:GetChildren()) do
                                    if not pad:GetAttribute("Occupied") then
                                        local delta = characterRoot.Position - pad.Position
                                        if Vector2.new(delta.X, delta.Z).Magnitude <= 6.5 and now - (wrongShopWarningAt[player] or -math.huge) >= 5 then
                                            feedback:FireClient(player, "message", "WRONG BASE! FOLLOW THE LIGHT PILLAR TO YOUR BASE")
                                            wrongShopWarningAt[player] = now
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

function BaseManager.AssignPlot(player)
    for _, plot in ipairs(plots) do
        if plot:GetAttribute("OwnerUserId") == 0 then
            plot:SetAttribute("OwnerUserId", player.UserId)
            plot.OwnerSign.OwnerBillboard.OwnerText.Text = player.DisplayName .. "'S BAZAAR"
            local account = economy.States[player]
            account.plot = plot
            local angle = (plot:GetAttribute("PlotIndex") - 1) * math.pi / 4
            player:SetAttribute("PlotX", math.cos(angle) * 82)
            player:SetAttribute("PlotZ", math.sin(angle) * 82)
            return plot
        end
    end
    return nil
end

function BaseManager.OnPadTouched(plot, pad, hit)
    if pad:GetAttribute("Occupied") then
        return
    end
    local character = hit:FindFirstAncestorOfClass("Model")
    local player = character and game:GetService("Players"):GetPlayerFromCharacter(character)
    local account = player and economy.States[player]
    if not account or account.plot ~= plot or not account.carried then
        return
    end
    local carried = account.carried
    local model = carried.model
    account.carried = nil
    model:SetAttribute("OwnerUserId", player.UserId)
    model:SetAttribute("Income", carried.income)
    model:PivotTo(CFrame.new(pad.Position + Vector3.new(0, 2.3, 0)))
    for _, object in ipairs(model:GetDescendants()) do
        if object:IsA("BasePart") then
            object.Anchored = true
        end
    end
    local accessory = model:FindFirstChild("Accessory")
    local prompt = accessory and accessory:FindFirstChild("BrainrotPrompt")
    if prompt then
        prompt.ActionText = "Steal"
        prompt.Enabled = true
        prompt.Triggered:Connect(function(thief) BaseManager.Steal(thief, model) end)
    end
    pad:SetAttribute("Occupied", true)
    carried.model = model
    carried.pad = pad
    table.insert(account.placed, carried)
    feedback:FireClient(player, "message", carried.name .. " placed! +$" .. carried.income .. "/s")
    economy.Sync(player)
end

function BaseManager.Steal(player, model)
    local account = economy.States[player]
    if not account or account.carried then
        return
    end
    local ownerId = model:GetAttribute("OwnerUserId")
    local owner
    for candidate in pairs(economy.States) do
        if candidate.UserId == ownerId then
            owner = candidate; break
        end
    end
    if not owner or owner == player then
        return
    end
    local ownerState = economy.States[owner]
    if not ownerState then
        return
    end
    if ownerState.plot and os.time() < (ownerState.plot:GetAttribute("LockedUntil") or 0) then
        feedback:FireClient(player, "message", "THAT BASE IS LOCKED")
        return
    end
    for index, item in ipairs(ownerState.placed) do
        if item.model == model then
            table.remove(ownerState.placed, index)
            item.pad:SetAttribute("Occupied", false)
            model:SetAttribute("OwnerUserId", 0)
            account.carried = item
            local accessory = model:FindFirstChild("Accessory")
            local prompt = accessory and accessory:FindFirstChild("BrainrotPrompt")
            if prompt then
                prompt.Enabled = false
            end
            local characterRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if characterRoot then
                local look = characterRoot.CFrame.LookVector
                local yaw = math.atan2(-look.X, -look.Z)
                model:PivotTo(CFrame.new(characterRoot.Position + Vector3.new(0, 4.3, 0)) * CFrame.Angles(0, yaw, 0))
            end
            feedback:FireClient(player, "message", "STOLEN! RUN IT HOME")
            economy.Sync(owner)
            return
        end
    end
end

function BaseManager.IsPlayerSafe(player)
    local account = economy.States[player]
    local characterRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not account or not account.plot or not characterRoot then
        return false
    end
    local floor = account.plot:FindFirstChild("BaseFloor")
    return floor ~= nil and (characterRoot.Position - floor.Position).Magnitude < 22
end

function BaseManager.ClearPlayer(player)
    local account = economy.States[player]
    if not account then
        return
    end
    if account.carried then
        account.carried.model:Destroy()
    end
    if account.plot then
        for _, item in ipairs(account.placed) do item.model:Destroy(); item.pad:SetAttribute("Occupied", false) end
        account.plot:SetAttribute("OwnerUserId", 0)
        account.plot:SetAttribute("LockedUntil", 0)
        account.plot.OwnerSign.OwnerBillboard.OwnerText.Text = "OPEN PLOT"
    end
end

return BaseManager
