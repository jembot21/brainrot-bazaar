local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("BazaarRemotes")
local feedbackEvent = remotes:WaitForChild("Feedback")
local waveEvent = remotes:WaitForChild("WaveWarning")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local data = require(Shared:WaitForChild("BrainrotData"))

local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "BazaarHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local function label(parent, size, pos, text, color, textSize, font, xAlign)
	local lbl = Instance.new("TextLabel")
	lbl.Size = size
	lbl.Position = pos
	lbl.Text = text or ""
	lbl.TextColor3 = color or Color3.new(1, 1, 1)
	lbl.TextSize = textSize or 16
	lbl.Font = font or Enum.Font.GothamBold
	lbl.TextXAlignment = xAlign or Enum.TextXAlignment.Center
	lbl.BackgroundTransparency = 1
	lbl.BorderSizePixel = 0

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(25, 33, 40)
	stroke.Transparency = 0.25
	stroke.Parent = lbl

	lbl.Parent = parent
	return lbl
end

-- Wallet frame
local wallet = Instance.new("Frame")
wallet.Name = "Wallet"
wallet.AnchorPoint = Vector2.new(0.5, 0)
wallet.Position = UDim2.new(0.5, 0, 0, 18)
wallet.Size = UDim2.fromOffset(390, 84)
wallet.BackgroundColor3 = Color3.fromRGB(30, 43, 51)
wallet.BackgroundTransparency = 0.08
wallet.BorderSizePixel = 0
local walletCorner = Instance.new("UICorner")
walletCorner.CornerRadius = UDim.new(0, 8)
walletCorner.Parent = wallet
wallet.Parent = gui

local cashLabel = label(wallet, UDim2.new(1, 0, 0, 44), UDim2.new(0, 0, 0, 2), "$150", Color3.fromRGB(255, 223, 99), 34)
local detailsLabel = label(wallet, UDim2.new(1, 0, 0, 28), UDim2.new(0, 0, 0, 48), "$0 / sec     x1.0 income", Color3.fromRGB(192, 235, 218), 18)

-- WaveWarning banner
local waveLabel = Instance.new("TextLabel")
waveLabel.Name = "WaveWarning"
waveLabel.Size = UDim2.new(0.7, 0, 0, 55)
waveLabel.Position = UDim2.new(0.15, 0, 0, 112)
waveLabel.BackgroundColor3 = Color3.fromRGB(195, 57, 60)
waveLabel.BackgroundTransparency = 0.12
waveLabel.TextColor3 = Color3.fromRGB(255, 247, 219)
waveLabel.TextSize = 30
waveLabel.Font = Enum.Font.GothamBold
waveLabel.Text = ""
waveLabel.Visible = false
local waveCorner = Instance.new("UICorner")
waveCorner.CornerRadius = UDim.new(0, 8)
waveCorner.Parent = waveLabel
local waveStroke = Instance.new("UIStroke")
waveStroke.Color = Color3.fromRGB(25, 33, 40)
waveStroke.Transparency = 0.25
waveStroke.Parent = waveLabel
waveLabel.Parent = gui

-- Feedback banner
local feedbackLabel = Instance.new("TextLabel")
feedbackLabel.Name = "Feedback"
feedbackLabel.Size = UDim2.new(0.7, 0, 0, 44)
feedbackLabel.Position = UDim2.new(0.15, 0, 0.82, 0)
feedbackLabel.BackgroundColor3 = Color3.fromRGB(30, 43, 51)
feedbackLabel.BackgroundTransparency = 0.1
feedbackLabel.TextColor3 = Color3.new(1, 1, 1)
feedbackLabel.TextSize = 23
feedbackLabel.Font = Enum.Font.GothamBold
feedbackLabel.Text = ""
feedbackLabel.Visible = false
local feedCorner = Instance.new("UICorner")
feedCorner.CornerRadius = UDim.new(0, 8)
feedCorner.Parent = feedbackLabel
local feedStroke = Instance.new("UIStroke")
feedStroke.Color = Color3.fromRGB(25, 33, 40)
feedStroke.Transparency = 0.25
feedStroke.Parent = feedbackLabel
feedbackLabel.Parent = gui

-- CollectionIndex frame
local collectionIndex = Instance.new("Frame")
collectionIndex.Name = "CollectionIndex"
collectionIndex.AnchorPoint = Vector2.new(1, 0.5)
collectionIndex.Position = UDim2.new(1, -20, 0.5, 0)
collectionIndex.Size = UDim2.fromOffset(270, 390)
collectionIndex.BackgroundColor3 = Color3.fromRGB(34, 48, 58)
collectionIndex.BackgroundTransparency = 0.08
collectionIndex.BorderSizePixel = 0
local colCorner = Instance.new("UICorner")
colCorner.CornerRadius = UDim.new(0, 8)
colCorner.Parent = collectionIndex
collectionIndex.Parent = gui

local titleLabel = label(collectionIndex, UDim2.new(1, -16, 0, 38), UDim2.new(0, 8, 0, 8), "BAZAAR INDEX  0/12", Color3.fromRGB(255, 229, 150), 20)

local entriesFrame = Instance.new("Frame")
entriesFrame.Name = "Entries"
entriesFrame.Position = UDim2.new(0, 10, 0, 52)
entriesFrame.Size = UDim2.new(1, -20, 1, -62)
entriesFrame.BackgroundTransparency = 1
entriesFrame.Parent = collectionIndex

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 2)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = entriesFrame

local owned = {}
local castRows = {}

for idx, castMember in data.Cast do
	local row = label(
		entriesFrame,
		UDim2.new(1, 0, 0, 24),
		UDim2.new(0, 0, 0, 0),
		"-  " .. castMember.name,
		Color3.fromRGB(207, 215, 219),
		15,
		Enum.Font.GothamMedium,
		Enum.TextXAlignment.Left
	)
	row.LayoutOrder = idx
	castRows[castMember.name] = row
end

local function update()
	local cashVal = player:GetAttribute("Cash") or 150
	local incomeVal = player:GetAttribute("Income") or 0
	local multVal = player:GetAttribute("Multiplier") or 1

	cashLabel.Text = "$" .. cashVal
	detailsLabel.Text = "$" .. incomeVal .. " / sec     x" .. string.format("%.1f", multVal) .. " income"

	local count = 0
	for _, item in data.Cast do
		local row = castRows[item.name]
		if row then
			if owned[item.name] then
				count += 1
				row.Text = "✓  " .. item.name
				row.TextColor3 = Color3.fromRGB(112, 235, 164)
			else
				row.Text = "-  " .. item.name
				row.TextColor3 = Color3.fromRGB(207, 215, 219)
			end
		end
	end

	titleLabel.Text = "BAZAAR INDEX  " .. count .. "/12"
end

player:GetAttributeChangedSignal("Cash"):Connect(update)
player:GetAttributeChangedSignal("Income"):Connect(update)
player:GetAttributeChangedSignal("Multiplier"):Connect(update)

feedbackEvent.OnClientEvent:Connect(function(kind, text)
	if kind == "owned" then
		owned[text] = true
		update()
	elseif kind == "message" then
		feedbackLabel.Text = tostring(text)
		feedbackLabel.Visible = true
		task.delay(3.5, function()
			if feedbackLabel.Text == tostring(text) then
				feedbackLabel.Visible = false
			end
		end)
	end
end)

waveEvent.OnClientEvent:Connect(function(text)
	waveLabel.Text = text or ""
	local active = (text ~= nil and text ~= "")
	waveLabel.Visible = active
	if active then
		task.spawn(function()
			for _ = 1, 3 do
				waveLabel.BackgroundTransparency = 0.35
				task.wait(0.15)
				waveLabel.BackgroundTransparency = 0.12
				task.wait(0.15)
			end
		end)
	end
end)

update()
