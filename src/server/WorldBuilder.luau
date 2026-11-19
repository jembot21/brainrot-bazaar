local Tags=game:GetService("CollectionService")
local W={Plots={}}
function W.Build()
 local folder=Instance.new("Folder"); folder.Name="TideglassIsland"; folder.Parent=workspace
 W.Folder=folder
 local function part(name,size,pos,color,area,material)
  local p=Instance.new("Part"); p.Name=name; p.Anchored=true
  p.Size=size; p.Position=pos; p.Color=color; p.Material=material or Enum.Material.SmoothPlastic
  p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
  p:SetAttribute("Area",area); Tags:AddTag(p,area); p.Parent=folder
  return p
 end
 W.Part=part
 part("OceanFloor",Vector3.new(800,3,800),Vector3.new(0,-12,0),Color3.fromRGB(36,103,136),"Ocean",Enum.Material.Sand)
 local ocean=part("Ocean",Vector3.new(790,1,790),Vector3.new(0,-3,0),Color3.fromRGB(38,158,201),"Ocean")
 ocean.Transparency=0.3; ocean.CanCollide=false
 part("BeachRing",Vector3.new(300,3,300),Vector3.new(0,-1.5,0),Color3.fromRGB(245,216,155),"Beach",Enum.Material.Sand)
 part("IslandGround",Vector3.new(268,3,268),Vector3.new(0,-0.5,0),Color3.fromRGB(99,180,110),"Island",Enum.Material.Grass)
 for i=1,8 do
  local col=(i-1)%4; local row=math.floor((i-1)/4)
  local center=Vector3.new(-99+col*66,1.2,row==0 and -91 or 91)
  local plot={Center=center,Pads={},Index=i}
  plot.Floor=part("Base"..i,Vector3.new(54,0.6,48),center,Color3.fromRGB(60+i*10,102,139),"Base")
  for j=1,6 do
   local p=center+Vector3.new(((j-1)%3-1)*15,0.9,(math.floor((j-1)/3)-0.5)*22)
   plot.Pads[j]=part("Plot"..i.."Pad"..j,Vector3.new(10,1,9),p,Color3.fromRGB(237,207,112),"Pads",Enum.Material.Neon)
  end
  W.Plots[i]=plot
 end
 W.Belt=part("OfferBelt",Vector3.new(112,1,12),Vector3.new(0,2,0),Color3.fromRGB(40,53,72),"Market",Enum.Material.Metal)
 for x=-54,54,6 do part("BeltStripe",Vector3.new(0.4,0.08,11),Vector3.new(x,2.55,0),Color3.fromRGB(95,218,213),"Market") end
 for _,x in ipairs({-95,95}) do
  part("HighGroundRefuge",Vector3.new(32,3,40),Vector3.new(x,23,0),Color3.fromRGB(116,129,141),"HighGround",Enum.Material.Slate)
  for step=1,12 do
   part("RefugeStep"..step,Vector3.new(16,2,4),Vector3.new(x,step*2-1,49-step*4),Color3.fromRGB(148,153,153),"HighGround",Enum.Material.Slate)
  end
 end
 local function stand(name,x,z,color)
  local p=part(name,Vector3.new(14,3,9),Vector3.new(x,2.5,z),color,"Shops")
  part(name.."Roof",Vector3.new(18,1,12),Vector3.new(x,10,z),color,"Shops")
  for _,dx in ipairs({-6,6}) do part(name.."Post",Vector3.new(0.8,7,0.8),Vector3.new(x+dx,6,z),Color3.fromRGB(111,76,57),"Shops") end
  local gui=Instance.new("BillboardGui"); gui.Size=UDim2.fromScale(8,1.5); gui.StudsOffset=Vector3.new(0,6,0); gui.MaxDistance=100; gui.Parent=p
  local text=Instance.new("TextLabel"); text.Size=UDim2.fromScale(1,1); text.BackgroundTransparency=1; text.Text=name; text.TextScaled=true; text.Font=Enum.Font.GothamBold; text.TextColor3=Color3.new(1,1,1); text.Parent=gui
  return p
 end
 W.SpeedStand=stand("Speed Shop",-35,-32,Color3.fromRGB(66,180,218))
 W.SellStand=stand("Sell Carried",0,-32,Color3.fromRGB(239,164,73))
 W.FusionStand=stand("Fusion Corner",35,-32,Color3.fromRGB(176,105,226))
 local spawn=Instance.new("SpawnLocation"); spawn.Name="IslandArrival"; spawn.Size=Vector3.new(12,1,12); spawn.Position=Vector3.new(0,2,35); spawn.Anchored=true; spawn.Neutral=true; spawn.Duration=0; spawn.Parent=folder; Tags:AddTag(spawn,"Arrival")
 -- Twenty palms, each with a two-layer broad crown made entirely from parts.
 for i=1,20 do
  local angle=i*math.pi*2/20; local x=math.cos(angle)*139; local z=math.sin(angle)*139
  part("PalmTrunk"..i,Vector3.new(2,14,2),Vector3.new(x,6,z),Color3.fromRGB(132,91,58),"Beach",Enum.Material.Wood)
  for layer=1,2 do for axis=0,2 do
   local leaf=part("PalmFrond",Vector3.new(19-layer*2,0.7,4),Vector3.new(x,12+layer*1.2,z),Color3.fromRGB(45,133+layer*15,76),"Beach",Enum.Material.Grass)
   leaf.Orientation=Vector3.new(0,axis*60+layer*25,layer==1 and 8 or -8)
  end end
 end
 local rng=Random.new(927)
 -- 250 extra scenery pieces, kept along the beach perimeter for clear paths.
 for i=1,250 do
  local angle=rng:NextNumber()*math.pi*2; local radius=rng:NextNumber(136,147)
  local pos=Vector3.new(math.cos(angle)*radius,1,math.sin(angle)*radius)
  local kind=i%5
  if kind==0 then
   local p=part("BeachRock",Vector3.new(3,2,3),pos,Color3.fromRGB(137,148,154),"Decor",Enum.Material.Slate); p.Shape=Enum.PartType.Ball
  elseif kind==1 then
   local p=part("Bush",Vector3.new(4,3,4),pos,Color3.fromRGB(53,137,77),"Decor",Enum.Material.Grass); p.Shape=Enum.PartType.Ball
  elseif kind==2 then
   local p=part("Fence",Vector3.new(5,2.5,0.5),pos,Color3.fromRGB(173,127,79),"Decor",Enum.Material.Wood); p.Orientation=Vector3.new(0,math.deg(angle),0)
  elseif kind==3 then
   local p=part("Lamp",Vector3.new(1,5,1),pos+Vector3.new(0,1.5,0),Color3.fromRGB(255,223,139),"Decor",Enum.Material.Neon)
   local light=Instance.new("PointLight"); light.Range=10; light.Brightness=0.5; light.Parent=p
  else part("Crate",Vector3.new(3,3,3),pos,Color3.fromRGB(163,112,66),"Decor",Enum.Material.WoodPlanks) end
 end
 game:GetService("Lighting").ClockTime=14
 return W
end
return W
