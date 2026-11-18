local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WorldBuilder = require(script:WaitForChild("WorldBuilder"))
local CharacterFactory = require(script:WaitForChild("CharacterFactory"))
local Economy = require(script:WaitForChild("Economy"))
local Bases = require(script:WaitForChild("BaseManager"))
local Spawner = require(script:WaitForChild("Spawner"))
local WaveEvent = require(script:WaitForChild("WaveEvent"))

-- Parent the folder after all event names are available to clients.
local remotes = Instance.new("Folder")
remotes.Name = "TsunamiEvents"
local events = {}
for _, name in ipairs({"Feedback", "Warning", "Impact", "Income", "Fusion"}) do
	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = remotes
	events[name] = remote
end
remotes.Parent = ReplicatedStorage

local Data = WorldBuilder.Data
local world = WorldBuilder.Build()
Economy.Init(Data, events)
Bases.Init(Data, Economy, CharacterFactory, events, world)

local function atPrompt(player, prompt)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return root and humanoid and humanoid.Health > 0 and (root.Position - prompt.Parent.Position).Magnitude <= 12
end

world.speedPrompt.Triggered:Connect(function(player)
	if atPrompt(player, world.speedPrompt) then Economy.BuySpeed(player) end
end)

world.rebirthPrompt.Triggered:Connect(function(player)
	local state = Economy.Players[player]
	if not state or not atPrompt(player, world.rebirthPrompt) then return end
	if state.cash < Data.RebirthCost then
		events.Feedback:FireClient(player, "You need $25,000 to rebirth")
		return
	end
	Bases.ClearCollection(player)
	state.cash = Data.StartCash
	state.rebirths += 1
	state.multiplier = 1 + state.rebirths * Data.RebirthMultiplierStep
	for index in ipairs(Data.Cast) do
		player:SetAttribute("Owned_" .. index, nil)
	end
	Economy.Sync(player)
	events.Feedback:FireClient(player, ("Rebirth complete · %.1fx income"):format(state.multiplier))
end)

local function onPlayer(player)
	if player.Parent ~= Players or Economy.Players[player] then return end
	Economy.AddPlayer(player)
	Bases.Assign(player)
	-- Players without a plot start at the lobby spawn.
	player.RespawnLocation = Bases.SpawnLocation(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		character:WaitForChild("HumanoidRootPart")
		if player.Character ~= character or not Economy.Players[player] then return end
		Economy.ApplySpeed(player)
		humanoid.Died:Connect(function()
			Bases.DropCarry(player)
			task.delay(Players.RespawnTime, function()
				if player.Parent == Players and player.Character == character then
					player:LoadCharacterAsync()
				end
			end)
		end)
	end)
	player:LoadCharacterAsync()
end

Players.PlayerRemoving:Connect(function(player)
	if not Economy.Players[player] then return end
	Bases.Release(player)
	Economy.Players[player] = nil
end)
Players.PlayerAdded:Connect(onPlayer)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayer, player)
end

Economy.Start()
Spawner.Start(Data, world, Economy, CharacterFactory, events)
WaveEvent.Start(world, Data.Wave, Economy, Bases, events)
