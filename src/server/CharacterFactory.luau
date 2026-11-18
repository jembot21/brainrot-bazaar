local Data = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("BrainrotData"))
local CharacterFactory = {}

local DARK_COLOR = Color3.fromRGB(30, 37, 49)
local WHITE_COLOR = Color3.fromRGB(240, 242, 245)
local GOLD_COLOR = Color3.fromRGB(255, 190, 60)
local EYE_SIZE = Vector3.new(0.55, 0.6, 0.25)

local function createPart(parent, name, size, cf, color, shape, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cf
	part.Color = color
	part.Shape = shape or Enum.PartType.Block
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function createCylinder(parent, name, diameter, height, cf, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Shape = Enum.PartType.Cylinder
	part.Size = Vector3.new(height, diameter, diameter)
	part.CFrame = cf * CFrame.Angles(0, 0, math.rad(90))
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function addFace(parent, centerPos, eyeSpacing, eyeY, eyeZ)
	local y = eyeY or 0
	local z = eyeZ or -1.5
	local spacing = eyeSpacing or 0.6

	-- Left Eye & Pupil
	createPart(parent, "EyeL", EYE_SIZE, CFrame.new(centerPos + Vector3.new(-spacing, y, z)), WHITE_COLOR, Enum.PartType.Ball)
	createPart(parent, "PupilL", Vector3.new(0.22, 0.3, 0.12), CFrame.new(centerPos + Vector3.new(-spacing, y, z - 0.12)), DARK_COLOR, Enum.PartType.Ball)

	-- Right Eye & Pupil
	createPart(parent, "EyeR", EYE_SIZE, CFrame.new(centerPos + Vector3.new(spacing, y, z)), WHITE_COLOR, Enum.PartType.Ball)
	createPart(parent, "PupilR", Vector3.new(0.22, 0.3, 0.12), CFrame.new(centerPos + Vector3.new(spacing, y, z - 0.12)), DARK_COLOR, Enum.PartType.Ball)

	-- Mouth
	createPart(parent, "Mouth", Vector3.new(0.9, 0.18, 0.1), CFrame.new(centerPos + Vector3.new(0, y - 0.45, z + 0.05)), DARK_COLOR)
end

local function addSneakers(parent, legColor)
	local sides = { -0.65, 0.65 }
	for _, x in ipairs(sides) do
		createPart(parent, "Leg", Vector3.new(0.55, 0.6, 0.55), CFrame.new(x, 0.72, -0.1), legColor)
		createPart(parent, "Shoe", Vector3.new(0.8, 0.42, 1.5), CFrame.new(x, 0.21, -0.3), WHITE_COLOR)
		local soleColor = (x < 0) and Color3.fromRGB(50, 110, 255) or Color3.fromRGB(245, 70, 70)
		createPart(parent, "Sole", Vector3.new(0.85, 0.16, 1.55), CFrame.new(x, 0.08, -0.3), soleColor)
	end
end

local function addFeet(parent, footColor, spacing)
	local sp = spacing or 0.65
	createPart(parent, "FootL", Vector3.new(0.8, 0.4, 1.1), CFrame.new(-sp, 0.2, -0.15), footColor or DARK_COLOR)
	createPart(parent, "FootR", Vector3.new(0.8, 0.4, 1.1), CFrame.new(sp, 0.2, -0.15), footColor or DARK_COLOR)
end

local function addCrown(parent, name, centerPos, diameter)
	local crownCyl = createCylinder(parent, name or "Accessory", diameter, 0.65, CFrame.new(centerPos), GOLD_COLOR)
	local r = (diameter / 2) - 0.12
	local rimOffsets = {
		Vector3.new(r, 0.35, 0),
		Vector3.new(-r, 0.35, 0),
		Vector3.new(0, 0.35, r),
		Vector3.new(0, 0.35, -r),
	}
	for i, offset in ipairs(rimOffsets) do
		createPart(parent, "CrownPoint" .. i, Vector3.new(0.25, 0.45, 0.25), CFrame.new(centerPos + offset), GOLD_COLOR)
	end
	return crownCyl
end

-- Each cast builder returns the Body and creates the Accessory used by Build.
local Builders = {}

Builders["Sir Bounce Banana"] = function(parent, bodyColor)
	local body = createPart(parent, "Body", Vector3.new(2.4, 1.8, 2.4), CFrame.new(0, 2, 0), bodyColor)
	createPart(parent, "LowerBanana", Vector3.new(2.2, 1.5, 2.2), CFrame.new(-0.45, 0.95, 0) * CFrame.Angles(0, 0, math.rad(-16)), bodyColor)
	createPart(parent, "UpperBanana", Vector3.new(2, 1.5, 2), CFrame.new(0.5, 3.35, 0) * CFrame.Angles(0, 0, math.rad(18)), bodyColor)
	createPart(parent, "BrownTip", Vector3.new(0.45, 0.4, 0.5), CFrame.new(0.75, 4.15, 0), Color3.fromRGB(90, 56, 30))
	addCrown(parent, "Accessory", Vector3.new(0.5, 4.65, 0), 1.6)
	addFace(parent, Vector3.new(0, 2, 0), 0.6, 0.4, -1.22)
	addSneakers(parent, bodyColor)
	return body
end

Builders["Pigeon Barry"] = function(parent, bodyColor)
	local body = createPart(parent, "Body", Vector3.new(3.6, 3.6, 3.6), CFrame.new(0, 2, 0), bodyColor, Enum.PartType.Ball)
	local head = createPart(parent, "Head", Vector3.new(1.8, 1.8, 1.8), CFrame.new(0, 3.6, -0.9), bodyColor, Enum.PartType.Ball)
	createPart(parent, "Beak", Vector3.new(0.5, 0.35, 0.8), CFrame.new(0, 3.5, -2), Color3.fromRGB(245, 157, 48))
	addFace(parent, head.Position, 0.48, 0.25, -0.85)

	local wingColor = Color3.new(bodyColor.R * 0.8, bodyColor.G * 0.8, bodyColor.B * 0.8)
	createPart(parent, "WingL", Vector3.new(0.35, 1.6, 2.2), CFrame.new(-1.85, 2.2, 0) * CFrame.Angles(0, 0, math.rad(20)), wingColor)
	createPart(parent, "WingR", Vector3.new(0.35, 1.6, 2.2), CFrame.new(1.85, 2.2, 0) * CFrame.Angles(0, 0, math.rad(-20)), wingColor)
	createPart(parent, "Tail", Vector3.new(1.5, 0.3, 1.1), CFrame.new(0, 2.4, 1.9) * CFrame.Angles(math.rad(25), 0, 0), wingColor)

	createPart(parent, "Accessory", Vector3.new(0.25, 1.1, 0.5), CFrame.new(0, 4.8, -0.9) * CFrame.Angles(0, 0, math.rad(20)), Color3.fromRGB(108, 202, 245))
	addSneakers(parent, Color3.fromRGB(245, 157, 48))
	return body
end

Builders["Toaster Todd"] = function(parent, bodyColor, isMutated)
	local toasterColor = isMutated and bodyColor or Color3.fromRGB(198, 205, 212)
	local body = createPart(parent, "Body", Vector3.new(3.6, 3.2, 2.8), CFrame.new(0, 2, 0), toasterColor)

	createPart(parent, "SlotL", Vector3.new(1.1, 0.25, 0.5), CFrame.new(-0.8, 3.7, 0), DARK_COLOR)
	createPart(parent, "SlotR", Vector3.new(1.1, 0.25, 0.5), CFrame.new(0.8, 3.7, 0), DARK_COLOR)

	local crustColor = Color3.fromRGB(188, 126, 78)
	createCylinder(parent, "CrustKnobL", 0.35, 0.4, CFrame.new(-0.65, 4.95, 0), crustColor)
	createCylinder(parent, "CrustKnobR", 0.35, 0.4, CFrame.new(0.65, 4.95, 0), crustColor)

	local toastRot = CFrame.Angles(0, 0, math.rad(8))
	createPart(parent, "Accessory", Vector3.new(1.7, 1.6, 0.45), CFrame.new(0, 4.3, 0) * toastRot, crustColor)
	createPart(parent, "ToastInner", Vector3.new(1.4, 1.3, 0.5), CFrame.new(0, 4.3, -0.03) * toastRot, Color3.fromRGB(232, 190, 130))

	createPart(parent, "Lever", Vector3.new(0.5, 0.3, 0.65), CFrame.new(1.95, 2.2, 0), DARK_COLOR)
	addFace(parent, Vector3.new(0, 2, 0), 0.8, 0.5, -1.42)

	for x = -0.8, 0.801, 0.4 do
		local y = 2.9 - (x * x * 0.35)
		createPart(parent, "ChainLink", Vector3.new(0.34, 0.34, 0.18), CFrame.new(x, y, -1.45), GOLD_COLOR, Enum.PartType.Block, Enum.Material.Metal)
	end

	addFeet(parent, DARK_COLOR)
	return body
end

Builders["Disco Broccoli Bro"] = function(parent, bodyColor, isMutated)
	local stalkColor = isMutated and bodyColor or Color3.fromRGB(168, 224, 150)
	local body = createCylinder(parent, "Body", 1.5, 3.2, CFrame.new(0, 2, 0), stalkColor)

	for i = 1, 5 do
		local ang = (i - 1) * (2 * math.pi / 5)
		local fx = math.cos(ang) * 0.95
		local fz = math.sin(ang) * 0.95 * 0.8
		createPart(parent, "Floret" .. i, Vector3.new(1.7, 1.7, 1.7), CFrame.new(fx, 3.65, fz), bodyColor, Enum.PartType.Ball)
	end
	createPart(parent, "TopFloret", Vector3.new(1.9, 1.9, 1.9), CFrame.new(0, 4.1, 0), bodyColor, Enum.PartType.Ball)

	createCylinder(parent, "DiscoString", 0.08, 0.9, CFrame.new(1.15, 4.7, 0) * CFrame.Angles(0, 0, math.rad(30)), Color3.fromRGB(180, 180, 180), Enum.Material.Metal)
	createPart(parent, "Accessory", Vector3.new(0.9, 0.9, 0.9), CFrame.new(1.9, 4.6, 0), Color3.fromRGB(225, 230, 238), Enum.PartType.Ball, Enum.Material.Metal)

	createPart(parent, "Sunglasses", Vector3.new(2.2, 0.55, 0.2), CFrame.new(0, 2.6, -0.78), DARK_COLOR)
	createPart(parent, "Mouth", Vector3.new(0.9, 0.18, 0.1), CFrame.new(0, 1.9, -0.8), DARK_COLOR)

	createPart(parent, "UpperArmL", Vector3.new(0.85, 1.9, 0.85), CFrame.new(-2.05, 2.5, 0) * CFrame.Angles(0, 0, math.rad(-25)), Color3.fromRGB(120, 220, 130))
	createPart(parent, "UpperArmR", Vector3.new(0.85, 1.9, 0.85), CFrame.new(2.05, 2.5, 0) * CFrame.Angles(0, 0, math.rad(25)), Color3.fromRGB(120, 220, 130))
	createPart(parent, "FistL", Vector3.new(0.95, 0.95, 0.95), CFrame.new(-2.6, 1.5, 0), Color3.fromRGB(120, 220, 130), Enum.PartType.Ball)
	createPart(parent, "FistR", Vector3.new(0.95, 0.95, 0.95), CFrame.new(2.6, 1.5, 0), Color3.fromRGB(120, 220, 130), Enum.PartType.Ball)

	addFeet(parent, stalkColor)
	return body
end

Builders["Grandma Turbo"] = function(parent, bodyColor)
	local body = createPart(parent, "Body", Vector3.new(3.6, 3.6, 3.6), CFrame.new(0, 2, 0), bodyColor, Enum.PartType.Ball)
	createPart(parent, "Bun", Vector3.new(1.5, 1.5, 1.5), CFrame.new(0, 4.1, 0.3), Color3.fromRGB(206, 211, 219), Enum.PartType.Ball)
	addFace(parent, Vector3.new(0, 2, 0), 0.75, 0.5, -1.83)

	local glassRot = CFrame.Angles(math.rad(90), 0, 0)
	createCylinder(parent, "Accessory", 0.82, 0.12, CFrame.new(-0.75, 2.5, -1.78) * glassRot, DARK_COLOR)
	createCylinder(parent, "GlassesRim", 0.82, 0.12, CFrame.new(0.75, 2.5, -1.78) * glassRot, DARK_COLOR)
	createPart(parent, "GlassesBridge", Vector3.new(0.8, 0.12, 0.1), CFrame.new(0, 2.5, -1.91), DARK_COLOR)

	createPart(parent, "Shawl", Vector3.new(3.9, 0.5, 3.9), CFrame.new(0, 1.1, 0), Color3.fromRGB(150, 110, 190))
	createCylinder(parent, "Turbo", 1.1, 1.6, CFrame.new(0, 2.2, 2) * CFrame.Angles(math.rad(90), 0, 0), Color3.fromRGB(120, 128, 140))
	createPart(parent, "Flame", Vector3.new(1, 1, 1), CFrame.new(0, 2.2, 3), Color3.fromRGB(255, 143, 40), Enum.PartType.Ball)

	addSneakers(parent, Color3.fromRGB(238, 154, 183))
	return body
end

Builders["Cactus Carl"] = function(parent, bodyColor)
	local body = createCylinder(parent, "Body", 1.6, 4.0, CFrame.new(0, 2, 0), bodyColor)

	for _, s in ipairs({ -1, 1 }) do
		createCylinder(parent, "ArmV" .. s, 0.7, 1.6, CFrame.new(s * 1.65, 2.6, 0), bodyColor)
		createCylinder(parent, "ArmH" .. s, 0.7, 1.1, CFrame.new(s * 1.2, 3.4, 0) * CFrame.Angles(0, 0, math.rad(90)), bodyColor)
	end

	for i = 1, 8 do
		local ang = i * 2.4
		local radius = 0.78
		local y = 0.9 + ((i % 4) * 0.8)
		local sx = math.cos(ang) * radius
		local sz = math.sin(ang) * radius
		createPart(parent, "Spike" .. i, Vector3.new(0.14, 0.3, 0.14), CFrame.new(sx, y, sz), WHITE_COLOR)
	end

	for i = 1, 5 do
		local ang = (i - 1) * (2 * math.pi / 5)
		local px = math.cos(ang) * 0.45
		local pz = math.sin(ang) * 0.45
		createPart(parent, "Petal" .. i, Vector3.new(0.65, 0.65, 0.65), CFrame.new(px, 4.35, pz), Color3.fromRGB(251, 100, 136), Enum.PartType.Ball)
	end
	createPart(parent, "Accessory", Vector3.new(0.55, 0.55, 0.55), CFrame.new(0, 4.5, 0), GOLD_COLOR, Enum.PartType.Ball)

	createPart(parent, "PotRim", Vector3.new(3.4, 0.7, 3.4), CFrame.new(0, 0.35, 0), Color3.fromRGB(176, 96, 64))
	addFace(parent, Vector3.new(0, 2, 0), 0.43, 0.5, -0.82)
	addSneakers(parent, bodyColor)
	return body
end

Builders["Croissant Dragon Draco"] = function(parent, bodyColor)
	local body = createPart(parent, "Body", Vector3.new(2.8, 2.8, 2.8), CFrame.new(0, 2, 0), bodyColor, Enum.PartType.Ball)
	createPart(parent, "Curl", Vector3.new(2.3, 2.3, 2.3), CFrame.new(1.7, 2.5, 0), bodyColor, Enum.PartType.Ball)

	local darkerColor = Color3.new(bodyColor.R * 0.85, bodyColor.G * 0.85, bodyColor.B * 0.85)
	createPart(parent, "CurlTip", Vector3.new(1.8, 1.8, 1.8), CFrame.new(2.9, 3.4, 0), darkerColor, Enum.PartType.Ball)
	createPart(parent, "LeftTip", Vector3.new(1.7, 1.7, 1.7), CFrame.new(-1.6, 2.3, 0), darkerColor, Enum.PartType.Ball)

	local wingColor = Color3.fromRGB(178, 64, 60)
	createPart(parent, "WingL", Vector3.new(0.25, 2.2, 1.6), CFrame.new(-0.9, 3.4, 1.2) * CFrame.Angles(0, math.rad(-20), math.rad(15)), wingColor)
	createPart(parent, "WingR", Vector3.new(0.25, 2.2, 1.6), CFrame.new(0.9, 3.4, 1.2) * CFrame.Angles(0, math.rad(20), math.rad(-15)), wingColor)

	local creamColor = Color3.fromRGB(240, 230, 200)
	createCylinder(parent, "Accessory", 0.56, 1, CFrame.new(-0.65, 3.75, 0) * CFrame.Angles(0, 0, math.rad(25)), creamColor)
	createCylinder(parent, "Horn", 0.56, 1, CFrame.new(0.65, 3.75, 0) * CFrame.Angles(0, 0, math.rad(-25)), creamColor)

	addFace(parent, Vector3.new(0, 2, 0), 0.65, 0.4, -1.38)
	addSneakers(parent, bodyColor)
	return body
end

Builders["WiFi Wizard Wally"] = function(parent, bodyColor)
	local body = createPart(parent, "Body", Vector3.new(3.4, 3.4, 3), CFrame.new(0, 2, 0), bodyColor)
	createPart(parent, "Beard", Vector3.new(1.8, 1.6, 0.35), CFrame.new(0, 1.5, -1.6), Color3.fromRGB(235, 238, 242))

	local purple = Color3.fromRGB(104, 82, 190)
	createCylinder(parent, "HatBrim", 4.4, 0.25, CFrame.new(0, 3.8, 0), purple)

	local tiers = { { diam = 3, y = 4.33 }, { diam = 2.1, y = 4.71 }, { diam = 1.2, y = 5.09 } }
	for i, tier in ipairs(tiers) do
		createCylinder(parent, "HatTier" .. i, tier.diam, 0.42, CFrame.new(0, tier.y, 0), purple)
	end

	createCylinder(parent, "Antenna", 0.15, 0.35, CFrame.new(0, 5.22, 0), purple)
	createPart(parent, "Accessory", Vector3.new(0.4, 0.4, 0.4), CFrame.new(0, 5.35, 0), Color3.fromRGB(93, 237, 246), Enum.PartType.Ball, Enum.Material.Neon)

	addFace(parent, Vector3.new(0, 2, 0), 0.75, 0.8, -1.53)
	addFeet(parent, DARK_COLOR)
	return body
end

Builders["Golden Toilet King"] = function(parent, bodyColor, isMutated)
	createPart(parent, "Base", Vector3.new(1.8, 1.2, 1.8), CFrame.new(0, 0.6, 0), WHITE_COLOR)
	local bowlColor = isMutated and bodyColor or WHITE_COLOR
	local body = createCylinder(parent, "Body", 4, 1.6, CFrame.new(0, 2, 0), bowlColor)

	createCylinder(parent, "Seat", 4.3, 0.3, CFrame.new(0, 2.9, 0), GOLD_COLOR)
	createPart(parent, "Tank", Vector3.new(3.2, 2, 1), CFrame.new(0, 3.4, 1.6), WHITE_COLOR)

	addCrown(parent, "Accessory", Vector3.new(0, 4.8, 1.6), 2)
	createPart(parent, "FlushHandle", Vector3.new(0.6, 0.2, 0.2), CFrame.new(0.9, 3.8, 1.02), GOLD_COLOR)

	addFace(parent, Vector3.new(0, 2, 0), 0.8, 0.2, -1.95)
	return body
end

Builders["Moon Cheese Golem"] = function(parent, bodyColor)
	local body = createPart(parent, "Body", Vector3.new(4.2, 3.6, 3.4), CFrame.new(0, 2, 0), bodyColor)

	local holeColor = Color3.fromRGB(214, 178, 92)
	local holes = {
		{ x = -1.5, y = 3.2, d = 0.7 },
		{ x = 1.5, y = 3.3, d = 0.8 },
		{ x = 0, y = 1.0, d = 0.6 },
		{ x = -1.5, y = 1.4, d = 0.5 },
		{ x = 1.5, y = 1.5, d = 0.65 },
	}
	for i, h in ipairs(holes) do
		createCylinder(parent, "CheeseHole" .. i, h.d, 0.12, CFrame.new(h.x, h.y, -1.73) * CFrame.Angles(math.rad(90), 0, 0), holeColor)
	end

	local armColor = Color3.new(bodyColor.R * 0.9, bodyColor.G * 0.9, bodyColor.B * 0.9)
	createPart(parent, "ArmL", Vector3.new(0.9, 2.6, 0.9), CFrame.new(-2.55, 1.9, 0), armColor)
	createPart(parent, "ArmR", Vector3.new(0.9, 2.6, 0.9), CFrame.new(2.55, 1.9, 0), armColor)

	createPart(parent, "FootL", Vector3.new(1.2, 0.8, 1.2), CFrame.new(-1.1, 0.4, 0), DARK_COLOR)
	createPart(parent, "FootR", Vector3.new(1.2, 0.8, 1.2), CFrame.new(1.1, 0.4, 0), DARK_COLOR)

	createCylinder(parent, "MoonStalk", 0.15, 0.5, CFrame.new(0, 4.3, 0), DARK_COLOR)
	local paleYellow = Color3.fromRGB(255, 226, 121)
	createPart(parent, "Accessory", Vector3.new(0.65, 0.65, 0.65), CFrame.new(0, 5.15, 0), paleYellow, Enum.PartType.Ball)
	createPart(parent, "MoonTipL", Vector3.new(0.65, 0.65, 0.65), CFrame.new(-0.45, 4.85, 0), paleYellow, Enum.PartType.Ball)
	createPart(parent, "MoonTipR", Vector3.new(0.65, 0.65, 0.65), CFrame.new(0.45, 4.85, 0), paleYellow, Enum.PartType.Ball)

	addFace(parent, Vector3.new(0, 2, 0), 1, 0.5, -1.73)
	createPart(parent, "Sunglasses", Vector3.new(2.6, 0.6, 0.2), CFrame.new(0, 2.55, -1.75), DARK_COLOR)
	return body
end

Builders["Galaxy Brain Octopus"] = function(parent, bodyColor)
	local body = createPart(parent, "Body", Vector3.new(3.4, 3.4, 3.4), CFrame.new(0, 2, 0), bodyColor, Enum.PartType.Ball)
	createPart(parent, "Brain", Vector3.new(2.4, 2.4, 2.4), CFrame.new(0, 3.6, 0), Color3.fromRGB(244, 154, 199), Enum.PartType.Ball)

	local tentColor = Color3.new(bodyColor.R * 0.85, bodyColor.G * 0.85, bodyColor.B * 0.85)
	for i = 1, 6 do
		local ang = (i - 1) * (2 * math.pi / 6)
		local tx = math.cos(ang) * 1.3
		local tz = math.sin(ang) * 1.3
		local rot = CFrame.Angles(-math.sin(ang) * math.rad(20), 0, math.cos(ang) * math.rad(20))
		createCylinder(parent, "Tentacle" .. i, 0.7, 1.6, CFrame.new(tx, 0.9, tz) * rot, tentColor)
	end

	local starColor = Color3.fromRGB(254, 238, 93)
	createPart(parent, "Accessory", Vector3.new(1.3, 1.3, 0.25), CFrame.new(1.6, 3.9, -0.6), starColor)
	createPart(parent, "StarPoints", Vector3.new(1.3, 1.3, 0.25), CFrame.new(1.6, 3.9, -0.6) * CFrame.Angles(0, 0, math.rad(45)), starColor)

	createPart(parent, "BigEyeL", Vector3.new(1, 1, 1), CFrame.new(-0.8, 2.5, -1.55), WHITE_COLOR, Enum.PartType.Ball)
	createPart(parent, "BigEyeR", Vector3.new(1, 1, 1), CFrame.new(0.8, 2.5, -1.55), WHITE_COLOR, Enum.PartType.Ball)
	createPart(parent, "PupilL", Vector3.new(0.48, 0.48, 0.48), CFrame.new(-0.8, 2.5, -2), DARK_COLOR, Enum.PartType.Ball)
	createPart(parent, "PupilR", Vector3.new(0.48, 0.48, 0.48), CFrame.new(0.8, 2.5, -2), DARK_COLOR, Enum.PartType.Ball)
	createPart(parent, "Mouth", Vector3.new(0.9, 0.18, 0.1), CFrame.new(0, 1.75, -1.7), DARK_COLOR)
	return body
end

Builders["Rainbow Sock Puppet"] = function(parent, bodyColor)
	local body = createCylinder(parent, "Body", 2.7, 1.3, CFrame.new(0, 2, 0), bodyColor)
	createCylinder(parent, "LowerSock", 2.7, 1.3, CFrame.new(0, 0.75, 0.2) * CFrame.Angles(math.rad(-6), 0, 0), bodyColor)
	createCylinder(parent, "UpperSock", 2.7, 1.3, CFrame.new(0, 3.2, -0.35) * CFrame.Angles(math.rad(-12), 0, 0), bodyColor)

	local rainbowColors = { Color3.fromRGB(245, 92, 92), Color3.fromRGB(254, 202, 87), Color3.fromRGB(72, 219, 251) }
	for i = 1, 3 do
		local y = 0.1 + (i * 1.25)
		local z = 0.25 - (i * 0.2)
		createCylinder(parent, "RainbowBand" .. i, 2.84, 0.3, CFrame.new(0, y, z) * CFrame.Angles(math.rad(-6), 0, 0), rainbowColors[i])
	end

	createPart(parent, "Head", Vector3.new(2.5, 2.5, 2.5), CFrame.new(0, 3.95, -0.9), bodyColor, Enum.PartType.Ball)
	createPart(parent, "Snout", Vector3.new(1.6, 1.6, 1.6), CFrame.new(0, 3.8, -1.8), bodyColor, Enum.PartType.Ball)
	createPart(parent, "Mouth", Vector3.new(1.2, 0.18, 0.8), CFrame.new(0, 3.25, -1.7) * CFrame.Angles(math.rad(15), 0, 0), Color3.fromRGB(115, 32, 55))

	for _, s in ipairs({ -1, 1 }) do
		createCylinder(parent, "EyeStalk" .. s, 0.2, 0.5, CFrame.new(s * 0.65, 4.85, -0.9), WHITE_COLOR)
		local eyeName = (s < 0) and "Accessory" or "GooglyEye"
		createPart(parent, eyeName, Vector3.new(0.6, 0.6, 0.6), CFrame.new(s * 0.7, 5.2, -0.9), WHITE_COLOR, Enum.PartType.Ball)
		createPart(parent, "Pupil" .. s, Vector3.new(0.3, 0.3, 0.3), CFrame.new(s * 0.7, 5.2, -1.18), DARK_COLOR, Enum.PartType.Ball)
	end

	createCylinder(parent, "Cuff", 3, 0.5, CFrame.new(0, 0.25, 0.2), WHITE_COLOR)
	return body
end

local function buildGeneric(parent, definition, rarity, bodyColor)
	local body = createPart(parent, "Body", Vector3.new(4, 4, 3), CFrame.new(0, 2, 0), bodyColor, rarity.shape)

	-- Eyes & Pupils on generic body
	createPart(parent, "EyeL", EYE_SIZE, CFrame.new(-0.8, 2.2, -1.52), WHITE_COLOR, Enum.PartType.Ball)
	createPart(parent, "EyeR", EYE_SIZE, CFrame.new(0.8, 2.2, -1.52), WHITE_COLOR, Enum.PartType.Ball)
	createPart(parent, "PupilL", Vector3.new(0.22, 0.3, 0.12), CFrame.new(-0.8, 2.2, -1.68), DARK_COLOR, Enum.PartType.Ball)
	createPart(parent, "PupilR", Vector3.new(0.22, 0.3, 0.12), CFrame.new(0.8, 2.2, -1.68), DARK_COLOR, Enum.PartType.Ball)
	createPart(parent, "Mouth", Vector3.new(0.9, 0.18, 0.1), CFrame.new(0, 1.6, -1.52), DARK_COLOR)

	local accColors = {
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

	local accKind = definition.accessory or "Crown"
	local accColor = accColors[accKind] or GOLD_COLOR

	if accKind == "Crown" or accKind == "WizardHat" or accKind == "Horns" then
		createCylinder(parent, "Accessory", 1.5, 1.2, CFrame.new(0, 4.4, 0), accColor)
	else
		createPart(parent, "Accessory", Vector3.new(1.5, 1.2, 1.5), CFrame.new(0, 4.4, 0), accColor, Enum.PartType.Ball)
	end

	return body
end

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
		bodyPart = buildGeneric(model, definition, rarity, bodyColor)
	end

	local accessoryPart = model:FindFirstChild("Accessory")
	if not accessoryPart then
		accessoryPart = createPart(model, "Accessory", Vector3.new(1, 1, 1), CFrame.new(0, 4.2, 0), GOLD_COLOR)
	end

	-- Cylinder bodies are rotated to stand upright. Keep the model's forward axis at -Z.
	bodyPart.PivotOffset = bodyPart.CFrame:ToObjectSpace(CFrame.new(0, 2, 0))
	model.PrimaryPart = bodyPart
	model.WorldPivot = CFrame.new(0, 2, 0)

	-- BrainrotLabel BillboardGui
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "BrainrotLabel"
	billboard.Size = UDim2.fromOffset(260, 86)
	billboard.StudsOffset = Vector3.new(0, 5.6, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 150
	billboard.Parent = bodyPart

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	local mutationPrefix = mutation and (mutation.name .. " ") or ""
	label.Text = string.format("%s%s\n%s  |  $%d/s", mutationPrefix, definition.name, definition.rarity, income)
	label.TextColor3 = rarity.color
	label.TextStrokeColor3 = Color3.fromRGB(24, 29, 36)
	label.TextStrokeTransparency = 0.1
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = billboard

	-- BrainrotPrompt ProximityPrompt
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

function CharacterFactory.Create(definition, mutation)
	local income = Data.Income(definition, mutation)
	local model, prompt = CharacterFactory.Build(definition, Data.Rarities[definition.rarity], mutation, income)
	return {definition = definition, mutation = mutation, model = model, prompt = prompt}
end

return CharacterFactory
