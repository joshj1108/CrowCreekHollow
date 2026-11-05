# ART-005 H1: 32 px farmhouse art-direction brief and one controlled PixelLab Pro edit (proposal)

Status: **proposal only. No generation was run and no credits were spent.** The only PixelLab calls were free: `get_balance` (4,938 generations, USD 0, unchanged), `search_help` (the `edit_image` price) and two `get_pro_flash_capabilities` quotes. No production asset, farmhouse stage, camera, gameplay, save, `DESIGN.md`, night lighting or live layout was changed. ART-005 E0/E1, G1, M0/M1, W-4 and VIS-002 are untouched.

Answers: ChatGPT's four-sheet review (`b399b39`) and the owner's message after it. M0 is the accepted **non-production geometry baseline**. This brief says what the materials must look like on that geometry, and how one paid attempt would be run, measured and stopped.

Labels: **[Measured]** checked in the repo; **[Doc]** PixelLab documentation or its help agent; **[Quote]** a free PixelLab price quote taken today; **[Judgement]** my opinion, to be checked.

---

## 1. Art-direction brief (32 px per tile, shown at 1.5× in game)

The house is one object in a muted autumn homestead, lit from the upper left, seen straight-on in 3/4. It should read at game scale as **a big, quiet roof over a lived-in timber front**. Detail comes second; large value shapes come first.

### 1.1 Texture hierarchy and cluster sizes

Read order, strongest first: **door and windows → eave shadow line → roof planes → siding → foundation → ground**.

| Surface | Mark size (art px) | Value range inside a plane | Texture energy |
| --- | --- | --- | --- |
| Door, windows, trim | frames 3–4 px, mullions 2 px, glints 2–3 px | full ramp, the only place with the brightest and darkest steps together | highest (focal) |
| Roof planes | slate courses **16 px** tall; slates 10–24 px wide, staggered | 3 steps per plane plus the big gradient (§1.2) | medium-low: course lines carry it, no speckle |
| Siding | lap boards **12 px**; board ends every 48–120 px, never aligned in columns | 2–3 steps | medium-low |
| Foundation | stones 10–16 px wide × 6–9 px tall, irregular | 3 steps | medium |
| Chimney | stones 6–10 px (smaller: it is narrow) | 3 steps | medium |

- Clusters are at least 2 × 2 px. Single pixels only as deliberate glints or moss flecks, never as noise.
- No surface may repeat a recognisable motif inside 64 px horizontally. Variation comes from slate width, board-end spacing and weathering patches, not from noise.
- The roof must not be the noisiest surface. In M0 it is; this is the main correction [Measured in M0, Judgement].

### 1.2 Roof planes and courses

- **Plane shading:** the front plane gets a vertical value gradient across its 140 px: lighter near the ridge, one step darker in the bottom two courses where it nears the eave. The west hip is one step lighter than the front plane and the east hip one step darker, as flat planes with no gradient break.
- **Hip lines:** a lit 2 px hip-cap on the west hip and a dark one on the east. Courses meet the hip line at a mitre, not as horizontal stripes running through it.
- **Course variation:** each 16 px course has a 2–3 px shadow lip at its bottom edge. Slate widths vary from 10 to 24 px. One to three courses are slightly misaligned by 1 px over 20–40 px, so they read as hand-laid, not tiled.
- **Weathering:** two or three large, soft patches (≥ 24 px) of moss or darker wet slate, concentrated on the north/east side and below the chimney. Never a spread of single moss pixels.
- **Ridge:** a capped ridge line 8 px tall (y 12–20) with its own lit top edge, which strongly shapes the silhouette.

### 1.3 Timber and material readability

- **Siding:** horizontal lap boards, each with a lit top edge (1 px) and a shadow under the lap (1–2 px). Grain is a sparse, long streak (≥ 8 px), not stippling.
- **Weathering:** silver-grey at the top under the eave, warmer brown lower down, and darker within 10–12 px of the foundation (splash-back). One or two replaced boards in a slightly different value.
- **Trim:** door frame, window frames and corner posts read as **thicker, cleaner timber** than the siding: fewer marks and a higher value contrast.
- **Door:** vertical planks, a ledge and a darker recess at the top of the opening (the door sits back in its frame).

### 1.4 Facade balance (inside the fixed geometry)

The roof (y 12–160, 148 px) is taller than the wall (y 160–298, 138 px), and that cannot change. It is balanced with value, not geometry:
- **The roof is darker and lower in contrast than the wall.** The wall is the lightest large plane in the image.
- **A deep eave shadow:** 4–6 px of the darkest wall value directly under the fascia, fading over 8–10 px. This is the strongest horizontal line in the house and separates the roof from the facade.
- **The fascia** (y 148–160) is a solid, lit timber board, giving the roof a definite bottom edge.
- **The foundation** (y 280–298) is cooler and greyer than the timber, so the house sits on something.
- The windows and the door carry the warmest and brightest values, so the eye lands on the facade, not the roof.

### 1.5 Outlines and contact shadows

- **Selective outlines:** the silhouette is a dark outline, but it is one step lighter on the lit (top and west) edges and darkest at the bottom and on the east side. There are no outlines inside planes. Interior edges are drawn by value change, not by ink.
- **Contact shadows**, all drawn as values, never as a black line:
  - the chimney base on the roof: a flashing strip and a shadow down-slope on the east side;
  - under each window sill: 2–3 px;
  - inside the door opening, at the top and on the east jamb;
  - where the foundation meets the ground: 2 px darker.
- The ground shadow of the whole house stays in its own layer, generated by script (not part of the sprite).

### 1.6 Day and night

- **Day (the edit's only output):** warm, low, upper-left autumn light. The glass is dark blue-grey with 2–3 px glints. Nothing in the day art is lit from inside.
- **Night (free, from the same art):** the day art under the existing night grade, plus a separate **emissive layer** made by script from M0's glass mask (warm glass, mullions left dark), plus an optional emissive spill strip on the sill below each window. Night is never painted into the day sprite.
- **F1 is recorded, not fixed:** production `_build_window_lights` places the window lights 74 art px below the glass, at the wall base. Correcting that is a production lighting change and needs its own authorization. The harness uses the true window centres.

### 1.7 Roof, facade and chimney consistency

- One palette, one light direction and the same shading logic on every material: lit top edge, mid face, shadow under the lap or course.
- The chimney's stone matches the foundation's stone family (same hues, smaller stones), with a lit west face and a shaded east face, and a 2–3 px cap with an overhang shadow.
- The roof slate and the foundation stone are distinct: slate is cooler and flatter.

### 1.8 Porch and dormer (separate upgrades, not in this edit)

They stay independent, purchased layers. The paid edit renders the **base house only**. The dormer zone (x 94–290, y 59–127) stays plain shingle, with no baked porch.

When they are made later, each must:
- use the house's slate, fascia profile, timber and stone, made from the finished H1 house as the reference, so they share one hand;
- **porch:** a substantial entrance, not an awning. M0's proposed layer (F2): a shed roof y 164–200, 8 px posts with a base and a cap, clear of the door and windows by ≥ 16 px, a deck on the porch row, and a step aligned with the door at x 192;
- **dormer:** new geometry with windows at least 2/3 of the house windows (≈ 30 px, against today's 16 × 15), a real gable pitch, its own eave shadow, and a cheek-wall contact shadow on the roof;
- not move any base-house anchor;
- need an `estate_system.gd` change, which is not authorized.

### 1.9 Protected gameplay anchors (exact, from `m0/anchors.json`)

| Anchor | Value | Tolerance in the final file |
| --- | --- | --- |
| Silhouette below the eave (collision footprint) | x 16–368, wall y 160–298 | **exact** (alpha snapped to M0) |
| Door opening | x 173–211, y 224–298, centre x 192 | **exact** |
| Window glass | x 74–119 and 264–309, y 202–247 (centres 96.5 / 286.5, 224.5) | **exact** (they feed the emissive layer and lights) |
| Steps | x 160–224, y 298–320 | **exact** |
| Wall base | y 298 | **exact** |
| Eave line and fascia band | y 160; 148–160 | ±1 px |
| Ridge, hip corners, chimney | ridge y 12–20, x 64–320; chimney x 297–331, y 0–52 | ±2 px |
| Dormer zone, porch row | as above | must stay free of anything but shingle and steps |

---

## 2. The recommended paid experiment (not authorized)

One whole-house **`edit_image` (Pro) reference edit**, then at most two small masked repairs. Not separate pieces: one image, one hand, no assembly seams.

### 2.1 Operation and cost

| Item | Detail | Cost |
| --- | --- | --- |
| Operation | `edit_image` (Pro), **reference mode**: `images_base64=[input]`, `reference_image_base64=ref`, `width 384`, `height 320`, background follows the transparent input, one fixed recorded seed | **25 generations** [Doc: 10 up to 256², 15 up to 341², 25 above; the help agent confirmed 384 × 320 lands at 25. There is no free pre-quote for `edit_image`; the receipt states the exact charge] |
| Repairs (optional) | `inpaint_image_pro_flash` on crops of the edited house, mask white = regenerate, outside the mask byte-identical | **6** per crop up to 128 × 128, **9** at 256 × 160 [Quote, provisional] |
| Free steps | input preparation, reference crop, measurement, alpha snap, palette snap, emissive and shadow layers, harness captures, review package | 0 |

The account has 4,938 generations on Tier 2 (USD 0) [Measured, `get_balance`].

### 2.2 Inputs

1. **Image input: `m0/valuepass.png`** (free, to be scripted from the same `labels.png`; geometry identical to `blockout.png`). It is the flat blockout plus only the large-scale decisions of §1: the roof gradient, hip values, 1 px course lines every 16 px, the eave shadow band, wall weathering gradient, lap lines every 12 px, the foundation's stone outline and the contact-shadow shapes. **No micro texture.**
   - Why not the plain blockout: the edit keeps the input's composition and values [Doc]. A flat input leaves the large shading to chance, which is ChatGPT's main criticism; a value pass decides it in advance.
   - Why not the M0 mockup: it carries the tiled, mechanical texture the review rejected, and an edit would keep it.
2. **Reference: `m1/ref_house.png`**, a **64 × 64 crop of four material cells only** (slate, stone, timber, window) from the chosen anchor.
   - The full 96 × 96 board also holds red leaves, wheat, dirt and water, which could leak into the house.
   - **c1 or anchor_v2 is not decided.** As ChatGPT said, v2's cleaner metrics are not proof of better art. The free comparison already exists: the same house skinned with each (`32/house_day.png` = c1, `m0/house_day_v2mat.png` = v2; master 3). **My recommendation [Judgement]: the anchor_v2 crop**, because a generative edit tends to add detail, so c1's speckle would come back louder. Neither anchor is locked by this choice; it is used for one run.
3. **Description** (≤ 2,000 characters; final text logged in `pixellab-assets.json`). Draft:
   > Render this farmhouse as finished premium 32 px pixel art in the reference's materials. Keep every edge, line, opening and the silhouette exactly where they are. Straight-on 3/4 top-down view, light from upper left, muted autumn palette, dark selective outlines. Hipped slate roof with 16 px courses, staggered slates of varied width, a shadow lip under each course, lighter near the ridge and darker toward the eave, lit west hip, shaded east hip, a few large soft moss patches, no speckle. Horizontal 12 px lap siding, silver-grey under the eave and warmer brown below, long sparse grain. Deep shadow under the eave. Irregular stone foundation, matching stone chimney with a cap. Clean thick timber trim on the door and windows, dark glass with small glints. No porch, no dormer, nothing added.

### 2.3 Protecting and measuring the geometry

A Pro edit does **not** guarantee edges [Doc, help agent]. So protection is mostly done after the edit, by free scripts, and the result is measured, not assumed.

- **Before:** the value-pass input fixes every anchor and value decision. The dormer zone and porch row hold nothing to invent from.
- **After (free, scripted, all logged):**
  1. **Alpha snap:** the silhouette is replaced by M0's exact alpha, so collision, the overhang and the wall base are exact by construction.
  2. **Measurement** by a new `tools/art005_h1_measure.py` against `labels.png` and `anchors.json`:
     - the offset of every anchor edge in §1.9 (door, windows, steps, eave, fascia, ridge, hips, chimney), by edge detection along each anchor;
     - region overlap (IoU) per label;
     - the roof course period (autocorrelation, target 16 ± 2 px) and the lap period (12 ± 2 px);
     - texture repetition (the strongest self-match inside 64 px on the roof and wall);
     - format: colours, palette fit, orphans, partial alpha, resampling.
  3. **Exact anchors:**
     - if the door opening, glass and steps sit within 2 px, they are snapped back to M0's edges with a small, logged pixel repair;
     - between 2 and 4 px, by one masked Pro Flash repair (§2.4);
     - beyond 4 px, the stop rule applies (§2.5).
  4. **Palette snap** to the E0 palette and the emissive and shadow layers, as in G1.
- **Overlay sheet** in the review package: the edited house with every anchor line and the M0 outline drawn over it, plus a difference map against the value pass.

### 2.4 Limited repair plan and budget

- **Repairs fix local defects only, never overall quality.** Allowed:
  - an anchor that moved 2–4 px;
  - an invented object (a porch, dormer, lamp or extra window);
  - one broken area, such as the chimney base or a hip line.
- **At most two** `inpaint_image_pro_flash` crops. Reference = the edited house's own neighbouring area, so the repair matches the edit's hand. The pixels outside each mask are checked byte-identical.
- Any free pixel touch-ups are logged with their count. If they exceed **15% of the pixels**, the result is a fail, not a repair job.
- **Budget:** 25 (edit) + ≤ 2 × 9 (repairs) = **43 at most; hard cap 45.** No second full edit, no retry with the other reference, no stages, porch, dormer or well inside this cap.

### 2.5 Visual stop rule

**Stop 1: straight after the edit, before any repair (free checks).** No repairs are made, and the result goes to review as a failure, if **any** of these is true:

- **Geometry:** the door, a window or the silhouette moved more than 4 px, or an anchor is missing.
- **Roof:**
  - at 720p game scale it still reads as one repeated tile pattern;
  - or it has no visible ridge-to-eave gradient or hip planes;
  - or it is the noisiest surface in the frame.
- **Siding:** it reads as ruled lines with a uniform texture, with no weathering gradient or lap shadow.
- **Hierarchy:** the eave shadow does not separate the roof from the wall, or the windows and door are not the focal point.
- **Hand:** the materials do not look like one artist, or they do not look like the reference.
- **Format:** heavy anti-aliasing or resampling that a palette snap can't fix.

**Stop 2: after the repairs.** Owner and ChatGPT judge the house in the ART-005 harness, day and night, at 1080p and 720p, at 1:1, beside the M0 mockup. If it is **still below premium quality**:
- the PixelLab-only route for the house ends;
- no second edit, prompt variant or reference variant is run;
- the next decision is an artist-led finish: an artist paints over the M0 geometry, or the earlier artist test (ART-005 §E2).

This keeps the work from turning into a third cycle of small texture fixes.

If it passes, the next steps are proposed separately with their own caps: porch and dormer layers from the H1 house, stages 0–2, then the same-hand well test.

### 2.6 What the review package would contain

- matched captures of M0 (before) and H1 (after) in `tools/art005_density.gd` `art=g2` (day and night, 1080p and 720p);
- 1:1 and 4× crops of the roof, windows, door, chimney base and foundation;
- the anchor overlay and the measurement table;
- the input, the reference, the raw edit, each repair with its mask, and the final file;
- one master PNG in `art/style_tests/ART-005/pl/g3/review/`, per `VISUAL_REVIEW_PROTOCOL.md`.

## 3. Order of work if authorized

1. **Free prep:** write `valuepass.png` (extending `tools/art005_m0.py`; the other outputs unchanged, checked by hash) and both 64 × 64 reference crops; the owner and ChatGPT pick c1 or v2. Write `art005_h1_measure.py` and test it on the M0 mockup.
2. **One paid edit (25).** Record the receipt. Free checks → **Stop 1**.
3. **At most two repairs (≤ 18)**, then the free snaps and layers.
4. Review package → **Stop 2**, for the owner and ChatGPT.

Nothing is spent until the owner approves this plan, its 45-generation cap and the choice of reference.
