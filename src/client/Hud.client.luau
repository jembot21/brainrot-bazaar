local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local D = require(ReplicatedStorage.Shared.BrainrotData)
local player = Players.LocalPlayer
local network = ReplicatedStorage:WaitForChild("IslandNetwork")
local event = network:WaitForChild("Event")
local action = network:WaitForChild("Action")

local gui = Instance.new("ScreenGui")
gui.Name = "IslandHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function text(name, parent, size, pos, value)
    local caption = Instance.new("TextLabel")
    caption.Name = name
    caption.Size = size
    caption.Position = pos
    caption.BackgroundColor3 = Color3.fromRGB(23, 36, 55)
    caption.BackgroundTransparency = 0.12
    caption.TextColor3 = Color3.fromRGB(242, 249, 255)
    caption.Font = Enum.Font.GothamBold
    caption.TextScaled = true
    caption.TextWrapped = true
    caption.Text = value
    caption.Parent = parent

    local rounding = Instance.new("UICorner")
    rounding.CornerRadius = UDim.new(0, 9)
    rounding.Parent = caption
    local inset = Instance.new("UIPadding")
    inset.PaddingLeft = UDim.new(0, 8)
    inset.PaddingRight = UDim.new(0, 8)
    inset.Parent = caption
    return caption
end

local function button(name, parent, size, pos, value, callback)
    local control = Instance.new("TextButton")
    control.Name = name
    control.Size = size
    control.Position = pos
    control.Text = value
    control.BackgroundColor3 = Color3.fromRGB(42, 114, 133)
    control.TextColor3 = Color3.new(1, 1, 1)
    control.Font = Enum.Font.GothamBold
    control.TextScaled = true
    control.TextWrapped = true
    control.Parent = parent
    local rounding = Instance.new("UICorner")
    rounding.Parent = control
    control.Activated:Connect(callback)
    return control
end

local cash = text("Cash", gui, UDim2.fromScale(0.28, 0.075), UDim2.fromScale(0.02, 0.02), "$150")
local banner = text("WaveStatus", gui, UDim2.fromScale(0.6, 0.085), UDim2.fromScale(0.35, 0.02), "CALM • Preparing island")
local carry = text("CarryStatus", gui, UDim2.fromScale(0.46, 0.06), UDim2.fromScale(0.27, 0.91), "Buy → carry → place → earn")
local toast = text("Toast", gui, UDim2.fromScale(0.7, 0.1), UDim2.fromScale(0.15, 0.77), "")
toast.Visible = false
local rebirth = button("Rebirth", gui, UDim2.fromScale(0.23, 0.09), UDim2.fromScale(0.75, 0.88), "Rebirth", function()
    action:FireServer("Rebirth")
end)

local panel = Instance.new("Frame")
panel.Name = "SpeedShop"
panel.Size = UDim2.fromScale(0.37, 0.65)
panel.Position = UDim2.fromScale(0.02, 0.19)
panel.BackgroundColor3 = Color3.fromRGB(23, 36, 55)
panel.Visible = false
panel.Parent = gui
text("Title", panel, UDim2.fromScale(1, 0.09), UDim2.fromScale(0, 0), "SPEED SHOP • 10 tiers")

local rows = {}
for tier = 1, D.SpeedTiers do
    rows[tier] = button(
        "Tier" .. tier,
        panel,
        UDim2.fromScale(0.94, 0.077),
        UDim2.fromScale(0.03, 0.11 + (tier - 1) * 0.085),
        "",
        function()
            if (player:GetAttribute("SpeedTier") or 0) + 1 == tier then
                action:FireServer("Speed")
            end
        end
    )
end
button("ToggleSpeed", gui, UDim2.fromScale(0.23, 0.065), UDim2.fromScale(0.02, 0.11), "Speed Shop", function()
    panel.Visible = not panel.Visible
end)

local function refresh()
    local ownedSpeed = player:GetAttribute("SpeedTier") or 0
    local rebirthCount = player:GetAttribute("Rebirths") or 0
    cash.Text = "$" .. (player:GetAttribute("Cash") or 150)
        .. " • $" .. string.format("%.1f", player:GetAttribute("IncomePerSecond") or 0) .. "/s"
    rebirth.Text = "Rebirth $25,000\n" .. rebirthCount .. " rebirths • "
        .. (1 + rebirthCount * 0.5) .. "× income"

    local heldName = player:GetAttribute("Carrying")
    carry.Text = heldName and heldName ~= "" and "Carrying: " .. heldName .. " • Bring to your pad!"
        or "3 matching species → fuse at Fusion Corner"
    for tierIndex, control in ipairs(rows) do
        control.Text = (tierIndex <= ownedSpeed and "OWNED • " or tierIndex == ownedSpeed + 1 and "BUY • " or "LOCKED • ")
            .. "Tier " .. tierIndex .. " / Speed " .. (16 + tierIndex * 2) .. " / $" .. D.SpeedCost(tierIndex)
        control.BackgroundColor3 = tierIndex == ownedSpeed + 1 and Color3.fromRGB(38, 148, 151)
            or Color3.fromRGB(57, 68, 86)
        control.Active = tierIndex == ownedSpeed + 1
        control.AutoButtonColor = tierIndex == ownedSpeed + 1
    end
end
player.AttributeChanged:Connect(refresh)

local toastId = 0
event.OnClientEvent:Connect(function(kind, data)
    if kind == "Wave" then
        banner.Text = data.Phase .. " • " .. data.Remaining .. "s • " .. data.Height .. " stud wave\n"
            .. (data.Phase == "CALM" and "Collect now. Your own base is safe." or "Return home or climb the high platforms!")
        banner.BackgroundColor3 = data.Phase == "CALM" and Color3.fromRGB(24, 93, 106)
            or Color3.fromRGB(164, 60, 61)
    elseif kind == "Toast" or kind == "Warning" then
        toastId += 1
        local messageId = toastId
        toast.Text = data
        toast.Visible = true
        task.delay(5, function()
            if toastId == messageId then
                toast.Visible = false
            end
        end)
    end
end)

refresh()
action:FireServer("Sync")
