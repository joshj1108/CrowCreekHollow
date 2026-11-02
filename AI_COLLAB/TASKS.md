# Collaborative Tasks

| ID | Task | Owner | Reviewer | State | Approval gate |
| --- | --- | --- | --- | --- | --- |
| VIS-001 | Audit farm visuals, sprite consistency and current Godot lighting; propose a single-scene visual vertical slice | Claude Code | ChatGPT | proposed | Owner approves audit; separately approves implementation |
| COLLAB-001 | Establish shared collaboration notes and root instruction pointer | ChatGPT | Claude Code | review requested | Owner reviews/merges setup PR |

## VIS-001 — Scope and acceptance criteria
**Inputs:** `DESIGN.md` (especially locked art style), `CLAUDE.md`, farm scenes/scripts, `art/`, `shaders/`, current SpriteCook registry.

**Deliverables (audit only):**
1. Asset and perspective consistency report with concrete file paths and discrepancies.
2. Current-day/night, point lights, ambient tint, and shadow rendering inventory; identify existing systems before proposing replacements.
3. Feasible Godot-native lighting/atmosphere plan, with performance and tile-scale considerations.
4. A narrowly scoped, reversible first implementation proposal and screenshot comparison plan.
5. Questions or decisions needed from owner before editing production content.

**Must preserve:** Square 16px terrain grid displayed at 3×; fixed straight-on 3/4 top-down perspective; existing game behavior and saves. Do not treat concept mockups as pixel-perfect assets. Do not assume new visual mechanics are approved.

**Next step:** Owner explicitly greenlights audit, Claude investigates and posts findings in `MESSAGE_BOARD.md` or `AI_COLLAB/REVIEWS.md` if that file is added later.
