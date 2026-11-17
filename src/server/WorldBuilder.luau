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
	local existing = workspace:FindFirstChild("BazaarWorld")
	if existing then existing:Destroy() end
	local world = Instance.new("Folder")
	world.Name = "BazaarWorld"
	world.Parent = workspace

	local island = part(world, "PlazaIsland", Vector3.new(8, 250, 250), Vector3.new(0, -3, 0), Color3.fromRGB(82, 160, 111), Enum.Material.Grass)
	island.Shape = Enum.PartType.Cylinder
	island.Orientation = Vector3.new(0, 0, 90)
	part(world, "BazaarFloor", Vector3.new(214, 2, 214), Vector3.new(0, 2, 0), Color3.fromRGB(238, 218, 169), Enum.Material.Sand)
	part(world, "ConveyorLane", Vector3.new(156, 1, 16), Vector3.new(0, 7, 0), Color3.fromRGB(50, 57, 70), Enum.Material.Metal)
	for x = -65, 65, 26 do
		for _, z in ipairs({ -6, 6 }) do
			part(world, "ConveyorLeg", Vector3.new(2, 3.5, 2), Vector3.new(x, 4.75, z), Color3.fromRGB(75, 82, 92), Enum.Material.Metal)
		end
	end
	for _, x in ipairs({ -80, 80 }) do
		part(world, "ConveyorEndZone", Vector3.new(5, 2, 20), Vector3.new(x, 8.5, 0), Color3.fromRGB(242, 93, 88), Enum.Material.Neon)
	end
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
		local plot = Instance.new("Model")
		plot.Name = "Plot" .. index
		plot:SetAttribute("PlotIndex", index)
		plot:SetAttribute("OwnerUserId", 0)
		plot:SetAttribute("LockedUntil", 0)
		plot.Parent = bases
		local floor = part(plot, "BaseFloor", Vector3.new(38, 1, 34), center, Color3.fromRGB(76, 134, 164))
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
	local boardGui = Instance.new("BillboardGui")
	boardGui.Size = UDim2.fromOffset(420, 250)
	boardGui.StudsOffset = Vector3.new(0, 9, 0)
	boardGui.AlwaysOnTop = true
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
