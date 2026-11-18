local RunService = game:GetService("RunService")
local Spawner = {}

local spawnPoint = Vector3.new(-74, 9.6, 0)
local beltFacing = CFrame.Angles(0, -math.pi / 2, 0)
local beltEnd = -23
local beltSpeed = 3.1
local spawnInterval = 2.5
local random = Random.new()

-- Choose a rarity by weight, then choose uniformly among its species.
local function rollSpecies(data)
	local roll = random:NextNumber(0, 100)
	for _, rarity in ipairs(data.RarityOrder) do
		roll -= data.Rarities[rarity].weight
		if roll < 0 then
			local choices = {}
			for _, definition in ipairs(data.Cast) do
				if definition.rarity == rarity then
					table.insert(choices, definition)
				end
			end
			return choices[random:NextInteger(1, #choices)]
		end
	end
end

local function rollMutation(data)
	local roll = random:NextNumber()
	for _, mutation in ipairs(data.Mutations) do
		roll -= mutation.chance
		if roll < 0 then return mutation end
	end
	return nil
end

function Spawner.Start(data, world, economy, factory, events)
	local marching = {}

	local function spawnBrainrot()
		local definition = rollSpecies(data)
		local item = factory.Create(definition, rollMutation(data))
		item.prompt.ActionText = ("Catch · $%d"):format(definition.price)
		item.model:PivotTo(CFrame.new(spawnPoint) * beltFacing)
		item.model.Parent = world.folder
		marching[item] = spawnPoint.X
		item.connection = item.prompt.Triggered:Connect(function(player)
			local state = economy.Players[player]
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if not marching[item] or not state or not root or not humanoid or humanoid.Health <= 0
				or (root.Position - item.prompt.Parent.Position).Magnitude > 13 then return end
			if not player.RespawnLocation or player.RespawnLocation == world.lobbySpawn then
				events.Feedback:FireClient(player, "All bases are occupied. A plot will open when someone leaves.")
			elseif state.carry then
				events.Feedback:FireClient(player, "Place the brainrot you're carrying first")
			elseif economy.Spend(player, definition.price) then
				-- Remove the caught model from belt updates before handing it to the player.
				marching[item] = nil
				item.connection:Disconnect()
				item.connection = nil
				item.prompt.Enabled = false
				state.carry = item
				events.Feedback:FireClient(player, "Caught " .. definition.name .. "! Run to an empty base pad")
			else
				events.Feedback:FireClient(player, ("You need $%d"):format(definition.price))
			end
		end)
	end

	RunService.Heartbeat:Connect(function(dt)
		for item, x in pairs(marching) do
			x += dt * beltSpeed
			if x >= beltEnd then
				marching[item] = nil
				item.model:Destroy()
			else
				marching[item] = x
				item.model:PivotTo(CFrame.new(x, spawnPoint.Y, spawnPoint.Z) * beltFacing)
			end
		end
		for player, state in pairs(economy.Players) do
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if root and state.carry then
				-- Preserve heading while keeping the carried model level.
				local look = root.CFrame.LookVector
				local yaw = math.atan2(-look.X, -look.Z)
				state.carry.model:PivotTo(CFrame.new(root.Position + Vector3.new(0, data.CarryOffset, 0)) * CFrame.Angles(0, yaw, 0))
			end
		end
	end)

	task.spawn(function()
		while true do
			if world.folder:GetAttribute("WavePhase") ~= "WAVE" then
				spawnBrainrot()
			end
			task.wait(spawnInterval)
		end
	end)
end

return Spawner
