# ART-005 VS16 — polished 16 px vertical slice

**Status:** zero-generation, NON-PRODUCTION prototype for the owner's and ChatGPT's review. It follows the owner's decision of 2026-11-05 (commit `618ae4a`, a cohesive 16 px indie direction). It proposes. It does not decide. Nothing in the game was changed:

- not `DESIGN.md`;
- not the production art, gameplay, saves, camera, scaling or production lighting;
- not the live map or fields;
- not the C2, HC1, HC2, ART-003 W-4, F2 or VIS-002 originals.

No PixelLab or SpriteCook calls were made. Porch and second-storey purchase IDs and benefits are untouched.

**Labels:** the **VS16 cabin** is a hand-composed 16 px prototype of the restored stage only. The **scene-style study** is a harness-only treatment, applied at run time to one test scene. Neither is production-approved.

## What was made

| Piece | File | How |
|---|---|---|
| Restored 16 px cabin, day and night | `art/style_tests/ART-005/vs16/cabin/house_{day,night}.png` (192×160), `palette.png` | `tools/vs16_cabin.py`, drawn element by element, not resampled. It uses C2's geometry, so the footprint, silhouette, chamfers, chimney, 8 log courses, both windows, door, lamp, foundation and steps match C2's positions. |
| Scene harness | `tools/vs16_scene.gd`, `tools/vs16_run.sh` | HC2's harness with two switches. `cabin16` puts the VS16 cabin on C2's anchor at full scale. `style` turns on the study. Frames are rendered in the clean export, as in HC1 and HC2. |
| Review | `tools/vs16_review.py` → `art/style_tests/ART-005/vs16/review/`, `vs16/measure.json` | Sheets, pan GIF, frame strip and shimmer measurement. |

### How the cabin is composed for 16 px (not an automatic shrink of C2)

- **Roof:** seven bold shake courses instead of C2's dense mottling.
  - Each course is three parts: a dark row cast by the butts above, a body in two close tones, and a lit butt edge.
  - Joints are staggered and only one step darker, so the courses read before the individual shakes.
  - Weathering and moss are a few deliberate clusters, not per-shake noise.
  - The chimney casts a shadow down and to the right.
  - The verge board is lit on the left and shaded on the right.
- **Walls:** each log is a cylinder: a lit top row, a warm body and a cooler underside, with dark chinking.
  - Grain is sparse 3–8 px streaks, plus a few knots and axe checks.
  - One or two logs sit a step darker, as real timber does.
  - A broad two-step shadow under the eave grounds the roof overhang.
  - The round log ends are stacked and jogged, as C2's, and show end grain.
- **Openings:**
  - The windows are real recesses. The top and left inner edges are shadowed (key light from the upper left), and a diagonal sky reflection sits in the upper panes.
  - Each sill is lit and casts a row of shadow.
  - The door has a hewn lintel log, lit and shaded jambs, four planks, iron strap hinges and a brass latch.
- **Foundation:** two courses of rounded fieldstones. Each has a lit upper-left cluster and a little moss low down, and the logs throw a shadow row on the footing.
- **Night:** only the glass changes, as C2's night does: four warm tones with a hot lower corner, plus a little spill on the sills and reveals. The porch lamp stays unlit, as C2's is.
- **Size:** 39 colours by day and 42 at night. C2 has 59 and the HC2 mockup 30. All come from one draft palette (`palette.png`).

### The scene-style study (harness only, reversible)

| Change | Setting | Why |
|---|---|---|
| Warmer, brighter day | Grade exposure 0.84 → 0.90, warmth 0.02 → 0.045, vignette 0.55 → 0.42; only before 18:00 | HC1 measured noon as low-key (grass luma 49). |
| Quieter grass | A 3×3 majority filter, once (4 of 9 neighbours), on grass-coloured ground pixels, using only existing colours | Merges speckle into larger clusters. Paths, soil, water and litter are untouched. |
| Contact shadows | A hard-edged pixel shadow at the base of each standing prop and building: 2–3 art rows, one art px toward the lower right, a dark green-black at 42% (26% at night) | Fixes HC1's "objects float" finding with one rule. Forest fill trees and the farmer, who has his own shadow, are skipped. |

The night grade, the tint and every light are unchanged, so R3-1 stays locked. In production, the grass treatment would be repainted tiles and the shadows authored pixels, not a run-time filter. The study only shows the target look.

## Review package (`art/style_tests/ART-005/vs16/review/`)

| Master | Contents | Scale |
|---|---|---|
| `ART-005VS16_master.png` | **Farmhouse source:** 1:1 day and night, the palette, ×3 day and night, C2 at the same world size. **The farmer beside the farmhouse:** 720p crops ×2, noon and R3-1, C2 vs VS16. | 64% |
| `ART-005VS16_master_2.png` | **Real 720p, 1:1:** C2 vs VS16, home (cabin, golden oak, well, farmer) and door, at noon and at the R3-1 night (21:30). | 50% |
| `ART-005VS16_master_3.png` | **Scene-style study, before and after:** VS16 vs VS16 + style, at home noon, the F2 fields at noon, and home at R3-1. | 70% |
| `ART-005VS16_master_4.png` | **Movement diagnostic:** the HC2 diagonal pan at 30 fps, consecutive world-locked frames ×2, for C2, VS16 and VS16 + style. | 100% |

- **Supporting files:**
  - Source sheets: `vs16_source.png`, `vs16_farmer_door.png`, `vs16_noon.png`, `vs16_night.png`, `vs16_style.png` and `vs16_pan_frames.png`.
  - Motion: `vs16_pan.gif`, which shows all three side by side at 1:1.
  - Measurements: `vs16/measure.json`.
- **Framing:** every direct comparison uses identical framing and the same farmer spot. Only the named switch differs between panels.

## Findings

**Measured:**

| | Colours | Pixel clusters | Mean cluster | 1-px clusters |
|---|---|---|---|---|
| VS16 cabin | 39 | 1,345 | 18.3 px | 15% |
| HC2 scripted mockup | 30 | 1,401 | 17.5 px | 20% |
| C2 (32 px source) | 58 | 5,326 | 18.5 px (about 4.6 in 16 px units) | 30% |

Pan shimmer (HC2's method: the share of the cabin's pixels still different after aligning consecutive frames by the best whole-pixel shift):

| | Cabin | Rest of frame |
|---|---|---|
| C2 control | 8.8% | 2.3% |
| VS16 cabin | **0.25%** | 2.1% |
| VS16 + style | 0.41% | 2.5% |

The cabin stops shimmering because every art pixel lands on 3 whole screen pixels. The rest of the frame is unchanged, as expected.

**What works (observed at gameplay scale):**
- The cabin shares the oak's, the well's, the farmer's and the grass's pixel grid. It no longer reads as a sprite from a different game, which was HC1's main finding about C2.
- It keeps what defines the house:
  - C2's architecture: side gable, chimney, stacked log ends, two windows, central door, footing and steps;
  - C2's warmth: the wall mean is (106,83,61) against C2's (116,90,66), slightly darker, and much closer than the first draft's (98,75,55);
  - C2's material order: dark shakes over warm logs over a grey footing.
- The farmer's 3 px outline matches the cabin's. Beside the door, they read as one world.
- The eave shadow, sill shadows and the door's lintel log give the front a depth that the HC2 mockup lacked.
- At night, the four warm panes hold the eye as strongly as C2's, and R3-1 is unchanged.

**What is weaker than C2 (honest):**
- **Roof:** at 720p it reads more as regular rows of tiles than as C2's soft, mottled shakes. The courses are right, but the shake rhythm is too even. This is the first thing a human pixel-art pass should fix: irregular butt lines, fewer and softer joints, and a little more warm variation.
- **Door:** simpler than C2's layered boards. It reads, but it is darker and less of a focal point.
- **Footing:** the fieldstones are blockier and a little greyer than C2's rounded cobbles.
- **Windows:** C2's diagonal glass glare reads more strongly by day than VS16's short reflection.

**One correction pass was made, by measurement:**
- The first draft was 18 levels darker on the walls than C2 and about 40 darker on the door, and its roof had more value spread than C2's, so it looked like bricks.
- The ramps were lifted toward C2's means, and the roof joints softened, once. No further micro-polish was done, as the decision asked.

**Scene-style study (observed):**
- The day is a little brighter and warmer without losing the autumn mood.
- The grass is calmer, but only modestly.
- The contact shadows visibly seat the rocks, the stump, the log pile and the well. Under the cabin they are mostly hidden by the footing, and a production version would draw a wider shadow along the foundation.
- The effect is deliberately conservative. A stronger version would need repainted grass tiles, not a filter.
- An earlier two-pass grass filter made a camouflage-like blotch and was dropped. The single strong-majority pass keeps the original colours.
- The night is unchanged except for the grass and the fainter shadows.

## Plan for the other three restoration stages (planning only, not drawn)

All four stages share the restored cabin's geometry, footprint, anchor, door and window centres. Each stage is a 192×160 day and night pair drawn on top of the stage-3 file by removing and replacing parts, so every stage stays on one grid and one palette. Porch and second-storey purchases stay as their existing IDs and benefits. Their art is a separate overlay question for later.

| Stage | Condition | What changes from the restored art | Night |
|---|---|---|---|
| 0 Derelict | Abandoned for years | About 25% of the shakes missing in two ragged holes, showing dark rafters. The ridge cap is broken and the chimney's top two courses have fallen. Logs are a step greyer and silvered, with one sagging course. Both windows are boarded with 2–3 crooked planks. The door hangs slightly open and dark. Heavy moss and grass at the footing, and the top step has a cracked slab. | No window light. A faint cold glint behind the boards. |
| 1 Patched | First repairs | The holes are covered with mismatched new shakes (lighter, warmer, clearly new) and one tarp-coloured patch. The chimney is restacked with a few fresh stones. One window is boarded and the other has glass with a cracked pane. The door is rehung. Logs are still greyed. | A dim lamp glow behind the glazed window. |
| 2 Repaired | Weather-tight | The whole roof is sound, with new shakes still slightly lighter in rows. Both windows glazed, chinking renewed (one step lighter in places), and the moss cleared from the walls. | Both windows lit, a step dimmer than restored. |
| 3 Restored | This slice | — | Full warm windows. |

Effort for stages 0–2 from the restored file is about 1–1.5 artist-days each, including night variants and review.

## Draft indie pixel-art style guide (16 px world)

This is guidance, not locked numbers. Where a rule and a good-looking result disagree, the result wins and the rule gets revised. None of this changes `DESIGN.md` until the owner approves an amendment.

1. **Pixel clusters.**
   - Build materials from clusters, not single pixels: wood streaks of 3–8 px, stones of 5–10 px, leaf masses of 4–8 px.
   - Keep single pixels for things that should sparkle: highlights, glints, nail heads, eyes, knots.
   - If an area looks noisy at 720p, merge clusters before adding detail.
2. **Outlines.**
   - Standing objects get a 1 art px silhouette (3 screen px) in the shared warm near-black `#18110F`.
   - Inner lines (seams, mortar, plank gaps) are a dark step of the material, not the outline colour, except where a deep gap really is black.
   - Foliage may use its darkest leaf tone as a soft outline.
   - Never thin outlines to 1 screen px, and never mix 2 px and 1 px art outlines in one scene.
3. **Shared autumn palette.**
   - One master palette (the VS16 ramps are a start: outline, logs, chinking, shakes, weathered, moss, trim, stone, glass, lit glass, door, metal), extended for grass, soil, foliage, water and skin.
   - Ramps have 4–7 steps. Highlights shift warm (toward ochre), and shadows shift cool (toward plum or blue-grey), never straight to grey or black.
   - Reuse ramps across objects so a stone is the same stone everywhere.
4. **Material shading.**
   - Wood: logs are cylinders (lit top, cool underside) and planks are flat with lit left edges.
   - Shakes: the course line carries the read, with a shadow row under every butt.
   - Stone: a rounded lit upper-left cluster and a dark lower-right rim.
   - Metal: a single hot glint.
   - Glass: dark with one reflection streak by day, warm and graded at night.
   - No dithering on world sprites.
5. **Light direction.**
   - One key light from the upper left for every sprite: lit top and left edges, shaded bottom and right.
   - Overhangs (eaves, sills, lintels, canopies) always cast a shadow row on what is below them.
6. **Ground texture frequency.**
   - The ground is the quietest layer: broad grass clusters, with an accent (tuft, flower, pebble) roughly every couple of tiles, grouped rather than sprinkled.
   - Paths have a clear edge, a lighter worn centre and a few stones.
   - Detail density rises from ground to props to hero objects.
7. **Contact shadows.**
   - Every standing object meets the ground with a hard-edged pixel shadow: 1–2 rows for small props and 2–3 for buildings and trees, offset toward the lower right.
   - Shadows are drawn in the ground's own darker ramp, not as an alpha blob.
   - At night they fade, because no sun is casting them.
8. **Building and character consistency.**
   - Characters share the world's outline colour and weight and its light direction.
   - Their mid-values stay clearly apart from the ground under them, by day and in R3-1.
   - Buildings and props use the same cluster sizes as characters, so nothing looks from another game.
   - New NPCs follow the farmer's 16×32 build.
9. **Night lighting.**
   - Night is the R3-1 grade, tint and lights. Sprites do not darken themselves.
   - Light sources change only their emitting pixels (glass, flame) plus a little spill on adjacent surfaces.
   - Warm light is the only saturated colour at night, so it leads the eye.
10. **Visual hierarchy.**
    - Make sure, in order, that:
      1. the farmer reads first;
      2. interactables and doors second;
      3. hero landmarks (the cabin, the golden oak, the well, the gate) third;
      4. the props fourth;
      5. the ground last.
    - Contrast and saturation are spent in that order. A prop that out-shouts a landmark is a bug.

## Prioritized environment roadmap (proposal, each step its own reviewed task)

Every step:
- keeps the ART-003 road, gate, orchard, pond, oak, fields and wider layout, the 16 px grid, the 3× camera and saves;
- swaps art behind the existing sprite names with the old art kept as a fallback, so each step can be rolled back;
- stops for review.

| # | Step | Scope | Est. artist-days* |
|---|---|---|---|
| 1 | Cohesive 16 px cabin | Polish VS16 from review, draw stages 0–2 from it, and wire all four behind the house sprites on C2's anchor. Save-compatible: same stage IDs and purchases. | 4–6 |
| 2 | Warmer, more attractive daytime | Tune the day grade (exposure, warmth, vignette) and the sunny tint in the real game, behind a flag, with an A/B against VIS-002 and R3-1. Night is untouched. | 1–2 |
| 3 | Quieter terrain, clearer paths | Repaint grass fill and variants at lower frequency, regroup scatter, and give paths a defined edge and worn centre. | 4–6 |
| 4 | Outlines and contact shadows | Move the props' pure-black outlines to `#18110F`, and author per-prop pixel contact shadows, or a shared shadow sprite set. | 3–4 |
| 5 | Orchard trees | Redraw apple and pear crowns as clustered 16 px masses consistent with the golden oak, with windfalls and a trunk shadow. | 2–3 |
| 6 | Wood dock | Planks with lit edges, posts with water contact and reflection, and a shadow under the deck. | 1–2 |
| 7 | Farm entrance and closed gate | A recognizable post-and-rail gate with a lit top rail, a sign or mailbox landmark at the road, and a stronger silhouette against the forest avenue. | 2–3 |
| 8 | Character and environment detailing | Check the farmer and visitors against the guide (outline, values, light side). Bring the well and other props to the same cluster and outline rules. | 3–5 |

\* Estimates are for an experienced pixel artist with AI-assisted drafts cleaned by hand, ±50%. They are not quotes.

## Costs and risks

- **Cost of this slice:** none. There was no generation spend.
- **Visible risks:**
  - The prototype was drawn by script-driven hand placement, not freehand in an editor. A human pixel artist pass would refine the roof rhythm and the door further.
  - The run-time grass filter and shadow rule only stand in for authored art.
  - The day-grade change touches the global grade, so it must be A/B'd against every weather before any production change.
- **What it cannot show:**
  - the other three stages;
  - a whole repainted world;
  - 1080p presentation, which still uses a non-integer stretch and is a separate decision.
