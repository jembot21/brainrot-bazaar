local Data = {}
Data.RarityOrder = {"Common", "Rare", "Epic", "Legendary", "Mythic"}
Data.Rarities = {
	Common = {weight = 52, price = 25, incomePerSecond = 2, color = Color3.fromRGB(246, 205, 91), shape = Enum.PartType.Ball},
	Rare = {weight = 27, price = 90, incomePerSecond = 8, color = Color3.fromRGB(90, 208, 132), shape = Enum.PartType.Block},
	Epic = {weight = 13, price = 300, incomePerSecond = 28, color = Color3.fromRGB(112, 150, 255), shape = Enum.PartType.Ball},
	Legendary = {weight = 6, price = 1200, incomePerSecond = 110, color = Color3.fromRGB(255, 153, 63), shape = Enum.PartType.Cylinder},
	Mythic = {weight = 2, price = 6000, incomePerSecond = 520, color = Color3.fromRGB(235, 93, 217), shape = Enum.PartType.Ball},
}
Data.Mutations = {
	{name = "Gold", multiplier = 2, chance = 0.08, color = Color3.fromRGB(255, 211, 58)},
	{name = "Diamond", multiplier = 3, chance = 0.035, color = Color3.fromRGB(93, 237, 246)},
	{name = "Rainbow", multiplier = 5, chance = 0.012, color = Color3.fromRGB(248, 91, 190)},
}

local function species(name, rarity, accessory, red, green, blue)
	local tier = Data.Rarities[rarity]
	return {
		name = name, rarity = rarity, accessory = accessory,
		color = Color3.fromRGB(red, green, blue), shape = tier.shape,
		price = tier.price, incomePerSecond = tier.incomePerSecond,
	}
end

Data.Cast = {
	species("Sir Bounce Banana", "Common", "Crown", 255, 225, 58),
	species("Pigeon Barry", "Common", "Feather", 160, 175, 183),
	species("Toaster Todd", "Common", "Toast", 188, 126, 78),
	species("Disco Broccoli Bro", "Rare", "DiscoBall", 76, 207, 102),
	species("Grandma Turbo", "Rare", "Glasses", 238, 154, 183),
	species("Cactus Carl", "Rare", "Flower", 53, 166, 96),
	species("Croissant Dragon Draco", "Epic", "Horns", 216, 143, 74),
	species("WiFi Wizard Wally", "Epic", "WizardHat", 89, 118, 233),
	species("Golden Toilet King", "Legendary", "Crown", 255, 188, 37),
	species("Moon Cheese Golem", "Legendary", "Moon", 229, 221, 147),
	species("Galaxy Brain Octopus", "Mythic", "Star", 142, 93, 235),
	species("Rainbow Sock Puppet", "Mythic", "Sock", 247, 104, 167),
}

Data.StartCash = 150
Data.SellReturn = 0.9
Data.RebirthCost = 25000
Data.RebirthMultiplierStep = 0.5
Data.BaseLockSeconds = 60
Data.CarryOffset = 4.3
Data.Wave = {
	WaveHeights = {6, 10, 14, 18},
	CalmSeconds = 40,
	WarningSeconds = 10,
	WaveCrossSeconds = 9,
	WaveCashPenalty = 0.05,
}
Data.Fusion = {FuseCount = 3}
Data.SpeedShop = {
	BaseWalkSpeed = 16,
	SpeedPerTier = 2,
	SpeedMaxTier = 10,
	SpeedBaseCost = 250,
	SpeedCostGrowth = 1.6,
}

-- Purchase tiers are one-based. Tier zero is the starting WalkSpeed.
function Data.SpeedShop.Cost(tier)
	return math.round(Data.SpeedShop.SpeedBaseCost * tier ^ Data.SpeedShop.SpeedCostGrowth)
end

function Data.Income(definition, mutation)
	return definition.incomePerSecond * (mutation and mutation.multiplier or 1)
end

-- Shared palette and repeatable dimensions for static island scenery.
Data.Decor = {
	Trunk = Color3.fromRGB(144, 92, 55),
	-- The lower blades form the canopy outline and the lighter blades fill the top.
	Frond = Color3.fromRGB(52, 184, 77),
	FrondLight = Color3.fromRGB(100, 214, 92),
	Coconut = Color3.fromRGB(85, 52, 38),
	Rock = Color3.fromRGB(115, 128, 139),
	Bush = Color3.fromRGB(48, 137, 86),
	Flowers = {Color3.fromRGB(255, 124, 181), Color3.fromRGB(255, 222, 105), Color3.fromRGB(255, 250, 238)},
	Towels = {Color3.fromRGB(243, 111, 120), Color3.fromRGB(78, 198, 213), Color3.fromRGB(157, 130, 235)},
	TorchFlame = Color3.fromRGB(255, 140, 44),
	FrondSize = Vector3.new(8.2, 0.32, 2.6),
	FrondTopSize = Vector3.new(6, 0.32, 2.1),
	FrondCount = 7,
	FrondTopCount = 5,
	FrondTilt = math.rad(34),
	FrondTopTilt = math.rad(10),
	CoconutSize = Vector3.new(0.55, 0.55, 0.55),
	FlowerSize = Vector3.new(0.52, 0.34, 0.52),
	TowelSize = Vector3.new(4, 0.15, 7),
	PlanterSize = Vector3.new(5, 1.2, 5),
}

return Data
