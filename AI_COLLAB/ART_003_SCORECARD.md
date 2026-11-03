# ART-003 Round 2 scorecard

Scored with `ART_REVIEW_RUBRIC.md` (proposed). **Provisional self-score by Claude Code, the author of Round 2**, 2026-11-02, so expect bias toward its own work. ChatGPT's independent score and the owner's view should be recorded beside it. No ChatGPT review of Round 2 is recorded on the board yet.

**Source:** `art/style_tests/ART-003/review/round2/ART-003R2_master.png` and `_master_2.png` (commit `6debb09`, captured in a clean checkout of `cf828c9`): concept vs Round 1 vs Round 2, 12:00 sunny and 21:30 with the lantern, 1280×720 shown at half size, plus full-size close-ups. Production reference: `art/style_tests/VIS-001/review/VIS-001_master.png` (a different spot on the farm, so not a matched comparison).

**What is scored:** Round 2 as presented — Round 2 art with the night preview. Where the result differs under the game's real night, it is noted.

**Limits:** the slice is a 30×18-tile patch built by a tool over the farm, not the live farm. The concept crops are fitted to the frame, not matched in scale or camera (`CONCEPT_FIDELITY_FEASIBILITY.md` systems 1–3). No performance was measured.

## Scores

| Dimension | Weight | Score | Evidence |
| --- | --- | --- | --- |
| Concept fidelity | 25% | **5** | [Judgement] The ingredients are right: a central sprawling oak with roots and a charm, a winding path, a fenced garden with lantern posts, red maples and firs framing it. Oak A's branching silhouette is close to image 02's ([Observed] close-up sheet). Against that: no house, well or other architecture in the frame; the stone ring reads as a regular henge (the concept's are scattered dark boulders); the crown is clipped flat; no fungus; the day is browner and dimmer than 02; and roughly half the frame is plain grass, where the concept has none. |
| Environmental richness | 20% | **5** | [Observed] Litter drifts, leaf/twig/acorn decals, a cobble landing, two raised beds with six crop types, and three forest layers were added over Round 1. [Judgement] Still short of the concept: the base grass repeats its speck in a grid; open grass dominates the centre; no ferns, logs, crossing roots, flowers, barrels or trellis; the undergrowth clump repeats. |
| Lighting and atmosphere | 20% | **5** | [Measured] Night preview mean luma 0.114 vs concept 0.200 (pixels above 0.12: 31% vs 69%); forest edges 0.058, so the edges stay threatening. Under the game's real night the same art measures 0.030 (4%), so this score depends entirely on adopting the preview. [Judgement] The preview reads blue-grey with warm pools, the right direction. Missing: the oak's warm rim, moonlight, fog in the corners, more warm points. Day: muted by the grade (saturation 0.62, exposure 0.84). |
| Asset consistency | 15% | **6** | [Observed] One PixelLab family on one forced 32-colour concept palette; it holds together by colour. [Judgement] Outlines are mixed: some assets selective, the farmer (SpriteCook) and the fence fully outlined. The flat, even stone ring doesn't match the oak's organic rendering. The prototype family as a whole doesn't match the production SpriteCook set (ART-001 finding), so it can't drop into the game as is. |
| Gameplay readability | 10% | **7** | [Observed] The farmer and path stay clear by day and in the preview night; the lantern pool is distinct. Crops read by type. [Judgement] Under the game's real night almost nothing outside the lantern reads. The foreground row at the bottom edge doesn't cover the player in this frame; it isn't tested with the player walking near it. |
| Technical quality | 10% | **6** | [Observed] Non-production and reversible: no live layout, saves, collisions or gameplay changed; `save_test.gd` passed after the separate trek compile fix. Defects: oak crown clipped by its canvas; baked grass disc at the ring's centre; blocky Wang path edges; a grass seam between cobbles and path; the second bed mostly off-screen. Not measured: frame time, draw calls. Nothing moves in the package, so shimmer or jitter is unchecked. |

**Weighted total:** 5×0.25 + 5×0.20 + 5×0.20 + 6×0.15 + 7×0.10 + 6×0.10 = 5.45 → **54.5 / 100**.

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
6. Approval: pending. Round 2 is not proposed for production.

## Top three gaps (feed Round 3)

1. **Night is only right in a preview.** Adopting it is rendering work in `main.gd` (no art). Biggest score lever: lighting and readability at once.
2. **Oak and ring details.** Clipped crown, missing fungus and charms, henge-like ring. Art work with composition.
3. **The ground is still mostly flat grass.** Grass repetition, blocky path edges, open centre, missing ground cover. Art plus a scatter/variant renderer.

Next: `ART_003_ROUND3_PLAN.md`.
