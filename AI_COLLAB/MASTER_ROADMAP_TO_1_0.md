# Crow Creek Hollow — Master Roadmap to Version 1.0

> **Naming update (2026-11-14):** **Wicker Cove** is the official in-world name. Legacy `CCH-LOWMERE-*` task IDs and `LOWMERE_*` document paths are retained as stable project identifiers; they do not indicate a second town. All previous lore and design commitments are preserved.

**Planning baseline:** 2026-11-14. **Status:** strategy and prioritization ONLY; not blanket authority for Claude implementation.
**Sources of truth:** `DEVELOPMENT_ROADMAP.md` (detailed backlog), `TASKS.md` (active historic work), `MESSAGE_BOARD.md` (Claude handoffs), `LOWMERE_FIRST_DISTRICT_DESIGN.md` (town design), `DESIGN.md` (existing gameplay and lore).
**Order of work:** dependency-driven and subject to owner reprioritization; no promised calendar dates.

## 1. The target game / definition of 1.0

A polished, completable **top-down 3/4 pixel-art cozy folk-horror life RPG** in which the player:
- Establishes and restores the last mountain farm above Wicker Cove, surviving Hunger, Thirst, Comfort, Health and Sanity while everyday upkeep becomes easier through infrastructure.
- Grows crops, fishes, raises animals, cooks, preserves supplies, crafts, explores, and meaningfully progresses in existing interconnected skills.
- Supplies **Wicker Cove**, a **failing seaside fishing village forever covered by fog**, down the farm's mountain road, through voluntary home-dispatch customer orders and optional in-person town trade.
- Meets a small memorable cast, helps selected owners **repair and upgrade their businesses**, and designs **at least one playable, persistent inn guest room** for an original client brief. Expanded rooms/contracts are stretch scope, not essential for first integrated release.
- Returns to a cozy farm and occasionally ventures into the dangerous woods from the last settled stop; existing Agnes Rook, Maren, Davy, vicar, postman and town-vote narrative and existing ending routes remain reachable.
- Can continue free play and homestead/community goals after the main narrative, subject to save/story compatibility.
- Offers credible farmer, explorer and cautious survivor playstyles, low-repetition daily routines, useful winter activity and non-mandatory evening preparation.

**Explicit scope boundaries:** single-player, existing Godot tech and camera, existing HUD/menu art baseline, no seamless giant overworld requirement, no second farm, no live-service systems, no multiplayer, no new major survival meters, no new mandatory currency, no arbitrary skill level 99 grind, no copy of other games' proprietary art/UI/story. Never abandon or rewrite existing 17-chapter progression or endings to add town.

**Acceptance is not aesthetics alone:** meaningful voluntary daily/weekly goals, functioning full year including winter, working new economy, real input and human playtest evidence, all supported save paths, reproducible release builds, no confirmed P0 problems, regression passes, no impossible progression.

## 2. Status and priority definitions

Priority: **P0** critical ship blocker, **P1** core gameplay and quality, **P2** meaningful depth and extension, **P3** polish/stretch.
Statuses: Idea → Design → Ready for approval → Approved → Implementing → Testing → Review → Complete (or Deferred). Priority and status are independent.
Approval: owner explicitly approves a *specific brief*; this roadmap merely queues and defines gates. Claude must pause for visual or gameplay review at each assigned gate.

## 3. Ten-phase development pathway

### Phase 0 — Foundation and baseline [SUBSTANTIALLY COMPLETE; acceptance caveats]
- Existing playable farm, basic resources/skills, crop, animals, crafting, combat, cave and trek, full story framework and 3 endings in simulation.
- CCH-CONSOLIDATED-003 approved art/UI/interior/player/creature baseline, static main menu, balanced night lighting.
- CCH-PLAYABLE-002 gameplay repairs: 14 fixes, 79 tests passed, initial harvest and trek by input-driven bot, chapters 17/17 by long simulation; human playthrough not yet demonstrated.
- CCH-LOOP-001 idle-time audit: evening/afternoon gap, midgame and winter content drought, too much repeated felling.
- CCH-EVENING-001 implemented and image-reviewed but balance **NOT approved**.
**Gate:** preserve stable playable baseline; no claim all human-tested.

### Phase 1 — Make everyday play work [IN PROGRESS / P1]
- **CCH-EVENING-002** approved brief, implementation not yet verified: stage-based farmhouse shelter, firewood-free Quiet Hour, clues, early sanity and long-run simulation. Review actual results/screenshots; tune against relaxed/cozy, cautious, explorer, minimal.
- **CCH-FOOD-001** NEXT DESIGN/AUDIT: inventory of actual foods, crops, fishing, livestock, recipe output, prices, nutrition/Hunger effects, storage/smokehouse/cooler, winter provision and expedition meals. Approve a small balanced slice only after evidence.
- **CCH-SURVIVAL-001** survival maintenance time per stage (Decrepit/Boarded/Patched/Restored), no extra meters; infrastructure should reduce repetitive upkeep.
- **CCH-LEGACY-001** retire porch/storey gameplay only via explicitly approved save-safe preservation plan; currently still live.
**Exit test:** first 14 days have a viable homesteader route; meaningful evenings; no major onboarding blocker or runaway resource exploit.

### Phase 2 — Profitable, interconnected homestead production [P1]
- **CCH-ORDERS-001** prototype 2–3 optional home-dispatch customer requests using existing stand/mailbox. Partial fulfillment, reasonable quantities and seasons, reward margins, save/load, prevent reroll and double turn-in.
- **CCH-SKILLS-001** audit existing level/XP and meaningful unlocks; start small Farming → Cooking/preservation → Trading synergy and material/crafting support; preserve existing saved skill IDs.
- **CCH-HOMESTEAD-001** choose a few household foods and storage/preservation uses; avoid excessive processing interfaces.
- **CCH-FISH-001** make fish play a useful economic/cooking role; do not expand as redundant full fishing game.
**Exit test:** completing orders feels better than dumping all harvest at a stand, but not required or exponentially profitable; early and late supply constraints sensible.

### Phase 3 — Living daily/seasonal world [P1 core, P2 depth]
- **CCH-LOOP-002** 1–2 concise afternoon activity loops with existing landmarks and characters, not another endless quest chain.
- **CCH-WORLD-001** repeat-location discoveries and seasonal environmental changes; mystery integrated into everyday routines, no guaranteed paranormal event each day.
- **CCH-WINTER-001** meaningful winter activities and preservation, not an empty season.
- Optional P2 integrations: CCH-HERBAL-001, CCH-ANIMALS-001, CCH-TREK-002 (solo micro-forays), CCH-QOL-001 (earned relief from felling grind).
**Exit test:** real-activity availability and meaningful progression through a full seasonal cycle; winter and midgame less empty without mandatory chores.

### Phase 4 — First accessible Wicker Cove district [P2 elevated to target-1.0 requirement]
- **CCH-LOWMERE-001** begin with canon/engineering audit: road/gate, map scale, collision, transitions, world time, fog, inn/store/market/depot interaction, NPC dialogue and existing town-vote lore. No hardcoded coordinates from concept sheets.
- First playable slice: descending approach; permanent fog bank; small harbor district with general store, fish market, orders depot, inn/tavern and docks; only 1–2 interior scenes if feasible.
- Farm dispatch orders still work; town visit offers useful supplies, one optional commission, one encounter with a person and one subtle grounded clue. Avoid long mandatory journey for each delivery.
**Exit test:** travel downhill/return without save issues or missing evening; town feels like a failing fogbound fishing village with repeat utility; farm remains principal base.

### Phase 5 — Village restoration and owners [P2]
- **CCH-LOWMERE-BUILD-001** share one optional construction/contract framework across existing order and quest architecture.
- Prototype **one inn structural repair** first: request, contribution of material/labor, visible before/after, bounded coins and existing skill XP (confirm skill actually exists), new practical function and relationship acknowledgment.
- Expand to market/store/docks **only** after confirming first repaired location improves play.
**Exit test:** material economy sustainable; building owner and town visually respond; no unbounded XP/coin farming; all states persist through saves.

### Phase 6 — Inn design and creativity [P2 target minimum]
- **CCH-INN-001** implement **one usable guest room** with small original client brief, constrained tile/grid furniture editing, door/path/bed safety, optional theme choices and saved arrangement.
- Earn coins/relationship/furniture unlock where appropriate; client satisfaction based on clear requirements, not punishing subjective scoring.
- Stretch: multiple rooms, returning guests, decorative collections and inn dining orders. Do not hold 1.0 hostage to a giant creative editor or hotel management simulation.
**Exit test:** a human player can repair → decorate → finish → revisit the room with correct persistence; gameplay works on keyboard and controller.

### Phase 7 — Story, community and long-term mastery integration [P1 narrative integrity]
- **CCH-LOWMERE-002**, **CCH-PEOPLE-001**, **CCH-PROGRESSION-002**: existing people and threads expand into Wicker Cove naturally, with no retcon of Agnes's pages, bell, mill, vicar, votes or endings.
- Business/farm/skill specializations must provide non-story reasons to return; endings remain attainable without exhaustive decorating or construction.
- **CCH-ENDGAME-001** small optional ongoing economic/creative goals after ending; prevent perpetual maintenance grind.
**Exit test:** 17 chapters and existing endings still playable with actual town, save branching/return rules; meaningful mid/late-game non-trek progression.

### Phase 8 — Integrated testing, balance and accessibility [P0/P1]
- **CCH-PLAYTEST-001** expanded: real humans + bots, first 30 days, at least full seasonal/year simulation, winter, different playstyles, repaired town and one inn room.
- Validate time budgets, income/supplies, gifts, trading, skills, rest/warmth, Sanity, combat, story access, plot accessibility, controller/keyboard, visual legibility, readability, accessibility, performance and save migration.
- Run 14/60/400 day probes (label simulated versus input-driven and human); review strongest possible exploits and grind.
- Focused bug fixing and scope cuts on expensive P3 proposals.
**Exit test:** 0 known P0; no unresolved progression-breaking P1; human plays without developer intervention and chooses to continue; no critical save regressions.

### Phase 9 — Release candidate / distribution [P0/P1]
- Audit content completeness, source/license and originality; release build export, fresh install, multiple machines/resolutions, controller, save/load, migration, audio mixes, settings, performance.
- Debug/developer controls excluded from releases, usability and tutorial checks, final limited visual/audio polish, known issues, credits/store assets/docs as required for target storefront.
- Freeze new features, release candidate and regression pass, finalize 1.0; only then evaluate larger post-launch additions.

## 4. Milestone gates — no unbounded work
- **M0 Core playable:** baseline already exists; CCH-EVENING-002 review pending.
- **M1 Good first fortnight:** sane farming and survival with evenings, first harvest/trek, stable saves.
- **M2 Goods have purpose:** food/preservation/orders work on farm and economy balances.
- **M3 Full seasonal life:** afternoons/winter/midgame aren't devoid of fresh choices.
- **M4 Wicker Cove is real:** leave farm, trade and interact, return, stable 24/7 fog and small district.
- **M5 Town visibly responds:** complete one owner repair, reap meaningful benefit.
- **M6 Inn activity works:** decorate one room from brief and revisit it later.
- **M7 Complete story + free play:** original chapters/endings preserved; non-story progression meaningful.
- **M8 Release candidate:** playtests, stability, performance, accessibility and exports pass.

## 5. Master task queue for next implementation/design cycle
| Rank | Task ID | Priority | Current state | Next action / acceptance gate |
| --- | --- | --- | --- | --- |
| 1 | CCH-EVENING-002 | P1 | Approved / result not yet verified | Claude simulation and screenshot review; tune numbers |
| 2 | CCH-FOOD-001 | P1 | Design | Audit food, cooking, costs, storage; choose small recipe/benefit slice |
| 3 | CCH-ORDERS-001 | P1 | Design | 2–3 home-dispatch order prototypes after economy audit |
| 4 | CCH-SURVIVAL-001 | P1 | Design | Measure five stats and maintenance cost by stage |
| 5 | CCH-SKILLS-001 | P1 | Design | Audit XP/cap and unlocks; identify meaningful cross-skill ladders |
| 6 | CCH-HOMESTEAD-001 | P1 | Idea | Initial preservation/production link to food orders |
| 7 | CCH-LOOP-002 | P1 | Idea | Afternoon errands/discoveries in existing map |
| 8 | CCH-WINTER-001 | P2 | Idea | Winter-specific routine and economic activity design |
| 9 | CCH-LOWMERE-001 | P2 / 1.0-critical | Design / feasibility | Canon/route/art/scene/interaction blueprint; separately approve town slice |
| 10 | CCH-LOWMERE-BUILD-001 | P2 / 1.0 feature | Design | First inn-owner repair contract |
| 11 | CCH-INN-001 | P2 / 1.0 feature | Design | One guest-room design and persistent rearrangement |
| 12 | CCH-WORLD-001 | P2 | Idea | One changing landmark prototype |
| 13 | CCH-PEOPLE-001 / CCH-LOWMERE-002 | P2 | Idea | Use existing story cast and order framework |
| 14 | CCH-PROGRESSION-002 | P2 | Idea | Resolve midgame progress drought; improve non-trek paths |
| 15 | CCH-LEGACY-001 | P2 | Ready for approval | Safe retirement of old porch and second-storey options |
| 16 | CCH-PLAYTEST-001 | P1 | Idea | Formal human playtest gate after integrated core |
| 17 | CCH-FISH-001 / CCH-HERBAL-001 | P2 | Idea | Add only if they fill demonstrated gaps |
| 18 | CCH-ANIMALS-001 / CCH-TREK-002 / CCH-QOL-001 | P2 | Idea | Scope after core seasonal loop |
| 19 | CCH-ENDGAME-001 / CCH-CUSTOM-001 | P2/P3 | Idea | Optional long-term goal/decoration system |
| 20 | CCH-FESTIVAL-001 / CCH-POLISH-001 | P3 | Deferred | Only if time remains and measured player value supports |
| 21 | CCH-QA-001 | P0/P1 release gate | Design | Build test matrix, new/old save and human testing |
| 22 | CCH-RELEASE-001 | P0/P1 release gate | Idea | Export, perf, settings, distribution readiness |

## 6. Scope gates and measurable targets (proposals)
- Never add a second daily mandatory chores board. Orders, woodworking and hotel requests are opt-in.
- **Food:** survival staples available without specialized cooking; crafted meals/preservation have distinct utility; winter sustainable via reasonable preparation.
- **Farm time:** target basic daily needs maintenance declining with infrastructure (illustrative 30% at Stage 0 toward 10% at Restored; measure before coding).
- **Town:** repeat visits useful without having to walk for every delivery; map fog perpetual but gameplay still readable and not too dark.
- **Skills:** improve capability at milestones; no arbitrary grind inflation or broken existing XP.
- **One-room test:** placement and accessibility rules, persistent design, client brief satisfied, meaningful but bounded rewards.
- **Crisis:** if a P0 emerges, interrupt feature pipeline and address it first.

## 7. Working process for Claude and ChatGPT
1. Owner and ChatGPT design scope/priority, split required vs optional, document open decisions.
2. Claude inspects current code/lore and runs an **audit if necessary** (no assumptions that concepts are current mechanics).
3. Owner approves a specific implementation prompt and its resource budget.
4. Claude implements a small testable slice, runs regression and input-driven tests, captures review images, updates collaboration board.
5. ChatGPT reviews actual evidence and owner accepts/revises; status only becomes Complete after approval.
6. Re-rank backlog based on measured issues and player enjoyment; do not start a new phase solely because its design is exciting.

**Immediate next action:** receive/test CCH-EVENING-002, then CCH-FOOD-001 audit/design; prepare CCH-ORDERS-001 bounded farm-side prototype. No Wicker Cove map, new story beat or hotel editor is authorized until its own gate.


## CCH-SKILLS-001 design expansion (2026-11-14)

A source-grounded, design-only skill mastery plan is now recorded in [SKILL_MASTERY_DESIGN.md](SKILL_MASTERY_DESIGN.md). Preserve the existing ten skills and level-10 cap for v1.0 unless an audit justifies change. Prioritize meaningful unlocks rather than repetitive XP; use Farming/Cooking/Orders and Carpentry/Wicker Cove repairs as first synergistic prototypes. Keep current XP thresholds, save keys, chapter gates and Hale interactions intact. **CCH-SKILLS-001A (source/XP audit)** is the next approval gate; broader implementation remains unapproved.


## 2026-11-14 — Skill roster reassessment + maritime future (design-only)

**Owner changed the planning assumption:** a skill does not automatically survive into 1.0 simply because the current game has ten. The current ten-skill roster and cap remain the *code baseline* until a source, unlock and save audit proves a safe revision. This **supersedes** earlier master-roadmap language to preserve all ten as a design goal. See [SKILL_ROSTER_AND_MARITIME_DESIGN.md](SKILL_ROSTER_AND_MARITIME_DESIGN.md).

- **CCH-SKILLS-REVIEW-001 P1:** evaluate redundant/low-payoff skills, initially Cleaning (candidate retire from skill panel; preserve tidying/cleanse) and Forestry (candidate merge into Bushcrafting/Carpentry). Keep story gates, level thresholds, XP saves and benefits intact until explicit migration approval. Do not treat proposal as approved deletion.
- **CCH-MARITIME-001 P2:** possible future NPC-led voyages from Wicker Cove docks: join fishermen, help work a nearshore ground, decide return/risk, make discoveries. Prototype one short boat trip after harbor district.
- **CCH-MARITIME-002 P2:** discover one or two grounds, fish species and local maritime supply needs.
- **CCH-COASTAL-TRADE-001 P2/P3:** supply runs to **off-map** seaside towns using existing delivery/contract framework; only later consider physically accessible towns.
- **CCH-SEAMANSHIP-001 P3 CONDITIONAL:** add a distinct maritime skill only if real piloting/deck tasks justify mastery; preserve Fishing as catch skill. No open ocean or elaborate boat management needed for 1.0.
- **CCH-MARITIME-MYSTERY-001 P3:** optional dread in permanent fog, preserving balanced cozy working trips and existing supernatural lore.

**1.0 scope gate:** Voyages remain *candidate/stretch scope*, not mandatory for release. An optional one-route voyage may be promoted only after a tested Wicker Cove district and feasibility audit. Other seaside town maps are not 1.0 requirements. Restored town, inn and existing mystery remain priority over speculative ocean systems.


## 2026-11-14 — Wicker Cove resident and relationship design

[LOWMERE_RESIDENTS_DESIGN.md](LOWMERE_RESIDENTS_DESIGN.md) records a **design-only** four-resident concept, rooted in existing Maren/Davy/vicar/postman and town-vote canon. Proposed newcomers: Edith Vale (inn), Gideon Pike (fishing crew), Thomas Bellweather (general store), Martha Fenwick (fishmonger). Names, portraits, stories are not canon without owner approval. **CCH-LOWMERE-PEOPLE-001A P1 design prerequisite** is a story/relationship compatibility matrix; **001B P2** is a two-NPC playable town slice. New quests and relationships reuse existing FolkSystem and orders rather than creating separate machinery. Inn guests, fisherman routes, rumors, owner arcs remain downstream P2/P3 expansions.


## 2026-11-14 — Wicker Cove economic history and recovery design

Design-only reference: [LOWMERE_ECONOMY_HISTORY_DESIGN.md](LOWMERE_ECONOMY_HISTORY_DESIGN.md). Local history of declining fish catches, damaged harbor, supply shortages, reduced inn traffic and failing coastal trade is **proposed**, not approved story canon. Permanent fog and downhill geography **are** owner canon; the fog's origin/timeline remains undecided. **CCH-LOWMERE-ECON-001 P1 design prerequisite** covers history, existing-story reconciliation, and price/supply audit before production. Supporting P2 tasks: CCH-LOWMERE-ECON-002 (decay/repair world states), CCH-FISHERY-001 (fishery supply chain), CCH-HARBOR-REPAIR-001 (one dock repair opening an NPC voyage), CCH-LOWMERE-TRADE-001 (farm/port trade), CCH-LOWMERE-HISTORY-001 (story-safe town history). CCH-LOWMERE-RECOVERY-001 P3 (ambient local recovery). None may be coded from the roadmap alone.

## 2026-11-14 — Canon decision: contradictory Wicker Cove fog history

**Owner decision:** The town stays shrouded by fog 24/7. Villagers and historical documents provide contradictory, uncertain accounts of whether the fog always existed or arrived within living memory. **The cause, timeline and any Hollow/bell connection remain unresolved**. See [LOWMERE_ECONOMY_HISTORY_DESIGN.md](LOWMERE_ECONOMY_HISTORY_DESIGN.md) and [LOWMERE_RESIDENTS_DESIGN.md](LOWMERE_RESIDENTS_DESIGN.md) for canon safeguards. This updates earlier 'timing undecided' wording: **no canonical timing is decided, but contradictions themselves are mandatory world lore**.

- **CCH-LOWMERE-FOG-001 — P1, Design:** canon-safe evidence/testimony matrix, preserving existing 17 chapters and ending requirements. Prerequisite for new Wicker Cove lore.
- **CCH-LOWMERE-FOG-002 — P2, Idea:** 3 optional micro-discoveries (NPC, document, environmental feature), to implement only after town NPC/diary systems are ready and the owner approves.
- **CCH-LOWMERE-FOG-003 — P2, Idea:** persistent coastline fog presentation and readability on foot; extensible to optional future boat trips. The fog is distinct from regular weather and must not obliterate the balanced farm lighting.
- In release-story review, **do not accidentally answer the fog mystery** or equate one person's recollection with objective lore. A satisfying rumor/discovery can offer a resource, dialogue or route without resolving the fog.
**No game code changes or Claude task authorization issued.**


## 2026-11-14 — Coastal world exploration, locations and working voyages

[LOWMERE_COASTAL_WORLD_DESIGN.md](LOWMERE_COASTAL_WORLD_DESIGN.md) is a **design-only creative exploration** of the Working Harbor, Old Breakwater, Tide Pools, Outer Shoals, off-map Far Channel, and rare Unmarked Water. Place names, coastal geometry and special happenings are speculative. Owner canon remains: permanent 24/7 fog and **contradictory accounts about its history, with no confirmed explanation**. Working sea life and occasional dread must coexist. First possible boat activity is an **NPC-led safe working fishing trip** with one meaningful interaction, one return/continue choice and a save-safe return, *only after* Wicker Cove district is playable.

New candidates: CCH-COAST-WORLD-001 **P1 Design only** (geography/lore compatibility); CCH-COAST-SHORE-001 **P2 Idea** (one shoreline interaction); CCH-COAST-VOYAGE-001 **P2 Idea** (one working crew trip); CCH-COAST-GROUNDS-001 **P2 Idea** (one new ground with market utility); CCH-COAST-RHYTHMS-001 **P2/P3 Idea** (seasonal harbor ambience); CCH-COAST-CHARTS-001 **P2/P3 Idea** (ambiguous charts/logs); CCH-COAST-ROUTES-001 **P3 Idea** (off-map coastal trade); CCH-COAST-DEEPWATER-001 **P3 stretch** (rare mysterious expedition). Reconcile these with existing CCH-MARITIME-001/002, FISHERY-001 and FOG-001/002; use existing systems, **not duplicate implementations**. v1.0 still does not require an ocean map or voyages.


## 2026-11-14 — Comprehensive creative blueprint for the complete game

**Primary start-to-finish player-experience reference:** [CREATIVE_BLUEPRINT_START_TO_FINISH.md](CREATIVE_BLUEPRINT_START_TO_FINISH.md). Covers the first hour, first fortnight, autumn/winter/spring/summer, existing second-year 17-chapter story and three endings, post-story daily life, three interconnected progress paths (Homestead, Community, Mystery), Wicker Cove and maritime future, skills consolidation, minimum v1.0 content, QA and emotional north star. All historical/character/shore examples not already owner-set remain proposals. This operational master roadmap remains the priority and release-gate source of truth; blueprint is the **creative** source of truth. No code authorization.


## 2026-11-14 — Choice & consequence becomes a core 1.0 pillar

**Owner direction:** Crow Creek Hollow must feel like a choose-your-own-adventure, with **no morally or strategically mandatory 'right' way to play**. Meaningful decisions should persist and influence relationships, town economy, world state and personal journey. D&D-inspired hidden resolution rolls may introduce uncertainty, but must respect preparation, skills and agency; failure opens a different path rather than deleting essential content. Major authored ending conditions and existing 17 chapters remain in place until independently approved narrative changes.

Design: [CHOICE_CONSEQUENCE_SYSTEM_DESIGN.md](CHOICE_CONSEQUENCE_SYSTEM_DESIGN.md). **P1 CCH-CHOICE-001A** audit current branch/flag/save systems; **P1 CCH-CHOICE-001B** hidden d20-style degree-of-outcome spec; **P1 CCH-CHOICE-001C** three-choice prototype using existing farm/walker content after separate owner approval; **P1 CCH-CHOICE-QA-001** choice/roll/save/endings QA; **P2 CCH-CHOICE-LOWMERE-001** later town dilemma; **P3 conditional CCH-CHOICE-MARITIME-001** future sea decisions.

**1.0 definition refinement:** include one small validated *persistent and replayably divergent* choice-and-consequence loop with a later callback; spread it to more content only after game tests prove it valuable. No sprawling branching novel, new moral alignment, redundant RPG stats or visible dice UI required. This is a cross-cutting design gate for town NPCs, orders and restoration and should be solved in the current farm before adding many narrative scenes. No code approved by this entry.


## 2026-11-14 — Player-authored life paths and consequence weaving

[PLAYER_PATHS_AND_CONSEQUENCE_WEAVE.md](PLAYER_PATHS_AND_CONSEQUENCE_WEAVE.md) elaborates the approved choose-your-own-adventure **design pillar** into specific consequence levels, playstyle identity, season-spanning callbacks, winter food choices, competing harbor restoration priorities and fog testimony responses. These scenarios are illustrative, not new canon/quests. P1 design **CCH-CHOICE-PATHS-001** documented; **CCH-CHOICE-PATHS-002 P1** (audit 5–8 first-week decisions/callbacks); **CCH-CHOICE-PERSIST-001 P1** (one-shot RNG/save/rollback/old-save QA); **CCH-CHOICE-WINTER-001 P2**, **CCH-CHOICE-TOWN-001 P2**, **CCH-CHOICE-FOG-001 P2**, **CCH-CHOICE-LIFE-001 P2/P3**. Preserve existing chapter/ending rules and make outcomes responsive without morality grading. No implementation approval.


## 2026-11-14 — Branching resident stories + player-authored diary (design only)

[BRANCHING_RESIDENT_ARCS_AND_PLAYER_DIARY.md](BRANCHING_RESIDENT_ARCS_AND_PLAYER_DIARY.md) is the latest integrated personal-story design. Source review confirmed the diary already supports multiple page sections and Agnes/player handwriting via `PanelRows`, `ActionBar`, `DiaryBook`, and the four established walker arcs already persist in `FolkSystem`; do not rebuild either. New *proposed* Wicker Cove resident arcs: Edith (inn hospitality priorities), Gideon (fishing/route priorities), Thomas (general store economy), Martha (fish market provisioning). Specific names and branches still await owner approval. A future 'My days' diary section would render a small set of **verified** player choices and outcomes in their own writing, with seasonal callbacks and ambiguity-aware beliefs, not generated moral judgments or spoilers.

**P1 design:** CCH-CHARACTER-ARCS-001A (existing walker hook/arc audit); CCH-DIARY-LIFE-001A (journal state/section/save review). **P1 gated prototype candidate:** CCH-DIARY-LIFE-001B (one saved two-way optional farm choice, two accurate journal text variants, later callback). **P2:** CCH-CHARACTER-ARCS-001B/002/003 (town/boat/social arcs), CCH-DIARY-LIFE-002 (selected memory/season page); **P3:** CCH-DIARY-LIFE-003 extra personal notes. No code or chapter changes authorized. Execute P1 choice/save infrastructure on existing farm before creating many town dialogues.

## 2026-11-14 — Back-cover synopsis and year-one branching sequence

[**YEAR_ONE_BRANCHING_NARRATIVE_DESIGN.md**](YEAR_ONE_BRANCHING_NARRATIVE_DESIGN.md) contains the first proposed back-cover synopsis and a season-by-season choice web from October 1 through the first September, including delayed callbacks and a diary reflection. **Wicker Cove is official canon; specific side quests are design-only.** Timeline reconciliation: the established **day 240 clerk letter falls around May 28 (late spring)**, despite some earlier 'early summer' prose; day 300 mill access ~July 27, Harvest Moon day357 Sept22, Davy day370 Oct5 next year, bell day396 Oct31 next year. Preserve all existing narrative triggers and three endings. P1 **CCH-YEAR1-BRANCH-001** design matrix complete; P1 **002** audit actual early triggers, P1 **003** small October choice/November callback candidate; P2 winter/Cove/summer/reflection arcs only after related infrastructure. This is not an implementation authorization.

## 2026-11-14 — First autumn branching narrative: source-grounded detail

[**FIRST_AUTUMN_BRANCHING_DETAIL.md**](FIRST_AUTUMN_BRANCHING_DETAIL.md) is the detailed seven-beat first-autumn creative storyboard and choice/callback matrix. The existing day-4 Maren escort and all chapters stay intact; Maren's farm visits only occur from day 5 after the edge trek, and may not occur reliably. Choices cannot depend on a random visit for their sole callback. Oct31 All Hallows and Nov10 First Frost retain their original mechanics. P1 design **CCH-AUTUMN-BRANCH-001** completed as concept, **-002** TrekSystem/UI/save audit required, **-003** one-choice/future diary callback candidate requires explicit owner implementation approval. P2 ideas **-004** surplus choice, **-005** optional risky woodside, **-006** annual events personality, **-007** autumn reflection. P1 eventual QA **CCH-AUTUMN-BRANCH-QA-001**. This is a design dependency, not license for code changes.

## 2026-11-14 — First winter branching narrative

[**FIRST_WINTER_BRANCHING_DETAIL.md**](FIRST_WINTER_BRANCHING_DETAIL.md) expands *The Keeper* December–February into optional resource allocation, neighbor aid/exchange/independence, practical investigations and spring echoes. Preserve actual existing events: Dec 21 doubled nighttime Sanity effect; Jan 1 two grilled fish and bandage; Mar 1 Spring Thaw, plus day62-onward wood encroachment after 12 days of skipped treks. No new forced morality, re-rolled story endings or punitive moral fail states. **CCH-WINTER-BRANCH-001 P1 design** documented; **-002 P1 design** economy/save/first-scene audit; **-003 P2** gated one-episode supply/Jan callback; **-004 P2** existing holiday diary texture; **-005 P2** Feb-to-Mar response; **-QA-001 P1** eventual regression. Shares CCH-CHOICE and DIARY-LIFE infrastructure; **not authorized for implementation**.

## 2026-11-14 — Literary craftsmanship in plain language

**Owner editorial direction:** The game should aspire to a literary masterpiece's depth while remaining easy to read, natural and grounded. This is an approved **voice principle**, not permission to revise existing story dialogue. See [NARRATIVE_VOICE_AND_LITERARY_STANDARDS.md](NARRATIVE_VOICE_AND_LITERARY_STANDARDS.md) for practical style rules, dialogue/diary distinctions, scene review rubric and original Wicker Cove first-visit tone sample. **CCH-NARRATIVE-VOICE-001 P1 editorial design** documented; **002 P1** review representative existing lines before any rewrite; **CCH-SPRING-BRANCH-001 P1** develop first visit and branching approaches with this style; **002 P2** potential implementation only after town/choice systems; **CCH-NARRATIVE-QA-001 P1** eventual tone/agency/lore QA. Keep prose clear, observed details specific, meaning beneath dialogue, and choice outcomes fair.

## 2026-11-14 — First spring's multiple routes to Wicker Cove

[**FIRST_SPRING_BRANCHING_DETAIL.md**](FIRST_SPRING_BRANCHING_DETAIL.md) extends year-one choice architecture to March–May. Give all players practical access to the same **permanently fogbound** harbor street; remember whether they first come to sell goods, quote repairs, seek records or simply shop, without locking them into a class or making town access a prerequisite for the existing 17 chapters. One useful purchase, sale/order and human encounter, then a short return route. Mar1 Spring Thaw, Apr20 seed award and day240 (~May28) E. Pell letter are unchanged. Candidate P1 design `CCH-SPRING-BRANCH-001` complete; P1 audit `-002`; P2 implementation candidate `-003`, fog witness/ledger `CCH-SPRING-FOG-001`, letter-side-reaction `CCH-SPRING-LETTER-001`, memory `CCH-SPRING-DIARY-001`, eventual P1 QA. **No implementation approval.**

## 2026-11-14 — Summer of choice, consequence and growing responsibilities

[**FIRST_SUMMER_BRANCHING_DETAIL.md**](FIRST_SUMMER_BRANCHING_DETAIL.md) records the June–August 'The One Who Stays' branching design. Player can invest in their farm, supply Wicker Cove, accept a fairly paid inn repair, or pursue woods and neighbors; no mandatory altruism, mystery or universal optimal route. Practical outcomes should alter actual resources/physical state and later resident/diary callbacks, not introduce global moral alignment. Protect existing `StoryAct`: day240 late-May letter, conditional orchard event from day265 after shown letter, later actual knock from max(285, orchard day+4), mill vote from day300 with `maren_book` and `vicar_register`, Harvest Moon fallback after day357. P1 `CCH-SUMMER-BRANCH-001` design complete; P1 `-002` audit; P2 `-003/004/005/006` optional content after infrastructure; P1 eventual `-QA-001`. No code authorized.

## 2026-11-14 — Owner-set woodworking and station crafting rules

Owner directs that players **hew logs into planks at a workbench**, and **all non-anvil-made tools are manufactured at the workbench**. Metal tool forging belongs at an **anvil**, downstream of the existing furnace, without removing special cooking/firewood stations. See [WORKBENCH_ANVIL_WOODWORKING_DESIGN.md](WORKBENCH_ANVIL_WOODWORKING_DESIGN.md) for explicit compatibility and no-softlock safeguards. **P1** `CCH-CRAFT-STATIONS-001` owner-approved design requirement, `CCH-CRAFT-STATIONS-002` source audit; **P1** `CCH-WOOD-001` material keys and economics; **P1 gated prototype** `CCH-WORKBENCH-001` one station+logs/planks+one tool after approval; **P2 gated** `CCH-ANVIL-001` appropriate metal recipe migration; **P1 QA** `CCH-CRAFT-QA-001` first-hour survival, old saves, wood/fuel balance, 17 chapters. This is not authorization to modify code. Proposed future Wicker Cove repair jobs should consume actually prepared planks where suitable, not generic unprocessed wood.

## 2026-11-14 — Accessible forest woodcutting becomes primary timber route

**Owner requirement:** homestead trees are too difficult to locate; a clearly entered woodland **logging zone** must let the player choose to collect useful quantities of logs from forest trees, rather than scouring the farm perimeter. [FOREST_LOGGING_EXPEDITIONS_DESIGN.md](FOREST_LOGGING_EXPEDITIONS_DESIGN.md) specifies a compact renewable **nearwood cutting grove** (early, solo, safe daylight) and optional later **deep hardwood stand**, physical cutting and transport to the required workbench for planks. Existing 12 grove trees stay emergency/early supply. Distinguish original escorted story treks (`CCH-TREK-002` adjacency) so logging cannot bypass walker/story/wood-encroachment systems. **P1** `CCH-FOREST-LOGGING-001` design requirement, `-002` harvest/tree-layout/transition/save audit; **P1 gated** `-003` logging-to-planks vertical slice linked to `CCH-WORKBENCH-001`; **P2 gated** `-004` deeper hardwood, transport upgrades; **P1 QA** `CCH-FOREST-LOGGING-QA-001` early tools/first winter/canon/old save tests. No gameplay implementation approved.

## 2026-11-14 — September first-year choices culminate in a truthful personal diary

[**FIRST_SEPTEMBER_BRANCHING_DETAIL.md**](FIRST_SEPTEMBER_BRANCHING_DETAIL.md) is the proposed September/Year-One reflection: show what a player actually built, grew, repaired, sold, learned or left alone, with no morality grading or fabricated memory. It acknowledges **forest logging/workbench planks only once those systems are implemented**. Preserve the existing Sep22 Harvest Moon two turnip hashes and +10 sanity and original `StoryAct` morning-fallback meeting from `m.day > 357` (or later letter condition), determined by Maren's minute book and vicar register. Avoid renaming story 'second year' chapters or retconning Davy/second All Hallows. P1 `CCH-SEPTEMBER-BRANCH-001` design drafted; `-002` audit; P2 gated `CCH-SEPTEMBER-DIARY-001` personal entry and `CCH-SEPTEMBER-CALLBACK-001` later small echo; P1 `CCH-SEPTEMBER-BRANCH-QA-001` regression. Design only; no code changes authorized.

## 2026-11-14 — Year Two: The Cost of Staying

[**YEAR_TWO_COST_OF_STAYING_DESIGN.md**](YEAR_TWO_COST_OF_STAYING_DESIGN.md) is the source-checked design-only second-calendar-autumn and post-ending human-story plan. Existing 'second-year story' starts at **day240 (late May of first October–September cycle)**; this new October arc must not move the story gates. Davy's existing one-night opportunity begins from **day370/Oct5** *if orchard beat has occurred*, from **20:00 to before 01:00**; protect found/lost consequences. The day396/Oct31 second All Hallows crow bell and all three original endings remain intact. Preserve exact `maren_book`+`vicar_register` meeting evidence, `davy_turn`+`post_hand`+wood pages/night grove requirements for `elias`, and the recoverable `hollow` ending. Literary/plain-language addition means small conditional echoes of prior real farm/forest/workbench/Wicker Cove choices, never replacing core scenes or mysteriously clearing permanent coastal fog. **CCH-YEAR2-NARRATIVE-001 P1 design** documented; **-002 P1** source/flags/diary audit; **CCH-YEAR2-DAVY-001**, **-CHOICE-001**, **-AFTER-001** P2 optional small callback candidates; **CCH-YEAR2-QA-001 P1** eventual complete ending regression. **Design only, no implementation authorization.**

## 2026-11-14 — Make residents feel like people, plus essential postal lore check

[**CHARACTER_LIVES_AND_RELATIONSHIPS_DESIGN.md**](CHARACTER_LIVES_AND_RELATIONSHIPS_DESIGN.md) maps the existing Maren, Davy, vicar and postman's workaday rhythms and human wants, then candidate Wicker Cove Edith/Thomas/Gideon/Martha relationships and tiny callbacks. Style target: literary depth, ordinary speech; small repeated objects and meaningful choices rather than universal drama or affection scoring. **Important source conflict:** original `scripts/folk_system.gd` postman scenes `post_round/post_crate/post_dead` still refer to Lowmere as *'over the hills'* and as Agnes's mail/bell-iron source, despite Wicker Cove's new official name and downward coastal-road geography. Do **not** blind-replace those lines or invent a second town; prioritize `CCH-LORE-NAME-001 P1` exact lore/geography reconciliation before runtime dialogue edits. `CCH-CHARACTER-LIVES-001 P1` design documented, `-002 P1` walker/source voice audit, `CCH-MAREN-MICRO-001 P1 gated`, `CCH-DAVY-MICRO-001 P2 gated`, `CCH-COVE-CAST-001 P1 cast decision`/P2 slice, `CCH-COVE-RELATIONS-001 P2` one linked resident exchange, `CCH-CHARACTER-LIVES-QA-001 P1` eventual tests. No code authorized.

## 2026-11-14 — Living community expansion: character connections, scene voice and playable proof

New integrated design-only references:
- [LIVING_COMMUNITY_RELATIONSHIP_WEB.md](LIVING_COMMUNITY_RELATIONSHIP_WEB.md): 10 plausible interpersonal ties, three connected story webs (Maren/Ruth/vicar, Davy/family, Wicker Cove workers), information provenance, one 4-beat farm-to-inn delivery story and no-town playthrough. P1 `CCH-SOCIAL-WEB-001`, `CCH-SOCIAL-WEB-002` audit, `CCH-SOCIAL-PROVENANCE-001` design; P2 gated linked micro-stories.
- [SCENE_ANTHOLOGY_AND_CHARACTER_VOICE_BIBLE.md](SCENE_ANTHOLOGY_AND_CHARACTER_VOICE_BIBLE.md): character-specific voice table, twelve **proposed** grounded mini scenes, workday/seasonal conditions and no-spoiler screenwriting rubric. P1 `CCH-SCENES-001` design and `CCH-SCENES-AUDIT-001`; one `CCH-SCENES-PROTOTYPE-001` gated.
- [RESIDENT_ARCS_TWO_YEAR_BLUEPRINT.md](RESIDENT_ARCS_TWO_YEAR_BLUEPRINT.md): eight bounded two-year interlocking resident arcs, real economic tradeoffs, truthful callbacks and existing original-story safeguards. `CCH-RESIDENT-ARCS-002` P1 design, `CCH-RESIDENT-ARCS-AUDIT-002` P1, `CCH-RESIDENT-ARCS-SLICE-002` P1 gated, town pair P2 gated.
- [LIVING_WORLD_PRODUCTION_BLUEPRINT.md](LIVING_WORLD_PRODUCTION_BLUEPRINT.md): 6-outcome first existing-farm choice/memory slice, staged development through solo timber→workbench, orders, two-resident first Wicker Cove district, persistent September/year2 echo, human test cases. `CCH-LIVING-WORLD-001` P1 design, `CCH-LIVING-WORLD-AUDIT-001` P1 then `-SLICE-001` P1 gated; town/season P2. No giant all-features implementation prompt.
- [WICKER_COVE_POSTAL_LORE_CONTINUITY_AUDIT.md](WICKER_COVE_POSTAL_LORE_CONTINUITY_AUDIT.md): **P1 `CCH-LORE-NAME-001` partially source-verified mandatory continuity issue** — original `FolkSystem` old Lowmere postal scenes say 'over the hills', weekly Agnes correspondence, bill and original bell-iron crate. Owner canon renamed fogbound coastal village Wicker Cove downhill. **Do not touch runtime dialogue via blind rename.** Recommended *pending owner approval* Option A: same town via ridge/descent, preserve facts/scene IDs with minimal proper-name and geography text edits. Remote indexed GitHub search did not find even verified existing references; later **raw repository scan** required before safe change. `CCH-LORE-NAME-002` P1 gated patch, QA.
Production order: lore + script audit → one actual walker optional choice with delayed callback and personal diary → timber bench/orders → small town with two residents → one resident-to-resident delivery memory → second-year echo; preserve every original StoryAct gate and 3 endings. None of the new scripts/quests/art has been implemented or approved for implementation.

## 2026-11-14 — Twelve-month community rhythm, lived-in Wicker Cove, complete guestroom branch

Additional linked design references (all **design-only**, no code authorization):
- [YEAR_ROUND_COMMUNITY_RHYTHMS.md](YEAR_ROUND_COMMUNITY_RHYTHMS.md), `CCH-COMMUNITY-CALENDAR-001` P1 design: October–September character work, seasonal objects and source-verified event dates; no new forced holidays or quests. `-002` P1 calendar/source audit; seasonal callbacks and town routines P2 gated; QA P1.
- [WICKER_COVE_LIVED_IN_DISTRICT_BIBLE.md](WICKER_COVE_LIVED_IN_DISTRICT_BIBLE.md), `CCH-COVE-LIFE-001` P1 design: modest readable harbor street, working store/inn/market/slipway, warm human interiors, permanent fog that doesn't hide controls, optional orders, 1–2 core new residents. `CCH-COVE-LIFE-002` P1 technical/geometry audit and `CCH-COVE-CAST-DECISION-001` P1 owner decision; `CCH-COVE-LIFE-SLICE-001` P2 gated, inn room and harbor afterward.
- [INN_ROOM_BRANCHING_STORY_PROTOTYPE.md](INN_ROOM_BRANCHING_STORY_PROTOTYPE.md), `CCH-INN-STORY-001` P1 narrative design: one complete Edith/Thomas **candidate** roof-quote → home-vs-inn planks → guestroom brief → winter guest response → second-year lit-window arc. `-002` P1 real economy/crafting/UI audit; `-003/004/005` P2 gated content, QA P1. It requires **actual forest logging, logs→workbench planks, town map, orders, room furniture save**, not fake inventory, and doesn't change any existing Rook ending.
**Narrative-quality gate:** no forced morality verdict, original story preserved, genuine tradeoffs, one durable world response and a believable NPC workday. **No art, map, scene or game-code changes have been approved through these plans.**

## 2026-11-14 — Literary motif and horror pacing architecture

[**LITERARY_STRUCTURE_AND_HORROR_PACING.md**](LITERARY_STRUCTURE_AND_HORROR_PACING.md) turns the owner-approved "literary masterpiece in plain language" standard into a concrete narrative framework: recurring wood/light/paper/water/bell-and-work sounds; a satisfying ordinary 420s game day; warm/uncertain/hard registers so the horror doesn't overwhelm daily life; existing human character complexity; persistent state and truthful diary motifs. `CCH-LITERARY-STRUCTURE-001` P1 design documented; `CCH-LITERARY-QA-001` P1 content/source/agency review; `CCH-LITERARY-ECHO-001` P2 a single item/object remembered across seasons. Every major supernatural plot beat stays in existing `StoryAct` with original conditions; the permanent Wicker Cove fog does not clear or get its real onset exposed. No code authorized.

## 2026-11-14 — Consolidated first-30-days playable proof instead of uncontrolled scope

[**FIRST_30_DAYS_LIVING_WORLD_VERTICAL_SLICE.md**](FIRST_30_DAYS_LIVING_WORLD_VERTICAL_SLICE.md) is the detailed **P1 DESIGN**, **not implementation approval**, for one connected first-month gameplay slice: preserve existing guided day1, fixed first scare, first Tin Lantern chapter, Maren day4 escort, first crop around day8, day14 mill eligibility, Davy eligibility day20; add *only after source/UX/save audit* a clearly signposted early forest logging path, raw logs→planks at functional workbench, one non-anvil starter tool and useful home repair, plus a voluntary Maren help/exchange/independent choice with one deterministic later callback and truthful diary entry. No Wicker Cove map or giant town cast in this vertical slice. Requires no circular tool/bench/anvil dependencies, preserves original three endings, and tests 30-day human play and old saves. `CCH-30DAY-SLICE-001` P1 design documented, `-AUDIT-001` P1; `-FOREST-001`, `-WORKBENCH-001`, `-STORY-001` all P1 separately gated candidates sharing existing forest/workbench/diary tasks; `-QA-001` P1 eventual. Use this to prevent design expansion from delaying playable progress.

## 2026-11-14 — One indexed handoff for the entire living-world design expansion

[**LIVING_WORLD_DESIGN_HANDOFF_INDEX.md**](LIVING_WORLD_DESIGN_HANDOFF_INDEX.md) now groups all current creative source material: season-by-season first-year and second-autumn plan, editorial standards, existing and tentative character stories, 12 illustrative dialogue scenes, 8 two-year resident arcs, realistic Wicker Cove coastal town, player-authored consequence/diary system, workbench/plank and deliberate forest logging, postal-Lowmere continuity audit, and the **FIRST_30_DAYS_LIVING_WORLD_VERTICAL_SLICE** as the preferred next practical build-review brief. All are **design only**; no code, visual art, existing chapter or save schema changed. Priority stays actual playable first-month demonstration with old save/chapter/ending QA, not implementing every document at once.

## 2026-11-14 — Deep player identity and farmhouse story architecture

The new [**PLAYER_IDENTITY_AND_HOME_STORY_BIBLE.md**](PLAYER_IDENTITY_AND_HOME_STORY_BIBLE.md) defines the central thematic distinction **ownership / belonging / responsibility** without personality classes, a global morality score or new canonical endings. [**HOUSE_MEMORY_AND_PLAYER_DIARY_ATLAS.md**](HOUSE_MEMORY_AND_PLAYER_DIARY_ATLAS.md) specifies seven meaningful repeated spaces and **facts-only** player diary; [**MEANINGFUL_CHOICES_AND_REVELATION_ARCHITECTURE.md**](MEANINGFUL_CHOICES_AND_REVELATION_ARCHITECTURE.md) connects eight reveal questions to **existing** `StoryAct` and `FolkSystem` scenes, with credible tradeoffs/callbacks and no fog origin; [**NARRATIVE_QUALITY_BENCHMARK_AND_RED_TEAM.md**](NARRATIVE_QUALITY_BENCHMARK_AND_RED_TEAM.md) sets a hard editorial QA rubric and four playstyle tests. IDs `CCH-STORY-LIFE-001`, `CCH-HOUSE-MEMORY-001`, `CCH-STORY-CHOICES-001`, `CCH-STORY-QUALITY-001` **P1 Design** documented. P1 detailed code/source audit tasks `CCH-STORY-LIFE-002`, `CCH-HOUSE-MEMORY-002`, `CCH-STORY-CHOICES-AUDIT-001`, `CCH-STORY-QUALITY-002` remain before production; original 17 chapters/3 endings and event/day/letter/deed gates must not be casually edited. **Do not implement this as a bulk rewrite.** Preferred next playable proof remains [FIRST_30_DAYS_LIVING_WORLD_VERTICAL_SLICE.md](FIRST_30_DAYS_LIVING_WORLD_VERTICAL_SLICE.md) with one Maren choice→callback→diary and separate forest logs→workbench planks after owner approval. `CCH-LORE-NAME-001` remains undecided.

## 2026-11-14 — Interactive past: The Road to Crow Creek Hollow

[**PLAYER_ARRIVAL_INTERACTIVE_PROLOGUE_DESIGN.md**](PLAYER_ARRIVAL_INTERACTIVE_PROLOGUE_DESIGN.md) develops a **Firewatch-inspired but original** 4–7-minute optional literary prelude that establishes *why the farmer chose the Rook property*. Small choices about reason to move (independence/financial opportunity, prior life change, work autonomy, curiosity, practical chance), one person left behind, a kept or discarded memento and a departure line build a **personal past without forced family tragedy or hidden personality classification**. A few sourced callbacks in diary/ordinary mail can echo through the first year; never alter gameplay resources, starting skills, core events or three ending conditions. **Important legal canon audit:** `scripts/estate_system.gd` presently holds the farm from the town by quarter tax, with deed purchasable after Patched stage, 12,000 coins in 500 installments; `StoryAct` calls the player tenant. The older promotional phrase 'inherited farmhouse' **does not establish already owning deed or kinship to Agnes**. Draft proposes an ordinary notice/offer to occupy a neglected farm on town terms, **pending exact owner-approved wording**. `CCH-PROLOGUE-001` P1 Design documented, `-002` P1 creative/legal approval, `-003` P1 UI/save/new-game audit, `CCH-PROLOGUE-PROTOTYPE-001` P2 gated short version, `CCH-PROLOGUE-REMEMBER-001` P2 gated later personal echo, `CCH-PROLOGUE-QUALITY-001` P1 QA. Preserve day1 tutorial and first-night scare; no code work authorized.

## 2026-11-14 — Owner amendment: mandatory narrative interlude; equal weight of coming and staying

**Supersedes previous 'optional, skippable, token callbacks' prologue design.** [PLAYER_ARRIVAL_INTERACTIVE_PROLOGUE_DESIGN.md](PLAYER_ARRIVAL_INTERACTIVE_PROLOGUE_DESIGN.md) is now an owner-required **mandatory story interlude for every new game**, with meaningful player-selected reason to arrive, no Skip or bypass, pause/read-speed/resume accessibility and no consumed October1 gameplay time. **Why the player came must be as narratively important as why they stay.** Origin is a parallel long-form strand: initial chosen history, early winter development, midyear meaningful decision, September acknowledgment and second-year/afterword echo; not 1–3 decorative keepsake lines. Allow privacy on relationship details but no origin omission. `CCH-PROLOGUE-001` P1 owner-approved direction (design work), `CCH-PROLOGUE-002` P1 determine exact premise/wording and final scenes, `-003` P1 NewGame/UI/save/resume audit; `CCH-PROLOGUE-PROTOTYPE-001` **P1 gated** mandatory opening, `CCH-PROLOGUE-REMEMBER-001` **P1/P2 gated** substantial life-before strand; `-QUALITY-001` P1 no-skip, origin branch, resume and original-canon tests. **No gameplay implementation authorized yet.**

## 2026-11-14 — Two Lives, One Road: five complete personal origin arcs

[**TWO_LIVES_INTERWOVEN_ORIGIN_ARCS.md**](TWO_LIVES_INTERWOVEN_ORIGIN_ARCS.md) is the substantive follow-through on the **owner-required mandatory, non-skippable** `CCH-PROLOGUE-001`: five candidate fully developed origins (housing stability, work autonomy, changed household, chosen curiosity, pragmatic chance), each with opening lived circumstances, first autumn item/connection, an external winter change, a material or relational midyear decision, and September/year-two/postending story results. **Why they came is equal in narrative importance to why they stay**, not a briefly mentioned reason or a static personality class. Existing Rook story, 17 chapters, deed mechanics, permanent Cove fog and all endings remain independent. `CCH-TWO-LIVES-001` P1 design, `-002` P1 editorial audit, `-003` P1 NewGame/save UI audit; `CCH-TWO-LIVES-INTERLUDE-001`, `-WINTER-001` P1 gated, `-MIDYEAR-001` P1/P2 gated, `-RETURN-001` P2 gated, `-QA-001` P1 QA. No game code changes authorized.
