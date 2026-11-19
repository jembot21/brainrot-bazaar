local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Data = require(ReplicatedStorage.Shared.BrainrotData)

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("BrainrotRemotes")
local gui = Instance.new("ScreenGui")
gui.Name = "IslandHud"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local function label(name, size, position, text, color)
	local item = Instance.new("TextLabel")
	item.Name = name
	item.Size = size
	item.Position = position
	item.BackgroundColor3 = Color3.fromRGB(23, 39, 52)
	item.BackgroundTransparency = 0.13
	item.BorderSizePixel = 0
	item.Font = Enum.Font.GothamBold
	item.TextColor3 = color or Color3.new(1, 1, 1)
	item.TextScaled = true
	item.Text = text
	item.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = item
	return item
end

local cashLabel = label("Cash", UDim2.fromOffset(220, 46), UDim2.fromOffset(18, 18), "Cash: $150", Color3.fromRGB(255, 230, 129))
local waveLabel = label("Wave", UDim2.new(0.48, 0, 0, 48), UDim2.new(0.26, 0, 0, 18), "CALM", Color3.fromRGB(185, 242, 255))
local statsLabel = label("Stats", UDim2.fromOffset(220, 40), UDim2.fromOffset(18, 72), "Speed 0/10 · Rebirths 0", Color3.fromRGB(205, 229, 239))
local toastLabel = label("Toast", UDim2.new(0.5, 0, 0, 48), UDim2.new(0.25, 0, 0.78, 0), "Collect, place, and get to high ground!", Color3.fromRGB(255, 239, 180))
toastLabel.Visible = true

local function button(name, position, text, color)
	local item = Instance.new("TextButton")
	item.Name = name
	item.Size = UDim2.fromOffset(205, 54)
	item.Position = position
	item.BackgroundColor3 = color
	item.BorderSizePixel = 0
	item.Font = Enum.Font.GothamBold
	item.TextColor3 = Color3.new(1, 1, 1)
	item.TextScaled = true
	item.Text = text
	item.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = item
	return item
end

local speedButton = button("SpeedShop", UDim2.new(1, -223, 1, -132), "Speed +2", Color3.fromRGB(63, 144, 205))
local rebirthButton = button("Rebirth", UDim2.new(1, -223, 1, -68), "Rebirth $25,000", Color3.fromRGB(141, 86, 190))
local state = { Cash = Data.StartCash, Speed = 0, Rebirths = 0 }

local function update()
	cashLabel.Text = "Cash: $" .. tostring(state.Cash)
	local nextTier = state.Speed + 1
	statsLabel.Text = "Speed " .. state.Speed .. "/10 · Rebirths " .. state.Rebirths
	if state.Speed >= Data.SpeedTiers then
		speedButton.Text = "MAX SPEED"
	else
		speedButton.Text = "+2 Speed · $" .. Data.SpeedCost(nextTier)
	end
	rebirthButton.Text = state.Cash >= Data.RebirthCost and "REBIRTH · $25,000" or "Rebirth · $25,000"
end

speedButton.Activated:Connect(function()
	remotes.BuySpeed:FireServer()
end)
rebirthButton.Activated:Connect(function()
	remotes.Rebirth:FireServer()
end)

remotes.CashChanged.OnClientEvent:Connect(function(cash, rebirths, speed)
	state.Cash = cash
	state.Rebirths = rebirths
	state.Speed = speed
	update()
end)

local toastToken = 0
remotes.Toast.OnClientEvent:Connect(function(message)
	toastToken += 1
	local token = toastToken
	toastLabel.Text = tostring(message)
	toastLabel.Visible = true
	task.delay(3.5, function()
		if token == toastToken then toastLabel.Visible = false end
	end)
end)

local wavePhase = "CALM"
local waveEnd = 0
local waveHeight = 6
remotes.WaveStatus.OnClientEvent:Connect(function(phase, duration, height)
	wavePhase = phase
	waveEnd = os.clock() + duration
	waveHeight = height
	if phase == "WARNING" then
		waveLabel.Text = "TSUNAMI WARNING! GET TO HIGH GROUND"
		waveLabel.BackgroundColor3 = Color3.fromRGB(186, 65, 71)
	elseif phase == "SWEEP" then
		waveLabel.BackgroundColor3 = Color3.fromRGB(31, 112, 157)
	else
		waveLabel.BackgroundColor3 = Color3.fromRGB(23, 39, 52)
	end
end)

RunService.RenderStepped:Connect(function()
	local remaining = math.max(0, math.ceil(waveEnd - os.clock()))
	if wavePhase == "WARNING" then
		waveLabel.Text = "TSUNAMI WARNING · " .. remaining .. "s · HIGH GROUND!"
	elseif wavePhase == "SWEEP" then
		waveLabel.Text = "WAVE SWEEP · " .. remaining .. "s · " .. waveHeight .. " STUDS"
	else
		waveLabel.Text = "CALM · NEXT WAVE IN " .. remaining .. "s"
	end
end)

update()
