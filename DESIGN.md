# Hallowvale — Design

A top-down farming game with heavy psychological horror, built in Godot 4.7.

## Pillars

- **Day is work, night is dread.** Each day is a farming shift. Night brings a horror encounter.
- **Atmosphere over jump scares.** Horror comes from lighting, sound, and escalating events.
- **Progress carries over.** Skills, the house, gear, quests, and sanity persist between sessions.
- **Homestead first.** Early quests teach the farm: planting, gathering, repairs, and light.

## Controls (Stardew-style)

- Move: WASD or arrow keys
- Use, plant, harvest, gather, sleep, tidy, or read: Space / Enter (face the tile)
- Walk into the farmhouse door to go inside. Walk onto the exit mat to leave.
- Action bar (click or key): Skills K, Inventory I, Gear G, Quests Q, House H, Settings
- Esc opens Settings, or closes it if it's already open
- Farming and gathering pause while a panel is open

## Action bar

- Tab buttons along the bottom. A panel opens above the bar for the active tab.
- Each panel lists rows: name, value, and optional buttons or progress bars.
- Panels rebuild only when their content changes, so buttons don't disappear mid-click.

## Art

- 16×16 base tiles, scaled 3× in-game (`SCALE = 3`), nearest-neighbor filtering.
- Warm, saturated daytime palette. Night uses a cool, shadowy tint via `CanvasModulate`.
- Placeholder art is drawn in code. Real licensed or commissioned pixel art replaces it later without touching game logic.

## Map

- A 40×24 walkable farm surrounded by a tree border, so the camera stays centered on the player all the way to the farm's edge.
- Trees, water, the house walls, and brush piles block movement. The player slides along walls.
- A minimap in the top-right shows the farm, the house, brush piles, the player, and the shadow on event nights.
- The farmhouse interior sits below the farm and has its own camera bounds.

## Day and night

- The day runs **06:00 to 03:00** the next morning.
- Darkness starts at 19:00.
- The bed can be used from **18:00 to 03:00**. Using it saves the game and ends the day.
- If you aren't in bed by **03:00**, you collapse. The day ends, the game saves, and your **sanity limit drops by 5 permanently**. The penalty is meant to be curable later.
- Crops grow one stage per day, and brush piles respawn each morning.

## Quests (homestead)

The early quests teach the farm. They're shown in the Quests panel with progress bars, and each one pays a reward once.

| Quest | Goal | Reward |
|---|---|---|
| Break ground | Plant 3 seeds | 5 seeds |
| First harvest | Harvest 1 crop | 50 Farming XP |
| Gather from the brush | Gather from 3 brush piles | 2 wood, 2 fiber |
| Patch the walls | Repair the house to Boarded | 2 wood, 2 fiber |
| Light the way | Build a Tin Lantern | 3 seeds |
| Sleep under your own roof | Sleep in the bed | 40 Carpentry XP |
| A clean start | Repair to Patched and tidy once | 40 Cleaning XP |

The story questline is on hold until the homestead stage is solid.

## Farmhouse

- Starts at its final size in a **Decrepit** state. Repairs change its condition, not its footprint.
- Stages: Decrepit → Boarded → Patched → Restored.
- Repairs cost wood and fiber and need a Carpentry level:

| Repair to | Wood | Fiber | Carpentry |
|---|---|---|---|
| Boarded | 3 | 2 | 1 |
| Patched | 5 | 4 | 2 |
| Restored | 8 | 6 | 3 |

- Rooms inside open as the house is repaired:
  - **Hall:** open from the start, with the exit mat.
  - **Bedroom (Boarded):** the bed. Sleeping here saves and ends the day.
  - **Parlor (Patched):** a cleaning station. Tidy once a day for Cleaning XP.
  - **Study (Restored):** a desk.
- A restored house softens the night overall.
- Before the house is boarded there's no bed, so every night ends in a collapse until the first repair.

## Skills (RuneScape-style)

- Four skills, each with XP and levels (`Level = 1 + XP / 100`):
  - **Farming:** planting gives 5 XP, harvesting gives 25 XP.
  - **Bushcrafting:** gathering a brush pile gives 10 XP.
  - **Carpentry:** each house repair gives 30 XP.
  - **Cleaning:** each daily tidy gives 20 XP.
- Levels will unlock new areas, tools, and fortifications.

## Survival (bushcrafting and lanterns)

- Brush piles give wood and fiber, and sometimes resin.
- Lanterns are built in the Gear panel. Each tier lights a ring around the player in the dark:

| Tier | Ring | Needs | Bushcrafting |
|---|---|---|---|
| Tin Lantern | 2.5 tiles | 2 wood, 2 fiber | 2 |
| Brass Lantern | 4 tiles | 4 wood, 4 fiber, 2 resin | 4 |
| Hollow Lantern | 6 tiles, flickers | 6 wood, 6 fiber, 4 resin | 6 |

- No hunger or thirst.

## Sanity and horror

- Sanity runs from 0 to a maximum that drops with each collapse. It shows in the HUD as `Sanity current/max`.
- Outdoors in the dark, sanity drains slowly. Indoors it recovers. Tidying gives +10, and sleeping gives +25.
- Below 30 sanity, the whole screen gets darker.
- Night events vary by day and change sanity:
  - Something at the edge of the field (−5)
  - Knocks on the house wall (−10)
  - A figure watching by the house (−15)
  - A quiet night (−3)
- The field shadow creeps closer each night.

## Saving

- The game saves **only** when you sleep in bed or collapse at 03:00.
- Saved: day, skill XP, inventory, materials, stats, quests done, lantern tier, house stage, sanity and sanity penalty, crops, and brush piles.
- Quitting mid-day loses that day's progress since the last save.

## Deferred

- The story: beats, mystery, and horror escalation. Waiting until the homestead is solid.
- Curing the sanity penalty.

## Open decisions

- Whether the house interior should become a separate scene.
- Whether the tile map moves to a `TileMapLayer` with a real `TileSet` once art is in.
- Whether the player's position should also be saved. It isn't yet.
