# ART-003 Round 2 scorecard

Scored with `ART_REVIEW_RUBRIC.md` (proposed). Two separate assessments are kept here and not averaged:

| Assessor | Basis | Total |
| --- | --- | --- |
| **Claude Code** (author of Round 2; provisional self-score, expect bias toward its own work) | The Round 2 master sheets, 2026-11-02 | **54.5 / 100** |
| **ChatGPT** (independent) | An image-level review of the Round 2 master sheets the owner attached in conversation; recorded on the board in ChatGPT's ART-004 entry (commit `0121d1d`). ChatGPT notes it is subjective, for the prototype with the night preview, and that performance and motion weren't verified. | **57.75 / 100** |

The owner's view, if given, goes beside them.

Revision 1 (2026-11-02): ChatGPT's score added; the earlier statement that no ChatGPT review of Round 2 was recorded is replaced, since ChatGPT did review the sheets at image level and the board now records it.

**Source:** `art/style_tests/ART-003/review/round2/ART-003R2_master.png` and `_master_2.png` (commit `6debb09`, captured in a clean checkout of `cf828c9`): concept vs Round 1 vs Round 2, 12:00 sunny and 21:30 with the lantern, 1280×720 shown at half size, plus full-size close-ups. Production reference: `art/style_tests/VIS-001/review/VIS-001_master.png` (a different spot on the farm, so not a matched comparison).

**What is scored:** Round 2 as presented — Round 2 art with the night preview. Where the result differs under the game's real night, it is noted.

**Limits:** the slice is a 30×18-tile patch built by a tool over the farm, not the live farm. The concept crops are fitted to the frame, not matched in scale or camera (`CONCEPT_FIDELITY_FEASIBILITY.md` systems 1–3). No performance was measured.

## Scores side by side

| Dimension | Weight | Claude Code | ChatGPT |
| --- | --- | --- | --- |
| Concept fidelity | 25% | 5 | 5.5 |
| Environmental richness | 20% | 5 | 5.5 |
| Lighting and atmosphere | 20% | 5 | 5.5 |
| Asset consistency | 15% | 6 | 6 |
| Gameplay readability | 10% | 7 | 7 |
| Technical quality | 10% | 6 | 6 |
| **Total** | | **54.5** | **57.75** |

Both put Round 2 below the provisional 65 band and agree on consistency, readability and technical quality; ChatGPT scores fidelity, richness and lighting half a point higher. ChatGPT's per-dimension evidence is in its board entry; Claude Code's is below.

## Claude Code's scores and evidence

| Dimension | Weight | Score | Evidence |
| --- | --- | --- | --- |
| Concept fidelity | 25% | **5** | [Judgement] The ingredients are right: a central sprawling oak with roots and a charm, a winding path, a fenced garden with lantern posts, red maples and firs framing it. Oak A's branching silhouette is close to image 02's ([Observed] close-up sheet). Against that: no house, well or other architecture in the frame; the stone ring reads as a regular henge (the concept's are scattered dark boulders); the crown is clipped flat; no fungus; the day is browner and dimmer than 02; and roughly half the frame is plain grass, where the concept has none. |
| Environmental richness | 20% | **5** | [Observed] Litter drifts, leaf/twig/acorn decals, a cobble landing, two raised beds with six crop types, and three forest layers were added over Round 1. [Judgement] Still short of the concept: the base grass repeats its speck in a grid; open grass dominates the centre; no ferns, logs, crossing roots, flowers, barrels or trellis; the undergrowth clump repeats. |
| Lighting and atmosphere | 20% | **5** | [Measured, diagnostic only: single unmatched whole frames, HUD hidden] Night preview mean luma 0.114 vs a concept 03 crop 0.200 (pixels above 0.12: 31% vs 69%); forest edges 0.058. Under the game's real night the same art reads 0.030 (4%), so this score depends on the preview treatment being carried forward. [Judgement] The preview reads blue-grey with warm pools, the right direction. Missing: the oak's warm rim, moonlight, fog in the corners, more warm points. Day: muted by the grade (saturation 0.62, exposure 0.84). |
| Asset consistency | 15% | **6** | [Observed] One PixelLab family on one forced 32-colour concept palette; it holds together by colour. [Judgement] Outlines are mixed: some assets selective, the farmer (SpriteCook) and the fence fully outlined. The flat, even stone ring doesn't match the oak's organic rendering. The prototype family as a whole doesn't match the production SpriteCook set (ART-001 finding), so it can't drop into the game as is. |
| Gameplay readability | 10% | **7** | [Observed] The farmer and path stay clear by day and in the preview night; the lantern pool is distinct. Crops read by type. [Judgement] Under the game's real night almost nothing outside the lantern reads. The foreground row at the bottom edge doesn't cover the player in this frame; it isn't tested with the player walking near it. |
| Technical quality | 10% | **6** | [Observed] Non-production and reversible: no live layout, saves, collisions or gameplay changed; `save_test.gd` passed after the separate trek compile fix. Defects: oak crown clipped by its canvas; baked grass disc at the ring's centre; blocky Wang path edges; a grass seam between cobbles and path; the second bed mostly off-screen. Not measured: frame time, draw calls. Nothing moves in the package, so shimmer or jitter is unchecked. |

**Weighted total:** 5×0.25 + 5×0.20 + 5×0.20 + 6×0.15 + 7×0.10 + 6×0.10 = 5.45 → **54.5 / 100**. (ChatGPT: 5.5×0.25 + 5.5×0.20 + 5.5×0.20 + 6×0.15 + 7×0.10 + 6×0.10 = 5.775 → 57.75.)

**Reading (provisional bands):** below 65, "reconsider the current approach for the weakest dimensions". That points at *how the slice is composed and lit*, not at abandoning Round 2: the three lowest dimensions are fidelity, richness and lighting, which Round 3 targets directly.

### For context (same rubric, same author, lower confidence)

| | Fidelity | Richness | Lighting | Consistency | Readability | Technical | Total |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Production farm (VIS-001 master) | 2 | 2 | 3 | 7 | 7 | 8 | **40.5** |
| ART-003 Round 1 | 4 | 4 | 3 | 6 | 6 | 6 | **45** |
| ART-003 Round 2 | 5 | 5 | 5 | 6 | 7 | 6 | **54.5** |

Production scores high on consistency and technical quality (one SpriteCook set, shipped and tested) and low on everything that compares it with the concept. Those two rows are rough: they are scored from existing sheets of different scenes, not matched captures.

## Gates

1. Rules (grid, camera, scale, view): ✓ unchanged.
2. Gameplay and saves: ✓ unchanged.
3. Tests: ✓ `save_test.gd` passed (ROUND2 board entry); menus not touched.
4. Evidence: partial. The master shows concept, Round 1 and Round 2, but **no matched production column** (the rubric asks for one). Round 3 adds it.
5. Compromises listed: ✗ not before this task; now in `CONCEPT_FIDELITY_FEASIBILITY.md`, all PROPOSED — NOT APPROVED.
6. Approval: ChatGPT's image-level review and score are recorded (`0121d1d`); owner approval pending. Round 2 is not proposed for production.

## Top three gaps (feed Round 3)

1. **Night is only right in a preview.** The next step is a slice-only night study judged by eye and by play checks (rendering, no art); production integration is a separate approval. Biggest score lever: lighting and readability at once.
2. **Oak and ring details.** Clipped crown, missing fungus and charms, henge-like ring. Art work with composition.
3. **The ground is still mostly flat grass.** Grass repetition, blocky path edges, open centre, missing ground cover. Art plus a scatter/variant renderer.

Next: `ART_003_ROUND3_PLAN.md`.

## R3-1 night experiment (added 2026-11-02)

Claude Code's provisional self-score for ART-003 R3-1 (Round 2's art under the refined slice-only night): **59.25 / 100** (fidelity 5.5, richness 5, lighting 6, consistency 6, readability 7.5, technical 7). Evidence and limits are in `art/style_tests/ART-003/ROUND3.md`. The art is unchanged from Round 2, so only lighting, readability and technical quality moved.

ChatGPT's independent R3-1 score, from its image-level review of the three R3 master sheets, as relayed by the owner on 2026-11-02 (the review is not yet a separate board entry): **61.5 / 100**. Kept separate, not averaged.

| Dimension | Weight | Claude Code (self) | ChatGPT |
| --- | --- | --- | --- |
| Concept fidelity | 25% | 5.5 | 6.0 |
| Environmental richness | 20% | 5 | 5.0 |
| Lighting and atmosphere | 20% | 6 | 6.5 |
| Asset consistency | 15% | 6 | 6.0 |
| Gameplay readability | 10% | 7.5 | 7.5 |
| Technical quality | 10% | 7 | 7.0 |
| **Total** | | **59.25** | **61.5** |

ChatGPT's conclusions, as relayed by the owner: R3-1 is the best night direction so far, preferred over production and Round 2, and the chosen variant over the cooler one. It is the non-production night baseline for the slice. The remaining gap to the concept is mainly art, composition and detail, not the night tint. P-1 (production integration) is not approved.

## R3 slice, R3-2 to R3-5 (added 2026-11-02)

Claude Code's provisional self-score for the refined slice under the locked R3-1 night: **62.5 / 100** (fidelity 6, richness 6, lighting 6, consistency 6, readability 7.5, technical 7). Evidence and limits are in `art/style_tests/ART-003/ROUND3S.md`. ChatGPT's independent score, from its four-sheet image review (board, commit `a3c47bb`): **63.0 / 100**. Kept separate, not averaged.

| Dimension | Weight | Claude Code (self) | ChatGPT |
| --- | --- | --- | --- |
| Concept fidelity | 25% | 6 | 6.0 |
| Environmental richness | 20% | 6 | 6.0 |
| Lighting and atmosphere | 20% | 6 | 6.5 |
| Asset consistency | 15% | 6 | 6.0 |
| Gameplay readability | 10% | 7.5 | 7.5 |
| Technical quality | 10% | 7 | 6.5 |
| **Total** | | **62.5** | **63.0** |

ChatGPT's conclusions, in short:
- Prefer oak D's structure, but its canopy is too sparse: plan a targeted foliage edit, not a reroll.
- Litter and grass detail are too evenly spread.
- The garden is now limited by composition and scale.
- The straight shade boundary must be fixed before visual approval.
- R3-1 stays the night baseline.
- Small forage and dark crops need more contrast.

Next step: a wider homestead composition plan (`AI_COLLAB/ART_003_WIDE_HOMESTEAD_PLAN.md`).

## Wider homestead W-1/W-2 (added 2026-11-03)

Claude Code's provisional self-score for the wider non-production prototype (existing art only, R3-1 night): **61.75 / 100** (fidelity 6.5, richness 5.5, lighting 6, consistency 5, readability 7.5, technical 7.5). Evidence and limits are in `art/style_tests/ART-003/WIDE.md`. No ChatGPT score for this pass is recorded yet.
