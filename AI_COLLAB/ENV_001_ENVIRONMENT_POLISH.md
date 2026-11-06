# ENV-001: whole-farm environment polish study

**Status:** one bounded, zero-generation, NON-PRODUCTION prototype study, done under the owner's ENV-001 authorization (board commit `3afa0d6`). It is for the owner's and ChatGPT's image-level review. It proposes. It does not decide. Nothing here is integrated into the game.

**Not touched:**
- the farmhouse pixels (VS16-P1, VS16 and C2 are byte-identical);
- ART-003, ART-005, HC1/HC2, VIS-002, `DESIGN.md`;
- production art, lighting, shaders, the night (R3-1), the camera and scale;
- collision, path, gate, road and field geometry, the four restoration conditions, purchase IDs, saves.

No PixelLab or SpriteCook calls were made and nothing was bought. The orchard crowns, the dock and the gate were not started.

## Approach

Each study is a separate, reversible switch in a dedicated harness, `tools/env001_scene.gd`. It extends VS16-P1's harness: W-4 layout b, F2 fields, the P1 cabin, and the game's own camera, grade and R3-1 night. Every switch repaints this run's ground image and nothing else. The layout map, the collision check and every sprite are the same as the control's.

| Switch | What it does |
|---|---|
| `terrain` (T) | Redraws the ground from a hand-composed 16 px tile family on the **same material map**, so every path, bank, field edge and the pond keep their exact tiles. |
| `shadows` (S) | Authored contact shadows under a representative set of objects, darkening the ground in its own colours. |
| `day` (D) | A noon value and colour key on the ground only. It is strongest in the clearing and fades to nothing inside the forest, so the forest edge frames a lit homestead. |
| `all` | T + S + D. `daynight` forces D at night, for the regression check. |

## Prototype assets (all new, all under `art/style_tests/ENV-001/`)

| Piece | Files | Made by |
|---|---|---|
| **Grass family:** G0/G1 calm fills; G2 blade clumps; G3 autumn (forest edge) | `terrain/grass.png` (4 × 16 px) | `tools/env001_art.py`: each tuft, patch and leaf placed at hand-chosen coordinates |
| **Dirt:** shaded base and worn centre | `terrain/dirt.png` | the same |
| **Grass/path dual-grid set:** 16 corner keys × 2 verge variants | `terrain/path_wang.png` | A smooth corner field plus a periodic wobble, so every tile meets its neighbours exactly. The verge rules: the turf's front face and its shadow on the path where grass lies north or west, a lit lip where it lies south or east, an occasional blade over the edge, and a worn centre 4 px in. |
| **Accents** (replace the old white tufts and large leaf decals) | `terrain/accents.png`: green clump, dry clump (straw, not white), clover, pebbles, two leaves, mushrooms | hand pixel maps |
| **Palette** (25 colours, matched to the control's grass and path) | `terrain/palette.png` | |
| **Contact shadows** | `shadows/{cabin,oak,well,apple_b,logpile_flip}.png`, `shadows.json` | authored per object from its silhouette; the fence's is projected in the harness |
| Harness, run script, sheets | `tools/env001_scene.gd`, `tools/env001_run.sh`, `tools/env001_review.py` | |

**Accent placement by zone:**
- **Calm zones** (no accents; G0/G1 only): the cabin front, porch, well and crossroads (x 33–55, y 11–18); round the fields (x 41–61, y 17–31); the road (y 33–35).
- **Verges:** in grouped runs with gaps.
- **Forest edge:** more accents, plus G2/G3.

**Kept from the control:** the leaf-litter drifts under the oak and at the forest and orchard edges, the worn stone round the well, the pond's PixelLab banks and water, and the road ruts. When these overlays are applied, only their leaf, stone or bank pixels are taken, so the old speckled grass does not come back with them.

**Shadow convention:**
- The key light is upper left, as on the cabin's chimney and eaves, so shadows fall down and to the right.
- There are two steps:
  - **Contact:** where the object meets the ground. It is kept at night, weaker, as occlusion.
  - **Cast:** the sun's shadow, by day only.
- Each step darkens the ground's own pixels with a cool multiply, so the texture shows through. It is not an alpha blob.
- The objects:
  - **Cabin:** contact under the footing and steps, a cast band below them, and a wedge east of the east wall.
  - **Oak:** a dappled, lobed pool right of the trunk, with contact under the trunk and roots.
  - **Well:** contact under the ring and an oval cast.
  - **One orchard tree** (apple_b at 9,19): a small dappled pool.
  - **Log pile** at 35.5,15: contact and a short wedge.
  - **The fields' east-west fence runs:** each rail pixel h rows up falls h/2 right and h/4 down, with contact under the posts.

**Noon key (D), per material:**
- **Grass:** lighter (+22% at full strength, mid and high values more than darks, so blade shadows stay) and about 4° warmer.
- **Paths:** a lighter warm ochre (+20%).
- **Leaves:** +10%.
- **Stone:** +14%.
- **Not changed:** water, all standing sprites, the cabin, the oak, the fields, the farmer and the grade.

## Evidence (`art/style_tests/ENV-001/review/`)

| Master | Contents | Scale |
|---|---|---|
| `ENV-001_master.png` | Source art at 1:1 and ×3: the grass family, dirt, the 32-tile dual-grid set, accents, palette, a sample patch, and the shadow masks over their sprites | 96% |
| `ENV-001_master_2.png` | View 1: cabin, oak, well and farmer, at real 720p noon. Control, T, S, D and combined, plus value maps (7 luma bands) and ×2 centre crops. | 70% |
| `ENV-001_master_3.png` | View 2: the F2 fields and adjacent paths (same layout) | 70% |
| `ENV-001_master_4.png` | View 3: orchard, pond and dock, with quiet lawn against the forest edge | 70% |
| `ENV-001_master_5.png` | View 4: the road, the closed gate and the southern boundary | 70% |
| `ENV-001_master_6.png` | Night regression at R3-1 21:30, 1:1 centre crops of all four views: control, T+S, and T+S+D forced | 79% |
| `ENV-001_master_7.png` | Whole W-4 homestead, a stitched 3×3 of real 720p frames, **DOWNSCALED 1/3**: noon control vs combined, night control vs T+S | 80% |

- **Held constant:** every row uses the same camera, farmer spot, hour and 3× scale. Only the switches differ.
- **Grain:** the grade's film grain is time-seeded, so any two runs differ slightly outside what changed.
- **Not shown:** no pan was rendered. The ground is static art on the same 16 px grid, so the new tiles add no sub-pixel motion.
- **Measurements** are in `measure.json`:
  - **mean luma** (whole frame);
  - **"busy":** the share of pixels with a strong edge to a neighbour, a texture-frequency proxy.

  They support what is visible. **They are not proof of quality.**

| View | Noon luma, ctrl → T+S+D | Busy, ctrl → T+S+D | Night luma, ctrl → T+S → T+S+D forced |
|---|---|---|---|
| Home | 51.7 → 58.2 | 0.203 → 0.161 | 35.0 → 36.1 → 40.9 |
| Fields | 46.8 → 55.1 | 0.139 → 0.127 | 28.7 → 30.5 → 35.1 |
| Orchard/pond | 45.3 → 55.5 | 0.156 → 0.102 | 25.5 → 26.7 → 32.5 |
| Gate/road | 33.4 → 39.6 | 0.129 → 0.117 | 16.8 → 17.8 → 21.3 |

**Iterations (one draft, one substantive revision, then stopped):**

The draft's self-review found four problems:
1. The path outlines were stair-stepped.
2. The lawn had gone flat and empty.
3. D greyed the grass and made the paths pale.
4. T lifted the night (orchard night luma 28.1 against the control's 25.5) and lost some of its dark texture.

The revision made four changes:
1. A wider, smoothstepped blend band and a larger multi-harmonic wobble, for rounder path outlines.
2. Darker shadow clusters in every grass tile, and a slightly darker base.
3. More G2/G3 tiles and accents on open lawn.
4. In D, no desaturation, and a smaller lift on paths.

Afterwards, the orchard night was 26.7 against the control's 25.5, and the combined home noon luma went from 61.0 (draft) to 58.2. The draft frames are kept in the export, at `builds/review/ENV-001/draft/` (gitignored).

## Gameplay-scale scorecard (Claude's, observed at 720p)

| Criterion | Control | T+S+D | Note |
|---|---|---|---|
| Pixel cohesion | Fair: the PixelLab grass has a regular orange speck grid and high-contrast white tufts | **Better** | One palette and one 16 px vocabulary for ground, verges and accents |
| Path and character readability | Weak: paths and grass close in value, fuzzy edges | **Clearly better** | Paths read as walkable lanes. The farmer separates from a calmer ground. |
| Focal hierarchy | The ground competes with the cabin and oak | **Better** | Calm zones round the cabin, well and fields; the oak's shadow pool anchors it |
| Daytime warmth | Dark, low-key noon | **Better, still autumnal** | Warmer green-gold lawn, ochre paths; the forest stays deep |
| Night legibility (R3-1) | Baseline | **About the same with T+S**; worse with D forced | See the D verdict |
| Ecological texture | Rich but noisy | **Reduced** | Kept toward the forest edge. Open lawn is plainer than the control by design. |

## Go / no-go per study

- **T: terrain, GO as the direction** for a production terrain set, with these caveats:
  - **Clear gains:** calmer, clearer paths; the white-tuft and speck noise is gone.
  - **Path outlines:** still follow the tile grid (rounded but stepped corners, most visible in the orchard and gate views). Paths drawn on rectangular route tiles can only be re-skinned so far. A production set needs hand-drawn junction and corner pieces, a few extra Wang variants, or both.
  - **Open lawn:** now plainer than the control. That is intended in the calm zones, but some may find it slightly bare.
  - **At night:** about +1 to +1.8 luma over the control; the darkness and threat read is kept.
- **S: contact shadows, GO for trees and props; NEUTRAL for the cabin and fence.**
  - **Oak:** the pool is the strongest single grounding gain in the study, and the well and log pile seat clearly.
  - **Cabin:** the band is mostly hidden by its own foundation and steps (as in VS16). Only the east wedge reads.
  - **Fence:** the projected shadow is faint at 720p.
  - **At night:** only the weak contact step remains, as intended.
- **D: the noon key, GO as a daytime look; NO-GO as baked albedo.**
  - **By day:** it gives the "more inviting" noon and the value separation the brief asks for.
  - **Baked into the ground:** it lifts R3-1 by 4 to 7 luma (third column of master 6), which flattens the night.
  - **So in production it would belong to the time-of-day lighting, not the tiles.** That touches production lighting, which needs its own explicit authorization. Its value with T alone is visible in the T and combined frames.

## Limitations

- The studies repaint only the ground image, as an overlay in this harness. They are not integrated, and they are not proof of in-game performance.
- The pond banks, litter drifts and worn stone are still the PixelLab art, filtered so their grass doesn't return. A production pass would redraw them in this palette.
- The new terrain was judged at 720p only. Not checked at 1080p or in weather (rain, fog, snow, other seasons).
- The fields' sprites, the forest, orchard crowns, props and the farmer were not restyled, so their outlines and ramps still come from the earlier art.
- The F2 field soil is now the darkest ground. That helps separation, but it is worth confirming in review.

## Roadmap for later, separately approved work (not implemented)

1. **Orchard trees:** redraw the apple and pear crowns as clustered 16 px masses consistent with the golden oak's light (upper-left key), with a trunk shadow following this study's S convention and windfalls in the G3 palette.
2. **Wooden dock:** planks with lit top edges and dark gaps, posts meeting the water with a contact ring and a short reflection, and a shadow under the deck on the water.
3. **Closed entrance gate:** a recognizable plank gate with a cross brace, capped posts and a latch. Give it a contact and cast shadow across the road (replacing the current flat shadow line) and a clear road-to-gate verge, so the closed state reads at 720p.
4. **If T is approved for production:**
   - hand-drawn path junction and corner pieces, and pond-bank and litter tiles in this palette;
   - D moved into the daytime lighting key (needs lighting authorization);
   - S extended per prop as authored pixels.
