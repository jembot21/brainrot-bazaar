local WorldBuilder = {}

local function part(parent, name, size, position, color, material)
	local object = Instance.new("Part")
	object.Name = name
	object.Size = size
	object.Position = position
	object.Anchored = true
	object.Color = color
	object.Material = material or Enum.Material.SmoothPlastic
	object.TopSurface = Enum.SurfaceType.Smooth
	object.BottomSurface = Enum.SurfaceType.Smooth
	object.Parent = parent
	return object
end

function WorldBuilder.Build()
	local Lighting = game:GetService("Lighting")
	Lighting.ClockTime = 14
	Lighting.Brightness = 2
	Lighting.Ambient = Color3.fromRGB(128, 128, 140)
	Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 165)
	local plotColors = {
		Color3.fromRGB(245, 92, 92), Color3.fromRGB(255, 159, 67), Color3.fromRGB(254, 202, 87), Color3.fromRGB(88, 214, 141),
		Color3.fromRGB(72, 219, 251), Color3.fromRGB(84, 160, 255), Color3.fromRGB(165, 94, 234), Color3.fromRGB(253, 121, 168),
	}
	local existing = workspace:FindFirstChild("BazaarWorld")
	if existing then existing:Destroy() end
	local world = Instance.new("Folder")
	world.Name = "BazaarWorld"
	world.Parent = workspace

	local island = part(world, "PlazaIsland", Vector3.new(8, 250, 250), Vector3.new(0, -3, 0), Color3.fromRGB(96, 211, 124), Enum.Material.Grass)
	island.Shape = Enum.PartType.Cylinder
	island.Orientation = Vector3.new(0, 0, 90)
	part(world, "BazaarFloor", Vector3.new(214, 2, 214), Vector3.new(0, 2, 0), Color3.fromRGB(255, 206, 120), Enum.Material.SmoothPlastic)
	part(world, "PlazaFloor", Vector3.new(190, 0.2, 190), Vector3.new(0, 0.1, 0), Color3.fromRGB(214, 183, 140), Enum.Material.SmoothPlastic)
	part(world, "ConveyorLane", Vector3.new(156, 1, 16), Vector3.new(0, 7, 0), Color3.fromRGB(50, 57, 70), Enum.Material.Metal)
	part(world, "BeltRailA", Vector3.new(156, 0.5, 1), Vector3.new(0, 7.8, -8.5), Color3.fromRGB(72, 219, 251), Enum.Material.Neon)
	part(world, "BeltRailB", Vector3.new(156, 0.5, 1), Vector3.new(0, 7.8, 8.5), Color3.fromRGB(253, 121, 168), Enum.Material.Neon)
	for x = -65, 65, 26 do
		for _, z in ipairs({ -6, 6 }) do
			part(world, "ConveyorLeg", Vector3.new(2, 6.5, 2), Vector3.new(x, 3.25, z), Color3.fromRGB(75, 82, 92), Enum.Material.Metal)
		end
	end
	part(world, "ConveyorEndZone", Vector3.new(5, 2, 20), Vector3.new(-80, 8.5, 0), Color3.fromRGB(88, 214, 141), Enum.Material.Neon)
	part(world, "ConveyorEndZone", Vector3.new(5, 2, 20), Vector3.new(80, 8.5, 0), Color3.fromRGB(242, 93, 88), Enum.Material.Neon)
	for x = -68, 68, 12 do
		part(world, "BeltStripe", Vector3.new(1, 0.25, 13), Vector3.new(x, 7.65, 0), Color3.fromRGB(123, 140, 152), Enum.Material.Metal)
	end

	local bases = Instance.new("Folder")
	bases.Name = "Bases"
	bases.Parent = world
	local plots = {}
	for index = 1, 8 do
		local angle = (index - 1) * math.pi / 4
		local center = Vector3.new(math.cos(angle) * 82, 3.5, math.sin(angle) * 82)
		local path = part(world, "PlotPath", Vector3.new(76, 0.25, 9), Vector3.new(math.cos(angle) * 45, 3.12, math.sin(angle) * 45), plotColors[index], Enum.Material.SmoothPlastic)
		path.Orientation = Vector3.new(0, -math.deg(angle), 0)
		local plot = Instance.new("Model")
		plot.Name = "Plot" .. index
		plot:SetAttribute("PlotIndex", index)
		plot:SetAttribute("OwnerUserId", 0)
		plot:SetAttribute("LockedUntil", 0)
		plot.Parent = bases
		local floor = part(plot, "BaseFloor", Vector3.new(38, 1, 34), center, plotColors[index])
		local beacon = part(plot, "HomeBeacon", Vector3.new(3, 72, 3), center + Vector3.new(0, 39, 0), plotColors[index], Enum.Material.Neon)
		beacon.Transparency = 1
		beacon.CanCollide = false
		beacon.CanTouch = false
		beacon.CanQuery = false
		part(plot, "BaseFoundation", Vector3.new(30, 3, 26), center + Vector3.new(0, -2, 0), Color3.fromRGB(52, 92, 112), Enum.Material.Slate)
		floor:SetAttribute("SafeZone", true)
		local sign = part(plot, "OwnerSign", Vector3.new(14, 8, 1), center + Vector3.new(0, 5, -16), Color3.fromRGB(34, 48, 62))
		local gui = Instance.new("BillboardGui")
		gui.Name = "OwnerBillboard"
		gui.Size = UDim2.fromOffset(220, 70)
		gui.StudsOffset = Vector3.new(0, 6, 0)
		gui.AlwaysOnTop = true
		gui.Parent = sign
		local label = Instance.new("TextLabel")
		label.Name = "OwnerText"
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Text = "OPEN PLOT"
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextStrokeTransparency = 0.3
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.Parent = gui
		local lock = Instance.new("ProximityPrompt")
		lock.Name = "BaseLockPrompt"
		lock.ActionText = "Toggle 60s Lock"
		lock.ObjectText = "Base Security"
		lock.HoldDuration = 0.4
		lock.MaxActivationDistance = 12
		lock.Parent = sign
		local pads = Instance.new("Folder")
		pads.Name = "Pads"
		pads.Parent = plot
		for padIndex = 1, 6 do
			local row = math.floor((padIndex - 1) / 3)
			local column = (padIndex - 1) % 3
			local pad = part(pads, "Pad" .. padIndex, Vector3.new(8, 0.6, 8), center + Vector3.new(-11 + column * 11, 1, -4 + row * 11), Color3.fromRGB(65, 207, 191), Enum.Material.Neon)
			pad:SetAttribute("Occupied", false)
		end
		plots[index] = plot
	end

	part(world, "RarityBoardPole", Vector3.new(2, 4.5, 2), Vector3.new(0, 5.25, -35), Color3.fromRGB(61, 67, 72), Enum.Material.Metal)
	local board = part(world, "RarityBoard", Vector3.new(24, 15, 1), Vector3.new(0, 15, -35), Color3.fromRGB(35, 47, 58))
	local boardGui = Instance.new("SurfaceGui")
	boardGui.Face = Enum.NormalId.Front
	boardGui.CanvasSize = Vector2.new(420, 250)
	boardGui.Parent = board
	local boardText = Instance.new("TextLabel")
	boardText.Size = UDim2.fromScale(1, 1)
	boardText.BackgroundTransparency = 1
	boardText.Text = "BAZAAR RARITIES\nCOMMON 52%   RARE 27%\nEPIC 13%   LEGENDARY 6%\nMYTHIC 2%"
	boardText.TextColor3 = Color3.fromRGB(255, 235, 169)
	boardText.TextScaled = true
	boardText.Font = Enum.Font.GothamBlack
	boardText.Parent = boardGui

	part(world, "RebirthPedestal", Vector3.new(13, 4, 13), Vector3.new(0, 5, 43), Color3.fromRGB(104, 82, 123), Enum.Material.Slate)
	local shrine = part(world, "RebirthShrine", Vector3.new(15, 2, 15), Vector3.new(0, 8, 43), Color3.fromRGB(170, 92, 215), Enum.Material.Neon)
	local shrinePrompt = Instance.new("ProximityPrompt")
	shrinePrompt.Name = "RebirthPrompt"
	shrinePrompt.ActionText = "Rebirth ($25,000)"
	shrinePrompt.ObjectText = "Rebirth Shrine"
	shrinePrompt.HoldDuration = 1
	shrinePrompt.MaxActivationDistance = 12
	shrinePrompt.Parent = shrine

	for i = 1, 4 do
		local x = (i % 2 == 0) and 103 or -103
		local z = (i <= 2) and 103 or -103
		local fence = part(world, "BazaarFence", Vector3.new(32, 5, 2), Vector3.new(x, 9, z), Color3.fromRGB(133, 92, 55), Enum.Material.WoodPlanks)
		fence.Orientation = Vector3.new(0, (i % 2 == 0) and 90 or 0, 0)
	end
	for _, position in ipairs({ Vector3.new(-45, 7, 38), Vector3.new(45, 7, 38), Vector3.new(-45, 7, -38), Vector3.new(45, 7, -38) }) do
		local pole = part(world, "BazaarLamp", Vector3.new(1, 14, 1), position + Vector3.new(0, 7, 0), Color3.fromRGB(61, 67, 72), Enum.Material.Metal)
		local lamp = part(world, "LampGlow", Vector3.new(4, 1, 4), pole.Position + Vector3.new(0, 7, 0), Color3.fromRGB(255, 226, 121), Enum.Material.Neon)
		local light = Instance.new("PointLight")
		light.Range = 24
		light.Brightness = 1.5
		light.Parent = lamp
	end
	return { world = world, plots = plots, shrinePrompt = shrinePrompt }
end

return WorldBuilder
