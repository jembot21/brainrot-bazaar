local Players = game:GetService("Players")
local Data = require(game:GetService("ReplicatedStorage").Shared.BrainrotData)
local CharacterFactory = require(script.Parent.CharacterFactory)

local BaseManager = {}
local plots = {}
local playerPlots = {}
local carried = {}
local economy
local remotes

local function toast(player, message)
	if remotes and remotes.Toast then
		remotes.Toast:FireClient(player, message)
	end
end

local function getPadBrainrot(pad)
	for _, child in ipairs(pad:GetChildren()) do
		if child:IsA("Model") and child:GetAttribute("Species") then
			return child
		end
	end
	return nil
end

local function padList(plot)
	local pads = {}
	for _, descendant in ipairs(plot.Model:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant:GetAttribute("PadIndex") then
			table.insert(pads, descendant)
		end
	end
	table.sort(pads, function(a, b)
		return a:GetAttribute("PadIndex") < b:GetAttribute("PadIndex")
	end)
	return pads
end

local function setAnchored(model, anchored)
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Anchored = anchored
			descendant.CanCollide = false
		end
	end
end

local function attachCarry(player, model)
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	local primary = model.PrimaryPart
	if not head or not primary then
		model.Parent = workspace:FindFirstChild("BrainrotIsland")
		model:PivotTo(player.Character and player.Character:GetPivot() or CFrame.new())
		return false
	end
	local oldPrompt = model:FindFirstChild("PickupPrompt", true)
	if oldPrompt then oldPrompt:Destroy() end
	model.Parent = character
	setAnchored(model, false)
	for _, child in ipairs(model:GetChildren()) do
		if child:IsA("BasePart") and child ~= primary then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = primary
			weld.Part1 = child
			weld.Parent = primary
		end
	end
	primary.CFrame = head.CFrame * CFrame.new(0, 2.15, 0)
	local weld = Instance.new("WeldConstraint")
	weld.Name = "CarryWeld"
	weld.Part0 = head
	weld.Part1 = primary
	weld.Parent = primary
	model:SetAttribute("CarriedBy", player.UserId)
	carried[player] = model
	return true
end

local function place(player, pad)
	local plot = playerPlots[player]
	local item = carried[player]
	if not plot or not item then
		return false
	end
	local speciesName = item:GetAttribute("Species")
	if pad:GetAttribute("PlotIndex") ~= plot.Index or pad:GetAttribute("Occupied") then
		return false
	end
	local primary = item.PrimaryPart
	if not primary then return false end
	for _, descendant in ipairs(item:GetDescendants()) do
		if descendant:IsA("WeldConstraint") then descendant:Destroy() end
	end
	item.Parent = pad
	setAnchored(item, true)
	item:PivotTo(pad.CFrame * CFrame.new(0, 1.15, 0))
	item:SetAttribute("CarriedBy", nil)
	item:SetAttribute("OwnerUserId", player.UserId)
	pad:SetAttribute("Occupied", true)
	pad:SetAttribute("LockedUntil", os.clock() + Data.PadLockSeconds)
	carried[player] = nil
	if remotes and remotes.PurchaseSparkle then remotes.PurchaseSparkle:FireAllClients(item:GetPivot().Position) end
	local fused = BaseManager.TryFusion(player)
	if not fused then
		local matching = 0
		for _, placed in ipairs(BaseManager.GetPlaced(player)) do
			if placed:GetAttribute("Species") == speciesName then matching += 1 end
		end
		if matching == 2 then toast(player, "Fusion hint: place one more " .. speciesName .. " on your pads!") end
	end
	return true
end

local function take(player, pad)
	local model = getPadBrainrot(pad)
	if not model or carried[player] then return false end
	local ownerId = model:GetAttribute("OwnerUserId")
	local isOwner = ownerId == player.UserId
	local unlocked = os.clock() >= (pad:GetAttribute("LockedUntil") or 0)
	if not isOwner and not unlocked then
		toast(player, "That brainrot is locked for a little longer!")
		return false
	end
	pad:SetAttribute("Occupied", false)
	model.Parent = workspace
	return attachCarry(player, model)
end

local function makePadPrompt(pad)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "PadPrompt"
	prompt.ActionText = "Place / Take"
	prompt.ObjectText = "Brainrot Pad"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0.2
	prompt.MaxActivationDistance = 11
	prompt.RequiresLineOfSight = false
	prompt.Parent = pad
	prompt.Triggered:Connect(function(player)
		if carried[player] then
			place(player, pad)
		else
			take(player, pad)
		end
	end)
end

local function assign(player)
	for _, plot in ipairs(plots) do
		if not plot.Owner then
			plot.Owner = player
			plot.Model:SetAttribute("OwnerUserId", player.UserId)
			playerPlots[player] = plot
			local spawn = plot.Spawn
			local function placeCharacter(character)
				local root = character:WaitForChild("HumanoidRootPart", 8)
				if root and playerPlots[player] == plot then
					root.CFrame = spawn.CFrame + Vector3.new(0, 4, 0)
					local humanoid = character:FindFirstChildOfClass("Humanoid")
					if humanoid then
						local state = economy.GetState(player)
						humanoid.WalkSpeed = 16 + ((state and state.SpeedTier or 0) * Data.SpeedPerTier)
					end
				end
			end
			player.CharacterAdded:Connect(placeCharacter)
			if player.Character then task.spawn(placeCharacter, player.Character) end
			return plot
		end
	end
	toast(player, "All island plots are full.")
	return nil
end

function BaseManager.Start(world, economyService, remoteFolder)
	economy = economyService
	remotes = remoteFolder
	plots = {}
	for _, child in ipairs(world.Root:GetChildren()) do
		if child:IsA("Model") and child:GetAttribute("PlotIndex") then
			local spawn = child:FindFirstChild("PlotSpawn")
			local floor = child:FindFirstChild("BaseFloor")
			table.insert(plots, {
				Index = child:GetAttribute("PlotIndex"),
				Model = child,
				Center = floor and floor.Position or child:GetPivot().Position,
				Spawn = spawn,
			})
		end
	end
	table.sort(plots, function(a, b) return a.Index < b.Index end)
	for _, plot in ipairs(plots) do
		for _, pad in ipairs(padList(plot)) do makePadPrompt(pad) end
	end
	Players.PlayerAdded:Connect(assign)
	Players.PlayerRemoving:Connect(function(player)
		local plot = playerPlots[player]
		if plot then
			plot.Owner = nil
			plot.Model:SetAttribute("OwnerUserId", nil)
			for _, pad in ipairs(padList(plot)) do
				local model = getPadBrainrot(pad)
				if model then model:Destroy() end
				pad:SetAttribute("Occupied", false)
			end
		end
		if carried[player] then carried[player]:Destroy() end
		carried[player] = nil
		playerPlots[player] = nil
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		assign(player)
	end
	for _, stand in ipairs(world.Root:GetChildren()) do
		if stand:IsA("BasePart") and stand:GetAttribute("ShopType") == "Sell" then
			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = "Sell Carried Brainrot"
			prompt.ObjectText = "Trade Stand"
			prompt.KeyboardKeyCode = Enum.KeyCode.E
			prompt.MaxActivationDistance = 12
			prompt.Parent = stand
			prompt.Triggered:Connect(function(player) BaseManager.SellCarry(player) end)
		end
	end
end

function BaseManager.GetPlaced(player)
	local plot = playerPlots[player]
	local result = {}
	if not plot then return result end
	for _, pad in ipairs(padList(plot)) do
		local model = getPadBrainrot(pad)
		if model then table.insert(result, model) end
	end
	return result
end

function BaseManager.GiveCarry(player, model)
	if carried[player] or not playerPlots[player] then return false end
	return attachCarry(player, model)
end

function BaseManager.ClearCarry(player)
	local model = carried[player]
	if model then model:Destroy() end
	carried[player] = nil
end

function BaseManager.SellCarry(player)
	local model = carried[player]
	if not model then toast(player, "Carry a brainrot to the trade stand first."); return false end
	local value = economy.SellValue(model:GetAttribute("Price") or 0)
	BaseManager.ClearCarry(player)
	economy.AddCash(player, value)
	toast(player, "Sold for $" .. value .. "!")
	return true
end

function BaseManager.TryFusion(player)
	local plot = playerPlots[player]
	if not plot then return false end
	local groups = {}
	for _, pad in ipairs(padList(plot)) do
		local model = getPadBrainrot(pad)
		if model then
			local name = model:GetAttribute("Species")
			groups[name] = groups[name] or {}
			table.insert(groups[name], { Pad = pad, Model = model })
		end
	end
	for speciesName, group in pairs(groups) do
		if #group >= Data.FusionCount then
			local oldSpecies = Data.SpeciesByName[speciesName]
			local nextTier = math.min(oldSpecies.Tier + 1, #Data.TierPrice)
			if nextTier == oldSpecies.Tier then return false end
			local choices = {}
			for _, species in ipairs(Data.Species) do
				if species.Tier == nextTier then table.insert(choices, species) end
			end
			if #choices == 0 then return false end
			for i = 1, Data.FusionCount do group[i].Model:Destroy(); group[i].Pad:SetAttribute("Occupied", false) end
			local target = group[1].Pad
			local fused = CharacterFactory.Create(choices[math.random(1, #choices)].Name, "Normal")
			fused.Parent = target
			fused:PivotTo(target.CFrame * CFrame.new(0, 1.15, 0))
			fused:SetAttribute("OwnerUserId", player.UserId)
			target:SetAttribute("Occupied", true)
			target:SetAttribute("LockedUntil", os.clock() + Data.PadLockSeconds)
			toast(player, "Fusion! Three " .. speciesName .. " became " .. fused:GetAttribute("Species") .. ".")
			return true
		end
	end
	return false
end

function BaseManager.IsInOwnBase(player, position)
	local plot = playerPlots[player]
	if not plot then return false end
	local center = plot.Center
	return math.abs(position.X - center.X) <= 26 and math.abs(position.Z - center.Z) <= 23
end

return BaseManager
