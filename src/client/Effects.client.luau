local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local player=Players.LocalPlayer
local event=game.ReplicatedStorage:WaitForChild("IslandNetwork"):WaitForChild("Event")
local gui=Instance.new("ScreenGui"); gui.Name="TsunamiEffects"; gui.IgnoreGuiInset=true; gui.ResetOnSpawn=false; gui.DisplayOrder=5; gui.Parent=player:WaitForChild("PlayerGui")
local borders={}
for _,box in ipairs({{0,0,1,0.07},{0,0.93,1,0.07},{0,0,0.045,1},{0.955,0,0.045,1}}) do
 local frame=Instance.new("Frame"); frame.BorderSizePixel=0; frame.Position=UDim2.fromScale(box[1],box[2]); frame.Size=UDim2.fromScale(box[3],box[4]); frame.BackgroundColor3=Color3.fromRGB(246,62,79); frame.BackgroundTransparency=1; frame.Parent=gui
 table.insert(borders,frame)
end
local warning=false; local shakeUntil=0; local shakeStrength=0
RunService:BindToRenderStep("IslandWaveEffects",Enum.RenderPriority.Camera.Value+1,function()
 local now=os.clock()
 for _,frame in ipairs(borders) do frame.BackgroundTransparency=warning and (0.72+math.sin(now*7)*0.13) or 1 end
 local camera=workspace.CurrentCamera
 if camera and now<shakeUntil then
  local strength=math.min(shakeUntil-now,1)*shakeStrength
  camera.CFrame*=CFrame.new(math.noise(now*29,0)*strength,math.noise(0,now*31)*strength,0)
 end
end)
local function burst(position,color,count)
 local anchor=Instance.new("Part"); anchor.Name="LocalSplash"; anchor.Size=Vector3.one; anchor.Position=position; anchor.Anchored=true; anchor.CanCollide=false; anchor.CanTouch=false; anchor.CanQuery=false; anchor.Transparency=1; anchor.Parent=workspace
 local emitter=Instance.new("ParticleEmitter"); emitter.Color=ColorSequence.new(color)
 emitter.Rate=0; emitter.Lifetime=NumberRange.new(0.4,0.9); emitter.Speed=NumberRange.new(6,15)
 emitter.SpreadAngle=Vector2.new(150,150); emitter.Acceleration=Vector3.new(0,-18,0)
 emitter.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,0.5),NumberSequenceKeypoint.new(1,0)})
 emitter.Parent=anchor; emitter:Emit(count); Debris:AddItem(anchor,2)
end
event.OnClientEvent:Connect(function(kind,data)
 if kind=="Warning" then warning=true
 elseif kind=="Wave" then warning=data.Phase~="CALM"
 elseif kind=="Shake" then shakeUntil=os.clock()+(data.Duration or 1); shakeStrength=data.Strength or 0.3
 elseif kind=="Caught" then
  burst(data,Color3.fromRGB(153,233,255),60)
  shakeUntil=os.clock()+0.8; shakeStrength=0.6
 elseif kind=="Purchase" then
  local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  if root then burst(root.Position+Vector3.new(0,2,0),Color3.fromRGB(255,227,112),30) end
 end
end)
local function mutationEffect(object)
 if not object:IsA("Model") then return end
 local mutation=object:GetAttribute("Mutation")
 if mutation~="Gold" and mutation~="Diamond" then return end
 local body=object:FindFirstChild("Body")
 if body and not body:FindFirstChild("MutationShimmer") then
  local sparkles=Instance.new("Sparkles"); sparkles.Name="MutationShimmer"
  sparkles.SparkleColor=mutation=="Gold" and Color3.fromRGB(255,217,78) or Color3.fromRGB(143,236,255)
  sparkles.Parent=body
 end
end
workspace.DescendantAdded:Connect(mutationEffect)
for _,object in ipairs(workspace:GetDescendants()) do mutationEffect(object) end
-- TweenService is reserved for subsequent screen transitions; effects stay local.
gui.Destroying:Connect(function() RunService:UnbindFromRenderStep("IslandWaveEffects") end)
