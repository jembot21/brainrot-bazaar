local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local WaveEvent = {}

local function setPhase(world, events, phase, duration, height, cycle)
	world.folder:SetAttribute("WaveEndsAt", workspace:GetServerTimeNow() + duration)
	world.folder:SetAttribute("WaveHeight", height)
	world.folder:SetAttribute("WaveNumber", cycle)
	world.folder:SetAttribute("WavePhase", phase)
	if phase == "WARNING" then
		events.Warning:FireAllClients("TSUNAMI INCOMING", duration, height)
	elseif phase == "WAVE" then
		events.Impact:FireAllClients(duration, height)
	end
end

local function isAboveWave(character, humanoid, root, height)
	if root.Position.Y <= height then return false end
	if humanoid.FloorMaterial == Enum.Material.Air then return false end
	local filter = RaycastParams.new()
	filter.FilterDescendantsInstances = {character}
	filter.RespectCanCollide = true
	local ground = workspace:Raycast(root.Position, Vector3.new(0, -8, 0), filter)
	return ground and ground.Position.Y > height
end

local function sweep(world, config, height, economy, bases, events)
	local wall = Instance.new("Part")
	wall.Name = "TsunamiWall"
	wall.Size = Vector3.new(8, height, world.waveWidth)
	wall.Anchored = true
	wall.CanCollide = false
	wall.CanTouch = false
	wall.CanQuery = false
	wall.Material = Enum.Material.Glass
	wall.Color = Color3.fromRGB(48, 188, 255)
	wall.Transparency = 0.32

	local crest = Instance.new("Part")
	crest.Name = "FoamCrest"
	crest.Size = Vector3.new(9, 0.75, world.waveWidth)
	crest.Anchored = true
	crest.CanCollide = false
	crest.CanTouch = false
	crest.CanQuery = false
	crest.Material = Enum.Material.Neon
	crest.Color = Color3.fromRGB(187, 248, 255)
	crest.Parent = wall

	local function moveWall(x)
		wall.Position = Vector3.new(x, height / 2, 0)
		crest.Position = Vector3.new(x, height, 0)
	end
	moveWall(world.waveStart)
	wall.Parent = world.folder

	local hit = {}
	local elapsed = 0
	local previousX = world.waveStart
	-- Check the swept span so a long server frame cannot skip over a player.
	while elapsed < config.WaveCrossSeconds do
		elapsed += RunService.Heartbeat:Wait()
		local progress = math.min(1, elapsed / config.WaveCrossSeconds)
		local x = world.waveStart + (world.waveEnd - world.waveStart) * progress
		moveWall(x)
		for _, player in ipairs(Players:GetPlayers()) do
			local state = economy.Players[player]
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if state and root and humanoid and humanoid.Health > 0 and not hit[player]
				and root.Position.X >= previousX - wall.Size.X / 2 and root.Position.X <= x + wall.Size.X / 2
				and math.abs(root.Position.Z) <= world.waveWidth / 2
				and not bases.IsSafe(player, root.Position) and not isAboveWave(character, humanoid, root, height) then
				hit[player] = true
				local lostCarry = bases.DropCarry(player)
				local penalty = math.floor(state.cash * config.WaveCashPenalty * 100 + 0.5) / 100
				state.cash -= penalty
				economy.Sync(player)
				character:PivotTo(bases.Spawn(player))
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
				events.Feedback:FireClient(player, ("Washed out%s · -$%.2f"):format(lostCarry and " and lost your brainrot" or "", penalty))
			end
		end
		previousX = x
	end
	wall:Destroy()
end

function WaveEvent.Start(world, config, economy, bases, events)
	task.spawn(function()
		local cycle = 0
		while true do
			cycle += 1
			local height = config.WaveHeights[math.min(cycle, #config.WaveHeights)]
			setPhase(world, events, "CALM", config.CalmSeconds, height, cycle)
			task.wait(config.CalmSeconds)
			setPhase(world, events, "WARNING", config.WarningSeconds, height, cycle)
			task.wait(config.WarningSeconds)
			setPhase(world, events, "WAVE", config.WaveCrossSeconds, height, cycle)
			sweep(world, config, height, economy, bases, events)
		end
	end)
end

return WaveEvent
