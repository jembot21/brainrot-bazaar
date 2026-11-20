local D = require(game.ReplicatedStorage.Shared.BrainrotData)
local Factory = {}

function Factory.Create(item)
    local speciesInfo = D.Species[item.Species]
    local mutationInfo = D.Mutations[item.Mutation]
    local creature = Instance.new("Model")
    creature.Name = speciesInfo.Name
    creature:SetAttribute("Mutation", item.Mutation)

    local function block(name, size, position, color)
        local piece = Instance.new("Part")
        piece.Name = name
        piece.Size = size
        piece.Position = position
        piece.Color = color
        piece.Material = Enum.Material.SmoothPlastic
        piece.Anchored = true
        piece.CanCollide = false
        piece.CanTouch = false
        piece.TopSurface = Enum.SurfaceType.Smooth
        piece.BottomSurface = Enum.SurfaceType.Smooth
        piece.Parent = creature
        return piece
    end

    local coat = mutationInfo.Color or speciesInfo.Color
    local torso = block("Body", Vector3.new(2, 2.2, 1.4), Vector3.new(0, 1.5, 0), coat)
    creature.PrimaryPart = torso
    local face = block("Head", Vector3.new(2.3, 1.7, 1.7), Vector3.new(0, 3.4, 0), coat)
    for _, horizontal in ipairs({ -0.55, 0.55 }) do
        block("Foot", Vector3.new(0.8, 0.5, 1.4), Vector3.new(horizontal, 0.25, -0.15), speciesInfo.Color)
        block("Eye", Vector3.new(0.4, 0.5, 0.12), Vector3.new(horizontal, 3.55, -0.9), Color3.new(1, 1, 1))
        block("Pupil", Vector3.new(0.17, 0.25, 0.13), Vector3.new(horizontal, 3.55, -0.98), Color3.fromRGB(25, 25, 40))
    end
    block("Smile", Vector3.new(0.65, 0.12, 0.12), Vector3.new(0, 3, -0.91), Color3.fromRGB(40, 25, 50))

    local trim = Color3.fromRGB(255, 234, 136)
    local accessory = speciesInfo.Accessory
    if accessory == "Hat" then
        block("HatBrim", Vector3.new(3, 0.2, 2.2), Vector3.new(0, 4.35, 0), trim)
        block("HatTop", Vector3.new(1.6, 0.9, 1.4), Vector3.new(0, 4.85, 0), trim)
    elseif accessory == "Ears" then
        for _, horizontal in ipairs({ -0.8, 0.8 }) do
            block("Ear", Vector3.new(0.5, 1.6, 0.5), Vector3.new(horizontal, 4.8, 0), trim)
        end
    elseif accessory == "Tail" then
        block("Tail", Vector3.new(0.5, 0.5, 2.5), Vector3.new(0, 1.3, 1.6), trim)
    elseif accessory == "Crown" then
        block("CrownBand", Vector3.new(2.5, 0.3, 1.9), Vector3.new(0, 4.4, 0), trim)
        for horizontal = -1, 1 do
            block("CrownPoint", Vector3.new(0.4, 0.8, 0.4), Vector3.new(horizontal, 4.9, 0), trim)
        end
    elseif accessory == "Orbit" then
        for starIndex = 1, 6 do
            local radians = starIndex * math.pi / 3
            block(
                "OrbitStar",
                Vector3.new(0.45, 0.45, 0.45),
                Vector3.new(math.cos(radians) * 1.8, 4.5, math.sin(radians) * 1.8),
                trim
            )
        end
    elseif accessory == "Goggles" then
        block("GoggleBar", Vector3.new(2.6, 0.2, 0.2), Vector3.new(0, 3.6, -1.05), trim)
    elseif accessory == "Wings" then
        for _, side in ipairs({ -1, 1 }) do
            local feather = block("Wing", Vector3.new(1.8, 0.4, 2), Vector3.new(side * 1.8, 2, 0.6), trim)
            feather.Orientation = Vector3.new(0, 0, side * 25)
        end
    end

    if item.Mutation == "Rainbow" then
        local partCount = 0
        for _, piece in ipairs(creature:GetChildren()) do
            if piece:IsA("BasePart") then
                partCount += 1
                piece.Color = Color3.fromHSV((partCount * 0.13) % 1, 0.7, 1)
            end
        end
        local glimmer = Instance.new("Sparkles")
        glimmer.SparkleColor = mutationInfo.Color
        glimmer.Parent = torso
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BrainrotLabel"
    billboard.Size = UDim2.fromScale(6.5, 2)
    billboard.StudsOffset = Vector3.new(0, 2.8, 0)
    billboard.MaxDistance = 85
    billboard.AlwaysOnTop = false
    billboard.Parent = face

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.fromScale(1, 1)
    title.BackgroundTransparency = 1
    title.Text = speciesInfo.Name .. "\n" .. item.Mutation .. " • $" .. D.Income(item) .. "/s"
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.TextColor3 = mutationInfo.Color or Color3.fromRGB(244, 250, 255)
    title.TextStrokeTransparency = 0.65
    title.ZIndex = 2
    title.Parent = billboard

    local backdrop = title:Clone()
    backdrop.Name = "DropShadow"
    backdrop.Position = UDim2.fromScale(0.012, 0.035)
    backdrop.TextColor3 = Color3.fromRGB(15, 22, 36)
    backdrop.TextTransparency = 0.35
    backdrop.TextStrokeTransparency = 1
    backdrop.ZIndex = 1
    backdrop.Parent = billboard
    return creature
end

return Factory
