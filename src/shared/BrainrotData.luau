local D = {}

D.Tiers = {
    { Name = "Common", Weight = 52, Price = 25, Income = 2 },
    { Name = "Rare", Weight = 27, Price = 90, Income = 8 },
    { Name = "Epic", Weight = 13, Price = 300, Income = 28 },
    { Name = "Legendary", Weight = 6, Price = 1200, Income = 110 },
    { Name = "Mythic", Weight = 2, Price = 6000, Income = 520 },
}

D.Species = {
    { Name = "Wobble Noodle", Tier = 1, Color = Color3.fromRGB(245, 156, 94), Accessory = "Hat" },
    { Name = "Bongo Sprout", Tier = 1, Color = Color3.fromRGB(127, 211, 108), Accessory = "Ears" },
    { Name = "Puddle Biscuit", Tier = 1, Color = Color3.fromRGB(124, 198, 233), Accessory = "Tail" },
    { Name = "Zippy Turnip", Tier = 2, Color = Color3.fromRGB(202, 143, 237), Accessory = "Crown" },
    { Name = "Muffin Gobbler", Tier = 2, Color = Color3.fromRGB(235, 142, 174), Accessory = "Hat" },
    { Name = "Dizzy Picklepuff", Tier = 2, Color = Color3.fromRGB(152, 222, 148), Accessory = "Ears" },
    { Name = "Orbit Dumpling", Tier = 3, Color = Color3.fromRGB(96, 132, 233), Accessory = "Orbit" },
    { Name = "Snorkel Waffle", Tier = 3, Color = Color3.fromRGB(238, 190, 86), Accessory = "Goggles" },
    { Name = "Velvet Bonk", Tier = 4, Color = Color3.fromRGB(164, 89, 209), Accessory = "Crown" },
    { Name = "Turbo Crumpet", Tier = 4, Color = Color3.fromRGB(238, 99, 89), Accessory = "Wings" },
    { Name = "Cosmic Flapjack", Tier = 5, Color = Color3.fromRGB(89, 231, 215), Accessory = "Orbit" },
    { Name = "Royal Sploosh", Tier = 5, Color = Color3.fromRGB(245, 122, 221), Accessory = "Wings" },
}

D.Mutations = {
    Normal = { Multiplier = 1 },
    Gold = { Multiplier = 2, Chance = 0.08, Color = Color3.fromRGB(255, 206, 62) },
    Diamond = { Multiplier = 3, Chance = 0.035, Color = Color3.fromRGB(124, 238, 255) },
    Rainbow = { Multiplier = 5, Chance = 0.012, Color = Color3.fromRGB(241, 130, 255) },
}

D.StartCash = 150
D.SellRatio = 0.9
D.PadLock = 60
D.FusionCount = 3
D.SpeedTiers = 10
D.SpeedStep = 2
D.RebirthCost = 25000
D.RebirthBonus = 0.5
D.Calm = 40
D.Warning = 10
D.Sweep = 9
D.CaughtPenalty = 0.05

function D.SpeedCost(tier)
    return math.floor(250 * tier ^ 1.6 + 0.5)
end

function D.Roll(rng)
    local remainingWeight = rng:NextNumber() * 100
    local selectedTier = 1
    for tierIndex, definition in ipairs(D.Tiers) do
        remainingWeight -= definition.Weight
        if remainingWeight <= 0 then
            selectedTier = tierIndex
            break
        end
    end

    local candidates = {}
    for speciesIndex, definition in ipairs(D.Species) do
        if definition.Tier == selectedTier then
            table.insert(candidates, speciesIndex)
        end
    end

    local selectedMutation = "Normal"
    local mutationRoll = rng:NextNumber()
    local cumulativeChance = 0
    for _, mutationName in ipairs({ "Rainbow", "Diamond", "Gold" }) do
        cumulativeChance += D.Mutations[mutationName].Chance
        if mutationRoll < cumulativeChance then
            selectedMutation = mutationName
            break
        end
    end

    return {
        Species = candidates[rng:NextInteger(1, #candidates)],
        Mutation = selectedMutation,
    }
end

function D.Price(item)
    return D.Tiers[D.Species[item.Species].Tier].Price
end

function D.Income(item)
    return D.Tiers[D.Species[item.Species].Tier].Income
        * D.Mutations[item.Mutation].Multiplier
end

return D
