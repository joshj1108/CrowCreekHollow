# ART-003: Vertical slice findings

Status: for owner and ChatGPT review. This is a non-production prototype: no live layout, production art, `DESIGN.md` or gameplay changed.

## What was built

- **One asset family** in `src/`, generated with PixelLab. Every prop uses `create_image_pixflux` with the same settings: low top-down view, selective outline, detailed shading, high detail, and the same forced palette (`src/concept_palette.png`, 32 colours hand-picked from the concept art).
  - **Ancient oak:** 160×160, 10×10 tiles.
  - **Trees:** Douglas fir 48×96, vine maple 64×80.
  - **Ground props:** undergrowth clump 48×32, mossy rock cluster 48×32.
  - **Garden and lights:** split-rail fence 64×32, lantern post 32×48, pumpkin and cabbage rows 48×32.
  - **Ground:** two chained 16 px Wang tilesets, grass/path with a meandering border and grass/soil, sharing one grass tile.
  - IDs are in `src/pixellab-assets.json`. It cost 10 generations; 8 trial generations remain.
- **Slice tool:** `tools/art003_slice.gd` lays a 30×18-tile patch over the farm around the player, using the game's own camera (3x), colour grade and day/night tint.
  - **Ground:** corner-based autotiling from the tilesets, with plain tiles mirrored by position to hide the repeat.
  - **Depth:** props are sorted by their base around the player, so the forest's front trees overlap the player.
  - **Lights:** at night the lantern posts get Godot `PointLight2D`s built with the game's own `_glow()`, alongside the player's lantern. Nothing is baked into the art.
- **Renders:** 12:00 sunny and 21:30 with lantern tier 1, from a clean checkout of `8b9d426`. The working tree's uncommitted `trek_system.gd` still doesn't compile.

## What works

- **Composition reads like the concept:** a central twisted oak with hanging charms, a dirt path winding past it, a layered forest frame (firs behind red maples behind undergrowth), and a fenced garden with lantern posts.
- **The palette holds the family together.** The oranges, reds, deep fir greens and brown paths sit together without any one asset looking foreign.
- **The square grid and straight-on camera are unchanged,** and the scene still reads as the concept's world.
- **Night stays engine-driven:** the posts' and player's light pools come from Godot lights over unlit art.

## Gaps vs the concept

1. **Night is far darker than the concept.** At 21:30 the game's tint and grade leave almost everything black apart from the light pools. The concept's night keeps the scene readable in blue-grey and gives every light source a warm rim. This is engine tuning, not art: night tint, ambient level and light energy. It is the biggest single gap, and it belongs to a lighting task (it overlaps VIS-001's notes).
2. **The day grade mutes the concept's warmth.** The grade's saturation (0.62) and exposure (0.84), plus the locked "muted, desaturated" rule, pull the concept's saturated autumn toward brown-grey. A side-by-side with a lighter grade would show how much of the gap is the grade.
3. **Detail density.** At 16 px per tile shown at 3x, the props are chunkier than the concept's painterly micro-detail. Layering and prop density close part of that gap. The rest would need a higher art density, whose trade-offs are covered in ART-002.
4. **Ground.** The grass tile repeats a leaf speck in a visible grid even with mirroring. The Wang path edges step in diagonal blocks. The soil is flat, with no furrows or bed edging. The concept's ground has leaf litter, cobbles and irregular verges. It needs two or three grass variants, a scatter of separate leaf and pebble decals, and a better soil tile.
5. **Prop cleanup.** The oak and rocks sit on baked grass discs. The crop sprite is clipped at its canvas edges. The undergrowth clump repeats noticeably.
6. **Missing set dressing:** stone ring under the oak, mushrooms, the concept's cobbles and well, barrels and crates, flowers, corn and trellises.
7. **Camera.** The concept's higher, oblique view shows more ground per screen. The game keeps its camera (owner rule), so compositions have to be tighter.

## Suggested next steps (each needs owner approval)

- **Lighting:** a night lighting study, behind a preview flag: a brighter blue ambient, warm rims and more light sources, measured against image 03. It is the cheapest large step toward the concept.
- **Grade:** a day-grade comparison: the current grade against a warmer, more saturated one, with the art left the same.
- **Ground pass:** grass variants, leaf and pebble decals, a cobble tile and a furrowed soil tile. PixelLab tilesets are good at this.
- **Layout:** if the blueprint is approved, a layout migration task (it resets crops in old saves).
- **Art rules:** a decision on whether to relax "muted, desaturated" and "dark outlines on every sprite" toward the concept's saturated autumn palette and selective outlines.
