# Design and Process Decisions

Record accepted owner decisions, with date/source; separate them from assistant suggestions.

## Confirmed
- **D-001 — Source of truth:** `DESIGN.md` remains the authoritative game design and locked art specification; this workspace does not replace it.
- **D-002 — AI ownership:** ChatGPT leads visual/game-design review; Claude Code leads technical/art implementation; both critique each other's work; the project owner has final approval.
- **D-003 — Review gates:** Major gameplay or visual-direction changes require owner approval; a technical implementation does not imply design acceptance.
- **D-004 — Camera/art foundation:** Maintain the game's existing straight-on 3/4 top-down square-grid design, not isometric. Follow the locked pixel scale and palette details in `DESIGN.md`.

## Proposed, not approved
- **P-001 — VIS-001:** Start with a read-only visual audit, then one reversible farm lighting vertical slice, using existing Godot facilities instead of wholesale sprite regeneration.
- **P-002 — ART-004:** `ART_DIRECTION.md` as a proposed art bible under `DESIGN.md`; `AI_COLLAB/ART_REVIEW_RUBRIC.md` for scoring; compromises C-01 to C-14 in `AI_COLLAB/CONCEPT_FIDELITY_FEASIBILITY.md`. None approved; the owner decides each.

## VIS-001 owner approvals — 2026-11-01
- **D-005 — Lighting:** Owner authorizes ALL FOUR changes proposed in `VIS-001_audit.md`: nighttime weather tint correction; pixel-stepped light falloff; three-color dusk; and window/porch light spill onto the ground. Implement as reversible `LIGHTING_V2`; final visual acceptance requires owner review. Preserve gameplay `darkness` and saves.
- **D-006 — Legacy house tiles:** Archive the five unused 64×64 pre-SpriteCook house/porch tiles outside production art after checking for indirect references. Do not delete.
- **D-007 — Pixel scaling:** Keep existing 1080p scaling/stretch behavior for now. No camera/stretch changes in VIS-001.
- **D-008 — Saturation:** Preserve saturated oaks and crops until visual comparisons are reviewed; do not recolor now.
- **D-009 — Farmhouse:** Compare close-ups of farmhouse stages against the locked style anchor before editing farmhouse assets. No automatic redraw or quantization.

These approvals supersede the pending status of the initial VIS-001 lighting proposal. Broader changes (occluder shadows, sprite regeneration, trek lighting overhaul, scaling changes) remain unapproved.

## ART-003 W-3 owner approvals — 2026-11-03
- **D-010 — House wall (prototype):** Wall variant **A** (warm weathered) is the restored-house palette for the non-production ART-003 prototype, as ChatGPT recommended after its image review (`cad881d`). Not a production or `DESIGN.md` change.
- **D-011 — Batch C:** The whole proposed non-production Batch C scope (orchard fruit trees, V3 crossroads, road arrival, worn path edges, garden → pond dressing, per `art/style_tests/ART-003/w3w/W3W.md`) is approved. Reuse first. PixelLab: 3 standard `create_image_pixflux` generations expected, **hard limit 5**; no Pro Flash, inpainting or other premium tools; one retry per asset, then stop and report. Review: Godot BEFORE/AFTER of V3, V4 and the arrival, day and R3-1 night, walking route, collision and performance checks, labelled master, then stop for review.
- **D-012 — Batch C baseline and W-4 (2026-11-04, after ChatGPT's WH review `6595947`):** Batch C is accepted as the preferred **non-production** homestead baseline, keeping wall A, G1, the golden oak, the four-bed garden, the improved pond and orchard, and R3-1 night; the 16×16 grid, camera scale and mechanics stay as they are. Authorized: **Task A** (prototype only, no PixelLab spend): a log pile hand-built from the PixelLab log art in place of the woodstore at V3 and both house wings; small manual orchard crown and harvest-dressing changes without regenerating the trees; the closed east gate and forest avenue as a reversible experiment that keeps the blocked boundary and implies no travel; the eastern forest margin fixed; tests at day and R3-1 night. **Task B**: a layout-parity, coordinate-mapping, save-preservation, migration/rollback, risk and phased-transition plan, **documentation only**. Not authorized: implementing the migration, production asset replacement, live farm changes, real saves, camera/scale, P-1, stages 0–2, `DESIGN.md`, new gameplay or travel. VIS-002 work and backups preserved.

## Art-direction owner decision — 2026-11-04
- **D-013 — Professional pixel art is the primary visual goal:** the game should reach the cohesion, environmental detail, animation and polish of premium commercial pixel-art games (Eastward, Sea of Stars, Hyper Light Drifter as quality references, not art to copy). The concept paintings are not to be reproduced pixel for pixel. Premium high-density pixel art is the leading candidate; the logical 16×16 farming and collision grid stays; 32 px and 64 px per tile are options to evaluate, not decisions. Unified handcrafted-looking art is preferred over mixed AI families. Warm autumn days and threatening nights are kept. HD-2D and illustrated 2D are secondary alternatives only. Immediate task: update `AI_COLLAB/VISUAL_PIPELINE_REASSESSMENT.md` and propose a non-production 16/32/64 px comparison (ART-005). **Not authorized:** production implementation, further PixelLab spending, changes to the locked `DESIGN.md` rules. Prototype, W-4 work, gameplay, saves and review history preserved.

Still unapproved: production integration, the live layout, saves, camera, scaling, gameplay, locked `DESIGN.md` rules, P-1 and other night-lighting changes, farmhouse stages 0–2.

## ART-005 S1 owner decisions — 2026-11-05
- **D-014 — Farmhouse direction (prototype only):** SA (simple side gable, one roofline) is the preferred structural baseline over M0, H1 and SB; log-cabin walls (stacked hewn logs, dark seams, notched corners, stone foundation and chimney) replace plank siding; four restoration stages keep the same roofline, footprint, door, windows and collision. Not a production asset or rendering spec.
- **D-015 — Structural expansions:** the farmhouse's look should no longer depend on the purchasable covered porch or second storey. Audit and a backward-compatible retirement plan only; no code removal, no save change.
- **D-016 — Layout and fields:** keep the ART-003 wider homestead (house and oak, well and crossroads, orchard, pond and dock, forest, paths, the road and the gate). Replace the raised garden boxes with small ground-level tilled fields in the same area; planning and non-production mockups only, no farming-system or live-layout change.
- **Next authorized task (2026-11-05):** a non-production design comparison (ART-005 S2) with no PixelLab spending, no purchases, no production, gameplay, save, camera, night-lighting or `DESIGN.md` change; commit the non-production work; stop for owner and ChatGPT image review.
- **D-017 — S2 accepted as the preferred non-production direction (2026-11-05, after ChatGPT's S2 review `6146d5b`):** SA simple side-gable farmhouse, rustic hand-hewn log exterior, four fixed-structure restoration stages, small ground-level fields in place of raised boxes, and the ART-003 W-4 homestead layout with the road and closed gate. Not final art and not authorization for production changes. **Next authorized task (ART-005 S3):** zero-generation roof material mockups (dark wood shakes vs dark blue-grey slate) with revised interlocking log corners; the stage 0 roof holes and the stage 1 night sign of habitation fixed in the schematics; minor field polish (furrows, soil edges) keeping lanes, fences, gates and collision; an updated production-feasibility plan. Zero PixelLab generations, zero paid SpriteCook calls; no production art, layout, gameplay, save, camera, lighting or `DESIGN.md` change; no upgrade removed; VIS-002 and earlier ART-003/ART-005 assets preserved.
- **D-018 — S3 owner approval and P1 authorization (2026-11-05, after the owner's review of the S3 masters, `e76198c`):** the approved **non-production visual baseline** is:
  - the SA simplified side-gable farmhouse with **Roof A, dark hand-laid wood shakes** (chosen over S2 slate and S3 quiet slate);
  - rustic horizontal hand-hewn logs and the S3 interlocking squared timber corners;
  - the existing stone foundation and chimney;
  - fixed central door and window positions, and the existing footprint and collision;
  - no structural change between stages.

  The S3 art is a structural and stylistic reference, not final art.
  - **Four stages, same house:** 0 Decrepit, 1 Boarded/Stabilized (with a subtle night sign of habitation), 2 Patched/Repaired, 3 Restored (warm night windows, flower boxes, firewood). Roofline, openings, footprint and collision are identical in all four. No production stage assets yet.
  - **Layout:** keep the ART-003 wider homestead with the road and the closed gate. No live-farm replacement, boundary-collision change or travel through the gate.
  - **Fields:** the ART-005 S3 **F2** ground-level fields are the preferred non-production farming-area baseline. They keep 112 plantable positions. The 105 → 112 crop map is a planning artifact only. **No save migration is authorized.**
  - **Porch and second storey:** they do not change the silhouette in the new direction. Their code, purchase ids, benefits, achievements and save data are kept, and the documented retirement and re-dressing plan stands. Gameplay, economy, UI or save changes need separate approval.
  - **Authorized:** one non-production PixelLab Pro `edit_image` of `pl/g6/shake/32/house_day.png`, at 384 × 320, expected and hard-capped at 25 generations. No USD, no second attempt, no inpainting, no reroll. Strict stop rule, and a full Godot review package. No SpriteCook paid operations.
  - **Not authorized:** production farmhouse, layout, crop or save migration, real saves, gameplay, `DESIGN.md`, camera or scaling, P-1, production stages.
- **P1 result (2026-11-05, for review; not a decision):**
  - The single edit was run and charged 25 (4,888 left, USD 0).
  - The openings and footprint held within 1 px.
  - The roof stayed a rectangle grid with pale blotches, and the fascia board became shake butts, so **the stop rule was triggered**. Nothing was rescued.
  - See `AI_COLLAB/ART_005_P1_RESULTS.md`. Awaiting the owner's and ChatGPT's image review.
