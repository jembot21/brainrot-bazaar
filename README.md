[![make.fun · roblox-brainrot-01](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/jembot21/brainrot-bazaar/rank.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/jembot21/brainrot-bazaar/reward.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)

# Brainrot Tsunami Escape

[Play on Roblox](https://www.roblox.com/games/106961934406857)

Race from a beach lined with broad, two-tier palm crowns past the orange-roofed lifeguard tower to the island's bases. Flower patches dot the grass, tiki torches frame the central path, and red-and-white buoys mark the water beneath drifting-looking banks of white clouds.

## How to play

Brainrot name labels shrink with distance and are visible within 85 studs.

1. Start with $150. Go to the beach conveyor and use the Catch prompt to buy one of the passing brainrots.
2. Run back to your plot with the brainrot on your head and step on an empty display pad. Placed brainrots earn cash every second.
3. Place three of the same species to fuse them into a brainrot from the next rarity tier. The result keeps the strongest mutation among the three. The result uses the same position in the next tier’s cast, or that tier’s first species if it has fewer entries. Three matching Mythics fuse into the same Mythic species.
4. Buy speed tiers at the Speed Shop. Each tier adds 2 WalkSpeed, up to tier 10. Tier n costs the nearest whole dollar to $250 × n^1.6.
5. Use a placed brainrot's prompt to steal from an unlocked rival plot or sell one of your own for 90% of its base price. Use your base sign to toggle a 60-second lock.
6. At $25,000, use the Rebirth Shrine to reset your cash and brainrots. Each rebirth adds 0.5× to your income multiplier. Speed tiers carry through rebirth.

## Wave cycle

Each cycle has 40 seconds of calm, a 10-second warning, and a 9-second tsunami sweeping inland from the ocean. The wall grows from 6 to 10 to 14 to 18 studs across the first four cycles. Get inside your own plot or climb high ground above the wall. A washout sends you to your spawn, takes 5% of your cash, and sweeps away your carried brainrot. Brainrots on display pads are safe.

Gold, Diamond, and Rainbow mutations multiply base income by 2×, 3×, and 5× respectively.

## Controls

- **WASD** to move, **Space** to jump, and mouse to look around.
- **E** near an object to use its prompt. Use the on-screen prompts on touch devices.
- Open **Collection** on the HUD to check off the 12 species you've placed this rebirth.

## Build and run

Build the Roblox place with Rojo and open it in Roblox Studio to playtest. Use Studio’s Server & Clients mode with two players to try stealing and locking. Cash, collections, speed tiers, and rebirths reset when you leave the server.

```sh
rojo build default.project.json --output game.rbxl
```

Publish the binary place through Roblox Open Cloud with a key authorized to publish versions for the universe in `PLAY.json`.

```sh
curl --fail-with-body -X POST \
  -H "x-api-key: ${ROBLOX_API_KEY}" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @game.rbxl \
  'https://apis.roblox.com/universes/v1/10777357093/places/106961934406857/versions?versionType=Published'
```

After building, run `MAKEFUN_OUTPUT_DIR=out node main.ts` to package the competition hand-in.
