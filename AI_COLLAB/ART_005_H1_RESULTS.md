# ART-005 H1: one controlled PixelLab Pro edit of the 32 px farmhouse (results)

Status: **done and stopped for the owner's and ChatGPT's image review.** One `edit_image` (Pro) reference edit was run, as authorized. **25 generations** were charged, the quoted price (4,938 → 4,913; credits USD 0 before and after). No second generation, no alternative reference, no inpainting or repair, no purchase. No production file, asset, camera, lighting, gameplay, save or `DESIGN.md` change. E0/E1, G1, M0/M1, W-4 and VIS-002 are untouched (M0's `blockout.png`, `labels.png` and `anchors.json` were hash-checked before and after).

Labels: **[Measured]** by script or read off the overlay; **[Judgement]** my opinion, for the owner and ChatGPT to check.

## 1. What was run

| Step | Detail |
| --- | --- |
| Value pass (free) | `pl/g3/h1/valuepass.png`, made by `tools/art005_h1.py prep` from M0's own `build_labels()`. The labels and the alpha match M0 exactly (asserted). It adds only the large value decisions: the ridge-to-eave gradient, the hip planes, 16 px course lines with lips, the ridge and hip caps, the fascia, the eave shadow and its fade, 12 px lap lines, a silver-to-warm weathering gradient, foundation and chimney stone outlines, contact shadows under the sills, the door recess, and a selective outline. No micro texture. |
| References (free) | `ref_v2.png` (used) and `ref_c1.png` (made for the record, not used): 64 × 64 crops of slate, timber, stone and window cells only, from anchor_v2 and c1. |
| Paid edit | `edit_image` Pro, reference mode, 384 × 320, seed 4210, transparency following the input, the brief's §2.2 description. Job `7b583538-…`, asset `18d7ca65-…`, 112 s. Logged in `pl/pixellab-assets.json`. |
| Raw output | `pl/g3/h1/raw_edit.png`, unchanged (sha256/16 `6b2ad1f68139edc4`). |
| Only adjustment (free) | `h1_snap_day.png`: M0's exact alpha. 5,083 raw pixels outside M0's silhouette were cut, and 410 inside it (0.40% of the house) were filled from the nearest raw pixel on the same row. No palette snap, repaint or inpaint. |
| Night (free) | `h1_snap_night.png`: the day art plus a scripted emissive layer from M0's glass mask. The harness applies the existing night grade and puts the lights at the true window centres. |
| Harness | A new `art=g3` mode in `tools/art005_density.gd`, reading `pl/g3/32/`; the other modes are unchanged. |

## 2. Geometry (measured on the raw edit, not assumed fixed by the alpha snap)

| Anchor | M0 | Raw edit | Deviation |
| --- | --- | --- | --- |
| Door opening | x 173–211, top 224 | x 173–210, top 224 | 0 / −1 px |
| Door trim | x 167–217, top 218 | x 167–216, top 217–218 | ≤ 1 px |
| Glass, west / east | x 80–113 / 270–303, y 208–241 | x 79–112 / 269–302, y 207–240 | −1 px |
| Window frames | M0 lines | on the lines | ±1 px |
| Steps | upper 164–220, split y 309 | upper ≈ 165–218, split 308–309 | ≤ 2 px, but the upper tread is partly drawn as foundation stone |
| Eave line, ridge cap | 160; 12–20 | 160; 12–20 | 0 |
| Fascia | y 148–156 | a board at y 152–155 under a roof lip | thinner by about 4 px |
| Chimney | x 300–328, y 0–52 | x ≈ 299–328, y 0–52 | ≤ 1 px; the cap isn't a separate overhang |
| Foundation top | 280 | 280 | 0 |
| **Wall base / porch row** | **y 298** | **y 314: a second foundation course across the full width** | **+16 px, 5,083 px of new structure outside the footprint** |
| Silhouette (raw) | — | IoU 0.949 vs M0 | +5,083 / −410 px |

**Method note [Measured]:** the glass was found by colour segmentation (its bounding box). The door, trim, steps, eave, ridge, chimney and foundation were read from luminance profiles along fixed rows and columns, then checked on the overlay. The automatic profile matcher in `art005_h1.py measure` passed a synthetic shift test (+3/+2 px, read back exactly). But it gives low-confidence matches wherever the shading differs, even on the M0 mockup, so it isn't used for the verdict; its numbers are in `measure.json`.

## 3. Material quality (measured, then judged)

| Measure | Value pass | M0 mockup | Raw edit |
| --- | --- | --- | --- |
| Roof course period | 16 | 16 | 16 (strength 0.73) |
| Roof self-match within 8–64 px | 1.00 (flat by design) | 0.65 | **0.71 at exactly dx 32** |
| Wall lap period | 12 (0.73) | 12 (0.75) | 12 (**0.55**, weaker laps) |
| Noise, roof / wall | 3.1 / 5.2 | 11.5 / 14.0 | 7.3 / 11.7 (roof no longer the noisiest) |
| Mean luminance, roof / wall | 98 / 132 | 65 / 76 | 68 / **97** (the wall is the lightest large plane) |
| Under the eave (y 160–166) | 88 | 65 | **45** (the strongest dark line) |
| Colours / orphans / partial alpha | 344 / 0.28% / 0 | 22 / 1.78% / 0 | 38 / 1.01% / 0 |
| 2 × 2 grid uniformity | | | 49–55% at all four offsets: **not a 2× upscale**, just 2 px clusters |

Against the quality standard [Judgement, from the sheets]:

- **Large-scale lighting and hierarchy: pass.** The eave shadow separates the roof from the wall. The wall is clearly lighter than the roof. The door and windows are the focal point at both 1080p and 720p, a real step up from M0's flat, dark facade.
- **Door and windows: pass.** Readable, with thick, clean trim, a planked door, dark glass with glints and sill shadows. They are within about 1 px of the anchors.
- **Weathered timber: partial.** It has a convincing silver-grey to warm-brown gradient and real weathering. But the grain is streaky horizontal noise, and the lap boards are weakly defined (lap strength 0.55), so it reads more as painted streaks than as lapped boards.
- **Non-repetitive slate: fail.**
  - On the front plane the slates are nearly uniform, about 24 px wide, laid in a regular half-bond. At 720p it reads as a **brick wall or large tile grid** (self-match 0.71 at exactly 32 px, higher than M0).
  - The weathering is many small rust-brown flecks, not the 2–3 large soft patches the brief asked for.
  - The ridge-to-eave gradient is weak.
- **Consistent perspective and material: fail on the hips.** Both hips are drawn as grids of pale vertical panels, the west one almost white. They read as glazing or tin, not as slate planes continuing the front roof.
- **Foundation: partial.** The stones are large and irregular with good contact shadow, but warm brown rather than the cool grey the brief asked for. They also spill into the porch row (§2).
- **Chimney: acceptable.** Small stones with a lit west face, but no distinct cap overhang.
- **Controlled clusters and format: pass.** 38 colours, 1% orphans, no partial alpha, no resampling.

## 4. Stop-rule outcome

The authorization's stop rule applies: **the output still looks procedurally repetitive on its largest surface, the roof, and fails part of the intended hierarchy of materials (the hips).** It also has one major geometry drift: an extra foundation course in the porch row, which also overwrites part of the upper step tread. The alpha snap removes the part outside the footprint but cannot restore the step.

**Recorded as a failure of the PixelLab-only whole-house route against the premium standard. Nothing was rescued:** no second generation, no reference swap, no inpainting.

What the test did show [Judgement]:
- the scripted value pass works. PixelLab kept every interior opening within about 1 px and adopted the value hierarchy (eave shadow, light wall, focal openings), which no earlier attempt managed;
- what it can't do from this setup is draw a varied, hand-laid slate roof or coherent hip planes.

This matches the brief's §2.5: if the owner and ChatGPT confirm the failure, the next decision is an artist-led finish over the M0 geometry. H1's facade (wall, eave, door and windows) could serve as a value and colour reference for that artist. No further PixelLab spending is proposed.

## 5. Review package (`art/style_tests/ART-005/pl/g3/review/`)

- `ART-005H1_master.png`: harness at 1080p, day and night, M0 | H1 (sheets at 100%).
- `ART-005H1_master_2.png`: real 720p gameplay scale, full frames, day and night (75%).
- `ART-005H1_master_3.png`: full facade (value pass, raw, adjusted, M0) with the raw-vs-adjusted difference map, plus the coordinate overlay with the measured deviations (59%).
- `ART-005H1_master_4.png`: 1:1 and 3× crops of the roof, hip, timber, door, window, foundation and steps, and chimney, plus the receipt and measurement table (73%).
- Sheets: `h1_harness_1080p.png`, `h1_gamescale_720p.png`, `h1_facade.png`, `h1_overlay.png`, `h1_crops.png`, `h1_receipt_measure.png`. Full harness frames are in `builds/review/ART-005/h1/` (gitignored).
- Data: `pl/g3/h1/` (value pass, references, raw edit, adjusted day and night, emissive, `prep_log.json`, `measure.json`).
- Reproduce:
  - `python tools/art005_h1.py prep`
  - `python tools/art005_h1.py measure`
  - `godot --path . -s tools/art005_density.gd -- density=32 art=g2|g3 hour=12|21.5 framing=int|today task=stills res=1920x1080|1280x720 out=builds/review/ART-005/h1`
  - `python tools/art005_h1_review.py`
  - then `tools/review_sheet.ps1` and `tools/review_master.ps1`.
