local CharacterFactory = {}

local DARK_COLOR = Color3.fromRGB(30, 37, 49)
local WHITE_COLOR = Color3.fromRGB(240, 242, 245)
local GOLD_COLOR = Color3.fromRGB(255, 190, 60)

local function makePart(parent, name, size, cframe, color, shape, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	if shape then
		part.Shape = shape
	end
	part.Parent = parent
	return part
end

local function makeCylinder(parent, name, diameter, height, cframe, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Shape = Enum.PartType.Cylinder
	part.Size = Vector3.new(height, diameter, diameter)
	part.CFrame = cframe * CFrame.Angles(0, 0, math.rad(90))
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function addFace(model, centerPos, eyeSpacing)
	local x = eyeSpacing * 0.5
	local y = centerPos.Y
	local z = centerPos.Z

	makePart(model, "EyeL", Vector3.new(0.55, 0.6, 0.25), CFrame.new(-x, y, z), WHITE_COLOR, Enum.PartType.Ball)
	makePart(model, "EyeR", Vector3.new(0.55, 0.6, 0.25), CFrame.new(x, y, z), WHITE_COLOR, Enum.PartType.Ball)

	makePart(model, "PupilL", Vector3.new(0.22, 0.3, 0.12), CFrame.new(-x, y, z - 0.1), DARK_COLOR, Enum.PartType.Ball)
	makePart(model, "PupilR", Vector3.new(0.22, 0.3, 0.12), CFrame.new(x, y, z - 0.1), DARK_COLOR, Enum.PartType.Ball)

	makePart(model, "Mouth", Vector3.new(0.9, 0.18, 0.1), CFrame.new(0, y - 0.45, z - 0.05), DARK_COLOR)
end

local function addSneakers(model, legColor)
	for _, sign in { -1, 1 } do
		local x = sign * 0.65
		makePart(model, "Leg", Vector3.new(0.55, 0.6, 0.55), CFrame.new(x, 0.72, -0.1), legColor)
		makePart(model, "Shoe", Vector3.new(0.8, 0.42, 1.5), CFrame.new(x, 0.21, -0.3), WHITE_COLOR)
		local soleColor = sign == -1 and Color3.fromRGB(50, 110, 255) or Color3.fromRGB(245, 70, 70)
		makePart(model, "Sole", Vector3.new(0.85, 0.16, 1.55), CFrame.new(x, 0.08, -0.3), soleColor)
	end
end

local function addFeet(model, spacing, color)
	local shoeColor = color or DARK_COLOR
	for _, sign in { -1, 1 } do
		local x = sign * spacing
		makePart(model, "Foot", Vector3.new(0.8, 0.4, 1.1), CFrame.new(x, 0.2, -0.15), shoeColor)
	end
end

local function addCrown(model, name, cframe, diameter)
	local crown = makeCylinder(model, name, diameter, 0.65, cframe, GOLD_COLOR, Enum.Material.SmoothPlastic)
	local radius = (diameter * 0.5) - 0.12
	local angles = { 0, math.pi * 0.5, math.pi, math.pi * 1.5 }
	for i, angle in angles do
		local offset = Vector3.new(math.cos(angle) * radius, 0.4, math.sin(angle) * radius)
		makePart(model, "CrownSpike" .. i, Vector3.new(0.25, 0.45, 0.25), cframe + offset, GOLD_COLOR)
	end
	return crown
end

local Builders = {}

-- 1. Sir Bounce Banana
Builders["Sir Bounce Banana"] = function(model, bodyColor)
	local body = makePart(model, "Body", Vector3.new(2.4, 1.8, 2.4), CFrame.new(0, 2, 0), bodyColor)
	makePart(model, "LowerBanana", Vector3.new(2.2, 1.5, 2.2), CFrame.new(-0.45, 0.95, 0) * CFrame.Angles(0, 0, math.rad(-16)), bodyColor)
	makePart(model, "UpperBanana", Vector3.new(2, 1.5, 2), CFrame.new(0.5, 3.35, 0) * CFrame.Angles(0, 0, math.rad(18)), bodyColor)
	makePart(model, "BrownTip", Vector3.new(0.45, 0.4, 0.5), CFrame.new(0.75, 4.15, 0), Color3.fromRGB(90, 56, 30))
	addCrown(model, "Accessory", CFrame.new(0.5, 4.65, 0), 1.6)
	addFace(model, Vector3.new(0, 2.4, -1.22), 0.6)
	addSneakers(model, bodyColor)
	return body
end

-- 2. Pigeon Barry
Builders["Pigeon Barry"] = function(model, bodyColor)
	local body = makePart(model, "Body", Vector3.new(3.6, 3.6, 3.6), CFrame.new(0, 2, 0), bodyColor, Enum.PartType.Ball)
	makePart(model, "Head", Vector3.new(1.8, 1.8, 1.8), CFrame.new(0, 3.6, -0.9), bodyColor, Enum.PartType.Ball)
	makePart(model, "Beak", Vector3.new(0.5, 0.35, 0.8), CFrame.new(0, 3.5, -2), Color3.fromRGB(245, 157, 48))
	addFace(model, Vector3.new(0, 3.85, -1.75), 0.48)
	local wingColor = Color3.new(bodyColor.R * 0.8, bodyColor.G * 0.8, bodyColor.B * 0.8)
	makePart(model, "WingL", Vector3.new(0.35, 1.6, 2.2), CFrame.new(-1.85, 2.2, 0) * CFrame.Angles(0, 0, math.rad(20)), wingColor)
	makePart(model, "WingR", Vector3.new(0.35, 1.6, 2.2), CFrame.new(1.85, 2.2, 0) * CFrame.Angles(0, 0, math.rad(-20)), wingColor)
	makePart(model, "Tail", Vector3.new(1.5, 0.3, 1.1), CFrame.new(0, 2.4, 1.9) * CFrame.Angles(math.rad(25), 0, 0), wingColor)
	makePart(model, "Accessory", Vector3.new(0.25, 1.1, 0.5), CFrame.new(0, 4.8, -0.9) * CFrame.Angles(0, 0, math.rad(20)), Color3.fromRGB(108, 202, 245))
	addSneakers(model, Color3.fromRGB(245, 157, 48))
	return body
end

-- 3. Toaster Todd
Builders["Toaster Todd"] = function(model, bodyColor, isMutated)
	local toasterColor = isMutated and bodyColor or Color3.fromRGB(198, 205, 212)
	local body = makePart(model, "Body", Vector3.new(3.6, 3.2, 2.8), CFrame.new(0, 2, 0), toasterColor)
	makePart(model, "SlotL", Vector3.new(1.1, 0.25, 0.5), CFrame.new(-0.8, 3.7, 0), DARK_COLOR)
	makePart(model, "SlotR", Vector3.new(1.1, 0.25, 0.5), CFrame.new(0.8, 3.7, 0), DARK_COLOR)
	makeCylinder(model, "CrustKnobL", 0.35, 0.4, CFrame.new(-0.65, 4.95, 0), Color3.fromRGB(188, 126, 78))
	makeCylinder(model, "CrustKnobR", 0.35, 0.4, CFrame.new(0.65, 4.95, 0), Color3.fromRGB(188, 126, 78))
	local toastCF = CFrame.new(0, 4.3, 0) * CFrame.Angles(0, 0, math.rad(8))
	makePart(model, "Accessory", Vector3.new(1.7, 1.6, 0.45), toastCF, Color3.fromRGB(188, 126, 78))
	makePart(model, "ToastInner", Vector3.new(1.4, 1.3, 0.5), toastCF * CFrame.new(0, 0, -0.03), Color3.fromRGB(232, 190, 130))
	makePart(model, "Lever", Vector3.new(0.5, 0.3, 0.65), CFrame.new(1.95, 2.2, 0), DARK_COLOR)
	addFace(model, Vector3.new(0, 2.5, -1.42), 0.8)
	for x = -0.8, 0.81, 0.4 do
		local y = 2.9 - (x * x * 0.35)
		makePart(model, "ChainLink", Vector3.new(0.34, 0.34, 0.18), CFrame.new(x, y, -1.45), GOLD_COLOR, nil, Enum.Material.Metal)
	end
	addFeet(model, 0.95)
	return body
end

-- 4. Disco Broccoli Bro
Builders["Disco Broccoli Bro"] = function(model, bodyColor, isMutated)
	local stalkColor = isMutated and bodyColor or Color3.fromRGB(168, 224, 150)
	local body = makeCylinder(model, "Body", 1.5, 3.2, CFrame.new(0, 2, 0), stalkColor)
	for i = 1, 5 do
		local angle = (i - 1) * (math.pi * 2 / 5)
		local fx = math.cos(angle) * 0.95
		local fz = math.sin(angle) * 0.95 * 0.8
		makePart(model, "Floret" .. i, Vector3.new(1.7, 1.7, 1.7), CFrame.new(fx, 3.65, fz), bodyColor, Enum.PartType.Ball)
	end
	makePart(model, "TopFloret", Vector3.new(1.9, 1.9, 1.9), CFrame.new(0, 4.1, 0), bodyColor, Enum.PartType.Ball)
	makeCylinder(model, "DiscoString", 0.08, 1.2, CFrame.new(1.15, 4.7, 0) * CFrame.Angles(0, 0, math.rad(25)), Color3.fromRGB(200, 200, 200), Enum.Material.Metal)
	makePart(model, "Accessory", Vector3.new(0.9, 0.9, 0.9), CFrame.new(1.9, 4.6, 0), Color3.fromRGB(225, 230, 238), Enum.PartType.Ball, Enum.Material.Metal)
	makePart(model, "Sunglasses", Vector3.new(2.2, 0.55, 0.2), CFrame.new(0, 2.6, -0.78), DARK_COLOR)
	makePart(model, "Mouth", Vector3.new(0.7, 0.15, 0.1), CFrame.new(0, 1.9, -0.8), DARK_COLOR)
	for _, sign in { -1, 1 } do
		local armCF = CFrame.new(sign * 2.05, 2.5, 0) * CFrame.Angles(0, 0, math.rad(-sign * 30))
		makePart(model, "UpperArm", Vector3.new(0.85, 1.9, 0.85), armCF, Color3.fromRGB(120, 220, 130))
		makePart(model, "Fist", Vector3.new(0.95, 0.95, 0.95), CFrame.new(sign * 2.6, 1.5, 0), Color3.fromRGB(120, 220, 130), Enum.PartType.Ball)
	end
	addFeet(model, 0.65, stalkColor)
	return body
end

-- 5. Grandma Turbo
Builders["Grandma Turbo"] = function(model, bodyColor)
	local body = makePart(model, "Body", Vector3.new(3.6, 3.6, 3.6), CFrame.new(0, 2, 0), bodyColor, Enum.PartType.Ball)
	makePart(model, "Bun", Vector3.new(1.5, 1.5, 1.5), CFrame.new(0, 4.1, 0.3), Color3.fromRGB(206, 211, 219), Enum.PartType.Ball)
	addFace(model, Vector3.new(0, 2.5, -1.83), 0.75)
	local g1 = makePart(model, "Accessory", Vector3.new(0.12, 0.82, 0.82), CFrame.new(-0.75, 2.5, -1.78) * CFrame.Angles(math.rad(90), 0, 0), DARK_COLOR, Enum.PartType.Cylinder)
	local g2 = makePart(model, "GlassesRim", Vector3.new(0.12, 0.82, 0.82), CFrame.new(0.75, 2.5, -1.78) * CFrame.Angles(math.rad(90), 0, 0), DARK_COLOR, Enum.PartType.Cylinder)
	makePart(model, "GlassesBridge", Vector3.new(0.8, 0.12, 0.1), CFrame.new(0, 2.5, -1.91), DARK_COLOR)
	makePart(model, "Shawl", Vector3.new(3.9, 0.5, 3.9), CFrame.new(0, 1.1, 0), Color3.fromRGB(150, 110, 190))
	makePart(model, "Turbo", Vector3.new(1.6, 1.1, 1.1), CFrame.new(0, 2.2, 2) * CFrame.Angles(math.rad(90), 0, 0), Color3.fromRGB(120, 128, 140), Enum.PartType.Cylinder)
	makePart(model, "Flame", Vector3.new(1, 1, 1), CFrame.new(0, 2.2, 3), Color3.fromRGB(255, 143, 40), Enum.PartType.Ball, Enum.Material.Neon)
	addSneakers(model, Color3.fromRGB(238, 154, 183))
	return body
end

-- 6. Cactus Carl
Builders["Cactus Carl"] = function(model, bodyColor)
	local body = makeCylinder(model, "Body", 1.6, 4.0, CFrame.new(0, 2, 0), bodyColor)
	for _, sign in { -1, 1 } do
		makeCylinder(model, "ArmV", 0.7, 1.6, CFrame.new(sign * 1.65, 2.6, 0), bodyColor)
		local elbowCF = CFrame.new(sign * 1.2, 3.4, 0) * CFrame.Angles(0, 0, math.rad(90))
		makePart(model, "ArmH", Vector3.new(1.1, 0.7, 0.7), elbowCF, bodyColor, Enum.PartType.Cylinder)
	end
	for i = 1, 8 do
		local angle = i * 2.4
		local radius = 0.78
		local y = 0.9 + (i % 4) * 0.8
		local sx = math.cos(angle) * radius
		local sz = math.sin(angle) * radius
		makePart(model, "Spike" .. i, Vector3.new(0.14, 0.3, 0.14), CFrame.new(sx, y, sz), WHITE_COLOR)
	end
	for i = 1, 5 do
		local angle = (i - 1) * (math.pi * 2 / 5)
		local px = math.cos(angle) * 0.45
		local pz = math.sin(angle) * 0.45
		makePart(model, "Petal" .. i, Vector3.new(0.65, 0.65, 0.65), CFrame.new(px, 4.35, pz), Color3.fromRGB(251, 100, 136), Enum.PartType.Ball)
	end
	makePart(model, "Accessory", Vector3.new(0.55, 0.55, 0.55), CFrame.new(0, 4.5, 0), GOLD_COLOR, Enum.PartType.Ball)
	makePart(model, "PotRim", Vector3.new(3.4, 0.7, 3.4), CFrame.new(0, 0.35, 0), Color3.fromRGB(176, 96, 64))
	addFace(model, Vector3.new(0, 2.5, -0.82), 0.43)
	addSneakers(model, bodyColor)
	return body
end

-- 7. Croissant Dragon Draco
Builders["Croissant Dragon Draco"] = function(model, bodyColor)
	local body = makePart(model, "Body", Vector3.new(2.8, 2.8, 2.8), CFrame.new(0, 2, 0), bodyColor, Enum.PartType.Ball)
	makePart(model, "Curl", Vector3.new(2.3, 2.3, 2.3), CFrame.new(1.7, 2.5, 0), bodyColor, Enum.PartType.Ball)
	local tipColor = Color3.new(bodyColor.R * 0.85, bodyColor.G * 0.85, bodyColor.B * 0.85)
	makePart(model, "CurlTip", Vector3.new(1.8, 1.8, 1.8), CFrame.new(2.9, 3.4, 0), tipColor, Enum.PartType.Ball)
	makePart(model, "LeftTip", Vector3.new(1.7, 1.7, 1.7), CFrame.new(-1.6, 2.3, 0), tipColor, Enum.PartType.Ball)
	local wingRed = Color3.fromRGB(178, 64, 60)
	for _, sign in { -1, 1 } do
		local wingCF = CFrame.new(sign * 0.9, 3.4, 1.2) * CFrame.Angles(0, math.rad(sign * 25), math.rad(sign * 15))
		makePart(model, "Wing", Vector3.new(0.25, 2.2, 1.6), wingCF, wingRed)
	end
	local hornColor = Color3.fromRGB(240, 230, 200)
	local h1CF = CFrame.new(-0.65, 3.75, 0) * CFrame.Angles(0, 0, math.rad(25))
	local h2CF = CFrame.new(0.65, 3.75, 0) * CFrame.Angles(0, 0, math.rad(-25))
	makePart(model, "Accessory", Vector3.new(1, 0.56, 0.56), h1CF * CFrame.Angles(0, 0, math.rad(90)), hornColor, Enum.PartType.Cylinder)
	makePart(model, "Horn", Vector3.new(1, 0.56, 0.56), h2CF * CFrame.Angles(0, 0, math.rad(90)), hornColor, Enum.PartType.Cylinder)
	addFace(model, Vector3.new(0, 2.4, -1.38), 0.65)
	addSneakers(model, bodyColor)
	return body
end

-- 8. WiFi Wizard Wally
Builders["WiFi Wizard Wally"] = function(model, bodyColor)
	local body = makePart(model, "Body", Vector3.new(3.4, 3.4, 3), CFrame.new(0, 2, 0), bodyColor)
	makePart(model, "Beard", Vector3.new(1.8, 1.6, 0.35), CFrame.new(0, 1.5, -1.6), Color3.fromRGB(235, 238, 242))
	local purple = Color3.fromRGB(104, 82, 190)
	makeCylinder(model, "HatBrim", 4.4, 0.25, CFrame.new(0, 3.8, 0), purple)
	local tiers = { { 3.0, 4.33 }, { 2.1, 4.71 }, { 1.2, 5.09 } }
	for i, tier in tiers do
		makeCylinder(model, "HatTier" .. i, tier[1], 0.42, CFrame.new(0, tier[2], 0), purple)
	end
	makeCylinder(model, "Antenna", 0.15, 0.35, CFrame.new(0, 5.22, 0), Color3.fromRGB(200, 200, 200), Enum.Material.Metal)
	makePart(model, "Accessory", Vector3.new(0.4, 0.4, 0.4), CFrame.new(0, 5.35, 0), Color3.fromRGB(93, 237, 246), Enum.PartType.Ball, Enum.Material.Neon)
	addFace(model, Vector3.new(0, 2.8, -1.53), 0.75)
	addFeet(model, 1.0)
	return body
end

-- 9. Golden Toilet King
Builders["Golden Toilet King"] = function(model, bodyColor, isMutated)
	makePart(model, "ToiletBase", Vector3.new(1.8, 1.2, 1.8), CFrame.new(0, 0.6, 0), WHITE_COLOR)
	local bowlColor = isMutated and bodyColor or WHITE_COLOR
	local body = makeCylinder(model, "Body", 4.0, 1.6, CFrame.new(0, 2, 0), bowlColor)
	makeCylinder(model, "Seat", 4.3, 0.3, CFrame.new(0, 2.9, 0), GOLD_COLOR)
	makePart(model, "Tank", Vector3.new(3.2, 2.0, 1.0), CFrame.new(0, 3.4, 1.6), WHITE_COLOR)
	addCrown(model, "Accessory", CFrame.new(0, 4.8, 1.6), 2.0)
	makePart(model, "FlushHandle", Vector3.new(0.6, 0.2, 0.2), CFrame.new(0.9, 3.8, 1.02), GOLD_COLOR, nil, Enum.Material.Metal)
	addFace(model, Vector3.new(0, 2.2, -1.95), 0.8)
	return body
end

-- 10. Moon Cheese Golem
Builders["Moon Cheese Golem"] = function(model, bodyColor)
	local body = makePart(model, "Body", Vector3.new(4.2, 3.6, 3.4), CFrame.new(0, 2, 0), bodyColor)
	local holeColor = Color3.fromRGB(214, 178, 92)
	local holes = {
		{ -1.5, 3.2, 0.6 },
		{ 1.5, 3.3, 0.7 },
		{ 0, 1.0, 0.5 },
		{ -1.5, 1.4, 0.8 },
		{ 1.5, 1.5, 0.65 },
	}
	for i, h in holes do
		makePart(model, "CheeseHole" .. i, Vector3.new(0.12, h[3], h[3]), CFrame.new(h[1], h[2], -1.73) * CFrame.Angles(math.rad(90), 0, 0), holeColor, Enum.PartType.Cylinder)
	end
	local armColor = Color3.new(bodyColor.R * 0.9, bodyColor.G * 0.9, bodyColor.B * 0.9)
	for _, sign in { -1, 1 } do
		makePart(model, "Arm", Vector3.new(0.9, 2.6, 0.9), CFrame.new(sign * 2.55, 1.9, 0), armColor)
		makePart(model, "GolemFoot", Vector3.new(1.2, 0.8, 1.2), CFrame.new(sign * 1.1, 0.4, 0), DARK_COLOR)
	end
	makeCylinder(model, "MoonStalk", 0.18, 0.7, CFrame.new(0, 4.3, 0), Color3.fromRGB(180, 180, 180), Enum.Material.Metal)
	local moonColor = Color3.fromRGB(255, 226, 121)
	makePart(model, "Accessory", Vector3.new(0.65, 0.65, 0.65), CFrame.new(0, 5.15, 0), moonColor, Enum.PartType.Ball)
	makePart(model, "MoonTipL", Vector3.new(0.65, 0.65, 0.65), CFrame.new(-0.45, 4.85, 0), moonColor, Enum.PartType.Ball)
	makePart(model, "MoonTipR", Vector3.new(0.65, 0.65, 0.65), CFrame.new(0.45, 4.85, 0), moonColor, Enum.PartType.Ball)
	addFace(model, Vector3.new(0, 2.5, -1.73), 1.0)
	makePart(model, "Sunglasses", Vector3.new(2.6, 0.6, 0.2), CFrame.new(0, 2.55, -1.75), DARK_COLOR)
	return body
end

-- 11. Galaxy Brain Octopus
Builders["Galaxy Brain Octopus"] = function(model, bodyColor)
	local body = makePart(model, "Body", Vector3.new(3.4, 3.4, 3.4), CFrame.new(0, 2, 0), bodyColor, Enum.PartType.Ball)
	makePart(model, "Brain", Vector3.new(2.4, 2.4, 2.4), CFrame.new(0, 3.6, 0), Color3.fromRGB(244, 154, 199), Enum.PartType.Ball)
	local tentacleColor = Color3.new(bodyColor.R * 0.85, bodyColor.G * 0.85, bodyColor.B * 0.85)
	for i = 1, 6 do
		local angle = (i - 1) * (math.pi * 2 / 6)
		local tx = math.cos(angle) * 1.3
		local tz = math.sin(angle) * 1.3
		local tentCF = CFrame.new(tx, 0.9, tz) * CFrame.Angles(math.sin(angle) * math.rad(20), 0, -math.cos(angle) * math.rad(20))
		makeCylinder(model, "Tentacle" .. i, 0.7, 1.6, tentCF, tentacleColor)
	end
	local starColor = Color3.fromRGB(254, 238, 93)
	makePart(model, "Accessory", Vector3.new(1.3, 1.3, 0.25), CFrame.new(1.6, 3.9, -0.6), starColor)
	makePart(model, "StarPoints", Vector3.new(1.3, 1.3, 0.25), CFrame.new(1.6, 3.9, -0.6) * CFrame.Angles(0, 0, math.rad(45)), starColor)
	for _, sign in { -1, 1 } do
		makePart(model, "BigEye", Vector3.new(1, 1, 1), CFrame.new(sign * 0.8, 2.5, -1.55), WHITE_COLOR, Enum.PartType.Ball)
		makePart(model, "Pupil", Vector3.new(0.48, 0.48, 0.48), CFrame.new(sign * 0.8, 2.5, -2.0), DARK_COLOR, Enum.PartType.Ball)
	end
	makePart(model, "Mouth", Vector3.new(0.9, 0.2, 0.1), CFrame.new(0, 1.75, -1.7), DARK_COLOR)
	return body
end

-- 12. Rainbow Sock Puppet
Builders["Rainbow Sock Puppet"] = function(model, bodyColor)
	local body = makeCylinder(model, "Body", 2.7, 1.3, CFrame.new(0, 2, 0), bodyColor)
	local lowerCF = CFrame.new(0, 0.75, 0.2) * CFrame.Angles(math.rad(-6), 0, 0)
	makeCylinder(model, "LowerSock", 2.7, 1.3, lowerCF, bodyColor)
	local upperCF = CFrame.new(0, 3.2, -0.35) * CFrame.Angles(math.rad(-12), 0, 0)
	makeCylinder(model, "UpperSock", 2.7, 1.3, upperCF, bodyColor)
	local bandColors = {
		Color3.fromRGB(245, 92, 92),
		Color3.fromRGB(254, 202, 87),
		Color3.fromRGB(72, 219, 251),
	}
	for i = 1, 3 do
		local by = 0.1 + (i * 1.25)
		local bz = 0.25 - (i * 0.2)
		local bCF = CFrame.new(0, by, bz) * CFrame.Angles(math.rad(-6), 0, 0)
		makeCylinder(model, "RainbowBand" .. i, 2.84, 0.3, bCF, bandColors[i])
	end
	makePart(model, "Head", Vector3.new(2.5, 2.5, 2.5), CFrame.new(0, 3.95, -0.9), bodyColor, Enum.PartType.Ball)
	makePart(model, "Snout", Vector3.new(1.6, 1.6, 1.6), CFrame.new(0, 3.8, -1.8), bodyColor, Enum.PartType.Ball)
	makePart(model, "Mouth", Vector3.new(1.2, 0.18, 0.8), CFrame.new(0, 3.25, -1.7) * CFrame.Angles(math.rad(15), 0, 0), Color3.fromRGB(115, 32, 55))
	for _, sign in { -1, 1 } do
		local x = sign * 0.65
		makeCylinder(model, "EyeStalk", 0.2, 0.5, CFrame.new(x, 4.85, -0.9), WHITE_COLOR)
		local eyeName = sign == -1 and "Accessory" or "GooglyEye"
		makePart(model, eyeName, Vector3.new(0.6, 0.6, 0.6), CFrame.new(sign * 0.7, 5.2, -0.9), WHITE_COLOR, Enum.PartType.Ball)
		makePart(model, "GooglyPupil", Vector3.new(0.3, 0.3, 0.3), CFrame.new(sign * 0.7, 5.2, -1.18), DARK_COLOR, Enum.PartType.Ball)
	end
	makeCylinder(model, "Cuff", 3.0, 0.5, CFrame.new(0, 0.25, 0.2), WHITE_COLOR)
	return body
end

local FallbackAccessoryColors = {
	Crown = Color3.fromRGB(255, 208, 47),
	Feather = Color3.fromRGB(40, 111, 173),
	Toast = Color3.fromRGB(199, 121, 57),
	DiscoBall = Color3.fromRGB(230, 91, 213),
	Glasses = Color3.fromRGB(30, 35, 42),
	Flower = Color3.fromRGB(251, 100, 136),
	Horns = Color3.fromRGB(108, 69, 43),
	WizardHat = Color3.fromRGB(76, 68, 177),
	Moon = Color3.fromRGB(244, 233, 158),
	Star = Color3.fromRGB(254, 238, 93),
	Sock = Color3.fromRGB(96, 236, 210),
}

function CharacterFactory.Build(definition, rarity, mutation, income, promptAction)
	local model = Instance.new("Model")
	model.Name = definition.name

	model:SetAttribute("BrainrotName", definition.name)
	model:SetAttribute("Rarity", definition.rarity)
	model:SetAttribute("Mutation", mutation and mutation.name or "")
	model:SetAttribute("Income", income)

	local bodyColor = (mutation and mutation.color) or definition.color or rarity.color
	local isMutated = mutation ~= nil

	local builder = Builders[definition.name]
	local bodyPart
	if builder then
		bodyPart = builder(model, bodyColor, isMutated)
	else
		bodyPart = makePart(model, "Body", Vector3.new(4, 4, 3), CFrame.new(0, 2, 0), bodyColor, rarity.shape)
		makePart(model, "EyeL", Vector3.new(0.55, 0.6, 0.25), CFrame.new(-0.6, 2.5, -1.52), WHITE_COLOR, Enum.PartType.Ball)
		makePart(model, "EyeR", Vector3.new(0.55, 0.6, 0.25), CFrame.new(0.6, 2.5, -1.52), WHITE_COLOR, Enum.PartType.Ball)
		makePart(model, "PupilL", Vector3.new(0.22, 0.3, 0.12), CFrame.new(-0.6, 2.5, -1.68), DARK_COLOR, Enum.PartType.Ball)
		makePart(model, "PupilR", Vector3.new(0.22, 0.3, 0.12), CFrame.new(0.6, 2.5, -1.68), DARK_COLOR, Enum.PartType.Ball)
		makePart(model, "Mouth", Vector3.new(0.9, 0.18, 0.1), CFrame.new(0, 1.9, -1.55), DARK_COLOR)

		local accKind = definition.accessory or "Crown"
		local accColor = FallbackAccessoryColors[accKind] or GOLD_COLOR
		if accKind == "Crown" or accKind == "WizardHat" or accKind == "Horns" then
			makeCylinder(model, "Accessory", 1.5, 1.2, CFrame.new(0, 4.6, 0), accColor)
		else
			makePart(model, "Accessory", Vector3.new(1.5, 1.2, 1.5), CFrame.new(0, 4.6, 0), accColor, Enum.PartType.Ball)
		end
	end

	local accessoryPart = model:FindFirstChild("Accessory")
	if not accessoryPart then
		accessoryPart = makePart(model, "Accessory", Vector3.new(1, 1, 1), CFrame.new(0, 4.5, 0), GOLD_COLOR)
	end

	model.PrimaryPart = bodyPart
	model.WorldPivot = CFrame.new(0, 2, 0)

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "BrainrotLabel"
	billboard.Size = UDim2.fromOffset(260, 86)
	billboard.StudsOffset = Vector3.new(0, 5.6, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 150
	billboard.Parent = bodyPart

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundTransparency = 1
	local prefix = mutation and (mutation.name .. " ") or ""
	textLabel.Text = string.format("%s%s\n%s  |  $%d/s", prefix, definition.name, definition.rarity, income)
	textLabel.TextColor3 = rarity.color
	textLabel.TextStrokeColor3 = Color3.fromRGB(24, 29, 36)
	textLabel.TextStrokeTransparency = 0.1
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = billboard

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "BrainrotPrompt"
	prompt.ActionText = promptAction or "Catch"
	prompt.ObjectText = definition.name
	prompt.HoldDuration = 0.35
	prompt.MaxActivationDistance = 11
	prompt.RequiresLineOfSight = false
	prompt.Parent = accessoryPart

	return model, prompt
end

return CharacterFactory
