local CharacterFactory = {}

local accessoryColors = {
	Crown = Color3.fromRGB(255, 208, 47), Feather = Color3.fromRGB(40, 111, 173), Toast = Color3.fromRGB(199, 121, 57),
	DiscoBall = Color3.fromRGB(230, 91, 213), Glasses = Color3.fromRGB(30, 35, 42), Flower = Color3.fromRGB(251, 100, 136),
	Horns = Color3.fromRGB(108, 69, 43), WizardHat = Color3.fromRGB(76, 68, 177), Moon = Color3.fromRGB(244, 233, 158),
	Star = Color3.fromRGB(254, 238, 93), Sock = Color3.fromRGB(96, 236, 210),
}

local function makePart(parent, name, size, position, color, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = position
	p.Color = color
	p.Shape = shape or Enum.PartType.Block
	p.Anchored = true
	p.CanCollide = false
	p.Material = Enum.Material.SmoothPlastic
	p.Parent = parent
	return p
end

function CharacterFactory.Build(definition, rarity, mutation, income, promptAction)
	local model = Instance.new("Model")
	model.Name = definition.name
	model:SetAttribute("BrainrotName", definition.name)
	model:SetAttribute("Rarity", definition.rarity)
	model:SetAttribute("Mutation", mutation and mutation.name or "")
	model:SetAttribute("Income", income)
	local bodyColor = mutation and mutation.color or definition.color or rarity.color
	local body = makePart(model, "Body", Vector3.new(4, 4, 3), Vector3.new(0, 2, 0), bodyColor, rarity.shape)
	model.PrimaryPart = body
	makePart(model, "LeftEye", Vector3.new(0.55, 0.6, 0.25), body.Position + Vector3.new(-0.8, 0.5, -1.52), Color3.fromRGB(255, 255, 255), Enum.PartType.Ball)
	makePart(model, "RightEye", Vector3.new(0.55, 0.6, 0.25), body.Position + Vector3.new(0.8, 0.5, -1.52), Color3.fromRGB(255, 255, 255), Enum.PartType.Ball)
	makePart(model, "LeftPupil", Vector3.new(0.22, 0.3, 0.12), body.Position + Vector3.new(-0.8, 0.45, -1.68), Color3.fromRGB(30, 37, 49), Enum.PartType.Ball)
	makePart(model, "RightPupil", Vector3.new(0.22, 0.3, 0.12), body.Position + Vector3.new(0.8, 0.45, -1.68), Color3.fromRGB(30, 37, 49), Enum.PartType.Ball)
	local accessory = makePart(model, "Accessory", Vector3.new(1.5, 1.2, 1.5), body.Position + Vector3.new(0, 2.1, 0), accessoryColors[definition.accessory] or Color3.new(1, 1, 1), Enum.PartType.Ball)
	if definition.accessory == "Crown" or definition.accessory == "WizardHat" or definition.accessory == "Horns" then accessory.Shape = Enum.PartType.Cylinder end
	local label = Instance.new("BillboardGui")
	label.Name = "BrainrotLabel"
	label.Size = UDim2.fromOffset(260, 86)
	label.StudsOffset = Vector3.new(0, 4.7, 0)
	label.AlwaysOnTop = true
	label.MaxDistance = 150
	label.Parent = body
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Text = string.format("%s%s\n%s  |  $%d/s", mutation and (mutation.name .. " ") or "", definition.name, definition.rarity, income)
	text.TextColor3 = Color3.new(1, 1, 1)
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
