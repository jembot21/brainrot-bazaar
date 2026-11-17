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

local remotes = ReplicatedStorage:FindFirstChild("BazaarRemotes") or Instance.new("Folder")
remotes.Name = "BazaarRemotes"
remotes.Parent = ReplicatedStorage
local function getRemote(name)
	local remote = remotes:FindFirstChild(name) or Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = remotes
	return remote
end
local events = {
	Wave = getRemote("WaveWarning"),
	Feedback = getRemote("Feedback"),
	Rebirth = getRemote("Rebirth"),
}

local world = WorldBuilder.Build()
BaseManager.Init(Economy, CharacterFactory, events.Feedback, world)
Economy.StartIncomeTick()
Spawner.Init(Data, Economy, CharacterFactory, events, BaseManager, world.shrinePrompt)
WaveEvent.Init(events, Economy, BaseManager)

local function onPlayerAdded(player)
	Economy.InitPlayer(player)
	local plot = BaseManager.AssignPlot(player)
	if not plot then
		Economy.AddCash(player, 0)
	end
	player.CharacterAdded:Connect(function(character)
		local root = character:WaitForChild("HumanoidRootPart", 10)
		if root and plot then
			local angle = (plot:GetAttribute("PlotIndex") - 1) * math.pi / 4
			character:PivotTo(CFrame.new(math.cos(angle) * 82, 11, math.sin(angle) * 82))
		end
	end)
	player:LoadCharacter()
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
	BaseManager.ClearPlayer(player)
	Economy.RemovePlayer(player)
end)
for _, player in ipairs(Players:GetPlayers()) do task.spawn(onPlayerAdded, player) end
