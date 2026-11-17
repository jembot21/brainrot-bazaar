-- Animate the income popup emitted when a player catches a mascot.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("BazaarRemotes")
local feedback = remotes:WaitForChild("Feedback")

local function showIncomePopup(amount)
    local gui = player:FindFirstChildOfClass("PlayerGui")
    if not gui then
        return
    end
    local popup = Instance.new("TextLabel")
    popup.Name = "CashPopup"
    popup.AnchorPoint = Vector2.new(0.5, 0.5)
    popup.Position = UDim2.new(0.5, 0, 0.43, 0)
    popup.Size = UDim2.fromOffset(190, 44)
    popup.BackgroundTransparency = 1
    popup.Text = "+$" .. amount .. "/s"
    popup.TextColor3 = Color3.fromRGB(255, 226, 105)
    popup.TextStrokeTransparency = 0.2
    popup.TextSize = 28
    popup.Font = Enum.Font.GothamBlack
    popup.Parent = gui
    local tween = TweenService:Create(popup, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, 0, 0.32, 0), TextTransparency = 1, TextStrokeTransparency = 1 })
    tween:Play()
    tween.Completed:Connect(function() popup:Destroy() end)
end

feedback.OnClientEvent:Connect(function(kind, value)
    if kind == "cash" then
        showIncomePopup(value)
    end
end)
