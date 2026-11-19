local D=require(game.ReplicatedStorage.Shared.BrainrotData)
local Factory={}
function Factory.Create(item)
 local species=D.Species[item.Species]
 local mutation=D.Mutations[item.Mutation]
 local model=Instance.new("Model")
 model.Name=species.Name
 model:SetAttribute("Mutation",item.Mutation)
 local function block(name,size,position,color)
  local p=Instance.new("Part")
  p.Name=name; p.Size=size; p.Position=position
  p.Color=color; p.Material=Enum.Material.SmoothPlastic
  p.Anchored=true; p.CanCollide=false; p.CanTouch=false
  p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
  p.Parent=model
  return p
 end
 local color=mutation.Color or species.Color
 local body=block("Body",Vector3.new(2,2.2,1.4),Vector3.new(0,1.5,0),color)
 model.PrimaryPart=body
 local head=block("Head",Vector3.new(2.3,1.7,1.7),Vector3.new(0,3.4,0),color)
 for _,x in ipairs({-0.55,0.55}) do
  block("Foot",Vector3.new(0.8,0.5,1.4),Vector3.new(x,0.25,-0.15),species.Color)
  block("Eye",Vector3.new(0.4,0.5,0.12),Vector3.new(x,3.55,-0.9),Color3.new(1,1,1))
  block("Pupil",Vector3.new(0.17,0.25,0.13),Vector3.new(x,3.55,-0.98),Color3.fromRGB(25,25,40))
 end
 block("Smile",Vector3.new(0.65,0.12,0.12),Vector3.new(0,3,-0.91),Color3.fromRGB(40,25,50))
 local accent=Color3.fromRGB(255,234,136)
 local a=species.Accessory
 if a=="Hat" then
  block("HatBrim",Vector3.new(3,0.2,2.2),Vector3.new(0,4.35,0),accent)
  block("HatTop",Vector3.new(1.6,0.9,1.4),Vector3.new(0,4.85,0),accent)
 elseif a=="Ears" then
  for _,x in ipairs({-0.8,0.8}) do block("Ear",Vector3.new(0.5,1.6,0.5),Vector3.new(x,4.8,0),accent) end
 elseif a=="Tail" then
  block("Tail",Vector3.new(0.5,0.5,2.5),Vector3.new(0,1.3,1.6),accent)
 elseif a=="Crown" then
  block("CrownBand",Vector3.new(2.5,0.3,1.9),Vector3.new(0,4.4,0),accent)
  for x=-1,1 do block("CrownPoint",Vector3.new(0.4,0.8,0.4),Vector3.new(x,4.9,0),accent) end
 elseif a=="Orbit" then
  for i=1,6 do local angle=i*math.pi/3; block("OrbitStar",Vector3.new(0.45,0.45,0.45),Vector3.new(math.cos(angle)*1.8,4.5,math.sin(angle)*1.8),accent) end
 elseif a=="Goggles" then
  block("GoggleBar",Vector3.new(2.6,0.2,0.2),Vector3.new(0,3.6,-1.05),accent)
 elseif a=="Wings" then
  for _,x in ipairs({-1,1}) do local wing=block("Wing",Vector3.new(1.8,0.4,2),Vector3.new(x*1.8,2,0.6),accent); wing.Orientation=Vector3.new(0,0,x*25) end
 end
 if item.Mutation=="Rainbow" then
  local n=0
  for _,p in ipairs(model:GetChildren()) do if p:IsA("BasePart") then n+=1; p.Color=Color3.fromHSV((n*0.13)%1,0.7,1) end end
  local sparkle=Instance.new("Sparkles"); sparkle.SparkleColor=mutation.Color; sparkle.Parent=body
 end
 local gui=Instance.new("BillboardGui")
 gui.Name="BrainrotLabel"; gui.Size=UDim2.fromScale(6.5,2)
 gui.StudsOffset=Vector3.new(0,2.8,0); gui.MaxDistance=85; gui.AlwaysOnTop=false
 gui.Parent=head
 local label=Instance.new("TextLabel")
 label.Name="Title"; label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=1
 label.Text=species.Name.."\n"..item.Mutation.." • $"..D.Income(item).."/s"
 label.Font=Enum.Font.GothamBold; label.TextScaled=true
 label.TextColor3=mutation.Color or Color3.fromRGB(244,250,255)
 label.TextStrokeTransparency=0.65; label.ZIndex=2; label.Parent=gui
 local shadow=label:Clone()
 shadow.Name="DropShadow"; shadow.Position=UDim2.fromScale(0.012,0.035)
 shadow.TextColor3=Color3.fromRGB(15,22,36); shadow.TextTransparency=0.35
 shadow.TextStrokeTransparency=1; shadow.ZIndex=1; shadow.Parent=gui
 return model
end
return Factory
