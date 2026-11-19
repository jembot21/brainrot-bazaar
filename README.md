# Brainrot Tsunami Escape
[![make.fun · roblox-brainrot-01](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/jembot21/brainrot-bazaar/rank.svg)](https://make.fun/bounty/roblox-brainrot-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/jembot21/brainrot-bazaar/reward.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)

An island collecting tycoon with a recurring tsunami escape challenge. Build a collection of twelve original block creatures on Tideglass Island, grow your income, and decide how far to venture before the siren.

## The loop

Start with $150. Buy a creature from the moving market belt, carry it home, and place it on one of six pads. Placed creatures earn cash each second. Pads are locked against theft for sixty seconds after placement; afterward other players can steal from them. Your own creatures can be picked up at any time.

Every cycle has forty calm seconds, ten warning seconds, and a nine-second sweep. Waves rise through 6, 10, 14, and 18 studs, then remain at 18. Your own base is safe. Away from home, climb the stone refuge stairs above the water. Being caught destroys the creature you carry and removes 5% of your cash, once per sweep.

## Features

- Eight plots, six pads each, and income from five rarity tiers.
- Twelve original species with part-built hats, ears, tails, crowns, wings, goggles, and orbiting-star shapes.
- Gold ×2, Diamond ×3, and Rainbow ×5 income mutations rolled at spawn.
- Sell a carried creature for 90% of its tier price at the sell stand.
- Fuse three of the same species on your pads at Fusion Corner to receive one Normal creature from the next tier. Mythics cannot fuse further.
- Ten speed tiers, each adding two WalkSpeed; rebirths cost $25,000 and add 0.5× income each.
- Animated wave wall, warning border, camera shake, splash particles, purchase effects, and mutation sparkles.
- Palm-lined beach, two high refuges, and 250 additional rocks, bushes, fence sections, lamps, and crates.

## Controls

Use the platform's standard movement and jump controls. Approach a creature, pad, or stand and hold the displayed interaction prompt (E on keyboard, or its touch/gamepad equivalent). Carry only one creature at a time. Use the Speed Shop HUD button to open the ten-tier panel. Use the Rebirth button to spend $25,000 for the session multiplier. The HUD shows wave state, countdown, cash, income, and carrying hints.

## Build

Built from scratch with Rojo and Luau. WorldBuilder creates the anchored island at server startup; CharacterFactory constructs all creatures with native parts and UI. Server modules own transactions, placement, theft, fusion, and wave penalties. Client scripts provide HUD and cosmetic effects. No external art assets are required. Session state intentionally resets when the server closes; no DataStore is used.

Build with `/home/hatch/workspace/tools/rojo-bin/rojo build -o game.rbxl`. Run `MAKEFUN_OUTPUT_DIR=/tmp/brainrot-r10-out node main.ts` to assemble the kit dossier after the build. The dossier builder copies the place, source, screenshots, and PLAY.json into the selected output directory. PLAY.json contains the experience link; TOUR.json contains the guided route.
