-- Render the wallet, discovered mascot index, feedback, and tsunami warning.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("BazaarRemotes")
local feedbackEvent = remotes:WaitForChild("Feedback")
local waveEvent = remotes:WaitForChild("WaveWarning")
local data = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotData"))

local gui = Instance.new("ScreenGui")
gui.Name = "BazaarHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local function label(parent, name, size, position, text, color, textSize)
    local item = Instance.new("TextLabel")
    item.Name = name
    item.Size = size
    item.Position = position
    item.BackgroundTransparency = 1
    item.Text = text
    item.TextColor3 = color
    item.TextStrokeColor3 = Color3.fromRGB(25, 33, 40)
    item.TextStrokeTransparency = 0.25
    item.TextSize = textSize
    item.Font = Enum.Font.GothamBold
    item.TextXAlignment = Enum.TextXAlignment.Center
    item.Parent = parent
    return item
end

local top = Instance.new("Frame")
top.Name = "Wallet"
top.AnchorPoint = Vector2.new(0.5, 0)
top.Position = UDim2.new(0.5, 0, 0, 18)
top.Size = UDim2.fromOffset(390, 84)
top.BackgroundColor3 = Color3.fromRGB(30, 43, 51)
top.BackgroundTransparency = 0.08
top.BorderSizePixel = 0
top.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = top
local cash = label(top, "Cash", UDim2.new(1, 0, 0, 44), UDim2.fromOffset(0, 2), "$150", Color3.fromRGB(255, 223, 99), 34)
local details = label(top, "IncomeAndMultiplier", UDim2.new(1, 0, 0, 28), UDim2.fromOffset(0, 48), "$0 / sec     x1.0 income", Color3.fromRGB(192, 235, 218), 18)

local waveBanner = label(gui, "WaveWarning", UDim2.new(0.7, 0, 0, 55), UDim2.new(0.15, 0, 0, 112), "", Color3.fromRGB(255, 247, 219), 30)
waveBanner.BackgroundColor3 = Color3.fromRGB(195, 57, 60)
waveBanner.BackgroundTransparency = 0.12
waveBanner.Visible = false

local message = label(gui, "Feedback", UDim2.new(0.7, 0, 0, 44), UDim2.new(0.15, 0, 0.82, 0), "", Color3.fromRGB(255, 255, 255), 23)
message.BackgroundColor3 = Color3.fromRGB(30, 43, 51)
message.BackgroundTransparency = 0.1
message.Visible = false

local collection = Instance.new("Frame")
collection.Name = "CollectionIndex"
collection.AnchorPoint = Vector2.new(1, 0.5)
collection.Position = UDim2.new(1, -20, 0.5, 0)
collection.Size = UDim2.fromOffset(270, 390)
collection.BackgroundColor3 = Color3.fromRGB(34, 48, 58)
collection.BackgroundTransparency = 0.08
collection.BorderSizePixel = 0
collection.Parent = gui
local collectionCorner = Instance.new("UICorner")
collectionCorner.CornerRadius = UDim.new(0, 8)
collectionCorner.Parent = collection
label(collection, "Title", UDim2.new(1, -16, 0, 38), UDim2.fromOffset(8, 8), "BAZAAR INDEX  0/12", Color3.fromRGB(255, 229, 150), 20)
local list = Instance.new("Frame")
list.Name = "Entries"
list.Position = UDim2.fromOffset(10, 52)
list.Size = UDim2.new(1, -20, 1, -62)
list.BackgroundTransparency = 1
list.Parent = collection
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 2)
layout.Parent = list

local owned = {}
local rows = {}
for index, character in ipairs(data.Cast) do
    local row = Instance.new("TextLabel")
    row.Name = "Entry" .. index
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundTransparency = 1
    row.Text = "-  " .. character.name
    row.TextXAlignment = Enum.TextXAlignment.Left
    row.TextColor3 = Color3.fromRGB(207, 215, 219)
    row.TextSize = 15
    row.Font = Enum.Font.GothamMedium
    row.Parent = list
    rows[character.name] = row
end

local function update()
    cash.Text = "$" .. tostring(player:GetAttribute("Cash") or 150)
    details.Text = "$" .. tostring(player:GetAttribute("Income") or 0) .. " / sec     x" .. string.format("%.1f", player:GetAttribute("Multiplier") or 1) .. " income"
    local count = 0
    for name, row in pairs(rows) do
        if owned[name] then
            count += 1
            row.Text = "✓  " .. name
            row.TextColor3 = Color3.fromRGB(112, 235, 164)
        end
    end
    collection.Title.Text = "BAZAAR INDEX  " .. count .. "/12"
end

for _, attribute in ipairs({ "Cash", "Income", "Multiplier" }) do player:GetAttributeChangedSignal(attribute):Connect(update) end
feedbackEvent.OnClientEvent:Connect(function(kind, text)
    if kind == "owned" then
        owned[text] = true; update(); return
    end
    if kind == "message" then
        message.Text = text
        message.Visible = true
        task.delay(3.5, function() if message.Text == text then message.Visible = false end end)
    end
end)
waveEvent.OnClientEvent:Connect(function(text)
    waveBanner.Text = text
    waveBanner.Visible = text ~= ""
    if text ~= "" then
        waveBanner.BackgroundTransparency = 0.12
        for _ = 1, 3 do task.wait(0.15); waveBanner.BackgroundTransparency = 0.35; task.wait(0.15); waveBanner.BackgroundTransparency = 0.12 end
    end
end)
update()
