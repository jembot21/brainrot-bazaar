-- Base assignments associate players with the plots built by WorldBuilder.
local Players = game:GetService("Players")

local Bases = {Assigned = {}}

local function inRange(player, position, range)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return root and humanoid and humanoid.Health > 0 and (root.Position - position).Magnitude <= range
end

local function placedAction(plot)
	return plot.lockUntil > time() and "Sell · Base Locked" or "Sell / Steal"
end

local function updateSign(plot)
	local title = "OPEN PLOT"
	if plot.owner then
		local status = plot.lockUntil > time() and "LOCKED" or "OPEN"
		title = plot.owner.DisplayName .. "\n" .. status
		for _, item in pairs(Bases.Economy.Players[plot.owner].placed) do
			item.prompt.ActionText = placedAction(plot)
		end
	end
	for _, surface in ipairs(plot.board:GetChildren()) do
		if surface:IsA("SurfaceGui") then
			surface:FindFirstChildOfClass("TextLabel").Text = title
		end
	end
end

function Bases.Init(data, economy, factory, events, world)
	Bases.Data = data
	Bases.Economy = economy
	Bases.Factory = factory
	Bases.Events = events
	Bases.World = world
	Bases.ByRarity = {}
	for _, rarity in ipairs(data.RarityOrder) do
		Bases.ByRarity[rarity] = {}
	end
	for _, definition in ipairs(data.Cast) do
		table.insert(Bases.ByRarity[definition.rarity], definition)
	end
	for _, plot in ipairs(world.plots) do
		plot.lockUntil = 0
		plot.lockPrompt.Enabled = false
		plot.lockPrompt.Triggered:Connect(function(player)
			if player ~= plot.owner or not inRange(player, plot.board.Position, 12) then return end
			plot.lockUntil = plot.lockUntil > time() and 0 or time() + data.BaseLockSeconds
			local expires = plot.lockUntil
			updateSign(plot)
			events.Feedback:FireClient(player, expires == 0 and "Base unlocked" or ("Base locked for %d seconds"):format(data.BaseLockSeconds))
			if expires > 0 then
				task.delay(data.BaseLockSeconds, function()
					-- An older timer must leave a newer lock in place.
					if plot.lockUntil == expires then
						plot.lockUntil = 0
						updateSign(plot)
					end
				end)
			end
		end)
		for _, pad in ipairs(plot.pads) do
			pad.Touched:Connect(function(hit)
				local owner = plot.owner
				if owner and owner.Character and hit:IsDescendantOf(owner.Character) and inRange(owner, pad.Position, 7) then
					Bases.Place(owner, pad)
				end
			end)
		end
	end
end

function Bases.Assign(player)
	if Bases.Assigned[player] then return end
	for _, plot in ipairs(Bases.World.plots) do
		if not plot.owner then
			plot.owner = player
			Bases.Assigned[player] = plot
			player.RespawnLocation = plot.spawn
			plot.lockPrompt.Enabled = true
			updateSign(plot)
			return
		end
	end
end

function Bases.SpawnLocation(player)
	local plot = Bases.Assigned[player]
	return plot and plot.spawn or Bases.World.lobbySpawn
end

function Bases.Spawn(player)
	return Bases.SpawnLocation(player).CFrame * CFrame.new(0, 4, 0)
end

function Bases.IsSafe(player, position)
	local plot = Bases.Assigned[player]
	if not plot then return false end
	local offset = plot.floor.CFrame:PointToObjectSpace(position)
	return math.abs(offset.X) <= plot.floor.Size.X / 2
		and math.abs(offset.Z) <= plot.floor.Size.Z / 2
		and offset.Y >= 0 and offset.Y <= 24
end

function Bases.Register(player, pad, item)
	local state = Bases.Economy.Players[player]
	state.placed[pad] = item
	player:SetAttribute("Owned_" .. table.find(Bases.Data.Cast, item.definition), true)
	item.model:PivotTo(pad.CFrame * CFrame.new(0, 2.3, 0) * CFrame.Angles(0, math.pi / 2, 0))
	item.prompt.ActionText = placedAction(Bases.Assigned[player])
	item.prompt.ObjectText = item.definition.name
	item.prompt.Enabled = true
	item.connection = item.prompt.Triggered:Connect(function(visitor)
		if state.placed[pad] ~= item or not inRange(visitor, item.prompt.Parent.Position, 13) then return end
		local visitorState = Bases.Economy.Players[visitor]
		if not visitorState then return end
		if visitor == player then
			state.placed[pad] = nil
			state.cash += item.definition.price * Bases.Data.SellReturn
			item.model:Destroy()
			Bases.Events.Feedback:FireClient(player, "Sold " .. item.definition.name)
		elseif Bases.Assigned[player].lockUntil > time() then
			Bases.Events.Feedback:FireClient(visitor, "This base is locked")
			return
		elseif visitorState.carry or not Bases.Assigned[visitor] then
			return
		else
			state.placed[pad] = nil
			item.connection:Disconnect()
			item.connection = nil
			item.prompt.Enabled = false
			visitorState.carry = item
			Bases.Events.Feedback:FireClient(visitor, "Stolen! Get back to your base")
			Bases.Events.Feedback:FireClient(player, item.definition.name .. " was stolen!")
		end
		Bases.Economy.Sync(player)
	end)
end

function Bases.Fuse(player, definition)
	local state = Bases.Economy.Players[player]
	local pads = Bases.Assigned[player].pads
	local count = Bases.Data.Fusion.FuseCount
	while true do
		-- Pad order determines which slot receives the fused model.
		local matches = {}
		local bestMutation
		for _, pad in ipairs(pads) do
			local item = state.placed[pad]
			if item and item.definition == definition then
				table.insert(matches, pad)
				if item.mutation and (not bestMutation or item.mutation.multiplier > bestMutation.multiplier) then
					bestMutation = item.mutation
				end
				if #matches == count then break end
			end
		end
		if #matches < count then return end

		local order = Bases.Data.RarityOrder
		local nextRarity = order[table.find(order, definition.rarity) + 1]
		if nextRarity then
			local rank = table.find(Bases.ByRarity[definition.rarity], definition)
			local nextSpecies = Bases.ByRarity[nextRarity]
			definition = nextSpecies[rank] or nextSpecies[1]
		end
		for _, pad in ipairs(matches) do
			state.placed[pad].model:Destroy()
			state.placed[pad] = nil
		end
		local fused = Bases.Factory.Create(definition, bestMutation)
		fused.model.Parent = Bases.World.folder
		Bases.Register(player, matches[1], fused)
		Bases.Events.Fusion:FireClient(player, definition.name, bestMutation and bestMutation.name or "")
	end
end

function Bases.Place(player, pad)
	local state = Bases.Economy.Players[player]
	if not state or not state.carry or state.placed[pad] then return end
	local item = state.carry
	state.carry = nil
	Bases.Register(player, pad, item)
	Bases.Fuse(player, item.definition)
	Bases.Economy.Sync(player)
	Bases.Events.Feedback:FireClient(player, "Placed " .. item.definition.name)
end

function Bases.DropCarry(player)
	local state = Bases.Economy.Players[player]
	if state and state.carry then
		state.carry.model:Destroy()
		state.carry = nil
		return true
	end
	return false
end

function Bases.ClearCollection(player)
	Bases.DropCarry(player)
	local state = Bases.Economy.Players[player]
	for _, item in pairs(state.placed) do
		item.model:Destroy()
	end
	table.clear(state.placed)
end

function Bases.Release(player)
	Bases.ClearCollection(player)
	local plot = Bases.Assigned[player]
	if not plot then return end
	Bases.Assigned[player] = nil
	plot.owner = nil
	plot.lockUntil = 0
	plot.lockPrompt.Enabled = false
	updateSign(plot)
	for _, waiting in ipairs(Players:GetPlayers()) do
		if waiting ~= player and Bases.Economy.Players[waiting] and not Bases.Assigned[waiting] then
			Bases.Assign(waiting)
			break
		end
	end
end

return Bases
