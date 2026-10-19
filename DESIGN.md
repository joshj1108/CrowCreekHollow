# Hallowvale — Design

A top-down farming game with heavy psychological horror, built in Godot 4.7.

## Pillars

- **Day is work, night is dread.** Each day is a farming shift. Night brings a horror encounter.
- **Atmosphere over jump scares.** Horror comes from lighting, sound, and escalating events.
- **Progress carries over.** Skills, the house, and gear persist between days and build toward a longer story.

## Controls (Stardew-style)

- Move: WASD or arrow keys
- Use, plant, harvest, gather, or enter the house panel: Space / Enter (face the tile)
- Action bar (click or key): Skills K, Inventory I, Gear G, House H, Settings
- Esc opens Settings, or closes it if it's already open
- Farming and gathering pause while a panel is open
- Switch tool: number keys or scroll (planned)

## Action bar

- Tab buttons along the bottom. A panel opens above the bar for the active tab.
- Each panel lists rows: name, value, and optional buttons or XP bars.
- Panels are rebuilt only when their content changes, so buttons don't disappear mid-click.

## Art

- 16×16 base tiles, scaled 3× in-game (`SCALE = 3`), nearest-neighbor filtering.
- Warm, saturated daytime palette. Night uses a cool, shadowy tint via `CanvasModulate`.
- Placeholder art is drawn in code. Real licensed or commissioned pixel art replaces it later without touching game logic.

## Map

- A 40×24 walkable farm surrounded by a tree border, so the camera stays centered on the player all the way to the farm's edge.
- Tile types: trees (border), grass, tilled soil, path, water, house.
- Trees, water, the house, and brush piles block movement. The player slides along walls.
- A minimap in the top-right shows the whole map, the house, brush piles, the player, and the shadow on event nights.

## Farmhouse

- Starts at its final size in a **Decrepit** state. Repairs change its condition rather than its footprint.
- Stages: Decrepit → Boarded → Patched → Restored.
- Repairs cost wood and fiber and need a Carpentry level:

| Repair to | Wood | Fiber | Carpentry |
|---|---|---|---|
| Boarded | 3 | 2 | 1 |
| Patched | 5 | 4 | 2 |
| Restored | 8 | 6 | 3 |

- Unlocks:
  - **Boarded:** sleep in bed from 18:00 to end the day early.
  - **Patched:** tidy the house once a day for Cleaning XP.
  - **Restored:** a restored house softens the night.
- Planned: an interior you can walk through, with rooms unlocked by stage.

## Skills (RuneScape-style)

- Four skills, each with XP and levels (`Level = 1 + XP / 100`):
  - **Farming:** planting gives 5 XP, harvesting gives 25 XP.
  - **Bushcrafting:** gathering a brush pile gives 10 XP. Replaces the earlier "Foraging" idea. Ties into survival.
  - **Carpentry:** each house repair gives 30 XP.
  - **Cleaning:** each daily tidy gives 20 XP.
- Levels will unlock new areas, tools, and fortifications.
- Quests will advance the story and be gated by skill levels.
- Cleaning and Carpentry will double as horror defenses: a clean, fortified house pushes back the haunting.

## Survival (bushcrafting)

- Brush piles on the farm give wood and fiber. They respawn each morning.
- A **lantern** (Gear panel, needs Bushcrafting 2) lights a small ring around the player at night. Only the ring is lit, not the whole screen.
- Planned: lantern upgrades with higher Bushcrafting and better materials, each giving a larger ring.
- No hunger or thirst. Survival comes from gathering, building, and keeping shelter.

## Day and night

- Each day runs from 06:00 to midnight.
- Night darkness starts at 19:00. At 22:00 each night, a shadow appears at the edge of the field and creeps closer each day.
- Sleep in bed (from 18:00, after the house is boarded) to end the day early.
- At midnight the day ends: crops grow one stage, brush piles respawn, and the next day starts at 06:00.

## Milestone 1 (current)

- [x] Design document
- [x] Godot 4.7 project skeleton (`project.godot`, input map)
- [x] Farm map drawn from a 16×16 tile grid, with a tree border
- [x] Player movement with collision and a camera that stays centered
- [x] Day/night clock with a tinted night and an on-screen HUD
- [x] Planting and harvest on tilled soil, with crops that grow overnight
- [x] Skills: Farming, Bushcrafting, Carpentry, Cleaning
- [x] Action bar with Skills, Inventory, Gear, House, and Settings panels
- [x] Seeds, crops, wood, and fiber in the inventory
- [x] Brush piles to gather for bushcrafting
- [x] Farmhouse in its decrepit state, with repairs and unlocks
- [x] Minimap
- [x] One night event (creeping shadow)

## Open decisions

- Save system format and timing.
- Final story beats and horror escalation schedule.
- Whether the house interior should be a separate scene.
- Whether the day should end at a fixed hour or only when the player goes to bed.
- Whether the tile map moves to a `TileMapLayer` with a real `TileSet` once art is in.
