# Collaborative Tasks

| ID | Task | Owner | Reviewer | State | Approval gate |
| --- | --- | --- | --- | --- | --- |
| VIS-001 | Audit farm visuals, sprite consistency and current Godot lighting; propose a single-scene visual vertical slice | Claude Code | ChatGPT | review requested (implementation `cb2661b`, 2026-11-01; not visually accepted; audit in `AI_COLLAB/VIS-001_audit.md`) | Owner approves audit; separately approves implementation |
| COLLAB-001 | Establish shared collaboration notes and root instruction pointer | ChatGPT | Claude Code | review requested | Owner reviews/merges setup PR |
| ART-001 | PixelLab vs SpriteCook comparison (non-production) | Claude Code | ChatGPT | review requested (`e3bb50c`) | Owner chooses the asset pipeline |
| ART-002 | 16 px vs 32 px art density test (non-production) | Claude Code | ChatGPT | review requested (`f3da292`) | Owner decides on art density |
| ART-003 | Concept-to-game vertical slice and wider homestead prototype (non-production) | Claude Code | ChatGPT | Round 1 reviewed (changes requested); Round 2 reviewed (ChatGPT 57.75); R3-1 accepted as the slice's night baseline (ChatGPT 61.5); R3-2 to R3-5 reviewed (ChatGPT 63.0); wider prototype W-1/W-2 reviewed (ChatGPT 60.0); W-3 Batch A reviewed (ChatGPT 64.25); W-3 Batch B reviewed (ChatGPT 68.25); W-3 polish reviewed (ChatGPT 71.0); W-3 wall comparison image-reviewed (`cad881d`): ChatGPT recommends wall A, owner confirmation pending; Batch C proposed, ChatGPT recommends approval, owner has not approved; P-1 not approved. History below | Owner approves each batch and its credit limit; no production migration |
| ART-004 | Art direction, concept-fidelity feasibility, rubric, ART-003 scorecard and Round 3 plan (documents only) | Claude Code | ChatGPT | review requested | Owner approves each document and each compromise (all PROPOSED — NOT APPROVED) |

## ART-003 — W-3 history (all non-production, prototype only)
| Step | Commit | What it did | PixelLab | ChatGPT review |
| --- | --- | --- | --- | --- |
| W-3/W-4 art plan | `b2736ff` | Ranked plan: oak, pond, house, garden, orchard, arrival (`ART_003_W3_ART_PLAN.md`) | 0 | No separate score; each batch then authorized on its own |
| W-3 Batch A | `1a55ce9` | Oak canopy, pond shoreline and dock | 18 (forecast 4–8; two inpaints cost 12) | 64.25 (`f8c51f9`); oak and pond endorsed as candidates; shore buffer and route fix asked for |
| W-3 Batch B | `658fab8` | Restored-house candidates A–C, four-bed garden, grass G0–G2, Batch A follow-ups | 5 of a 12 cap | 68.25 (`77aa098`); house C and G1 preferred as prototype baselines |
| W-3 polish | `d88f210` | House C paint-over (roof, glass, porch, walls a/b/c), garden variation, G1 check | 0 | 71.0 (`dacdf09`); wall b too dark by day, compare a with b or a midpoint |
| W-3 wall comparison | `5ccbdf6` | Walls A/M/B in V1-B, V5 and an establishing view, day and R3-1 night; roof/chimney framing check; Batch C proposal | 0 | Image review (`cad881d`): A recommended as the non-production palette; no more generations on wall colour. Owner confirmation pending |
| W-3 Batch C | — | Orchard fruit trees, V3 crossroads, road arrival, worn paths, garden → pond (proposed in `art/style_tests/ART-003/w3w/W3W.md`) | Proposed: 3 expected, 5 hard limit, `create_image_pixflux` only | ChatGPT recommends the whole scope at this cap (`cad881d`). **Owner has not approved; nothing generated or placed** |

**Still unapproved:** Batch C, production integration of any ART-003 art, P-1 night lighting, farmhouse stages 0–2, gameplay changes, and any camera change (the roof/chimney framing limit is register entry C-14 in `CONCEPT_FIDELITY_FEASIBILITY.md`). Review masters stay where they were committed, under `art/style_tests/ART-003/*/review/`.

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
