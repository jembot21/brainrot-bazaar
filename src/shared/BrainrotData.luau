-- Brainrot Bazaar shared data definitions and configuration
local BrainrotData = {}

-- Rarity tiers: price, base income per second, palette color, shape, and drop weight
BrainrotData.Rarities = {
	Common = {
		price = 25,
		incomePerSecond = 2,
		color = Color3.fromRGB(246, 205, 91),
		shape = Enum.PartType.Ball,
		weight = 52,
	},
	Rare = {
		price = 90,
		incomePerSecond = 8,
		color = Color3.fromRGB(90, 208, 132),
		shape = Enum.PartType.Block,
		weight = 27,
	},
	Epic = {
		price = 300,
		incomePerSecond = 28,
		color = Color3.fromRGB(112, 150, 255),
		shape = Enum.PartType.Ball,
		weight = 13,
	},
	Legendary = {
		price = 1200,
		incomePerSecond = 110,
		color = Color3.fromRGB(255, 153, 63),
		shape = Enum.PartType.Cylinder,
		weight = 6,
	},
	Mythic = {
		price = 6000,
		incomePerSecond = 520,
		color = Color3.fromRGB(235, 93, 217),
		shape = Enum.PartType.Ball,
		weight = 2,
	},
}

BrainrotData.Mutations = {
	{
		name = "Gold",
		multiplier = 2,
		color = Color3.fromRGB(255, 211, 58),
		chance = 0.08,
	},
	{
		name = "Diamond",
		multiplier = 3,
		color = Color3.fromRGB(93, 237, 246),
		chance = 0.035,
	},
	{
		name = "Rainbow",
		multiplier = 5,
		color = Color3.fromRGB(248, 91, 190),
		chance = 0.012,
	},
}

BrainrotData.RebirthCost = 25000
BrainrotData.RebirthMultiplierStep = 0.5

BrainrotData.Cast = {
	{ name = "Sir Bounce Banana", rarity = "Common", accessory = "Crown", color = Color3.fromRGB(255, 225, 58) },
	{ name = "Pigeon Barry", rarity = "Common", accessory = "Feather", color = Color3.fromRGB(160, 175, 183) },
	{ name = "Toaster Todd", rarity = "Common", accessory = "Toast", color = Color3.fromRGB(188, 126, 78) },
	{ name = "Disco Broccoli Bro", rarity = "Rare", accessory = "DiscoBall", color = Color3.fromRGB(76, 207, 102) },
	{ name = "Grandma Turbo", rarity = "Rare", accessory = "Glasses", color = Color3.fromRGB(238, 154, 183) },
	{ name = "Cactus Carl", rarity = "Rare", accessory = "Flower", color = Color3.fromRGB(53, 166, 96) },
	{ name = "Croissant Dragon Draco", rarity = "Epic", accessory = "Horns", color = Color3.fromRGB(216, 143, 74) },
	{ name = "WiFi Wizard Wally", rarity = "Epic", accessory = "WizardHat", color = Color3.fromRGB(89, 118, 233) },
	{ name = "Golden Toilet King", rarity = "Legendary", accessory = "Crown", color = Color3.fromRGB(255, 188, 37) },
	{ name = "Moon Cheese Golem", rarity = "Legendary", accessory = "Moon", color = Color3.fromRGB(229, 221, 147) },
	{ name = "Galaxy Brain Octopus", rarity = "Mythic", accessory = "Star", color = Color3.fromRGB(142, 93, 235) },
	{ name = "Rainbow Sock Puppet", rarity = "Mythic", accessory = "Sock", color = Color3.fromRGB(247, 104, 167) },
}

return BrainrotData
