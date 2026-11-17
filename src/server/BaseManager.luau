local BaseManager = {}
local RunService = game:GetService("RunService")
local economy
local feedback
local plots

function BaseManager.Init(economyModule, _characterFactory, remote, worldData)
	economy, feedback, plots = economyModule, remote, worldData.plots
	for _, plot in ipairs(plots) do
		local sign = plot:FindFirstChild("OwnerSign")
		local prompt = sign and sign:FindFirstChild("BaseLockPrompt")
		if prompt then
			prompt.Triggered:Connect(function(player)
				local state = economy.States[player]
				if not state or state.plot ~= plot then return end
				local lockedUntil = plot:GetAttribute("LockedUntil") or 0
				if os.time() < lockedUntil then
					plot:SetAttribute("LockedUntil", 0)
					feedback:FireClient(player, "message", "BASE UNLOCKED")
				else
					plot:SetAttribute("LockedUntil", os.time() + 60)
					feedback:FireClient(player, "message", "BASE LOCKED FOR 60 SECONDS")
				end
			end)
		end
		for _, pad in ipairs(plot.Pads:GetChildren()) do
			pad.Touched:Connect(function(hit) BaseManager.OnPadTouched(plot, pad, hit) end)
		end
	end
	local lastWrongBaseWarning = {}
	task.spawn(function()
		while true do
			task.wait(0.15)
			for _, plot in ipairs(plots) do
				local beacon = plot:FindFirstChild("HomeBeacon")
				if beacon then beacon.Transparency = 1 end
			end
			for player, state in pairs(economy.States) do
				local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if state.carried and state.plot and root then
					local beacon = state.plot:FindFirstChild("HomeBeacon")
					if beacon then beacon.Transparency = 0.3 end
					local placed = false
					for _, pad in ipairs(state.plot.Pads:GetChildren()) do
						if not pad:GetAttribute("Occupied") then
							local delta = root.Position - pad.Position
							if Vector2.new(delta.X, delta.Z).Magnitude <= 6.5 and math.abs(delta.Y) <= 5 then
								BaseManager.OnPadTouched(state.plot, pad, root)
								placed = true
								break
							end
						end
					end
					if not placed then
						local now = os.clock()
						for _, otherPlot in ipairs(plots) do
							if otherPlot ~= state.plot then
								for _, pad in ipairs(otherPlot.Pads:GetChildren()) do
									if not pad:GetAttribute("Occupied") then
										local delta = root.Position - pad.Position
										if Vector2.new(delta.X, delta.Z).Magnitude <= 6.5 and now - (lastWrongBaseWarning[player] or -math.huge) >= 5 then
											feedback:FireClient(player, "message", "WRONG BASE! FOLLOW THE LIGHT PILLAR TO YOUR BASE")
											lastWrongBaseWarning[player] = now
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
	for _, plot in ipairs(plots) do
		if plot:GetAttribute("OwnerUserId") == 0 then
			plot:SetAttribute("OwnerUserId", player.UserId)
			plot.OwnerSign.OwnerBillboard.OwnerText.Text = player.DisplayName .. "'S BAZAAR"
			local state = economy.States[player]
			state.plot = plot
			local angle = (plot:GetAttribute("PlotIndex") - 1) * math.pi / 4
			player:SetAttribute("PlotX", math.cos(angle) * 82)
			player:SetAttribute("PlotZ", math.sin(angle) * 82)
			return plot
		end
	end
	return nil
end

function BaseManager.OnPadTouched(plot, pad, hit)
	if pad:GetAttribute("Occupied") then return end
	local character = hit:FindFirstAncestorOfClass("Model")
	local player = character and game:GetService("Players"):GetPlayerFromCharacter(character)
	local state = player and economy.States[player]
	if not state or state.plot ~= plot or not state.carried then return end
	local carried = state.carried
	local model = carried.model
	state.carried = nil
	model:SetAttribute("OwnerUserId", player.UserId)
	model:SetAttribute("Income", carried.income)
	model:PivotTo(CFrame.new(pad.Position + Vector3.new(0, 2.3, 0)))
	for _, object in ipairs(model:GetDescendants()) do
		if object:IsA("BasePart") then object.Anchored = true end
	end
	local accessory = model:FindFirstChild("Accessory")
	local prompt = accessory and accessory:FindFirstChild("BrainrotPrompt")
	if prompt then
		prompt.ActionText = "Steal"
		prompt.Enabled = true
		prompt.Triggered:Connect(function(thief) BaseManager.Steal(thief, model) end)
	end
	pad:SetAttribute("Occupied", true)
	carried.model = model
	carried.pad = pad
	table.insert(state.placed, carried)
	feedback:FireClient(player, "message", carried.name .. " placed! +$" .. carried.income .. "/s")
	economy.Sync(player)
end

function BaseManager.Steal(player, model)
	local state = economy.States[player]
	if not state or state.carried then return end
	local ownerId = model:GetAttribute("OwnerUserId")
	local owner
	for candidate in pairs(economy.States) do
		if candidate.UserId == ownerId then owner = candidate; break end
	end
	if not owner or owner == player then return end
	local ownerState = economy.States[owner]
	if not ownerState then return end
	if ownerState.plot and os.time() < (ownerState.plot:GetAttribute("LockedUntil") or 0) then
		feedback:FireClient(player, "message", "THAT BASE IS LOCKED")
		return
	end
	for index, item in ipairs(ownerState.placed) do
		if item.model == model then
			table.remove(ownerState.placed, index)
			item.pad:SetAttribute("Occupied", false)
			model:SetAttribute("OwnerUserId", 0)
			state.carried = item
			local accessory = model:FindFirstChild("Accessory")
			local prompt = accessory and accessory:FindFirstChild("BrainrotPrompt")
			if prompt then prompt.Enabled = false end
			model:PivotTo(player.Character:GetPivot() * CFrame.new(0, 3, -5))
			feedback:FireClient(player, "message", "STOLEN! RUN IT HOME")
			economy.Sync(owner)
			return
		end
	end
end

function BaseManager.IsPlayerSafe(player)
	local state = economy.States[player]
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not state or not state.plot or not root then return false end
	local floor = state.plot:FindFirstChild("BaseFloor")
	return floor ~= nil and (root.Position - floor.Position).Magnitude < 22
end

function BaseManager.ClearPlayer(player)
	local state = economy.States[player]
	if not state then return end
	if state.carried then state.carried.model:Destroy() end
	if state.plot then
		for _, item in ipairs(state.placed) do item.model:Destroy(); item.pad:SetAttribute("Occupied", false) end
		state.plot:SetAttribute("OwnerUserId", 0)
		state.plot:SetAttribute("LockedUntil", 0)
		state.plot.OwnerSign.OwnerBillboard.OwnerText.Text = "OPEN PLOT"
	end
end

return BaseManager
