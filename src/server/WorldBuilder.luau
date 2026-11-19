local CollectionService = game:GetService("CollectionService")

local WorldBuilder = {}
local root

local function block(name, size, position, color, material, parent, tag)
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.Position = position
	item.Color = color
	item.Material = material or Enum.Material.SmoothPlastic
	item.Anchored = true
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item.Parent = parent or root
	CollectionService:AddTag(item, tag or "Island")
	return item
end

local function sign(name, text, position, color)
	local board = block(name, Vector3.new(5, 2.3, 0.35), position, color, Enum.Material.WoodPlanks)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.Parent = board
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Text = text
	label.Parent = gui
	return board
end

local function palm(x, z)
	local trunk = block("PalmTrunk", Vector3.new(1.1, 11, 1.1), Vector3.new(x, 6.1, z), Color3.fromRGB(126, 88, 56), Enum.Material.Wood)
	trunk.Orientation = Vector3.new(0, 0, 7)
	for ring = 1, 2 do
		local y = 11.2 + (ring - 1) * 0.48
		for i = 1, 7 do
			local angle = math.rad((i - 1) * (360 / 7) + ring * 16)
			local frond = block("PalmFrond", Vector3.new(1.0, 0.35, 6.5), Vector3.new(x + math.cos(angle) * 2.0, y, z + math.sin(angle) * 2.0), ring == 1 and Color3.fromRGB(53, 149, 93) or Color3.fromRGB(75, 177, 107), Enum.Material.Grass)
			frond.Orientation = Vector3.new(0, -math.deg(angle), -12)
		end
	end
end

local function makeBase(index)
	local row = math.floor((index - 1) / 4)
	local col = (index - 1) % 4
	local x = (col - 1.5) * 54
	local z = (row - 0.5) * 54 + 37
	local folder = Instance.new("Model")
	folder.Name = "Plot" .. index
	folder:SetAttribute("PlotIndex", index)
	folder.Parent = root
	CollectionService:AddTag(folder, "PlayerBase")
	block("BaseFloor", Vector3.new(48, 1, 42), Vector3.new(x, 1.6, z), Color3.fromRGB(91, 194, 145), Enum.Material.Grass, folder, "PlayerBase")
	block("BaseBorder", Vector3.new(48, 0.5, 1), Vector3.new(x, 2.3, z - 20), Color3.fromRGB(240, 218, 151), Enum.Material.Sand, folder, "PlayerBase")
	for padIndex = 1, 6 do
		local padCol = (padIndex - 1) % 3
		local padRow = math.floor((padIndex - 1) / 3)
		local padX = x + (padCol - 1) * 12
		local padZ = z - 5 + padRow * 13
		local pad = block("Pad" .. padIndex, Vector3.new(9, 0.7, 9), Vector3.new(padX, 2.45, padZ), Color3.fromRGB(76, 214, 188), Enum.Material.Neon, folder, "BrainrotPad")
		pad:SetAttribute("PlotIndex", index)
		pad:SetAttribute("PadIndex", padIndex)
		pad:SetAttribute("Occupied", false)
	end
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "PlotSpawn"
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.Position = Vector3.new(x, 2.5, z + 14)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Parent = folder
	return { Index = index, Model = folder, Center = Vector3.new(x, 2, z), Spawn = spawn }
end

function WorldBuilder.Build()
	local existing = workspace:FindFirstChild("BrainrotIsland")
	if existing then
		existing:Destroy()
	end
	root = Instance.new("Model")
	root.Name = "BrainrotIsland"
	root.Parent = workspace
	block("Island", Vector3.new(248, 4, 190), Vector3.new(0, -1, 0), Color3.fromRGB(81, 183, 129), Enum.Material.Grass)
	block("BeachRing", Vector3.new(270, 3, 212), Vector3.new(0, -2, 0), Color3.fromRGB(241, 218, 155), Enum.Material.Sand)
	block("OceanFloor", Vector3.new(550, 4, 500), Vector3.new(0, -6, 0), Color3.fromRGB(38, 148, 188), Enum.Material.Sand, workspace, "Ocean")
	block("TidePool", Vector3.new(280, 2, 220), Vector3.new(0, -3.2, 0), Color3.fromRGB(52, 173, 205), Enum.Material.Water, root, "Ocean")
	block("MainLand", Vector3.new(242, 3, 184), Vector3.new(0, 0.3, 0), Color3.fromRGB(91, 194, 145), Enum.Material.Grass)
	block("HighGroundHill", Vector3.new(46, 18, 38), Vector3.new(0, 8, -60), Color3.fromRGB(91, 159, 111), Enum.Material.Grass, root, "HighGround")
	block("HighGroundPlatform", Vector3.new(34, 2, 29), Vector3.new(0, 18, -60), Color3.fromRGB(224, 201, 131), Enum.Material.Sand, root, "HighGround")
	for step = 0, 8 do
		block(
			"HighGroundStep" .. (step + 1),
			Vector3.new(4.5, 2, 17),
			Vector3.new(41 - step * 2.25, 2.8 + step * 1.8, -60),
			Color3.fromRGB(125, 197, 125),
			Enum.Material.Grass,
			root,
			"HighGround"
		)
	end
	for _, p in ipairs({ { -105, -67 }, { 107, -61 }, { -109, 55 }, { 110, 57 }, { -72, -80 }, { 73, -82 }, { -72, 83 }, { 73, 81 } }) do
		palm(p[1], p[2])
	end
	for index = 1, 8 do
		makeBase(index)
	end

	local belt = block("OfferBelt", Vector3.new(44, 1, 10), Vector3.new(0, 2, -2), Color3.fromRGB(56, 76, 92), Enum.Material.Metal, root, "SpawnerArea")
	belt:SetAttribute("OfferBelt", true)
	sign("BeltSign", "BRAINROT BELT", Vector3.new(0, 5, -8), Color3.fromRGB(222, 120, 77))
	for tier = 1, 3 do
		local x = -44 + tier * 44
		local stand = block("ShopStand" .. tier, Vector3.new(13, 3, 9), Vector3.new(x, 2.5, -41), Color3.fromRGB(100 + tier * 24, 128, 212 - tier * 24), Enum.Material.SmoothPlastic, root, "ShopStand")
		stand:SetAttribute("ShopType", tier == 1 and "Speed" or tier == 2 and "Rebirth" or "Sell")
		sign("ShopSign" .. tier, tier == 1 and "SPEED" or tier == 2 and "REBIRTH" or "SELL", Vector3.new(x, 5.4, -46), stand.Color)
	end
	for i = 1, 310 do
		local x = ((i * 37) % 220) - 110
		local z = ((i * 61) % 158) - 78
		if not (math.abs(x) < 25 and math.abs(z) < 56) then
			local kind = i % 5
			local name = ({ "IslandRock", "BeachBush", "TrailFence", "DockLamp", "SupplyCrate" })[kind + 1]
			local y = kind == 2 and 1.7 or 2.3
			local size = kind == 0 and Vector3.new(2.2, 1.6, 1.7) or kind == 1 and Vector3.new(2.4, 1.5, 2.2) or kind == 2 and Vector3.new(3.5, 1.3, 0.55) or kind == 3 and Vector3.new(0.7, 4.7, 0.7) or Vector3.new(1.8, 1.8, 1.8)
			local color = kind == 0 and Color3.fromRGB(124, 129, 123) or kind == 1 and Color3.fromRGB(63, 153, 96) or kind == 2 and Color3.fromRGB(209, 183, 127) or kind == 3 and Color3.fromRGB(235, 217, 132) or Color3.fromRGB(157, 112, 76)
			local deco = block(name .. i, size, Vector3.new(x, y, z), color, kind == 0 and Enum.Material.Rock or Enum.Material.Wood, root, "IslandDecoration")
			if kind == 0 or kind == 1 then
				deco.Shape = Enum.PartType.Ball
			elseif kind == 3 then
				local light = Instance.new("PointLight")
				light.Color = color
				light.Range = 12
				light.Brightness = 0.8
				light.Parent = deco
			end
		end
	end
	return { Root = root, Bases = root:GetChildren(), Belt = belt }
end

return WorldBuilder
