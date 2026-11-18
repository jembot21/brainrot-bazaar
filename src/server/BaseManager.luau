local Players = game:GetService("Players")

local BaseManager = {}

local economy = nil
local feedbackRemote = nil
local plots = {}
local lastRescue = {}
local lastWrongBase = {}

local function getRoot(player)
	local char = player.Character
	if char then
		return char:FindFirstChild("HumanoidRootPart")
	end
	return nil
end

function BaseManager.Init(economyModule, characterFactory, feedbackRemoteEvent, worldData)
	economy = economyModule
	feedbackRemote = feedbackRemoteEvent
	plots = worldData.plots

	for _, plot in ipairs(plots) do
		local ownerSign = plot:FindFirstChild("OwnerSign")
		if ownerSign then
			local lockPrompt = ownerSign:FindFirstChild("BaseLockPrompt")
			if lockPrompt then
				lockPrompt.Triggered:Connect(function(player)
					local account = economy.States[player]
					if not account or account.plot ~= plot then
						return
					end

					local lockedUntil = plot:GetAttribute("LockedUntil") or 0
					if os.time() < lockedUntil then
						plot:SetAttribute("LockedUntil", 0)
						feedbackRemote:FireClient(player, "message", "BASE UNLOCKED")
					else
						plot:SetAttribute("LockedUntil", os.time() + 60)
						feedbackRemote:FireClient(player, "message", "BASE LOCKED FOR 60 SECONDS")
					end
				end)
			end
		end

		local padsFolder = plot:FindFirstChild("Pads")
		if padsFolder then
			for _, pad in ipairs(padsFolder:GetChildren()) do
				if pad:IsA("BasePart") then
					pad.Touched:Connect(function(hit)
						BaseManager.OnPadTouched(plot, pad, hit)
					end)
				end
			end
		end
	end

	-- Background monitoring loop (beacons, auto-placement, fall rescue)
	task.spawn(function()
		while true do
			task.wait(0.15)

			-- Reset all beacons
			for _, plot in ipairs(plots) do
				local beacon = plot:FindFirstChild("HomeBeacon")
				if beacon then
					beacon.Transparency = 1
				end
			end

			-- Highlight beacons for plot owners
			for player, account in pairs(economy.States) do
				if account.plot then
					local beacon = account.plot:FindFirstChild("HomeBeacon")
					if beacon then
						beacon.Transparency = account.carried and 0.25 or 0.55
					end
				end

				-- Fall rescue check
				local root = getRoot(player)
				if root and root.Position.Y < -2 then
					local now = os.clock()
					if not lastRescue[player] or (now - lastRescue[player] >= 2) then
						lastRescue[player] = now
						local px = player:GetAttribute("PlotX")
						local pz = player:GetAttribute("PlotZ")
						if not px or not pz then
							if account.plot then
								local plotIdx = account.plot:GetAttribute("PlotIndex") or 1
								local ang = (plotIdx - 1) * (math.pi / 4)
								px = math.cos(ang) * 82
								pz = math.sin(ang) * 82
							else
								px = 0
								pz = 0
							end
						end
						if player.Character then
							player.Character:PivotTo(CFrame.new(px, 11, pz))
							feedbackRemote:FireClient(player, "message", "BACK TO YOUR BASE!")
						end
					end
				end

				-- Auto-place check if carrying
				if root and account.carried and account.plot then
					local ownPads = account.plot:FindFirstChild("Pads")
					local bestPad = nil
					local bestDistSq = math.huge

					if ownPads then
						for _, pad in ipairs(ownPads:GetChildren()) do
							if pad:IsA("BasePart") and not pad:GetAttribute("Occupied") then
								local dx = root.Position.X - pad.Position.X
								local dz = root.Position.Z - pad.Position.Z
								local dy = math.abs(root.Position.Y - pad.Position.Y)
								local xzDist = math.sqrt(dx * dx + dz * dz)

								if xzDist <= 8.5 and dy <= 12 then
									local dSq = dx * dx + dz * dz
									if dSq < bestDistSq then
										bestDistSq = dSq
										bestPad = pad
									end
								end
							end
						end
					end

					if bestPad then
						BaseManager.OnPadTouched(account.plot, bestPad, root)
					else
						-- Fallback own pad
						local fallbackPad = nil
						if ownPads then
							for _, pad in ipairs(ownPads:GetChildren()) do
								if pad:IsA("BasePart") and not pad:GetAttribute("Occupied") then
									local dx = root.Position.X - pad.Position.X
									local dz = root.Position.Z - pad.Position.Z
									local dy = math.abs(root.Position.Y - pad.Position.Y)
									local xzDist = math.sqrt(dx * dx + dz * dz)
									if xzDist <= 6.5 and dy <= 5 then
										fallbackPad = pad
										break
									end
								end
							end
						end

						if fallbackPad then
							BaseManager.OnPadTouched(account.plot, fallbackPad, root)
						else
							-- Check if standing in another plot's unoccupied pad
							for _, otherPlot in ipairs(plots) do
								if otherPlot ~= account.plot then
									local otherPads = otherPlot:FindFirstChild("Pads")
									if otherPads then
										for _, pad in ipairs(otherPads:GetChildren()) do
											if pad:IsA("BasePart") and not pad:GetAttribute("Occupied") then
												local dx = root.Position.X - pad.Position.X
												local dz = root.Position.Z - pad.Position.Z
												local xzDist = math.sqrt(dx * dx + dz * dz)
												if xzDist <= 6.5 then
													local now = os.clock()
													if not lastWrongBase[player] or (now - lastWrongBase[player] >= 5) then
														lastWrongBase[player] = now
														feedbackRemote:FireClient(player, "message", "WRONG BASE! FOLLOW THE LIGHT PILLAR TO YOUR BASE")
													end
													break
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end)
end

function BaseManager.AssignPlot(player)
	local account = economy.States[player]
	for _, plot in ipairs(plots) do
		local ownerId = plot:GetAttribute("OwnerUserId") or 0
		if ownerId == 0 then
			plot:SetAttribute("OwnerUserId", player.UserId)
			local ownerSign = plot:FindFirstChild("OwnerSign")
			if ownerSign then
				local ownerGui = ownerSign:FindFirstChild("OwnerBillboard")
				if ownerGui then
					local ownerText = ownerGui:FindFirstChild("OwnerText")
					if ownerText then
						ownerText.Text = player.DisplayName .. "'S BAZAAR"
					end
				end
			end

			if account then
				account.plot = plot
			end

			local plotIdx = plot:GetAttribute("PlotIndex") or 1
			local angle = (plotIdx - 1) * (math.pi / 4)
			player:SetAttribute("PlotX", math.cos(angle) * 82)
			player:SetAttribute("PlotZ", math.sin(angle) * 82)
			return plot
		end
	end
	return nil
end

function BaseManager.OnPadTouched(plot, pad, hit)
	if pad:GetAttribute("Occupied") then
		return
	end

	local char = hit:FindFirstAncestorOfClass("Model")
	if not char then
		return
	end

	local player = Players:GetPlayerFromCharacter(char)
	if not player then
		return
	end

	local account = economy.States[player]
	if not account or account.plot ~= plot or not account.carried then
		return
	end

	local carried = account.carried
	account.carried = nil

	local model = carried.model
	model:SetAttribute("OwnerUserId", player.UserId)
	model:SetAttribute("Income", carried.income)
	model:PivotTo(CFrame.new(pad.Position + Vector3.new(0, 2.3, 0)))

	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end

	local accessory = model:FindFirstChild("Accessory")
	if accessory then
		local prompt = accessory:FindFirstChild("BrainrotPrompt")
		if prompt then
			prompt.ActionText = "Steal"
			prompt.Enabled = true
			prompt.Triggered:Connect(function(thief)
				BaseManager.Steal(thief, model)
			end)
		end
	end

	pad:SetAttribute("Occupied", true)
	carried.model = model
	carried.pad = pad
	table.insert(account.placed, carried)

	feedbackRemote:FireClient(player, "message", carried.name .. " placed! +$" .. carried.income .. "/s")
	economy.Sync(player)
end

function BaseManager.Steal(thief, model)
	local thiefAccount = economy.States[thief]
	if not thiefAccount or thiefAccount.carried then
		return
	end

	local ownerPlayer = nil
	local ownerId = model:GetAttribute("OwnerUserId") or 0
	for p, _ in pairs(economy.States) do
		if p.UserId == ownerId then
			ownerPlayer = p
			break
		end
	end

	if not ownerPlayer or ownerPlayer == thief then
		return
	end

	local ownerAccount = economy.States[ownerPlayer]
	if not ownerAccount or not ownerAccount.plot then
		return
	end

	local lockedUntil = ownerAccount.plot:GetAttribute("LockedUntil") or 0
	if lockedUntil > os.time() then
		feedbackRemote:FireClient(thief, "message", "THAT BASE IS LOCKED")
		return
	end

	local foundItem = nil
	local foundIndex = nil
	for idx, item in ipairs(ownerAccount.placed) do
		if item.model == model then
			foundItem = item
			foundIndex = idx
			break
		end
	end

	if not foundItem then
		return
	end

	table.remove(ownerAccount.placed, foundIndex)
	if foundItem.pad then
		foundItem.pad:SetAttribute("Occupied", false)
	end

	model:SetAttribute("OwnerUserId", 0)
	thiefAccount.carried = foundItem

	local accessory = model:FindFirstChild("Accessory")
	if accessory then
		local prompt = accessory:FindFirstChild("BrainrotPrompt")
		if prompt then
			prompt.Enabled = false
		end
	end

	local thiefRoot = getRoot(thief)
	if thiefRoot then
		local look = thiefRoot.CFrame.LookVector
		local yaw = math.atan2(-look.X, -look.Z)
		model:PivotTo(CFrame.new(thiefRoot.Position + Vector3.new(0, 4.3, 0)) * CFrame.Angles(0, yaw, 0))
	end

	feedbackRemote:FireClient(thief, "message", "STOLEN! RUN IT HOME")
	economy.Sync(ownerPlayer)
end

function BaseManager.IsPlayerSafe(player)
	local account = economy.States[player]
	if not account or not account.plot then
		return false
	end

	local root = getRoot(player)
	if not root then
		return false
	end

	local floor = account.plot:FindFirstChild("BaseFloor")
	if not floor then
		return false
	end

	return (root.Position - floor.Position).Magnitude < 22
end

function BaseManager.ClearPlayer(player)
	local account = economy.States[player]
	if not account then
		return
	end

	lastRescue[player] = nil
	lastWrongBase[player] = nil

	if account.carried and account.carried.model then
		account.carried.model:Destroy()
		account.carried = nil
	end

	for _, item in ipairs(account.placed) do
		if item.pad then
			item.pad:SetAttribute("Occupied", false)
		end
		if item.model then
			item.model:Destroy()
		end
	end
	account.placed = {}

	if account.plot then
		account.plot:SetAttribute("OwnerUserId", 0)
		account.plot:SetAttribute("LockedUntil", 0)
		local ownerSign = account.plot:FindFirstChild("OwnerSign")
		if ownerSign then
			local ownerGui = ownerSign:FindFirstChild("OwnerBillboard")
			if ownerGui then
				local ownerText = ownerGui:FindFirstChild("OwnerText")
				if ownerText then
					ownerText.Text = "OPEN PLOT"
				end
			end
		end
		account.plot = nil
	end
end

return BaseManager
