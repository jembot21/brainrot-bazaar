local Players=game:GetService("Players")
local D=require(game.ReplicatedStorage.Shared.BrainrotData)
local Factory=require(script.Parent.CharacterFactory)
local B={Assignments={},Carried={}}
local world,economy,remote
local function toast(p,message) remote:FireClient(p,"Toast",message) end
local function aliveNear(p,part)
 local c=p.Character; local root=c and c:FindFirstChild("HumanoidRootPart")
 local h=c and c:FindFirstChildOfClass("Humanoid")
 return root and h and h.Health>0 and (root.Position-part.Position).Magnitude<=14
end
local function prompt(part,text,callback)
 local p=Instance.new("ProximityPrompt"); p.ActionText=text; p.ObjectText=part.Name
 p.HoldDuration=0.4; p.MaxActivationDistance=11; p.RequiresLineOfSight=false; p.Parent=part
 p.Triggered:Connect(function(player) if aliveNear(player,part) then callback(player) end end)
 return p
end
function B.GetPlaced(player)
 local result={}; local plot=B.Assignments[player]
 if plot then for _,slot in pairs(plot.Slots) do table.insert(result,slot.Item) end end
 return result
end
function B.IsHome(player,position)
 local plot=B.Assignments[player]
 return plot~=nil and math.abs(position.X-plot.Center.X)<=27 and math.abs(position.Z-plot.Center.Z)<=24
end
function B.Drop(player)
 local carried=B.Carried[player]
 if carried then carried.Model:Destroy(); B.Carried[player]=nil end
 player:SetAttribute("Carrying","")
end
function B.Give(player,item)
 if B.Carried[player] or not B.Assignments[player] then return false end
 local char=player.Character; local head=char and char:FindFirstChild("Head")
 local hum=char and char:FindFirstChildOfClass("Humanoid")
 if not head or not hum or hum.Health<=0 then return false end
 local model=Factory.Create(item); model.Parent=world.Folder
 model:PivotTo(head.CFrame*CFrame.new(0,3.5,0))
 for _,p in ipairs(model:GetDescendants()) do
  if p:IsA("BasePart") then
   p.Anchored=false; p.Massless=true
   local weld=Instance.new("WeldConstraint"); weld.Part0=head; weld.Part1=p; weld.Parent=p
  end
 end
 B.Carried[player]={Item=item,Model=model}
 player:SetAttribute("Carrying",D.Species[item.Species].Name)
 return true
end
local function place(plot,index,item)
 local pad=plot.Pads[index]
 local model=Factory.Create(item); model.Parent=world.Folder
 model:PivotTo(CFrame.new(pad.Position+Vector3.new(0,2,0)))
 local slot={Item=item,Model=model,Unlock=os.clock()+D.PadLock}
 plot.Slots[index]=slot
 pad.Color=Color3.fromRGB(244,135,103)
 task.delay(D.PadLock,function()
  if plot.Slots[index]==slot then pad.Color=Color3.fromRGB(113,236,158) end
 end)
end
function B.Fuse(player)
 local plot=B.Assignments[player]; if not plot then return end
 local groups={}
 for index,slot in pairs(plot.Slots) do
  local id=slot.Item.Species; groups[id]=groups[id] or {}; table.insert(groups[id],index)
 end
 for id,indices in pairs(groups) do
  local tier=D.Species[id].Tier
  if #indices>=D.FusionCount and tier<#D.Tiers then
   local nextId
   for i,s in ipairs(D.Species) do if s.Tier==tier+1 then nextId=i; break end end
   for i=1,D.FusionCount do local index=indices[i]; plot.Slots[index].Model:Destroy(); plot.Slots[index]=nil end
   place(plot,indices[1],{Species=nextId,Mutation="Normal"})
   toast(player,"Fusion! Three duplicates became "..D.Species[nextId].Name..".")
   remote:FireClient(player,"Purchase"); return
  end
 end
 toast(player,"Place 3 of the same species on your pads. Mythics are already the highest tier.")
end
local function assign(player)
 if B.Assignments[player] then return end
 for _,plot in ipairs(world.Plots) do
  if not plot.Owner then
   plot.Owner=player; B.Assignments[player]=plot
   player:SetAttribute("Plot",plot.Index)
   plot.Floor:SetAttribute("Owner",player.Name)
   local function spawned(char)
    B.Drop(player)
    local root=char:WaitForChild("HumanoidRootPart",10)
    if root and B.Assignments[player]==plot then char:PivotTo(CFrame.new(plot.Center+Vector3.new(0,5,0))) end
    local h=char:FindFirstChildOfClass("Humanoid")
    if h then h.Died:Connect(function() B.Drop(player) end) end
   end
   player.CharacterAdded:Connect(spawned)
   if player.Character then task.spawn(spawned,player.Character) end
   return
  end
 end
 toast(player,"All eight plots are occupied. A plot will be assigned when one opens.")
end
function B.Start(w,e,r)
 world=w; economy=e; remote=r
 for _,plot in ipairs(world.Plots) do
  plot.Slots={}
  for index,pad in ipairs(plot.Pads) do
   prompt(pad,"Place / pick up / steal",function(player)
    local slot=plot.Slots[index]
    if slot then
     if B.Carried[player] then toast(player,"Your hands are full."); return end
     if player~=plot.Owner and os.clock()<slot.Unlock then toast(player,"Locked for "..math.ceil(slot.Unlock-os.clock()).." seconds."); return end
     if B.Give(player,slot.Item) then slot.Model:Destroy(); plot.Slots[index]=nil; pad.Color=Color3.fromRGB(237,207,112) end
    elseif player==plot.Owner and B.Carried[player] then
     local item=B.Carried[player].Item; B.Drop(player); place(plot,index,item)
     toast(player,"Placed! Protected from stealing for 60 seconds.")
    elseif player==plot.Owner then toast(player,"Buy a creature at the belt, then bring it here.") end
   end)
  end
 end
 prompt(world.FusionStand,"Fuse duplicates",B.Fuse)
 prompt(world.SellStand,"Sell carried for 90%",function(player)
  local carry=B.Carried[player]
  if carry then economy.Sell(player,carry.Item); B.Drop(player); remote:FireClient(player,"Purchase") end
 end)
 prompt(world.SpeedStand,"Buy next speed tier",function(player)
  toast(player,economy.BuySpeed(player) and "Speed upgraded!" or "Need more cash, or speed is maxed.")
 end)
 Players.PlayerAdded:Connect(assign)
 Players.PlayerRemoving:Connect(function(player)
  B.Drop(player); local plot=B.Assignments[player]
  if plot then
   for _,slot in pairs(plot.Slots) do slot.Model:Destroy() end
   plot.Slots={}; plot.Owner=nil; plot.Floor:SetAttribute("Owner",nil)
   for _,pad in ipairs(plot.Pads) do pad.Color=Color3.fromRGB(237,207,112) end
   B.Assignments[player]=nil
   task.defer(function() for _,waiting in ipairs(Players:GetPlayers()) do if waiting~=player then assign(waiting) end end end)
  end
 end)
 for _,player in ipairs(Players:GetPlayers()) do assign(player) end
end
return B
