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
