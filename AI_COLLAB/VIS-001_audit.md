# VIS-001 — Farm visual audit

**Author:** Claude Code · **Date:** 2026-11-01 · **Base commit:** `68f9121` · **State:** review requested
**Approval:** owner approved the read-only audit in chat on 2026-11-01. Nothing below is approved for implementation.

No production art, code or saves were changed. Measurements came from a throwaway script run outside the repo that loads each PNG with Godot's `Image`. Screenshots come from `tools/capture.gd`.

**Fact** = seen in the code, files or screenshots. **Proposal** = my suggestion, not approved.

## Screenshots

Every shot: Autumn, overcast, house stage 2 (Patched), Tin Lantern, standing below the porch (`tile=24,15`). Saved at half size in `art/style_tests/vis001/` (not committed):

| Time | File | What it shows |
| --- | --- | --- |
| 12:05 | `farm_h12.png` | Daylight. Neutral overcast tint, a heavy vignette, small ground shadows under the bushes. |
| 19:35 | `farm_h19.5.png` | Dusk. The tint is already sliding toward blue. The lantern pool is on, a smooth round yellow-green blob. |
| 22:35 | `farm_h22.5.png` | Night. A dark blue tint, a readable lantern pool, **and pale grey cloud blobs over the house that are brighter than the ground** (see L-1). |

This framing cuts off the top of the house, so I couldn't check the window glows here. The next comparison set needs a frame that shows the whole front of the house.

## 1. Asset and perspective consistency

I measured all 79 PNGs in `art/farm/` and 33 in `art/player/`.

| ID | Finding (fact) | Files | Severity |
| --- | --- | --- | --- |
| A-1 | **Five unused pre-SpriteCook tiles.** They are 64×64, fully opaque, 3,000–3,700 colours each, and were cut from the old 32 px tileset on 2026-10-24. No script loads them and they are missing from `spritecook-assets.json`. | `art/farm/house_door.png`, `house_roof_bottom.png`, `house_roof_top.png`, `house_wall.png`, `porch.png` | Low: they ship in the build but are never drawn |
| A-2 | **The farmhouse has far more colours than any other sprite**: 3,635 / 7,816 / 10,358 / 5,564 for stages 0–3, against 5–31 for props, trees, buildings and characters. Stages 1–2 were made as edits of stage 0, and each edit added more in-between colours. Gentle gradients like these read as softer than the hard-edged props next to it. | `art/farm/house_stage_0..3.png` | Medium: needs a close-up check against the style anchor |
| A-3 | **The ground and cave tiles are also high-colour** (grass 602, soil 751, path 849, fallow 1,208, water 1,125, cave floor 587, cave wall 364). This is normal for SpriteCook dual-grid tilesets, and in the daytime shot the grass reads as fine noise rather than visible banding. | `art/farm/ground_*.png`, `cave_floor.png`, `cave_wall.png` | Low: watch only |
| A-4 | **Saturation outliers.** Average saturation is 0.63–0.69 for the oaks, 0.79 for pumpkin, 0.76 for corn, 0.78 for leaves, 0.60 for the stall, 0.62 for the stump and 0.64 for clutter. Firs, rocks, fences and the outbuildings sit at 0.05–0.47. The grade scales everything by 0.62, so these stay the brightest things on screen. That may be on purpose (autumn colour, crops as the focal point). | `tree_oak_*`, `crop_pumpkin`, `crop_corn`, `weather_leaves`, `prop_stall`, `prop_stump`, `clutter` | Owner decision |
| A-5 | **Some outlines are lighter than the "dark outlines on every sprite" rule.** About 85–100% of edge pixels are dark on almost every sprite, but only 57% on `boulder_2`, 58% on `cave_exit` and 61% on `cave_mouth`. | those three | Low |
| A-6 | **Some frames aren't whole tiles.** Farmer cells are 36×36 (a 16×32 figure with padding), hens and goats 20×20 and 36×36, foes 16×20, and interior pieces are cropped to 29, 57 and 24 px tall. These are padded animation cells or crops, which the "multiples of 16 where they can be" rule allows. | `art/player/*`, `hen_walk`, `goat_walk`, `foe_*`, `int_furniture`, `int_hearth`, `int_chairs` | None: only matters if the draw offsets aren't snapped |
| A-7 | **Perspective.** In the screenshots, the house, stall, fence, rocks, bushes and farmer are all straight-on 3/4 with fronts facing the camera, and nothing is isometric. I haven't yet checked every sprite side by side. | — | Next step: a contact sheet with `tools/sheet.ps1` |
| A-8 | **The pixel scale is not whole-number at 1080p.** The game is 1280×720 with `stretch/mode="canvas_items"` and `aspect="expand"`, so at 1920×1080 each art pixel becomes 4.5 screen pixels, which makes some pixel rows and columns uneven. 1440p (6 px) and 4K (9 px) come out whole. This breaks "one art pixel is always three screen pixels" on the most common Steam resolution. | `project.godot` | Medium: owner decision |
| A-9 | **The grade's film grain uses screen pixels**, not 3-pixel art pixels, so it's finer than the art it sits on. | `shaders/grade.gdshader` | Low |

Every outline, palette and size check passed except the items above. The SpriteCook registry covers every drawn file in `art/farm/` and `art/player/`.

## 2. What the game already uses for light and atmosphere (all facts)

| System | Where | How it works |
| --- | --- | --- |
| Day/night tint | `main.gd` ~L1230, `CanvasModulate` built ~L1908 | `darkness = smoothstep(19, 21, hour)`, adjusted by sanity (`_night_relief`, `_low_sanity_boost`). The colour moves from `WEATHER_LIGHT[weather]` (near-white, per weather) to `NIGHT_TINT #3a3f6e`. There is **no separate dusk colour**: it goes straight from grey-white to blue. |
| Cave and trek tint | `CAVE_TINT #050508`, `trek._tint()` | Near-black. The lantern is boosted ×4 in the cave. |
| Light falloff | `_glow_texture()` | One 256 px white-to-black radial `GradientTexture2D` with smooth interpolation, shared by every light. |
| Lantern | `_build_lantern_light`, `_update_lantern` | `PointLight2D` on the player, `#ffd38a`, energy 0.5. The radius follows the tier (2.5 / 4 / 6 tiles). It flickers at tier 3 and turns on above darkness 0.05. |
| Windows and porch | `_build_window_lights` | Two `#ffc878` lights on the house sprite's windows (`HOUSE_SPRITE_WINDOWS`) from stage 2, and a porch lamp at stage 3. Energy 0.45 × (0.6–1.0). They sit on the wall, so they don't light the ground in front. |
| Homestead lamps | `farm_projects.gd` L343–388 | One `PointLight2D` per lamp tile, energy follows darkness. |
| Story and night lights | crow roosts (red), desk post light (red), night visitor (`night_system.gd`, red or pale), cave mouth daylight (`#c8d4e0`) | All `PointLight2D`, toggled on and off. |
| Shadows | `main.gd` draw pass two (~L1342), `farm_art.gd` | Code-drawn soft shapes under trees, rocks and brush, plus crow shadows from their height. **No light casts shadows**: no `LightOccluder2D` and no `shadow_enabled`. |
| Colour grade | `shaders/grade.gdshader` on CanvasLayer 0 | Saturation 0.62, exposure 0.84, contrast 1.1, warm highlights, cool shadows, vignette 0.55, grain. |
| Weather overlay | `scripts/weather.gd`, **its own CanvasLayer** | A grey wash, an edge darkening, cloud shadows (`weather_cloud` shaded to `(0.18,0.2,0.24)`), fog, rain and snow. |
| Particles | `main.gd`, `game_feel.gd` | Leaves, petals, fireflies (summer dusk) and action bursts. |
| Renderer | `project.godot` | `gl_compatibility`, nearest filtering. |

### L-1: Bug — cloud shadows and the weather wash ignore the night (fact)

`weather.gd` is a `CanvasLayer`, so the world's `CanvasModulate` doesn't reach it. By day, cloud shadows and the grey wash darken the scene as intended. At night they are drawn at full brightness over a world tinted `#3a3f6e`, so the "shadows" come out **lighter** than the ground. You can see this in `farm_h22.5.png`. Fog and the overcast wash brighten the night in the same way. This goes against "the horror comes from lighting and the night tint" and reads as a mistake rather than a design choice.

## 3. Lighting and atmosphere plan using Godot's built-in features (proposal)

Keep the stack the game already has (CanvasModulate, PointLight2D and the grade pass). Don't add normal maps, `LightOccluder2D` shadows or a 3D environment:

- **Normal maps** would need a second set of art for every sprite, and SpriteCook doesn't make them. In a straight-on 3/4 view, sprite lighting that changes with the light's direction tends to look out of place.
- **Occluder shadows** are drawn from the top-down floor outline. In a 3/4 view they cut the wrong way across sprite fronts, and on `gl_compatibility` every light that casts shadows adds an extra render pass.
- **Cost today:** about 4–8 lights are visible at most, and each 2D light is one extra pass over the items it touches. That's cheap. The plan below adds no new lights and changes no light radii.

The plan:

1. **Make the weather overlay follow the night (fixes L-1).** Darken or tint the cloud and wash colours by the current `canvas_modulate.color`, or reduce their alpha by `(1 − darkness)`. This is one function in `weather.gd` plus one call from `main.gd`.
2. **Pixel-stepped light falloff.** Give `_glow_texture()` 4–5 hard bands (`Gradient.interpolation_mode = GRADIENT_INTERPOLATE_CONSTANT`) and snap light positions to the 3 px art-pixel grid. Light pools then step the way pixel-art lighting does, rather than smooth airbrushed circles. Lantern radii stay as they are.
3. **A dusk colour.** Change the tint from two colours to three: day → amber/rose at about 19:30 → `NIGHT_TINT` at 21:00. The timing and `darkness` stay exactly the same (sanity and lantern logic depend on `darkness`, not on the colour).
4. **Window light spill.** Move the window and porch lights about one tile down so the warm light falls on the porch and ground rather than on the wall. Same energy.

What stays baked into the sprites: outlines, form shading, the colours of materials, and a top-left key light. What Godot handles: time of day, weather tone, lamp and lantern pools, colour grading, and story lights. Nothing in the sprites needs to be redrawn for this plan.

## 4. First implementation proposal (reversible) and screenshot plan

- **Scope:** items 1–4 above, behind one `const LIGHTING_V2 := true` in `main.gd`. Setting it to false brings back today's exact look. No gameplay changes, nothing saved, no new art and no new lights.
- **Files:** `scripts/main.gd` (`_glow_texture`, the tint lerp near L1233, `_build_window_lights`), `scripts/weather.gd` (cloud and wash colour).
- **Checks:** `tools/save_test.gd` and `tools/menu_test.gd` must still pass. No balance sim is needed because `darkness` doesn't change.
- **Screenshot comparison:** take matching before/after pairs with `capture.gd` using `LIGHTING_V2` false and true, at hours 12, 19.5, 20.5 and 22.5, with `stage=2` and `stage=3` in a frame that shows the whole house front. Also take one rain shot at 22.5 and one cave shot. Put them side by side with `tools/sheet.ps1` into `art/style_tests/vis001/compare_*.png` and link them on the message board.

## 5. Decisions needed from the owner

1. **Slice scope:** approve items 1–4 as one slice, or only some of them? Item 1 is a bug fix and could go in on its own.
2. **A-1:** delete the five unused 64×64 tiles, or move them to `art/style_tests/`?
3. **A-8:** keep fractional scaling at 1080p, or switch to integer scaling (`window/stretch/scale_mode="integer"`, which leaves borders or shows more of the map)? This touches the camera, which is locked, so it needs your call.
4. **A-4:** are the saturated oaks, crops and stall intended as focal points, or should they be toned down when those sprites are next redone?
5. **A-2:** should I compare the house stages close up against the style anchor before any lighting work? Its soft shading will look different under stepped light.
