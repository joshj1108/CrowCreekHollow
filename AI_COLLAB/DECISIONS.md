# Design and Process Decisions

Record accepted owner decisions, with date/source; separate them from assistant suggestions.

## Confirmed
- **D-001 — Source of truth:** `DESIGN.md` remains the authoritative game design and locked art specification; this workspace does not replace it.
- **D-002 — AI ownership:** ChatGPT leads visual/game-design review; Claude Code leads technical/art implementation; both critique each other's work; the project owner has final approval.
- **D-003 — Review gates:** Major gameplay or visual-direction changes require owner approval; a technical implementation does not imply design acceptance.
- **D-004 — Camera/art foundation:** Maintain the game's existing straight-on 3/4 top-down square-grid design, not isometric. Follow the locked pixel scale and palette details in `DESIGN.md`.

## Proposed, not approved
- **P-001 — VIS-001:** Start with a read-only visual audit, then one reversible farm lighting vertical slice, using existing Godot facilities instead of wholesale sprite regeneration.
