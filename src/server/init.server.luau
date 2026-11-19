local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")
local World=require(script.WorldBuilder)
local Economy=require(script.Economy)
local Base=require(script.BaseManager)
local Spawner=require(script.Spawner)
local Wave=require(script.WaveEvent)
local network=Instance.new("Folder"); network.Name="IslandNetwork"; network.Parent=ReplicatedStorage
local event=Instance.new("RemoteEvent"); event.Name="Event"; event.Parent=network
local action=Instance.new("RemoteEvent"); action.Name="Action"; action.Parent=network
local world=World.Build()
Economy.Start(Base)
Base.Start(world,Economy,event)
Spawner.Start(world,Economy,Base,event)
Wave.Start(world,Economy,Base,event)
local cooldown={}
action.OnServerEvent:Connect(function(player,verb)
 if type(verb)~="string" then return end
 local now=os.clock()
 if cooldown[player] and now-cooldown[player]<0.25 then return end
 cooldown[player]=now
 if verb=="Sync" then event:FireClient(player,"Wave",Wave.State)
 elseif verb=="Speed" then
  local ok=Economy.BuySpeed(player)
  event:FireClient(player,"Toast",ok and "Speed upgraded!" or "Not enough cash, or speed is maxed.")
  if ok then event:FireClient(player,"Purchase") end
 elseif verb=="Rebirth" then
  local ok=Economy.Rebirth(player)
  event:FireClient(player,"Toast",ok and "Reborn! Your permanent session income multiplier increased by 0.5×." or "Rebirth requires $25,000.")
  if ok then event:FireClient(player,"Purchase") end
 end
end)
Players.PlayerRemoving:Connect(function(player) cooldown[player]=nil end)
