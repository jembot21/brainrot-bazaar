local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("BrainrotRemotes")
local gui = Instance.new("ScreenGui")
gui.Name = "IslandEffects"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 10
gui.Parent = player:WaitForChild("PlayerGui")

local edges = {}
for _, spec in ipairs({
	{ Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, 0) },
	{ Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 1, -16) },
	{ Size = UDim2.new(0, 16, 1, 0), Position = UDim2.new(0, 0, 0, 0) },
	{ Size = UDim2.new(0, 16, 1, 0), Position = UDim2.new(1, -16, 0, 0) },
}) do
	local edge = Instance.new("Frame")
	edge.Size = spec.Size
	edge.Position = spec.Position
	edge.BorderSizePixel = 0
	edge.BackgroundColor3 = Color3.fromRGB(238, 71, 74)
	edge.BackgroundTransparency = 1
	edge.Parent = gui
	table.insert(edges, edge)
end

local warningToken = 0
remotes.WaveWarning.OnClientEvent:Connect(function()
	warningToken += 1
	local token = warningToken
	task.spawn(function()
		local finish = os.clock() + 10
		while os.clock() < finish and token == warningToken do
			for _, edge in ipairs(edges) do
				TweenService:Create(edge, TweenInfo.new(0.35), { BackgroundTransparency = 0.2 }):Play()
			end
			task.wait(0.4)
			for _, edge in ipairs(edges) do
				TweenService:Create(edge, TweenInfo.new(0.45), { BackgroundTransparency = 0.82 }):Play()
			end
			task.wait(0.5)
		end
		for _, edge in ipairs(edges) do
			TweenService:Create(edge, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
		end
	end)
end)

local function bead(position, color, direction, scale)
	local drop = Instance.new("Part")
	drop.Name = "SplashBead"
	drop.Shape = Enum.PartType.Ball
	drop.Size = Vector3.new(scale, scale, scale)
	drop.Position = position
	drop.Color = color
	drop.Material = Enum.Material.Neon
	drop.Anchored = true
	drop.CanCollide = false
	drop.Parent = workspace
	local tween = TweenService:Create(drop, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = position + direction,
		Transparency = 1,
		Size = Vector3.new(0.08, 0.08, 0.08),
	})
	tween:Play()
	tween.Completed:Connect(function() drop:Destroy() end)
end

remotes.Caught.OnClientEvent:Connect(function(loss)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root then
		for index = 1, 18 do
			local angle = index / 18 * math.pi * 2
			bead(root.Position, Color3.fromRGB(62, 195, 228), Vector3.new(math.cos(angle) * 5, math.random() * 4 + 1, math.sin(angle) * 5), math.random(3, 7) / 10)
		end
	end
	local message = Instance.new("TextLabel")
	message.Name = "CaughtMessage"
	message.AnchorPoint = Vector2.new(0.5, 0.5)
	message.Position = UDim2.fromScale(0.5, 0.43)
	message.Size = UDim2.fromOffset(480, 76)
	message.BackgroundTransparency = 1
	message.Font = Enum.Font.GothamBlack
	message.TextColor3 = Color3.fromRGB(255, 230, 236)
	message.TextStrokeTransparency = 0.25
	message.TextScaled = true
	message.Text = "CAUGHT! Lost carried brainrot + $" .. tostring(loss)
	message.Parent = gui
	TweenService:Create(message, TweenInfo.new(1.8), { TextTransparency = 1, TextStrokeTransparency = 1, Position = UDim2.fromScale(0.5, 0.34) }):Play()
	task.delay(2, function() message:Destroy() end)
end)

remotes.PurchaseSparkle.OnClientEvent:Connect(function(position)
	for index = 1, 14 do
		local angle = index / 14 * math.pi * 2
		local color = Color3.fromHSV(index / 14, 0.65, 1)
		bead(position + Vector3.new(0, 1.3, 0), color, Vector3.new(math.cos(angle) * 2.8, math.random(2, 5), math.sin(angle) * 2.8), 0.26)
	end
end)

remotes.CameraShake.OnClientEvent:Connect(function(duration, magnitude)
	local camera = workspace.CurrentCamera
	if not camera then return end
	local started = os.clock()
	local connection
	local base = camera.CFrame
	connection = game:GetService("RunService").RenderStepped:Connect(function()
		local elapsed = os.clock() - started
		if elapsed >= duration then
			camera.CFrame = base
			connection:Disconnect()
			return
		end
		local falloff = 1 - elapsed / duration
		local offset = Vector3.new(math.random() - 0.5, math.random() - 0.5, 0) * magnitude * falloff
		camera.CFrame = base * CFrame.new(offset)
	end)
end)

local function addMutationSparkle(instance)
	if not instance:IsA("BasePart") then return end
	local model = instance:FindFirstAncestorOfClass("Model")
	if not model or model:GetAttribute("Mutation") ~= "Rainbow" or not model.PrimaryPart then return end
	if model.PrimaryPart:FindFirstChild("ClientMutationSparkle") then return end
	local sparkles = Instance.new("Sparkles")
	sparkles.Name = "ClientMutationSparkle"
	sparkles.SparkleColor = Color3.fromRGB(255, 137, 232)
	sparkles.Parent = model.PrimaryPart
end

for _, instance in ipairs(CollectionService:GetTagged("BrainrotCharacter")) do
	addMutationSparkle(instance)
end
CollectionService:GetInstanceAddedSignal("BrainrotCharacter"):Connect(function(instance)
	task.defer(addMutationSparkle, instance)
end)
