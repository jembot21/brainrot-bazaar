local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Data = require(Shared:WaitForChild("BrainrotData"))

local WorldBuilder = require(script:WaitForChild("WorldBuilder"))
local CharacterFactory = require(script:WaitForChild("CharacterFactory"))
local Economy = require(script:WaitForChild("Economy"))
local BaseManager = require(script:WaitForChild("BaseManager"))
local Spawner = require(script:WaitForChild("Spawner"))
local WaveEvent = require(script:WaitForChild("WaveEvent"))

-- Setup Remotes
local remotesFolder = ReplicatedStorage:FindFirstChild("BazaarRemotes")
if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "BazaarRemotes"
	remotesFolder.Parent = ReplicatedStorage
end

local function getOrCreateRemote(name)
	local remote = remotesFolder:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = remotesFolder
	end
	return remote
end

local waveRemote = getOrCreateRemote("WaveWarning")
local feedbackRemote = getOrCreateRemote("Feedback")
local rebirthRemote = getOrCreateRemote("Rebirth")

local events = {
	Wave = waveRemote,
	Feedback = feedbackRemote,
	Rebirth = rebirthRemote,
}

-- Build World and Boot Subsystems
local world = WorldBuilder.Build()
BaseManager.Init(Economy, CharacterFactory, events.Feedback, world)
Economy.StartIncomeTick()
Spawner.Init(Data, Economy, CharacterFactory, events, BaseManager, world.shrinePrompt)
WaveEvent.Init(events, Economy, BaseManager)

local function initializePlayer(player)
	Economy.InitPlayer(player)
	local plot = BaseManager.AssignPlot(player)
	if not plot then
		Economy.AddCash(player, 0)
	end

	player.CharacterAdded:Connect(function(character)
		local root = character:WaitForChild("HumanoidRootPart", 10)
		if root and plot then
			-- Calculate world spawn location corresponding to the assigned plot index on the outer ring
			local plotIndex = plot:GetAttribute("PlotIndex") or 1
			local angle = (plotIndex - 1) * (math.pi / 4)
			character:PivotTo(CFrame.new(math.cos(angle) * 82, 11, math.sin(angle) * 82))
		end

		local humanoid = character:WaitForChild("Humanoid", 10)
		if humanoid then
			humanoid.Died:Connect(function()
				task.wait(2)
				if player:IsDescendantOf(Players) then
					pcall(function()
						player:LoadCharacter()
					end)
				end
			end)
		end
	end)

	pcall(function()
		player:LoadCharacter()
	end)
end

Players.PlayerAdded:Connect(initializePlayer)

Players.PlayerRemoving:Connect(function(player)
	BaseManager.ClearPlayer(player)
	Economy.RemovePlayer(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(initializePlayer, player)
end
