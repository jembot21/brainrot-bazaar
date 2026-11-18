local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("BazaarRemotes")
local feedbackEvent = remotes:WaitForChild("Feedback")

local function showIncomePopup(amount)
	local playerGui = player:FindFirstChild("PlayerGui")
	if not playerGui then
		return
	end

	local container = playerGui:FindFirstChild("BazaarHUD") or playerGui

	local popup = Instance.new("TextLabel")
	popup.Name = "CashPopup"
	popup.AnchorPoint = Vector2.new(0.5, 0.5)
	popup.Position = UDim2.new(0.5, 0, 0.43, 0)
	popup.Size = UDim2.fromOffset(190, 44)
	popup.BackgroundTransparency = 1
	popup.Text = "+$" .. tostring(amount) .. "/s"
	popup.TextColor3 = Color3.fromRGB(255, 226, 105)
	popup.TextStrokeColor3 = Color3.fromRGB(24, 29, 36)
	popup.TextStrokeTransparency = 0.2
	popup.TextSize = 28
	popup.Font = Enum.Font.GothamBlack
	popup.Parent = container

	local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(popup, tweenInfo, {
		Position = UDim2.new(0.5, 0, 0.32, 0),
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	})

	tween.Completed:Connect(function()
		popup:Destroy()
	end)

	tween:Play()
end

feedbackEvent.OnClientEvent:Connect(function(kind, value)
	if kind == "cash" then
		showIncomePopup(value)
	end
end)
