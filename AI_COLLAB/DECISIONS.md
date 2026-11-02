# Design and Process Decisions

Record accepted owner decisions, with date/source; separate them from assistant suggestions.

## Confirmed
- **D-001 — Source of truth:** `DESIGN.md` remains the authoritative game design and locked art specification; this workspace does not replace it.
- **D-002 — AI ownership:** ChatGPT leads visual/game-design review; Claude Code leads technical/art implementation; both critique each other's work; the project owner has final approval.
- **D-003 — Review gates:** Major gameplay or visual-direction changes require owner approval; a technical implementation does not imply design acceptance.
- **D-004 — Camera/art foundation:** Maintain the game's existing straight-on 3/4 top-down square-grid design, not isometric. Follow the locked pixel scale and palette details in `DESIGN.md`.

## Proposed, not approved
- **P-001 — VIS-001:** Start with a read-only visual audit, then one reversible farm lighting vertical slice, using existing Godot facilities instead of wholesale sprite regeneration.

## VIS-001 owner approvals — 2026-11-01
- **D-005 — Lighting:** Owner authorizes ALL FOUR changes proposed in `VIS-001_audit.md`: nighttime weather tint correction; pixel-stepped light falloff; three-color dusk; and window/porch light spill onto the ground. Implement as reversible `LIGHTING_V2`; final visual acceptance requires owner review. Preserve gameplay `darkness` and saves.
- **D-006 — Legacy house tiles:** Archive the five unused 64×64 pre-SpriteCook house/porch tiles outside production art after checking for indirect references. Do not delete.
- **D-007 — Pixel scaling:** Keep existing 1080p scaling/stretch behavior for now. No camera/stretch changes in VIS-001.
- **D-008 — Saturation:** Preserve saturated oaks and crops until visual comparisons are reviewed; do not recolor now.
- **D-009 — Farmhouse:** Compare close-ups of farmhouse stages against the locked style anchor before editing farmhouse assets. No automatic redraw or quantization.

These approvals supersede the pending status of the initial VIS-001 lighting proposal. Broader changes (occluder shadows, sprite regeneration, trek lighting overhaul, scaling changes) remain unapproved.
