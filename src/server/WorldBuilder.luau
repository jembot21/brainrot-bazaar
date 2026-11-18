local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WorldBuilder = {}
WorldBuilder.Data = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotData"))

local sand = Color3.fromRGB(245, 202, 123)
local navy = Color3.fromRGB(21, 37, 57)
local mint = Color3.fromRGB(93, 243, 187)
local orange = Color3.fromRGB(255, 145, 69)

local function part(parent, name, size, frame, color, material)
	local piece = Instance.new("Part")
	piece.Name = name
	piece.Size = size
	piece.CFrame = frame
	piece.Color = color
	piece.Material = material or Enum.Material.SmoothPlastic
	piece.Anchored = true
	piece.Parent = parent
	return piece
end

local function sign(parent, name, position, title, accent, width)
	local board = part(parent, name, Vector3.new(0.7, 4, width or 16), CFrame.new(position), navy)
	for _, face in ipairs({Enum.NormalId.Left, Enum.NormalId.Right}) do
		local surface = Instance.new("SurfaceGui")
		surface.Face = face
		surface.CanvasSize = Vector2.new(640, 160)
		surface.Parent = board
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(0.94, 0.86)
		label.Position = UDim2.fromScale(0.03, 0.07)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamBlack
		label.TextColor3 = accent
		label.TextScaled = true
		label.Text = title
		label.Parent = surface
	end
	return board
end

local function ramp(parent, name, from, to, width, color)
	local length = (to - from).Magnitude
	local frame = CFrame.lookAt((from + to) / 2, to)
	return part(parent, name, Vector3.new(width, 1, length), frame * CFrame.new(0, -0.5, 0), color)
end

local function prompt(parent, action, object)
	local button = Instance.new("ProximityPrompt")
	button.ActionText = action
	button.ObjectText = object
	button.MaxActivationDistance = 9
	button.RequiresLineOfSight = false
	button.Parent = parent
	return button
end

local function spawnLocation(parent, name, x, surfaceY, z)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = name
	spawn.Size = Vector3.new(5, 0.2, 5)
	spawn.CFrame = CFrame.lookAt(Vector3.new(x, surfaceY, z), Vector3.new(x - 1, surfaceY, z))
	spawn.Anchored = true
	spawn.CanCollide = false
	spawn.CanTouch = false
	spawn.CanQuery = false
	spawn.Transparency = 1
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Parent = parent
	return spawn
end

-- Scenery stays out of pad touches, travel, and the wave's ground raycast.
local function ornament(piece)
	piece.CanCollide = false
	piece.CanTouch = false
	piece.CanQuery = false
	return piece
end

local function decorPart(parent, name, size, frame, color, material)
	return ornament(part(parent, name, size, frame, color, material))
end

local function ball(parent, name, size, frame, color, material)
	local piece = decorPart(parent, name, size, frame, color, material)
	piece.Shape = Enum.PartType.Ball
	return piece
end

local function cylinder(parent, name, diameter, height, frame, color, material)
	local piece = decorPart(parent, name, Vector3.new(height, diameter, diameter),
		frame * CFrame.Angles(0, 0, math.pi / 2), color, material)
	piece.Shape = Enum.PartType.Cylinder
	return piece
end

local function palmFronds(parent, crown, count, size, color, yawOffset, tilt, reach, rootHeight)
	-- Local +X points outward. At zero yaw, the lower blade spans X = -0.50 to 6.30
	-- relative to the crown, crossing the trunk axis about 0.10 studs below the crown centre.
	local drop = size.X / 2 * math.sin(tilt)
	for index = 0, count - 1 do
		local yaw = CFrame.Angles(0, yawOffset + index * 2 * math.pi / count, 0)
		local frame = crown * yaw * CFrame.new(reach, rootHeight - drop, 0) * CFrame.Angles(0, 0, -tilt)
		decorPart(parent, "PalmFrond", size, frame, color)
	end
end

local function palm(parent, palette, ground)
	local segmentLength = 2.2
	local trunkTop = ground
	for segment = 1, 4 do
		local lean = CFrame.Angles(0, 0, -math.rad(4 + segment * 2))
		local center = trunkTop + lean.UpVector * (segmentLength / 2)
		cylinder(parent, "PalmTrunk", 1.15, segmentLength, CFrame.new(center) * lean, palette.Trunk, Enum.Material.Wood)
		trunkTop += lean.UpVector * (segmentLength - 0.04)
	end

	local crown = CFrame.new(trunkTop)
	palmFronds(parent, crown, palette.FrondCount, palette.FrondSize, palette.Frond, 0, palette.FrondTilt, 2.9, 0.24)
	palmFronds(parent, crown, palette.FrondTopCount, palette.FrondTopSize, palette.FrondLight, math.rad(36),
		palette.FrondTopTilt, 2.1, 0.35)

	for index = 0, 2 do
		local yaw = CFrame.Angles(0, index * 2 * math.pi / 3, 0)
		ball(parent, "Coconut", palette.CoconutSize, crown * yaw * CFrame.new(0.48, -0.5, 0), palette.Coconut)
	end
end

local function planter(parent, palette, ground)
	decorPart(parent, "PalmPlanter", palette.PlanterSize, CFrame.new(ground + Vector3.new(0, palette.PlanterSize.Y / 2, 0)),
		palette.Coconut, Enum.Material.WoodPlanks)
	palm(parent, palette, ground + Vector3.new(0, palette.PlanterSize.Y, 0))
end

local function lifeguardTower(parent, palette)
	local center = CFrame.new(-84, 0, 38)
	for _, x in ipairs({-1, 1}) do
		for _, z in ipairs({-1, 1}) do
			local foot = Vector3.new(x * 3.2, 0.5, z * 3.2)
			local top = Vector3.new(x * 2.5, 5.85, z * 2.5)
			local leg = CFrame.lookAt((foot + top) / 2, top)
			decorPart(parent, "LifeguardLeg", Vector3.new(0.55, 0.55, (top - foot).Magnitude),
				center * leg, palette.Trunk, Enum.Material.Wood)
			decorPart(parent, "LifeguardPost", Vector3.new(0.35, 3, 0.35),
				center * CFrame.new(x * 2.5, 8, z * 2.5), palette.Trunk, Enum.Material.Wood)
		end
	end
	decorPart(parent, "LifeguardPlatform", Vector3.new(7, 1, 7), center * CFrame.new(0, 6, 0),
		palette.Trunk, Enum.Material.WoodPlanks)
	for index = 0, 3 do
		local roofSide = center * CFrame.new(0, 10, 0) * CFrame.Angles(0, index * math.pi / 2, 0)
		decorPart(parent, "LifeguardRoof", Vector3.new(7.3, 0.3, 2.8),
			roofSide * CFrame.new(0, 0.2, 2.25) * CFrame.Angles(0.38, 0, 0), orange)
	end
	decorPart(parent, "LifeguardRoofCap", Vector3.new(2.1, 0.38, 2.1),
		center * CFrame.new(0, 10.8, 0) * CFrame.Angles(0, math.pi / 4, 0), orange)
	for _, z in ipairs({-0.95, 0.95}) do
		decorPart(parent, "LadderRail", Vector3.new(0.26, 5.5, 0.26),
			center * CFrame.new(3.8, 3.2, z) * CFrame.Angles(0, 0, 0.1), palette.Coconut, Enum.Material.Wood)
	end
	for rung = 1, 4 do
		decorPart(parent, "LadderRung", Vector3.new(0.35, 0.2, 2.1),
			center * CFrame.new(4.05 - rung * 0.1, 0.7 + rung * 1.12, 0), palette.Trunk, Enum.Material.Wood)
	end
	local board = ornament(sign(parent, "LifeguardSign", Vector3.new(-80.35, 8.1, 38), "LIFEGUARD", orange, 6.5))
	board.Size = Vector3.new(0.3, 1.25, 6.5)
end

local function buildDecorations(world, palette)
	local folder = Instance.new("Folder")
	folder.Name = "Decorations"
	folder.Parent = world

	for _, ground in ipairs({
		Vector3.new(-84, 0.5, -70), Vector3.new(-84, 0.5, -18),
		Vector3.new(-84, 0.5, 58), Vector3.new(-84, 0.5, 76),
		Vector3.new(-22, 0.5, -52), Vector3.new(-22, 0.5, 64),
		Vector3.new(0, 0, -84), Vector3.new(0, 0, 84),
		Vector3.new(30, 0, 88), Vector3.new(44, 0, -32),
	}) do
		palm(folder, palette, ground)
	end
	for _, z in ipairs({-86, 86}) do
		planter(folder, palette, Vector3.new(68, 4, z))
	end

	for _, center in ipairs({
		Vector3.new(-70, 0.5, 62), Vector3.new(-38, 0.5, -64),
		Vector3.new(-5, 0, -88), Vector3.new(35, 0, -90), Vector3.new(9, 0, -56),
	}) do
		local stoneCount = center.X == 9 and 3 or 2
		for index = 1, stoneCount do
			local size = Vector3.new(3.5 - 0.55 * index, 2 - 0.3 * index, 2.6 - 0.35 * index)
			local frame = CFrame.new(center + Vector3.new((index - 2) * 1.65, size.Y * 0.25, index % 2))
			ball(folder, "BeachStone", size, frame * CFrame.Angles(0, index * 0.8, 0), palette.Rock, Enum.Material.Slate)
		end
	end
	for _, z in ipairs({-45, 45, -85, 85}) do
		ball(folder, "FloweringBush", Vector3.new(4, 2.2, 3.6), CFrame.new(58, 0.8, z), palette.Bush, Enum.Material.Grass)
		for index, color in ipairs(palette.Flowers) do
			local side = index - 2
			ball(folder, "BushFlower", palette.FlowerSize, CFrame.new(58 + side, 1.9 - math.abs(side) * 0.12, z + side * 0.3), color)
		end
	end
	for _, center in ipairs({Vector3.new(10, 0.17, -70), Vector3.new(25, 0.17, 70), Vector3.new(40, 0.17, -55)}) do
		for index = 1, 6 do
			local angle = index * math.pi / 3
			local offset = Vector3.new(math.cos(angle) * 1.45, 0, math.sin(angle) * 1.45)
			ball(folder, "GrassFlower", palette.FlowerSize, CFrame.new(center + offset), palette.Flowers[(index - 1) % #palette.Flowers + 1])
		end
	end

	for _, center in ipairs({
		Vector3.new(-60, 0.55, -40), Vector3.new(-40, 0.55, 45),
		Vector3.new(-75, 0.55, 30), Vector3.new(-30, 0.55, -70),
	}) do
		local frame = CFrame.new(center)
		ball(folder, "Starfish", Vector3.new(1.32, 0.19, 1.15), frame, orange)
		ball(folder, "PinkShell", Vector3.new(0.62, 0.32, 0.48), frame * CFrame.new(1.35, 0, 0.65), palette.Flowers[1])
		ball(folder, "IvoryShell", Vector3.new(0.45, 0.25, 0.58), frame * CFrame.new(-1.05, 0, 0.88), palette.Flowers[3])
	end
	for index, center in ipairs({Vector3.new(-70, 0.58, 52), Vector3.new(-38, 0.58, -52), Vector3.new(-72, 0.58, -30)}) do
		local frame = CFrame.new(center) * CFrame.Angles(0, (index - 2) * 0.26, 0)
		decorPart(folder, "BeachTowel", palette.TowelSize, frame, palette.Towels[index], Enum.Material.Fabric)
		for _, z in ipairs({-2.75, 2.75}) do
			decorPart(folder, "TowelStripe", Vector3.new(palette.TowelSize.X, 0.02, 0.48),
				frame * CFrame.new(0, 0.08, z), palette.Flowers[3], Enum.Material.Fabric)
		end
		if index <= 2 then
			decorPart(folder, "BeachCrate", Vector3.new(1.7, 1.6, 1.7), frame * CFrame.new(-3.1, 0.72, 1.4),
				palette.Trunk, Enum.Material.WoodPlanks)
			local barrel = frame * CFrame.new(-3.1, 0.92, -1.2)
			cylinder(folder, "BeachBarrel", 1.65, 2, barrel, palette.Trunk, Enum.Material.WoodPlanks)
		end
	end
	lifeguardTower(folder, palette)

	for _, x in ipairs({30, 46}) do
		for _, z in ipairs({-18, 18}) do
			local frame = CFrame.new(x, 0, z)
			cylinder(folder, "TikiPole", 0.44, 4, frame * CFrame.new(0, 2, 0), palette.Coconut, Enum.Material.Wood)
			cylinder(folder, "TikiCup", 0.9, 0.45, frame * CFrame.new(0, 3.9, 0), palette.Trunk)
			local flame = ball(folder, "TikiFlame", Vector3.new(0.68, 0.93, 0.68),
				frame * CFrame.new(0, 4.42, 0), palette.TorchFlame, Enum.Material.Neon)
			local light = Instance.new("PointLight")
			light.Color = palette.TorchFlame
			light.Range = 9
			light.Brightness = 0.8
			light.Parent = flame
		end
	end

	for _, center in ipairs({
		Vector3.new(-82, 59, -77), Vector3.new(-78, 65, 77),
		Vector3.new(92, 68, -83), Vector3.new(95, 55, 84),
	}) do
		for index = 1, 3 do
			local size = Vector3.new(19 + index * 1.8, 4.4 + index * 0.55, 10 + index)
			local puff = ball(folder, "CloudPuff", size, CFrame.new(center + Vector3.new((index - 2) * 9, index % 2, index * 1.8)),
				Color3.fromRGB(253, 254, 255))
			puff.CastShadow = false
		end
	end
	for _, z in ipairs({-50, 0, 50}) do
		local frame = CFrame.new(-115, -0.5, z)
		cylinder(folder, "OceanBuoy", 2.6, 3, frame, Color3.fromRGB(235, 63, 67))
		cylinder(folder, "BuoyStripe", 2.66, 0.52, frame * CFrame.new(0, 0.3, 0), palette.Flowers[3])
	end
	for _, z in ipairs({-14, 14}) do
		ornament(sign(folder, "BeachWarning", Vector3.new(-14, 3, z), "WATCH FOR WAVES", orange, 8))
	end
end

function WorldBuilder.Build()
	local data = WorldBuilder.Data
	workspace.Baseplate.CanCollide = false
	workspace.Baseplate.Transparency = 1
	workspace.Baseplate.CanTouch = false
	workspace.Baseplate.CanQuery = false
	local world = Instance.new("Folder")
	world.Name = "TsunamiIsland"
	world.Parent = workspace

	part(world, "OceanSide", Vector3.new(490, 3, 440), CFrame.new(0, -4, 0), Color3.fromRGB(28, 137, 194), Enum.Material.Glass)
	part(world, "Island", Vector3.new(210, 6, 192), CFrame.new(15, -3, 0), Color3.fromRGB(109, 180, 127), Enum.Material.Grass)
	part(world, "Beach", Vector3.new(72, 1, 192), CFrame.new(-54, 0, 0), sand, Enum.Material.Sand)
	part(world, "ConveyorRunway", Vector3.new(58, 1, 12), CFrame.new(-49, 6.9, 0), navy, Enum.Material.Metal)
	for x = -74, -24, 5 do
		local stripe = part(world, "BeltStripe", Vector3.new(0.6, 0.05, 11), CFrame.new(x, 7.42, 0), mint, Enum.Material.Neon)
		stripe.CanCollide = false
	end
	for _, x in ipairs({-68, -33}) do
		for _, side in ipairs({-1, 1}) do
			ramp(world, "BeachAccessRamp", Vector3.new(x, 0.5, side * 25), Vector3.new(x, 7.4, side * 6), 8, navy)
		end
	end
	for _, z in ipairs({-31, 31}) do
		sign(world, "BeachWayfinding", Vector3.new(-20, 3, z), "BEACH BELT\nCATCH & RUN", mint, 13)
	end
	sign(world, "BeachMarquee", Vector3.new(-79, 12, 0), "BRAINROT\nTSUNAMI ESCAPE", mint, 25)

	local heights = {0, 7, 14, 20}
	for index, z in ipairs({-48, 48}) do
		local tower = Instance.new("Folder")
		tower.Name = index == 1 and "HighTowerA" or "HighTowerB"
		tower.Parent = world
		for level = 1, 3 do
			local y = heights[level + 1]
			local fromY = heights[level]
			local x = -12 + 21 * level
			part(tower, "Platform" .. level, Vector3.new(9, 1, 12), CFrame.new(x, y - 0.5, z), navy)
			part(tower, "Support" .. level, Vector3.new(2, y - 1, 2), CFrame.new(x, (y - 1) / 2, z), navy, Enum.Material.Metal)
			ramp(tower, "Ramp" .. level, Vector3.new(x - 16.5, fromY, z), Vector3.new(x - 4.5, y, z), 9, orange)
		end
		sign(tower, "RefugeSign", Vector3.new(56, 23, z), "HIGH GROUND\n20 STUDS", mint, 12)
	end

	part(world, "BaseTerrace", Vector3.new(55, 4, 184), CFrame.new(91.5, 2, 0), Color3.fromRGB(195, 204, 220), Enum.Material.Concrete)
	for _, z in ipairs({-67.5, -22.5, 22.5, 67.5}) do
		ramp(world, "TerraceRamp", Vector3.new(55, 0, z), Vector3.new(64, 4, z), 10, navy)
	end
	local plots = {}
	for row = 1, 4 do
		for column = 1, 2 do
			local number = #plots + 1
			local x = column == 1 and 78 or 105
			local z = -67.5 + (row - 1) * 45
			local plotFolder = Instance.new("Folder")
			plotFolder.Name = "BasePlot" .. number
			plotFolder.Parent = world
			local accent = Color3.fromHSV((number - 1) / 8, 0.48, 1)
			local floor = part(plotFolder, "PlotFloor", Vector3.new(25, 0.3, 39), CFrame.new(x, 4.15, z), navy)
			local board = sign(plotFolder, "OwnerSign", Vector3.new(x + 10, 8, z - 12), "OPEN PLOT", accent, 10)
			local pads = {}
			for slot = 1, 6 do
				local padX = x + (slot <= 3 and -5 or 5)
				local padZ = z + ((slot - 1) % 3 - 1) * 8
				pads[slot] = part(plotFolder, "DisplayPad" .. slot, Vector3.new(6, 0.4, 6), CFrame.new(padX, 4.5, padZ), accent)
			end
			for _, side in ipairs({-1, 1}) do
				part(plotFolder, "Fence", Vector3.new(25, 2, 0.45), CFrame.new(x, 5.3, z + side * 19), accent, Enum.Material.Metal)
			end
			plots[number] = {
				floor = floor, board = board, pads = pads,
				spawn = spawnLocation(plotFolder, "PlotSpawn", x, 4.3, z + 13),
				lockPrompt = prompt(board, "Lock / Unlock", "Base security"),
			}
		end
	end

	local speed = part(world, "SpeedShopPad", Vector3.new(11, 1, 12), CFrame.new(54, 0.5, -10), mint)
	local speedSign = sign(world, "SpeedShopSign", Vector3.new(59, 4, -10), "+ SPEED SHOP", mint, 12)
	local shrine = part(world, "RebirthShrine", Vector3.new(11, 1, 12), CFrame.new(54, 0.5, 10), orange)
	sign(world, "RebirthSign", Vector3.new(59, 4, 10), "REBIRTH\n$25,000", orange, 12)
	local rows = {}
	for _, rarity in ipairs(data.RarityOrder) do
		local tier = data.Rarities[rarity]
		table.insert(rows, ("%s   $%d   +$%d/s"):format(rarity, tier.price, tier.incomePerSecond))
	end
	sign(world, "RarityBoard", Vector3.new(-22, 5, 20), table.concat(rows, "\n"), mint, 21).Size *= Vector3.new(1, 2, 1)

	for _, z in ipairs({-84, -58, -30, 30, 58, 84}) do
		part(world, "LampPost", Vector3.new(0.5, 8, 0.5), CFrame.new(-19, 4, z), navy)
		local lamp = part(world, "Lamp", Vector3.new(2, 0.7, 2), CFrame.new(-19, 8, z), mint, Enum.Material.Neon)
		local light = Instance.new("PointLight")
		light.Color = mint
		light.Range = 13
		light.Parent = lamp
		part(world, "BeachUmbrellaPole", Vector3.new(0.4, 6, 0.4), CFrame.new(-66, 3, z), navy)
		part(world, "BeachUmbrella", Vector3.new(7, 0.65, 7), CFrame.new(-66, 6, z) * CFrame.Angles(0, math.pi / 4, 0), orange)
	end

	buildDecorations(world, data.Decor)

	return {
		folder = world, plots = plots, lobbySpawn = spawnLocation(world, "LobbySpawn", 50, 0, 0),
		speedPrompt = prompt(speedSign, "Buy +2 WalkSpeed", "Speed shop"),
		rebirthPrompt = prompt(shrine, "Rebirth", "$25,000"),
		waveStart = -100, waveEnd = 130, waveWidth = 204,
	}
end

return WorldBuilder
