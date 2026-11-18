local Workspace = game:GetService("Workspace")

local WaveEvent = {}

function WaveEvent.Init(events, economy, bases)
	task.spawn(function()
		while true do
			task.wait(145)

			events.Wave:FireAllClients("TSUNAMI INCOMING! GET HOME!")
			task.wait(10)

			local world = Workspace:FindFirstChild("BazaarWorld")
			if not world then
				continue
			end

			local wave = Instance.new("Part")
			wave.Name = "TsunamiWave"
			wave.Size = Vector3.new(10, 44, 240)
			wave.Position = Vector3.new(-126, 25, 0)
			wave.Anchored = true
			wave.CanCollide = false
			wave.Material = Enum.Material.Neon
			wave.Color = Color3.fromRGB(57, 195, 236)
			wave.Transparency = 0.15
			wave.Parent = world

			local affected = {}

			for _ = 1, 120 do
				wave.Position += Vector3.new(2.1, 0, 0)

				for player, account in economy.States do
					if not affected[player] and not bases.IsPlayerSafe(player) then
						local char = player.Character
						local root = char and char:FindFirstChild("HumanoidRootPart")
						if root then
							if math.abs(root.Position.X - wave.Position.X) <= 18 then
								affected[player] = true
								if account.carried and account.carried.model then
									account.carried.model:Destroy()
									account.carried = nil
								end
								account.cash *= 0.9
								economy.Sync(player)
								events.Feedback:FireClient(player, "message", "SWEPT BY THE TSUNAMI! LOST CARRIED MASCOT & 10% CASH")
							end
						end
					end
				end

				task.wait(0.05)
			end

			if wave then
				wave:Destroy()
			end
			events.Wave:FireAllClients("")
		end
	end)
end

return WaveEvent
