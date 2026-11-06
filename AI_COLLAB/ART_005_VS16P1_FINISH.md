# ART-005 VS16-P1: farmhouse artistic finishing pass

**Status:** a zero-generation, NON-PRODUCTION variant for the owner's and ChatGPT's image-level review. It responds to ChatGPT's VS16 review (commit `b81e7b6`) and the owner's VS16-P1 brief. It proposes. It does not decide.

**What was not touched:**
- VS16 (`art/style_tests/ART-005/vs16/` and `tools/vs16_cabin.py` are byte-identical);
- C2, HC1, HC2, ART-003 and VIS-002;
- `DESIGN.md`, the production art, gameplay, saves, the camera and scale, the lighting (including R3-1) and the farm layout.

No PixelLab or SpriteCook calls were made and nothing was bought. There was no live integration.

## What was made

| Piece | File |
|---|---|
| P1 cabin, day and night (192×160) and its ramps | `art/style_tests/ART-005/vs16p1/cabin/house_{day,night}.png`, `palette.png` |
| Generator: a copy of VS16's, with only the parts below redrawn | `tools/vs16p1_cabin.py` |
| Harness switch `p1`: VS16's harness, drawing the P1 cabin on the same anchor | `tools/vs16p1_scene.gd`, `tools/vs16p1_run.sh` |
| Sheets and measurements | `tools/vs16p1_review.py` → `vs16p1/review/`, `vs16p1/measure.json` |

To rebuild everything: `python tools/vs16p1_cabin.py && bash tools/vs16p1_run.sh && python tools/vs16p1_review.py`, then `tools/review_master.ps1`.

## What stayed fixed (verified)

- **Canvas and footprint:** the 192×160 canvas, the silhouette and the footprint are unchanged. Day and night alpha are pixel-identical to VS16.
- **Openings:** the door rectangle (84,108)–(107,148) and the window rectangles (37/132,101)–(59/154,126) are unchanged, so the window centres and the game's window-light positions still match.
- **Fixed parts:** the chimney, ridge, fascia, verge boards, lamp and steps are VS16's. The only exception is a one-row threshold shadow on the upper step.
- **In the game:** the same 16 px grid at 3×, on the same anchor.

## Record of artistic changes

| Part | VS16 | P1 |
|---|---|---|
| **Roof** (6,606 px changed) | Fixed-height courses with a full black shadow row and a dark joint around every shake, so it read as brick. | Courses are painted from the eave up, so each butt overlaps the course below and casts its own shadow (three steps, then a broken one-step second row) instead of a uniform black row. Each shake has its own width (5–11 px), and its butt can sit 1 px lower or shorter. Some shakes have a worn corner or a tapered butt. The joints are soft (1–2 steps darker, and not all full length). The value comes from one broad light field (lighter toward the upper-left key light), plus one sun-warmed zone and two small silvered zones, chosen per shake rather than per pixel. The bright butt edges are clustered where the field is lit. The ridge cap is lit more on the left. The moss is kept. |
| **Door** (844 px) | A black frame, a black inner rectangle and four even grooved planks. | A wooden casing with depth: a lit left board, a dark-wood rebate rather than outline black, and a right board catching the light. The planks are 4, 5, 3 and 4 px wide, with a lit left edge, long grain that kinks once, and a knot. The head casing and left jamb throw shadows onto the leaf. Two lit battens carry iron strap hinges with nail glints and knuckles on the jamb. There is a brass thumb latch on an iron plate, and a lit threshold board on the upper step. |
| **Foundation** (1,427 px) | Two courses of rectangular blocks. | Fieldstones of mixed sizes: about half are tall stones through the whole footing, and the rest are smaller stones stacked in two bands. They come in warm, neutral and cool greys, with corners cut (more on the big ones), a lit upper-left rim and highlight cluster, and a darker lower-right rim. The mortar is a recessed dark brown rather than outline black. The logs cast a shadow on the footing, there is contact darkening at the ground, and four small moss spots. |
| **Windows** (387 px each by day, 398 at night) | A flat frame and near-black panes with a short glint. By night, four evenly bright panes. | The casing is lit on the top and left. The sash is recessed: the top and left reveals are dark, and the bottom and right reveals are lit. By day, the glass is a blue-grey ramp, with one pane catching more sky and one restrained diagonal glare (a core and a fringe, broken by the muntins). By night, each pane is graded: the lower panes and the panes toward the room's middle are brighter, the top and left edges are shaded by the sash, the muntins are backlit and dark, and warm spill falls on the reveals and sill. |
| **Logs and corners** (about 1,700 px, mostly the corners and the removed ticks) | Boxy log ends, and repeated two-pixel axe-check ticks on every log. | The log ends are in the wall's own ramp, with a lit rim, a ring arc and a pith. The left corner stack casts a one-pixel shadow on the wall. The axe-check ticks are removed. The siding is otherwise VS16's. |

**Colours:** 66 by day and 70 at night, against VS16's 39 and 42. The new colours come from short added ramps (warm and silvered shakes, warm and cool stone, mortar, glass, lit glass and door), not from noise.

**Iterations:** one draft, one correction (the roof had gone muddy and the stones were flat slabs), and one measured roof calibration. After the draft, the roof's luma spread had fallen to SD 11.8 against VS16's 15.3, and it went murky under the game's grade. A deeper butt shadow brought it to 13.4. No further micro-revisions were made.

## Review package (`art/style_tests/ART-005/vs16p1/review/`)

| Master | Contents | Scale |
|---|---|---|
| `ART-005VS16P1_master.png` (1/5) | Source art: VS16 vs P1 at 1:1 and ×3 by day, and the night glass. The P1 ramps. A change map of every modified pixel. The footprint and opening alignment overlay. | 80% |
| `ART-005VS16P1_master_2.png` (2/5) | Close-ups of enlarged source pixels: roof, door, foundation, window and log corner by day, and window and door at night. | 100% |
| `ART-005VS16P1_master_3.png` (3/5) | The cabin at true gameplay size: 1:1 crops of the real 720p frames at noon and at 21:30. | 100% |
| `ART-005VS16P1_master_4.png` (4/5) | Full-game 720p: the cabin beside the golden oak and well, with the farmer, at noon and at R3-1 21:30. | 74% |
| `ART-005VS16P1_master_5.png` (5/5) | Full-game 720p: the farmer beside the door, at noon and at 21:30. | 74% |

- **What is held constant:** every pair uses the same camera, farmer spot, hour and 3× scale, in the clean export, as in VS16. Only the cabin sprite differs.
- **Grain:** the grade's film grain is seeded by time, so the whole frame differs slightly between any two runs, even with the same settings. `measure.json` therefore reports strong differences inside and outside the cabin, not raw pixel identity.
- **Not included:** no camera pan was rendered. The brief makes it optional, and P1 is on the same 16 px grid at the same scale as VS16.

## Quality assessment (Claude's, observed at 720p)

**Visible improvements during play:**
- **Door:** the clearest gain. It is lighter and warmer and no longer a dark slot. The casing, battens, hinges and latch read at 1:1. It is now the focal point the hierarchy asks for.
- **Foundation:** reads as rounded fieldstones at 1:1, by day and at night, not as masonry blocks.
- **Day windows:** the reveal depth and the diagonal glare read at 1:1. The panes look like glass instead of black holes.
- **Night windows:** warmer and more dimensional than VS16's flat yellow-white panes. They do not burn evenly, and the backlit muntins keep the window's structure. R3-1 itself is unchanged.
- **Roof by day:** reads as overlapping, hand-laid shakes rather than a brick grid.
  - The difference is modest at the home framing.
  - It is clearest in the door framing and at ×3.

**Honest weaknesses:**
- **Roof:** a little darker and lower in contrast in the game than VS16's, even after the calibration. At night, both roofs fall to near black under R3-1, so the change is invisible there. It still looks scripted in places: some soft per-shake blotches in the warm zone.
- **Fieldstones:** several large stones are flat, single-tone ovals with only a 1 px rim. A human artist would add a second plane to each.
- **Night glass:** the per-pane gradient shows stepped contour bands at ×6. They are not visible at 1:1.
- **Logs and corners:** essentially unchanged at gameplay scale, as the brief intended.
- **Against the golden oak:** the cabin is still more schematic and less organic than the oak. This pass narrows the gap only on the door, footing and windows.
- **Colour count:** up from 39 to 66, still within a restrained ramp set.

## Recommendation

Prefer **VS16-P1 as the non-production art candidate**, replacing VS16:
- **Clear gains at gameplay scale:** the door, the windows by day and night, and the foundation.
- **Roof:** a qualified gain by day and neutral at night. If the reviewers judge P1's roof too murky at 720p, the generator can keep P1's door, windows and footing with VS16's roof, a one-line choice. That would be a component decision, not a new revision series.

Production integration, stages 0–2, any `DESIGN.md` amendment and any spending still need the owner's separate approval. The environment pass (daylight, grass, paths, shadows, orchard, dock, gate) is the next priority and was not started.
