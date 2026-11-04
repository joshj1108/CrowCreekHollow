# ART-003 W-3 wall comparison (A / M / B) and Batch C proposal

Status: for the owner's and ChatGPT's review. **Non-production, non-generative.** Asked for by the owner after ChatGPT's polish review (board, `dacdf09`, independent score 71.0; Claude's 71.25 kept separate, not averaged).

- **Kept, as directed:** candidate C's architecture, blue-black roof, unlit day glass, lit night glass, porch deck, stone steps and dressing; G1 grass; the four-bed garden as it is (no new gaps); the R3-1 night, lantern energy and falloff.
- **Not changed:** production art, `main.gd`, gameplay, saves, collision, camera, scale, the live farm, `DESIGN.md`. No P-1, no house stages 0–2, no Batch C.
- **PixelLab:** **0 generations used.** Balance 4,964 of 5,000 (cycle resets 2026-12-03); $0.00 USD credit.

## What was made
- `../w3p/house/polish.py` gains one variant, **M**, the midpoint of A and B. The script regenerates a, b and c **byte-identical** (md5 checked), so the reviewed polish art is untouched.
  - **A** warm weathered: boards ×0.74, +6 warm.
  - **M** midpoint: ×0.68, +5 warm.
  - **B** dark weathered: ×0.62, +4 warm (the polish default).
- Board-to-board tone, grain, trim, roof, glass, porch, treads and every other pixel are the same in all three: the 6,316 pixels that differ between A and B are the wall boards and nothing else.
- `tools/art003_wide.gd` only documents `wall=m` (the switch already took any letter).
- Renders: a `git archive` export of `dacdf09` plus the tool and the M sprites, so the VIS-002 working tree is not in them. `mode=wide layout=b art=w3p grass=1 wall=a|m|b`, 1280×720, 12:00 and 21:30, sunny, autumn, sanity 100. B at V1-B day matches the polish package's `postG1_V1_day` within 0.003 in every measured region (the rest is animation).
- `make_sheets.py` builds the sheets. The concept cells are the exact crops from the polish package's `house_views.png`.

## Measurements
| Wall pixels only (day sprite) | Mean RGB | Luma |
| --- | --- | --- |
| Batch B (before the polish) | 136, 100, 62 | 0.411 |
| A warm weathered | 105, 73, 39 | 0.302 |
| M midpoint | 96, 67, 36 | 0.277 |
| B dark weathered | 87, 61, 34 | 0.253 |

| House region, mean luma (A / M / B) | Day | Night |
| --- | --- | --- |
| V1-B | 0.156 / 0.148 / 0.142 | 0.160 / 0.153 / 0.146 |
| V5 | 0.165 / 0.156 / 0.148 | 0.181 / 0.171 / 0.165 |
| Establishing | 0.175 / 0.166 / 0.156 | 0.234 / 0.223 / 0.198 |
| Production house, V1-B (Batch B record) | 0.153 | 0.122 |

- Every other region (play area, oak, forest edge, lantern pool) stays within ±0.005 across the three, so the walls are the only real variable.
- At night the lit glass dominates. A, M and B differ less there than by day.

## Reading
- **By day,** A is the only one that reads as warm wood beside the golden oak. M sits visibly closer to B than to A. All three keep the board wear, the dark trim and the contrast with the lit glass at night.
- **Even A is well below the concept's wall warmth.** Part of that warmth in Concept 02 is its warm sunlight and glowing porch, which the game's neutral daylight grade doesn't add. A wall brighter than A would drift back toward Batch B's clean, new-timber look.
- **My recommendation: A.** It answers ChatGPT's concern most directly, it is still darker than Batch B by about a quarter, and its house luma by day (0.156) is the closest to the production house's (0.153). M is the fallback if A reads too clean at full size. A lighter step past A (for example ×0.80) would be a zero-cost follow-up, but it isn't made here.

## Roof and chimney in normal play
The camera follows the farmer and shows 7.5 tiles above them. The house sprite's top (chimney cap) is at inner tile y 2.4; its wall line is at y 11.3.
- **V1-B** (farmer at y 10): the whole roof and chimney show. The cap's top 2 sprite px are just off-frame.
- **V5** (farmer on the porch path, y 13.5): the top 3.6 tiles of the sprite are off-frame. That's the whole chimney stack and the upper roof down to the gable window.
- **Any spot south of the porch** (the well, the garden, the path): the chimney is off-screen. The full facade shows only when the farmer is level with or north of the house's upper floor, beside or behind it. The establishing row (farmer at 45,10, behind the house) is that view.
- **This is a camera consequence, not an art fault.** A camera change is out of scope. In production the roofline would mostly be seen from the sides (V1-B), so the side silhouette and chimney should stay the identity cues.

## Review package (`review/`)
- `ART-003WW_master.png` (sheets at 66%): `wall_views.png`. Concept | A | M | B for V1-B, V5 and the establishing view, day and R3-1 night; game frames at 50%.
- `ART-003WW_master_2.png` (54%): `wall_closeups.png` (the Concept 02 house, sprites at 3× day and night) and `wall_ingame.png` (the house at 100% in V1-B day, establishing day and night, V5 day).
- Stills only; nothing moves in this change.

## Checks
- **VIS-002:** the working-tree diff, leaving out `tools/art003_wide.gd`, `make_blueprint.py` and `polish.py`, still hashes `f52e5ae0…`. `stash@{0}` is present.
- **Saves:** slots 1–3 match `builds/wip_backup/saves_after_wb.txt`. Slot 8's time is unchanged (18:18).

---

# Batch C proposal: orchard, arrival and connecting paths (not started)

**Needs the owner's approval of scope and budget before anything is generated or built.**

## Where it stands now (polish + G1, day)
- **V3, the well crossroads:** two broad brown paths cross open grass with leaf litter. The well is the only focal object. It is the thinnest view.
- **V4, the orchard and pond:** the orchard tiles carry `maple.png` stand-ins (red-orange crowns, no fruit) behind a split-rail fence. The pond and dock are in place.
- **The road and its gate:** a long, even path edge with nothing at the entrance.

## Reuse first (0 generations)
| Area | Existing art | Use |
| --- | --- | --- |
| V3 crossroads | `chopping_log`, `woodstore` (production, SpriteCook); W-3 porch firewood and crates; `boulder_0..2`, `rock_0..2` | A woodcutting group between the well and the oak; a small boulder group at the fork's outer corner |
| Road gate | `tree_dead_0` (the single quiet horror note); boulders; `brush_0..2` | A dead tree and a boulder cluster flanking the gate |
| Paths | The Round 2–3 path and litter Wang sets; `r2/decals.png`; brush | Broken path edges (grass tufts and litter creeping in), a narrower trodden line toward the dock, ruts on the road from the existing path set's darker tiles |
| Garden → pond | W-3 Batch A shore props (reeds, lilies); brush | Cattails thickening toward the water |
| Orchard | The orchard fence and layout; `r2/decals.png` | Kept; only the trees change |

## New art that's genuinely needed
All PixelLab `create_image_pixflux` (1 generation each, with the concept palette), the same tool and settings as Batch B. No Pro Flash (6 per image at this size), and no inpainting (10).
| # | Asset | Size | Why reuse can't cover it | Expected | Retry allowance |
| --- | --- | --- | --- | --- | --- |
| 1 | Apple tree, autumn leaves, red fruit, open crown, 1-tile trunk | 48×64 | There is no fruit tree in any art set; maples read as forest | 1 | +1 |
| 2 | A second fruit-tree crown (a pear, or a second apple shape) | 48×64 | So the orchard rows don't repeat one tree | 1 | 0 |
| 3 | A prop strip: signpost, mailbox, handcart with sacks, compost heap, rain barrel, fallen-fruit basket | 128×48 | None of these exist; they carry the "lived-in" story the concept has | 1 | +1 |

- **Expected spend:** 3 generations. **Hard limit: 5 generations** (subscription generations; no USD credit spend).
- **Stop rule:** if an asset fails its one retry, it stays unmade. I stop and report rather than escalate tools or spend past the cap.
- **Balance** is checked and recorded before and after.

## Visual improvements expected
1. **V4 reads as an orchard:** fruit trees with visible red fruit in place of every maple stand-in, alternating two crowns, with fallen fruit and a basket under one or two. The pond view gains a cultivated counterpoint to the forest.
2. **V3 gets three deliberate groups:** a signpost at the fork, a handcart with sacks where the road path meets the well path, and a woodcutting corner between the well and the oak. Open grass stays between them as rest space.
3. **The arrival:** a mailbox at the road gate, a dead tree and a boulder cluster, so entering the farm has a threshold.
4. **The paths:** irregular, worn edges in place of the even brown bands, ruts on the road, and a narrower line to the dock. Every walkable tile stays walkable.
5. **Garden → pond:** a compost heap and rain barrel at the garden's south-west corner, with cattails thickening toward the water.

## Limits and checks
- **Prototype only:** layout b, `art=w3c` on top of `art=w3p` in `tools/art003_wide.gd`, files in `art/style_tests/ART-003/w3c/`. No production art, live layout, collision rules, camera, scale, lights, P-1 or `DESIGN.md`.
- **The trunk and prop tiles block, as now.** The route stays continuous (the walk re-run must report no skipped legs).
- **Performance:** about 10–20 more sprites per view, so under +30 draw calls, and 0 new lights. The trees replace the maples one for one.
- **Review:** BEFORE (polish) and AFTER for V3, V4 and the road, day and R3-1 night; a V1-B/V2 spot check that nothing else moved; the walk GIF; masters per the protocol.
- **Conflicts:** PixelLab art is still prototype-only under C-12. Fruit trees would need seasonal states before production.
- **The wall choice** (A, M or B) is carried into Batch C's captures, so the house stays consistent.

## Decisions for the owner
1. **The wall:** A (recommended), M, B, or a lighter step past A.
2. **Batch C scope:** all five areas, or a subset (for example the orchard and V3 only).
3. **Budget:** approve the 5-generation hard limit, or set another.
4. **Commit and push** of this package.
