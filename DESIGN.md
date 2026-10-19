# Hallowvale — Design

A top-down farming game with heavy psychological horror, built in Godot 4.7.

## Pillars

- **Day is work, night is dread.** Each day is a farming shift. Night brings a horror encounter.
- **Atmosphere over jump scares.** Horror comes from lighting, sound, and escalating events.
- **Progress carries over.** Skills, the house, gear, quests, and sanity persist between sessions.
- **Homestead first.** Early quests teach the farm: planting, gathering, repairs, and light.

## Controls (Stardew-style)

- Move: WASD or arrow keys
- Use, plant, harvest, gather, sleep, tidy, cleanse, or read: Space / Enter (face the tile)
- Walk into the farmhouse door to go inside. Walk onto the exit mat to leave.
- Action bar (click or key): Skills K, Inventory I, Gear G, Quests Q, House H, Settings
- Esc opens Settings, or closes it if it's already open
- Farming and gathering pause while a panel is open

## Action bar

- Tab buttons along the bottom. A panel opens above the bar for the active tab.
- Each panel lists rows: name, value, and optional buttons or progress bars.
- Panels rebuild only when their content changes, so buttons don't disappear mid-click.
- The open panel is saved and reopened on load.

## Art

- 16×16 base tiles, scaled 3× in-game (`SCALE = 3`), nearest-neighbor filtering.
- Warm, saturated daytime palette. Night uses a cool, shadowy tint via `CanvasModulate`.
- Placeholder art is drawn in code. Real licensed or commissioned pixel art replaces it later without touching game logic.

## Map

- A 40×24 walkable farm surrounded by a tree border, so the camera stays centered on the player all the way to the farm's edge.
- Two plots: **Plot one** is tilled from the start. **Plot two** is overgrown and opens at Farming 2.
- Trees, water, the house walls, and brush piles block movement. The player slides along walls.
- A minimap in the top-right shows the farm, the house, brush piles, the player, and the shadow on event nights.
- The farmhouse interior sits below the farm and has its own camera bounds.

## Day and night

- The day runs **06:00 to 03:00** the next morning.
- Darkness starts at 19:00.
- The bed can be used from **18:00 to 03:00**. Using it saves the game and ends the day.
- If you aren't in bed by **03:00**, you collapse. The day ends, the game saves, and your **sanity limit drops by 5 permanently**. A cleanse can recover it (see Sanity).
- Crops grow one stage per day, and brush piles respawn each morning. Thicket piles appear at Bushcrafting 3.

## Quests (homestead)

Quests run in order. The first unfinished quest is shown at the top of the Quests panel as the **Next goal**, with a progress bar. Each quest pays a reward once.

| # | Quest | Goal | Reward |
|---|---|---|---|
| 1 | Break ground | Plant 3 seeds | 5 turnip seeds |
| 2 | First harvest | Harvest 1 crop | 50 Farming XP |
| 3 | Gather from the brush | Gather from 3 brush piles | 2 wood, 2 fiber |
| 4 | Patch the walls | Repair the house to Boarded | 2 wood, 2 fiber |
| 5 | Light the way | Build a Tin Lantern | 3 turnip seeds |
| 6 | Sleep under your own roof | Sleep in the bed | 40 Carpentry XP |
| 7 | A clean start | Repair to Patched and tidy once | 40 Cleaning XP |
| 8 | A second plot | Reach Farming 2 (opens plot two) | 3 pumpkin seeds |
| 9 | Ten harvests | Harvest 10 crops | 60 Farming XP |
| 10 | Angler's start | Catch 3 fish | 40 Fishing XP |
| 11 | Carpenter's apprentice | Mend 6 boards | 3 wood, 3 fiber |
| 12 | Pumpkin patch | Reach Farming 3 (unlocks pumpkins) | 2 pumpkin seeds |
| 13 | Clear the stain | Cleanse the house once | 40 Cleaning XP |
| 14 | A home worth keeping | Restore the farmhouse fully | 60 Cleaning XP |

The story questline is on hold until the homestead stage is solid.

## Farming and crops

- Two crop kinds:
  - **Turnip** (starter): yields 1 crop and 1 seed back. 25 XP.
  - **Pumpkin** (Farming 3): yields 3 crops and 1 pumpkin seed back. 40 XP.
- Planting uses the **selected seed**. Switch it in the Inventory panel (Farming 3 and up). If you pick pumpkin before Farming 3, turnip is planted.
- Planting gives 5 XP.
- Plot two stays overgrown until Farming 2. Walking up to it says so.

## Farmhouse

- Starts at its final size in a **Decrepit** state. Repairs change its condition, not its footprint.
- Stages: Decrepit → Boarded → Patched → Restored.
- Repairs cost wood and fiber and need a Carpentry level:

| Repair to | Wood | Fiber | Carpentry |
|---|---|---|---|
| Boarded | 3 | 2 | 1 |
| Patched | 5 | 4 | 2 |
| Restored | 8 | 6 | 3 |

- The hall and bedroom are open from the start, so the bed is usable right away. Other rooms open as the house is repaired:
  - **Hall:** open from the start, with the exit mat.
  - **Bedroom:** open from the start. The bed saves and ends the day.
  - **Parlor (Patched):** a cleaning station. Tidy once a day for Cleaning XP.
  - **Study (Restored):** a desk.
- A restored house softens the night overall.
- **Cleanse** (House panel): needs Cleaning 3 and 2 harvested crops. Once a day. Lifts the sanity limit by 5 and cures part of the collapse penalty.

## Skills (RuneScape-style)

- Five skills, each with XP and levels (`Level = 1 + XP / 100`):
  - **Farming:** planting gives 5 XP. Turnips give 25 XP and pumpkins give 40 XP on harvest. Level 2 opens plot two. Level 3 unlocks pumpkins.
  - **Bushcrafting:** gathering a brush pile gives 10 XP. Level 3 adds three thicket piles.
  - **Carpentry:** each house repair gives 30 XP. Mending a board (1 wood, 1 fiber, from the House panel) gives 15 XP, capped at 2 mends per day so the house can't be finished in one day. Training to level 2 takes about 3 days, and level 3 takes about a week.
  - **Cleaning:** each daily tidy gives 20 XP. At Cleaning 2, a tidy also gives +5 sanity. Cleaning 3 unlocks the cleanse.
  - **Fishing:** face a sparkling spot on the pond edge and press Space. Each catch gives 15 XP, and the chance rises 2% per level. Spots move every 12 seconds. There are 3 spots, with one more at Fishing 3 and another at Fishing 5.
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
- Outdoors in the dark, sanity drains slowly. Indoors it recovers, faster once the house is boarded. Tidying gives +10 (+5 more at Cleaning 2), and sleeping gives +25.
- Below 30 sanity, the whole screen gets darker.
- Night events vary by day and change sanity:
  - Something at the edge of the field (−5)
  - Knocks on the house wall (−10)
  - A figure watching by the house (−15)
  - A quiet night (−3)
- The field shadow creeps closer each night.
- **Collapse penalty:** missing the bed by 03:00 lowers the sanity limit by 5 permanently. A **cleanse** (see Farmhouse) lifts it by 5 per use, once a day.

## Saving

- The game saves **only** when you sleep in bed or collapse at 03:00.
- Saved: day, skill XP, inventory, materials, stats, quests done, selected seed, lantern tier, house stage, tidy/mend/cleanse days, sanity and sanity penalty, crops (with kind), brush piles, **player position**, whether you were **inside the house**, and the **open panel**.
- Quitting mid-day loses that day's progress since the last save. Position and panel are saved at the same moment, so they reflect the last sleep or collapse.

## Deferred

- The story: beats, mystery, and horror escalation. Waiting until the homestead is solid.
- Sound and display settings (listed in Settings as coming later).

## Open decisions

- Whether the house interior should become a separate scene.
- Whether the tile map moves to a `TileMapLayer` with a real `TileSet` once art is in.
