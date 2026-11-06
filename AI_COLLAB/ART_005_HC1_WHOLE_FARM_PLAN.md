# ART-005 HC1 (homestead cohesion): whole-farm art-quality plan (documentation only)

**Status:** a plan only. Nothing in this document is implemented, approved or scheduled. No art, layout, code, save, camera, scaling, lighting or `DESIGN.md` change is proposed for now. Each step below needs the owner's go-ahead.

**Answers:** the owner's C2 image-review brief: "shift the project's artistic focus toward overall homestead cohesion".

**Purpose:** evaluate the selected log cabin (C2) inside the complete ART-003 W-4 homestead. Find the inconsistencies that most hurt the scene as a whole, and order the fixes so each one improves the complete frame rather than one asset.

## Fixed: preserved in every step

- The four fixed-structure restoration stages of the cabin.
- The F2 compact, ground-level tilled crop fields (112 plantable positions; no crop-map or save migration).
- The ancient golden oak.
- The central well and the crossroads.
- The orchard, the pond and the dock.
- The incoming road and the closed gate.
- The preferred wider W-4 farm composition (layout b).
- The 16 × 16 logical grid, collision, camera and scale, the R3-1 night and P-1 lighting, and all existing upgrade systems.
- All ART-003, ART-005 and VIS-002 files, and every save.

## Evidence used, and its limits

**Observed:**
- the C2 | C3 homestead-north frames rendered for C3 (`art003_wide.gd`, W-4 + F2, at noon and R3-1 night);
- the ART-005 harness frames at 720p and 1080p.

**Taken from earlier reviews on the board:**
- ChatGPT's C1 and C2 image reviews;
- the E2-PL G1 note on a higher-density "patch" (`1498`).

**Not yet observed for this plan:** the F2 fields, the orchard, the pond and dock, and the road and gate as part of one frame with C2. Their findings below are marked *to verify*. Step 1 exists to close that gap before anything is changed.

## The most significant inconsistencies, ranked by how much they hurt the whole scene

1. **Mixed pixel density** (observed; rubric: "mixed pixel scales", "uneven pixel sizes")
   - **The problem:** the cabin is 32 art px per tile, drawn at half scale (1 art px = 1.5 screen px at 720p). Everything around it is 16 px art at 3×: the oak, the well, the props, the ground, the fields and the farmer.
   - **What it does to the scene:** the cabin's pixels and outlines are half the size of its neighbours'. Its detail is twice as fine, so it reads as a pasted-in higher-resolution picture, the same "patch" problem ChatGPT named at G1.
   - **At 720p:** nearest-neighbour sampling also draws its pixels as alternating 1- and 2-screen-px runs, which is likely to shimmer when the camera moves (stills can't show this).
   - **Why it ranks first:** this is the largest single source of incoherence, and no amount of roof polish can fix it. It is also the owner's open decision from D-013 (16, 32 or 64 px).
2. **Value hierarchy and focal point** (observed)
   - **The problem:** the cabin roof is the largest and darkest mass in the homestead frame, by day and at night. The ancient golden oak should be the landmark, but the roof competes with it and the cabin facade.
   - **Why the roof can't fix it alone:** C3 showed that a value lift on the roof can't solve this. It needs a deliberate scene value key: which masses are darkest, which lightest, and where the eye goes first.
3. **Ground noise and clutter** (observed)
   - **The problem:** the grass is a high-frequency speckle. Leaves, acorns, mushrooms and pebbles are scattered evenly over all of it.
   - **What it does to the scene:** there are no quiet areas for the structures to sit against. The dirt path's edges are soft and noisy, so the crossroads read weakly, and the farmer and interactables lose contrast against the ground (rubric: gameplay readability).
4. **Grounding and one light model** (observed for the cabin, the well and the props; *to verify* for the oak, orchard and dock)
   - **The problem:** the cabin's foundation meets the grass with no contact shadow or ground transition, and the props have inconsistent or missing contact shadows.
   - **To check:** whether cast shadows agree on one light direction across the cabin, the oak, the well and the trees, as `ART_005_STYLE_SPEC.md` §4 requires.
5. **Outline weight and colour** (observed)
   - **The problem:** the cabin's dark outline is 1 art px at 1.5 screen px, while the props and the oak have 3-screen-px outlines. Outline colours also differ: near-black on the cabin, warm dark brown on the props.
   - **Dependency:** this follows from issue 1, but it also needs its own rule.
6. **Palette temperature** (observed)
   - **The problem:** the cabin is a cool grey-brown, and its roof a desaturated plank-grey. The oak is saturated orange and the grass a mid-dark olive. The cabin reads as though it was painted under a different light from its surroundings.
7. **Farmer versus cabin proportion and detail** (observed in the harness)
   - **The problem:** the 16 px farmer stands beside a 32 px door and logs. The proportion is acceptable, but the farmer has a quarter of the detail per area of the building beside them.
   - **Why it matters:** the character is the one asset on screen all the time, so a detail gap here is more visible than one in the scenery.
8. **Fields, orchard, pond and dock, and road and gate** (*to verify*)
   - **Things to check:**
     - F2 furrow and soil-edge texture against the new ground;
     - orchard crown style against the oak;
     - the water and dock outline weight;
     - the road and gate against the cabin's material quality.
   - **How they will be ranked:** in step 1.

## Recommended order (each step zero-credit, non-production, and stopped for review)

### Step 1: whole-farm baseline capture and scorecard (no art change)

**Captures:** the existing harnesses (`art003_wide.gd`, W-4 + F2, `house=g7:c2`), at noon and R3-1 night, at real 720p and at 1080p integer:
- the full overview;
- the north (cabin, oak, well);
- the fields;
- the orchard, pond and dock;
- the road and gate;
- a farmer close-up beside the door.

**Also produced:**
- a greyscale value version of the overview;
- a short camera-pan GIF, to test the 1.5 px shimmer.

**Scoring:** the overview is scored with `ART_REVIEW_RUBRIC.md` for asset consistency, environmental richness, lighting and readability.

**Output:** a ranked and confirmed version of the list above, replacing every *to verify*.

### Step 2: density decision study

This is the gating owner decision, and the study only informs it. Two zero-credit variants of the C2 cabin go into the same W-4 frame:
- **(a) C2 reduced to 16 px per tile and hand-cleaned:** the same design, outlines and values. It matches the rest of the farm at native density.
- **(b) C2 at 32 px as it is today:** the control.

**Comparison:** at 720p, 1080p and in the pan GIF.

**Outcome:** if (a) is clearly more coherent, the farm stays at 16 px and the C2 design carries over. If (b) is preferred, the owner is choosing a full 32 px environment, which is a large production commitment and a `DESIGN.md` change. That cost would be estimated before anything is made.

### Step 3: scene value and colour key

This is a paint-over study on one captured frame, not a game change. It sets:
- the darkest and lightest masses;
- the oak as the focal point;
- the roof's place in the value order;
- a shared warm light for the cabin and its surroundings.

**Output:** a target key and a short list of per-asset value and hue moves for the cabin, ground and props. No lighting-system change.

### Step 4: ground calm-down and grounding, harness only

- Halve the scatter density near structures and paths, and cluster litter under trees and along edges.
- Give the path firmer edges.
- Give the cabin, well and props consistent contact shadows, all on one light direction.

These changes are tested in `art003_wide.gd`, never in the live farm.

### Step 5: consistency pass rules

This step writes, but does not apply:
- one outline rule (weight and colour per material);
- one shadow rule;
- one scatter rule.

These become the acceptance checklist for any later asset, paid or human-made.

### Step 6: decide what money or a human artist should buy

This happens only after steps 1–5. Possible answers:
- farmer detail;
- tile and ground art;
- final cabin finishing.

Each would get a cost estimate for the owner, and nothing would be bought without approval.

## Explicitly out of scope

- A farm-wide art overhaul.
- Production asset replacement.
- Live farm migration.
- New restoration stages.
- Removing an upgrade.
- Camera, scale or lighting changes.
- Save changes.
- Further farmhouse roof polishing (closed by C3).
- Any PixelLab or SpriteCook spend.

## Success criteria for the whole-farm effort

At real 720p, in one frame, and at both noon and R3-1 night, the homestead should meet all of these:
- it reads as one hand-made place: one pixel scale, one outline rule, one light;
- the golden oak and the cabin read as landmarks in that order;
- the farmer, the path and the interactables stay readable against the ground;
- no asset looks more or less finished than its neighbours.

These criteria are judged by the owner and ChatGPT on Godot captures, never on concept images.
