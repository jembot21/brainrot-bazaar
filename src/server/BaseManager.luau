local Players = game:GetService("Players")

local BaseManager = {}

local economy = nil
local feedbackRemote = nil
local plots = {}
local lastRescue = {}
local lastWrongBaseMsg = {}

function BaseManager.Init(economyModule, characterFactory, feedbackRemoteEvent, worldData)
	economy = economyModule
	feedbackRemote = feedbackRemoteEvent
	plots = worldData.plots

	for _, plot in plots do
		local ownerSign = plot:FindFirstChild("OwnerSign")
		local lockPrompt = ownerSign and ownerSign:FindFirstChild("BaseLockPrompt")
		if lockPrompt then
			lockPrompt.Triggered:Connect(function(player)
				local account = economy.States[player]
				if not account or account.plot ~= plot then
					return
				end

				local lockedUntil = plot:GetAttribute("LockedUntil") or 0
				local now = os.time()
				if now < lockedUntil then
					plot:SetAttribute("LockedUntil", 0)
					feedbackRemote:FireClient(player, "message", "BASE UNLOCKED")
				else
					plot:SetAttribute("LockedUntil", now + 60)
					feedbackRemote:FireClient(player, "message", "BASE LOCKED FOR 60 SECONDS")
				end
			end)
		end

		local padsFolder = plot:FindFirstChild("Pads")
		if padsFolder then
			for _, pad in padsFolder:GetChildren() do
				pad.Touched:Connect(function(hit)
					BaseManager.OnPadTouched(plot, pad, hit)
				end)
			end
		end
	end

	task.spawn(function()
		while true do
			task.wait(0.15)

			for _, plot in plots do
				local beacon = plot:FindFirstChild("HomeBeacon")
				if beacon then
					beacon.Transparency = 1
				end
			end

			for player, account in economy.States do
				if account.plot then
					local beacon = account.plot:FindFirstChild("HomeBeacon")
					if beacon then
						beacon.Transparency = account.carried and 0.25 or 0.55
					end
				end

				local char = player.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				if root then
					-- Fall rescue: Position.Y < -2 throttled to 2s
					if root.Position.Y < -2 then
						local now = os.clock()
						if (now - (lastRescue[player] or 0)) >= 2 then
							lastRescue[player] = now
							local px = player:GetAttribute("PlotX")
							local pz = player:GetAttribute("PlotZ")
							if not px or not pz then
								if account.plot then
									local pIdx = account.plot:GetAttribute("PlotIndex") or 1
									local angle = (pIdx - 1) * (math.pi / 4)
									px = math.cos(angle) * 82
									pz = math.sin(angle) * 82
								else
									px, pz = 0, 0
								end
							end
							char:PivotTo(CFrame.new(px, 11, pz))
							feedbackRemote:FireClient(player, "message", "BACK TO YOUR BASE!")
						end
					end

					-- Auto-place
					if account.carried and account.plot then
						local padsFolder = account.plot:FindFirstChild("Pads")
						local padsList = padsFolder and padsFolder:GetChildren() or {}
						local nearestPad = nil
						local nearestDist = math.huge

						for _, pad in padsList do
							if not pad:GetAttribute("Occupied") then
								local dx = pad.Position.X - root.Position.X
								local dz = pad.Position.Z - root.Position.Z
								local dy = math.abs(pad.Position.Y - root.Position.Y)
								local xzDist = math.sqrt(dx * dx + dz * dz)
								if xzDist <= 8.5 and dy <= 12 then
									if xzDist < nearestDist then
										nearestDist = xzDist
										nearestPad = pad
									end
								end
							end
						end

						if nearestPad then
							BaseManager.OnPadTouched(account.plot, nearestPad, nil, player)
						else
							local fallbackPad = nil
							for _, pad in padsList do
								if not pad:GetAttribute("Occupied") then
									local dx = pad.Position.X - root.Position.X
									local dz = pad.Position.Z - root.Position.Z
									local dy = math.abs(pad.Position.Y - root.Position.Y)
									local xzDist = math.sqrt(dx * dx + dz * dz)
									if xzDist <= 6.5 and dy <= 5 then
										fallbackPad = pad
										break
									end
								end
							end

							if fallbackPad then
								BaseManager.OnPadTouched(account.plot, fallbackPad, nil, player)
							else
								local nearOtherPad = false
								for _, otherPlot in plots do
									if otherPlot ~= account.plot then
										local otherPadsFolder = otherPlot:FindFirstChild("Pads")
										local otherPads = otherPadsFolder and otherPadsFolder:GetChildren() or {}
										for _, opad in otherPads do
											if not opad:GetAttribute("Occupied") then
												local dx = opad.Position.X - root.Position.X
												local dz = opad.Position.Z - root.Position.Z
												local xzDist = math.sqrt(dx * dx + dz * dz)
												if xzDist <= 6.5 then
													nearOtherPad = true
													break
												end
											end
										end
										if nearOtherPad then
											break
										end
									end
								end

								if nearOtherPad then
									local now = os.clock()
									if (now - (lastWrongBaseMsg[player] or 0)) >= 5 then
										lastWrongBaseMsg[player] = now
										feedbackRemote:FireClient(player, "message", "WRONG BASE! FOLLOW THE LIGHT PILLAR TO YOUR BASE")
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
	for _, plot in plots do
		if (plot:GetAttribute("OwnerUserId") or 0) == 0 then
			plot:SetAttribute("OwnerUserId", player.UserId)
			local ownerSign = plot:FindFirstChild("OwnerSign")
			local billboard = ownerSign and ownerSign:FindFirstChild("OwnerBillboard")
			local text = billboard and billboard:FindFirstChild("OwnerText")
			if text then
				text.Text = player.DisplayName .. "'S BAZAAR"
			end

			local account = economy.States[player]
			if account then
				account.plot = plot
			end

			local pIdx = plot:GetAttribute("PlotIndex") or 1
			local angle = (pIdx - 1) * (math.pi / 4)
			player:SetAttribute("PlotX", math.cos(angle) * 82)
			player:SetAttribute("PlotZ", math.sin(angle) * 82)
			return plot
		end
	end
	return nil
end

function BaseManager.OnPadTouched(plot, pad, hit, directPlayer)
	if pad:GetAttribute("Occupied") == true then
		return
	end

	local player = directPlayer
	if not player and hit then
		local char = hit:FindFirstAncestorOfClass("Model")
		if char then
			player = Players:GetPlayerFromCharacter(char)
		end
	end

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
	if not model or not model.Parent then
		return
	end

	model:SetAttribute("OwnerUserId", player.UserId)
	model:SetAttribute("Income", carried.income)
	model:PivotTo(CFrame.new(pad.Position + Vector3.new(0, 2.3, 0)))

	for _, desc in model:GetDescendants() do
		if desc:IsA("BasePart") then
			desc.Anchored = true
		end
	end

	local accessory = model:FindFirstChild("Accessory")
	local prompt = accessory and accessory:FindFirstChild("BrainrotPrompt")
	if prompt then
		prompt.ActionText = "Steal"
		prompt.Enabled = true
		if carried.stealConn then
			carried.stealConn:Disconnect()
		end
		carried.stealConn = prompt.Triggered:Connect(function(thief)
			BaseManager.Steal(thief, model)
		end)
	end

	pad:SetAttribute("Occupied", true)
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

	local ownerId = model:GetAttribute("OwnerUserId") or 0
	local ownerPlayer = nil
	local ownerAccount = nil

	for p, acc in economy.States do
		if p.UserId == ownerId then
			ownerPlayer = p
			ownerAccount = acc
			break
		end
	end

	if not ownerPlayer or ownerPlayer == thief or not ownerAccount then
		return
	end

	local lockedUntil = ownerAccount.plot and ownerAccount.plot:GetAttribute("LockedUntil") or 0
	if lockedUntil > os.time() then
		feedbackRemote:FireClient(thief, "message", "THAT BASE IS LOCKED")
		return
	end

	local itemIndex = nil
	local item = nil
	for idx, placedItem in ownerAccount.placed do
		if placedItem.model == model then
			itemIndex = idx
			item = placedItem
			break
		end
	end

	if not item then
		return
	end

	table.remove(ownerAccount.placed, itemIndex)
	if item.pad then
		item.pad:SetAttribute("Occupied", false)
		item.pad = nil
	end

	model:SetAttribute("OwnerUserId", 0)
	thiefAccount.carried = item

	local accessory = model:FindFirstChild("Accessory")
	local prompt = accessory and accessory:FindFirstChild("BrainrotPrompt")
	if prompt then
		prompt.Enabled = false
	end

	local thiefChar = thief.Character
	local thiefRoot = thiefChar and thiefChar:FindFirstChild("HumanoidRootPart")
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

	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
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
	lastRescue[player] = nil
	lastWrongBaseMsg[player] = nil

	local account = economy.States[player]
	if account then
		if account.carried and account.carried.model then
			account.carried.model:Destroy()
			account.carried = nil
		end

		if account.placed then
			for _, item in account.placed do
				if item.model then
					item.model:Destroy()
				end
				if item.pad then
					item.pad:SetAttribute("Occupied", false)
				end
			end
			account.placed = {}
		end

		if account.plot then
			account.plot:SetAttribute("OwnerUserId", 0)
			account.plot:SetAttribute("LockedUntil", 0)
			local ownerSign = account.plot:FindFirstChild("OwnerSign")
			local billboard = ownerSign and ownerSign:FindFirstChild("OwnerBillboard")
			local text = billboard and billboard:FindFirstChild("OwnerText")
			if text then
				text.Text = "OPEN PLOT"
			end
			account.plot = nil
		end
	end
end

return BaseManager
