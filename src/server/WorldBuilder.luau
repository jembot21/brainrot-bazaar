local Tags = game:GetService("CollectionService")
local W = { Plots = {} }

function W.Build()
    local islandFolder = Instance.new("Folder")
    islandFolder.Name = "TideglassIsland"
    islandFolder.Parent = workspace
    W.Folder = islandFolder

    local function part(name, size, pos, color, area, material)
        local piece = Instance.new("Part")
        piece.Name = name
        piece.Anchored = true
        piece.Size = size
        piece.Position = pos
        piece.Color = color
        piece.Material = material or Enum.Material.SmoothPlastic
        piece.TopSurface = Enum.SurfaceType.Smooth
        piece.BottomSurface = Enum.SurfaceType.Smooth
        piece:SetAttribute("Area", area)
        Tags:AddTag(piece, area)
        piece.Parent = islandFolder
        return piece
    end
    W.Part = part

    part("OceanFloor", Vector3.new(800, 3, 800), Vector3.new(0, -12, 0), Color3.fromRGB(36, 103, 136), "Ocean", Enum.Material.Sand)
    local sea = part("Ocean", Vector3.new(790, 1, 790), Vector3.new(0, -3, 0), Color3.fromRGB(38, 158, 201), "Ocean")
    sea.Transparency = 0.3
    sea.CanCollide = false
    part("BeachRing", Vector3.new(300, 3, 300), Vector3.new(0, -1.5, 0), Color3.fromRGB(245, 216, 155), "Beach", Enum.Material.Sand)
    part("IslandGround", Vector3.new(268, 3, 268), Vector3.new(0, -0.5, 0), Color3.fromRGB(99, 180, 110), "Island", Enum.Material.Grass)

    for plotIndex = 1, 8 do
        local column = (plotIndex - 1) % 4
        local rowIndex = math.floor((plotIndex - 1) / 4)
        local origin = Vector3.new(-99 + column * 66, 1.2, rowIndex == 0 and -91 or 91)
        local home = { Center = origin, Pads = {}, Index = plotIndex }
        home.Floor = part("Base" .. plotIndex, Vector3.new(54, 0.6, 48), origin, Color3.fromRGB(60 + plotIndex * 10, 102, 139), "Base")
        for padIndex = 1, 6 do
            local location = origin + Vector3.new(
                ((padIndex - 1) % 3 - 1) * 15,
                0.9,
                (math.floor((padIndex - 1) / 3) - 0.5) * 22
            )
            home.Pads[padIndex] = part(
                "Plot" .. plotIndex .. "Pad" .. padIndex,
                Vector3.new(10, 1, 9),
                location,
                Color3.fromRGB(237, 207, 112),
                "Pads",
                Enum.Material.Neon
            )
        end
        W.Plots[plotIndex] = home
    end

    W.Belt = part("OfferBelt", Vector3.new(112, 1, 12), Vector3.new(0, 2, 0), Color3.fromRGB(40, 53, 72), "Market", Enum.Material.Metal)
    for horizontal = -54, 54, 6 do
        part("BeltStripe", Vector3.new(0.4, 0.08, 11), Vector3.new(horizontal, 2.55, 0), Color3.fromRGB(95, 218, 213), "Market")
    end
    for _, horizontal in ipairs({ -95, 95 }) do
        part("HighGroundRefuge", Vector3.new(32, 3, 40), Vector3.new(horizontal, 23, 0), Color3.fromRGB(116, 129, 141), "HighGround", Enum.Material.Slate)
        for stairIndex = 1, 12 do
            part(
                "RefugeStep" .. stairIndex,
                Vector3.new(16, 2, 4),
                Vector3.new(horizontal, stairIndex * 2 - 1, 49 - stairIndex * 4),
                Color3.fromRGB(148, 153, 153),
                "HighGround",
                Enum.Material.Slate
            )
        end
    end

    local function stand(name, x, z, color)
        local counter = part(name, Vector3.new(14, 3, 9), Vector3.new(x, 2.5, z), color, "Shops")
        part(name .. "Roof", Vector3.new(18, 1, 12), Vector3.new(x, 10, z), color, "Shops")
        for _, offset in ipairs({ -6, 6 }) do
            part(name .. "Post", Vector3.new(0.8, 7, 0.8), Vector3.new(x + offset, 6, z), Color3.fromRGB(111, 76, 57), "Shops")
        end

        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.fromScale(8, 1.5)
        billboard.StudsOffset = Vector3.new(0, 6, 0)
        billboard.MaxDistance = 100
        billboard.Parent = counter
        local caption = Instance.new("TextLabel")
        caption.Size = UDim2.fromScale(1, 1)
        caption.BackgroundTransparency = 1
        caption.Text = name
        caption.TextScaled = true
        caption.Font = Enum.Font.GothamBold
        caption.TextColor3 = Color3.new(1, 1, 1)
        caption.Parent = billboard
        return counter
    end

    W.SpeedStand = stand("Speed Shop", -35, -32, Color3.fromRGB(66, 180, 218))
    W.SellStand = stand("Sell Carried", 0, -32, Color3.fromRGB(239, 164, 73))
    W.FusionStand = stand("Fusion Corner", 35, -32, Color3.fromRGB(176, 105, 226))

    local arrival = Instance.new("SpawnLocation")
    arrival.Name = "IslandArrival"
    arrival.Size = Vector3.new(12, 1, 12)
    arrival.Position = Vector3.new(0, 2, 35)
    arrival.Anchored = true
    arrival.Neutral = true
    arrival.Duration = 0
    arrival.Parent = islandFolder
    Tags:AddTag(arrival, "Arrival")

    -- Each of the twenty palms uses parts for a wide canopy in two layers.
    for palmIndex = 1, 20 do
        local radians = palmIndex * math.pi * 2 / 20
        local horizontal = math.cos(radians) * 139
        local depth = math.sin(radians) * 139
        part("PalmTrunk" .. palmIndex, Vector3.new(2, 14, 2), Vector3.new(horizontal, 6, depth), Color3.fromRGB(132, 91, 58), "Beach", Enum.Material.Wood)
        for canopyLayer = 1, 2 do
            for spoke = 0, 2 do
                local frond = part(
                    "PalmFrond",
                    Vector3.new(19 - canopyLayer * 2, 0.7, 4),
                    Vector3.new(horizontal, 12 + canopyLayer * 1.2, depth),
                    Color3.fromRGB(45, 133 + canopyLayer * 15, 76),
                    "Beach",
                    Enum.Material.Grass
                )
                frond.Orientation = Vector3.new(0, spoke * 60 + canopyLayer * 25, canopyLayer == 1 and 8 or -8)
            end
        end
    end

    local sceneryRandom = Random.new(927)
    -- Put the 250 additional decorations around the beach edge to leave routes open.
    for decorIndex = 1, 250 do
        local radians = sceneryRandom:NextNumber() * math.pi * 2
        local distance = sceneryRandom:NextNumber(136, 147)
        local location = Vector3.new(math.cos(radians) * distance, 1, math.sin(radians) * distance)
        local category = decorIndex % 5
        if category == 0 then
            local rock = part("BeachRock", Vector3.new(3, 2, 3), location, Color3.fromRGB(137, 148, 154), "Decor", Enum.Material.Slate)
            rock.Shape = Enum.PartType.Ball
        elseif category == 1 then
            local shrub = part("Bush", Vector3.new(4, 3, 4), location, Color3.fromRGB(53, 137, 77), "Decor", Enum.Material.Grass)
            shrub.Shape = Enum.PartType.Ball
        elseif category == 2 then
            local railing = part("Fence", Vector3.new(5, 2.5, 0.5), location, Color3.fromRGB(173, 127, 79), "Decor", Enum.Material.Wood)
            railing.Orientation = Vector3.new(0, math.deg(radians), 0)
        elseif category == 3 then
            local lantern = part("Lamp", Vector3.new(1, 5, 1), location + Vector3.new(0, 1.5, 0), Color3.fromRGB(255, 223, 139), "Decor", Enum.Material.Neon)
            local glow = Instance.new("PointLight")
            glow.Range = 10
            glow.Brightness = 0.5
            glow.Parent = lantern
        else
            part("Crate", Vector3.new(3, 3, 3), location, Color3.fromRGB(163, 112, 66), "Decor", Enum.Material.WoodPlanks)
        end
    end
    game:GetService("Lighting").ClockTime = 14
    return W
end

return W
