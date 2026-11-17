local WaveEvent = {}
local Players = game:GetService("Players")

function WaveEvent.Init(events, economy, bases)
	task.spawn(function()
		while true do
			task.wait(145)
			events.Wave:FireAllClients("TSUNAMI INCOMING! GET HOME!")
			task.wait(10)
			local affected = {}
			local wave = Instance.new("Part")
			wave.Name = "TsunamiWave"
			wave.Size = Vector3.new(10, 44, 240)
			wave.Position = Vector3.new(-126, 25, 0)
			wave.Anchored = true
			wave.CanCollide = false
			wave.Material = Enum.Material.Neon
			wave.Color = Color3.fromRGB(57, 195, 236)
			wave.Transparency = 0.15
			wave.Parent = workspace.BazaarWorld
			for _ = 1, 120 do
				wave.Position += Vector3.new(2.1, 0, 0)
				for _, player in ipairs(Players:GetPlayers()) do
					if not affected[player] and not bases.IsPlayerSafe(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
						if math.abs(player.Character.HumanoidRootPart.Position.X - wave.Position.X) > 18 then continue end
						affected[player] = true
						local state = economy.States[player]
						if state then
							if state.carried then state.carried.model:Destroy(); state.carried = nil end
							state.cash *= 0.9
							economy.Sync(player)
						end
					end
				end
				task.wait(0.05)
			end
			wave:Destroy()
			events.Wave:FireAllClients("")
		end
	end)
end

return WaveEvent
