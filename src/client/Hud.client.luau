local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local data = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotData"))
local events = ReplicatedStorage:WaitForChild("TsunamiEvents")
local world = workspace:WaitForChild("TsunamiIsland")
local stats = player:WaitForChild("leaderstats")
local cash = stats:WaitForChild("Cash")
local income = stats:WaitForChild("$/s")

local mint = Color3.fromRGB(125, 255, 205)
local white = Color3.fromRGB(248, 251, 255)
local navy = Color3.fromRGB(16, 33, 50)
local muted = Color3.fromRGB(177, 199, 218)

local gui = Instance.new("ScreenGui")
gui.Name = "TsunamiHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function panel(parent, size, position, anchor)
	local frame = Instance.new("Frame")
	frame.Size = size
	frame.Position = position
	frame.AnchorPoint = anchor or Vector2.zero
	frame.BackgroundColor3 = navy
	frame.BackgroundTransparency = 0.09
	frame.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(116, 175, 198)
	stroke.Transparency = 0.65
	stroke.Parent = frame
	return frame
end

local function label(parent, size, position, textSize, color, font)
	local text = Instance.new("TextLabel")
	text.Size = size
	text.Position = position
	text.BackgroundTransparency = 1
	text.TextColor3 = color
	text.Font = font or Enum.Font.GothamBold
	text.TextSize = textSize
	text.Parent = parent
	return text
end

local header = panel(gui, UDim2.new(0.86, 0, 0, 122), UDim2.new(0.5, 0, 0, 9), Vector2.new(0.5, 0))
local maxWidth = Instance.new("UISizeConstraint")
maxWidth.MaxSize = Vector2.new(420, 122)
maxWidth.Parent = header
local cashText = label(header, UDim2.new(1, 0, 0, 44), UDim2.fromOffset(0, 3), 38, mint, Enum.Font.GothamBlack)
local metrics = label(header, UDim2.new(1, 0, 0, 23), UDim2.fromOffset(0, 45), 14, white)
local waveText = label(header, UDim2.new(1, 0, 0, 24), UDim2.fromOffset(0, 75), 16, white)
local track = panel(header, UDim2.new(1, -24, 0, 6), UDim2.fromOffset(12, 105))
track.BackgroundColor3 = Color3.fromRGB(49, 70, 91)
local fill = Instance.new("Frame")
fill.BorderSizePixel = 0
fill.Parent = track
local rounding = Instance.new("UICorner")
rounding.CornerRadius = UDim.new(1, 0)
rounding.Parent = fill

local feedback = label(gui, UDim2.new(0.95, 0, 0, 52), UDim2.new(0.5, 0, 0.78, 0), 19, white)
feedback.AnchorPoint = Vector2.new(0.5, 0)
feedback.TextStrokeTransparency = 0.25
feedback.TextWrapped = true
feedback.Text = ""
local feedbackVersion = 0
events.Feedback.OnClientEvent:Connect(function(message)
	feedbackVersion += 1
	local version = feedbackVersion
	feedback.Text = message
	task.delay(3, function()
		if feedbackVersion == version then feedback.Text = "" end
	end)
end)

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.fromOffset(144, 40)
toggle.Position = UDim2.new(1, -12, 0, 142)
toggle.AnchorPoint = Vector2.new(1, 0)
toggle.BackgroundColor3 = navy
toggle.TextColor3 = mint
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 15
toggle.Parent = gui
local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 10)
toggleCorner.Parent = toggle

local index = panel(gui, UDim2.new(0, 246, 1, -205), UDim2.new(1, -12, 0, 189), Vector2.new(1, 0))
local indexSize = Instance.new("UISizeConstraint")
indexSize.MaxSize = Vector2.new(246, 272)
indexSize.Parent = index
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.fromScale(1, 1)
scroll.CanvasSize = UDim2.fromOffset(0, 24 + #data.Cast * 20)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = mint
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.Parent = index
index.Visible = false
toggle.Activated:Connect(function() index.Visible = not index.Visible end)
local entries = {}
for number in ipairs(data.Cast) do
	local entry = label(scroll, UDim2.new(1, -24, 0, 19), UDim2.fromOffset(12, 12 + (number - 1) * 20), 13, muted)
	entry.TextXAlignment = Enum.TextXAlignment.Left
	entries[number] = entry
end

-- Refresh the checklist from the ownership attributes replicated by the server.
local function updateCollection()
	local owned = 0
	for number, definition in ipairs(data.Cast) do
		local unlocked = player:GetAttribute("Owned_" .. number)
		owned += unlocked and 1 or 0
		entries[number].Text = (unlocked and "✓  " or "○  ") .. definition.name
		entries[number].TextColor3 = unlocked and data.Rarities[definition.rarity].color or muted
	end
	toggle.Text = ("Collection  %d / %d"):format(owned, #data.Cast)
end
for number in ipairs(data.Cast) do
	player:GetAttributeChangedSignal("Owned_" .. number):Connect(updateCollection)
end
updateCollection()

local function money(amount)
	if amount == math.floor(amount) then return string.format("%d", amount) end
	return (string.format("%.2f", amount):gsub("0$", ""))
end

local function updateMoney()
	cashText.Text = "$" .. money(cash.Value)
	metrics.Text = ("$%s/s   ·   %.1fx income   ·   Speed %d/%d"):format(
		money(income.Value), player:GetAttribute("Multiplier") or 1,
		player:GetAttribute("SpeedTier") or 0, data.SpeedShop.SpeedMaxTier
	)
end
cash.Changed:Connect(updateMoney)
income.Changed:Connect(updateMoney)
player:GetAttributeChangedSignal("Multiplier"):Connect(updateMoney)
player:GetAttributeChangedSignal("SpeedTier"):Connect(updateMoney)
updateMoney()

local phaseStyles = {
	CALM = {title = "CALM", color = mint, duration = data.Wave.CalmSeconds},
	WARNING = {title = "TSUNAMI INCOMING", color = Color3.fromRGB(255, 143, 105), duration = data.Wave.WarningSeconds},
	WAVE = {title = "WAVE CROSSING", color = Color3.fromRGB(126, 213, 255), duration = data.Wave.WaveCrossSeconds},
}
-- Cache the status text while the progress fill updates each frame.
local displayedStatus
RunService.RenderStepped:Connect(function()
	local style = phaseStyles[world:GetAttribute("WavePhase")] or phaseStyles.CALM
	local endsAt = world:GetAttribute("WaveEndsAt") or workspace:GetServerTimeNow()
	local remaining = math.max(0, endsAt - workspace:GetServerTimeNow())
	local status = ("%s  ·  %ds  ·  %d studs"):format(style.title, math.ceil(remaining), world:GetAttribute("WaveHeight") or 0)
	if status ~= displayedStatus then
		displayedStatus = status
		waveText.Text = status
		waveText.TextColor3 = style.color
		fill.BackgroundColor3 = style.color
	end
	fill.Size = UDim2.fromScale(math.clamp(remaining / style.duration, 0, 1), 1)
end)
