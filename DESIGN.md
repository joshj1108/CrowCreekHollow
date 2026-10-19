# Hallowvale — Design

A top-down farming game with heavy psychological horror, built in Godot 4.7.

## Pillars

- **Day is work, night is dread.** Each day is a farming shift. Night brings a horror encounter.
- **Atmosphere over jump scares.** Horror comes from lighting, sound, and escalating events.
- **Progress carries over.** Skills, the house, gear, and sanity persist between sessions and build toward a longer story.

## Controls (Stardew-style)

- Move: WASD or arrow keys
- Use, plant, harvest, gather, sleep, tidy, or read: Space / Enter (face the tile)
- Walk into the farmhouse door to go inside. Walk onto the exit mat to leave.
- Action bar (click or key): Skills K, Inventory I, Gear G, House H, Settings
- Esc opens Settings, or closes it if it's already open
- Farming and gathering pause while a panel is open

## Action bar

- Tab buttons along the bottom. A panel opens above the bar for the active tab.
- Each panel lists rows: name, value, and optional buttons or XP bars.
- Panels rebuild only when their content changes, so buttons don't disappear mid-click.

## Art

- 16×16 base tiles, scaled 3× in-game (`SCALE = 3`), nearest-neighbor filtering.
- Warm, saturated daytime palette. Night uses a cool, shadowy tint via `CanvasModulate`.
- Placeholder art is drawn in code. Real licensed or commissioned pixel art replaces it later without touching game logic.

## Map

- A 40×24 walkable farm surrounded by a tree border, so the camera stays centered on the player all the way to the farm's edge.
- Trees, water, the house walls, and brush piles block movement. The player slides along walls.
- A minimap in the top-right shows the whole farm, the house, brush piles, the player, and the shadow on event nights.
- The farmhouse interior sits below the farm and has its own camera bounds.

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
  - **Bedroom (Boarded):** a bed. Sleep there from 18:00 to end the day early.
  - **Parlor (Patched):** a cleaning station. Tidy once a day for Cleaning XP.
  - **Study (Restored):** a desk with old letters. They're part of the story.
- A restored house softens the night overall.

## Skills (RuneScape-style)

- Four skills, each with XP and levels (`Level = 1 + XP / 100`):
  - **Farming:** planting gives 5 XP, harvesting gives 25 XP.
  - **Bushcrafting:** gathering a brush pile gives 10 XP. Survival-focused.
  - **Carpentry:** each house repair gives 30 XP.
  - **Cleaning:** each daily tidy gives 20 XP.
- Levels will unlock new areas, tools, and fortifications.
- Quests will advance the story and be gated by skill levels.

## Survival (bushcrafting and lanterns)

- Brush piles on the farm give wood and fiber, and sometimes resin. They respawn each morning.
- Lanterns are built in the Gear panel. Each tier lights a ring around the player in the dark, and only the ring is lit:

| Tier | Ring | Needs | Bushcrafting |
|---|---|---|---|
| Tin Lantern | 2.5 tiles | 2 wood, 2 fiber | 2 |
| Brass Lantern | 4 tiles | 4 wood, 4 fiber, 2 resin | 4 |
| Hollow Lantern | 6 tiles, flickers | 6 wood, 6 fiber, 4 resin | 6 |

- No hunger or thirst. Survival comes from gathering, building, and keeping shelter.

## Sanity and horror

- Sanity runs from 0 to 100 and shows in the HUD.
- Outdoors in the dark, sanity drains slowly. Indoors it recovers. Tidying gives +10, and sleeping gives +25.
- Below 30 sanity, the whole screen gets darker, a visible warning.
- Night events vary by day. Each one can move the shadow and changes sanity:
  - Something at the edge of the field (−5)
  - Knocks on the house wall (−10)
  - A figure watching by the house (−15)
  - A quiet night (−3)
- The shadow creeps closer to the farm each night.

## Story beats

- One-off messages appear on the morning of set days (day 3, 7, and 12 so far). They're placed in the DESIGN doc so the story can be planned in one place.

## Day and night

- Each day runs from 06:00 to midnight.
- Night darkness starts at 19:00.
- Sleep in the bedroom (from 18:00) to end the day early.
- At midnight the day ends: crops grow one stage, brush piles respawn, sanity is kept, and the next day starts at 06:00.

## Saving

- Progress saves automatically every 30 seconds, at the end of each day, and when the game closes.
- Saved: day and time, skill XP, inventory, materials, lantern tier, house stage, sanity, crops, and brush piles.
- Not saved yet: the player's position and which panel is open.

## Milestone 1 (current)

- [x] Design document
- [x] Godot 4.7 project skeleton (`project.godot`, input map)
- [x] Farm map drawn from a 16×16 tile grid, with a tree border
- [x] Player movement with collision and a camera that stays centered
- [x] Day/night clock with a tinted night and an on-screen HUD
- [x] Planting and harvest on tilled soil, with crops that grow overnight
- [x] Skills: Farming, Bushcrafting, Carpentry, Cleaning
- [x] Action bar with Skills, Inventory, Gear, House, and Settings panels
- [x] Brush piles to gather for bushcrafting, with resin
- [x] Lantern tiers with a light ring that flickers at the top tier
- [x] Farmhouse: decrepit to restored, with rooms that open as it's repaired
- [x] Walk-in farmhouse interior
- [x] Sanity meter with night events and story beats
- [x] Minimap
- [x] Save and load

## Open decisions

- Final story beats and horror escalation schedule.
- Whether the day should end at a fixed hour or only when the player goes to bed.
- Whether the tile map moves to a `TileMapLayer` with a real `TileSet` once art is in.
- Save the player's position, and which panel is open?
