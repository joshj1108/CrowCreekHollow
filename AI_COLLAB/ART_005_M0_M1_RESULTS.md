# ART-005 M0 + M1: complete farmhouse blockout and mockup, and refined style anchor (results)

Task: the owner's M0/M1 authorization after ChatGPT's review `9bf8302`. Owner: Claude Code. Reviewers: ChatGPT, then the owner.

**Budget.** Zero PixelLab generations and zero USD were spent. No PixelLab tool was called at all.

**Untouched.** `DESIGN.md`, production art, gameplay, saves, layout, camera, scaling and lighting are unchanged. So are E0/E1 outputs, W-4, VIS-002 and earlier review artifacts. The G1 files are byte-identical: `pl/G1_PRESERVED.sha256` passes for all 27 files.

**Not started:** H0, H1, the well test, farmhouse stages 0–2 and production migration.

Labels: **[Measured]** checked by script; **[Judgement]** my opinion, for the owner and ChatGPT to check.

## 1. What was made

| Item | Where |
| --- | --- |
| Blockout script: the label map, flat blockout, masks, anchors and mockup | `tools/art005_m0.py` |
| Flat blockout, label map, `anchors.json` (every coordinate below), emissive layer | `art/style_tests/ART-005/pl/g2/m0/` |
| Harness files: `house_day`, `house_night`, `ext_dormer_day/night`, `ext_porch_day/night` | `pl/g2/32/` |
| Comparison only: the same blockout skinned with anchor_v2 | `pl/g2/m0/house_day_v2mat.png`, `house_night_v2mat.png` |
| M1: `anchor_v2.png`, its diff, `m1_log.json`, `M1_EDIT_LOG.md` | `pl/g2/m1/`, script `tools/art005_m1.py` |
| Review panels and masters | `pl/g2/review/`, script `tools/art005_m0_review.py` |
| Harness: new `art=g2` mode (reads `pl/g2/<density>/`), `ext=porch,dormer`, window lights at the exact window centres. Other modes are unchanged. | `tools/art005_density.gd` |

The mockup is a **geometry and composition test**. Its materials are G1 c1 swatches, tiled and recoloured into hand-built structure: 16 px shingle courses, 12 px planks, trim, glass panes and stone. **It is not final art.**

## 2. M0: geometry [Measured]

The coordinates are art px at 32 px per tile, measured from the sprite's top-left. The canvas is 384 × 320.

| Anchor | Game source | M0 |
| --- | --- | --- |
| Collision footprint, 11 × 7 tiles | `farm_layout.gd`: roof rows 5–9, walls 10–11, door at column 24; sprite offset −0.5 tile | x 16–368; roof rows y 74–234; wall rows y 234–298. The only opaque pixels outside it below the eave are the 1 px eave-underside outline (overhang allowance) |
| Roof overhang | 12-tile sprite vs 11-tile footprint | x 0–16 and 368–384, roof only |
| Eave line / eave band | facade 4.3 tiles | eave y 160; fascia and under-eave band y 148–160, owned by the roof |
| Wall base | `HOUSE_WALL_BOTTOM_TILES` 9.3125 | y 298 |
| Door and steps | door tile = middle of the footprint | Opening x 173–211, y 224–298 (38 × 74), centre **192.0**. Steps x 160–224, y 298–320 |
| Windows | `HOUSE_SPRITE_WINDOWS` (3.0, 7.0), (8.94, 7.0) → (96, 224), (286.08, 224) | 45 × 45 at x 74–119 and 264–309, y 202–247. A 45 px window has a middle pixel, not a middle edge, so the glass centres are (96.5, 224.5) and (286.5, 224.5): **0.5 px and 0.42 px from the light points** |
| Roof projection | straight-on 3/4, light from upper left | One hipped roof: the front plane is a trapezoid from the ridge (y 20, x 64–320) to the eave; the hips are triangles outside it (lit west hip +1 step, shaded east hip −1 step); 8 courses of 16 px exactly |
| Chimney | outside the production dormer zone | Cap x 297–331, y 0–6; stack to y 52. **7 px** clear of the dormer zone |
| Dormer zone | `estate_system.gd` `_draw_outside` (`second_storey`) | x 94–290, y 59–127 (with the 2 px outline). It contains only plain front-plane shingle |
| Porch | purchased extension, never in the base house | Porch row y 298–330 holds only the steps and the wall-base outline row at y 298 |

## 3. Findings

**F1. The production window lights miss the windows (flagged, not changed) [Measured].** `main.gd` `_build_window_lights` adds `HOUSE_SPRITE_WINDOWS` to the footprint's top-left (map row 5), but the sprite's top is 2.3125 tiles higher (`_draw_house_roof_layer`: porch row − 9.3125). In sprite px the lights land at y **298** (the wall base), not 224, and at y 330 with `WINDOW_SPILL`. The overlay draws all three points. The E1 harness approximates its own (±3.1, −2.8 tiles). The `art=g2` mode uses the exact window centres. Lighting is out of scope, so nothing in the game changed.

**F2. The production porch geometry clashes with a 32 px door [Measured].** `_draw_outside` (`porch`), scaled to this canvas:
- its roof strip at y 287–294 crosses the door opening and the foundation;
- its deck at y 316–328 overlaps the steps by 4 px;
- its posts at x 19–23 and x 361–365 sit on the corner posts.

M0 therefore proposes a 32 px porch layer (384 × 336, shares the house origin):
- **Shed roof** y 164–194 and fascia y 194–200.
- **Posts:** 8 px wide at x 24, 136, 240 and 352.
- **Deck** y 298–322 inside the porch row, front edge y 322–330, centre step x 164–220.

| Clearance from the proposed porch to | px |
| --- | --- |
| Window frames | 2 |
| Window glass | 8 |
| Door trim | 18 |
| Nearest post to a window frame | 16 |
| Nearest post to the door trim | 23 |
| House eave, above the porch roof | 4 |

Adopting this geometry needs a production change to `estate_system.gd`, which is not authorized.

**F3. The production dormer is below the mark scale [Measured, Judgement].** The re-skinned dormer at today's geometry is 192 × 64 px with 16 × 15 windows. It fits the roof: 39 px below the ridge, 21 px above the eave band, 7 px from the chimney. But its windows are a third of the house's 45 px windows, and its gable is flat (35 px tall over 192 px). It reads as a bunkhouse strip rather than a dormer [Judgement]. Fixing it needs a new geometry and an estate code change.

**F4. Format [Measured, `tools/art005_check.py --density 32`]:**

| File | Colours | E0 palette | Orphans | Partial alpha | Resampled | Outline |
| --- | --- | --- | --- | --- | --- | --- |
| M0 `house_day` (c1 materials) | 22 | 100% | 1.78% | 0 | no | 100% |
| M0 skinned with anchor_v2 | 17 | 100% | 0.14% | 0 | no | 100% |
| Proposed porch layer | 16 | 100% | 1.24% | 0 | no | 100% |
| Dormer layer | 14 | 100% | 1.40% | 0 | no | 100% |
| G1 composite, for reference | 29 | 100% | 2.79% | 0 | no | 97% |

## 4. M1: anchor_v2 [Measured]

`anchor_v2.png` is a new file; c1 is unchanged.
- **Orphans:** 4.76% → **0.03%** (gate ≤ 3%).
- **Colours:** 38 → 31. Every colour is an existing c1 colour, all on the E0 palette.
- **Pixels changed:** 2,231 of 9,216 (24%).
- **Method:** three rules per swatch (merge near-duplicate colours, absorb orphans, absorb clusters under 2 × 2 while protecting dark structural lines), then **4 manual edits** (63 px) that restore the window's mullion row and glints, which the speck rule had removed.
- **Time:** about 5 minutes of agent time and 0.2 s of compute. An artist's time was not measured.
- **Mark sizes were not changed.** c1's slate courses are about 8 px and its stones 9–11 px, against the spec's 16 px courses and 10–16 px blocks. Full log: `pl/g2/m1/M1_EDIT_LOG.md`.

## 5. Review package (`art/style_tests/ART-005/pl/g2/review/`)

| Request | File |
| --- | --- |
| Full house at 1080p, day and night, in the ART-005 harness; G1 before, M0 after | `m0_harness_1080p.png`; full frames in `harness/m0_day_1080p.png`, `m0_night_1080p.png` |
| Gameplay-scale capture at 720p (`framing=today`: 48 px per tile, the 32 px art at 1.5×), plus integer 720p and night | `m0_gamescale_720p.png`; `harness/m0_*_720p_*.png` |
| Architectural coordinate overlay | `m0_overlay_coords.png` |
| 1:1 crops of the roof, windows, door and foundation, with 4× enlargements, c1 materials vs anchor_v2 materials | `m0_crops_1to1.png` |
| Original c1 vs refined anchor_v2 | `m1_c1_vs_anchor_v2.png` |
| Porch-extension clearance and roof/dormer compatibility | `m0_extension_clearance.png`, `m0_extensions_1080p.png`; `harness/m0_ext_*_1080p.png` |
| Masters | `ART-005M0_master.png` (harness, 95%), `_master_2.png` (720p + overlay, 60%), `_master_3.png` (crops, clearance, M1; 55%), `_master_4.png` (extensions, 95%) |

Re-create everything with:
1. `python tools/art005_m0.py`, `python tools/art005_m1.py`, `python tools/art005_m0.py --mat v2`
2. the harness commands in the board post
3. `python tools/art005_m0_review.py`

## 6. What M0 shows, and what it cannot [Judgement]

**Shows:**
- The whole house can be built to the game's anchors exactly. The collision footprint, door tile, steps, window and light points, eave, wall base, chimney clearance and dormer zone all hold, by construction and by measurement.
- It sits in the harness scene at a believable scale next to the farmer, oak and beds.
- The 16 px course and 12 px plank rules give one consistent mark scale across the roof and walls.
- The extensions can stay separate layers.

**Cannot show:** final material quality. The tiled G1 texture repeats and carries c1's grain. In the c1 version, the roof is the noisiest surface in the scene, which breaks the texture hierarchy. The anchor_v2 version is calmer (0.14% orphans).

## 7. Limitations only PixelLab or an artist can resolve

1. **Material rendering.** Weathering, value variation across large planes, light falloff and non-repeating texture. M0 only tiles 32 px swatches.
2. **A true 16 px slate material.** c1's slate has ≈ 8 px courses, so the face texture inside each 16 px M0 course carries half-size internal banding.
3. **Hip shingles.** On the hips, courses are drawn horizontal. A convincing hip turns and foreshortens its courses along the hip line.
4. **Horizontal siding grain.** The walls use c1's vertical timber swatch rotated 90°. Its grain was not drawn for lap siding.
5. **Contact shadows and junctions.** Chimney flashing, the under-sill and door-frame shadow, the eave shadow falloff, and the meeting of foundation and ground. M0 has only flat strips.
6. **Edges.** One uniform ink outline everywhere. A finished look needs selective outlines (lighter and broken on lit edges).
7. **Dormer design (F3) and porch design (F2).** Both need new geometry, art and a production code change.
8. **Repair stages 0–2.** Not attempted. As ChatGPT noted, their silhouettes may change, so "decay by masked inpaint" is still a hypothesis.
9. **Night emissive.** The harness draws the night house under the night tint, so the glass is tinted too. A true unshaded emissive layer is a production lighting decision, outside this task.
10. **Composition.** The oak, ground and farmer are still placeholders, so whole-scene coherence cannot be judged yet.

## 8. Notes for any future paid test (not requested)

As ChatGPT corrected, a Pixflux img2img pilot and a Pro `edit_image` are different models. A Pixflux failure would not rule out a Pro edit. Editing the whole image is not assumed to preserve edges. Each paid step needs its own owner-approved generation limit and stop point. The blockout, label map and `anchors.json` from M0 are ready to serve as the protected masks and the measurement reference for such a test.

**Stopped** for ChatGPT's and the owner's visual review. Nothing has been committed or pushed.
