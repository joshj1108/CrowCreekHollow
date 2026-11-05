# ART-005 S3: roof material A/B, hewn log corners, stage fixes, field polish and production feasibility

Status: **for the owner's and ChatGPT's image review. Non-production only.** Answers the owner's S3 brief after ChatGPT's S2 review (`6146d5b`).

- **Spend:** zero generations. PixelLab: only the free `get_balance`, `search_help` and two `get_pro_flash_capabilities` lookups (balance **4,913 generations, USD 0**, unchanged). SpriteCook: no calls. USD 0.
- **Not changed:** production art, the live farm and layout, gameplay, farming, saves (real or test), camera, scale, production lighting, `DESIGN.md`, porch and second-storey code, any existing upgrade.
- **Preserved:** VIS-002 (its uncommitted files are not staged), ART-003 (W-4, `f1/`), and ART-005 M0, H1, S1 (`g4/`) and S2 (`g5/`). S3 writes only new folders: `pl/g6/`, `ART-003/f2/` and `s3/`.
- Tags: **[Measured]** = from pixels, code or a check; **[Judgement]** = my opinion.

## 1. Roof comparison (Task 1)

`tools/art005_s3.py` builds every S3 sprite from SA (`pl/g4/sa/`, read only) and S2's log wall. The wall uses the same seed and is **byte-identical to S2 outside the corner zones** [Measured: `logc_vs_s2_outside_corners_identical: true` in `pl/g6/s3_metrics.json`].

Only the roof labels (field, ridge, far slope, chimney shadow) are re-skinned. The roofline, rake boards, fascia, eave shadow, chimney, door, windows, foundation, steps, footprint and alpha are SA's.

| | S2 (SA slate) | **A: dark wood shakes** (`g6/shake`) | **B: quiet dark slate** (`g6/slate`) |
|---|---|---|---|
| Courses | 8 × 12 px | 10 × 9–11 px | 10 × 9–11 px |
| Units | slates with tiled moss and rust motifs | shakes 8–18 px wide, random joints | slates 15–26 px wide |
| Texture | repeated texture sample per slate | long grain streaks on some shakes, a split in a few wide ones, a lit butt on ~40% | one base tone; sparse ±1 steps; joints only below each course's top 2 rows |
| Weathering | busy moss and rust specks everywhere | 4 soft silvered patches; moss in 6 small clumps by the eave | 3 very faint patches; no moss, no motif |
| Ridge | SA slate cap | a wooden ridge board | a dark slate cap |
| Roof mean luma / SD [Measured] | 65.9 / **21.4** | 45.4 / **11.2** | 51.0 / **9.0** |
| Roof colours [Measured] | 13 | 16 | 11 |

Both candidates halve the roof's tonal contrast, which is what made the S2 roof busy.

[Judgement]
- **A (shakes)** belongs with the log walls: one family of materials, warm-neutral, rough and rural. It reads as a cabin roof from a distance. At 1:1 the courses still read a little like small bricks, because the unit is a rectangle. A painter or a generator would add slight taper and butt irregularity.
- **B (slate)** is the most professional-looking and the calmest surface. Its cool blue-grey sits against the warm logs like the S2 roof did, only quieter. It reads more "farmhouse" than "cabin".
- **At harness night** both new roofs fall almost to black. The roof mass reads only by its fascia and ridge, while S2's lighter slate kept a faint texture. A production roof should sit about one value step lighter than these mockups, or pick up the moon or lantern rim.
- **Recommendation: A (dark wood shakes)**, about one step lighter at night. B is a sound alternative if the owner prefers a cleaner, less rustic house.

### Revised log corners
`corners()` replaces S2's eight identical round log ends with a dovetailed hewn-log corner:
- The front logs run 5–8 px past the corner (a different length per course) and end in a 2 px axe-cut face.
- Straddling each of the seven seams, a side-wall timber shows its **squared** end. Each end has its own width (9–15 px) and height (12–14 px), chamfered corners, an off-centre pith, squarish rings, a check crack on most, bark on some, and a dark gap all round.
- The light is screen-space upper-left on both corners.
- It is reversible: `logc` is S2's house with only the corners changed.

[Judgement] It now reads as interlocking timbers, not a column of coins. At 720p the corners are quieter and slightly ragged, as hand-hewn work would be. At 1:1 the rings are tiny and read as dots, which is a finish job.

## 2. Four restoration stages (Task 2)

These are schematic, as in S2, and drawn on both roofs: `g6/sh0`–`sh3` (A) and `sl0`–`sl3` (B). The walls, windows, door, steps and dressing follow S2's matrix exactly.

**[Measured]** In every stage the roofline, eave, openings, window and door centres and footprint are identical to SA. The only removed pixels are stage 0's broken chimney top (225 px).

Changes from S2:
- **Stage 0 roof holes**
  - Now whole missing shakes or slates inside a lobed, noisy outline, not rectangles.
  - Units at the rim are snapped off on a slant.
  - Nine units have slipped 2 px down the roof.
  - Inside each hole: laths, rafters and the dark attic, with a 1 px shadow under the rim.
- **Stage 1 (Stabilized)**
  - Day: two holes are covered with tarred boards of uneven length, and one with a draped canvas tarp, held by a rope and two stones.
  - **Night fix:** warm light shows in the 2 px gaps between the window boards, brightest mid-gap, with a thin line under the door. A faint, small light sits at each window (harness `winlights=dim`: 0.3 energy, 1-tile radius). Stage 0 stays dark.
  - [Judgement] Stage 1 now reads as inhabited at night, but subtly, and is clearly distinct from stage 0.
- **Stage 2 (Repaired):** the re-roofed areas use new shakes, one muted step warmer (or a cleaner, bluer slate on B). One small board patch remains.
- **Stage 3:** unchanged: flower boxes, firewood, pots and lit windows.

## 3. Small fields (Task 3)

`tools/art003_f2.py` makes `ART-003/f2/`, and `tools/art003_wide.gd art=f2` draws it. F1 is untouched.

The four fields keep the same F1 tiles (A x 44–50, B x 52–58, at y 20–23 and y 25–28), the same soil states and the same 3 px margin.

Furrows:
- each ridge row has its own slow wobble, so the rows are no longer parallel;
- the furrow line is broken where soil has slumped into it;
- the crest highlight shows in runs;
- the tone drifts slowly along each ridge.

Edges:
- a ±3 px rim wobble with 1–2 worn bites per side;
- spilt clods on the walk;
- corners of different radius.

Watered field C: wet soil in patches, not one flat tone.

Crops: plants pull into loose pairs and threes, about 0.07–0.09 tile off grid, with ±0.04 tile of row jitter.

States: A ripe, B growing, C planted and watered, D partly harvested.

[Measured] `check=reach` gives **byte-identical reachable tiles for F1 and F2 (1,608)**. Walks, fence and both gates are unchanged, and every tile code is unchanged.

[Judgement] The fields read as worked ground, not printed stripes. The remaining sameness is the four equal rectangles, which is a layout choice the brief keeps. The wet patches in C have slightly visible tone steps at 4x, but not at gameplay scale.

## 4. Production feasibility (Task 4; plan only, nothing run)

### 4.1 House geometry and roof
- Production draws one texture per stage, `house_stage_%d` (`main.gd:2599`), into a 12 × 10-tile rect. The window lights sit at `HOUSE_SPRITE_WINDOWS` (`main.gd:2584`).
- The SA log cabin keeps those anchors (door x 192, window centres 96 / 286, walls ending at 9.3125 tiles). Four stage textures drop in with **no code-path change**.
- **Density is open.** Production sprites are 16 px per tile (`house_stage_*.png` are 192 × 160), and the mockups are 32 px (384 × 320). The 16 px rule is locked in `DESIGN.md`, and D-013 lists 32/64 px as options to evaluate.
  - Shipping 32 px houses needs an owner decision on density, and a `DESIGN.md` change approved by the owner.
  - Shipping at 16 px needs the final art redrawn at 192 × 160. A 2:1 reduction of these mockups would not hold up.
- **Chosen roof:** A (shakes), pending the owner. The outside paint (`estate._paint_tint()`) tints the whole sprite. With logs and shakes it should tint a siding/trim mask only, a small drawing change.
- **Asset family:** the final cabin must match ART-003's PixelLab trees and props (see §6).

### 4.2 Four condition-based stages
- They map one to one onto `STAGE_NAMES`: Decrepit = 0 Dilapidated, Boarded = 1 Stabilized, Patched = 2 Repaired, Restored = 3.
- No save change: `house_stage` is saved as an int (`save_system.gd:81/200`).
- `ACH_RESTORED` (goal 3), the property value `pow(PROPERTY_HOUSE_GROWTH, house_stage)` (`desk_system.gd:232`), the estate gates (`estate_system.gd:139/185/208/230/288`) and `farm_projects.gd` read only the int, so they are unaffected.
- Stage 1's night look needs a dim window light in production: a per-stage energy on the existing window lights. It must be tested under R3-1 and production night, not only the harness night.

### 4.3 Porch and second storey: save compatibility
This is unchanged from S2 §3, re-checked:
- **Never delete the ids.** `_from_save` drops unknown `estate.built` ids (`estate_system.gd:93-95`).
- **Step 1:** a cosmetic re-dress with no save change. Stop drawing the porch roof and dormer, show porch furnishings, and reword "second storey" to "attic rooms". Costs, effects, property value and `ACH_EXTENDED` (goal `EXTENSIONS.size()`) stay as they are.
- **Step 2,** only if the owner wants them withdrawn from sale: grandfather owners, pin the achievement goal and move the benefits first.
- No upgrade is removed by S3.

### 4.4 Field-to-production crop coordinate mapping
- **Live state:** `PLOT_ONE` is `Rect2i(3, 19, 15, 7)` in inner tiles (105 tiles). Saves store **world** tiles (inner + `BORDER` 14, 8).
- **The hazard:** a `layout` mismatch clears every crop (`save_system.gd:295-297`).
- **Proposed spatial map** (`art/style_tests/ART-005/s3/plot_one_to_fields.csv`, verified one-to-one):
  - Columns 0–6 go to fields A/C at x 44–50, and columns 8–14 go to B/D at x 52–58.
  - Rows 0–3 go to y 20–23 (A/B), and rows 4–6 go to y 25–27 (C/D).
  - The middle column 7, which would land on the walk at x 51, moves to the bottom row of field C: (44 + row, 28).
  - Result: **98 of 105 crops keep their neighbours, 7 move, none is lost.** The 7 tiles left free are D's bottom row (52–58, 28), so the fields give 112 − 105 = 7 new tiles.
  - This replaces S2's index-order map, which scattered rows across fields.
- **Implementation (later, separately authorized):**
  - a `LAYOUT_VERSION` bump with a remap table, applied to crops (`kind`, `stage`, `days`, `watered_day` carried as they are) and sprinklers instead of the drop;
  - `PLOT_TWO` (3, 31, 15 × 6) and `PLOT_THREE` (29, 23, 12 × 6) get their own remaps in the ART-003 parity plan (Q-2);
  - the new world coordinates assume the border stays (14, 8);
  - fixture tests in slot 9 (`save_test`, a `layout_migration_test` against a dummy layout); slots 1–3 never touched.
- **Unchanged:** farming mechanics. There is still no tilling step: soil is always tilled, and FALLOW is the locked state.

### 4.5 Wider homestead, road and gate
- `art=f2` is `art=w4` plus the fields.
- The new `house=g6:<var>` only swaps the house sprite (drawn at half scale on the door anchor, with the house's dressing tiles left bare) and changes no tile, collision or code.
- The oak, well and crossroads, orchard, pond and dock, forest, paths, road and the closed east gate are drawn exactly as in W-4.
- The north/south homestead frames show them together with the cabin. Nothing implies travel past the gate.

## 5. Godot review package (`art/style_tests/ART-005/s3/review/`)

| Master | Content | Sheet scale |
|---|---|---|
| `ART-005S3_master.png` | roofs S2 / A / B, 720p and 1080p integer, noon and harness night | 53% |
| `_master_2.png` | corners S2 vs S3 (3x), roof close-ups (3x) | 100% |
| `_master_3.png` | stages 0–3 on roof A, 720p day and night; the stage 1 night fix vs S2 | 74% |
| `_master_4.png` | stages on roof B; stage 0 hole and stage 1 window close-ups; sprites and silhouettes | 53% |
| `_master_5.png` | fields F1 vs F2 at 720p, day and R3-1 night; soil images 4x | 56% |
| `_master_6.png` | homestead north (house, oak, well): S2 vs S3 A/B, day; A at R3-1 night | 50% (borderline; the full panel is `s3_farm_north.png`) |
| `_master_7.png` | homestead south (fields, road, gates): as above | 50% (borderline; `s3_farm_south.png`) |

Frame sources:
- The house frames come from `tools/art005_density.gd art=g6`.
- The field and homestead frames come from `tools/art003_wide.gd`, run in a `git archive` export of HEAD `6146d5b` plus the S3 tools and mockup art. They contain no VIS-002 work.

Night labels:
- The house sheets use the ART-005 harness night. That is not R3-1.
- The field and homestead sheets use R3-1.

Not captured: dusk, rain, fog, winter, a trek, motion.

## 6. Recommendation: is one PixelLab Pro edit now justified?

**Yes, one, once the owner picks the roof.** Structure, wall, corners, roof material and stages are now decided by zero-cost mockups. What a script can't add is material finish: tapered shakes, real end-grain, hand-cut log faces, and a unified painterly value pass that matches the ART-003 PixelLab family.

**The operation:**
- **Tool:** one `edit_image` (Pro), reference mode, 384 × 320, transparent background following the input, one recorded seed.
- **Quoted cost: 25 subscription generations, USD 0.**
  - PixelLab's documented band is 25 above 341², and H1's identical operation was charged exactly 25 (4,938 → 4,913).
  - There is no free pre-quote for `edit_image`. Pro Flash, which has quotes, does not support 384 × 320 (it is limited to 32–256 px; checked today).
  - Balance: **4,913 generations, USD 0**, renewing 2026-12-03.
- **Inputs:**
  - **input:** `pl/g6/shake/32/house_day.png`, the stage 3 base without dressing (or `slate` if the owner picks B);
  - **reference:** a 64 × 64 swatch board cut from the ART-003 PixelLab family (`r3/log.png` log texture, an oak bark cell, a ground and stone cell), so the house joins the trees and props;
  - **prompt:** keep every edge, opening and silhouette; dark hand-split wood shakes with tapered, irregular butts, about one value step lighter than the input; hewn logs with adze-flattened faces; squared dovetailed corner timbers; stone foundation and chimney as they are; upper-left light; no moss speckle; nothing added.
- **Limits:** hard cap 25, one attempt, no retry, no inpainting, and H1's stop rule (drift above 1 px at the openings or roofline, a repetitive roof grid, or broken alpha → record it and stop).
- **After it:** the same 720p, 1080p and night review.
- **Not part of it:**
  - Stages 0–2. These would be derived later, by masked edits or by hand with a small SpriteCook kit; SpriteCook needs re-authorising via `/mcp`.
  - Field art.
  - The density decision in §4.1.

This needs a separate owner authorization. **Nothing is generated by S3.**

## Files

- **New scripts (non-production):** `tools/art005_s3.py`, `tools/art003_f2.py`, `tools/art005_s3_review.py`.
- **Changed tools:**
  - `tools/art005_density.gd`: adds `art=g6 var=` and `winlights=dim`. Other modes are unchanged.
  - `tools/art003_wide.gd`: adds `art=f2` and `house=g6:<var>`. `art=f1` and `art=w4` are unchanged; the reach check matches.
- **New art (non-production):**
  - `art/style_tests/ART-005/pl/g6/` (`logc`, `shake`, `slate`, `sh0`–`sh3`, `sl0`–`sl3`, `s3_metrics.json`);
  - `art/style_tests/ART-003/f2/`;
  - `art/style_tests/ART-005/s3/` (`plot_one_to_fields.csv`, `review/`).
- **Raw frames (gitignored):** `builds/review/ART-005/s3/` and `builds/review/ART-005/s3_export/`.
