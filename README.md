# Brainrot Tsunami Escape
[![make.fun · roblox-brainrot-01](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/jembot21/brainrot-bazaar/rank.svg)](https://make.fun/bounty/roblox-brainrot-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/jembot21/brainrot-bazaar/reward.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)

Build a brainrot collection across a sunny island while staying ahead of the next tsunami.

## The loop

Buy a brainrot from the offer belt, carry it to your base, and place it on one of six pads. Each placed character earns cash every second. Collect matching species to fuse three into a higher-tier brainrot, then spend your income on speed upgrades or a rebirth. When the warning sounds, climb to the central high ground or return to your own base before the wave sweeps the island.

Players caught outside their base and below the wave lose their carried brainrot and five percent of their cash. Unlocked pads can be raided, so keep your collection growing and plan your trips carefully.

## Features

- Eight personal plots with six collection pads each.
- Twelve original species across five rarity tiers, with Gold, Diamond, and Rainbow mutations.
- Weighted belt offers, carrying and placement, timed pad locks, stealing, selling, and three-to-one fusion.
- Passive income, ten speed upgrades, and repeatable rebirths.
- Escalating tsunami waves, warning effects, and a central high-ground escape route.
- Hand-built island terrain, palms, beach, shops, and environmental decorations.

## How it was built

The place is authored in Luau and assembled with Rojo. Shared balance and species data lives in `src/shared`; server-owned world, economy, base, spawner, and wave systems live in `src/server`; interface and visual effects live in `src/client`.

## Controls

- **WASD** or **arrow keys** to move; **Space** to jump.
- **E** at an offer belt character to buy and carry it.
- **E** at a pad to place or pick up a brainrot.
- Use the on-screen buttons to buy speed or rebirth.
- Use the trade stand prompt to sell the character you are carrying.
