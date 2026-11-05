# ART-005 C1: zero-credit S3/P1 farmhouse composite (non-production)

**Brief:** the owner's ART-005 P1 image-review follow-up, after ChatGPT's five-sheet P1 review (`0966f99`).
Make one reversible, non-production composite: S3's roof and structure, plus P1's facade. Then add an optional
zero-generation shake-kit design study and stop for review.

**Spend:** zero. No PixelLab or SpriteCook call of any kind (not even a balance check), no purchase.
Every operation is a mask, a pixel copy or a per-colour palette remap.

## What C1 is

The files are in `art/style_tests/ART-005/pl/g7/c1/`, made by `tools/art005_c1.py`.

| From | Pixels | Parts |
|---|---|---|
| S3 roof A (`pl/g6/shake/32/`) | 55,031 | Roof field, ridge, fascia (148–154), eave shadow (155–159), chimney, the hewn timbers (2,417 px), stone foundation (row 281 down) and steps |
| P1 (`pl/g7/p1/32/`) | 43,280 | Log wall rows 160–280 between the timbers; window frames, sills and glass; door and trim down to row 297; lamp |

- **Silhouette:** S3's alpha exactly (IoU 1.0). No geometry is new.
- **Anchors:** windows, door, steps and chimney sit on S3's anchors. P1 measured 0–1 px on these, and the overlay sheet shows them.
- **Originals:** the S3 day and night sprites, the P1 day and night sprites and P1's raw edit were sha256-checked before and after. They are unchanged.

## Manual adjustments (all scripted and reproducible)

1. **Corner mask.** The exact S3 hewn-corner edit is the pixels where `pl/g6/logc` differs from `pl/g5/log`.
   - That edit also repainted plain wall between the timber ends, in S3 wall colours.
   - Beside the remapped P1 logs those pixels showed as grey-green blotches, so they were handed to P1.
   - Only the timber colours and their dark outlines stay S3.
2. **Palette fix.** One remap was applied to each of the 24 P1 colours used, so no new colours can appear. The C1 sprite has 59 colours, against S3's 88 and P1's 25.
   - **Hue:** wood hues (orange/brown) moved from 0.069 to 0.083, so less orange.
   - **Saturation:** multiplied by 0.80.
   - **Luma:**
     - At or below 24 (outlines and log seams): unchanged.
     - The 24–90 grain band: lifted by up to 12, most at 57. This softens the harsh dark streaks.
     - Above 130: compressed by a quarter, to tame the hot highlights.
3. **Night glass refit.** C1's lit glass is every pixel inside S3's pane boxes that is not a P1 brown frame, mullion or outline. It uses S3's night colours.
   - Lit: 1,596 px.
   - Unlit: 232 S3 glass px, which are P1 frame or mullion.
   - Nothing is lit outside the panes.
   - This fixes the mullion mismatch that ChatGPT flagged in P1's pasted-on glass.
4. **Control.** `c1/32n/` is the same composite without the palette fix, kept for comparison only.

## Measurements [Measured]

Wall measurements are on the clear wall panels.

| | S3 | P1 | C1 |
|---|---|---|---|
| Wall mean RGB | 111 / 87 / 61 | 137 / 91 / 58 | 125 / 96 / 68 |
| Saturation / hue | 0.455 / 0.087 | 0.549 / 0.069 | 0.443 / 0.082 |
| Wall luma p5 / p50 / p95 | 25 / 101 / 137 | 19 / 112 / 164 | 19 / 111 / 156 |
| Wall luma SD / noise | 33.4 / 12.7 | 45.0 / 17.3 | 41.8 / 16.1 |
| Log course strength | 0.42 | 0.53 | 0.52 |
| Roof luma SD / pale specks | 10.7 / 7 | 26.3 / 72 | 10.7 / 7 |

## Validation renders

All three houses were rendered in one session, in the clean export `builds/review/ART-005/p1_export/`. That export is HEAD's tools and art, with no VIS-002 working-tree changes.

- `tools/art005_density.gd density=32`, with `art=g6 var=shake`, `art=g7 var=p1` and `art=g7 var=c1`:
  - 1080p integer scale and real 720p gameplay scale;
  - noon, and the ART-005 harness night.
- `tools/art003_wide.gd`, W-4 + F2, north view (house, golden oak, well and the path), with `house=g7:c1`:
  - noon, and R3-1 night.

No harness code changed: C1 sits in `pl/g7/c1/32/`, which the existing `art=g7 var=` and `house=g7:` modes already read.

## Judgement

- **At 720p gameplay scale, C1 is a modest but real improvement over S3:**
  - the window frames and door read more clearly;
  - the log courses are more defined;
  - the facade is warmer.
- **Compared with P1:**
  - C1 keeps S3's calmer roof, fascia and chimney, with no brick look and no pale blotches;
  - its wood is visibly less orange.
- **Seams:** at 720p and in the homestead, no rectangular patch seam is visible.
  - **Eave to wall:** P1's slightly deeper eave shadow (to about row 167) continues S3's shadow band cleanly.
  - **Door into foundation:** reads as one piece.
- **Night:**
  - **R3-1:** C1's lit facade is warm without P1's orange cast. The glass sits inside P1's frames.
  - **Harness night:** C1 is close to S3, with a better door.
- **Remaining weaknesses [Judgement]:**
  - The wall is still brighter and busier than S3: noise 16 against 13, and the grain is only partly softened. A hand pass on individual streaks would help.
  - S3's timber ends are a touch cooler than the C1 logs at 3x, though not at 720p.
  - The roof is unchanged, so it is still S3's prototype: near-black at harness night, and not premium.
- **Overall:** C1 meets the success criterion as a coherent cabin with S3's roof and an improved facade. It is still short of the final professional standard, and the roof is now the weakest part.

## Optional study: hand-authored shake kit

`pl/g7/c1/kit/`, made by `tools/art005_c1_kit.py`. It is design only and does not replace roof A.

- **Pieces:** six, 6–14 px wide, with a 9 px exposure (S3's course height).
- **Piece details:**
  - a dark keyway at each joint;
  - a butt edge with a 1 px cast shadow;
  - one catch-light row;
  - plain, tapered, split and cupped variants.
- **Laying:** courses are laid from the eave up. Joints are staggered at least 3 px from the course below, and the butt lines step by 0–1 px.
- **Shading:** whole palette steps only, from seven steps of S3's own palette:
  - lighter up-slope;
  - darker at the eave;
  - two silvered zones.
- **[Judgement]**
  - It reads more like overlapping wood shakes than S3's field: the butts step and cast shadows.
  - But it is uniform and dense at 1:1, and the silvered zones are too faint.
  - A real kit would need hand-drawn pieces and a hand-placed eave and ridge row.
  - It is evidence that a kit approach is feasible, not a candidate roof.

## Not done or not shown

Not shown:

- dusk, rain, fog, winter, trek or motion;
- restoration stages 0–2 on C1;
- the south homestead, whose fields are unchanged.

Not touched: production art, layout, camera, scaling, lighting, gameplay, saves, porch and storey flags, `DESIGN.md`, VIS-002, ART-003, and ART-005 `g2`–`g7` originals.
