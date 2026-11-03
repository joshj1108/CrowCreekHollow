# Art review rubric

Task: ART-004 (proposed). Status: **proposed — not approved.** It adds a score to the visual review process; it replaces nothing in `VISUAL_REVIEW_PROTOCOL.md`, `README.md` or `DECISIONS.md`. A score is advice. The owner's approval gates still decide.

## When to score

Score every visual prototype or production candidate that goes out under `VISUAL_REVIEW_PROTOCOL.md` and is compared with the concept art (`art/reference/concept/`). Small fixes that don't change the look against the concept don't need a score.

The author (usually Claude Code) gives a **provisional self-score**. ChatGPT gives an **independent score** from the master PNG, recorded in its own board entry. The owner may score or simply decide. Report all of them; don't average them away.

## Dimensions and weights

| Dimension | Weight | What it asks |
| --- | --- | --- |
| Concept fidelity | 25% | Does the frame look like the matching concept image in composition, silhouettes, palette and mood? |
| Environmental richness | 20% | Is the ground and its edges covered with believable material, layers and detail, without repetition? |
| Lighting and atmosphere | 20% | Day warmth, night readability, warm points, fog and depth — against the concept, measured where possible |
| Asset consistency | 15% | Do all assets share one palette, outline rule, pixel scale, perspective and level of detail? |
| Gameplay readability | 10% | Can the player see the farmer, the path, crops, items, interactables and threats, day and night? |
| Technical quality | 10% | Clean pixels on the grid, no clipped canvases, baked backgrounds, seams, shimmer or repetition artefacts; measured performance; nothing broken |

**Score:** each dimension 0–10. Weighted total = Σ(score × weight) × 10, out of 100.

## Anchors

Use these to keep scores comparable between reviewers. Half points are fine.

| Score | Meaning |
| --- | --- |
| 0–2 | Missing or contradicts the concept |
| 3–4 | Present, but reads clearly unlike the concept or has major defects |
| 5–6 | Recognisably the concept's idea, with obvious gaps at game scale |
| 7–8 | Close at game scale; differences show mainly in close-ups or side by side |
| 9–10 | Hard to tell from the concept's intent at game scale; no defects found |

Per dimension, what pulls a score down:

- **Concept fidelity:** wrong silhouette or proportions on hero assets; wrong palette family; missing landmarks or storytelling detail the concept shows; a composition that reads as objects on empty ground.
- **Environmental richness:** visible tile repetition; bare grass at bases of objects; missing layers (canopy, understorey, ground cover, litter); flat paths and plots.
- **Lighting and atmosphere:** a night that fails the visual and play checks (play area unreadable, or so bright it stops being threatening); lights without warm rims; no depth falloff at forest edges; a day grade that hides the concept's warmth (or overshoots it). Brightness measurements inform this score; they don't set it.
- **Asset consistency:** mixed outline styles; mixed pixel scales; assets from different generators that read as different games; one asset noticeably more or less detailed than its neighbours.
- **Gameplay readability:** the farmer, path or interactables lost against the ground; foreground hiding the player; night too dark to see where to walk.
- **Technical quality:** clipped canvas edges; baked grass discs or backgrounds; seams; uneven pixel sizes; jitter or shimmer in motion; unmeasured performance claims.

## Interpretation (provisional)

| Total | Reading |
| --- | --- |
| 90–100 | Candidate for owner approval |
| 80–89 | Strong; targeted refinement needed |
| 65–79 | Promising prototype; more work needed |
| Below 65 | Reconsider the current approach for the weakest dimensions |

These bands are a starting point. The owner can move them after a few rounds. A high score never overrides an acceptance gate below.

## Acceptance gates (pass/fail, independent of the score)

A candidate can't be recommended for production unless every gate passes. Gate 2 depends on what kind of task it is.

1. **Rules.** Square 16 px grid, current camera and scale, and straight-on 3/4 view unchanged — or an owner-approved change to them is cited.
2. **Gameplay and saves.**
   - **Art-only tasks** (art, lighting, grade, atmosphere, composition, UI skin): no change to mechanics, collisions, movement, `darkness`, triggers, placement rules, progression or the save. An art-only task that turns out to need one stops and asks; it doesn't make the change.
   - **Tasks that include an explicitly approved gameplay change** (for example a layout migration or new landmark lights the owner has approved): the change is allowed only within the approval, which is cited by its `DECISIONS.md` entry or board entry. It must be behind a flag or otherwise reversible where practical, and tested on its own (gate 3) separately from the visual review. Its save effects are stated, and migrations are tested in slot 9 only.
   - Either way, slots 1–3 are never touched.
3. **Tests.** When code changed: `save_test.gd` and `menu_test.gd` pass on the working tree actually being shipped. For an approved gameplay change: also `balance_sim.gd` when anything timed, placed or progressed changed, and a save-migration case in `save_test.gd` when the save or layout changed. Visual approval doesn't stand in for these, and passing tests don't stand in for visual approval.
4. **Evidence.** A master PNG per `VISUAL_REVIEW_PROTOCOL.md`, with the columns below.
5. **Compromises.** Every visible departure from the concept is either fixed or listed in the compromise register (`CONCEPT_FIDELITY_FEASIBILITY.md`) with its status.
6. **Approval.** ChatGPT's review is recorded on the board (advice), and the owner has approved. Until then the state is *review requested*.

## Evidence standards

**Columns.** Every major proposal's master shows, side by side:
1. the concept crop that matches the scene;
2. the current production game (or, when production has no equivalent scene, the established prototype baseline — say which);
3. the proposal.

**Conditions.** Same scene, tile, hour, weather, season, house stage, lantern and canvas size wherever possible, all listed in the caption. Day and night when lighting can differ. At least one frame at **actual game scale** (1280×720 or the stated size, not enlarged), judged before any close-up.

**Settings to state.** Viewport and stretch; source dimensions and on-screen dimensions of new assets; grade and tint values used; light count and energies when lighting changed; the commit or flag for BEFORE and AFTER.

**Measurements.** Where they help: region luma readings for night, using matched captures and fixed masks (`CONCEPT_FIDELITY_FEASIBILITY.md`, "Night measurement method"); frame time and draw calls for density and lighting changes. Label them as measurements with their method. They are diagnostics: no number is an acceptance criterion on its own, and a change that improves a number but fails the visual or play checks fails.

**Play checks.** For lighting and density changes, test readability with the farmer moving (walk the path, find items and threats outside the lantern pool), not only in stills, and include a short motion clip.

**Honesty rules.**
- Say "matched" only when framing, scale and conditions match. Otherwise list the differences as limitations.
- The concept is a target, not evidence of what the game can do. Never put an AI-generated image where a Godot capture belongs.
- Label each claim as observed, measured, estimated or judgement.
- Never adjust the game to flatter a capture (`CLAUDE.md`).

## Scorecard template

```
### <TASK-ID> — <round> — scored by <who>, <date>, from <master file + commit>

| Dimension | Weight | Score | Evidence (observed / measured / judgement) |
| --- | --- | --- | --- |
| Concept fidelity | 25% | x | ... |
| Environmental richness | 20% | x | ... |
| Lighting and atmosphere | 20% | x | ... |
| Asset consistency | 15% | x | ... |
| Gameplay readability | 10% | x | ... |
| Technical quality | 10% | x | ... |
| **Total** | | **xx / 100** | |

Gates: 1 ✓/✗ · 2 ✓/✗ · 3 ✓/✗/n-a · 4 ✓/✗ · 5 ✓/✗ · 6 pending
Top three gaps: ...
```
