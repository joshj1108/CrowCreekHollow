# ART-005 E2 — Proposed artist test: directed 16 px vs 32 px (plan only)

Task: **ART-005, stage E2 — PLAN ONLY.** Owner: Claude Code. Reviewers: ChatGPT, then the owner.
Status: **proposal. Nothing is commissioned, generated or spent.** This plan does not authorise contacting artists, sharing project files outside the repo, or any payment. Each of those is a separate owner decision.

Labels: **[Proposal]**, **[Estimate]** (uncalibrated judgement), **[Unverified]** (market information not checked for this document).

## 1. Purpose

One professional pixel artist draws **the same small sample twice**, once at 16 px per tile (column A+) and once at 32 px (column B), from the same design sheet and palette. The goal is to measure, on real art rather than placeholders:

1. whether directed 16 px reaches the owner's professional bar, or whether 32 px is needed for it;
2. **actual hours per asset and per animation frame** at each density, to replace ART-005's estimates;
3. whether the style specification (`ART_005_STYLE_SPEC.md`) is workable for an artist, and what they change;
4. whether the source files, export and validation pipeline works end to end.

64 px is **deferred**. E1 found it can't be shown pixel-clean at 720p, costs 16× the texture memory, and has the highest cost per animation frame. It is reconsidered only if the 16 vs 32 result leaves a clear reason to (following ChatGPT's staged stop-loss review of `7bff20e`).

## 2. The sample (identical at both densities)

All pieces come from the E0 test composition (`art/style_tests/ART-005/e0/layout.txt`). They sit in the E1 harness at the same tiles, so they are reviewed in context, day and night, still and moving.

| # | Piece | Logical size | 16 px | 32 px | What it tests |
| --- | --- | --- | --- | --- | --- |
| S1 | **Farmhouse architectural corner**: the left third of the restored house, with roof eave and shingles, one window (plus its night state), plank wall, corner post, foundation stones, a porch step | about 4 × 6 tiles | ≈ 64×96 | ≈ 128×192 | materials, the light model, outline logic, emissive night state |
| S2 | **Ancient oak section**: the lower crown edge, trunk and root flare, contact shadow, a little leaf litter | about 5 × 6 tiles | ≈ 80×96 | ≈ 160×192 | organic clusters, foliage volume, bark |
| S3 | **Grass-to-path transition**: one dual-grid 16-piece path-over-grass set, plus 2 grass and 2 path fill variants and 3 decals | 16 pieces + 7 tiles | 16 px tiles | 32 px tiles | kit discipline, organic edges, repetition |
| S4 | **Player walk sample**: the farmer facing right, an 8-frame walk with the lantern's secondary motion, plus 1 idle frame | 1 × 2 tiles, 9 frames | 16×32 | 32×64 | proportions, animation quality, the hardest cost line |

Down and up walks, other tools and a whole house are **out of scope** for the test.

## 3. What the artist receives (identical for both densities)

- `ART_005_STYLE_SPEC.md` and `e0/design_sheet.png`: rules, ramps, light, proportions, value budget.
- `e0/palette.gpl` (load and lock in indexed mode). The artist may propose **one** retune of a ramp, recorded with the reason.
- `e0/composition.png` and crops of the existing W-3/W-4 house, oak and farmer **for design and layout only** (what the objects are, where the window sits). Their style is not the target.
- The engine conditions: 16×16 logical grid, tile = 64 screen px at 1080p (×4 / ×2), production night tint `3a3f6e` with warm lights `ffd38a`, key light upper-left.
- Quality benchmarks named by the owner (Eastward, Sea of Stars, Hyper Light Drifter) as **a bar for finish**. Brief wording: "no element, palette, character or composition from any existing game may be copied or closely imitated."
- The order to draw in (section 5).

## 4. Deliverables

- **Layered source files** per piece and density (Aseprite or another agreed layered tool), using the spec's layer names. Animation is tagged. Kit pieces are sliced.
- Flattened PNG exports and separate `*_shadow.png` layers, made with the scripted export (spec §11).
- A **time log** per piece and density, recording hours for design, line, colour, shading, AA and cleanup, animation and revision. A simple shared sheet is enough.
- A short note per density: what was hard, what the rules got wrong, what they would change.
- A rights statement: work made for hire, or an exclusive licence to the owner for commercial use in this game and its marketing; original work; no AI generation in the deliverables; nothing copied from third-party games. [Proposal; the owner should have the wording checked.]

## 5. Order and stop-loss gates

Cost-conscious order. Each gate is a point where the owner can stop and pay only for what was delivered.

| Step | Work | Gate after it |
| --- | --- | --- |
| G0 | Artist reads the brief and returns questions plus a **fixed quote** for each step | Owner accepts the quote |
| G1 | **S1 house corner at 16 px and at 32 px** (with night window) | In-harness review: does either meet the bar? Is the spec workable? Are the hours near estimate? **Stop here if neither density is close to the bar.** |
| G2 | S4 walk sample at both densities | Animation quality and frame cost: the main whole-game cost driver |
| G3 | S2 oak section and S3 transition set at both densities | Cohesion of the full sample |
| G4 | One revision round on the chosen density's notes | Final evaluation (section 7) |

To reduce bias, the artist draws S1 at 16 px first, then 32 px, and S4 at 32 px first, then 16 px. That way neither density always gets the benefit of a "second pass".

## 6. Cost

**[Estimate, uncalibrated]** From ART-005 §8, scaled to the sample (one experienced pixel artist, including cleanup, before revisions):

| Piece | 16 px (A+) | 32 px (B) |
| --- | --- | --- |
| Setup: read the spec, load the palette, ask questions | 1–2 | (shared) |
| S1 house corner | 2–4 | 5–9 |
| S2 oak section | 2–3 | 5–8 |
| S3 transition set | 3–5 | 7–12 |
| S4 walk sample (9 frames) | 3–5 | 8–14 |
| **Subtotal** | **11–19 h** | **25–43 h** |
| G4 revision round | +2–4 h | +4–8 h |

**Total about 42–74 artist hours** for both densities with one revision round.

- **Rates [Unverified]:** freelance pixel-art rates vary widely by experience and region. The owner should get **2–3 fixed quotes**, not rely on any figure here. As a planning illustration only, at USD 30–60/h the full test would be about USD 1,300–4,400. Stopping at G1 (S1 only, both densities) would be about 10–17 h, roughly USD 300–1,000 at the same rates.
- **Cheapest informative test:** G1 alone. It answers "can directed 16 px reach the bar?" and calibrates hours, before animation money is spent.
- My work (harness integration, validation, the review package) costs no artist money. It is about one session per gate.

## 7. Evaluation

### 7.1 Failure gates (any one fails a density, whatever the score)

From ChatGPT's review of `7bff20e`, plus the E1 findings:

1. **Mixels or resampling.** Validator `resampled ≠ no`, or mixed pixel sizes seen in the harness.
2. **Broken motion.** Foot sliding, volume popping, or outline shimmer in the walk sample at the integer smooth camera.
3. **Not reproducible.** The artist can't draw a second matching piece (S2 or S3) in the same hand as S1, judged side by side.
4. **Unaffordable.** The measured hours, extrapolated to the whole game (7.3), exceed the owner's budget.
5. **Night readability.** The value budget in spec §9 fails under the production night tint.
6. **Spec violations** the artist can't fix in the revision round: palette, alpha, outline thresholds (spec §11).

### 7.2 Score (trial weights from ART-005 §7.6; only for densities that pass 7.1)

| Dimension | Weight | How it is judged |
| --- | --- | --- |
| Craft (clusters, AA, materials) | 20% | 1:1 crops in the harness; validator numbers |
| Cohesion across house, oak, terrain, farmer | 20% | the four pieces together in the composition |
| Lighting and atmosphere, day and night | 15% | harness day/night, lantern walk |
| Motion | 15% | walk GIF at 50 fps and 144 Hz steps |
| Readability, day and night | 10% | the farmer and path against the ground, at 1080p and 720p |
| Mood fidelity to the concept (not pixel fidelity) | 10% | owner and ChatGPT |
| Scalability (hours × whole-game asset count) | 10% | 7.3 |

Placeholder columns are never scored. Column A is scored only as a reference baseline.

### 7.3 Whole-game extrapolation

Measured hours per unit × the game's counts (from ART-005 §8: 76 farm PNGs, 28 player sheets of 8 frames, 20 UI PNGs, plus the trek, cave, interior and walkers):

- environment: hours per tile-area of S1 and S2 × the farm's building and tree area;
- terrain: hours per kit (S3) × the number of materials and biomes;
- animation: hours per frame (S4) × all character frames.

The result is a range per density, which the owner compares against budget and schedule.

### 7.4 Records

Per density: actual hours per piece and in total, the number of revisions and what they were, palette changes, validator results, harness captures (the E1 package format with A, A+ and B side by side), the artist's notes, and a **production-suitability verdict**: could this artist, or another following the same spec, keep this quality across the whole game?

## 8. Owner decisions needed before E2 starts

1. Approve this plan's scope (S1–S4 at 16 and 32 px, 64 px deferred).
2. Choose how far to commit: **G1 only** (recommended first step) or G1–G4.
3. Set a budget ceiling, and authorise asking 2–3 artists for fixed quotes (who, and what may be shared with them).
4. Approve the rights terms (section 4) after checking them.
5. Confirm that no AI generation is used for any E2 deliverable.
