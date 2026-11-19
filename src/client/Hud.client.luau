local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local D=require(ReplicatedStorage.Shared.BrainrotData)
local player=Players.LocalPlayer
local network=ReplicatedStorage:WaitForChild("IslandNetwork")
local event=network:WaitForChild("Event"); local action=network:WaitForChild("Action")
local gui=Instance.new("ScreenGui"); gui.Name="IslandHUD"; gui.ResetOnSpawn=false; gui.Parent=player:WaitForChild("PlayerGui")
local function text(name,parent,size,pos,value)
 local label=Instance.new("TextLabel"); label.Name=name; label.Size=size; label.Position=pos
 label.BackgroundColor3=Color3.fromRGB(23,36,55); label.BackgroundTransparency=0.12
 label.TextColor3=Color3.fromRGB(242,249,255); label.Font=Enum.Font.GothamBold
 label.TextScaled=true; label.TextWrapped=true; label.Text=value; label.Parent=parent
 local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,9); corner.Parent=label
 local padding=Instance.new("UIPadding"); padding.PaddingLeft=UDim.new(0,8); padding.PaddingRight=UDim.new(0,8); padding.Parent=label
 return label
end
local function button(name,parent,size,pos,value,callback)
 local b=Instance.new("TextButton"); b.Name=name; b.Size=size; b.Position=pos; b.Text=value
 b.BackgroundColor3=Color3.fromRGB(42,114,133); b.TextColor3=Color3.new(1,1,1)
 b.Font=Enum.Font.GothamBold; b.TextScaled=true; b.TextWrapped=true; b.Parent=parent
 local corner=Instance.new("UICorner"); corner.Parent=b
 b.Activated:Connect(callback); return b
end
local cash=text("Cash",gui,UDim2.fromScale(0.28,0.075),UDim2.fromScale(0.02,0.02),"$150")
local banner=text("WaveStatus",gui,UDim2.fromScale(0.6,0.085),UDim2.fromScale(0.35,0.02),"CALM • Preparing island")
local carry=text("CarryStatus",gui,UDim2.fromScale(0.46,0.06),UDim2.fromScale(0.27,0.91),"Buy → carry → place → earn")
local toast=text("Toast",gui,UDim2.fromScale(0.7,0.1),UDim2.fromScale(0.15,0.77),""); toast.Visible=false
local rebirth=button("Rebirth",gui,UDim2.fromScale(0.23,0.09),UDim2.fromScale(0.75,0.88),"Rebirth",function() action:FireServer("Rebirth") end)
local panel=Instance.new("Frame"); panel.Name="SpeedShop"; panel.Size=UDim2.fromScale(0.37,0.65); panel.Position=UDim2.fromScale(0.02,0.19); panel.BackgroundColor3=Color3.fromRGB(23,36,55); panel.Visible=false; panel.Parent=gui
text("Title",panel,UDim2.fromScale(1,0.09),UDim2.fromScale(0,0),"SPEED SHOP • 10 tiers")
local rows={}
for tier=1,D.SpeedTiers do
 rows[tier]=button("Tier"..tier,panel,UDim2.fromScale(0.94,0.077),UDim2.fromScale(0.03,0.11+(tier-1)*0.085),"",function()
  if (player:GetAttribute("SpeedTier") or 0)+1==tier then action:FireServer("Speed") end
 end)
end
button("ToggleSpeed",gui,UDim2.fromScale(0.23,0.065),UDim2.fromScale(0.02,0.11),"Speed Shop",function() panel.Visible=not panel.Visible end)
local function refresh()
 local speed=player:GetAttribute("SpeedTier") or 0
 local count=player:GetAttribute("Rebirths") or 0
 cash.Text="$"..(player:GetAttribute("Cash") or 150).." • $"..string.format("%.1f",player:GetAttribute("IncomePerSecond") or 0).."/s"
 rebirth.Text="Rebirth $25,000\n"..count.." rebirths • "..(1+count*0.5).."× income"
 local carrying=player:GetAttribute("Carrying")
 carry.Text=carrying and carrying~="" and "Carrying: "..carrying.." • Bring to your pad!" or "3 matching species → fuse at Fusion Corner"
 for tier,b in ipairs(rows) do
  b.Text=(tier<=speed and "OWNED • " or tier==speed+1 and "BUY • " or "LOCKED • ").."Tier "..tier.." / Speed "..(16+tier*2).." / $"..D.SpeedCost(tier)
  b.BackgroundColor3=tier==speed+1 and Color3.fromRGB(38,148,151) or Color3.fromRGB(57,68,86)
  b.Active=tier==speed+1; b.AutoButtonColor=tier==speed+1
 end
end
player.AttributeChanged:Connect(refresh)
local toastId=0
event.OnClientEvent:Connect(function(kind,data)
 if kind=="Wave" then
  banner.Text=data.Phase.." • "..data.Remaining.."s • "..data.Height.." stud wave\n"..(data.Phase=="CALM" and "Collect now. Your own base is safe." or "Return home or climb the high platforms!")
  banner.BackgroundColor3=data.Phase=="CALM" and Color3.fromRGB(24,93,106) or Color3.fromRGB(164,60,61)
 elseif kind=="Toast" or kind=="Warning" then
  toastId+=1; local id=toastId; toast.Text=data; toast.Visible=true
  task.delay(5,function() if toastId==id then toast.Visible=false end end)
 end
end)
refresh(); action:FireServer("Sync")
