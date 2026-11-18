local Lighting = game:GetService("Lighting")

local WorldBuilder = {}

local function createPart(parent, name, size, cf, color, material, shape)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cf
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Shape = shape or Enum.PartType.Block
	part.Anchored = true
	part.CanCollide = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

function WorldBuilder.Build()
	Lighting.ClockTime = 14
	Lighting.Brightness = 2
	Lighting.Ambient = Color3.fromRGB(128, 128, 140)
	Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 165)

	local existingWorld = workspace:FindFirstChild("BazaarWorld")
	if existingWorld then
		existingWorld:Destroy()
	end

	local world = Instance.new("Folder")
	world.Name = "BazaarWorld"
	world.Parent = workspace

	-- Island & Grounds
	createPart(
		world,
		"PlazaIsland",
		Vector3.new(8, 250, 250),
		CFrame.new(0, -3, 0) * CFrame.Angles(0, 0, math.rad(90)),
		Color3.fromRGB(96, 211, 124),
		Enum.Material.Grass,
		Enum.PartType.Cylinder
	)
	createPart(world, "BazaarFloor", Vector3.new(214, 2, 214), CFrame.new(0, 2, 0), Color3.fromRGB(255, 190, 60))
	createPart(world, "PlazaFloor", Vector3.new(190, 0.2, 190), CFrame.new(0, 0.1, 0), Color3.fromRGB(214, 183, 140))

	-- Elevated Conveyor Runway
	createPart(world, "RunwayPlatform", Vector3.new(170, 7, 26), CFrame.new(0, 3.5, 0), Color3.fromRGB(124, 93, 250))
	createPart(world, "ConveyorLane", Vector3.new(156, 1, 16), CFrame.new(0, 7, 0), Color3.fromRGB(50, 57, 70), Enum.Material.Metal)

	for x = -72, 72, 18 do
		for _, z in ipairs({ -5, 5 }) do
			createPart(world, "RunwayDash", Vector3.new(6, 0.12, 1.6), CFrame.new(x, 7.57, z), Color3.fromRGB(255, 220, 80), Enum.Material.Neon)
		end
	end

	-- Arches & Rails
	createPart(world, "StartArchPost1", Vector3.new(1.2, 10, 1.2), CFrame.new(-80, 12, -9), Color3.fromRGB(80, 220, 120), Enum.Material.Neon)
	createPart(world, "StartArchPost2", Vector3.new(1.2, 10, 1.2), CFrame.new(-80, 12, 9), Color3.fromRGB(80, 220, 120), Enum.Material.Neon)
	createPart(world, "FinishArchPost1", Vector3.new(1.2, 10, 1.2), CFrame.new(80, 12, -9), Color3.fromRGB(253, 121, 168), Enum.Material.Neon)
	createPart(world, "FinishArchPost2", Vector3.new(1.2, 10, 1.2), CFrame.new(80, 12, 9), Color3.fromRGB(253, 121, 168), Enum.Material.Neon)

	createPart(world, "StartArchBeam", Vector3.new(1.6, 2.2, 20), CFrame.new(-80, 17.4, 0), Color3.fromRGB(80, 220, 120), Enum.Material.Neon)
	createPart(world, "FinishArchBeam", Vector3.new(1.6, 2.2, 20), CFrame.new(80, 17.4, 0), Color3.fromRGB(253, 121, 168), Enum.Material.Neon)

	createPart(world, "BeltRailA", Vector3.new(156, 0.5, 1), CFrame.new(0, 7.8, -8.5), Color3.fromRGB(72, 219, 251), Enum.Material.Neon)
	createPart(world, "BeltRailB", Vector3.new(156, 0.5, 1), CFrame.new(0, 7.8, 8.5), Color3.fromRGB(253, 121, 168), Enum.Material.Neon)

	for x = -65, 65, 26 do
		for _, z in ipairs({ -6, 6 }) do
			createPart(world, "ConveyorLeg", Vector3.new(2, 6.5, 2), CFrame.new(x, 3.25, z), Color3.fromRGB(75, 82, 92), Enum.Material.Metal)
		end
	end

	createPart(world, "ConveyorEndZoneGreen", Vector3.new(5, 2, 20), CFrame.new(-80, 8.5, 0), Color3.fromRGB(88, 214, 141), Enum.Material.Neon)
	createPart(world, "ConveyorEndZoneRed", Vector3.new(5, 2, 20), CFrame.new(80, 8.5, 0), Color3.fromRGB(242, 93, 88), Enum.Material.Neon)

	for x = -68, 68, 12 do
		createPart(world, "BeltStripe", Vector3.new(1, 0.25, 13), CFrame.new(x, 7.65, 0), Color3.fromRGB(123, 140, 152), Enum.Material.Metal)
	end

	-- Plots
	local basesFolder = Instance.new("Folder")
	basesFolder.Name = "Bases"
	basesFolder.Parent = world

	local plotColors = {
		Color3.fromRGB(245, 92, 92),
		Color3.fromRGB(255, 159, 67),
		Color3.fromRGB(254, 202, 87),
		Color3.fromRGB(88, 214, 141),
		Color3.fromRGB(72, 219, 251),
		Color3.fromRGB(84, 160, 255),
		Color3.fromRGB(165, 94, 234),
		Color3.fromRGB(253, 121, 168),
	}

	local plots = {}

	for i = 1, 8 do
		local angle = (i - 1) * (math.pi / 4)
		local center = Vector3.new(math.cos(angle) * 82, 3.5, math.sin(angle) * 82)
		local plotColor = plotColors[i]

		-- PlotPath connecting center plaza to plot
		local pathPos = Vector3.new(math.cos(angle) * 45, 3.12, math.sin(angle) * 45)
		local pathPart = createPart(world, "PlotPath" .. i, Vector3.new(76, 0.25, 9), CFrame.new(pathPos) * CFrame.Angles(0, -angle, 0), plotColor)
		pathPart.CanCollide = false

		local plotModel = Instance.new("Model")
		plotModel.Name = "Plot" .. i
		plotModel:SetAttribute("PlotIndex", i)
		plotModel:SetAttribute("OwnerUserId", 0)
		plotModel:SetAttribute("LockedUntil", 0)
		plotModel.Parent = basesFolder

		local baseFloor = createPart(plotModel, "BaseFloor", Vector3.new(38, 1, 34), CFrame.new(center), plotColor)
		baseFloor:SetAttribute("SafeZone", true)

		local beacon = createPart(plotModel, "HomeBeacon", Vector3.new(3, 72, 3), CFrame.new(center + Vector3.new(0, 39, 0)), plotColor, Enum.Material.Neon)
		beacon.Transparency = 1
		beacon.CanCollide = false
		beacon.CanTouch = false
		beacon.CanQuery = false

		createPart(plotModel, "BaseFoundation", Vector3.new(30, 3, 26), CFrame.new(center + Vector3.new(0, -2, 0)), Color3.fromRGB(52, 92, 112), Enum.Material.Slate)

		-- Shop Structure
		local creamColor = Color3.fromRGB(255, 244, 214)
		local darkWood = Color3.fromRGB(120, 78, 45)
		createPart(plotModel, "BackWall", Vector3.new(36, 8, 1), CFrame.new(center + Vector3.new(0, 4, -15.5)), creamColor)
		createPart(plotModel, "SideWallL", Vector3.new(1, 8, 10), CFrame.new(center + Vector3.new(-17.5, 4, -11)), creamColor)
		createPart(plotModel, "SideWallR", Vector3.new(1, 8, 10), CFrame.new(center + Vector3.new(17.5, 4, -11)), creamColor)

		local postPositions = {
			Vector3.new(-17.5, 4.3, -15.5),
			Vector3.new(17.5, 4.3, -15.5),
			Vector3.new(-17.5, 4.3, -6.5),
			Vector3.new(17.5, 4.3, -6.5),
		}
		for _, offset in ipairs(postPositions) do
			createPart(plotModel, "Post", Vector3.new(0.9, 8.6, 0.9), CFrame.new(center + offset), darkWood)
		end

		createPart(plotModel, "Counter", Vector3.new(30, 2.4, 2.2), CFrame.new(center + Vector3.new(0, 1.7, -8.6)), Color3.fromRGB(166, 108, 60))

		-- Construct 6 slanted awning roof stripes alternating between base theme color and clean white
		for k = 1, 6 do
			local ax = -15.5 + ((k - 0.5) * 6.2)
			local awningColor = (k % 2 == 1) and plotColor or Color3.fromRGB(245, 245, 245)
			local awningCF = CFrame.new(center + Vector3.new(ax, 8.9, -11)) * CFrame.Angles(math.rad(-16), 0, 0)
			createPart(plotModel, "AwningStripe" .. k, Vector3.new(6.2, 0.35, 12), awningCF, awningColor)
		end

		-- Owner Sign
		local ownerSign = createPart(plotModel, "OwnerSign", Vector3.new(18, 4.5, 0.8), CFrame.new(center + Vector3.new(0, 11.3, -13.5)), Color3.fromRGB(34, 48, 62))

		local ownerGui = Instance.new("BillboardGui")
		ownerGui.Name = "OwnerBillboard"
		ownerGui.Size = UDim2.fromOffset(220, 70)
		ownerGui.StudsOffset = Vector3.new(0, 6, 0)
		ownerGui.AlwaysOnTop = true
		ownerGui.Parent = ownerSign

		local ownerText = Instance.new("TextLabel")
		ownerText.Name = "OwnerText"
		ownerText.Size = UDim2.fromScale(1, 1)
		ownerText.BackgroundTransparency = 1
		ownerText.Text = "OPEN PLOT"
		ownerText.TextColor3 = Color3.new(1, 1, 1)
		ownerText.TextStrokeTransparency = 0.3
		ownerText.TextScaled = true
		ownerText.Font = Enum.Font.GothamBold
		ownerText.Parent = ownerGui

		local lockPrompt = Instance.new("ProximityPrompt")
		lockPrompt.Name = "BaseLockPrompt"
		lockPrompt.ActionText = "Toggle 60s Lock"
		lockPrompt.ObjectText = "Base Security"
		lockPrompt.HoldDuration = 0.4
		lockPrompt.MaxActivationDistance = 12
		lockPrompt.Parent = ownerSign

		-- Pads
		local padsFolder = Instance.new("Folder")
		padsFolder.Name = "Pads"
		padsFolder.Parent = plotModel

		for k = 1, 6 do
			local row = math.floor((k - 1) / 3)
			local col = (k - 1) % 3
			local padPos = center + Vector3.new(-11 + (col * 11), 1, -4 + (row * 11))
			local pad = createPart(padsFolder, "Pad" .. k, Vector3.new(8, 0.6, 8), CFrame.new(padPos), Color3.fromRGB(65, 207, 191), Enum.Material.Neon)
			pad:SetAttribute("Occupied", false)
		end

		table.insert(plots, plotModel)
	end

	-- Rarity Board
	createPart(world, "RarityBoardPole", Vector3.new(2, 4.5, 2), CFrame.new(0, 5.25, -35), Color3.fromRGB(61, 67, 72), Enum.Material.Metal)
	local rarityBoard = createPart(world, "RarityBoard", Vector3.new(24, 15, 1), CFrame.new(0, 15, -35), Color3.fromRGB(35, 47, 58))
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.CanvasSize = Vector2.new(420, 250)
	surfaceGui.Parent = rarityBoard

	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Size = UDim2.fromScale(1, 1)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Text = "BAZAAR RARITIES\nCOMMON 52%   RARE 27%\nEPIC 13%   LEGENDARY 6%\nMYTHIC 2%"
	rarityLabel.TextColor3 = Color3.fromRGB(255, 235, 169)
	rarityLabel.TextScaled = true
	rarityLabel.Font = Enum.Font.GothamBlack
	rarityLabel.Parent = surfaceGui

	-- Rebirth Shrine
	createPart(world, "RebirthPedestal", Vector3.new(13, 4, 13), CFrame.new(0, 5, 43), Color3.fromRGB(104, 82, 123), Enum.Material.Slate)
	local rebirthShrine = createPart(world, "RebirthShrine", Vector3.new(15, 2, 15), CFrame.new(0, 8, 43), Color3.fromRGB(170, 92, 215), Enum.Material.Neon)

	local shrinePrompt = Instance.new("ProximityPrompt")
	shrinePrompt.Name = "RebirthPrompt"
	shrinePrompt.ActionText = "Rebirth ($25,000)"
	shrinePrompt.ObjectText = "Rebirth Shrine"
	shrinePrompt.HoldDuration = 1
	shrinePrompt.MaxActivationDistance = 12
	shrinePrompt.Parent = rebirthShrine

	-- Fences at 4 corners
	local corners = {
		{ x = 103, z = 103, rot = 0 },
		{ x = -103, z = 103, rot = 90 },
		{ x = -103, z = -103, rot = 0 },
		{ x = 103, z = -103, rot = 90 },
	}
	for i, c in ipairs(corners) do
		createPart(
			world,
			"BazaarFence" .. i,
			Vector3.new(32, 5, 2),
			CFrame.new(c.x, 9, c.z) * CFrame.Angles(0, math.rad(c.rot), 0),
			Color3.fromRGB(133, 92, 55),
			Enum.Material.WoodPlanks
		)
	end

	-- Lamps
	local lampSpots = {
		Vector3.new(45, 7, 38),
		Vector3.new(-45, 7, 38),
		Vector3.new(45, 7, -38),
		Vector3.new(-45, 7, -38),
	}
	for i, spot in ipairs(lampSpots) do
		createPart(world, "BazaarLamp" .. i, Vector3.new(1, 14, 1), CFrame.new(spot + Vector3.new(0, 7, 0)), Color3.fromRGB(61, 67, 72), Enum.Material.Metal)
		local glow = createPart(world, "LampGlow" .. i, Vector3.new(4, 1, 4), CFrame.new(spot + Vector3.new(0, 14, 0)), Color3.fromRGB(255, 226, 121), Enum.Material.Neon)
		local light = Instance.new("PointLight")
		light.Range = 24
		light.Brightness = 1.5
		light.Parent = glow
	end

	return {
		world = world,
		plots = plots,
		shrinePrompt = shrinePrompt,
	}
end

return WorldBuilder
