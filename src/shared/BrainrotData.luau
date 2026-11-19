local Data = {}

Data.RarityOrder = { "Common", "Rare", "Epic", "Legendary", "Mythic" }
Data.RarityWeights = { Common = 52, Rare = 27, Epic = 13, Legendary = 6, Mythic = 2 }
Data.TierPrice = { 25, 90, 300, 1200, 6000 }
Data.TierIncome = { 2, 8, 28, 110, 520 }
Data.StartCash = 150
Data.SellMultiplier = 0.9
Data.PadLockSeconds = 60
Data.FusionCount = 3
Data.SpeedTiers = 10
Data.SpeedPerTier = 2
Data.RebirthCost = 25000
Data.RebirthIncomeBonus = 0.5
Data.WavePhases = { Calm = 40, Warning = 10, Sweep = 9 }
Data.WaveHeights = { 6, 10, 14, 18 }
Data.CaughtCashLoss = 0.05

Data.Mutations = {
	{ Name = "Normal", Income = 1, Chance = 0.873, Color = Color3.fromRGB(240, 231, 201) },
	{ Name = "Gold", Income = 2, Chance = 0.08, Color = Color3.fromRGB(255, 198, 45) },
	{ Name = "Diamond", Income = 3, Chance = 0.035, Color = Color3.fromRGB(64, 219, 255) },
	{ Name = "Rainbow", Income = 5, Chance = 0.012, Color = Color3.fromRGB(255, 107, 216) },
}

Data.Species = {
	{ Name = "Bloopaloop", Tier = 1, Body = Color3.fromRGB(79, 199, 166), Accent = Color3.fromRGB(255, 223, 117), Accessory = "Ears" },
	{ Name = "Muffin Mantis", Tier = 1, Body = Color3.fromRGB(162, 215, 120), Accent = Color3.fromRGB(240, 137, 115), Accessory = "Antennae" },
	{ Name = "Gloop Trooper", Tier = 1, Body = Color3.fromRGB(113, 157, 226), Accent = Color3.fromRGB(255, 190, 118), Accessory = "Tail" },
	{ Name = "Wobble Goblet", Tier = 2, Body = Color3.fromRGB(207, 111, 181), Accent = Color3.fromRGB(255, 225, 134), Accessory = "Crown" },
	{ Name = "Pickle Pogo", Tier = 2, Body = Color3.fromRGB(102, 191, 92), Accent = Color3.fromRGB(240, 151, 76), Accessory = "Ears" },
	{ Name = "Noodle Comet", Tier = 2, Body = Color3.fromRGB(244, 150, 83), Accent = Color3.fromRGB(255, 232, 138), Accessory = "Tail" },
	{ Name = "Captain Crumb", Tier = 3, Body = Color3.fromRGB(112, 110, 206), Accent = Color3.fromRGB(255, 208, 89), Accessory = "Hat" },
	{ Name = "Bumble Biscuit", Tier = 3, Body = Color3.fromRGB(245, 181, 72), Accent = Color3.fromRGB(89, 62, 49), Accessory = "Wings" },
	{ Name = "Yoyo Yeti", Tier = 5, Body = Color3.fromRGB(158, 223, 235), Accent = Color3.fromRGB(126, 110, 216), Accessory = "Ears" },
	{ Name = "Professor Puddle", Tier = 4, Body = Color3.fromRGB(79, 174, 185), Accent = Color3.fromRGB(255, 223, 133), Accessory = "Glasses" },
	{ Name = "Duke Dandelion", Tier = 4, Body = Color3.fromRGB(225, 184, 83), Accent = Color3.fromRGB(107, 184, 112), Accessory = "Crown" },
	{ Name = "Moonbean Supreme", Tier = 5, Body = Color3.fromRGB(135, 109, 219), Accent = Color3.fromRGB(255, 241, 163), Accessory = "Halo" },
}

Data.SpeciesByName = {}
for _, species in ipairs(Data.Species) do
	species.Price = Data.TierPrice[species.Tier]
	species.Income = Data.TierIncome[species.Tier]
	Data.SpeciesByName[species.Name] = species
end

function Data.RollMutation(random)
	local roll = random:NextNumber()
	local total = 0
	for _, mutation in ipairs(Data.Mutations) do
		total += mutation.Chance
		if roll <= total then
			return mutation
		end
	end
	return Data.Mutations[1]
end

function Data.SpeedCost(tier)
	return math.floor(250 * tier ^ 1.6 + 0.5)
end

function Data.IncomeMultiplier(rebirths)
	return 1 + rebirths * Data.RebirthIncomeBonus
end

return Data
