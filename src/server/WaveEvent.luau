local Players = game:GetService("Players")

local WaveEvent = {}

function WaveEvent.Init(events, economy, bases)
	task.spawn(function()
		while true do
			task.wait(145)
			events.Wave:FireAllClients("TSUNAMI INCOMING! GET HOME!")
			task.wait(10)

			local bazaarWorld = workspace:FindFirstChild("BazaarWorld")
			local wave = Instance.new("Part")
			wave.Name = "TsunamiWave"
			wave.Size = Vector3.new(10, 44, 240)
			wave.Position = Vector3.new(-126, 25, 0)
			wave.Anchored = true
			wave.CanCollide = false
			wave.Material = Enum.Material.Neon
			wave.Color = Color3.fromRGB(57, 195, 236)
			wave.Transparency = 0.15
			wave.Parent = bazaarWorld or workspace

			local hitPlayers = {}

			for _ = 1, 120 do
				wave.Position += Vector3.new(2.1, 0, 0)

				for _, player in ipairs(Players:GetPlayers()) do
					if not hitPlayers[player] and not bases.IsPlayerSafe(player) then
						local char = player.Character
						local root = char and char:FindFirstChild("HumanoidRootPart")
						if root and math.abs(root.Position.X - wave.Position.X) <= 18 then
							hitPlayers[player] = true
							local account = economy.States[player]
							if account then
								if account.carried and account.carried.model then
									account.carried.model:Destroy()
									account.carried = nil
								end
								account.cash *= 0.9
								economy.Sync(player)
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
