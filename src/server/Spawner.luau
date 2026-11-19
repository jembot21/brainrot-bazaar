local Players = game:GetService("Players")
local Data = require(game:GetService("ReplicatedStorage").Shared.BrainrotData)
local CharacterFactory = require(script.Parent.CharacterFactory)

local Spawner = {}
local economy
local baseManager
local remotes
local belt
local offerFolder
local random = Random.new()

local function rarityRoll()
	local total = 0
	for _, rarity in ipairs(Data.RarityOrder) do total += Data.RarityWeights[rarity] end
	local roll = random:NextNumber(0, total)
	local cursor = 0
	for _, rarity in ipairs(Data.RarityOrder) do
		cursor += Data.RarityWeights[rarity]
		if roll <= cursor then return rarity end
	end
	return "Common"
end

local function chooseSpecies()
	local rarity = rarityRoll()
	local tier = table.find(Data.RarityOrder, rarity)
	local choices = {}
	for _, species in ipairs(Data.Species) do
		if species.Tier == tier then table.insert(choices, species) end
	end
	return choices[random:NextInteger(1, #choices)]
end

local function spawnOffer(index)
	local species = chooseSpecies()
	local mutation = Data.RollMutation(random)
	local model = CharacterFactory.Create(species.Name, mutation.Name)
	model.Name = "BeltOffer_" .. index
	model.Parent = offerFolder
	model:PivotTo(belt.CFrame * CFrame.new((index - 2.5) * 8.2, 1.25, 0))
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "PurchasePrompt"
	prompt.ActionText = "Buy $" .. species.Price
	prompt.ObjectText = mutation.Name .. " " .. species.Name
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0.25
	prompt.MaxActivationDistance = 11
	prompt.RequiresLineOfSight = false
	prompt.Parent = model.PrimaryPart
	prompt.Triggered:Connect(function(player)
		if not model.Parent or model:GetAttribute("Sold") or model:GetAttribute("ReservedBy") then return end
		model:SetAttribute("ReservedBy", player.UserId)
		if economy.GetCash(player) < species.Price then
			model:SetAttribute("ReservedBy", nil)
			if remotes.Toast then remotes.Toast:FireClient(player, "Need $" .. species.Price .. " to buy this brainrot.") end
			return
		end
		if not baseManager.GiveCarry(player, model) then
			model:SetAttribute("ReservedBy", nil)
			if remotes.Toast then remotes.Toast:FireClient(player, "Your hands are full, or you need a plot.") end
			return
		end
		if not economy.TrySpend(player, species.Price) then
			baseManager.ClearCarry(player)
			if remotes.Toast then remotes.Toast:FireClient(player, "Need $" .. species.Price .. " to buy this brainrot.") end
			return
		end
		model:SetAttribute("Sold", true)
		if remotes.PurchaseSparkle then remotes.PurchaseSparkle:FireAllClients(model:GetPivot().Position) end
		if remotes.Toast then remotes.Toast:FireClient(player, "Bought " .. mutation.Name .. " " .. species.Name .. "!") end
	end)
	local tag = Instance.new("BillboardGui")
	tag.Name = "PriceTag"
	tag.Size = UDim2.fromScale(4, 1)
	tag.StudsOffset = Vector3.new(0, 3.3, 0)
	tag.MaxDistance = 70
	tag.AlwaysOnTop = false
	tag.Parent = model.PrimaryPart
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(30, 45, 54)
	label.BackgroundTransparency = 0.15
	label.TextColor3 = Color3.fromRGB(255, 239, 169)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = "$" .. species.Price
	label.Parent = tag
	return model
end

function Spawner.Start(world, economyService, bases, remoteFolder)
	economy = economyService
	baseManager = bases
	remotes = remoteFolder
	belt = world.Belt
	offerFolder = Instance.new("Folder")
	offerFolder.Name = "BeltOffers"
	offerFolder.Parent = world.Root
	for index = 1, 4 do spawnOffer(index) end
	task.spawn(function()
		while true do
			task.wait(12)
			offerFolder:ClearAllChildren()
			for index = 1, 4 do spawnOffer(index) end
		end
	end)
end

return Spawner
