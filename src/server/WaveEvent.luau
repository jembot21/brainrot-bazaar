local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local D=require(game.ReplicatedStorage.Shared.BrainrotData)
local HEIGHTS={6,10,14,18}
local Wave={State={Phase="CALM",Remaining=D.Calm,Height=6,Cycle=0}}
function Wave.Start(world,economy,base,remote)
 local function publish(phase,remaining,height,cycle)
  Wave.State={Phase=phase,Remaining=remaining,Height=height,Cycle=cycle}
  remote:FireAllClients("Wave",Wave.State)
 end
 local function countdown(phase,duration,height,cycle)
  for remaining=duration,1,-1 do publish(phase,remaining,height,cycle); task.wait(1) end
 end
 task.spawn(function()
  local cycle=0
  while true do
   cycle+=1
   local height=HEIGHTS[math.min(cycle,#HEIGHTS)]
   countdown("CALM",D.Calm,height,cycle)
   remote:FireAllClients("Warning","SIREN: Tsunami incoming! Your base or high ground is safe.")
   for remaining=D.Warning,1,-1 do
    publish("WARNING",remaining,height,cycle)
    if remaining==2 then
     remote:FireAllClients("Shake",{Duration=2,Strength=0.2+height/90})
    end
    task.wait(1)
   end
   local wall=world.Part("TsunamiWall",Vector3.new(340,height,13),Vector3.new(0,height/2,-170),Color3.fromRGB(47,179,235),"Wave",Enum.Material.Glass)
   wall.Transparency=0.35; wall.CanCollide=false; wall.CanTouch=false; wall.CastShadow=false
   local foam=world.Part("WaveFoam",Vector3.new(340,1,14),Vector3.new(0,height,-170),Color3.fromRGB(216,251,255),"Wave",Enum.Material.Neon)
   foam.CanCollide=false; foam.CanTouch=false
   local caught={}; local previousZ=-170; local start=os.clock(); local lastSecond=-1
   while os.clock()-start<D.Sweep do
    local elapsed=os.clock()-start
    local z=-170+340*math.min(elapsed/D.Sweep,1)
    wall.Position=Vector3.new(0,height/2,z); foam.Position=Vector3.new(0,height,z)
    local remaining=math.ceil(D.Sweep-elapsed)
    if remaining~=lastSecond then publish("SWEEP",remaining,height,cycle); lastSecond=remaining end
    for _,player in ipairs(Players:GetPlayers()) do
     local character=player.Character
     local root=character and character:FindFirstChild("HumanoidRootPart")
     local humanoid=character and character:FindFirstChildOfClass("Humanoid")
     if root and humanoid and humanoid.Health>0 and not caught[player] then
      local pos=root.Position
      if math.abs(pos.X)<=170 and pos.Z>=previousZ-7 and pos.Z<=z+7 and pos.Y-2<height and not base.IsHome(player,pos) then
       caught[player]=true; base.Drop(player); economy.Penalize(player)
       remote:FireClient(player,"Caught",pos)
       remote:FireClient(player,"Toast","Swept away! Lost your carried creature and 5% cash.")
      end
     end
    end
    previousZ=z
    RunService.Heartbeat:Wait()
   end
   wall:Destroy(); foam:Destroy()
  end
 end)
end
return Wave
