# Hallowvale — Design

A top-down farming game with heavy psychological horror, built in Godot 4.7.

## Pillars

- **Day is work, night is dread.** Each day is a farming shift. Dusk ends the day and the night brings a horror encounter.
- **Atmosphere over jump scares.** Horror comes from lighting, sound, and escalating events.
- **Progress carries over.** Skills, quests, and fortifications persist between days and build toward a longer story.

## Controls (Stardew-style)

- Move: WASD or arrow keys
- Use held tool: Space / Enter (planned)
- Switch tool: number keys or scroll (planned)
- Inventory and skills menu: I / K (planned)

## Art

- 16×16 base tiles, scaled 3× in-game (`SCALE = 3`), nearest-neighbor filtering.
- Warm, saturated daytime palette. Night uses a cool, shadowy tint via `CanvasModulate`.
- Placeholder art is drawn in code for milestone 1. Real licensed or commissioned pixel art replaces it later without touching game logic.

## Progression (RuneScape-style, planned)

- Skills with XP and levels: Farming, Carpentry, Foraging, Cleaning.
- Levels unlock new areas, tools, and fortifications.
- Quests advance the story and are gated by skill levels.
- Cleaning and Carpentry double as horror defenses: a clean, fortified house pushes back the haunting.

## Milestone 1 (current)

- [x] Design document
- [ ] Godot 4.7 project skeleton (`project.godot`, input map)
- [x] Farm map drawn from a 16×16 tile grid (grass, tilled soil, path, water)
- [x] Player movement with a camera that follows and stays inside the map
- [x] Day/night clock with a tinted night and an on-screen HUD
- [ ] One planting and harvest interaction
- [ ] One skill with XP
- [ ] One night event

## Open decisions

- Save system format and timing.
- Final story beats and horror escalation schedule.
- Whether the tile map moves to a `TileMapLayer` with a real `TileSet` once art is in.
