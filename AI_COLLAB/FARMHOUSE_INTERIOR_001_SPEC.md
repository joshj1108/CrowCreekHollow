# FARMHOUSE-INTERIOR-001 — Complete farmhouse interior overhaul (owner brief, 2026-11-11)

Recorded by Claude Code from the owner's brief (Part B of "Survival HUD redesign and complete farmhouse interior
overhaul", plus the Restoration Progression Addendum). Part A (HUD-REDESIGN-002) was done first. Reviewer: ChatGPT.
Final visual approval: the owner. The previously approved farmhouse interior is deliberately reopened; all other
approved UI and world art stays protected.

## Objective

Turn the sparse, functional interior into a warm, cozy, detailed, believable, lived-in rural home the player looks
forward to returning to, with a subtle sense of history. Not a showroom, not a modern apartment. A full artistic
overhaul, not just the six furniture sprites. **The farmhouse should visually tell the story of the player bringing
an abandoned home back to life.**

## Layout (creative freedom, with constraints)

- Authorized to redesign the whole floor plan: furniture placement, composition, walkable space, decor, fireplace
  position, windows, furnishings, wall details, room transitions where the architecture supports them.
- Before changing layout, inspect every interior interaction coordinate, bed/sleep logic, fireplace/hearth
  mechanics, furniture purchase and placement, upgrade stages, spawn and exit, collision, save/load, quest
  triggers and accessibility. Coordinates and collision may change; every feature, purchase, unlock and progression
  must survive. Do not remove or bypass furniture upgrades. A layout mapping layer is fine if it helps.
- **A beautiful interior that breaks interaction or progression is not acceptable.**
- Architecture: floorboards, timber walls, baseboards and trim, beams, stone fireplace and chimney, window and door
  frames, dividers, wall decoration, environmental shadows. No large empty rectangles.
- Recognizable areas (open plan is fine): living (fireplace, seating, rug, side table, books, candles, wall decor);
  sleeping (bed or its upgrade, bedside table, soft furnishings, chest or wardrobe, window and curtains); dining or
  practical (small table, chairs, shelving, supplies, rustic objects).

## Fireplace (major redesign, the focal point)

- Weathered stone or brick, defined hearth, mantel, visible firebox, ash and soot, logs, shadows, subtle highlights;
  built into the house at the right scale.
- Lit: animated flames, subtle embers, occasional small sparks, gentle intensity variation, no obvious 3-frame loop,
  no huge flames, no orange overlay over half the room, no magical particles.
- Real in-engine light when burning (Godot 2D lights): warm amber, lights nearby furniture and walls, gentle flicker,
  natural falloff. Unlit = no firelight. Lit/unlit logic, fuel use and survival benefits unchanged.

## Candles and other lights

- Every lit candle: animated flame, small warm Light2D radius, subtle brightness variation, independently
  controllable, desynchronised timing. No single giant ambient glow; no overexposure when several are close.
- Existing lanterns, lamps and practical lights behave consistently. The house is not uniformly lit.

## Windows and curtains (major new feature)

- Wooden frames, panes, sills, latches or hinges, rods, fabric curtains, subtle reflections; placed to match the
  exterior farmhouse's windows.
- Spring to autumn, pleasant weather (sunny/mild/dry, no storm): open, curtains moving gently (soft loop with small
  variations), subtle outdoor light, seasonal colour beyond the glass.
- Rain, strong wind, storms: closed, curtains settled, rain on the glass where fitting, muted outdoor light.
- Winter: closed, slightly fogged glass, delicate pixel-art frost at the edges, cool outside vs warm inside.
- Driven by season, weather, temperature where available, time of day. Atmospheric only: no health, comfort,
  temperature or energy effects.

## Environmental animation

Fire, embers, candles, curtains, rain through windows, very subtle light variation, the bought clock's pendulum,
other sensible small details. Furniture, books and static objects stay still. Pixel-perfect, consistent scale,
cheap, desynchronised loops.

## Restoration progression (core requirement, from the addendum)

- **Stage 0, decrepit:** broken or missing floorboards, exposed subfloor, torn wallpaper, damaged plaster, cobwebs,
  dust, stains, boarded or broken windows, tattered curtains, worn furniture, cold soot-covered fireplace. Abandoned,
  drafty, slightly unsettling; pathways and interactions stay safe and readable.
- **Stage 1, initial repairs:** reflect the repairs actually bought: patched floors, stabilised walls, debris gone,
  windows improved where repaired; some deterioration remains.
- **Stage 2, livable:** repaired floors, cleaner walls, working windows, presentable curtains, more comfortable
  details; the lit fireplace starts to carry the room.
- **Stage 3, fully restored:** finished wood floors, rustic walls, substantial stone fireplace, rugs, shelving,
  decor, warm lighting, curtains, bought furniture; lived-in, personal, full of history, not pristine or modern.
- Where individual repairs or purchases exist, update their elements immediately (floor repairs remove broken
  boards, wall repairs replace damaged paper, window repairs remove boards and restore glass, furniture purchases add
  their sprites, hearth restoration improves its construction without changing fire mechanics, cleaning removes
  cobwebs and dust). Map everything to existing progression flags: no new costs, requirements, stages or penalties.
- Lighting and ambience develop too: early stages colder and exposed, later warmer and sheltered. Damaged windows do
  not behave like restored ones; seasonal opening, breeze and frost appear as windows are repaired.
- Never show furniture before it is bought. Clutter may grow with restoration but must not block movement or
  interactions. Preserve purchase requirements, unlocks, costs, room restoration, saves, quests, sleep.

## Art production

- Authorized to create, regenerate, replace and refine interior art: PixelLab, existing SpriteCook assets,
  hand-made pixel art, procedural scripts, Pixelorama-compatible PNGs. Not restricted to code-drawn shapes.
- Match the approved farm and house art: perspective, pixel density, proportions, palette, outline weight,
  texture, lighting direction, materials. Verify each asset's native size. Keep editable sources or reproducible
  scripts. **No new additional charges without authorization** (PixelLab subscription generations only, as before).

## Technical

- Keep appearance separate from gameplay state; derive visual state from existing data, no redundant persistent
  data; save compatibility kept. Use existing scripts where clean (e.g. interior visual state, fireplace light,
  candle light, seasonal window, curtain animation). Efficient: shared animations, Light2D, texture reuse, no
  per-frame texture rebuilds, no unbounded particles. Do not change approved outdoor lighting or the main menu.

## Review package (in-engine captures only)

2. Farmhouse layout: stage 0, intermediate, fully restored; navigation; furniture and decor; before/after.
3. Fireplace and lighting: unlit, lit, candles on, night interior, several lights together; enlarged native-pixel
   crops.
4. Windows and seasons: spring, summer, autumn pleasant (open); rain (closed); winter (fogged, frosted).
5. Animation: frame sequences and short GIFs from the running game for fire, candles, curtains, clock pendulum,
   window state changes.
6. World integration: player inside, at the bed, at the fireplace, bought furniture, night, outside-to-inside.
7. Art and technical validation: new sprites, native and in-game sizes, sheets, light textures, window and furniture
   variants, collision and interaction validation.
Plus a **restoration comparison: the same interior camera position across all four stages.**

## Testing

Menu, layout, save, diary, Section Wheel, farmhouse progression, furniture purchase, interior interaction,
seasonal/window state, lighting and animation checks. No blocked paths; bed, fireplace, spawn and exit correct; no
duplicate or lost furniture after loading; correct window states, candle and fire light; no major FPS regression.

## Documentation and finish

Update `AI_COLLAB/MESSAGE_BOARD.md`, `AI_COLLAB/TASKS.md`, `DESIGN.md` and the art inventory (layout, sprite
methods, assets, lighting, animation, window/weather behaviour, files, tests, limits, commit SHA, review image
locations). Do not delete earlier records. Commit; stop after the review package is complete.
