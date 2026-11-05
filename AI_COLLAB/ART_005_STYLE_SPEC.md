# ART-005 E0 — Proposed professional pixel-art style specification

Task: **ART-005, stage E0**. Owner: Claude Code. Reviewers: ChatGPT, then the owner.
Status: **PROPOSED. Not approved. Nothing here changes `DESIGN.md`, production art, the camera, the scale or the game.** PixelLab 0, SpriteCook 0, no AI generation.

Labels: **[Rule]** a proposed standard for every future asset; **[Measured]** computed in this repo; **[Proposal]** a number to be confirmed after the E2 artist test; **[Unverified]** general industry practice not checked here.

Files that go with this document (all in `art/style_tests/ART-005/`, which Godot does not import):

| File | What it is |
| --- | --- |
| `e0/palette.gpl`, `e0/palette.json`, `e0/palette.png` | The proposed master palette (52 colours in 16 ramps). `.gpl` loads into Aseprite, GIMP and Krita. |
| `e0/design_sheet.png` | The common design sheet: ramps, light model, outline and cluster rules, proportions, terrain rules, value budget. |
| `e0/layout.txt`, `e0/composition.png` | The small test composition shared by every density and by the artist test. |
| `e0/value_budget.json` | The measured day and night contrast of key colour pairs. |
| `tools/art005_e0.py` | Regenerates all of the above and the size-correct placeholders. |
| `tools/art005_check.py` | The proposed asset validator (section 11). |

---

## 1. Purpose

One rule set for every asset, every density and every hand, so that a farmhouse, an oak, a path and the farmer read as **one game drawn by one studio**. It answers ART-005's diagnosis: what holds the current art back is mixed authorship, uncontrolled clusters, separate palettes and little hand animation. Raw resolution is not the main problem.

It is written so that:

- **an artist** can follow it without reading the codebase;
- **I** can check it by script (section 11);
- it holds at **16, 32 and 64 art px per logical tile**. Every size and pattern is given in logical tiles. Line widths are given in art px.

The **16×16 logical gameplay grid stays** under every option. Density changes only how many art px a tile has.

Quality references (Eastward, Sea of Stars, Hyper Light Drifter and the like) are **benchmarks for discipline and finish**. Nothing is to be copied from them: no palette, character, layout, tile or motif.

## 2. Master palette and material ramps

**[Rule]** Every opaque pixel in a shipped sprite or tile comes from the master palette. Ramps run from dark to light. Shadows shift toward blue-violet and highlights toward warm yellow, so a ramp never just mixes toward black or white.

**[Measured]** The palette has 52 unique colours in 16 ramps. 37 come from the approved concept palette (`ART-003/src/concept_palette.png`, 32 colours). 15 are proposed additions (marked n), needed for roof, soil, skin, coat, path and water ramps that the concept palette did not cover.

| Ramp | Colours, dark → light (n = proposed addition) | Use |
| --- | --- | --- |
| ink | 1a1410, 241c22, 2a1f18 | outer outlines against light ground, deepest contact shadow |
| moss | 1e2a1c, 2e3f24, 43552c, 5e6e34, 7d8a3e, 9a9a4a | grass, ground cover, crop leaves |
| leaf | 6e1a16, 9c2a1e, c4402a, d0641c, f0a030, f6c45a | autumn oak crown, leaf litter |
| bark | 2a1f18, 3b2a1e, 5a3d26, 7a5434, 9a6d42 | trunks, roots |
| timber | 3b2a1e, 5c4128, 7e5a36, a07a4c, c8b89a | planks, fence, bed edging, door |
| soil | 241c22, 3a2a24 n, 4f3a2e n, 6a5040 n | tilled beds and fields |
| path | 4a4038 n, 6e6250 n, 8a867a, a8a088 n, c8b89a | packed earth, porch apron |
| stone | 2c3a44, 3a3a3a, 5e5c56, 8a867a, b4b0a2 n | foundation, steps, chimney, pebbles |
| shingle | 1e2230 n, 2c3a44, 46525a n, 66707a n | roof |
| skin | 5a3d26, 9a6d42, c88a62 n, e8b48a n | faces, hands |
| coat | 1e2a2c n, 2c3a44, 46606a n, 6a8a8a n | the farmer's coat and hat |
| accent | 6e1a16, 9c2a1e, c4402a | scarf, berries, small red accents |
| pumpkin | 8a3a12, b8561a, d97a22, f0a030 | pumpkins, gourds |
| lantern | 8a3a12, d97a22, f4b850, f6c45a, fff0c0 n | **emissive only**: lantern glass, lit windows |
| night | 241c22, 2c3a44, 5a3a6a, 8a86a8 n | cold accents, fog, night-only details |
| water | 1e2a3a n, 2c3a44, 3e5a64 n, 6a8a8a n, a8bcb4 n | window glass by day, water |

- **[Rule]** An asset uses at most **24 colours** (a character at most **20**), drawn from as few ramps as its materials need.
- **[Rule]** Day and night use the **same pixels**. Night comes from lighting: the production `NIGHT_TINT` multiply, lights and the grade. The only exception is emissive pixels. A lit window has its own night frame, drawn from the lantern ramp.
- **[Rule]** A new colour joins the palette only by the art lead's decision, recorded in `palette.json`. No asset brings private colours.
- **[Proposal]** The roof, coat and soil ramps are the least proven. The E2 artist may retune any ramp once, before production, with the change recorded.

## 3. Pixel clusters, outlines and anti-aliasing

| | Rule | Check |
| --- | --- | --- |
| **One pixel size** | Every sprite, tile, particle, light step and in-world UI lands on the same art-px grid. No scaled, rotated or resampled sprites in the world. | validator: `resampled = no`; harness: integer scale |
| **Clusters** | Texture marks are clusters of **≥ 2 art px**. Single pixels only for deliberate glints, eyes and hand anti-aliasing. Clusters are designed in tile units, so a 32 px leaf cluster is the same leaf, drawn with more pixels. Don't add more, smaller leaves. | validator: orphan pixels **≤ 0.5%** of opaque px [Proposal] |
| **Outline** | Selective, **1 art px** at every density. The outer silhouette uses the material's darkest ramp tone. Use ink only against light ground, and never pure black. The lit (top or left) edge goes one step lighter. Interior lines use ramp step 1–2, never ink. | validator: dark outline **≥ 85%** of silhouette texels for props and characters; terrain exempt [Proposal] |
| **Line quality** | Curves use even step runs (1-1, 2-2, 3-3, 2-1-2…). No "doubles" (L-shaped corners) on outlines. Straight architectural lines stay straight. | art-lead review |
| **Anti-aliasing** | Hand-placed, inside the silhouette, one intermediate ramp colour. Sprite alpha is **0 or 255**. Only light textures, fog and shadow layers use partial alpha. | validator: partial alpha **0%** on sprites |
| **Dithering** | Allowed only as a deliberate texture (stone, distant foliage). Never for gradients on characters. Light falloff dithering belongs to the engine. | art-lead review |
| **Noise** | No uncontrolled pixel noise. "Detail" means readable forms: planks, shingles, leaf masses, roots. | orphan check + review |

## 4. One light model

- **[Rule] Key light from the upper left**, about 45° in screen space and about 50° above the ground. One direction for every asset in the farm world.
- **Planes:** top and left-facing planes take +1 or +2 ramp steps. Right-facing and undersides take −1 or −2. A front (south-facing) wall sits at the ramp's middle tone, with a darker band under the eaves.
- **[Rule] Contact shadow:** one colour, **1e2230 at alpha 96**, drawn as **its own layer** under the object. It falls slightly below and right, about 1/16 tile. It is exported as a separate `*_shadow.png`, so the engine can tint or fade it for weather and night. Objects never bake their ground shadow into the sprite.
- **Cast shadows:** short, below-right, at most half the object's height. The game is mostly overcast autumn, so long sunny cast shadows are out of style.
- **Self-shadow and AO:** recesses (under eaves, crown undersides, between roots) take −1 step. No soft gradients.
- **Emissive:** lantern glass, window light and embers use the lantern ramp and are **never key-lit**. The engine supplies the glow.
- **Night:** the production tint `3a3f6e` multiplies the scene. Lights (lantern, windows, porch) add warm `ffd38a`. Assets are not repainted for night.

## 5. Material rendering

| Material | Rendering notes (apply at every density) |
| --- | --- |
| Grass | Three value clusters of moss 1–4, broken by tufts. Warm tips (moss 4–5) only on the lit side of tufts. No single-pixel speckle. |
| Path | Packed earth path 1–3, with pebble clusters (stone 3, lit top-left) and a 1-px path 0 shadow below-right. Wear thins toward the edges. |
| Soil | Furrows with a fixed period (1/3 tile). The lower quarter of each furrow is in shade. Wet soil is darker, done by tint, not new art. |
| Timber | Planks of a fixed height (≈ 3/8 tile). Seams use timber 1. Grain goes along the plank. Left corner posts are lit and right ones shaded. |
| Shingle | Staggered rows of 1/2 tile. The top texel of each row catches the light and the bottom texel is the row's shadow. The ridge is lit. |
| Stone | Blocky clusters with chipped corners. Lit top-left faces use stone 3–4 and the mortar stone 1. |
| Bark and roots | Vertical grooves. The left third is lit. Roots flare into the ground with a contact shadow. Moss accents go on the shaded side only. |
| Foliage (oak) | Leaf **masses** (about 1/3 tile clusters) shaded as volumes from the upper left. The rim breaks into scallops, not single leaves. The underside takes −1 step. Show sky gaps where the crown is thin. |
| Cloth | Big flat planes with one fold line per limb. The lit side is +1 step. Seams are not outlined in ink. |
| Skin | Two tones plus a highlight. No outline inside the face. Eyes are a 1-px dark cluster at 16 px. |
| Glass | Day: water 1 with a top-left glint (water 3–4). Night: lantern 3–4 with mullions. |

## 6. Proportions

**[Rule]** Sizes are in logical tiles and identical at every density. The art px figure is that size times the density.

| Object | Logical size (tiles) | 16 px | 32 px | 64 px | Notes |
| --- | --- | --- | --- | --- | --- |
| Farmer (frame) | 1 × 2 | 16×32 | 32×64 | 64×128 | Figure about 1.85 tiles tall including the hat. Head about 0.42 tile (≈ 4.4 heads tall). Feet on the bottom row. |
| Door (opening) | 1.2 × 2.3 | 19×37 | 38×74 | 77×147 | The farmer clears it by about 0.4 tile. |
| Window | 1.4 × 1.4 | 22×22 | 45×45 | 90×90 | Sill at about 1.4 tiles above the ground. |
| Fence | 1 × 1.25 | 16×20 | 32×40 | 64×80 | Rails at about 0.4 and 0.75 tile. |
| Crop | ≤ 1 × 1 | ≤ 16×16 | ≤ 32×32 | ≤ 64×64 | Ripe pumpkin about 0.6 tile wide. |
| Garden bed | 7 × 4 | 112×64 | 224×128 | 448×256 | Edging boards 1/4 tile. |
| Ancient oak (image) | 12 × 12 | 192×192 | 384×384 | 768×768 | Crown about 10 tiles wide, trunk about 1.4 tiles. |
| Farmhouse (restored) | 12 × 10 | 192×160 | 384×320 | 768×640 | From `DESIGN.md`. Eaves at about 5 tiles. |

Character style: grounded, slightly stylised (not chibi). At 16 px the silhouette carries the read. At 32 px a face, a hand and clothing folds become readable. At 64 px the art approaches illustrated sprites (ART-005 §4).

## 7. Terrain kits, transitions and variation

- **[Rule] Dual grid:** one 16-piece set per material laid over grass (path, soil, water, fallow), as the production `DUAL_FRAME_BY_MASK` already uses. Pieces are 1 tile.
- **[Rule] Organic edges:** a boundary wanders about ±0.2 tile and is never straight for more than one tile. The lower material gets a **1/16-tile shade lip** where grass overhangs it (light from upper left). The grass edge itself gets warm blade tips.
- **[Rule] Variation:** at least **3 fill variants** per material, picked by tile hash, plus mirrored variants where the lighting allows (vertical mirroring breaks the light direction, so only horizontal mirroring is allowed for lit textures).
- **[Rule] Decals** (pebbles, leaf litter, ruts, tufts, puddles) break repetition. No distinctive feature repeats within 3 tiles in view. Decals sit on the same art-px grid and palette.
- **[Rule] Large areas:** at 64 px, ground is built in chunks of at most 4096 px a side (Compatibility renderer limit [Unverified for every GPU]).

## 8. Animation standards

| | 16 px | 32 px | 64 px |
| --- | --- | --- | --- |
| Walk cycle per direction | 6–8 frames | 8 frames | 8–12 frames |
| Idle | 4 frames (breathing, lantern sway) | 4–6 | 6–8 |
| Directions | down, up, right (left mirrored only if the design is symmetric) | same | same |
| Playback | walk 10–12 fps, idle 4–6 fps; ambient loops 6–8 fps | same | same |

- **[Rule]** No foot sliding: the stride matches the movement speed (3.75 tiles/s in play).
- **[Rule]** Keyframes first (contact, passing), then in-betweens. Anticipation and follow-through on tool swings. **Secondary motion** (the lantern lags the hand by 1–2 frames, the coat hem, the hat) is drawn, not added by the engine.
- **[Rule]** Volumes stay consistent. Every frame sits on the art grid, so outlines don't shimmer. No sub-pixel sprite rotation.
- **[Rule]** Environment loops (leaf sway, chimney smoke, grass in the wind, crows) are drawn on the same art grid and loop without a visible pop.
- Generated animation (PixelLab, SpriteCook) may be used as **timing reference only**.

## 9. Day/night readability and contrast

**[Measured]** CIELAB lightness difference (ΔL*) between key colour pairs, by day, and under the production night tint with no lamp (`e0/value_budget.json`):

| Pair | ΔL* day | ΔL* night (no lamp) |
| --- | --- | --- |
| farmer coat mid (coat 2) on grass (moss 2) | 5.4 | 2.5 |
| farmer coat lit (coat 3) on grass | 21.4 | 7.4 |
| farmer outline (coat 0) on path (path 2) | 39.9 | 10.7 |
| path (path 2) next to grass | 22.2 | 7.3 |
| tilled soil (soil 2) next to grass | 7.3 | 1.7 |
| timber wall (timber 2) on grass | 7.5 | 1.9 |
| pumpkin (pumpkin 2) on soil | 34.2 | 8.9 |
| oak crown mid (leaf 3) on grass | 21.0 | 5.3 |

**[Proposal] Value budget:**

- By day, a character's or interactable's silhouette (its outline plus its lit side) differs from the ground behind it by **ΔL* ≥ 15**. Its mid-tone alone may not.
- Under the night tint with no lamp, the farmer's and the path's silhouettes keep **ΔL* ≥ 6**. Inside a lantern pool, gameplay-relevant edges keep **ΔL* ≥ 12**.
- **What the measurement shows:** the coat's mid-tone almost matches the grass (5.4 by day, 2.5 at night). With this palette, the farmer reads through the outline and the lit side, so those are mandatory on characters. Soil next to grass (1.7 at night) and the timber wall on grass (1.9) vanish at night without the shade lip, the foundation stones and the window light. **The E2 artist should design for this budget, not around it.**
- These are measured on palette pairs. The harness can measure the same values on rendered frames once real art exists (E3).

## 10. Art-source workflow (editable, layered)

**[Rule] Source files are kept, not only flattened PNGs.**

- **Tool:** Aseprite (`.aseprite`), the de-facto standard for layered and animated pixel art [Unverified for the artist's preference; any layered format with a CLI export is acceptable].
- **Colour mode:** indexed, with the master palette loaded from `palette.gpl` and locked.
- **Layers, top to bottom:** `fx_emissive` (lantern-ramp pixels, exported separately where useful), `highlight`, `shade`, `flat` (base colours), `line` (outline), `shadow` (contact shadow, exported as `*_shadow.png`), `ref` (hidden design reference, never exported).
- **Animation:** one file per character per action. Aseprite tags `walk_down`, `walk_up`, `walk_right`, `idle_*`. Frame durations are set in the file.
- **Kits:** one file per kit (terrain material, building kit, foliage kit), with slices naming each piece (`path_00` … `path_15`).
- **Folders:** `art/source/<section>/<asset>.aseprite` → exports to `art/farm/`, `art/player/` and so on. At 32/64 px, sources may need **Git LFS** [Proposal; size measured in E2].
- **Naming:** `<asset>[_<variant>][_<state>].png`, e.g. `house_restored_night.png`, `crop_pumpkin.png`. A strip's frame count and size go in the export JSON, not the name.
- **Pivots:** a sprite's bottom-centre is its sort base (as in the harness). Characters stand with their feet on the bottom row.

## 11. Technical export and validation

1. **Export** by script, never by hand:
   `aseprite -b src.aseprite --layer "line" --layer "flat" --layer "shade" --layer "highlight" --layer "fx_emissive" --sheet out.png --data out.json --format json-array --sheet-type horizontal --list-tags`
   and a second pass with `--layer shadow` for `*_shadow.png`. [Proposal; the CLI flags are standard Aseprite batch flags, to be confirmed on the artist's version.]
2. **Validate** with `tools/art005_check.py --density D <files>`. It measures, per image:

| Check | Proposed pass | Why |
| --- | --- | --- |
| In palette (exact) | 100% of opaque px | T3: one palette |
| Colours per asset | ≤ 24 (characters ≤ 20) | control |
| Partial alpha | 0% (shadows, lights, fog exempt) | crisp edges at any scale |
| Orphan pixels | ≤ 0.5% | cluster discipline |
| Resampled | no | no mixels |
| Dark outline | ≥ 85% of silhouette (props, characters) | readable silhouettes |
| Half-tile grid | width and height multiples of D/2 | grid alignment |

3. **Import into Godot:** lossless, no mipmaps, nearest filter (the project already sets `default_texture_filter = 0`).
4. **Review:** in the harness first (`tools/art005_density.gd`), on the matched composition, day and night, still and moving. Then against the design sheet, never against the previous round only.

**[Measured] Baseline:** the same checker on the current art. This measures conformance to a palette that the current art was never made for, so it describes the gap and doesn't grade the art.

| Asset (16 px) | Colours | In palette (exact / ΔE ≤ 3) | Orphan px | Dark outline |
| --- | --- | --- | --- | --- |
| W-3p house (wall a, day) | 58 | 38% / 43% | 6.7% | 100% |
| W-3 oak | 45 | 45% / 45% | 20.6% | 95% |
| W-3b garden bed | 38 | 45% / 88% | 10.6% | 9% |
| production `house_stage_3` | 5,564 | 0% / 33% | 82.4% | 100% |
| production `ground_grass` | 602 | 0% / 0% | 71.2% | 70% |
| production `farmer_walk_right` | 18 | 0% / 5% | 4.7% | 99% |
| ART-005 placeholders, all densities | 1–16 | 100% / 100% | 0.0–0.25% | 69–100% |

The placeholders pass because a formula drew them to these rules. **That says nothing about their artistic quality.** They are engineering stand-ins (see the E1 report).

## 12. Common design sheet and test composition

- `e0/design_sheet.png` puts sections 2–9 on one page, for the artist and for review.
- `e0/composition.png` and `e0/layout.txt` define the **test composition**. It is a 30 × 17-tile vignette inside a 50 × 25-tile map (so the camera can pan): the restored farmhouse, the ancient oak with leaf litter, a lane with grass→path transitions and a porch apron, a tilled field (grass→soil), two 7 × 4 garden beds with two crops at two stages, a fence with a gate, and the farmer with a lantern. The walk route runs east along the lane, then diagonally. Every density and the future A+ column use this file.
- The ART-005 document named "four beds". The existing 16 px bed art is 7 × 4 tiles, so **two beds** fit the 30-tile vignette. The artist test (E2) uses one bed section.

## 13. Open points for the owner

1. Approve this specification as the **working standard for E2**. It stays a proposal, outside `DESIGN.md`, until the owner adopts it.
2. Confirm the 15 proposed palette additions, or let the E2 artist retune them once.
3. Confirm the value budget (section 9) as the night-readability gate.
4. Confirm Aseprite (or name another layered tool) and whether sources may use Git LFS.
