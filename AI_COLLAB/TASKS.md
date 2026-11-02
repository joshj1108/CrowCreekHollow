# Collaborative Tasks

| ID | Task | Owner | Reviewer | State | Approval gate |
| --- | --- | --- | --- | --- | --- |
| VIS-001 | Audit farm visuals, sprite consistency and current Godot lighting; propose a single-scene visual vertical slice | Claude Code | ChatGPT | approved for implementation (owner 2026-11-01; audit in `AI_COLLAB/VIS-001_audit.md`) | Owner approves audit; separately approves implementation |
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

## VIS-001 implementation authorization — owner approved 2026-11-01
**Status:** Approved for implementation. **Owner:** Claude Code. **Reviewer:** ChatGPT. **Final acceptance:** project owner.

**Scope:** Implement all four numbered items in `VIS-001_audit.md` section 3, behind reversible `LIGHTING_V2` as scoped in section 4: weather-night tint L-1, stepped/pixel-aligned light falloff, intermediate dusk tint, and shifted house-window/porch spill. Preserve gameplay darkness/sanity, time triggers, number of lights, saves, camera and existing art assets.

**Other owner decisions:** After checking references, archive five unused pre-SpriteCook house tiles outside production art; do not delete. Retain present 1080p stretch scaling and oak/crop saturation. Obtain farmhouse stage/anchor close-ups before any artwork revisions; no art revisions authorized.

**Review gate:** Provide before/after screenshots of the full house (stages 2/3; hours 12, 19.5, 20.5, 22.5), rainy night, cave and trek lantern where feasible; note if test captures cannot be produced. Validate stepped falloff for visible banding and motion jitter. Run existing save and menu tests without touching real saves (slots 1–3). Report files changed, archive destination, screenshots, test outcomes, and commit SHA in `MESSAGE_BOARD.md`, then set status to `review requested`. No changes to gameplay or broad sprite overhaul without separate owner approval.
