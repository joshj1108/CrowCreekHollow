# ART-005 E2-PL — limited PixelLab proof-of-quality test: results

Task: **ART-005 E2-PL, P0–P2 only**, run under the owner's authorization of 2026-11-04 (cap 30 subscription generations, USD 0). Owner: Claude Code. Reviewers: ChatGPT, then the owner.
Status: **stopped for visual review.** No oak, tileset or animation. `DESIGN.md`, production art, gameplay, saves, camera, night lighting, E0/E1 outputs, W-4 and VIS-002 are untouched. Everything is in `art/style_tests/ART-005/pl/` (Godot ignores it).

Labels: **[Measured]** checked here; **[Observed]** seen in captures; **[Judgement]** my artistic opinion, to be checked by the owner and ChatGPT.

## 1. Spend

| Step | Tool | Charged |
| --- | --- | --- |
| P0 | balance, price quotes (`get_pro_flash_capabilities`), upload, workbench lint/repair | 0 |
| P1 | `create_image_pro` 96×96, 4 candidates, seed 5001, 52-colour palette forced, no references | 10 |
| P2 | `create_image_pro_flash` 160×192, style image = board c1, palette forced, seed 5101 | 6 |
| P2 repair | `inpaint_image_pro_flash`, rectangle mask on the right strip, seed 5102 | 6 |
| | **Total** | **22 of 30** |

Balance [Measured]: 4,960 → **4,938** plan generations; credits USD 0 before and after. 8 generations of the allowance are left unspent; nothing else was bought or used. Every prompt, seed, setting and job/asset id is in `pl/pixellab-assets.json`. Each charge was quoted before it was submitted, and each matched its receipt.

## 2. What was made

- **P1 style board.** Four 96×96 candidates (`pl/anchors/board_c0..3.png`). **c1 selected**: the most coherent weathered set (mossy slate, cracked timber, chipped stone, four-pane window). The free workbench `repair` changed nothing (score 81.1 → 81.1), so the board is used as generated. Its weaknesses: the "grass" swatch came out as straw rather than the game's moss green, and the coat swatch is dithered.
- **P2 farmhouse corner, 160×192** (5 × 6 tiles at 32 px): roof eave, fascia beam, clapboard wall with a lit corner post, four-pane window with sill, fieldstone foundation, porch post, deck and step.
  - `house_section_original.png`: the unedited output.
  - Two real defects were found: a **transparent hole** between the wall and the porch post, and a **porch deck drawn on an isometric-style diagonal**. One masked inpaint fixed both; **0 pixels outside the mask changed** [Measured].
  - Free cleanup by script (`tools/art005_pl_cleanup.py`):
    - 2,661 inpainted pixels snapped back onto the palette (inpaint takes no forced palette).
    - The seam the inpaint left was fixed by cloning the adjacent wall columns. A first attempt that remapped values made the seam worse and was replaced.
    - The night window was made by mapping the glass to the lantern ramp.
    - In total, 3,405 of 25,883 opaque pixels (13%) differ from the inpaint output. Diff: `cleanup_diff.png`; mask: `inpaint1_mask.png`.
  - `pseudo_layers/`: **reconstructed pseudo-layers**, a value and edge split of the flattened PNG by script. They are **not** artist-authored editable layers and do not separate materials. PixelLab returns one flattened PNG per call.

## 3. Objective checks [Measured, `tools/art005_check.py`]

| File | Colours | In palette | Partial α | Resampled | Orphan px | Dark outline |
| --- | --- | --- | --- | --- | --- | --- |
| board c1 | 38 | 100% | 0% | no | 4.8% (warning) | 78% (warning) |
| section original | 18 | 100% | 0% | no | 10.9% (warning) | 93% |
| section cleaned day / night | 21 / 25 | 100% | 0% | no | 10.3% (warning) | 91% |

The hard checks pass: palette validity, no resampling, and the technical format. As the owner asked, the orphan, colour-count and outline figures are **warnings**. Here, though, the orphan figure does match what I see (§5).

Proportions, measured by eye on a ×4 crop (±2 px):

| Feature | Measured | Spec |
| --- | --- | --- |
| Window | ≈ 43×41 px | 45 ✓ |
| Plank height | ≈ 12 px | ✓ |
| Window sill above ground | **≈ 66 px (2.1 tiles)** | 1.4 tiles |
| Eave above ground | **≈ 4.0 tiles** | ≈ 5 |

The model did not follow the pixel numbers in the prompt.

## 4. In the E1 harness [Observed]

`tools/art005_density.gd` has a new **additive** option, `art=pl`. It loads `pl/<D>/<name>.png` where one exists and uses the placeholders everywhere else. The default output is **pixel-identical** to the committed E1 stills [Measured: 1080p day and night, and native].

For the test, the cleaned section is pasted onto the placeholder house's front-left corner (`pl/32/house_day.png`, `house_night.png`). Captures: 32 px, `framing=int`, smooth camera, grain off, day 12:00 and night 21:30 (production `NIGHT_TINT`, lantern and window lights, frozen grade), at 1080p (×2, 1:1 crops) and 720p (×1, whole frame).

- **Day:** at gameplay size, the materials read at once and the eave and porch show real depth. The fine grain turns into **grit/noise at ×2**. That is the clearest gap against premium work.
- **Night:** the grain disappears under the tint. The lit window carries the corner, and the wall keeps its plank structure.
- **The paste is crude, and that comes from the composite, not the art.** Because of the proportion drift, the section's eave sits about 1 tile below the placeholder's eave, and its porch post overlaps the placeholder door. The window light is positioned for the placeholder window, not the new one.

## 5. Artistic assessment [Judgement]

| Criterion | Assessment |
| --- | --- |
| Pixel-cluster craft | **Mixed.** The large forms are well built: shingle rows, rounded stones, planks, window. The surface texture is single-pixel grain everywhere: wood, stone and slate are speckled, not drawn as deliberate clusters. |
| Outlines and material shading | Consistent. The selective dark outline holds, the light comes from the upper left on the posts, shingles and stones, and the volumes are rounded. The wall is a flat mid-tone with little designed light structure beyond the beam's shadow. |
| Perspective and proportions | Straight-on after one repair; the first output had an iso-style deck. The window and planks are correct, but the sill and eave heights drifted. |
| Architectural depth | **The strongest point.** Eave overhang, beam, posts standing proud of the wall, foundation projection, porch step. |
| Distinct materials | Strong: slate, timber, stone and glass separate clearly, by day and by night. |
| Palette coherence | Good. The forced palette held 100% on creation; the inpaint drifted and was snapped back for free. |
| At gameplay size | Reads well and is far richer than the placeholder. The grain reads as noise next to clean surfaces. |
| Premium commercial standard | **Not yet.** It is competent: an upper-mid asset-pack level, a clear step up from ART-003's standalone sprites. It is not at the finish of the benchmark games: the texture marks aren't designed, and the wall has no value composition. |

**Success criterion.** The run was style-controlled and needed no repeated regeneration: one create and one targeted repair, with nothing re-rolled. That half is shown. Whether the asset is "convincingly professional" is, in my judgement, **only partly met**.

**Where the grain comes from.** The selected board already has the same speckled texture (4.8% orphans), and the house copied it, together with the detail and shading traits. **The anchor's finish is the main lever.** A noisy anchor gives a noisy family.

## 6. Recommendation: revise, don't abandon

**Reasons to continue**

- The structure is reliable and controllable.
- Masked repair works exactly: 0 pixels changed outside the mask.
- The palette lock works.
- One corner cost 12 generations, plus 10 for a reusable board.
- The material read and the architectural depth at 32 px are already better than any earlier AI round.

**Reasons to revise before spending more**

- The texture finish is below the bar.
- The proportion targets aren't followed from the prompt.
- The style trait transfers the anchor's flaws as faithfully as its strengths.

**Reasons to abandon PixelLab-first**

- If the owner judges the base output's grain and value design to need a full repaint to reach the bar, the tool only saves the layout work. The artist or hybrid route (plan §7, X1/X6) is then the better choice.

**A proposed next step, not authorized.** Any of these needs the owner's approval:

1. **A free hand-finish pass** on this same corner: consolidate the grain into clusters, design the wall's value structure, and correct the sill and eave heights. Log the minutes and the share of pixels changed (the A7/X3 measure), to see whether finishing is cheap or amounts to a repaint. Cost: 0 generations.
2. If that lifts the corner to the bar, **re-make the anchor from the hand-finished corner and board**, and test whether new pieces inherit the cleaner finish. About 10–20 generations, with a new cap set by the owner.
3. If it doesn't, the **hybrid route**: an artist makes the anchor only (plan §7 X1).

## 7. Files

- **Anchors:** `pl/anchors/board_c0..3.png` (c1 selected).
- **House:** `pl/house/house_section_original.png`, `_inpaint1.png`, `_clean_day.png`, `_clean_night.png`, `inpaint1_mask.png`, `cleanup_diff.png`, `pseudo_layers/` (reconstructed).
- **Harness inputs:** `pl/32/house_day.png`, `house_night.png`.
- **Receipts:** `pl/pixellab-assets.json`.
- **Scripts:** `tools/art005_pl_cleanup.py`; `tools/art005_density.gd` (`art=pl`).
- **Review:**
  - `pl/review/ART-005E2PL_master.png` (the section and the 1080p harness, sheets at 60%).
  - `pl/review/ART-005E2PL_master_2.png` (the board, the 720p whole frame and the pseudo-layers, sheets at 62%).
  - The individual sheets: `p1_style_board.png`, `p2_farmhouse_section.png`, `p2_pseudo_layers.png`, `harness_1080p_1to1.png`, `harness_720p_fullframe.png`.
- **Raw captures:** in `builds/review/ART-005/pl/` (gitignored). Reproduce with `godot --path . -s tools/art005_density.gd -- density=32 art=pl hour=12|21.5 task=stills framing=int res=1920x1080,1280x720 out=builds/review/ART-005/pl/pl`.
- **Licence:** PixelLab's commercial-use terms were **not** checked in this task. The owner should verify them before any production use.
