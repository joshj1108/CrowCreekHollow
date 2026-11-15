# Crow Creek Hollow — Prioritized Development Roadmap

> **Naming update (2026-11-14):** **Wicker Cove** is the official in-world name. Legacy `CCH-LOWMERE-*` task IDs and `LOWMERE_*` document paths are retained as stable project identifiers; they do not indicate a second town. All previous lore and design commitments are preserved.

**Master phase-by-phase pathway to 1.0:** [MASTER_ROADMAP_TO_1_0.md](MASTER_ROADMAP_TO_1_0.md). This document remains the detailed candidate backlog and history. Neither roadmap grants blanket implementation approval.

**Established:** 2026-11-14  
**Authority:** Owner and ChatGPT design direction. This file records plans; **it is not blanket implementation approval**. Claude implements only an explicitly owner-approved brief.  
**Companions:** `AI_COLLAB/TASKS.md`, `AI_COLLAB/MESSAGE_BOARD.md`, `AI_COLLAB/CCH_LOOP_001_IDLE_TIME_AUDIT.md`, `DESIGN.md`.

## Vision and scope guardrails

Crow Creek Hollow is a top-down 3/4 cozy folk-horror farming/survival game. **Homestead, mystery, and survival reinforce each other.** A thriving home is worth protecting; exploration reveals knowledge and useful resources; survival gives preparation and shelter meaning.

- **Balanced survival:** Hunger, Thirst, and Comfort matter initially; infrastructure progressively reduces routine maintenance rather than adding chores. Health means physical danger; Sanity means psychological pressure. Late-game wilderness remains risky.
- **Player agency:** Relaxed farmer, cautious survivor, explorer, and balanced player should each have meaningful progress. Quiet downtime is allowed; compulsory busywork is not.
- **Existing assets/systems first:** Prefer deeper use of the farm, cave, woodland edge, characters, production buildings, Diary, and weather over large new maps or feature sprawl.
- **Production baseline:** Preserve approved farmer, cave creature, farmhouse, HUD, menu, balanced night lighting, and outdoor mailbox art except for confirmed functional defects. Main menu remains static. Lantern upgrades increase light radius, not brightness.
- **Farmhouse:** Four restoration stages (Decrepit, Boarded, Patched, Restored), no new porch or second storey. Legacy extension sale/effects/achievements require separate save-safe retirement plan, not casual deletion.
- **Code and evidence:** Tests in scratch save profiles, playable Godot validation, measurement before rebalance, owner visual review where screenshots are requested. Never disturb uncommitted sunset experiment.

## Priority definitions

- **P0 — Essential/ship-blocking:** crashes, lost saves, permanent soft locks, inaccessible required progression, regression breaking the core playable build.
- **P1 — Core loop:** missing or weak experiences that materially prevent a satisfying, replayable everyday game.
- **P2 — Depth and variety:** enrich existing systems once core play is sound.
- **P3 — Optional expansion/polish:** longer-term additions, cosmetic polish, larger production investment.

## Status model

**Idea** (not designed), **Design** (owner + ChatGPT discussing), **Ready for approval** (scope/prototype spec complete), **Approved** (owner authorized implementation), **Implementing**, **Testing**, **Review** (results awaiting owner/ChatGPT acceptance), **Complete**, **Deferred**. Priority and status are independent. No approval by proximity in this table.

## Ordered backlog

| Order | ID | Priority | Task / deliverable | Status | Implementation gate / dependencies |
| --- | --- | --- | --- | --- | --- |
| 01 | CCH-EVENING-002 | P1 | Farmhouse-stage shelter protection, firewood-free Quiet Hour, clearer evening signs, week-one/long-term sanity simulation | Approved (brief supplied; **not verified implemented**) | Claude follows approved brief; owner reviews simulations and screenshots before accepting values. No broad content expansion |
| 02 | CCH-FOOD-001 | P1 | **Food economy + cooking design and audit:** classify existing foods/recipes, Hunger recovery, cost, resource availability, preservation/storage, meal roles, farming/fishing/animal links and winter needs; design practical and expedition recipes and identify imbalances | **Design — NEXT** | Owner + ChatGPT design first; Claude source audit/test brief only after separate approval. Do not add recipes or change balance before baseline metrics |
| 03 | CCH-SURVIVAL-001 | P1 | Balanced survival progression audit across four farmhouse stages: maintenance time and infrastructure benefits for Hunger, Thirst, Comfort, Health, Sanity | Design | Requires evening-balance results and food economy baseline; set and test progression targets, no extra meters |
| 04 | CCH-LOOP-002 | P1 | Afternoon choice prototype: small errands using existing characters/market/mail and small environmental discoveries on existing farm/woodland landmarks | Idea | Select 1–2 compact loops after food/survival design; use CCH-LOOP-001 baseline; require design and implementation approval |
| 05 | CCH-HOMESTEAD-001 | P1 | Domestic food production and preservation using existing kitchen/cellar/smokehouse/cooler, pantry-style convenient supplies, useful trek provisions | Idea | Depends on CCH-FOOD-001; improve utility without mandatory chores or automatic eating |
| 06 | CCH-PLAYTEST-001 | P1 | Human-playable vertical slice/retest: first 14 days with first harvest, trek, visitors, cozy evenings, trading and save-load; compare input-driven bots vs real player | Idea | Revalidate after key P1 changes; measure confusion, repetitive time, Sanity and reasons to keep playing |
| 07 | CCH-WINTER-001 | P2 | Winter-specific worthwhile work: selected fishing, processing, stored food, maintenance and seasonal encounters | Idea | After food and afternoon loops; avoid winter becoming a mandatory chore escalation |
| 08 | CCH-WORLD-001 | P2 | Living Hollow: rotating farm/woodland discoveries, revisitable location clues, mild world-state responses to actions and seasons | Idea | Gate story spoilers and persistence; start with one existing landmark, reuse systems |
| 09 | CCH-PEOPLE-001 | P2 | Relationship-follow-up and optional same-day requests using the existing four walkers, stand and mailbox | Idea | Coordinate with afternoon errands to avoid duplicate quest systems |
| 10 | CCH-FISH-001 | P2 | Make fishing useful in meals, occasional requests, winter and seasonal collections | Idea | Depends on food economy; don't default to blanket sale-price buffs |
| 11 | CCH-HERBAL-001 | P2 | Limited herbalism/remedies from existing forage for healing, warmth, and expedition preparedness | Idea | Prefer small meaningful recipe set; no new survival bars |
| 12 | CCH-ANIMALS-001 | P2 | Small livestock behavior/personality and occasional weather/night reactions | Idea | After core animal interactions confirmed in actual gameplay |
| 13 | CCH-TREK-002 | P2 | Compact solo woodland-edge forays using existing trek environments with different risk/reward from accompanied treks | Idea | Must not obsolete walker relationships or major treks |
| 14 | CCH-PROGRESSION-002 | P2 | Mid/late-game milestone pacing, stronger non-trek progress paths for homesteaders, meaningful upgrade acknowledgments | Idea | Revisit 55-day simulated relaxed-farmer progress gap; benchmark first |
| 15 | CCH-LEGACY-001 | P2 | Retire active covered-porch and second-storey purchase options safely; preserve existing saves, owner bonuses, and published achievement behavior | Ready for approval (D-015 plan already noted in repair report) | Requires separate owner approval before code changes |
| 16 | CCH-QOL-001 | P2 | Reduce tedious gathering/felling and friction through earned infrastructure rather than simply lowering every material cost | Idea | Measure true player time and wood demand first; balance approval required |
| 17 | CCH-FESTIVAL-001 | P3 | Small seasonal community traditions using existing world/characters; only after basic seasonal loop is rewarding | Idea | Avoid building an entire town/map |
| 18 | CCH-ENDGAME-001 | P3 | Long-term homestead mastery, optional neighbor/community projects, meaningful coin sinks after house restoration | Idea | Must preserve existing endings and story canon |
| 19 | CCH-CUSTOM-001 | P3 | Optional homestead decoration/individuality beyond existing purchased furniture | Idea | Save-compatible; no broad visual overhaul |
| 20 | CCH-POLISH-001 | P3 | Non-blocking visual/audio/animation polish and quality-of-life details identified by human playtests | Deferred | Only after user confirms actual priority |

## Next design brief: CCH-FOOD-001 (no implementation permission)

**Goal:** Every meaningful food source should have a role without making daily meals a chore. Develop an explicit food ladder:

1. **Daily staples:** Cheap, readily accessible meals or forage that reliably solve routine Hunger.
2. **Prepared household meals:** More efficient use of crops, animal goods, fish and cooking infrastructure; modest Comfort/Health/Sanity relevance where appropriate.
3. **Expedition provisions:** Portable, resource-efficient meals with bounded temporary effects that help trek/cave preparation; not obligatory buffs.
4. **Seasonal preservation:** Use existing cellar, cooler, smokehouse and cooking to convert abundance into winter security.
5. **Trade and relationship demand:** Selected dishes/ingredients enable market demand or optional character requests; prevent one food from dominating every choice.

**Design questions to settle:** food consumption cadence; meaningful Hunger restoration vs temporary effects; recipe/material and price economy; early access to cooking; food spoilage/stacking complexity; fishing/animal integration; role of warm meals in Comfort/Sanity; winter shortage pressure; accessibility for non-farming explorers; pantry convenience without automation.

**Evidence to request later from Claude:** current foods/recipes and actual code effects; source availability by season; crop/fish/animal output; coins and time cost per Hunger restored; food versus tool/infrastructure progression; 14-/60-/400-day simulated diets; early-, mid-, late-game bottlenecks; a small candidate recipe matrix. **Audit first; implementation only after owner approval.**

## Release gates and operating process

1. Owner + ChatGPT define purpose, success criteria, complexity, and design constraints.
2. Claude audits current code/measurements when required (separate approved audit brief).
3. Owner approves exact implementation scope.
4. Claude implements minimal vertical slice, documents files and tests, pushes commits, posts to message board.
5. ChatGPT reviews metrics and supplied images; owner accepts, requests adjustments, or defers.
6. On acceptance, update this roadmap and `TASKS.md`. Re-rank as results change; never silently mark an idea as approved.

**Immediate next conversation:** develop CCH-FOOD-001's roles, recipe principles, and food economy rules; do not send Claude an implementation prompt until requested.


## 2026-11-14 — New strategic direction: Wicker Cove, orders, and mastery (exploratory, NOT approved for implementation)

**Design north star:** Stardew Valley's self-directed farming and coziness; We Harvest Shadows' slow-burn farm unease; DREDGE's night-risk/psychological atmosphere; classic RuneScape's interconnected skill mastery; Molehill Empire's customer produce orders and town trade. Borrow design principles, not exact content, assets, story or mechanics.

**Wicker Cove:** Candidate accessible town connected to the existing gate, marketplace, merchant orders and residents. Its geography, lore, NPC roster, relationship to Crow Creek Hollow and unlock timing are **not yet canon**; reconcile with existing story/treks before approving. Town should feel lived-in and safe by day, subtly unsettling through clues and local history. Keep farm the emotional and functional home; preserve old saves, routes and landmarks.

| Relative priority | Proposed ID | Workstream | State | Prototype gate |
| --- | --- | --- | --- | --- |
| **P1, next alongside CCH-FOOD-001 design** | CCH-ORDERS-001 | Molehill Empire-inspired **optional home dispatch orders** at market stand/mailbox: simple produce/fish/food requests, partial delivery, accepted/declined/delayed choices, reasonable availability, predictable rewards and bounded rotating demand. Audit existing trade/inventory/economy and avoid a second parallel quest system | **Design — no implementation authorized** | First prototype entirely at existing farm stand with 2–3 request templates and no town art or new map |
| **P1, after economy audit** | CCH-SKILLS-001 | RuneScape-inspired **interlocking progression**: audit actual skill XP, level caps and unlocks; create clear novice-to-master capability ladders and meaningful cross-skill production chains without gratuitous level-99 grind | **Design — no implementation authorized** | Preserve existing skill saves and levels; prototype tangible Farming + Cooking/Trading synergies; separate owner approval for any XP rebalancing |
| **P2 (could rise after order prototype)** | CCH-LOWMERE-001 | **Town feasibility + narrative/technical blueprint**, then a compact accessible Wicker Cove vertical slice: marketplace, general store, limited NPC routines, one meaningful reason to visit, existing road/gate linkage, weather/time, save-safe scene transfer | **Idea — no implementation authorized** | First audit canon, route, map scale/performance, NPC dialogue, save migration and whether fast travel/dispatch is needed; no expansive town or new multiplayer |
| P2 | CCH-LOWMERE-002 | Town relationships, local business contracts, mysteries tied to existing Hollow story; distinct daytime comfort versus night unease | Idea | Depends on validated Wicker Cove slice; no lore rewrites without story review |

**Integration:** CCH-FOOD-001 designs cooked foods and crop value; CCH-ORDERS-001 creates demand for that production; CCH-SKILLS-001 gives mastery unlocks; CCH-LOWMERE-001 provides an optional place to deliver, meet people and follow mysteries; CCH-WORLD-001 ties environmental discoveries back to known landmarks and characters. Avoid duplicating CCH-LOOP-002 afternoon errands or CCH-PEOPLE-001 relationships: those should share a single request/relationship framework.

**Decision process:** (1) research and audit existing code/canon, (2) prototype orders **without** building a town, (3) measure trade economics and whether orders are fun, (4) design Wicker Cove's footprint, story identity and access, (5) prototype one town block only after explicit owner approval. No prompt to Claude has been authorized by this entry.


## 2026-11-14 — Owner-set Wicker Cove canon: fogbound failing seaside fishing village

**Owner's geographical/atmospheric decision — use as design canon, NOT automatic authorization to implement:**

- **Wicker Cove** is a **dreary, economically failing seaside fishing village**, situated **down the mountain road from Crow Creek Hollow**.
- **Crow Creek Hollow Farm** is the **last homestead / closest settled point to Wicker Cove before the mountain woods begin**; this is why **wilderness treks start at the farm**.
- A **dense bank of fog envelops Wicker Cove continuously, 24/7**. From the farm's mountain vantage point the road and town could otherwise be visible, but the permanent fog bank conceals the village/coast below.
- The existing farm gate and road should stay in place; a future town approach and traversal must respect the established landscape rather than require wholesale farm remapping.
- Town atmosphere: failing fishing livelihoods, worn coastal infrastructure, trade dependency, fogbound isolation. Avoid describing Wicker Cove as a cheery bustling market town.

**Optional, not yet canon:** the source of permanent fog, supernatural versus meteorological interpretation, precise road length and route, harbor layout, shop/NPC roster, precise visibility from specific viewpoints, ferry or sea travel, town-access milestones, and all special events. Keep these open for owner + ChatGPT story/gameplay design.

**High-leverage integration:** the farm supplies inland produce, wood, preserved goods and cooked provisions to a stressed fishing village; Wicker Cove may supply fish and coastal goods. Orders should feel like local needs, not just random generic delivery targets. The town can support atmospheric contrasts: farm as last refuge before wilderness, coastal village as civilization that is itself failing. Treks remain staged at the farm. The permanent fog must look and behave as a geographic landmark without indiscriminately darkening the entire farm or changing approved balanced lighting.

**Next design task:** combine CCH-FOOD-001 and CCH-ORDERS-001 into an *economy design exercise*, then determine the smallest viable Wicker Cove town slice and its relationship to the road. Still no code implementation authorization.


## 2026-11-14 — Wicker Cove first-district design draft

A concrete **design-only** first district, farm-to-town exchange, order categories, first-visit storyboard, dependencies and unresolved decisions is now stored at [`AI_COLLAB/LOWMERE_FIRST_DISTRICT_DESIGN.md`](LOWMERE_FIRST_DISTRICT_DESIGN.md). This refines CCH-LOWMERE-001 and CCH-ORDERS-001 without authorizing construction. Recommended sequence: CCH-FOOD-001 economy audit/design → CCH-ORDERS-001 farm dispatch prototype → CCH-SKILLS-001 interlocking skill progression audit → CCH-LOWMERE-001 small town district feasibility/prototype. Existing town-vote lore and farm-stage trek logic must be preserved.


## 2026-11-14 — Town-owner construction and inn room-design candidates

User selected two new gameplay directions (design only, no code approved):

| ID | Priority | Feature | Status | Implementation dependency |
| --- | --- | --- | --- | --- |
| CCH-LOWMERE-BUILD-001 | **P2** | Help owners visibly repair and improve the inn, general store, fish market and docks through optional labor/material contracts, with meaningful coins/skill progress, service upgrades and owner goodwill | Design | Verify actual Construction or related skill in code; needs CCH-LOWMERE-001 town prototype and CCH-ORDERS-001 shared contract engine |
| CCH-INN-001 | **P2** | Original, client-briefed themed guest-room design inspired by Animal Crossing 3.0 resort hotel / Happy Home Paradise: one-room editor, furniture arrangement, objective constraints and persistent room layouts | Design | Requires inn scene, furnishings/save infrastructure and one structural repair; prototype one room before multiple room/guest expansion |

**Design spec and proposed one-room vertical slice:** [Wicker Cove First District Design](LOWMERE_FIRST_DISTRICT_DESIGN.md). Restore a room first, furnish second; no new mandatory currency, no copying branded room/UI themes. A repair should benefit town economy and gameplay, not simply recolor a building. Keep perpetual fog and village's decline.

**Sequence revision:** Food/Orders audit → minimal Wicker Cove district and owners → one inn repair contract → one themed guest room → only then expand building renovations/guest demand based on testing. Existing CCH-EVENING-002 remains first gameplay review gate.


## 2026-11-14 — Proposed skill pruning and sea routes

**Skill roster:** [Skill Roster and Maritime Design](SKILL_ROSTER_AND_MARITIME_DESIGN.md) defines CCH-SKILLS-REVIEW-001 (**P1, Design**) to audit Cleaning and Forestry redundancy, preserve their abilities through any safe reallocation, and decide the final skill list before expanding mastery. This supersedes the earlier design assumption that all existing ten skills must remain; no code or save changes are approved.

**Wicker Cove maritime backlog:** CCH-MARITIME-001 (**P2, Design**) NPC crew fishing trips; CCH-MARITIME-002 (**P2, Idea**) discoverable fishing grounds; CCH-COASTAL-TRADE-001 (**P2/P3, Idea**) trade voyages to off-map coastal villages; CCH-SEAMANSHIP-001 (**P3/conditional, Idea**) potential maritime skill only if repeatable gameplay warrants; CCH-MARITIME-MYSTERY-001 (**P3, Idea**) optional fogbound maritime discoveries. Must first establish Wicker Cove harbor and one playable short trip, with no obligation to implement open sea/other cities in 1.0.


## 2026-11-14 — New Wicker Cove cast design and task IDs

See [LOWMERE_RESIDENTS_DESIGN.md](LOWMERE_RESIDENTS_DESIGN.md). **CCH-LOWMERE-PEOPLE-001A** (P1, Design): first reconcile existing characters, relationship flags and endings with proposed Wicker Cove residents. **001B** (P2, Idea): playable Edith plus one merchant, a few lines and requests. **CCH-LOWMERE-PEOPLE-002** (P2, Idea): one owner arc and restoration acknowledgment. **CCH-INN-GUESTS-001** (P2, Idea): distinctive hotel guest briefs. **CCH-FISHERMEN-001** (P2, Idea): fisher crew/market NPC handoff before boat prototype. **CCH-LOWMERE-RUMORS-001** (P2/P3, Idea): story-safe town rumors. **CCH-LOWMERE-SCHEDULES-001** (P3, Idea): local workday behavior. New character names and arcs are proposals, not canon or coding authorization.


## 2026-11-14 — Harbor economy and history planning tasks

[LOWMERE_ECONOMY_HISTORY_DESIGN.md](LOWMERE_ECONOMY_HISTORY_DESIGN.md) explores the fishing-village decline while preserving the existing Rook, town-vote, vicar and postman timelines. Tasks: **CCH-LOWMERE-ECON-001 P1 Design** (history compatibility and economy audit); **CCH-LOWMERE-ECON-002 P2 Idea** (visible local decline and upgrades); **CCH-FISHERY-001 P2 Idea** (fishing and processing supply); **CCH-HARBOR-REPAIR-001 P2 Idea** (pier repair as future boat access gate); **CCH-LOWMERE-TRADE-001 P2 Idea** (farm-town/coastal exchange); **CCH-LOWMERE-HISTORY-001 P2 Idea** (restrained story-safe village history); **CCH-LOWMERE-RECOVERY-001 P3 Idea** (small atmosphere improvements). Fog's origin and historic start are OPEN. No implementation approval.

## 2026-11-14 — Wicker Cove fog-memory canon and tasks

**Approved narrative direction:** the 24/7 Wicker Cove fog has a contradictory/uncertain past. Some locals remember clear sea views; others insist it has always been present. Documents can disagree. Neither chronology nor cause nor relation to the Hollow/bell is determined. This **supersedes** prior suggestion that a single answer to 'when did the fog arrive?' should be chosen now.

- **CCH-LOWMERE-FOG-001 P1 Design:** reconcile testimony chronology, existing characters, Agnes's 30-year history and the mill vote; define clue ambiguity rules and a contradiction matrix.
- **CCH-LOWMERE-FOG-002 P2 Idea:** optional witness-record-landmark mini-chain through existing dialogue and diary after town exists.
- **CCH-LOWMERE-FOG-003 P2 Idea:** permanent legible fog system, rain/season separation, future voyage visibility.
Full details: [LOWMERE_ECONOMY_HISTORY_DESIGN.md](LOWMERE_ECONOMY_HISTORY_DESIGN.md). No implementation approval.

 
## 2026-11-14 — Coastal setting and voyage design candidates

[LOWMERE_COASTAL_WORLD_DESIGN.md](LOWMERE_COASTAL_WORLD_DESIGN.md) (design-only) expands geography/mood from Wicker Cove harbor into a possible breakwater, tide pools, nearshore shoals and off-map coastal trade; none of these place names are canon. Preserve permanent fog and contradictory unconfirmed origins, main Hollow story, and optional nonpunitive voyages. Added **CCH-COAST-WORLD-001 P1 design prerequisite**, **CCH-COAST-SHORE-001 P2**, **CCH-COAST-VOYAGE-001 P2**, **CCH-COAST-GROUNDS-001 P2**, **CCH-COAST-RHYTHMS-001 P2/P3**, **CCH-COAST-CHARTS-001 P2/P3**, **CCH-COAST-ROUTES-001 P3**, **CCH-COAST-DEEPWATER-001 P3 stretch**. Cross-reference maritime/fishery/fog tasks; avoid overlapping tickets. No code authorization.


## 2026-11-14 — Start-to-finish creative blueprint

[CREATIVE_BLUEPRINT_START_TO_FINISH.md](CREATIVE_BLUEPRINT_START_TO_FINISH.md) is the current **creative north star** from first input through full-year play, original second-year story/endings and life afterward. It divides the game into intertwined Homestead / Community / Mystery paths and explicitly separates existing canon, owner-design direction and speculative expansion. Use this document before accepting newly proposed features; preserve the P0–P3 priority/status and approval process here. No blanket implementation permission.


## 2026-11-14 — New defining pillar: living choose-your-own-adventure

Owner wants meaningful branching choices **throughout the playthrough** with no right/wrong way to play, and optional hidden D&D-style rolls for uncertain outcomes. The decisions must affect relationships, livelihood, project order, discovery, town service and narrative callbacks. Avoid arbitrary binary checks, softlocks and required 'correct' dialogue. Keep existing 17 chapters / three endings structurally intact unless owner separately authorizes changes.

Full design: [CHOICE_CONSEQUENCE_SYSTEM_DESIGN.md](CHOICE_CONSEQUENCE_SYSTEM_DESIGN.md). Queue: **CCH-CHOICE-001A P1 Design** (actual branch/flag/save audit), **CCH-CHOICE-001B P1 Design** (hidden roll difficulty/skill/agency rules), **CCH-CHOICE-001C P1 candidate** (three choices and one delayed callback on existing farm; not authorized), **CCH-CHOICE-QA-001 P1** (branch/save/reload/endings regression), **CCH-CHOICE-LOWMERE-001 P2** (resident dilemma after town), **CCH-CHOICE-MARITIME-001 P3 conditional** (onboard navigation/crew decisions after voyages exist). The proposed d20 mechanics are illustrative, not preapproved formula.


## 2026-11-14 — Season-spanning choice arcs and player life identity

[PLAYER_PATHS_AND_CONSEQUENCE_WEAVE.md](PLAYER_PATHS_AND_CONSEQUENCE_WEAVE.md) outlines meaningful player-authored paths without classes, moral alignment or random critical story gates. CCH-CHOICE-PATHS-001 P1 design completed as concept; CCH-CHOICE-PATHS-002 P1 design proposed (current first-week choice audit); CCH-CHOICE-PERSIST-001 P1 design/QA; CCH-CHOICE-WINTER-001 P2 (winter supply tradeoff), CCH-CHOICE-TOWN-001 P2 (what to repair first), CCH-CHOICE-FOG-001 P2 (testimony responses), CCH-CHOICE-LIFE-001 P2/P3 (diary reflections and season callbacks). **Design only; not approved game content.**


## 2026-11-14 — Resident arcs and personalized life diary

Detailed **design-only** specification: [BRANCHING_RESIDENT_ARCS_AND_PLAYER_DIARY.md](BRANCHING_RESIDENT_ARCS_AND_PLAYER_DIARY.md). Existing `FolkSystem` walker scenes and diary UI are reusable and must be preserved. **P1** CCH-CHARACTER-ARCS-001A (canon/choice audit), CCH-DIARY-LIFE-001A (diary/readability/save audit), CCH-DIARY-LIFE-001B (candidate first-page/choice/callback prototype, NOT approved). **P2** CCH-CHARACTER-ARCS-001B (Edith), -002 (Gideon), -003 (Thomas/Martha), CCH-DIARY-LIFE-002 (6–12 selected memories/one seasonal recap only if usable). **P3** CCH-DIARY-LIFE-003 (additional character/profile journal content). New character histories and branches remain concepts, not owner-approved canon. Explicitly forbid fabricated memories, supernatural fog answers, incompatible original story flags and a duplicate diary system.

## 2026-11-14 — Year-one branching narrative and synopsis

[YEAR_ONE_BRANCHING_NARRATIVE_DESIGN.md](YEAR_ONE_BRANCHING_NARRATIVE_DESIGN.md) records planned-game marketing copy and **October–September** choice arcs with ordinary approaches, later world callbacks and accurate personal diary pages. Tasks: CCH-YEAR1-BRANCH-001 P1 Design complete as proposal; 002 P1 audit existing October dialogue and story hooks; 003 P1 gated optional choice prototype; WINTER-001 P2 winter distribution; COVE-001 P2 first town motives; SUMMER-001 P2 farm/town investment; REFLECT-001 P2 first-year diary reflection; QA-001 P1 eventual save/branch/clock/ending regression. Existing May28 day240 letter and September22 meeting timing supersede inaccurate season labels in earlier prose. No code approved.

## 2026-11-14 — First autumn scenario design

[**FIRST_AUTUMN_BRANCHING_DETAIL.md**](FIRST_AUTUMN_BRANCHING_DETAIL.md) specifies first autumn (Oct/Nov) choice beats, Maren day-4 trek and optional response, first harvest allocation, cautious exploration, All Hallows and First Frost callbacks, and truthful diary memories. This is *design only*. New optional decisions must never block original early story or become mandatory morality tests. Same branch prototype should be reused across CCH-AUTUMN-BRANCH-003 / YEAR1-BRANCH-003 / DIARY-LIFE-001B rather than creating three separate systems.
