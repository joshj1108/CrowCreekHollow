# ART-OVERHAUL-002 E1 — Asset inventory and scale reference

Audit of the production drawing code on 2026-11-06 (commit `7e1e41a` plus the working tree), with the live flags
`CONCEPT_ART`, `FARM_SPRITES`, `FLAT_FARM_ART`, `TREK_ART_V2`, `CAVE_EXT_V2` all on. Every `_draw*` function in
`scripts/` was checked for primitive drawing (`draw_rect`, `draw_circle`, `draw_line`, polygons) and for whether
that branch is reached with the flags as they are. Code behind a flag that is off (the old `FarmArt` farm, the
pre-`TREK_ART_V2` trek drawing) is a fallback and is not counted.

Legend: **Replace** = code-drawn world art to become PixelLab sprites. **Reuse** = an approved sprite already in
the repo covers it. **Retain** = procedural on purpose (light, particle, indicator, UI). **Missing** = the game state
exists but nothing at all is drawn for it under the concept farm; a sprite gives it back its appearance.

## 1. Treks (batch E2)

| Object | Code | Now | Decision |
| --- | --- | --- | --- |
| Walkers: Old Maren (mill/edge), the Tull boy (orchard), the vicar (chapel), the postman (post), the woman in the grey shawl (grove) | `trek_system.gd` `_draw_walker` | boxes and circles | **Replace**: 5 characters, 16 px wide, down/up/side walk; also used for the folk visitor on the farm |
| Feral dog | `_draw_dog` | lines and a box | **Replace**: 4-frame trot, side view, mirrored; hit flash kept as a modulate |
| The tall one | `_draw_tall` | rect and lines, red eyes | **Replace** body (3 tiles tall); the eyes stay drawn on top (they show alone outside the light) |
| Rope across the flood | `trek_art.gd` `_draw_crossing` | two lines | **Replace**: a rope-and-stake strip sprite laid along the line |
| Trail works: waymarks, gate lamp, boardwalk, waystation, chapel steps, handcart, oil tins, post lamps | `_has_work` only | **Missing** (only the footbridge shows) | **Replace** where the work has a place in a clearing: blazes at the fingerpost, oil tins at the stile, handcart at the mill, steps at the chapel, lamps on the post road, hut where the waystation rest happens, boardwalk planks on the orchard way. The gate lamp hangs on the farm's east gate |
| Crows mobbing | `_draw_layer` | V lines | **Reuse** `crow_fly.png` (the farm's crow) |
| Will-o'-lights | `_draw_layer` | glow circles | **Retain** (light effect) |
| Daytime gloom | `_tint`: `GLOOM` 0.6, `EDGE_GLOOM` 0.45, `GLOOM_DARK` 0.72 of the night tint at 11:00 | reads as night | **Fix** (Stage D review A): lighter for the art, the dark trail kept dark |
| Mill, chapel, flooded crossing, orchard | `trek_art.gd` | PixelLab, but low local contrast | **Fix** (Stage D review B): a cleared apron, contact shadow, no undergrowth against the silhouette |
| Deep-wood clutter | `trek_art.gd` `TREES` / undergrowth | busy near events | **Fix** (Stage D review C): fewer undergrowth pieces within 2 tiles of an event or destination |

## 2. Farm and homestead (batch E3)

| Object | Code | Now | Decision |
| --- | --- | --- | --- |
| Farmhouse repair stages 0–3 | concept scenery draws one P1 cabin | **Missing**: all four stages look the same | **Replace**: stage variants of the concept cabin (same footprint, door and windows), swapped by `house_stage` |
| House extensions: porch, second storey, cellar room | `estate_system.gd` `_draw_outside` | **Missing** (only drawn on the old flat farm) | **Replace**: overlay pieces on the cabin |
| Well unrepaired / repaired, cistern, hose | concept scenery: one well | **Missing** states | **Replace**: broken well (no roof, no bucket) and repaired; cistern and hose as small add-ons |
| Decor: lamp, flowers, apple tree, sprinkler, big sprinkler, fence, bench, birdbath, weathervane, torch, snare, scarecrow, shutters, crow bell | `farm_projects.gd` `_draw` (93 primitives) | code-drawn | **Replace**, except: lamp **reuses** `concept/src_lantern_post.png`, apple tree **reuses** `concept/w4_orchard_apple_a/b.png`, fence **reuses** the concept fence pieces |
| Forage on the ground (mushrooms, berries, herbs, ...) | `forage_system.gd` `_draw_one` | code-drawn by tint | **Replace**: one 16 px icon strip by food id, also used in the trek clearings |
| Daily happenings: storm oak, branch, crow gifts, flax, mushrooms, pedlar | `daily_happenings.gd` `_draw` | code-drawn | **Replace** (pedlar is a walker-scale character) |
| Night visitors and raiders, crow on the ground, wet footprints, field shadow marks | `night_system.gd` `_draw` | code-drawn | **Replace** raider and downed crow (crow **reuses** `crow_perch.png`); footprints and pulse **retain** (effects) |
| Madness figures at the screen edge | `madness_system.gd` | code-drawn | **Replace** the figure with a shadow-person sprite; the crop-that-isn't-there **reuses** crop art |
| Hens, goats | `_draw_hen_layer`, `_draw_goat_layer` | sprites (`hen_walk`, `goat_walk`) | **Reuse**; the circles below them are the no-art fallback |
| Coop, barn, workshop, stall, outbuildings, trees, rocks, brush, crops | sprites | | **Reuse** |
| Fish spots | `_draw_fish_spots` | ripples | **Retain** (indicator) |
| Placement ghost, interaction marker | | | **Retain** (UI) |

## 3. Cave and interiors (batch E4)

| Object | Code | Now | Decision |
| --- | --- | --- | --- |
| Cave geology, ore, exit, foes (bat, lizard, snake) | `cave_art.gd`, sprites | PixelLab / sprites | **Reuse** (no redesign) |
| Bought furniture: dresser, feather bed, armchair, clock, painting, bookshelf | `estate_system.gd` `_draw_furniture` (24 primitives) | code-drawn | **Replace**: one furniture strip |
| Wallpaper | `estate_system.gd` `_draw_paper` | tinted stripes | **Retain** (a tint over the wall sprite) |
| Base furniture (bed, desk, wash stand, cooler, hearth, table, chairs) | `_draw_standing` | sprites | **Reuse**; `_draw_bed_tile` and siblings are the no-art fallback |
| Doormat, rug | `_draw_doormat`, `_draw_rug_tile` | code-drawn | **Replace** with the furniture strip |
| Lit hearth glow | `draw_circle` | | **Retain** (light) |

## 4. Seasons (batch E5)

Trek trees (maple, apple, ancient) are autumn all year. The farm's trees already follow the season through
FarmScenery. E5 makes summer and winter variants of the trek maple and apple families (spring shares summer with a
lighter tint), chosen by `_season_on(day)`.

## 5. Retained procedural drawing (all locations)

Lighting masks and the lantern ring, the night tint and grade, weather (rain, snow, fog sprites already), seasonal
particles, water shimmer, fish ripples, the interaction marker and placement ghost, the will-o'-lights, hit flashes,
XP and coin pop-ups, the minimap, the section wheel and all UI, the fishing line and bobber, the tall one's eyes, the
code-drawn farmer (fallback only) and the raised-guard sword (no sheet yet, documented in DESIGN.md).

## 6. Scale reference

Measured from the art in the repository. 16 px tiles, drawn at `SCALE = 3`; one art pixel is always three screen
pixels, never resampled. Straight-on 3/4 view. Sprites stand with their bottom opaque row on the foot line of their
tile; the art may rise over tiles behind (Y-sorted by that foot line), while collision stays the map's tiles.

The farmer is the yardstick: **16 × 32 px** (bbox in a 36 px cell: 16 wide, 32 tall including the hat), about
1.75 m, so **about 18 art px per metre**.

| Class | Native size (art px) | Footprint | Rule |
| --- | --- | --- | --- |
| Adult human / NPC | 14–16 × 28–32 | 1 tile | eyes at about 6 px below the top; a bent old woman 26–28 tall, the boy 24, the vicar 32 with his hat |
| The tall one | 16 × 44–48 | 1 tile | about 1.5× the farmer |
| Dog | 22–24 × 14–16 | 1 tile | shoulder 10–11 px (a third of the farmer) |
| Hen | 16 × 16 (in 20 px cells) | 1 tile | existing |
| Goat | 32 × 24 (in 36 px cells) | 2 × 1 | existing |
| Small creature (bat, lizard, snake, crow) | 12–16 × 8–16 | 1 tile | existing |
| Fence post / gatepost | 4–10 × 16–34 | 1 tile | existing gatepost 10 × 34 |
| Shrub, fern, bramble | 16–32 × 12–24 | 1 tile | |
| Tree | 32–64 × 48–96 | 1 tile (trunk) | farm fir 48 × 96, maple 64 × 80; trek trees 32 × 48 to 48 × 64 at the edge |
| Interior furniture | chair 16 × 24, table 48 × 32, bed 32 × 47, hearth 32 × 57 | per piece | a seat 8–10 px high, a table top 12 px |
| Small tool, prop, pickup | 8–16 × 8–16 | 1 tile | handcart 27 × 21, barrel 16 × 20 |
| Rock / resource node | 16 × 16 (boulder up to 32 × 24) | 1 tile | existing |
| Building | coop 48 × 64, barn 80 × 80, workshop 112 × 96, farmhouse 192 × 160 | footprint tiles | door opening at least 14 × 26 so the farmer fits |
| Bridge, boardwalk | plank run 16 px across the trail per tile | trail tiles | at least the farmer's 16 px width |
| Large landmark (mill, chapel) | 64 × 64 to 64 × 80 | destination rect | |

Validation: `tools/scale_check.gd` (E2) loads every production sprite the game draws, checks it exists, that its
size matches the rule for its class, that its alpha is binary, and that its foot row is opaque; and
`art/style_tests/ART-OVERHAUL-002/review/scale_sheet.png` shows the farmer beside each class at 3×.

## 7. Status (2026-11-11)

- **E4:** the cave exterior (Stage B) and interior (Stage C) are reused unchanged, as decided above. The farmhouse is the
  only indoor space (the coop, barn, workshop and cellar are drawn on the farm, not entered); its six bought pieces are
  now sprites (`art/farm/e4/`: dresser 18x20, armchair 19x20, clock 18x42, painting 25x25, bookshelf 27x25, feather bed
  32x47). The doormat and rug were already sprites (`int_mat`, `int_rug`); their drawn versions are the fallback only.
  Wallpaper stays a tint, as decided.
- **E5:** done more widely than section 4 planned: the farm was autumn all year too (FarmScenery had no season), so the
  farm's deciduous pieces, its ground and the treks' atlas and grounds all follow the season (DESIGN.md, Calendar).
- **E6:** landmarks checked at one display scale (review Sheet 6); no landmark art changed.
