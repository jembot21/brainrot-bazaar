local Players=game:GetService("Players")
local D=require(game.ReplicatedStorage.Shared.BrainrotData)
local E={States={}}
function E.Sync(player)
 local s=E.States[player]; if not s then return end
 s.CashStat.Value=math.floor(s.Cash)
 player:SetAttribute("Cash",math.floor(s.Cash))
 player:SetAttribute("SpeedTier",s.Speed)
 player:SetAttribute("Rebirths",s.Rebirths)
 player:SetAttribute("IncomeMultiplier",1+s.Rebirths*D.RebirthBonus)
end
function E.AddPlayer(player)
 if E.States[player] then return end
 local stats=Instance.new("Folder"); stats.Name="leaderstats"; stats.Parent=player
 local cash=Instance.new("IntValue"); cash.Name="Cash"; cash.Parent=stats
 E.States[player]={Cash=D.StartCash,Speed=0,Rebirths=0,CashStat=cash}
 E.Sync(player)
 player.CharacterAdded:Connect(function(character)
  local humanoid=character:WaitForChild("Humanoid",10)
  local state=E.States[player]
  if humanoid and state then humanoid.WalkSpeed=16+state.Speed*D.SpeedStep end
 end)
end
function E.Credit(player,amount)
 local s=E.States[player]
 if not s or amount~=amount or amount<0 or amount==math.huge then return false end
 s.Cash+=amount; E.Sync(player); return true
end
function E.Spend(player,amount)
 local s=E.States[player]
 if not s or amount~=amount or amount<0 or amount==math.huge or s.Cash<amount then return false end
 s.Cash-=amount; E.Sync(player); return true
end
function E.Penalize(player)
 local s=E.States[player]; if s then E.Spend(player,s.Cash*D.CaughtPenalty) end
end
function E.Sell(player,item) return E.Credit(player,D.Price(item)*D.SellRatio) end
function E.BuySpeed(player)
 local s=E.States[player]
 if not s or s.Speed>=D.SpeedTiers then return false end
 if not E.Spend(player,D.SpeedCost(s.Speed+1)) then return false end
 s.Speed+=1
 local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if h then h.WalkSpeed=16+s.Speed*D.SpeedStep end
 E.Sync(player); return true
end
function E.Rebirth(player)
 local s=E.States[player]
 if not s or not E.Spend(player,D.RebirthCost) then return false end
 s.Rebirths+=1; E.Sync(player); return true
end
function E.Start(base)
 Players.PlayerAdded:Connect(E.AddPlayer)
 Players.PlayerRemoving:Connect(function(player) E.States[player]=nil end)
 for _,player in ipairs(Players:GetPlayers()) do E.AddPlayer(player) end
 task.spawn(function()
  while true do
   task.wait(1)
   for player,s in pairs(E.States) do
    local income=0
    for _,item in ipairs(base.GetPlaced(player)) do income+=D.Income(item) end
    income*=1+s.Rebirths*D.RebirthBonus
    player:SetAttribute("IncomePerSecond",income)
    if income>0 then E.Credit(player,income) end
   end
  end
 end)
end
return E
