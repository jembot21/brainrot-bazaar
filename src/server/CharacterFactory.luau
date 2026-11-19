local CollectionService = game:GetService("CollectionService")
local Data = require(game:GetService("ReplicatedStorage").Shared.BrainrotData)

local CharacterFactory = {}

local function part(parent, name, size, position, color, shape)
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.Position = position
	item.Color = color
	item.Anchored = true
	item.CanCollide = false
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	if shape then
		item.Shape = shape
	end
	item.Parent = parent
	CollectionService:AddTag(item, "BrainrotCharacter")
	return item
end

local function accessory(model, kind, center, accent)
	if kind == "Ears" then
		part(model, "LeftEar", Vector3.new(0.35, 0.65, 0.35), center + Vector3.new(-0.58, 1.05, 0), accent, Enum.PartType.Ball)
		part(model, "RightEar", Vector3.new(0.35, 0.65, 0.35), center + Vector3.new(0.58, 1.05, 0), accent, Enum.PartType.Ball)
	elseif kind == "Antennae" then
		for _, x in ipairs({ -0.3, 0.3 }) do
			part(model, "Antenna", Vector3.new(0.12, 0.8, 0.12), center + Vector3.new(x, 1.2, 0), accent)
			part(model, "AntennaTip", Vector3.new(0.3, 0.3, 0.3), center + Vector3.new(x, 1.6, 0), accent, Enum.PartType.Ball)
		end
	elseif kind == "Tail" then
		part(model, "Tail", Vector3.new(0.35, 0.35, 1.05), center + Vector3.new(0, -0.15, 0.88), accent, Enum.PartType.Ball)
	elseif kind == "Crown" then
		part(model, "CrownBand", Vector3.new(0.9, 0.2, 0.5), center + Vector3.new(0, 1.0, 0), accent)
		for x = -1, 1 do
			part(model, "CrownPoint", Vector3.new(0.2, 0.38, 0.2), center + Vector3.new(x * 0.3, 1.27, 0), accent)
		end
	elseif kind == "Hat" then
		part(model, "HatBrim", Vector3.new(1.25, 0.15, 0.8), center + Vector3.new(0, 1.0, 0), accent)
		part(model, "HatTop", Vector3.new(0.72, 0.48, 0.62), center + Vector3.new(0, 1.3, 0), accent)
	elseif kind == "Wings" then
		part(model, "LeftWing", Vector3.new(0.65, 0.55, 0.18), center + Vector3.new(-0.78, 0.05, 0.25), accent, Enum.PartType.Ball)
		part(model, "RightWing", Vector3.new(0.65, 0.55, 0.18), center + Vector3.new(0.78, 0.05, 0.25), accent, Enum.PartType.Ball)
	elseif kind == "Glasses" then
		for _, x in ipairs({ -0.3, 0.3 }) do
			local lens = part(model, "GlassesLens", Vector3.new(0.38, 0.32, 0.12), center + Vector3.new(x, 0.35, -0.54), accent)
			lens.Material = Enum.Material.Neon
		end
	elseif kind == "Halo" then
		local halo = part(model, "Halo", Vector3.new(1.05, 0.12, 1.05), center + Vector3.new(0, 1.35, 0), accent, Enum.PartType.Cylinder)
		halo.Orientation = Vector3.new(0, 0, 90)
	end
end

function CharacterFactory.Create(speciesName, mutationName)
	local species = Data.SpeciesByName[speciesName]
	assert(species, "Unknown brainrot species: " .. tostring(speciesName))
	local mutation = Data.Mutations[1]
	for _, candidate in ipairs(Data.Mutations) do
		if candidate.Name == mutationName then
			mutation = candidate
			break
		end
	end

	local model = Instance.new("Model")
	model.Name = species.Name
	model:SetAttribute("Species", species.Name)
	model:SetAttribute("Tier", species.Tier)
	model:SetAttribute("Mutation", mutation.Name)
	model:SetAttribute("Income", species.Income * mutation.Income)
	model:SetAttribute("Price", species.Price)
	local center = Vector3.new(0, 2, 0)
	local tint = mutation.Name == "Normal" and Color3.new(1, 1, 1) or mutation.Color
	local bodyColor = species.Body:Lerp(tint, mutation.Name == "Normal" and 0 or 0.62)
	local body = part(model, "Body", Vector3.new(1.4, 1.5, 1.1), center, bodyColor)
	body.CanCollide = true
	local head = part(model, "Head", Vector3.new(1.2, 1.0, 1.0), center + Vector3.new(0, 1.1, 0), bodyColor)
	part(model, "LeftEye", Vector3.new(0.15, 0.19, 0.08), center + Vector3.new(-0.23, 1.18, -0.52), Color3.fromRGB(35, 38, 49), Enum.PartType.Ball)
	part(model, "RightEye", Vector3.new(0.15, 0.19, 0.08), center + Vector3.new(0.23, 1.18, -0.52), Color3.fromRGB(35, 38, 49), Enum.PartType.Ball)
	part(model, "Smile", Vector3.new(0.28, 0.08, 0.08), center + Vector3.new(0, 0.91, -0.54), Color3.fromRGB(35, 38, 49))
	accessory(model, species.Accessory, center, species.Accent:Lerp(tint, mutation.Name == "Normal" and 0 or 0.5))

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "BrainrotLabel"
	billboard.Size = UDim2.fromScale(6.5, 2)
	billboard.StudsOffset = Vector3.new(0, 2.25, 0)
	billboard.MaxDistance = 85
	billboard.AlwaysOnTop = false
	billboard.Adornee = head
	billboard.Parent = model
	local label = Instance.new("TextLabel")
	label.Name = "Name"
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Position = UDim2.fromOffset(0, -1)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextStrokeTransparency = 0.35
	label.TextColor3 = mutation.Name == "Normal" and Color3.new(1, 1, 1) or mutation.Color
	label.Text = mutation.Name == "Normal" and species.Name or (mutation.Name .. " " .. species.Name)
	label.ZIndex = 2
	label.Parent = billboard
	local shadow = Instance.new("TextLabel")
	shadow.Name = "NameShadow"
	shadow.BackgroundTransparency = 1
	shadow.Size = UDim2.fromScale(1, 1)
	shadow.Position = UDim2.fromOffset(0, 2)
	shadow.Font = label.Font
	shadow.TextScaled = true
	shadow.TextColor3 = Color3.fromRGB(25, 31, 39)
	shadow.TextTransparency = 0.45
	shadow.TextStrokeTransparency = 1
	shadow.Text = label.Text
	shadow.ZIndex = 1
	shadow.Parent = billboard

	if mutation.Name == "Rainbow" then
		local sparkle = Instance.new("Sparkles")
		sparkle.Name = "RainbowSparkle"
		sparkle.SparkleColor = mutation.Color
		sparkle.Parent = body
	end
	model.PrimaryPart = body
	return model
end

return CharacterFactory
