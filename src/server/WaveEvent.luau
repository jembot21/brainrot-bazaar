local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Data = require(game:GetService("ReplicatedStorage").Shared.BrainrotData)

local WaveEvent = {}
local baseManager
local economy
local remotes
local currentPhase = "CALM"
local currentHeight = Data.WaveHeights[1]
local phaseEndsAt = 0

local function heightForCycle(cycle)
	local schedule = Data.WaveHeights
	return schedule[math.min(cycle, #schedule)]
end

local function announce(phase, duration, height)
	currentPhase = phase
	currentHeight = height
	phaseEndsAt = os.clock() + duration
	if remotes.WaveStatus then
		remotes.WaveStatus:FireAllClients(phase, duration, height)
	end
end

local function makeWave(height)
	local wave = Instance.new("Part")
	wave.Name = "TsunamiWall"
	wave.Size = Vector3.new(270, height, 8)
	wave.Position = Vector3.new(0, 2 + height / 2, -145)
	wave.Anchored = true
	wave.CanCollide = false
	wave.Material = Enum.Material.Neon
	wave.Color = Color3.fromRGB(47, 190, 225)
	wave.Transparency = 0.32
	wave.Parent = workspace:FindFirstChild("BrainrotIsland") or workspace
	local light = Instance.new("PointLight")
	light.Color = wave.Color
	light.Brightness = 1.3
	light.Range = 24
	light.Parent = wave
	return wave
end

local function sweep(height)
	local wave = makeWave(height)
	announce("SWEEP", Data.WavePhases.Sweep, height)
	local startZ = -145
	local endZ = 145
	local previousZ = startZ
	local started = os.clock()
	while os.clock() - started < Data.WavePhases.Sweep do
		local alpha = math.clamp((os.clock() - started) / Data.WavePhases.Sweep, 0, 1)
		local currentZ = startZ + (endZ - startZ) * alpha
		wave.Position = Vector3.new(0, 2 + height / 2, currentZ)
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if root and not baseManager.IsInOwnBase(player, root.Position) then
				local crossed = root.Position.Z >= previousZ and root.Position.Z <= currentZ
				local belowWave = root.Position.Y <= height + 2
				if crossed and belowWave then
					baseManager.ClearCarry(player)
					economy.ApplyCaughtPenalty(player)
				end
			end
		end
		previousZ = currentZ
		RunService.Heartbeat:Wait()
	end
	wave:Destroy()
end

function WaveEvent.Start(bases, economyService, remoteFolder)
	baseManager = bases
	economy = economyService
	remotes = remoteFolder
	Players.PlayerAdded:Connect(function(player)
		task.delay(1, function()
			if player.Parent == Players and remotes.WaveStatus then
				local remaining = math.max(0, phaseEndsAt - os.clock())
				remotes.WaveStatus:FireClient(player, currentPhase, remaining, currentHeight)
			end
		end)
	end)
	task.spawn(function()
		local cycle = 0
		while true do
			cycle += 1
			local height = heightForCycle(cycle)
			announce("CALM", Data.WavePhases.Calm, height)
			task.wait(Data.WavePhases.Calm)
			announce("WARNING", Data.WavePhases.Warning, height)
			if remotes.WaveWarning then remotes.WaveWarning:FireAllClients(height) end
			task.wait(math.max(0, Data.WavePhases.Warning - 2))
			if remotes.CameraShake then remotes.CameraShake:FireAllClients(1.5, 0.45) end
			task.wait(math.min(2, Data.WavePhases.Warning))
			sweep(height)
		end
	end)
end

return WaveEvent
