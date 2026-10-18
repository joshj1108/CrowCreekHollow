# Hallowvale — Design

A top-down farming game with heavy psychological horror, built in Godot 4.7.

## Pillars

- **Day is work, night is dread.** Each day is a farming shift. Night brings a horror encounter.
- **Atmosphere over jump scares.** Horror comes from lighting, sound, and escalating events.
- **Progress carries over.** Skills, quests, and fortifications persist between days and build toward a longer story.

## Controls (Stardew-style)

- Move: WASD or arrow keys
- Use tool / interact with the tile you face: Space / Enter
- Skills panel: K
- Switch tool: number keys or scroll (planned)
- Inventory menu: I (planned)

## Art

- 16×16 base tiles, scaled 3× in-game (`SCALE = 3`), nearest-neighbor filtering.
- Warm, saturated daytime palette. Night uses a cool, shadowy tint via `CanvasModulate`.
- Placeholder art is drawn in code for milestone 1. Real licensed or commissioned pixel art replaces it later without touching game logic.

## Map

- A 40×24 walkable farm surrounded by a tree border, so the camera stays centered on the player all the way to the farm's edge.
- Tile types: trees (border), grass, tilled soil (planting), path, water.

## Progression (RuneScape-style)

- Current: Farming XP. Planting gives 5 XP, harvesting gives 25 XP. Level = 1 + XP / 100.
- Planned skills: Carpentry, Foraging, Cleaning.
- Levels will unlock new areas, tools, and fortifications.
- Quests will advance the story and be gated by skill levels.
- Cleaning and Carpentry will double as horror defenses: a clean, fortified house pushes back the haunting.

## Day and night

- Each day runs from 06:00 to midnight.
- Night tint begins at 19:00. At 22:00 each night, a shadow appears at the edge of the field and creeps closer each day.
- At midnight the day ends: planted crops grow one stage, and the next day starts at 06:00.

## Milestone 1 (current)

- [x] Design document
- [x] Godot 4.7 project skeleton (`project.godot`, input map)
- [x] Farm map drawn from a 16×16 tile grid (grass, tilled soil, path, water, tree border)
- [x] Player movement with a camera that follows and stays centered
- [x] Day/night clock with a tinted night and an on-screen HUD
- [x] Planting and harvest on tilled soil, with crops that grow overnight
- [x] Farming XP and a skills panel (K)
- [x] One night event (creeping shadow)

## Open decisions

- Save system format and timing.
- Final story beats and horror escalation schedule.
- Whether the tile map moves to a `TileMapLayer` with a real `TileSet` once art is in.
- Whether the day should end at a fixed hour or only when the player goes to bed.
