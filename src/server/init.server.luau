local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WorldBuilder = require(script.Parent.WorldBuilder)
local Economy = require(script.Parent.Economy)
local BaseManager = require(script.Parent.BaseManager)
local Spawner = require(script.Parent.Spawner)
local WaveEvent = require(script.Parent.WaveEvent)

local remoteFolder = ReplicatedStorage:FindFirstChild("BrainrotRemotes")
if not remoteFolder then
	remoteFolder = Instance.new("Folder")
	remoteFolder.Name = "BrainrotRemotes"
	remoteFolder.Parent = ReplicatedStorage
end

local remoteNames = {
	"CashChanged", "BuySpeed", "Rebirth", "Toast", "WaveStatus", "WaveWarning",
	"Caught", "PurchaseSparkle", "CameraShake",
}
local remotes = {}
for _, name in ipairs(remoteNames) do
	local remote = remoteFolder:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = remoteFolder
	end
	remotes[name] = remote
end

local world = WorldBuilder.Build()
Economy.Start(remotes, BaseManager.GetPlaced)
BaseManager.Start(world, Economy, remotes)
Spawner.Start(world, Economy, BaseManager, remotes)
WaveEvent.Start(BaseManager, Economy, remotes)

print("Brainrot Tsunami Escape services started")
