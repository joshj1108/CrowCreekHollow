# ART-005 C2: zero-credit roof polish of the C1 log cabin (non-production study)

**Status:** this is a study for review only. It is not production art and does not approve any integration.

**Answers:** the owner's C1 image-review brief, following ChatGPT's four-sheet C1 review (`f63e72b`).

**Spend:** zero. There were no PixelLab or SpriteCook calls and no purchases. The work is a deterministic Python repaint (`tools/art005_c2.py`).

## What C2 is

C2 is C1 with two regions repainted. Every other pixel is C1's exactly; the script asserts this, and alpha is identical.

C1 itself (`pl/g7/c1/`), S3 Roof A (`pl/g6/shake/`) and P1 were not written to. Their sha256 hashes were checked before and after the run, and all are unchanged. S3 Roof A stays available as the unchanged control.

C2 lives in `art/style_tests/ART-005/pl/g7/c2/32/`. The existing harness modes `art=g7 var=c2` and `house=g7:c2` draw it, so no harness code changed.

### Region 1: the roof shake field

- **Area:** rows 57–147 and columns 8–375, minus C1's chimney block (x 294–333, y 57–66), which is kept with its cast shadow.
- **Pixels:** 24,422 of 33,088 field pixels changed. The rest happen to match their C1 colour.
- **Kept exactly:**
  - the ten course rows;
  - the ridge (rows 42–56), the fascia (148–154) and the eave shadow (155–159);
  - both verges and the chimney.
- **Palette:** only C1's own roof colours. The warm brown ramp and C1's grey "silvered" ramp were reused, and no new colour was introduced.

**Construction**

The field is painted course by course from the eave up, so each upper butt overlaps the course below it. Each shake has:
- a one-row shadow under the butt above it;
- a flat face;
- a butt catch-light row, on wide or dark shakes only;
- a one-pixel cast-shadow line.

**Rule-driven layout (fixed seed 5, chosen once and not re-rolled)**

- **Shakes:** 337, between 6 and 16 px wide (mean 10.9, 11 distinct widths).
- **Staggering:** no width repeats twice in a row, and every joint sits at least 3 px from the joints of the course below.
- **Joints:** 110 hard, 186 soft (face only, one step darker) and 31 shown only as a value change. This avoids a dark border around every shake.
- **Butts:** 59 shakes drop 1 px and 34 sit 1 px short, so the course lines are no longer perfectly straight.
- **Wear:** 64 chipped butt corners, 57 split shakes (cracks up from the butt) and 154 short grain streaks. The grain streaks are interrupted and never reach the butt.

**Hand-authored value masses**

Each shake takes one value from the masses at its centre, so the shading changes in whole shakes and adds no pixel noise. The masses are:
- a ridge shadow;
- a lit upper slope;
- a large sun-silvered field at the upper left-centre (53 shakes on C1's grey ramp);
- a smaller bleached patch;
- a runoff streak under the chimney;
- damp eave corners;
- a low shadow band;
- verge occlusion.

**Hand-placed moss:** 7 clusters of 1–5 px, placed only on shadow lines near the eave corners and in the lee of the chimney. No pale specks were added.

### Region 2: the hewn corner timbers

- **Area:** the S3 timber pixels from C1's own mask (rows 160–280, x < 26 and x > 357). 1,580 of 2,400 pixels changed.
- **Method:** 8 colours were moved half way toward the wall's median hue and saturation, and a third of the way in luma. Outlines and end-grain cracks were kept.
- **Timber medians:**

  |            | hue    | saturation | luma |
  |------------|--------|------------|------|
  | C1         | 0.0778 | 0.492      | 96.4 |
  | C2         | 0.0805 | 0.475      | 97.8 |
  | Wall (target) | 0.0806 | 0.465   | 100.0 |

## Measurements: roof field, C1 vs C2

| Measure | C1 | C2 |
|---|---|---|
| luma mean / SD | 46.2 / 10.9 | 45.4 / 12.1 |
| pixel noise (mean neighbour step) | 4.62 | 4.74 (+3%) |
| broad mass contrast (SD of 24×18 block means) | 2.64 | **4.20** (+59%) |
| course repetition (row autocorrelation at 9 px) | 0.785 | 0.760 |
| near-black line share | 0.096 | 0.101 |
| colours | 25 | 23 |

The texture is no busier than C1's (+3% pixel noise), and the broad value structure is clearly larger. Course repetition dropped only slightly, because the ten course rows were deliberately kept for construction clarity.

These numbers describe the change; they do not prove that it is better.

## Validation

Both houses were rendered in one session in the clean export `builds/review/ART-005/p1_export/` (with C2 copied in, and no VIS-002 changes):
- `tools/art005_density.gd density=32`, with `art=g7 var=c1|c2`:
  - 1080p integer and real 720p;
  - noon and the ART-005 harness night.
- `tools/art003_wide.gd`, W-4 + F2, homestead north, with `house=g7:c1|c2`:
  - noon and the R3-1 night.

The homestead frames also differ outside the house (falling leaves, grass), and that varies from run to run. A second C1 render differs from the C1 package's own frame just as much. Only the house is an authored difference.

**Review package:** `art/style_tests/ART-005/pl/g7/c2/review/`

| Master | Contents | Scale |
|---|---|---|
| `ART-005C2_master.png` | C1 \| C2 at 1080p integer, noon and harness night | 97% |
| `_master_2.png` | C1 \| C2 at real 720p, plus the changed-pixel map, the shading plan and the change record | 66% |
| `_master_3.png` | Roof and eave at 3×, timber corners at 3×, and all of them at 1:1 | 81% |
| `_master_4.png` | W-4 homestead north, noon | 65% |
| `_master_5.png` | W-4 homestead north, R3-1 night | 65% |

**Not shown:** dusk, rain, fog, winter, the trek, motion, the restoration stages on C2, and the south homestead.

## Qualitative assessment (Claude's judgement; not yet reviewed by ChatGPT)

**Improved**
- At 1080p and 3× the roof now reads as overlapping, hand-laid shakes rather than a brick or tile grid. Staggered joints of varied widths, soft joints and the occasional dropped or short butt break the "masonry" rhythm C1 inherited from S3.
- The eave, fascia and ridge construction is untouched and still reads clearly.
- No speckle was added, and texture density did not grow.

**Modest**
- At real 720p and in the W-4 homestead (cabin at 1.5 screen px per art px), the change is visible but small. The roof looks calmer and finer, and less blotchy than C1's grey and brown tile patches.
- The hand-authored masses are subtle at that distance. The roof still reads mostly as one dark brown plane.
- The timber change is real by measurement but barely visible except at 3×.

**Not improved**
- At harness night the roof is as near-black as C1. Its mean value is unchanged on purpose: no lighting or overall value change was in scope.

**Against professional pixel-art craftsmanship**
- C2 is closer: there is a deliberate overlap structure, joint weights are varied, and the shading follows whole shakes.
- It is still short of hand-finished commercial roofs in three ways:
  - the butt edges are still mostly straight runs;
  - there is no per-shake taper or curl;
  - the shading masses are too low in contrast to read as composition at gameplay scale.

## Limitation

More polish of the same kind (more rules, more variation) will not substantially change how the roof reads at gameplay scale. The remaining weakness there is the roof's overall value and the contrast of its masses, which means a decision about the roof's value range. That decision is the owner's, so the next step is a decision, not another round of polish:

- **Option 1:** lift C2's ramp one step and roughly double the mass contrast. This is still zero-credit.
- **Option 2:** have a human pixel artist hand-finish the butt edges.

Neither has been done.

## Untouched

- Production art, layout, camera, scaling and lighting.
- Gameplay and saves.
- The porch and storey flags.
- `DESIGN.md`.
- VIS-002, ART-003, and the S3, P1 and C1 files.
