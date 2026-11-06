# ART-005 HC1 Step 2 — 16 px vs 32 px art-density study

**Status:** zero-generation, non-production study, for the owner's and ChatGPT's review. It proposes; it does not decide. Nothing in the game, `DESIGN.md`, the live farm, saves, camera, scaling, lighting or the existing ART-003, ART-005 or VIS-002 assets was changed. No PixelLab or SpriteCook calls were made.

**Labels that apply to every image in this package:**
- The **16 px cabin** is an **experimental mockup**. A script redrew it on C2's halved coordinates using C2's own colours. It is not finished, artist-authored art, and a professional 16 px repaint would look better.
- The **32 px well** is a **constructed study**. A script laid the production well out on a doubled grid, thinned its lines and re-shaded it. It is not finished, artist-authored art. One 32 px prop also cannot show what a fully rebuilt 32 px world would look like.

## What was made

| Piece | File | How |
|---|---|---|
| 16 px cabin mockup, day and night | `art/style_tests/ART-005/hc2/house16/house_{day,night}.png` (192×160) | `tools/hc2_house16.py`. Every part is redrawn on C2's coordinates halved: roof and ridge cap, 8 shake courses, chimney, 8 log courses on C2's own seams, stacked log ends, both windows, the door, lamp, foundation and steps. Same 12×10-tile footprint, door centre, window centres, silhouette and chamfers. 30 colours, all taken from C2 (C2 has 59). At night only the window glass lights, using C2's three lit-glass colours. |
| 32 px well study | `art/style_tests/ART-005/hc2/well32/prop_well_32.png` (64×96) | `tools/hc2_well32.py`. The production well (32×48) on a doubled grid. Outlines and mortar are thinned from 2 px to 1 px, and the dark masses (the shaft, the shadow under the roof) stay solid. Each stone, shingle, post and stave gets a lit top-left edge and a shaded bottom-right edge. Added detail: a twisted 1 px rope, a water glint, and in-between ramp steps. 25 colours (production: 17). |
| Harness | `tools/hc2_density.gd`, `tools/hc2_density_run.sh` | This is HC1 Step 1's harness with two switches. `house16` swaps C2 for the mockup on the same anchor at full scale. `well32` swaps the well for the study at half scale on the same footprint. Frames are rendered in the clean export, as in HC1 Step 1. |
| Review and measurements | `tools/hc2_density_review.py` → `art/style_tests/ART-005/hc2/review/`, `hc2/measure.json` | Panels, GIFs, run lengths, cluster statistics, pan shimmer. |

The test scene is the HC1 baseline: W-4 layout b, F2 fields, C2 cabin, `grass=1`, the game's own camera, its stretch and colour grade, and the locked R3-1 night. The **home** framing puts the farmer at inner tile 38.5,10.5. At real 720p, that one frame holds the whole cabin, the well, the golden oak and the farmer. Every variant uses this same spot.

## Review package (`art/style_tests/ART-005/hc2/review/`)

| Master | Contents | Scale |
|---|---|---|
| `ART-005HC2_master.png` | **Farmhouse:** the source at equal world size; 720p crops ×4 of the window and corner and of the door and footing, day and night; the farmer at the door | 55% |
| `ART-005HC2_master_2.png` | **Well:** the source at equal world size; in context ×3, day and night; pan frames | 67% |
| `ART-005HC2_master_3.png` | **In context, noon, 1280×720 1:1:** control, A (16 px cabin), B (32 px well) | 69% |
| `ART-005HC2_master_4.png` | **In context, R3-1 night 21:30:** the same three | 70% |
| `ART-005HC2_master_5.png` | **Pan shimmer:** consecutive frames, locked to the world, ×4, cabin and well | 69% |

- **Motion:**
  - `hc2_pan_house.gif`: the diagonal pan, control and 16 px side by side, 1:1.
  - `hc2_pan_well.gif`: the same for the well, ×2.
- **Raw 720p frames:** `review/frames/`.
- **Measurements:** `hc2/measure.json`.

## Measurements

### Source density (from the PNGs)

| Sprite | Art px / tile | Screen px per art px at 720p | Colours | Mean cluster, art px | Mean cluster, screen px² | 1-px clusters | Outline width at 720p |
|---|---|---|---|---|---|---|---|
| C2 cabin (control) | 32 | **1.5** | 58 | 18.5 | 41.5 | 30% | 1.5 px |
| 16 px cabin mockup | 16 | 3 | 30 | 17.5 | 157.8 | 20% | 3 px |
| Well, production | 16 | 3 | 17 | 3.2 | 28.4 | 49% | 3 px |
| Well, 32 px study | 32 | **1.5** | 25 | 4.2 | **9.4** | 34% | 1.5 px |
| Golden oak | 16 | 3 | 45 | 1.9 | 17.4 | 69% | 3 px (coloured edge) |
| Farmer, idle | 16 | 3 | 18 | 3.4 | 30.5 | 47% | 3 px |
| Apple tree | 16 | 3 | 16 | 3.7 | 33.2 | 50% | 3 px (70% coloured edge) |

### Horizontal run lengths at 720p (HC1's method)

These are measured inside each sprite's exact screen rectangle.
- 16 px art at 3× gives runs of 3, 6, 9 and so on.
- 32 px art at 1.5× gives runs of 1, 2 and 3.

| Region (noon) | Runs that are a multiple of 3 | Runs of 1–2 px |
|---|---|---|
| Cabin, C2 32 px | 40% | 36% |
| Cabin, 16 px mockup | **74%** | **10%** |
| Well, 16 px | **88%** | **8%** |
| Well, 32 px study | 37% | 56% |
| Golden oak canopy (reference) | 86% | 11% |

Night gives the same picture: C2 42% / 43%, mockup 68% / 20%, well 89% / 8%, study 38% / 55%. The night grade's grain and the warm window light break up more runs on both cabins.

### Pan shimmer

The test uses 30 fps diagonal walks, so the camera moves 4.24 px a frame and its sub-pixel phase changes every frame. Consecutive frames are aligned by the best whole-pixel shift. The table gives the share of pixels that still differ: inside the sprite's exact rectangle (taken from each frame's logged camera), and in the rest of the frame. The farmer is masked out. There are 63 frame pairs for the cabin and 89 for the well.

| Sprite | Mean changed share | Max | Rest of frame |
|---|---|---|---|
| C2 cabin, 32 px | **8.6%** | 21.0% | 2.3% |
| 16 px cabin mockup | **0.4%** | 2.1% | 2.2% |
| Well, 16 px | **2.1%** | 10.6% | 2.7% |
| Well, 32 px study | **10.3%** | 28.4% | 2.8% |

This is the decisive technical result. **Any 32 px sprite shown at the locked 48 px tile shimmers about 4–20× more than 16 px art during a pan**, because its art pixels land as alternating 1- and 2-px columns that swap as the camera's phase moves. This reproduces HC1 Step 1's figure for C2 (9.3%). The density mismatch alone explains it; the quality of the art does not matter. The 16 px mockup is steadier than the rest of the frame, which carries leaf particles, water and grain.

## Visual findings

**Farmhouse (master 1, 3, 4):**
- At gameplay zoom, the 16 px mockup sits in the same pixel grid as the oak, the well, the grass and the farmer. The cabin no longer looks like it came from a different game.
- Its outline matches the farmer's 3 px outline. Beside the door, the farmer and the cabin read as one world.
- It loses some of what made C2 attractive:
  - the fine wood grain and knots;
  - the subtle mottling of the shakes;
  - the rounded cobbles;
  - the door's layered boards.

  A careful 16 px repaint can recover much of this through clustering and ramp choice. A script-built mockup does not. The roof is still more regular and block-like than C2's.
- At night, both cabins hold the warm window focus equally well. The R3-1 night does not depend on the cabin's density.

**Well (master 2, 3, 4):**
- At source size, the 32 px study looks more detailed: finer stones, a twisted rope, a 1 px outline.
- At gameplay zoom, beside the 16 px stump, rocks, log pile and farmer, that detail reads as fussy rather than crafted:
  - The thinner outline (1.5 px) makes it look lighter and less solid than everything around it.
  - Its mean cluster is a third of the size of its neighbours' (9 against 28–33 screen px²).
  - Its texture frequency is higher than the oak's.

  It stands out as a different style, not as a better well. The higher density does not buy craftsmanship that the player can see. It buys inconsistency, and it shimmers in motion (10.3%).

**What this study cannot show:**
- What a professional 16 px repaint of C2 would look like. It would be better than this mockup.
- What a fully rebuilt 32 px world would look like. In such a world, everything would be 1.5 px per art pixel at 720p, so the inconsistency would go away but the shimmer would be everywhere. The camera section below covers this.

## The camera constraint

At the locked 48 screen px per tile (16 px art at 3× at 720p):
- 16 px art is the only density that lands on whole screen pixels.
- 32 px art is 1.5 px per art pixel.

A 32 px world can only be pixel-exact if the tile grows to 64 or 96 screen px at 720p. At 64 px the view drops from 26.7 × 15 tiles to 20 × 11.25 tiles, a 44% smaller view. That changes gameplay readability, the night's reach, and the camera and scaling decisions that are locked. So a 32 px pipeline is also a camera decision, not only an art decision.

At 1080p, today's stretch is 4.5 px per 16 px art pixel, which is non-integer for every asset. That is a separate decision and is still not authorised. At an integer 64 px tile it would be 4× for 16 px art or 2× for 32 px art.

## Proposed pixel-art rules (draft, a 16 px standard; not a `DESIGN.md` change)

1. **Source density:**
   - Every world sprite is 16 art px per tile, shown at 3× with nearest filtering, and is never resampled.
   - No mixed-density world sprites, including hero props and buildings.
   - UI and portraits are their own layer and are not covered by this rule.
2. **Pixel clusters:**
   - Material texture is built from clusters of 2 px or more.
   - Single pixels are only for highlights, glints, eyes, nails and knots.
   - Targets:
     - props, buildings and characters: a mean cluster of 3 art px or more, and 1-px clusters at or under about 40%;
     - foliage: may go to about 70% 1-px clusters (the golden oak is 69%), but needs readable leaf masses of 4–8 px.
   - Ground tiles: a mean cluster of 4 px or more.
3. **Outlines:**
   - Every standing object has a 1 art px (3 screen px) silhouette outline.
   - Structures, characters and props use one shared near-black warm outline, `#18110F` (24,17,16), C2's.
   - Foliage and fruit trees may use their darkest leaf tone as a coloured outline, to keep the oak's softness.
   - Interior lines (seams, mortar, board gaps) are one ramp step darker than the darker of the two materials they separate, not black.
   - The pure-black outlines on the well and some props would move to the shared colour when they are next touched.
4. **Light and material shading:**
   - One key light from the upper left.
   - Lit top and left edges go one ramp step up; bottom and right edges, and the area under overhangs, one step down.
   - Ramps have 4–6 steps per material, with highlights shifted warm and shadows shifted cool.
   - Wood: horizontal grain streaks of 3–7 px and knots of 2 px.
   - Stone: rounded clusters of 6–10 px with a 2–3 px highlight on the upper left.
   - Shakes: 7–14 px wide in 6 px courses, with an uneven butt line.
   - No dithering on world sprites. No soft alpha, except light and atmosphere effects.
5. **Colour counts per sprite:**

   | Sprite | Colours |
   |---|---|
   | Small prop | 16 or fewer |
   | Medium prop, character, animal | 24 or fewer |
   | Building variant | 32 or fewer (the mockup has 30, C2 has 58) |
   | Hero tree | 48 or fewer |

   All sprites draw from one shared master palette of about 96 colours, so hues match across the farm.
6. **Texture frequency, as a hierarchy:**
   - Ground is quiet: low frequency, about one accent per 2×2 tiles, with scatter litter well below HC1's level.
   - Buildings and props are medium.
   - Hero objects (the oak, the cabin's door and windows) carry the most detail and contrast.
7. **Contact shadows:**
   - Every standing object gets a hard-edged ground contact shadow, drawn as pixel art (not an alpha blob):
     - small props: 1–2 rows;
     - buildings and trees: 2–3 rows, offset toward the lower right, away from the light.
   - Colour: the ground's own ramp, two steps down.
   - This fixes HC1's "floating props" finding.
8. **Environment and character consistency:**
   - Characters use the same outline colour and width as the world.
   - Their mid-values sit at least about 20 luma from the ground under them, by day and in the R3-1 night.
   - New NPCs follow the farmer's build: 16×32, 8-frame idle and walk, 3 facings plus a mirrored one.

## Asset inventory and conversion effort

The estimates are in **artist-days for an experienced pixel artist** (8 h, AI-assisted drafts allowed, final pixels cleaned by hand). They are ±50% and are meant for relative comparison, not budgeting.

| Group | What exists (production `art/` + the W-4 prototype art) | 16 px pipeline | 32 px pipeline |
|---|---|---|---|
| Farmhouse and restoration | 4 stages of 192×160 with lit-glass night variants. C2 (32 px, PixelLab-derived) is the preferred stage-3 design. | Repaint C2's design at 16 px, then derive stages 0–2: **6–10** | Finish C2 by hand (it is an AI-edited prototype) and make stages 0–2 at 32 px: **8–14** |
| Farmhouse interior | 10 sheets (walls, floors, hearth, beds, furniture, rug and so on) | keep: **0** | **8–12** |
| Terrain | grass, path, soil, fallow and water sets (64×64 each), hillside, cave floor and wall, and the PixelLab grass/water/path/wear/variation tilesets (about 7) | keep; value-key and scatter pass (wanted anyway): **2–4** | rebuild every autotile set (4× the pixels; ground at 32 px gets noisy easily): **12–20** |
| Farming and crops | 11 crops × 4 stages = 44 cells (3 drawn as strips, 8 still code-drawn), F2 field soil states (4), scarecrow | the 8 missing strips are needed anyway: **4–6** | all 44 cells and the soil: **10–16** |
| Trees and forest | fir ×3, oak ×3, willow ×2, dead ×2, the great tree (128²), the golden oak, undergrowth, brush and thicket ×7 | keep the golden oak and forest as they are: **0–1** | redraw everything, **including the golden oak**, the farm's best asset: **14–24** |
| Orchard | apple and pear crowns a/b, windfalls, basket | crown polish (HC1 weakness): **1–2** | **4–6** |
| Water and dock | 2 water tilesets, shore strip, dock ×3, rushes | dock recolour (HC1 weakness): **0.5–1** | **5–8** (+ water animation) |
| Roads and gates | path and wear tilesets, ruts, gatepost, gate leaves and spur, fence | gate redesign (HC1 weakness): **1–2** | **4–6** |
| Props and interactables | about 45: boulders, rocks, stump, chopping log, woodstore, log pile, clutter, crow perch, mailbox, signpost, 2 carts, compost, barrel kit, pumpkins, flowers, debris, fungus, well, stall, cellar, furnace, smokehouse; buildings: barn, coop, workshop; cave mouth, exit and ore | bring outlines and contact shadows to the standard: **3–5** | **20–30** |
| Player | 27 sheets × 8 frames = **216 frames** (16×32 figure in 36 px cells) | keep: **0** | 32×64 figure, 216 frames: **25–45**. Frame-to-frame consistency at 32 px is the hardest thing for the AI tools we use. |
| Animals and foes | goat, hen, crow (fly and perch), bat, lizard, snake (5 frames each) | keep: **0** | **6–10** |
| NPCs and future characters | not drawn yet: 4 walkers (Maren, Davy, the vicar, the postman), the woman in grey, and about 4 sprited night visitors (field figure, tall watcher, the Hollow, fox), each with idle and walk in 3 facings | **15–30** (needed under either pipeline) | **40–70** |
| Weather and effects | 6 particle strips | keep: **0** | match: **1–2** |
| UI and portraits | 20 UI pieces; portraits on a 48 px grid | not world density: **0** | **0** |

**Totals:**
- **16 px:** about **35–60 artist-days**. Only the farmhouse (6–10) is rework caused by the density choice. The rest is either work we need anyway (the missing crop strips, NPCs, HC1's weaknesses) or a standards pass on art we keep.
- **32 px:** about **160–260 artist-days**. About 110–190 of those redo art that already works, and the total assumes the camera change above.

**Risks:**
- **32 px:**
  - It needs a camera/scale change, or it shimmers everywhere.
  - It discards the golden oak, the forest and the farmer that the reviews rate highest.
  - At 32 px, AI-assisted generation drifts more between frames and pieces, so more hand cleanup is needed.
  - The ground gets noisier, the very problem HC1 found.
  - It is several months of art before the farm looks consistent again.
- **16 px:**
  - The cabin loses some of C2's material richness unless it is repainted carefully.
  - The look stays chunky, so "premium" has to come from the value key, contact shadows, palette discipline and composition rather than from pixel count. HC1 already ranked those as the bigger wins.

## Recommendation

**Adopt 16 px as the single world density.** Repaint the C2 farmhouse design at 16 px, keeping its layout, materials, palette and night behaviour. Treat the proposed rules above as the draft standard for the next phases.

The reasons:
1. 16 px is the only density that is pixel-exact at the locked camera.
2. The pan data shows the 32 px cabin and well shimmer about 4–20× more than 16 px art.
3. The 32 px well shows that extra density alone makes a prop look inconsistent, not finer, at gameplay zoom.
4. The art the reviews like best (the golden oak, the autumn forest, the farmer, the compact fields) is already 16 px.
5. It costs about a quarter as much as 32 px, and most of that work is needed anyway.

**Still uncertain:**
- How close a professional 16 px repaint can get to C2's richness. The mockup is a lower bound.
- How a whole 32 px world, with the camera changed to match, would feel. It was not built, and one 32 px prop cannot show it.
- The cost figures, ±50%.
- Whether the owner values C2's fine grain enough to accept a camera change. That is the owner's call.
- The separate 1080p scaling decision (4.5×, non-integer today), which affects every asset under either density.

Nothing here is authorised beyond the study. HC1 Step 3, any `DESIGN.md` change, any production art change and any camera change all wait for the owner.
