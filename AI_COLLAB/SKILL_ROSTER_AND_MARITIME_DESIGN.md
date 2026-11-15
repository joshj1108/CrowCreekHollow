# CCH-SKILLS-REVIEW-001 / CCH-MARITIME-001 — Lean Skills and Wicker Cove Maritime Progression

**Draft:** 2026-11-14. **State:** Design exploration, NO implementation approved.  
**Related:** `SKILL_MASTERY_DESIGN.md`, `MASTER_ROADMAP_TO_1_0.md`, `DEVELOPMENT_ROADMAP.md`, `LOWMERE_FIRST_DISTRICT_DESIGN.md`.
**New owner direction:** Audit and remove or consolidate redundant skills; consider bringing player aboard Wicker Cove fishing boats to discover new grounds and assist trade routes to other coastal towns.

## Source-grounded inventory
Existing `DESIGN.md` and `scripts/progression_system.gd` describe 10 skills, a 10-level cap and growing XP thresholds. They are Farming, Bushcrafting, Carpentry, Cleaning, Cooking, Fishing, Forestry, Mining, Smithing and Combat. Current features:
- **Cleaning:** repeat daily tidy +20 XP; Cleaning 2 increases tidying calm, Cleaning 3 unlocks cleanse; rest of household effects and any story gates require verification before redesign.
- **Forestry:** chopping trees gains XP, splitting wood and timber supply; overlaps the materials ecosystem of Bushcrafting (foraging/brush piles) and Carpentry (repairs/woodcraft). Other level gates and economy/simulation usage need audit.
- **Combat:** level grants max HP and XP by hits. Combat has consequential mechanical utility but its progression depth may need improvement.
- **Carpentry:** functional farmhouse restoration gates and upkeep, therefore important to town repairs and inn furnishing.
- **Cooking/Fishing/Farming:** concrete recipes, seasonal catches, crops, preservation, expedition provisions; prime candidates for Wicker Cove trade synergy.
- **Mining/Smithing:** cave ore feeds gear and tool unlocks; distinct gathering vs manufacturing jobs. Bushcrafting supports forest treks and lanterns.

## Provisional keep/merge/remove evaluation (NOT FINAL)
| Skill | Suggested action | Why | Risks and audit |
| --- | --- | --- | --- |
| Farming | KEEP/DEEPEN | Core identity, farm production and contracts | Preserve fields/crops unlocks |
| Cooking | KEEP/DEEPEN | Daily meals, preservation, inn, voyages | Recipe availability/XP balance |
| Fishing | KEEP/DEEPEN | Pond, coastal catches, boats | Separate skill from boating/navigation |
| Carpentry | KEEP/DEEPEN | Home, town structures and furnishings | Keep current story/restoration gates |
| Bushcrafting | KEEP/DEEPEN | Survival, foraging, wilderness | Avoid making it a grab-bag |
| Forestry | MERGE CANDIDATE | Chopping/wood processing may fit Bushcrafting or Carpentry | Audit unique Forestry requirements, XP and material progression before deciding; preserve milestones |
| Cleaning | RETIRE AS STANDALONE CANDIDATE | Daily tidying alone unlikely to reward 10 levels of mastery | Preserve clean/cleanse gameplay, sanity rewards, quests/achievements; check all gates |
| Mining | KEEP | Distinct extraction from smithing | Ensure ore use / progression remains worthwhile |
| Smithing | KEEP | Metalworking and tool/fixtures progression | Prevent overly mandatory cross-gating |
| Combat | KEEP BUT REVIEW | Protection and max-HP relevance | Preserve pacifist/cozy routes and difficulty balance |
| Seamanship | **POTENTIAL ADD**, not committed | Boats, routes, maritime preparation and deck tasks | Only justify as separate skill if enough repeatable distinct gameplay; no premature save migration |

**Possible 1.0 roster target:** 8 durable existing skills (Farming, Bushcrafting, Carpentry, Cooking, Fishing, Mining, Smithing, Combat) **if** Cleaning is retired and Forestry merged. A later sufficiently deep Seamanship becomes ninth. This is a **hypothesis, not a final roster**. Could retain Forestry if wood-processing grows into a real profession. No skill deletions/additions or XP formula changes approved.

## Before altering any existing skill: required audit
1. Source index of every `skill_xp` key, XP-grant action, level requirement, class, recipe, achievement, chapter, trader, GUI icon and save serializer.
2. 14/60/180/400 day timelines by play style. Identify level-8/10 reachability and whether skill can train without meaningless repeated interactions.
3. For each merge, propose a **save-compatible conversion** for accumulated XP or levels, with anti-exploit caps and compatibility tests. Do not blindly add both full XP totals, auto-max, wipe or silently rename skills.
4. Show preserved or reassigned relevant unlocks and maintain story/endings continuity; avoid menus that refer to deleted skill IDs.
5. Compare retained vs merged skill players in same input-driven simulation and at least one human playtest. Owner explicit selection before changes.

## Wicker Cove maritime exploration concept — future phase
**Context:** Wicker Cove is a dreary declining seaside fishing village below the mountain farm, permanently concealed by its own 24/7 fog bank. Fishers need assistance, and coastwise trade with other small towns could offer purpose to supplies and building projects. Farm remains nearest inhabited staging point to mountain treks; maritime routes **start from Wicker Cove harbor**, not the farm.

### Prototype voyage types
- **Working fishing trip:** board an NPC fisher's boat, help with nets/catch/boat chores at one nearby ground, then return. Rewards fish, coins, Fishing XP, relationships; do not need player-owned boat.
- **New fishing ground discovery:** fishers ask for help finding safer or more productive grounds; combine knowledge, timing, bait/gear and chart notes. New grounds unlock seasonal species and recurring Wicker Cove market orders.
- **Coastwise supply run:** prepare farm produce, lumber, smoked fish or building material through CCH-ORDERS-001; help transport it to an off-screen coastal village, possibly with simple deck actions and voyage choices. Return with payment, coastal inputs and character rumors; **no need to build another town map** to start.
- **Fogbound mystery crossing:** occasional optional voyage through visibility-limited water, with psychological dread, environmental clues and route decisions. Avoid automatic nightly pressure, constant monsters or turning all trips into horror events.

### Suggested first playable boat slice (only after Wicker Cove district)
1. NPC fisher at docks, one small boat and one selected route.
2. Short 1–3 minute structured trip using the established camera/scene conventions if feasible; prototype can use a discreet route/sea clearing rather than physics simulation or open ocean.
3. One real player contribution (tending a net, choosing when to cast, supplying fuel/provisions) and one meaningful choice (return now or attempt a farther ground).
4. Rewards coastal catch, a chart discovery or payment; publish an accessible return path and save/load handling.
5. Conditions/warnings rooted in weather and fog; do not make inability to see the horizon into completely unreadable gameplay.

### Decisions for maritime gameplay
- Player is initially **crew**, not instantly a ship captain. An owned boat, boatbuilder, piloting and ship upgrades are optional stretch goals after testing.
- Preserve original Fishing skill. If Seamanship added, it trains from distinct navigation/deck/route activities, **not** double XP for each fish or clicking 'depart'.
- Nearby coastal excursions first; **other seaside towns can exist as named off-screen trade destinations** before any additional traversable map. Trade uses existing coins, contracts and resources.
- Fog is permanent around Wicker Cove; its **origin stays unexplained**, with density/visibility varying locally without implying that fog vanishes.
- Boat trips should offer *cozy working maritime life* sometimes and *DREDGE-like* risk/curiosity tension occasionally. Preparation and time of day matter; don't punish player for simply enjoying fishing.
- Stop/pause and clock rules, controller inputs, boat accessibility, saving on voyages, scene transitions, path and location canon need technical review.
- No open-world ocean, naval combat, multiplayer, full sailing physics, endless ship maintenance or five new coastal towns in 1.0.

## Phase placement and task priorities
| ID | Priority | Status | Next gate |
| --- | --- | --- | --- |
| CCH-SKILLS-REVIEW-001 | **P1** | Design | Claude-source audit to decide keep/merge/retire, then owner confirms final roster |
| CCH-MARITIME-001 | **P2** | Idea/design | Harbor NPC, fishing trip and route design after first Wicker Cove district |
| CCH-MARITIME-002 | **P2** | Idea | One new fishing ground + working fishing trip with a return path |
| CCH-COASTAL-TRADE-001 | **P2/P3** | Idea | Simulated off-map coastal shipping contract; do not build other towns first |
| CCH-SEAMANSHIP-001 | **P3 / conditional** | Idea | Only add a tenth/ninth skill if voyages sustain distinctive mastery; validate save data and training |
| CCH-MARITIME-MYSTERY-001 | **P3** | Idea | Optional fogbound clue/encounter; lore and atmosphere review required |

## Integrations and sequencing
1. Phase 1–2: CCH-SKILLS-REVIEW-001 source audit alongside CCH-FOOD-001 and CCH-SKILLS-001A. Decide whether to merge Cleaning and Forestry before enlarging XP progression.
2. Phase 2: CCH-ORDERS-001 and food economy establish value of farm goods and fish.
3. Phase 4: CCH-LOWMERE-001 establishes accessible harbor and functional fish market / docks.
4. Future phase 4–7 (only after town works): CCH-MARITIME-001 → test one NPC fishing voyage → expand grounds / shipping if fun.
5. Version 1.0 requirement? **Not yet decided.** Treat voyages as P2 candidate, not ship-blocking; limit 1.0 to a single optional working trip only if prototype is demonstrably enjoyable and stable.
6. Existing mystery and endings must still function without boarding any boat.

**All proposals require specific owner authorization before Claude changes game code, arts or saved data.**
