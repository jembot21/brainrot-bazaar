-- Build each mascot in local space, facing -Z, with a shared body pivot and prompt contract.

local CharacterFactory = {}

local fallbackAccessoryColors = {
    Crown = Color3.fromRGB(255, 208, 47), Feather = Color3.fromRGB(40, 111, 173), Toast = Color3.fromRGB(199, 121, 57),
    DiscoBall = Color3.fromRGB(230, 91, 213), Glasses = Color3.fromRGB(30, 35, 42), Flower = Color3.fromRGB(251, 100, 136),
    Horns = Color3.fromRGB(108, 69, 43), WizardHat = Color3.fromRGB(76, 68, 177), Moon = Color3.fromRGB(244, 233, 158),
    Star = Color3.fromRGB(254, 238, 93), Sock = Color3.fromRGB(96, 236, 210),
}

local function createPart(parent, name, size, position, color, shape, orientation)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Color = color
    p.Shape = shape or Enum.PartType.Block
    p.Orientation = orientation or Vector3.zero
    p.Anchored = true
    p.CanCollide = false
    p.Material = Enum.Material.SmoothPlastic
    p.Parent = parent
    return p
end

local V = Vector3.new
local C = Color3.fromRGB
local dark, white, gold = C(30, 37, 49), C(240, 242, 245), C(255, 190, 60)
local function part(c, name, size, position, color, rotation, shape)
    return createPart(c.model, name, size, position, color, shape, rotation)
end
local function ball(c, name, diameter, position, color)
    return part(c, name, V(diameter, diameter, diameter), position, color, nil, Enum.PartType.Ball)
end
local function cylinder(c, name, diameter, height, position, color, rotation)
    local p = part(c, name, V(height, diameter, diameter), position, color, nil, Enum.PartType.Cylinder)
    local r = rotation or Vector3.zero
    p.CFrame = CFrame.new(position) * CFrame.Angles(math.rad(r.X), math.rad(r.Y), math.rad(r.Z)) * CFrame.Angles(0, 0, math.pi / 2)
    return p
end
local function createBody(c, size, shape, color)
    return part(c, "Body", size, V(0, 2, 0), color or c.bodyColor, nil, shape)
end
local function attachFace(body, y, z, spacing)
    for _, side in ipairs({-1, 1}) do
        createPart(body.Parent, side == -1 and "LeftEye" or "RightEye", V(0.55, 0.6, 0.25), body.Position + V(side * spacing, y, z), white, Enum.PartType.Ball)
        createPart(body.Parent, side == -1 and "LeftPupil" or "RightPupil", V(0.22, 0.3, 0.12), body.Position + V(side * spacing, y - 0.05, z - 0.16), dark, Enum.PartType.Ball)
    end
    createPart(body.Parent, "Mouth", V(0.9, 0.18, 0.1), body.Position + V(0, y - 0.7, z - 0.02), dark)
end
local function feet(c, color, spacing)
    for _, side in ipairs({-1, 1}) do part(c, "Foot", V(0.8, 0.4, 1.1), V(side * (spacing or 0.65), 0.2, -0.15), color or dark) end
end
local function sneakers(c, legColor)
    for _, s in ipairs({-1, 1}) do
        part(c, "Leg", V(0.55, 0.6, 0.55), V(s * 0.65, 0.72, -0.1), legColor)
        part(c, "Shoe", V(0.8, 0.42, 1.5), V(s * 0.65, 0.21, -0.3), white)
        part(c, "Sole", V(0.85, 0.16, 1.55), V(s * 0.65, 0.08, -0.3), s == -1 and C(50, 110, 255) or C(245, 70, 70))
    end
end
local function crown(c, position, diameter)
    cylinder(c, "Accessory", diameter, 0.65, position, gold)
    for i = 1, 4 do
        local a = i * math.pi / 2
        part(c, "CrownPoint", V(0.25, 0.45, 0.25), position + V(math.cos(a) * diameter * 0.4, 0.4, math.sin(a) * diameter * 0.4), gold)
    end
end

local builders = {}
builders["Sir Bounce Banana"] = function(c)
    local body = createBody(c, V(2.4, 1.8, 2.4))
    part(c, "LowerBanana", V(2.2, 1.5, 2.2), V(-0.45, 0.95, 0), c.bodyColor, V(0, 0, -16))
    part(c, "UpperBanana", V(2, 1.5, 2), V(0.5, 3.35, 0), c.bodyColor, V(0, 0, 18))
    part(c, "BrownTip", V(0.45, 0.4, 0.5), V(0.75, 4.15, 0), C(90, 56, 30))
    crown(c, V(0.5, 4.65, 0), 1.6)
    attachFace(body, 0.4, -1.22, 0.6)
    sneakers(c, c.bodyColor)
end
builders["Pigeon Barry"] = function(c)
    createBody(c, V(3.6, 3.6, 3.6), Enum.PartType.Ball)
    local head = ball(c, "Head", 1.8, V(0, 3.6, -0.9), c.bodyColor)
    part(c, "Beak", V(0.5, 0.35, 0.8), V(0, 3.5, -2), C(245, 157, 48))
    attachFace(head, 0.25, -0.85, 0.48)
    for _, s in ipairs({-1, 1}) do
        part(c, "Wing", V(0.35, 1.6, 2.2), V(s * 1.85, 2.2, 0), c.bodyColor * 0.8, V(0, 0, -s * 20))
    end
    sneakers(c, C(245, 157, 48))
    part(c, "Tail", V(1.5, 0.3, 1.1), V(0, 2.4, 1.9), c.bodyColor * 0.8, V(25, 0, 0))
    part(c, "Accessory", V(0.25, 1.1, 0.5), V(0, 4.8, -0.9), C(108, 202, 245), V(0, 0, 20))
end
builders["Toaster Todd"] = function(c)
    local body = createBody(c, V(3.6, 3.2, 2.8), nil, c.mutated and c.bodyColor or C(198, 205, 212))
    for _, s in ipairs({-1, 1}) do
        part(c, "Slot", V(1.1, 0.25, 0.5), V(s * 0.8, 3.7, 0), dark)
        cylinder(c, "CrustKnob", 0.35, 0.4, V(s * 0.65, 4.95, 0), C(188, 126, 78))
    end
    part(c, "Accessory", V(1.7, 1.6, 0.45), V(0, 4.3, 0), C(188, 126, 78), V(0, 0, 8))
    part(c, "ToastInner", V(1.4, 1.3, 0.5), V(0, 4.3, -0.03), C(232, 190, 130), V(0, 0, 8))
    part(c, "Lever", V(0.5, 0.3, 0.65), V(1.95, 2.2, 0), dark)
    attachFace(body, 0.5, -1.42, 0.8)
    for i = 0, 4 do
        local x = -0.8 + i * 0.4
        local link = part(c, "GoldChain", V(0.34, 0.34, 0.18), V(x, 2.9 - x^2 * 0.35, -1.45), gold)
        link.Material = Enum.Material.Metal
    end
    feet(c)
end
builders["Disco Broccoli Bro"] = function(c)
    local stalk = c.mutated and c.bodyColor or C(168, 224, 150)
    cylinder(c, "Body", 1.5, 3.2, V(0, 2, 0), stalk)
    for i = 1, 5 do
        local a = i * math.pi * 2 / 5
        ball(c, "Floret", 1.7, V(math.cos(a) * 0.95, 3.65, math.sin(a) * 0.8), c.bodyColor)
    end
    ball(c, "TopFloret", 1.9, V(0, 4.1, 0), c.bodyColor)
    cylinder(c, "DiscoString", 0.08, 1.7, V(1.15, 4.7, 0), dark, V(0, 0, -65))
    local disco = ball(c, "Accessory", 0.9, V(1.9, 4.6, 0), C(225, 230, 238))
    disco.Material = Enum.Material.Metal
    part(c, "Sunglasses", V(2.2, 0.55, 0.2), V(0, 2.6, -0.78), dark)
    part(c, "Mouth", V(0.9, 0.18, 0.1), V(0, 1.9, -0.8), dark)
    feet(c, stalk)
    for _, s in ipairs({-1, 1}) do
        part(c, "UpperArm", V(0.85, 1.9, 0.85), V(s * 2.05, 2.5, 0), C(120, 220, 130), V(0, 0, s * -18))
        ball(c, "Fist", 0.95, V(s * 2.6, 1.5, 0), C(120, 220, 130))
    end
end
builders["Grandma Turbo"] = function(c)
    local body = createBody(c, V(3.6, 3.6, 3.6), Enum.PartType.Ball)
    ball(c, "Bun", 1.5, V(0, 4.1, 0.3), C(206, 211, 219))
    attachFace(body, 0.5, -1.83, 0.75)
    for _, s in ipairs({-1, 1}) do
        -- Dark rims sit behind smaller eye whites so the pupils remain visible.
        cylinder(c, s == -1 and "Accessory" or "GlassesRim", 0.82, 0.12, V(s * 0.75, 2.5, -1.78), dark, V(90, 0, 0))
    end
    sneakers(c, C(238, 154, 183))
    part(c, "GlassesBridge", V(0.8, 0.12, 0.1), V(0, 2.5, -1.91), dark)
    part(c, "Shawl", V(3.9, 0.5, 3.9), V(0, 1.1, 0), C(150, 110, 190))
    cylinder(c, "Turbo", 1.1, 1.6, V(0, 2.2, 2), C(120, 128, 140), V(90, 0, 0))
    ball(c, "Flame", 1, V(0, 2.2, 3), C(255, 143, 40))
end
builders["Cactus Carl"] = function(c)
    cylinder(c, "Body", 1.6, 4.0, V(0, 2, 0), c.bodyColor)
    for _, s in ipairs({-1, 1}) do
        cylinder(c, "Arm", 0.7, 1.6, V(s * 1.65, 2.6, 0), c.bodyColor)
        cylinder(c, "ArmElbow", 0.7, 1.1, V(s * 1.2, 3.4, 0), c.bodyColor, V(0, 0, 90))
    end
    for i = 1, 8 do
        local a = i * 2.4
        part(c, "Spike", V(0.14, 0.3, 0.14), V(math.sin(a) * 0.78, 0.9 + (i % 4) * 0.8, math.cos(a) * 0.78), white)
    end
    for i = 1, 5 do
        local a = i * math.pi * 2 / 5
        ball(c, "Petal", 0.65, V(math.cos(a) * 0.45, 4.35, math.sin(a) * 0.45), C(251, 100, 136))
    end
    ball(c, "Accessory", 0.55, V(0, 4.5, 0), gold)
    part(c, "PotRim", V(3.4, 0.7, 3.4), V(0, 0.35, 0), C(176, 96, 64))
    sneakers(c, c.bodyColor)
    attachFace(c.model.Body, 0.5, -0.82, 0.43)
end
builders["Croissant Dragon Draco"] = function(c)
    local body = createBody(c, V(2.8, 2.8, 2.8), Enum.PartType.Ball)
    ball(c, "Curl", 2.3, V(1.7, 2.5, 0), c.bodyColor)
    ball(c, "CurlTip", 1.8, V(2.9, 3.4, 0), c.bodyColor * 0.85)
    ball(c, "LeftTip", 1.7, V(-1.6, 2.3, 0), c.bodyColor * 0.85)
    for _, s in ipairs({-1, 1}) do
        part(c, "Wing", V(0.25, 2.2, 1.6), V(s * 0.9, 3.4, 1.2), C(178, 64, 60), V(-30, 0, s * 25))
        cylinder(c, s == -1 and "Accessory" or "Horn", 0.56, 1, V(s * 0.65, 3.75, 0), C(240, 230, 200), V(0, 0, -s * 25))
    end
    attachFace(body, 0.4, -1.38, 0.65)
    sneakers(c, c.bodyColor)
end
builders["WiFi Wizard Wally"] = function(c)
    local body = createBody(c, V(3.4, 3.4, 3))
    part(c, "Beard", V(1.8, 1.6, 0.35), V(0, 1.5, -1.6), C(235, 238, 242))
    local purple = C(104, 82, 190)
    cylinder(c, "HatBrim", 4.4, 0.25, V(0, 3.8, 0), purple)
    for i, d in ipairs({3, 2.1, 1.2}) do cylinder(c, "HatTier", d, 0.42, V(0, 3.95 + i * 0.38, 0), purple) end
    cylinder(c, "Antenna", 0.1, 0.3, V(0, 5.22, 0), dark)
    local orb = ball(c, "Accessory", 0.4, V(0, 5.35, 0), C(93, 237, 246))
    orb.Material = Enum.Material.Neon
    attachFace(body, 0.8, -1.53, 0.75)
    feet(c)
end
builders["Golden Toilet King"] = function(c)
    part(c, "Base", V(1.8, 1.2, 1.8), V(0, 0.6, 0), white)
    cylinder(c, "Body", 4, 1.6, V(0, 2, 0), c.mutated and c.bodyColor or white)
    cylinder(c, "Seat", 4.3, 0.3, V(0, 2.9, 0), gold)
    part(c, "Tank", V(3.2, 2, 1), V(0, 3.4, 1.6), white)
    crown(c, V(0, 4.8, 1.6), 2)
    part(c, "FlushHandle", V(0.6, 0.2, 0.2), V(0.9, 3.8, 1.02), gold)
    attachFace(c.model.Body, 0.2, -1.95, 0.8)
end
builders["Moon Cheese Golem"] = function(c)
    local body = createBody(c, V(4.2, 3.6, 3.4))
    for i, pos in ipairs({V(-1.5, 3.2, -1.73), V(1.5, 3.3, -1.73), V(0, 1, -1.73), V(-1.5, 1.4, -1.73), V(1.5, 1.5, -1.73)}) do
        cylinder(c, "CheeseHole", 0.5 + (i % 3) * 0.15, 0.12, pos, C(214, 178, 92), V(90, 0, 0))
    end
    for _, s in ipairs({-1, 1}) do
        part(c, "Arm", V(0.9, 2.6, 0.9), V(s * 2.55, 1.9, 0), c.bodyColor * 0.9)
        part(c, "Foot", V(1.2, 0.8, 1.2), V(s * 1.1, 0.4, 0), dark)
    end
    cylinder(c, "MoonStalk", 0.12, 1, V(0, 4.3, 0), dark)
    ball(c, "Accessory", 0.65, V(0, 5.15, 0), C(255, 226, 121))
    for _, s in ipairs({-1, 1}) do ball(c, "MoonTip", 0.65, V(s * 0.45, 4.85, 0), C(255, 226, 121)) end
    attachFace(body, 0.5, -1.73, 1)
    part(c, "Sunglasses", V(2.6, 0.6, 0.2), V(0, 2.55, -1.75), C(25, 28, 34))
end
builders["Galaxy Brain Octopus"] = function(c)
    local body = createBody(c, V(3.4, 3.4, 3.4), Enum.PartType.Ball)
    ball(c, "Brain", 2.4, V(0, 3.6, 0), C(244, 154, 199))
    for i = 1, 6 do
        local a = i * math.pi / 3
        cylinder(c, "Tentacle", 0.7, 1.6, V(math.cos(a) * 1.3, 0.9, math.sin(a) * 1.3), c.bodyColor * 0.85, V(math.sin(a) * 20, 0, -math.cos(a) * 20))
    end
    part(c, "Accessory", V(1.3, 1.3, 0.25), V(1.6, 3.9, -0.6), C(254, 238, 93))
    part(c, "StarPoints", V(1.3, 1.3, 0.25), V(1.6, 3.9, -0.6), C(254, 238, 93), V(0, 0, 45))
    for _, s in ipairs({-1, 1}) do
        ball(c, "BigEye", 1, V(s * 0.8, 2.5, -1.55), white)
        ball(c, "Pupil", 0.48, V(s * 0.8, 2.5, -2), dark)
    end
    part(c, "Mouth", V(0.9, 0.18, 0.1), body.Position + V(0, -0.25, -1.7), dark)
end
builders["Rainbow Sock Puppet"] = function(c)
    cylinder(c, "Body", 2.7, 1.3, V(0, 2, 0), c.bodyColor)
    cylinder(c, "LowerSock", 2.7, 1.3, V(0, 0.75, 0.2), c.bodyColor, V(-6, 0, 0))
    cylinder(c, "UpperSock", 2.7, 1.3, V(0, 3.2, -0.35), c.bodyColor, V(-12, 0, 0))
    for i, color in ipairs({C(245, 92, 92), C(254, 202, 87), C(72, 219, 251)}) do
        cylinder(c, "RainbowBand", 2.84, 0.3, V(0, 0.1 + i * 1.25, 0.25 - i * 0.2), color, V(-6, 0, 0))
    end
    ball(c, "Head", 2.5, V(0, 3.95, -0.9), c.bodyColor)
    ball(c, "Snout", 1.6, V(0, 3.8, -1.8), c.bodyColor)
    part(c, "Mouth", V(1.2, 0.18, 0.8), V(0, 3.25, -1.7), C(115, 32, 55), V(15, 0, 0))
    for _, s in ipairs({-1, 1}) do
        cylinder(c, "EyeStalk", 0.2, 0.5, V(s * 0.65, 4.85, -0.9), white, V(0, 0, s * 10))
        ball(c, s == -1 and "Accessory" or "GooglyEye", 0.6, V(s * 0.7, 5.2, -0.9), white)
        ball(c, "Pupil", 0.3, V(s * 0.7, 5.2, -1.18), dark)
    end
    cylinder(c, "Cuff", 3, 0.5, V(0, 0.25, 0.2), white)
end

function CharacterFactory.Build(definition, rarity, mutation, income, promptAction)
    local model = Instance.new("Model")
    model.Name = definition.name
    model:SetAttribute("BrainrotName", definition.name)
    model:SetAttribute("Rarity", definition.rarity)
    model:SetAttribute("Mutation", mutation and mutation.name or "")
    model:SetAttribute("Income", income)
    local bodyColor = mutation and mutation.color or definition.color or rarity.color
    local builder = builders[definition.name]
    if builder then
        builder({model = model, bodyColor = bodyColor, definition = definition, rarity = rarity, mutated = mutation ~= nil})
    else
        -- Preserve the original generic appearance for future, unknown cast members.
        local body = createPart(model, "Body", Vector3.new(4, 4, 3), Vector3.new(0, 2, 0), bodyColor, rarity.shape)
    createPart(model, "LeftEye", Vector3.new(0.55, 0.6, 0.25), body.Position + Vector3.new(-0.8, 0.5, -1.52), Color3.fromRGB(255, 255, 255), Enum.PartType.Ball)
    createPart(model, "RightEye", Vector3.new(0.55, 0.6, 0.25), body.Position + Vector3.new(0.8, 0.5, -1.52), Color3.fromRGB(255, 255, 255), Enum.PartType.Ball)
    createPart(model, "LeftPupil", Vector3.new(0.22, 0.3, 0.12), body.Position + Vector3.new(-0.8, 0.45, -1.68), Color3.fromRGB(30, 37, 49), Enum.PartType.Ball)
    createPart(model, "RightPupil", Vector3.new(0.22, 0.3, 0.12), body.Position + Vector3.new(0.8, 0.45, -1.68), Color3.fromRGB(30, 37, 49), Enum.PartType.Ball)
    local accessory = createPart(model, "Accessory", Vector3.new(1.5, 1.2, 1.5), body.Position + Vector3.new(0, 2.1, 0), fallbackAccessoryColors[definition.accessory] or Color3.new(1, 1, 1), Enum.PartType.Ball)
    if definition.accessory == "Crown" or definition.accessory == "WizardHat" or definition.accessory == "Horns" then
        accessory.Shape = Enum.PartType.Cylinder
    end
    end
    local body = model:FindFirstChild("Body")
    local accessory = model:FindFirstChild("Accessory")
    model.PrimaryPart = body
    model.WorldPivot = CFrame.new(0, 2, 0)
    local label = Instance.new("BillboardGui")
    label.Name = "BrainrotLabel"
    label.Size = UDim2.fromOffset(260, 86)
    label.StudsOffset = Vector3.new(0, 5.6, 0)
    label.AlwaysOnTop = true
    label.MaxDistance = 150
    label.Parent = body
    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1, 1)
    text.BackgroundTransparency = 1
    text.Text = string.format("%s%s\n%s  |  $%d/s", mutation and (mutation.name .. " ") or "", definition.name, definition.rarity, income)
    text.TextColor3 = rarity.color
    text.TextStrokeColor3 = Color3.fromRGB(24, 29, 36)
    text.TextStrokeTransparency = 0.1
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.Parent = label
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "BrainrotPrompt"
    prompt.ActionText = promptAction or "Catch"
    prompt.ObjectText = definition.name
    prompt.HoldDuration = 0.35
    prompt.MaxActivationDistance = 11
    prompt.RequiresLineOfSight = false
    prompt.Parent = accessory
    return model, prompt
end

return CharacterFactory
