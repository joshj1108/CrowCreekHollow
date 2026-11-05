# ART-005 P1: one PixelLab Pro edit of the approved S3 Roof A log cabin (results)

Status: **done and stopped for the owner's and ChatGPT's image review.** This is the single `edit_image` (Pro) operation the owner authorized on 2026-11-05 after the S3 review (recorded as D-018). Non-production only.

- **Spend:** **25 generations** were charged, the quoted price: 4,913 → 4,888. Credits were USD 0 before and after. There was no second attempt, reroll, other seed, inpainting or purchase. No SpriteCook call was made.
- **Not changed:** production art, the live farm and its layout, gameplay, farming, saves (real or test), camera, scale, production lighting, P-1, `DESIGN.md`, and porch and second-storey code.
- **Preserved:** the S3 input. `pl/g6/shake/32/house_day.png` was hash-checked before and after (`474073e4…`). VIS-002, ART-003 W-4 and F2, and ART-005 `g2`–`g6` are untouched. P1 writes only new folders: `pl/g7/` and its review.

Tags: **[Measured]** = from pixels, by script or by profile; **[Judgement]** = my opinion, for the owner and ChatGPT to check.

## 1. What was run

| Step | Detail |
| --- | --- |
| Balance check (free) | `get_balance`: 4,913 generations, USD 0. |
| Cost check | The documented band for `edit_image` is 10 up to 256², 15 up to 341², and 25 above that. 384 × 320 measures about 350², so it falls in the 25 band. H1's identical call was billed 25. There is no free pre-quote. |
| Input | `pl/g6/shake/32/house_day.png`, unchanged, at 384 × 320. This is the S3 stage 3 base without dressing. |
| Reference (free) | `pl/g7/p1/ref_s3.png`, 64 × 64, cut from the ART-003 PixelLab family: two `r3/oak_c.png` bark cells (warm hand-painted wood) and `r3/boulders.png` stones. The mossy log and the grass cells were left out so that moss and green would not transfer to the walls. |
| Paid edit | `edit_image` Pro, reference mode, seed 5317, transparency following the input. Job `0ceb4ff0-…`, asset `2286075d-…`, 79 s. The prompt is logged in `pl/pixellab-assets.json`. It asked for individually varied, tapered shakes with no brick or tile grid, hewn logs, dovetailed corners, clear frames, eave and contact shadows, and nothing added. |
| Raw output | `pl/g7/p1/raw_edit.png`, exactly as downloaded and set read-only (sha256 `377eadb3…`). |
| Only adjustment (free) | The input's exact alpha. 503 raw pixels outside it were cut: the 1 px higher ridge row and two chimney-edge columns. 163 pixels inside it were filled from the nearest raw pixel on the same row. That is **0.17% of the house**. There was no palette snap, repaint or inpaint. |
| Night (free, scripted) | The adjusted day sprite plus S3's own night glass: the 1,828 px where S3's night sprite differs from its day sprite. The harness applies its night grade and window lights. |
| Harness | New modes: `art=g7 var=p1\|raw` in `tools/art005_density.gd` and `house=g7:<var>` in `tools/art003_wide.gd`. All other modes are unchanged. |

## 2. Geometry (measured on the raw edit, before the alpha adjustment)

The direct method finds the 1 px dark outlines along fixed rows and columns, and the glass by colour segmentation. The profile matcher from H1 passes its synthetic shift test (+3/+2 px read back exactly). It reported +5 px on the window right and bottom edges, but that was a false match: P1 painted the window frames lighter than the wall, which flips the sign of the edge gradient. The direct profiles and the overlay show those edges in place.

| Anchor | S3 input | P1 raw | Deviation |
| --- | --- | --- | --- |
| Window frame outline (W) | x 74 / 117–118, y 202 / 245–246 | x 74 / 118, y 202 / 246 | ≤ 1 px |
| Glass (colour segmentation) | W 80–112 × 208–240, E 270–302 × 208–240 | W 80–112 × 209–240, E 270–301 × 209–240 | top +1, E right −1 |
| Sill | y 247–251 | y 247–251 | 0 |
| Door trim and opening | trim outline 167 / 215–216, opening 173–210, top 218 / 224 | 166–167 / 215–216, 173–210, 218 / 224 | ≤ 1 px |
| Steps, foundation top, wall base | matcher 0 | 0 | 0 |
| Chimney sides and top | x 291–328, top 20 | the same, top 19 | ≤ 1 px |
| Ridge (roof silhouette top) | y 42 | y 41 on 315 of 384 columns | +1 px up |
| Ridge-board bottom shadow | y 56–57 | y 53–54 | 3 px higher (a thinner board) |
| Fascia board | y 148–154, a lit board | **repainted as a row of hanging shake butts** | the board is gone; the eave line is kept |
| Eave shadow | y 155–159 | y 155–159 | 0 |
| Silhouette | — | +503 / −163 px, IoU **0.9933** | no new structure |

**[Measured]** No new architecture was added. There is no porch, storey, gable or window, and the door and windows did not move. The footprint and collision rectangle are unchanged. The only structural reading changes are a thinner ridge board and the lost fascia board.

## 3. Material quality

| Measure [Measured] | S3 input | P1 raw |
| --- | --- | --- |
| Roof mean luma / SD | 46.3 / 10.7 | 56.7 / **26.3** |
| Roof pale specks (> mean + 3 SD) | 7 px | **72 px** |
| Roof course period (strength) | 9 px (0.81) | 9 px (0.66) |
| Roof self-match within 8–64 px | 0.53 | 0.55 |
| Roof noise | 5.1 | 10.6 |
| Wall mean luma / SD | 91.3 / 33.4 | 100.9 / 45.0 |
| Wall log period (strength) | 15 px (0.42) | 15 px (0.53, clearer courses) |
| Wall minus roof luma | 45.0 | 44.2 |
| Colours / orphans / partial alpha | 88 / 0.59% / 0 | 25 / 1.54% / 0 |

**[Judgement]**, from the review sheets, against the owner's priorities:

1. **Wood-shake roof: fail.**
   - The shakes are still near-uniform rectangles laid in a regular bond, now with heavier outlines. At 720p and in the homestead the roof reads as a brick or tile wall, the same failure as H1's slate.
   - The "silvered patches" came out as about ten small, pale grey-white blotches. They look like glitches or snow, not weathering.
   - There is no taper, no irregular butts and no ridge-to-eave gradient.
   - The lowest course hangs over where the fascia board was, so the eave edge is busier than S3's.
2. **Hewn logs: partial improvement.** The logs are warmer and honey-coloured, with clearer courses and seams and more light on the upper faces. They are also more orange and streakier than the restrained grain asked for.
3. **Corners: no real change.** They are S3's timber ends, slightly re-coloured. They still read as stacked blocks more than as dovetails.
4. **Window and door frames: improved.** The frames are warm and clear, the glass is dark with glints, and the door is lighter with clear planks and battens. This is the best part of the edit.
5. **Stone foundation and chimney: kept, the chimney slightly worse.**
   - The foundation is consistent with S3, with a few green moss pixels added to the stones and steps.
   - The chimney is darker and its stones less defined than S3's.
   - At night, S3's pasted glass meets P1's new warm mullion cross. That is a scripted-night artefact, not PixelLab's.
6. **Shading: partial.** The eave shadow and the top-log shading under it are stronger. The ground contact is unchanged.
7. **Palette: mixed.** It is warmer overall and the wall separates clearly from the roof. But the roof's blotches and heavier outlines make it noisier.
8. **Readability at game scale:**
   - At 720p the door and windows read better than S3's.
   - The roof is the noisiest surface on the house.
   - At harness night the roof keeps a faint texture, where S3's fell to black. This is the "one step lighter" that S3 asked for, but here it is a side effect of the extra contrast.

**Wider homestead (R3-1 night, day):** the cabin sits in the same spot as S3's. The warmer wall ties in with the golden oak and the autumn ground. The roof blotches stand out at day as light flecks. The oak, well, fields and ground are the older ART-003 prototype art, and this test does not judge them.

## 4. Stop-rule outcome

**The stop rule is triggered**:

- "the roof becomes excessively repetitive";
- "the finished artwork does not show a convincing improvement in professional artistic quality" on the roof, which is priority 1;
- the fascia board was repainted as part of the roof.

None of the other stop conditions applies:

- the door and windows are within 1 px;
- the silhouette IoU is 0.993, and the only change to the roofline is a 1 px higher ridge;
- the pixel density and perspective are consistent;
- the log courses stay coherent.

**Recorded as a failure of the roof finish; nothing rescued.** No second generation, no inpaint, no hand repair of the raw. The adjusted file differs from the raw only by the alpha restore.

My reading [Judgement]:

- Across H1 and P1, PixelLab's whole-image edit has twice improved the openings, the facade value hierarchy and the warmth of the timber, while keeping geometry within about 1 px.
- Both times it redrew a large roof field as a regular grid of rectangles, whatever the prompt said about irregularity.
- The facade from this result (logs, frames, door) is usable as a colour and value reference.
- A professional roof probably needs a different route: a hand-painted or artist-made shake field, or a small tile kit of shake units assembled by script with hand-placed variation, then one unified value pass.
- Proposing that is for the owner. No further spending is proposed here.

## 5. Review package (`art/style_tests/ART-005/pl/g7/review/`)

| Master | Content | Sheet scale |
| --- | --- | --- |
| `ART-005P1_master.png` | S3 vs P1 in the harness at 1080p (integer 2x) and at real 720p game scale, noon and ART-005 harness night | 64% |
| `_master_2.png` | input, raw and adjusted sprites, with a map of the adjustment; geometry overlay; receipt and measurement table | 61% |
| `_master_3.png` | roof and log wall at 3x and 1:1; west and east corners, window (day and night), door, foundation and steps, chimney | 68% |
| `_master_4.png` | homestead north (cabin, golden oak, well, crossroads): S3 vs P1, day and R3-1 night | 50% (borderline; full panel `p1_farm_north.png`) |
| `_master_5.png` | homestead south (fields, walks, gates, road): as above | 50% (borderline; `p1_farm_south.png`) |

Night labels:
- The house sheets (masters 1–3) use the **ART-005 harness night**: production `NIGHT_TINT`, lantern and window lights. They do not use R3-1.
- The homestead sheets (masters 4–5) use **R3-1**, the ART-003 prototype night.

The trees, ground and props around the house in the harness frames are older placeholder or prototype art, not part of this test.

Not captured: dusk, rain, fog, winter, a trek, motion.

Reproduce:
- `python tools/art005_p1.py`
- `godot --path . -s tools/art005_density.gd -- density=32 art=g7 var=p1|raw hour=12|21.5 framing=int|today task=stills res=1920x1080|1280x720 out=builds/review/ART-005/p1`
- homestead, in a `git archive` export of HEAD plus the P1 files:
  `godot --path . -s tools/art003_wide.gd -- mode=wide layout=b grass=1 art=f2 house=g6:shake|g7:p1 at=45,10|50,30 hour=12|21.5 size=1924x1080 out=builds/x/<tag>.png`
- `python tools/art005_p1_review.py`, then `tools/review_master.ps1`.

## 6. Files created

- **PixelLab output:** `art/style_tests/ART-005/pl/g7/p1/raw_edit.png` (raw, unchanged).
- **Free derivatives:**
  - `pl/g7/p1/ref_s3.png` (the reference);
  - `p1_snap_day.png`, `p1_snap_night.png` and `measure.json`;
  - `pl/g7/p1/32/house_day|night.png` (harness copies);
  - `pl/g7/raw/32/house_day|night.png` (raw, with S3's night glass for the night file).
- **Review:** `pl/g7/review/` (10 panels, 5 masters).
- **Scripts:**
  - new: `tools/art005_p1.py` and `tools/art005_p1_review.py`;
  - changed: `tools/art005_density.gd` (`art=g7`) and `tools/art003_wide.gd` (`house=g7:`).
- **Logs:** the job is added to `pl/pixellab-assets.json`.
- **Raw frames (gitignored):** `builds/review/ART-005/p1/` and `builds/review/ART-005/p1_export/`.
