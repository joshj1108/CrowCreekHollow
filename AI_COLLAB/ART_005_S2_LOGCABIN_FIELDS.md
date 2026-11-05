# ART-005 S2: SA log-cabin farmhouse, restoration stages, porch/storey retirement and small fields (design comparison)

Status: **for the owner's and ChatGPT's image-level review. Non-production only.**

- **Spend:** zero generations. PixelLab 0 (no calls at all), SpriteCook 0, USD 0. Every new pixel is placed by script.
- **Not changed:** production art, the live farm and layout, gameplay, saves (real or test), camera, scale, production night lighting, `DESIGN.md`, the porch and second-storey code, farmhouse stages in the game. M0, M1, H1, S1 (SA/SB), W-4 and VIS-002 are untouched (VIS-002's uncommitted files were not staged; the field captures ran in a `git archive` export of HEAD `424437f`, so they have no VIS-002 work in them).
- Tags: **[Measured]** = from pixels, code or a check; **[Judgement]** = my opinion.

## 1. SA log-cabin farmhouse proposal

`tools/art005_s2.py` takes the S1 SA sprite (`pl/g4/sa/32/`, read only) and replaces **only the wall and the corner posts**. Roof, chimney, windows, door, lamp, foundation, steps, canvas (384 × 320), roofline and footprint are SA's, pixel for pixel. Output: `art/style_tests/ART-005/pl/g5/log/32/`, shown in the harness with `art=g5 var=log`.

Treatment:
- **Logs:** 8 courses from the eave (y 160) to the stone foundation (y 280), 14–16 px each, so each log is about half a tile. Each course has a 1 px dark recessed seam, a lit upper curve, a mid body with long grain streaks (6–34 px runs, not per-pixel noise), a shaded underside and 1–2 small knots. Two close brown ramps alternate by log, so neighbours differ without noise.
- **Corners:** the plank corner posts are replaced by notched log ends, one per course, alternating 3 px in and out. Each has end-grain rings, a bark rim and an upper-left highlight. They stick out up to 8 px, inside the roof's existing overhang.
- **Occlusion:** the logs darken a step under the sills and to the right of the window and door trims.
- Colours [Measured]: 77 in the log sprite (SA 21). Opaque pixels +1,974 (the log ends only); nothing removed.

Evaluation [Judgement]:
- **Silhouette and balance:** unchanged from SA. The log ends give the walls a stronger frame, and the house now reads as a cabin at 720p, not a generic plank house.
- **Log proportions:** about right at 32 px. At 720p each log is about 22 screen px, and the courses stay countable. Thinner logs would turn into stripes; thicker ones would look toy-like next to the windows.
- **Roof readability:** the slate roof is now the weakest part. Its 12 px blue-grey courses are busy beside the warm logs, and it is still about 40% of the silhouette. A wood-shake or darker, quieter roof is the obvious next lever. I did not change it, so that this sheet isolates the wall.
- **Material density:** the logs are denser than SA's planks but still controlled. The end grains read as a column of coins at 1:1. A real notch, with the side log's end showing between the front logs, would read better, and that is a job for an artist or a generator.
- **Night:** under the harness night the logs keep their banding faintly, the lit windows anchor the facade, and the log ends catch a little window light. Mysterious enough. Nothing about the night treatment changed.
- **Verdict:** a believable direction, not premium art. It proves the structure and proportions. Material finish (grain, end-grain notching, roof) is what a paid step would add.

## 2. Four-stage restoration plan (schematic)

`pl/g5/st0` … `st3` are **schematic mockups** on the log house. They test the matrix, and they are not candidate art. Fixed in every stage: roofline, eave, chimney position, footprint, door opening, window openings and centres, foundation and steps footprint. They map one to one onto `STAGE_NAMES` (Decrepit, Boarded, Patched, Restored).

| | 0 Dilapidated | 1 Stabilized | 2 Repaired | 3 Restored |
|---|---|---|---|---|
| Roof | three holes along the slate courses showing laths, rafters and the dark attic; slipped slates; heavy moss | holes under tarred planks and a weighted canvas tarp; moss | holes re-slated in a fresher tone; one plank patch remains | complete |
| Chimney | top courses broken, no cap | capped | capped | capped |
| Logs | 70% weathered grey; rot streaks under the windows; one broken log open to the dark | 40% grey; the broken log braced with two nailed boards | warm logs; three runs of fresh replacement timber | even weathered logs |
| Windows | one smashed and dark, one crossed with two boards | both boarded | glazed, lit at night | glazed and lit; flower boxes |
| Door | grey, hanging off its top hinge | Z-brace | plain | plain; the lamp is the existing `porch_light` |
| Steps | a tread missing, cracks | a plank over the gap | sound | sound; pots of flowers |
| Dressing | vines up the corners and by the door, weeds, a fallen board | a few vines and weeds | a few tufts | firewood stack by the door, flower boxes, pots |

[Measured] Silhouettes against SA (`s2_stages_sprites.png`): the roofline, eave and openings are identical in all four. The only removed pixels are stage 0's broken chimney top. The added pixels are the log ends and the dressing below the wall.

[Judgement] The four stages read apart at 720p by day: holes, then patches, then two-tone timber, then flowers. At night, stages 0 and 1 are almost the same dark house. Stage 1's planned lamplight between the window boards **did not show**, which is a defect in my mockup (the boards came out dark). In production that light leak is the cheapest way to tell stage 1 from 0 at night. The stage 0 roof holes are hard rectangles. Real art would need ragged edges and slipped slates.

## 3. Porch and second-storey retirement (audit and plan; nothing removed)

The full line-by-line audit is in `ART_005_S1_SIMPLIFICATION.md` §5, and I re-checked it against the current code [Measured]:

- **Flags and save:** `estate.built` is a list of ids, saved at `save_system.gd:106` and loaded at `:212`. `_from_save` (`estate_system.gd:93-95`) **silently drops unknown ids**, which is the main hazard.
- **Costs:**
  - porch: 1,200 coins, 60 wood, 40 hardwood, 40 copper bars, Carpentry 6;
  - second storey: 3,000 coins, 100 wood, 80 hardwood, 60 stone, 60 copper, 20 iron, 60 crow feathers, Carpentry 8, and it needs the porch.
- **Benefits:**
  - porch: stand demand ×1.25 (`stall_system.gd`), +2 sanity each morning;
  - second storey: +6 sanity per sleep, night loss ×0.9 (`sanity_system.gd:30`, `night_system.gd:921`);
  - each adds 15% to property value (`desk_system.gd:233`).
- **Achievement:** `ACH_EXTENDED`. Its goal is `EXTENSIONS.size()`, and it is published on Steam.
- **UI:** the House → Extensions tab (`panel_rows.gd:645-668`) and the `ext:` action (`main.gd:3283`).
- **Tools:** `balance_sim`, `save_test`, `capture`.
- **Drawing:** `_draw_outside` only. **No collision, tile or interaction depends on either.**

Save-compatible migration plan (proposed, for a separate authorization):

1. **Never delete the ids.** `porch` and `second_storey` stay in `EXTENSIONS` (or in a `RETIRED` table that `_from_save` also accepts), so old saves keep their purchases.
2. **Step 1, cosmetic re-dress (recommended first; no save change):** keep the ids, costs, effects, order, property value and achievement.
   - `_draw_outside` stops drawing the porch roof and the dormer.
   - The porch becomes porch furnishings in the fixed porch row (bench, rocker).
   - "Second storey" becomes "Attic rooms". SA has no attic window, so its sign is interior only, or a lit gable-end vent (SB's attic window was the natural sign; with SA that is lost).
   - Only two `about` strings and the drawing change.
3. **Step 2, only if the owner wants them gone from sale:**
   - Hide the rows for players who don't own them, and grandfather owners (their effects continue).
   - Pin the achievement goal to a constant and reword it.
   - Move the lost value (late-game sanity, the stand bonus, a year-2 coin sink) to other purchases first, for example furniture or the cellar.
   - Then re-run `balance_sim` (all three modes) and update the sim targets in `DESIGN.md:237-244`, with the owner's approval of that locked-file change.
4. **Never refund-and-remove mid-save:** it would strip sanity and stand bonuses from owners, and it changes the property tax.
5. **Tests before any of it:**
   - `save_test` cases for an old save with both ids, with porch only, and with neither, plus an unknown id;
   - a `menu_test` case for the Extensions tab;
   - all in slot 9, never slots 1–3.

## 4. Revised small-field farming area (prototype `art=f1`)

`tools/art003_f1.py` draws four flat fields. `tools/art003_wide.gd art=f1` (on top of `w4`) lays them on the **same four 7 × 4 tile areas** as the raised beds and turns the stone cross walk into trodden dirt. Tile diagram: `s2_field_diagram.png`.

- **Fields:**
  - A x 44–50, y 20–23; B x 52–58, y 20–23; C x 44–50, y 25–28; D x 52–58, y 25–28;
  - **112 plantable tiles** (production `PLOT_ONE` is 15 × 7 = 105).
- **Walks and fence:** 1-tile walks round the fields and in a cross at x 51 / y 24. The fence and both gates (west 42, 23–24; south 50–51, 30) are unchanged.
- **Drawing:**
  - Ground-level soil with no box or wall.
  - **Each tile row is one ridge with its furrow**, so one crop sits per tile, as the game plants. The raised beds showed 3 rows of plants in 4 tiles, which the game can't do.
  - Irregular trodden edges, a few tufts, pebbles, straw and furrow weeds.
- **Soil states shown:** A ripe and mixed (W-3p crops in clumps, a few gaps); B growing (production stages 1–2); C just planted, on **watered** dark soil; D half harvested (two bare rows, a flatter unplanted ridge).
- **Collision [Measured]:** `check=reach` gives byte-identical reachable-tile lists for `art=w4` and `art=f1`. Every tile code is unchanged.

[Judgement]
- It reads as a working homestead field, not a garden centre, and it matches the game's per-tile rule.
- Still weak:
  - the four fields are identical 7 × 4 rectangles, and the furrow banding is strong at 720p;
  - at R3-1 night the soil goes very dark, though the crops still read;
  - no irrigation detail was added (the well and the existing rain barrel at the garden's south-west corner are the water).
- Next refinements:
  - give one field a different shape by moving its walk tiles (needs a layout decision);
  - add a shallow ditch or a trough along the north fence;
  - make the furrows softer.

### Integration with the current farming code (feasibility; not implemented)
[Measured] from `farm_system.gd`, `main.gd` and `save_system.gd`:
- **Tiles:** crops live in `crops[Vector2i]` with `stage`, `kind`, `days` and `watered_day`, on `Tile.SOIL` tiles, which are walkable. Planting (trowel), watering (bucket/hose; rain waters everything), growth by watered nights, and harvest (hoe) are all per tile. The current game has **no tilling step**: SOIL is always tilled, and FALLOW is the locked state for plots two and three.
- **Production already draws ground-level soil:** the `ground_soil` dual-grid layer (`DUAL_LAYERS`) plus `crop_<kind>` stage strips and a `WATERED_SOIL` darkening per tile. The F1 look is mostly **new art for those same slots:**
  - a soil dual-grid tile set with ridge rows;
  - per-tile watered soil, instead of a flat dark rectangle;
  - crop strips whose base sits on the ridge.

  No farming logic needs to change for the look.
- **Hazard:** a save is matched to `LAYOUT_VERSION`. If the layout version changes (as the ART-003 migration would), `save_system.gd:295-297` **drops every crop**, along with brush and rocks.
- **Migration proposal:** a coordinate remap for that version bump. Map `PLOT_ONE` tile (c, r) by index n = r × 15 + c onto the n-th of the 112 field tiles (row-major A, B, then C, D), so all 105 old crops survive. Plots two and three get their own remaps when they move (`ART_003_LAYOUT_PARITY_PLAN.md` Q-2).
- **Risk:** if the owner wants a real **tilling** mechanic (untilled → tilled → watered), that is a gameplay change. It needs a soil-state field per tile, a save version bump and its own balance check.

## 5. Preserved ART-003 road, gate and homestead layout

`art=f1` is `art=w4` plus the fields only. The house, golden oak, well and crossroads, orchard, pond and dock, forest frame, main paths, the road and the closed east gate with its forest avenue are drawn exactly as in W-4. The wide frames (`s2_fields_wide.png`) show the fields beside them. The blueprint files are unchanged. Nothing implies travel past the gate.

## 6. Godot comparison screenshots (review package `art/style_tests/ART-005/s2/review/`)

| Master | Content | Sheet scale |
|---|---|---|
| `ART-005S2_master.png` | SA vs SA + log: 1080p integer (2×) and 720p gameplay zoom, noon and night | 64% |
| `_master_2.png` | stages 0–3 at 720p, day and night; sprites 1:1 and silhouettes vs SA | 74% |
| `_master_3.png` | garden V2 at 720p, W-4 beds vs F1 fields, day and R3-1 night; the tile diagram | 70% |
| `_master_4.png` | wide homestead frames (3×): BEFORE/AFTER day, AFTER R3-1 night, east side | 50% (borderline; the full panel is `s2_fields_wide.png`) |
| `_master_5.png` | SA vs log sprites 1:1 and 3× close-ups (corner, window, door) | 83% |

- **Night labels:**
  - The farmhouse sheets use the ART-005 harness night: production `NIGHT_TINT`, the lantern and window lights. **R3-1 is not part of that harness.**
  - The field sheets use the locked R3-1 prototype night.
  - Stages 0–1 were captured with `winlights=0`.
- **Not captured:** dusk, rain, fog, winter, a trek, motion.

## 7. Technical dependencies and risks

1. **Stage art:** the production house draws one texture per `house_stage` (`main.gd:2599`), so four log sprites swap with no code-path change. The outside paint tints the whole sprite. With logs it should tint only a siding mask, which is a small drawing change.
2. **Extensions:** the `_from_save` drop and the achievement goal (§3). Re-dress first; retire later, if ever.
3. **Fields:** the `LAYOUT_VERSION` crop drop (§4). A remap is required before any layout migration.
4. **Asset families:** the log house is a hand-placed mockup. Its final art must match the PixelLab trees and props of ART-003, or the house will again sit apart (WH §B).
5. **Harness changes:**
   - `tools/art005_density.gd` gains `art=g5 var=` and `winlights=0`. A dead duplicate `g4` branch was replaced by the `g5` branch, so `g4` still loads the same files.
   - `tools/art003_wide.gd` gains `art=f1`; `_w4()` is also true for `f1`, and `art=w4` output is unchanged.

## 8. SpriteCook, PixelLab or both, for the simplified log cabin

- **PixelLab** (`edit_image` Pro, about 25 generations per edit; the balance after H1 was 4,913 subscription generations, USD 0):
  - best at material finish over a fixed value pass (H1's siding, windows and door were its best work);
  - SA with logs removes the hips and the large repeated surfaces where H1 failed, apart from the slate roof;
  - inpainting inside a mask keeps the alpha fixed for stage derivations.
- **SpriteCook** (`pixel-engine-image-v1`, 128 px maximum):
  - can't make the 384 × 320 house;
  - suits a matched strip kit: log-end cluster, boards, roof patch, tarp, vines, flower box, firewood. These are the stage overlays.
  - The plugin **needs re-authorising** (`/mcp`) before use.
- **Hybrid (recommended):**
  - we own the geometry (the SA log label map, fixed);
  - PixelLab finishes **one stage-3 master** over this S2 log mockup as its value and colour reference;
  - stages 2–0 are derived by masked edits or by hand with a small SpriteCook kit;
  - every stage keeps the master's alpha.

## 9. Recommended next experiment and spending limit (proposal only)

**S3: one PixelLab Pro `edit_image` of the stage-3 SA log house**, using `pl/g5/log/32/house_day.png` as the reference and the SA alpha as the mask.

- The prompt asks for hewn logs with notched corner ends, and a quieter dark roof (wood shakes or dark slate, 8–12 px courses). Nothing structural.
- **Cost:** about 25 generations, quoted with the free `get_pro_flash_capabilities`/help call first. **Hard limit 30 subscription generations, USD 0**, one attempt, no retry.
- **Stop rule (H1's):** geometry drift beyond 1 px at the openings or roofline, a repetitive roof grid, or broken alpha → record it and stop.
- **Then:** the same 1080p, 720p and night review.

No stage variants, no SpriteCook kit and no field art in S3. Optional, zero cost, before S3: a roof material mockup (wood shake vs dark slate) on this same log house, so the prompt's roof choice is made by the owner rather than by the generator.

## Files

- **New scripts (non-production):** `tools/art005_s2.py`, `tools/art003_f1.py`, `tools/art005_s2_review.py`.
- **Changed tools:** `tools/art005_density.gd` (`art=g5`, `winlights=0`), `tools/art003_wide.gd` (`art=f1`).
- **New art (non-production):**
  - `art/style_tests/ART-005/pl/g5/` (`log`, `st0`–`st3`, `s2_metrics.json`);
  - `art/style_tests/ART-003/f1/` (four field images);
  - `art/style_tests/ART-005/s2/review/`.
- **Raw frames (gitignored):** `builds/review/ART-005/s2/` and the export's `builds/x/`.
