# Brainrot Tsunami Escape
[![make.fun · roblox-brainrot-01](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/jembot21/brainrot-bazaar/rank.svg)](https://make.fun/bounty/roblox-brainrot-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/jembot21/brainrot-bazaar/reward.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)

Collect twelve original block creatures in a tycoon on Tideglass Island, where recurring tsunamis challenge you to escape. Increase your income and choose how far to explore before the siren sounds.

## Playing a cycle

Your starting cash is $150. Purchase a creature on the moving market belt, bring it home, and set it on one of six pads to earn cash every second. Placement prevents theft for sixty seconds, after which other players can steal it. You may retrieve your own creatures whenever you like.

A cycle consists of forty seconds of calm, ten seconds of warning, and a nine-second sweep. Wave heights progress through 6, 10, 14, and 18 studs and stay at 18 afterward. Your base provides safety; elsewhere, take the stone refuge stairs above the water. A catch destroys your carried creature and takes 5% of your cash, once per sweep.

## What is included

- Eight plots with six pads apiece and earnings from five rarity tiers.
- Twelve original species made from parts, featuring hats, ears, tails, crowns, wings, goggles, and orbiting-star shapes.
- Spawn rolls for Gold ×2, Diamond ×3, and Rainbow ×5 income mutations.
- A sell stand paying 90% of the tier price for your carried creature.
- Fusion Corner combines three matching species from your pads into one Normal creature of the next tier; Mythics have no further fusion.
- Ten speed tiers granting two WalkSpeed each, with $25,000 rebirths granting 0.5× income apiece.
- A moving wave wall, warning border, camera shake, splash particles, purchase effects, and sparkling mutations.
- A beach lined with palms, two elevated refuges, and 250 extra rocks, bushes, fence sections, lamps, and crates.

## Interacting

Move and jump with the platform's usual controls. Near a creature, pad, or stand, hold its interaction prompt: E on a keyboard or the corresponding touch/gamepad input. You may carry one creature at a time. The Speed Shop HUD button opens the ten-tier panel, and Rebirth spends $25,000 for the session multiplier. Wave state, countdown, cash, income, and carrying hints appear in the HUD.

## Build and dossier

The game was made from scratch using Rojo and Luau. At server startup, WorldBuilder builds the anchored island, while CharacterFactory makes every creature from native parts and UI. Transactions, placement, theft, fusion, and wave penalties belong to server modules; HUD and cosmetic effects run in client scripts. External art assets are unnecessary. There is no DataStore: session state deliberately resets on server shutdown.

Use `/home/hatch/workspace/tools/rojo-bin/rojo build -o game.rbxl` to build. Afterward, `MAKEFUN_OUTPUT_DIR=/tmp/brainrot-r10-out node main.ts` assembles the kit dossier. Its builder copies the place, source, screenshots, and PLAY.json to the chosen output directory. The experience link is in PLAY.json, and the guided route is in TOUR.json.
