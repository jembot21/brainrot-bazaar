local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local events = ReplicatedStorage:WaitForChild("TsunamiEvents")
local world = workspace:WaitForChild("TsunamiIsland")
local gui = Instance.new("ScreenGui")
gui.Name = "TsunamiEffects"
gui.IgnoreGuiInset = true
gui.DisplayOrder = 5
gui.ResetOnSpawn = false
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local tint = Instance.new("ColorCorrectionEffect")
tint.Name = "TsunamiTint"
tint.Parent = Lighting

local function tween(instance, duration, properties)
	local animation = TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
	animation:Play()
	return animation
end

local function banner(title, color, y, hold, height)
	local text = Instance.new("TextLabel")
	text.AnchorPoint = Vector2.new(0.5, 0.5)
	text.Position = UDim2.fromScale(0.5, y + 0.07)
	text.Size = UDim2.new(0.9, 0, 0, height)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamBlack
	text.Text = title
	text.TextColor3 = color
	text.TextScaled = true
	text.TextStrokeTransparency = 0.15
	text.Parent = gui
	local size = Instance.new("UITextSizeConstraint")
	size.MaxTextSize = 46
	size.Parent = text
	tween(text, 0.28, {Position = UDim2.fromScale(0.5, y)})
	task.delay(hold, function()
		tween(text, 0.35, {TextTransparency = 1, TextStrokeTransparency = 1}).Completed:Wait()
		text:Destroy()
	end)
end

local lastPhase
local function warning(title, duration, height)
	if lastPhase == "WARNING" then return end
	lastPhase = "WARNING"
	tween(tint, 0.8, {TintColor = Color3.fromRGB(255, 139, 114), Saturation = -0.1})
	banner(("%s\n%ds  ·  %d studs"):format(title, duration, height), Color3.fromRGB(255, 155, 101), 0.34, 2.5, 84)
end

local function impact(duration)
	if lastPhase == "WAVE" then return end
	lastPhase = "WAVE"
	tween(tint, 0.2, {TintColor = Color3.fromRGB(114, 206, 255), Saturation = 0.12})
	local rumble = TweenService:Create(tint, TweenInfo.new(0.28, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Contrast = 0.16})
	rumble:Play()
	task.delay(duration, function()
		rumble:Cancel()
		lastPhase = nil
		tween(tint, 0.65, {TintColor = Color3.new(1, 1, 1), Saturation = 0, Contrast = 0})
	end)
	local wash = Instance.new("Frame")
	wash.Size = UDim2.fromScale(1, 1)
	wash.BackgroundColor3 = Color3.fromRGB(51, 176, 255)
	wash.BackgroundTransparency = 0.74
	wash.BorderSizePixel = 0
	wash.Parent = gui
	tween(wash, 0.75, {BackgroundTransparency = 1}).Completed:Once(function() wash:Destroy() end)
end

events.Warning.OnClientEvent:Connect(warning)
events.Impact.OnClientEvent:Connect(impact)

-- The world clock also covers players whose client loaded after the phase event.
local function syncPhase()
	local remaining = (world:GetAttribute("WaveEndsAt") or 0) - workspace:GetServerTimeNow()
	if remaining <= 0 then return end
	local phase = world:GetAttribute("WavePhase")
	if phase == "WARNING" then
		warning("TSUNAMI INCOMING", math.ceil(remaining), world:GetAttribute("WaveHeight") or 0)
	elseif phase == "WAVE" then
		impact(remaining)
	end
end
world:GetAttributeChangedSignal("WavePhase"):Connect(syncPhase)
syncPhase()
events.Fusion.OnClientEvent:Connect(function(species, mutation)
	local name = mutation == "" and species or mutation .. " " .. species
	banner("FUSION!\n" .. name, Color3.fromRGB(241, 184, 255), 0.48, 2.1, 88)
end)
events.Income.OnClientEvent:Connect(function(amount)
	banner(("+$%g"):format(amount), Color3.fromRGB(113, 255, 182), 0.225, 0.38, 24)
end)

-- Ambient particles live on this client and use their own render connection.
pcall(function()
	local RunService = game:GetService("RunService")
	local motes = {}
	local origins = {
		Vector3.new(-82, 4, 39), Vector3.new(-79, 7, 51), Vector3.new(-80, 4, -61),
		Vector3.new(-24, 5, -53), Vector3.new(12, 3, -69), Vector3.new(25, 3, 70),
		Vector3.new(40, 5, -31), Vector3.new(48, 6, 30),
	}
	local folder = Instance.new("Folder")
	folder.Name = "IslandMotes"
	for index, origin in ipairs(origins) do
		local mote = Instance.new("Part")
		mote.Name = "Sparkle"
		mote.Shape = Enum.PartType.Ball
		mote.Size = Vector3.new(0.18, 0.18, 0.18)
		mote.Material = Enum.Material.Neon
		mote.Color = Color3.fromRGB(255, 235, 178)
		mote.Transparency = 0.5
		mote.Anchored = true
		mote.CanCollide = false
		mote.CanTouch = false
		mote.CanQuery = false
		mote.CastShadow = false
		mote.Position = origin
		mote.Parent = folder
		motes[index] = mote
	end
	folder.Parent = world

	-- Stable origins keep the motes near their scenery as they drift.
	local elapsed = 0
	RunService.RenderStepped:Connect(function(dt)
		elapsed += dt
		for index, mote in ipairs(motes) do
			local phase = elapsed * 0.48 + index * 1.7
			mote.Position = origins[index] + Vector3.new(math.cos(phase) * 1.6, math.sin(phase) * 0.7, math.sin(phase) * 1.1)
			mote.Transparency = 0.55 + math.sin(phase + index) * 0.2
		end
	end)
end)
