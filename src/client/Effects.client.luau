local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local player = Players.LocalPlayer
local event = game.ReplicatedStorage:WaitForChild("IslandNetwork"):WaitForChild("Event")

local gui = Instance.new("ScreenGui")
gui.Name = "TsunamiEffects"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 5
gui.Parent = player:WaitForChild("PlayerGui")

local borders = {}
for _, box in ipairs({
    { 0, 0, 1, 0.07 },
    { 0, 0.93, 1, 0.07 },
    { 0, 0, 0.045, 1 },
    { 0.955, 0, 0.045, 1 },
}) do
    local frame = Instance.new("Frame")
    frame.BorderSizePixel = 0
    frame.Position = UDim2.fromScale(box[1], box[2])
    frame.Size = UDim2.fromScale(box[3], box[4])
    frame.BackgroundColor3 = Color3.fromRGB(246, 62, 79)
    frame.BackgroundTransparency = 1
    frame.Parent = gui
    table.insert(borders, frame)
end

local warning = false
local shakeUntil = 0
local shakeStrength = 0
RunService:BindToRenderStep("IslandWaveEffects", Enum.RenderPriority.Camera.Value + 1, function()
    local currentTime = os.clock()
    for _, edge in ipairs(borders) do
        edge.BackgroundTransparency = warning and (0.72 + math.sin(currentTime * 7) * 0.13) or 1
    end

    local view = workspace.CurrentCamera
    if view and currentTime < shakeUntil then
        local amplitude = math.min(shakeUntil - currentTime, 1) * shakeStrength
        view.CFrame *= CFrame.new(
            math.noise(currentTime * 29, 0) * amplitude,
            math.noise(0, currentTime * 31) * amplitude,
            0
        )
    end
end)

local function burst(position, color, count)
    local origin = Instance.new("Part")
    origin.Name = "LocalSplash"
    origin.Size = Vector3.one
    origin.Position = position
    origin.Anchored = true
    origin.CanCollide = false
    origin.CanTouch = false
    origin.CanQuery = false
    origin.Transparency = 1
    origin.Parent = workspace

    local particles = Instance.new("ParticleEmitter")
    particles.Color = ColorSequence.new(color)
    particles.Rate = 0
    particles.Lifetime = NumberRange.new(0.4, 0.9)
    particles.Speed = NumberRange.new(6, 15)
    particles.SpreadAngle = Vector2.new(150, 150)
    particles.Acceleration = Vector3.new(0, -18, 0)
    particles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 0),
    })
    particles.Parent = origin
    particles:Emit(count)
    Debris:AddItem(origin, 2)
end

event.OnClientEvent:Connect(function(kind, data)
    if kind == "Warning" then
        warning = true
    elseif kind == "Wave" then
        warning = data.Phase ~= "CALM"
    elseif kind == "Shake" then
        shakeUntil = os.clock() + (data.Duration or 1)
        shakeStrength = data.Strength or 0.3
    elseif kind == "Caught" then
        burst(data, Color3.fromRGB(153, 233, 255), 60)
        shakeUntil = os.clock() + 0.8
        shakeStrength = 0.6
    elseif kind == "Purchase" then
        local pivot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if pivot then
            burst(pivot.Position + Vector3.new(0, 2, 0), Color3.fromRGB(255, 227, 112), 30)
        end
    end
end)

local function mutationEffect(object)
    if not object:IsA("Model") then
        return
    end

    local variant = object:GetAttribute("Mutation")
    if variant ~= "Gold" and variant ~= "Diamond" then
        return
    end
    local torso = object:FindFirstChild("Body")
    if torso and not torso:FindFirstChild("MutationShimmer") then
        local shimmer = Instance.new("Sparkles")
        shimmer.Name = "MutationShimmer"
        shimmer.SparkleColor = variant == "Gold" and Color3.fromRGB(255, 217, 78) or Color3.fromRGB(143, 236, 255)
        shimmer.Parent = torso
    end
end

workspace.DescendantAdded:Connect(mutationEffect)
for _, object in ipairs(workspace:GetDescendants()) do
    mutationEffect(object)
end

-- Keep TweenService available for later screen transitions; these visuals run only here.
gui.Destroying:Connect(function()
    RunService:UnbindFromRenderStep("IslandWaveEffects")
end)
