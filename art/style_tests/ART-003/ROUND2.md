# ART-003 Round 2: concept fidelity

Status: for ChatGPT's image-level review and the owner's decision. Non-production: the live layout, saves, collisions, movement, gameplay darkness and production art are unchanged. Production approval isn't being requested yet.

This round answers ChatGPT's Round 1 review (MESSAGE_BOARD.md, 2026-11-02). It uses the same 30×18-tile slice, camera and player spot as Round 1. `tools/art003_round2.gd` extends `tools/art003_slice.gd`, so Round 1 still renders exactly as before.

## 1. Night atmosphere (night preview)

- The preview runs only in the slice tool. A node that runs after the game each frame sets the sky tint to `7382ae` (the game's is `3a3f6e`) and softens the grade: saturation 0.62, exposure 0.96, contrast 1.04, shadow_cool 0.08, vignette 0.75, warmth 0.05.
- The game's `darkness` value, which drives sanity, lamps and the night events, is untouched, as are the clock and every trigger. Lantern posts and the player's lantern stay Godot `PointLight2D`s.
- The forest interior is darkened by a shade layer at the slice's edges (55% at night, 32% by day). A thin cool haze sits over the far rows.
- **Measured** at 1280×720 (mean luma; share of pixels above luma 0.12):

  | Render | Mean luma | Pixels above 0.12 |
  | --- | --- | --- |
  | Concept 03 crop | 0.200 | 69% |
  | Round 1 night | 0.030 | 5% |
  | Round 2 art, game night | 0.030 | 4% |
  | Round 2 night preview | 0.114 | 31% |

  Forest-edge columns in the preview average 0.058, so they stay dark.
- A first try (`8796bd`, exposure 0.96) read almost as day, and a second (`5d6b98`, exposure 0.92) measured 0.088. The current values sit between, a little darker than the concept, which is lit by many more lights than the slice has.
- **To adopt it:** the change belongs in `_sky_tint()` / `NIGHT_TINT` and the night grade in `main.gd`. That needs owner approval, and a check of sanity's low-light gloom and the trek's own tint, which build on the same values.

## 2. Ancient oak

- **Oak A (used):** `r2/oak_a.png`, 192×144 (12×9 tiles). PixelLab img2img from a downscaled crop of the concept's oak, strength 220, with the shared palette. It has a sprawling, asymmetric silhouette, thick gnarled horizontal branches with gaps between the leaf clumps, a twisted trunk, a mass of exposed roots and a hanging skull charm.
  - **Weaknesses:** the canopy is clipped flat by the top edge of the canvas. There's no red shelf fungus, and only one charm.
- **Oak B (alternative):** text only. Bare and sculptural, but too leafless for the concept.
- **Stone ring:** `r2/stone_ring.png`, 160×64, drawn flat under the oak. It's too regular, like a henge, and its centre is a baked grass disc. It needs irregular boulders and moss.
- **Fix next:** regenerate oak A on a taller canvas so the crown isn't clipped. Add fungus and two or three more charms. Swap the ring for scattered, irregular mossy boulders.

## 3. Ground and garden

- **Leaf litter:** organic drifts from a chained leaf-litter Wang tileset (`r2/litter_tileset`), placed by noise. They're kept sparse because the leaves are much brighter than the grass.
- **Decals:** small leaves, twigs, acorns and a mushroom cut out of one decal sheet (`r2/decals.png`) and scattered by hash. More sit along the path's edges than on open ground.
- **Cobbles:** a cobbled landing by the garden gate (`r2/cobble_tileset`).
- **Garden:** two raised beds with plank edging (`r2/garden_bed.png`), planted in rows along the furrows. There's one crop per row, and all six crops (`r2/crops.png`: green and purple cabbage, kale, carrot, beetroot, pumpkin) are used across the two beds. The beds sit on grass, not a dark rectangle.
- **Still weak:**
  - The grass base tile still repeats its leaf speck.
  - The path edge is still the Round 1 blocky Wang edge, and the cobbles meet the path with a grass seam.
  - The beds are crowded and the second one is mostly off-screen.
  - Rows of identical plants still read as tokens.
  - There's no trellis, corn or bed paths between the beds.

## 4. Depth

- **Far:** two staggered rows of firs along the top, tinted cooler and dimmer, under a thin haze.
- **Middle:** side edges with maples, undergrowth and rocks.
- **Near:** three trees standing just below the frame, their crowns over the bottom edge.
- **Shade:** the shade layer deepens the forest's interior.
- **Readability:** the path stays clear and the player stays visible.
- **Missing:** fallen logs, roots crossing the ground, and ferns as separate plants.

## Budget and assets

8 PixelLab generations: two oaks, the stone ring, the litter and cobble tilesets, decals, garden bed and crops. That used the last of the trial's 40. IDs are in `r2/pixellab-assets.json`. More art needs a PixelLab plan or SpriteCook signed in again.
