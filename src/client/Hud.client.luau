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

local function label(parent, text, size, pos, textColor, textSize, font, align)
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Text = text or ""
	lbl.Size = size or UDim2.fromScale(1, 1)
	lbl.Position = pos or UDim2.new(0, 0, 0, 0)
	lbl.TextColor3 = textColor or Color3.new(1, 1, 1)
	lbl.TextSize = textSize or 18
	lbl.Font = font or Enum.Font.GothamBold
	lbl.TextXAlignment = align or Enum.TextXAlignment.Center

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

local cashLabel = label(wallet, "$150", UDim2.new(1, 0, 0, 44), UDim2.new(0, 0, 0, 2), Color3.fromRGB(255, 223, 99), 34)
local detailsLabel = label(wallet, "$0 / sec     x1.0 income", UDim2.new(1, 0, 0, 28), UDim2.new(0, 0, 0, 48), Color3.fromRGB(192, 235, 218), 18)

-- WaveWarning banner
local waveBanner = label(gui, "", UDim2.new(0.7, 0, 0, 55), UDim2.new(0.15, 0, 0, 112), Color3.fromRGB(255, 247, 219), 30)
waveBanner.BackgroundColor3 = Color3.fromRGB(195, 57, 60)
waveBanner.BackgroundTransparency = 0.12
waveBanner.Visible = false

-- Feedback banner
local feedbackBanner = label(gui, "", UDim2.new(0.7, 0, 0, 44), UDim2.new(0.15, 0, 0.82, 0), Color3.new(1, 1, 1), 23)
feedbackBanner.BackgroundColor3 = Color3.fromRGB(30, 43, 51)
feedbackBanner.BackgroundTransparency = 0.1
feedbackBanner.Visible = false

-- CollectionIndex frame
local collectionIndex = Instance.new("Frame")
collectionIndex.Name = "CollectionIndex"
collectionIndex.AnchorPoint = Vector2.new(1, 0.5)
collectionIndex.Position = UDim2.new(1, -20, 0.5, 0)
collectionIndex.Size = UDim2.fromOffset(270, 390)
collectionIndex.BackgroundColor3 = Color3.fromRGB(34, 48, 58)
collectionIndex.BackgroundTransparency = 0.08
collectionIndex.BorderSizePixel = 0

local indexCorner = Instance.new("UICorner")
indexCorner.CornerRadius = UDim.new(0, 8)
indexCorner.Parent = collectionIndex
collectionIndex.Parent = gui

local titleLabel = label(
	collectionIndex,
	"BAZAAR INDEX  0/12",
	UDim2.new(1, -16, 0, 38),
	UDim2.new(0, 8, 0, 8),
	Color3.fromRGB(255, 229, 150),
	20
)

local entriesFrame = Instance.new("Frame")
entriesFrame.BackgroundTransparency = 1
entriesFrame.Position = UDim2.new(0, 10, 0, 52)
entriesFrame.Size = UDim2.new(1, -20, 1, -62)
entriesFrame.Parent = collectionIndex

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 2)
listLayout.Parent = entriesFrame

local castRows = {}
local owned = {}

for _, member in ipairs(data.Cast) do
	local row = label(
		entriesFrame,
		"-  " .. member.name,
		UDim2.new(1, 0, 0, 24),
		UDim2.new(0, 0, 0, 0),
		Color3.fromRGB(207, 215, 219),
		15,
		Enum.Font.GothamMedium,
		Enum.TextXAlignment.Left
	)
	castRows[member.name] = row
end

local function update()
	local cash = player:GetAttribute("Cash") or 150
	local income = player:GetAttribute("Income") or 0
	local mult = player:GetAttribute("Multiplier") or 1

	cashLabel.Text = "$" .. cash
	detailsLabel.Text = "$" .. income .. " / sec     x" .. string.format("%.1f", mult) .. " income"

	local ownedCount = 0
	for _, member in ipairs(data.Cast) do
		local row = castRows[member.name]
		if row then
			if owned[member.name] then
				ownedCount += 1
				row.Text = "✓  " .. member.name
				row.TextColor3 = Color3.fromRGB(112, 235, 164)
			else
				row.Text = "-  " .. member.name
				row.TextColor3 = Color3.fromRGB(207, 215, 219)
			end
		end
	end

	titleLabel.Text = "BAZAAR INDEX  " .. ownedCount .. "/12"
end

player:GetAttributeChangedSignal("Cash"):Connect(update)
player:GetAttributeChangedSignal("Income"):Connect(update)
player:GetAttributeChangedSignal("Multiplier"):Connect(update)

feedbackEvent.OnClientEvent:Connect(function(kind, text)
	if kind == "owned" then
		owned[text] = true
		update()
	elseif kind == "message" then
		feedbackBanner.Text = text
		feedbackBanner.Visible = true
		task.delay(3.5, function()
			if feedbackBanner.Text == text then
				feedbackBanner.Visible = false
			end
		end)
	end
end)

waveEvent.OnClientEvent:Connect(function(text)
	waveBanner.Text = text
	waveBanner.Visible = (text ~= "")
	if text ~= "" then
		task.spawn(function()
			for _ = 1, 3 do
				waveBanner.BackgroundTransparency = 0.12
				task.wait(0.15)
				waveBanner.BackgroundTransparency = 0.35
				task.wait(0.15)
			end
			waveBanner.BackgroundTransparency = 0.12
		end)
	end
end)

update()
