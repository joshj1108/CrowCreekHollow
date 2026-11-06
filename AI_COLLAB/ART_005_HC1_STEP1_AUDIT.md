# ART-005 HC1 Step 1: whole-farm visual quality audit (audit only)

**Status:** audit and evidence only. Review requested from the owner and ChatGPT. Nothing in the game, its art, layout, camera, scaling, lighting, saves or `DESIGN.md` was changed. No PixelLab or SpriteCook call was made, and no asset was generated, converted or downsampled.

**Answers:** the owner's HC1 Step 1 brief (2026-11-05), after ChatGPT's C3 image review (`af71008`). C2 is kept as the preferred non-production cabin, C3 is archived, and roof polishing is closed.

**Scene audited:** the ART-003 W-4 homestead (layout b), with the F2 fields, the C2 log cabin (`house=g7:c2`), the golden oak, the well and crossroads, the orchard, the pond and dock, the road, the closed gate, the 14-tile forest margin, and the existing farmer, terrain and props.

## Evidence and how it was made

Every frame is a Godot render through the existing W-4 harness (`tools/art003_wide.gd mode=wide layout=b grass=1 art=f2 house=g7:c2`). The renders ran in the clean export `builds/review/ART-005/p1_export/`: HEAD's code and art plus the C2 sprites, with no VIS-002 working-tree change. This is how C3 was rendered.

- **Harness:** `tools/hc1_audit.gd` is a new, evidence-only extension of that harness. It adds:
  - `nofarmer`, which hides the farmer for the overview tiles;
  - `fhd=today|int`, a borderless 1920×1080 window;
  - `camlog`, which writes the camera's position on every frame.
- **Scripts:** `tools/hc1_audit_run.sh` renders the frames, and `tools/hc1_audit_review.py` builds the panels and `measure.json`.
- **Not used:** concept images and enlarged sprites are never used as gameplay evidence.

| Item | Scale | File (`art/style_tests/ART-005/hc1/review/`) |
| --- | --- | --- |
| 1. Full overview, noon and R3-1 night | Nine real 1280×720 frames stitched edge to edge. Full-res = gameplay pixel scale; sheet = **50 % downscaled** | `hc1_overview.png`, `hc1_overview_{day,night}_fullres.png` |
| 2–9. The eight locations, noon and night (farmer present, lantern tier 1 at night) | **Actual 720p**: 800×450 centre crops at 1:1. The full frames are in `frames/` | `hc1_locations_a.png` (cabin/oak/well, crossroads, fields, farmer at door), `hc1_locations_b.png` (orchard, pond/dock, road, gate), `frames/*_720p.png` |
| 1080p | 1:1 crops of 1920×1080 frames: the game's own 1.5× stretch, and an integer 4/3 harness framing (**comparison only, not a camera proposal**) | `hc1_1080p.png`, `frames/*_1080p_*.png` |
| Value maps | Greyscale and 6-band value key of the stitched overview, plus a texture-noise map. **40 % downscaled** | `hc1_values.png` |
| Pixel density | 720p crops **enlarged 4×** (nearest), and measured run lengths | `hc1_density.png` |
| Camera pan | Three recorded walks (real input, the game's camera): west at 30 fps, north-west at 30 fps, west at 144 fps. Frame strip **enlarged 4×**, difference map, and a 1:1 GIF | `hc1_pan_frames.png`, `hc1_pan_diag.gif` |
| Numbers | Region luma and texture, pixel runs, sprite edge colours, pan instability | `art/style_tests/ART-005/hc1/measure.json` |
| **Masters (attach these)** | Each fits within 2048 px | `ART-005HC1_master.png` (summary, 100 %), `_2` (overview, 74 %), `_3` and `_4` (locations, 83 %), `_5` (values, 63 %), `_6` (density and pan, 70 %), `_7` (1080p, 96 %) |

**Night:** the locked ART-003 R3-1 night at 21:30. In the overview the lantern is off (`lantern=0`, farmer hidden), so the gaps between the farm's own lights show.

**Limits:**
- In the stitched overview, each frame keeps its own grade vignette, so faint darker bands appear at the joins.
- This is the W-4 prototype, not the live farm.
- Performance was not measured.

Each claim below is labelled **observed** (seen in the frames), **measured** (`measure.json`) or **hypothesis** (not verified).

## Findings

### 2. Pixel-density consistency

1. **The cabin's pixels are half the size of everything else's.** (measured)
   - Horizontal colour runs at 720p, where a run ends wherever the step exceeds the grade's film grain:

     | Asset (art density) | Runs that are multiples of 3 | Most common run lengths |
     | --- | --- | --- |
     | Oak canopy (16 px) | 85 % | 3 |
     | Grass (16 px) | 83 % | 3 |
     | Farmer (16 px) | 76 % | 3 |
     | C2 cabin walls (32 px) | 31 % | 1, 2 and 3 (42 % are 1 or 2) |

   - The cabin's 1-art-px outline is 1–2 screen px wide. Every other outline is 3 px.
   - The 4× crops show it directly: the cabin's window, log grain and foundation stones are drawn at twice the resolution of the well, farmer and oak beside them.
2. **It reads as a mixed-resolution picture, not just "more detail".** (observed)
   - At 720p the cabin looks like a crisper photo pasted into a chunkier world. Its wall texture (fine grain streaks, 58 colours in the sprite) is a different kind of rendering from the 16-px props (7–18 colours) and the oak (45).
   - The farmer, the one constant 16-px figure, has about a quarter of the detail per area of the door beside them.
   - This is the clearest visible inconsistency in the north of the farm.
3. **The cabin shimmers when the camera moves vertically.** (measured)
   - **Method:** consecutive frames were aligned by the best whole-pixel shift. The share of pixels that still changed:

     | Pan | Camera step per frame | Cabin | Rest of frame |
     | --- | --- | --- | --- |
     | Diagonal (north-west), 30 fps | 4.24 px | **9.3 %** | 2.2 % |
     | Straight west, 30 fps | exactly 6.0 px | 0.5 % | 0.7 % |
     | Straight west, 144 fps | 1.25 px | 4.0 % | 4.3 % |

   - **Diagonal pan:** the cabin changes 4.3× as much as the rest. The frame strip shows the log seams switching between 1 and 2 px thick from frame to frame.
   - **Horizontal pans:** they hardly trigger it, because the cabin's lines are mostly horizontal.
   - **The 16-px art doesn't shimmer** at any step size. Its 3-px pixels keep their size at any sub-pixel camera offset.
   - **"Rest" is an upper bound.** It also counts drifting leaf particles, swaying crops and the forest edge's animation.
4. **1080p is non-integer for every asset today.** (measured, existing production behaviour)
   - The game's `canvas_items` stretch makes a 16-px art pixel 4.5 screen px at 1080p. The oak's runs are 4 and 5 px. The cabin's art pixels are about 2.25 px, so its runs are 2, 3, 4 and 5 px.
   - So 1080p players already see uneven pixels everywhere. This is separate from the cabin, and it matters to the density decision.
   - The harness's integer 4/3 framing (tile 64 px) removes it, but that is a camera or scaling change and is not proposed here.
5. **Conclusion on density:** the mismatch is real and measurable, and it is a **major, but not the only**, contributor to the incoherent look.
   - It explains the "pasted-in" cabin and the shimmer.
   - It does not explain the farm-wide problems below (value key, ground noise, outlines, grounding, mixed asset families). Those are just as visible in views with no cabin: the orchard, pond, road and gate.
   - **The evidence doesn't settle 16 px versus 32 px.** It only says that any one choice must be applied to everything on screen together, including the farmer and the ground.

### 3. Whole-scene quality

**A. Craftsmanship**
- **Four outline families.** (measured, from the sprite edges)

  | Family | Assets | Edge luma (median) |
  | --- | --- | --- |
  | Pure black | farmer, well | about 0–1 |
  | Warm near-black | cabin, oak | 21 |
  | Warm near-black | log pile | 30 |
  | Selective, coloured | apple tree (reddish edge) | 44 |
  | None | gatepost | 45 |

  At 720p the farmer and well read as cut-outs with ink lines, the apple trees as soft-edged blobs, and the oak and cabin as somewhere in between. (observed)
- **Uneven shading quality.** (observed)
  - The oak has clustered, deliberate leaf masses.
  - The orchard crowns are round balls with evenly spaced fruit dots.
  - The forest trees are good, clean silhouettes.
  - The boulders are cool blue-grey with a bright top rim, cooler and more saturated than anything near them.
  - The dock is a cool light grey that reads more like stone than wood.
- **Soft, non-pixel overlays:** several effects are smooth, blurred shapes rather than pixel art. (observed)
  - F2's wet-soil patches;
  - the road's wheel-rut and fog bands;
  - the dark ring decal round the well;
  - the cloud or fog wisps at the margins.
- **The gate doesn't read as a gate.** It is drawn edge-on (north–south) at x 59, so at 720p it reads as a lamp post or pole across the road, not as a closed gate. (observed)
- **The avenue beyond the gate:** at night it is a flat black rectangle with hard corners. (observed)

**B. Environmental cohesion**
- **Cabin against its surroundings.** (observed)
  - Its palette is cooler and greyer than the oak and grass.
  - Its density differs (see 2).
  - It has no contact shadow or ground transition: the foundation sits on bare grass and litter.
- **The oak** is the best-integrated hero asset, and it is a clear landmark (see 4).
- **The orchard against the forest:** the orchard crowns and the margin's red deciduous trees come from different families. Small orange shrubs float beside the fruit trees. (observed)
- **Crops and fields:**
  - The crops are clear 16-px icons in readable rows.
  - The furrows are flat dark bands, and the soil has no material texture at the same density as the grass.
  - The fields read as dark rectangles inset into a path-coloured rim. (observed)
- **The farmer** reads cleanly everywhere. Their pure-black outline is the strongest on screen, which is good for play but inconsistent with the scenery. (observed)

**C. Lighting and atmosphere**
- **The noon key is low and narrow.** (measured; the judgement is mine)

  | Region | Mean luma (0–255) |
  | --- | --- |
  | Grass | 49 |
  | Path | 58 |
  | Fields | 50 |
  | Water | 38 |
  | Forest | 30 |
  | Roof | 33 |
  | Oak sprite rect | 64 (90th percentile 133) |

  - Most of the frame sits in one value band (40–69).
  - Noon reads like late afternoon under cloud. It is warm in hue, but not the bright, warm autumn day the concept shows.
- **No shared light model.** (observed)
  - There are no consistent contact or cast shadows. The trees, cabin, well, boulders, crates and gate have none, or tiny baked ones in different directions.
  - The light direction can't be read from the scene. (Style-spec §4 asks for one; not met.)
- **Night:** (observed)
  - Readability is good: paths, fields, crops and the farmer all read. The cabin windows and porch light give a warm focus.
  - The R3-1 grade keeps the oak and orchard crowns fairly saturated and mid-value (oak mean 37 against grass 28). Close to the farmer the night reads moody, but not threatening.
  - The pond turns a saturated cyan in the lantern pool.
  - The threat comes from the dark forest edge (mean 13), which works.

**D. Composition**
- **The oak and the cabin balance.** (observed)
  - The oak is the brighter, warmer mass. The roof is a dark rectangle at the forest's value, so it reads as a hole rather than as a dominant shape.
  - At full-farm scale the roof doesn't dominate. It dominates only in the north view, where it fills the top of the frame.
- **Large empty areas:** the north-west quarter and the area between the oak and the orchard are wide, evenly speckled grass with nothing to look at. (observed)
- **The paths** are separated from the grass mainly by hue. Their value is only about 9 luma apart, and their edges are irregular blobs. The crossroads read as a broad dirt clearing rather than as designed routes. (measured and observed)
- **Debris** is spread evenly, with no clustering:
  - acorns, mushrooms, pale leaves, tufts and the orange speckle;
  - the pale cream leaf sprites are the brightest small things in the day frame, so they pull the eye everywhere. (observed)

**E. Gameplay readability**
- **The farmer** is highly visible day and night. One problem: the orchard crowns can hide them when they stand north of a tree. (observed)
- **Crops** read at a glance. Seedlings on dark wet soil are the weakest. (observed)
- **Walkable routes** are clear by hue. Fences and posts are thin and dark but readable. (observed)
- **Interactables:** the gate is not recognisable as one. The well, crates and baskets read. The pale litter sprites look like pickups (forage), which risks confusion. (observed; the pickup confusion is a hypothesis)
- **Ground, objects and structures:**
  - Separation between the ground and objects is weak. The grass's texture energy (20.5) equals the crop fields' (20.0), so crops get no quieter backdrop. (measured)
  - Structures separate well by outline.

### 4. The value map, in short

- **Darkest:** the forest margin, the cabin roof (both in the 0–39 band), the pond, and the fields' wet soil.
- **Brightest by day:** the oak canopy, then the orchard crowns, then the cabin's wall highlights. Then hundreds of pale litter specks, scattered evenly.
- **Brightest at night:** the cabin windows and porch lamp, and the garden lantern post.
- **The oak** stays the clearest landmark, by day and at night.
- **The roof:** it doesn't take too much space at farm scale. Its problem is that it is the same value as the forest.
- **The grass** is the most texture-busy large surface, about as busy as the crop fields, with no quiet zones round the structures.
- **The eye's path:** oak → cabin windows (night) or wall (day) → the scattered pale specks (distracting) → the field crops. The paths don't guide the eye; the eye is guided by bright litter instead.

### 5. Rubric score (`ART_REVIEW_RUBRIC.md`): Claude Code's provisional self-score

The score is judged against the owner's premium commercial standard (D-013), not against earlier prototypes. As the author of much of this prototype, expect some bias.

| Dimension | Weight | Score | Evidence |
| --- | --- | --- | --- |
| Concept fidelity | 25 % | 6.0 | The W-4 layout, autumn palette family, oak landmark and forest frame match the concept's idea (observed). The cabin's density, the large empty grass areas, the dim noon and the illegible gate pull it down. |
| Environmental richness | 20 % | 5.5 | The layers are there: forest, litter, props, orchard, dock. But the scatter is even, nothing is clustered, there are no quiet zones, the furrows and ruts are flat and soft, and large areas are empty (observed). |
| Lighting and atmosphere | 20 % | 5.5 | Noon is low-key (grass luma 49, measured). There are no contact shadows and no single light direction (observed). Night is readable with warm windows, and the forest is threatening, but the play area isn't (observed). |
| Asset consistency | 15 % | 4.0 | Two pixel densities (measured). Four outline families (measured). PixelLab, SpriteCook and code art read as different families, with cool boulders and dock among warm props (observed). |
| Gameplay readability | 10 % | 7.0 | The farmer, crops and paths read day and night. The gate isn't readable, the litter looks like pickups, and the orchard crowns hide the farmer (observed). |
| Technical quality | 10 % | 5.5 | Mixed pixel sizes and cabin shimmer on diagonal moves (measured). 1080p is non-integer for every asset (measured). There are soft non-pixel overlays, but no seams (observed). Performance not measured. |
| **Total** | | **55.5 / 100** | Below 65: "reconsider the current approach for the weakest dimensions". |

**Gates:**

| Gate | Result |
| --- | --- |
| 1. Rules | ✗ for the cabin: 1.5-px pixels break the locked "one art pixel is always three screen pixels" (`DESIGN.md`). It is a non-production prototype. |
| 2. Gameplay and saves | ✓ (nothing changed) |
| 3. Tests | n/a (no game code changed) |
| 4. Evidence | ✓ |
| 5. Compromises | Register not updated (audit only) |
| 6. Approval | Pending |

For context only: the W-2 wider prototype scored 61.75 (Claude) and 60.0 (ChatGPT) on existing art. This lower number is a stricter standard applied to the whole farm, not evidence that the farm got worse.

**Strengths:**
- The oak is a genuine hero asset and a clear landmark.
- The forest margin (dark conifers and red deciduous trees) frames the farm strongly.
- The night is readable, with warm window light.
- The farmer and crops read clearly.
- The connected layout reads as one homestead.

## 6. The most important problems, ranked

| # | Problem | Impact on the scene | How often seen | Visible at 720p | Feasibility | Effort | Risk to systems |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | **No single art standard:** two pixel densities, four outline families, several generator "families" (cabin 1.5 px; outline luma 0–45; cool boulders and dock among warm props) | Very high: it is why the farm doesn't look like one team's work | Constant | Yes | High once a standard is chosen | Medium to large (rules first, then rework per asset) | Low: art only, the logical grid stays |
| 2 | **Scene value and colour key:** a narrow, low noon key (most of the frame at luma 40–69), the roof at forest value, the brightest small things being litter | Very high: everything looks dim and flat by day | Constant | Yes | High | Small to medium (a grade and value study, then per-asset moves) | Medium if production lighting is touched; low as a study |
| 3 | **Ground noise and uniform scatter:** grass as busy as the crops, no quiet zones, pale specks everywhere | High | Constant | Yes | High | Small (scatter rules in the harness) | Low |
| 4 | **No grounding or light model:** no contact shadows, no readable light direction | High: objects float | Constant | Yes | High | Small to medium (one shadow rule and decals) | Low |
| 5 | **Cabin shimmer and 1080p non-integer stretch:** cabin flicker on diagonal moves (measured 4.3×), uneven 4/5-px pixels for everyone at 1080p | Medium to high: motion quality on the most-watched screen | Every walk; 1080p players always | Yes (in motion) | The cabin part is resolved by item 1. The 1080p part needs a scaling decision | Medium | **High** for the 1080p part (camera and scaling, locked) |
| 6 | **Path and route design:** blobby edges, value close to the grass, a crossroads that reads as a clearing | Medium to high | Constant | Yes | High | Small to medium (path tiles and edge rule) | Low (drawn only, collision unchanged) |
| 7 | **Soft non-pixel overlays:** wet-soil blobs, wheel ruts, the well ring, fog wisps | Medium: they break the pixel-art illusion | Frequent near the fields, road and well | Yes | High | Small | Low |
| 8 | **Hero-prop clarity:** a gate that reads as a pole, orchard crowns unlike the oak, a cool stone-like dock, the black void beyond the gate at night | Medium | Occasional (edges of the farm) | Yes | High | Small to medium per prop | Low (the gate's collision stays) |
| 9 | **Composition gaps:** a large empty north-west quarter and the stretch between the oak and the orchard | Medium | Often, while crossing the farm | Yes | Medium | Medium (a layout dressing pass, not a redesign) | Low to medium (must keep W-4) |
| 10 | **Farmer detail and outline:** the only constant figure. Clean and readable, but its pure-black outline and its detail level set it apart from the scenery | Medium | Constant | Yes | Medium (needs a matching standard first) | Medium (all animation sheets) | Medium (many sheets) |

## 7. Recommended next three priorities (proposals, not authorization)

1. **Decide one art standard (density, outlines and shading rules), using evidence that compares like with like.**
   - This is HC1 Step 2, extended beyond the cabin.
   - **Tradeoffs:**
     - Staying at 16 px matches 90 % of the existing art, the farmer's sheets and `DESIGN.md`. It is the cheapest path. The cabin and future heroes would need a skilled hand-authored 16-px version (not an automatic downsample).
     - Moving to 32 px means reworking everything on screen together, including the ground, all props and every farmer animation. It is a `DESIGN.md` change and a large commission. Otherwise the mismatch just moves to another asset.
     - A hybrid ("heroes at 32 px") reproduces exactly the inconsistency measured here.
   - **Production implications:**
     - Every later purchase or generation depends on this decision.
     - The 1080p non-integer stretch should be decided at the same time, because it changes what "one pixel size" means for players.
2. **Set the scene value and colour key, and the grounding rule, as a harness-only study.**
   - Paint over the stitched overview to set:
     - a brighter, wider noon key;
     - the oak as the light focal point;
     - the roof separated from the forest;
     - litter brought down in value;
     - one light direction, with contact-shadow rules.
   - **Tradeoffs:** it is cheap and affects every frame. But any grade change touches production lighting, which is not authorized, so the output is a target and a per-asset list until approved.
3. **Calm the ground: scatter, path edges and soft overlays, in the harness only.**
   - Cluster the litter under trees and along edges, and leave quiet zones round the structures.
   - Give the path firmer pixel-art edges and a stronger value step.
   - Replace the blurred wet-soil and rut overlays with pixel-art equivalents.
   - **Tradeoffs:** this is low cost with no generation, and gives the biggest "finished" gain per hour. It must keep W-4 and the F2 layout exactly.

**Deliberately not first:**
- **The farmer** depends on decision 1.
- **Hero-prop fixes** (gate, dock, orchard crowns) are cheap but local. Do them after the rules exist, so they are made once to the standard.

## 8. Proposed scope for HC1 Step 2 (for approval; not started)

**"Art-standard decision study", zero generations, non-production, harness only:**
- **Cabin pair:** the C2 cabin at 32 px (control) against a hand-cleaned 16-px C2. The 16-px version is labelled as a strawman: an automatic reduction cleaned by hand, not finished art.
- **Second asset pair:** a small 16-px prop (the well) shown beside a 32-px redraw of the same prop. This tests whether 32 px reads better when everything around it matches, without a farm-wide conversion.
- **Measurement:** the same W-4 frames as this audit (north view, door, overview), the diagonal pan, and the run-length and shimmer measurements.
- **Written cost estimate** for each path (16 px everywhere, 32 px everywhere): the asset count by category, including the farmer's animation sheets. Plus a note on the 1080p integer-scaling question for the owner. Not a camera change.
- **Draft outline and shading rule** (one edge colour family, weight and when to use selective outlines), illustrated on existing sprites without changing them.
- **Stop for the owner's decision.**

**Out of scope for Step 2:**
- value, ground and grounding work (Steps 3–4);
- production migration;
- `DESIGN.md` edits;
- camera or scaling changes;
- any spending.

## Preserved

- The C2 cabin, the C3 archive, the four restoration stages (not implemented), the F2 fields and the W-4 layout with the road and gate.
- The ancient oak, the well and crossroads, the orchard, the pond and dock.
- Saves, the logical grid, the camera and scaling, production lighting, the porch and second-storey systems, VIS-002, `DESIGN.md`, and all ART-003 and ART-005 files.
- **New files only:**
  - `tools/hc1_audit.gd`, `tools/hc1_audit_run.sh`, `tools/hc1_audit_review.py`;
  - `art/style_tests/ART-005/hc1/`;
  - this document;
  - the board entry.
