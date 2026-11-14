# Crow Creek Hollow — Master Roadmap to Version 1.0

**Planning baseline:** 2026-11-14. **Status:** strategy and prioritization ONLY; not blanket authority for Claude implementation.
**Sources of truth:** `DEVELOPMENT_ROADMAP.md` (detailed backlog), `TASKS.md` (active historic work), `MESSAGE_BOARD.md` (Claude handoffs), `LOWMERE_FIRST_DISTRICT_DESIGN.md` (town design), `DESIGN.md` (existing gameplay and lore).
**Order of work:** dependency-driven and subject to owner reprioritization; no promised calendar dates.

## 1. The target game / definition of 1.0

A polished, completable **top-down 3/4 pixel-art cozy folk-horror life RPG** in which the player:
- Establishes and restores the last mountain farm above Lowmere, surviving Hunger, Thirst, Comfort, Health and Sanity while everyday upkeep becomes easier through infrastructure.
- Grows crops, fishes, raises animals, cooks, preserves supplies, crafts, explores, and meaningfully progresses in existing interconnected skills.
- Supplies **Lowmere**, a **failing seaside fishing village forever covered by fog**, down the farm's mountain road, through voluntary home-dispatch customer orders and optional in-person town trade.
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

### Phase 4 — First accessible Lowmere district [P2 elevated to target-1.0 requirement]
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
- **CCH-LOWMERE-002**, **CCH-PEOPLE-001**, **CCH-PROGRESSION-002**: existing people and threads expand into Lowmere naturally, with no retcon of Agnes's pages, bell, mill, vicar, votes or endings.
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
- **M4 Lowmere is real:** leave farm, trade and interact, return, stable 24/7 fog and small district.
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

**Immediate next action:** receive/test CCH-EVENING-002, then CCH-FOOD-001 audit/design; prepare CCH-ORDERS-001 bounded farm-side prototype. No Lowmere map, new story beat or hotel editor is authorized until its own gate.
