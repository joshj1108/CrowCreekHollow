# ART-003: Concept-to-game breakdown

Status: proposal for owner and ChatGPT review. Nothing in the live farm, `DESIGN.md` or production art changed.

The owner's four concept images are in `art/reference/concept/`: `01_overview` (homestead day/night, the trek, house stages, seasons, UI), `02_autumn_homestead`, `03_night_homestead` and `04_rookery_escort`.

## 1. Reference breakdown

**Composition.** One elevated, roughly circular clearing ringed by forest. A loose network of curving dirt paths links the functional areas, which form a wheel around the central oak. The forest frame is thick: tree trunks and canopies overlap the clearing's edge and cut its outline into an organic shape, with no hard boundary. Fog drifts at the frame's corners.

**Landmarks (02/03), clockwise from top left:**
- Cave mouth: a timber-and-stone arch, lit inside, in a mossy rock hillside, with stone steps down.
- The ancient oak at top centre: the largest object on the map (about as wide as the farmhouse). It has an orange canopy, a twisted trunk, exposed roots over a ring of dark stones, hanging charms and bundles, and red shelf fungus.
- Farmhouse at top right: a dark slate roof, timber walls, a stone chimney with smoke, warm windows, a porch with steps, flower beds, pumpkins and stacked firewood.
- Barn or shed on the right, a fenced coop and hen yard on the left, and an orchard of apple trees with a ladder and crates in the centre-left.
- Well in the centre, on a cobbled ring where paths meet.
- Garden on the right: a fenced square of six beds (cabbage, purple cabbage, pumpkins, root crops), corn, and bean trellises.
- Pond with lily pads, reeds, rocks and a plank dock at lower left.
- Produce stall with an awning at lower right, beside a road that crosses the bottom of the map.

**Vegetation.** Four layers:
- Canopy: fir and spruce (deep blue-green, dense boughs), red and orange maples, the oak.
- Understorey: red huckleberry and vine maple, golden shrubs.
- Ground cover: sword ferns, dry grass, reeds.
- Litter: orange leaves scattered on every surface, path edges included.

Plants crowd the bases of fences, rocks and buildings, so nothing stands on bare grass.

**Architecture.** Weathered timber, split-rail fences with mossy posts, stone foundations and chimneys, dark shingle roofs with moss. Everything is slightly irregular and lived-in, with barrels, crates, firewood and lanterns on posts.

**Palette.**
- By day: warm and saturated. Oranges, ambers and reds against deep fir greens and olive grass, with brown paths.
- Darks: brown-black rather than pure black. Outlines are dark brown and selective.
- At night (03): the whole scene drops to blue-grey. Warm colour survives only in light sources: windows, a lantern ring on every post, the cave mouth, the player's lantern, moonlight on the pond. A red glow at the lower-right edge marks the Hollow's threat.

**Lighting.**
- By day: soft overhead light. Forms are shaded but there are no strong cast shadows.
- At night: many small warm point lights with falloff, which the engine can do. The oak keeps orange rim light. Fog sits in the corners.

**Depth.** It comes from four things:
- Overlap: trees in front of fences, the canopy over paths, foreground grass along the bottom edge.
- Contrast: dark frame, lit centre.
- Raised edges: rock rims around the pond, the oak's stone ring, the hillside.
- Ground detail: leaves, pebbles, cobbles, grass edges along the paths.

**Trek (04).** Tall dark firs with mossy trunks fill the frame. The trail forks at a waymarker on a stone cairn, with lanterns on posts at each branch. Red undergrowth, ferns, fallen mossy logs with fungus, roots crossing the path, puddles, a small waterfall, and the Hollow's silhouette with red eyes in the far fog.

**Camera.** Every image is drawn from a high three-quarter view, steeper than the game's and roughly oblique. Building fronts face the camera, but paths and plots are seen from above at an angle. The footer of 01 says "16×16 tiles, 16×32 characters", but the images aren't on a clean pixel grid: they are painterly, with a pixel look about 1.5 to 2 screen pixels per art pixel.

## 2. Current game vs concept: gap analysis

| Area | Current game | Concept | Gap |
| --- | --- | --- | --- |
| Layout | 64×40 grid: house top-centre, pond top-right, great tree lower-right, plots left, well centre, stall by the house | A wheel around a central oak, with house top-right, pond lower-left, plots right and stall lower-right on a road | Most landmarks are in different places (see the blueprint) |
| Forest frame | A fixed band of trees around the border, thin inside | A dense, layered, irregular frame that bites into the clearing | Needs many more trees, undergrowth in front, and overlap |
| Ground | Flat dual-grid grass, straight paths, sparse clutter (1 tile in 11) | Olive grass covered in leaves; winding, irregular paths; cobbles around the well | Needs richer tiles, curving paths and dense litter |
| Vegetation layers | Trees and a few brush/thicket sprites | Canopy, understorey, ferns, grass, leaf litter | Missing the understorey and ground cover |
| Landmark oak | A 128×128 SpriteCook great tree, lower right | The biggest object, centred, with charms, fungus and a stone ring | Bigger, moved, more storytelling |
| Buildings | SpriteCook house in four stages, coop, barn, stall | Similar types, more ornamented (flower beds, firewood, barrels) | Mostly dressing, plus a dock and a road |
| Palette | Muted, desaturated (the locked style); the grade dims it further | Warm, saturated autumn by day | The locked "muted" rule conflicts with the concept's daylight |
| Night | Blue CanvasModulate tint, player lantern, house window lights | Many warm point lights (posts, windows, cave), moonlit water, fog, red threat glow | Engine-side: more PointLight2Ds and fog layers; no art change needed |
| Outlines | Bold dark outline on every sprite (locked) | Selective dark-brown outlines | Softer than the lock |
| Detail density | Chunky 16 px with few pixel clusters | Painterly, dense micro-detail | The concept's density can't be fully reached at 16 px on a 3x grid; richness has to come from layering and prop density |
| Camera | Straight-on 3/4 at 3x | Higher, oblique 3/4 | Keep the game camera (owner rule); compose for it |

## 3. Proposed layout blueprint

`layout_blueprint.txt` (64×40, the existing inner grid) and `review/layout_blueprint.png` translate image 02's arrangement onto the current square grid at today's footprint sizes. The house stays 11×7, the great tree base 3×3, plot sizes are similar, the well 2×2 and the stall 3×2.

**Codes:**
- From `farm_grid.txt`: `K` hillside, `C` cave, `O`/`H`/`D` house, `R` porch, `P` path, `~` water, `S` soil, `F` fallow/corn, `W` well, `A` stall, `B`/`b` great tree, `X` fence.
- New: `T` dense forest edge, `r` stone ring, `c` coop, `n` barn or shed, `o` orchard tree, `g` gate, `k` dock.

**Main moves:**
- The oak goes to the top centre inside a stone ring.
- The house moves top-right, with the barn beside it.
- The pond and dock go lower-left.
- The plots go right, inside one fence.
- The stall goes lower-right on a new road along the bottom.
- An orchard is added centre-left.
- The coop yard goes left.
- The forest edge gets thicker and irregular.
- The cave stays where it is.

This is a proposal only. Moving the live layout changes `farm_layout.gd`'s version, which resets every save's crops (see "Farm layout" in `DESIGN.md`). It needs the owner's approval and its own task.

## 4. Vertical slice

See `SLICE.md` and the review package for what was built, how it was rendered and what it shows.
