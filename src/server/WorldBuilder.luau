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

	return {
		folder = world, plots = plots, lobbySpawn = spawnLocation(world, "LobbySpawn", 50, 0, 0),
		speedPrompt = prompt(speedSign, "Buy +2 WalkSpeed", "Speed shop"),
		rebirthPrompt = prompt(shrine, "Rebirth", "$25,000"),
		waveStart = -100, waveEnd = 130, waveWidth = 204,
	}
end

return WorldBuilder
