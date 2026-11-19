local RunService=game:GetService("RunService")
local D=require(game.ReplicatedStorage.Shared.BrainrotData)
local Factory=require(script.Parent.CharacterFactory)
local S={}
function S.Start(world,economy,base,remote)
 local rng=Random.new(); local offers={}; local elapsed=4
 local function spawnOffer()
  local item=D.Roll(rng); local model=Factory.Create(item)
  model.Parent=world.Folder
  local offer={Model=model,Item=item,X=-51,Busy=false}
  model:PivotTo(CFrame.new(-51,4.5,0))
  local price=D.Price(item)
  local p=Instance.new("ProximityPrompt"); p.ActionText="Buy $"..price
  p.ObjectText=D.Species[item.Species].Name; p.MaxActivationDistance=11
  p.RequiresLineOfSight=false; p.HoldDuration=0.3; p.Parent=model.PrimaryPart
  p.Triggered:Connect(function(player)
   local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
   if offer.Busy or not model.Parent or not root or (root.Position-model.PrimaryPart.Position).Magnitude>14 then return end
   if base.Carried[player] then remote:FireClient(player,"Toast","Place or sell your carried creature first."); return end
   if not base.Assignments[player] then return end
   offer.Busy=true
   if economy.Spend(player,price) then
    if base.Give(player,item) then
     model:Destroy(); remote:FireClient(player,"Purchase")
     remote:FireClient(player,"Toast","Carry it home! Place it on an empty pad to earn income.")
    else economy.Credit(player,price); offer.Busy=false end
   else remote:FireClient(player,"Toast","You need $"..price.."."); offer.Busy=false end
  end)
  table.insert(offers,offer)
 end
 RunService.Heartbeat:Connect(function(dt)
  elapsed+=dt
  if elapsed>=4 then elapsed=0; if #offers<10 then spawnOffer() end end
  for i=#offers,1,-1 do
   local offer=offers[i]
   if not offer.Model.Parent then table.remove(offers,i)
   else
    offer.X+=dt*3
    if offer.X>53 then offer.Model:Destroy(); table.remove(offers,i)
    else offer.Model:PivotTo(CFrame.new(offer.X,4.5,0)) end
   end
  end
 end)
end
return S
