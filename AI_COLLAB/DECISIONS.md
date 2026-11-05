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

Still unapproved: production integration, the live layout, saves, camera, scaling, gameplay, locked `DESIGN.md` rules, P-1 and other night-lighting changes, farmhouse stages 0–2.
