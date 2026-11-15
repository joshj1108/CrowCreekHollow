# CROW CREEK HOLLOW — Creative Blueprint From First Day to Long-Term Life

**Planning draft:** 2026-11-14  
**Purpose:** Owner/ChatGPT north-star design from first input to post-ending life, tying existing game canon to future Wicker Cove and coastal aspirations.  
**Authority:** No feature in this document is automatic Claude implementation approval. Development requires specific owner-approved slices and test gates.  
**Companion:** [MASTER_ROADMAP_TO_1_0.md](MASTER_ROADMAP_TO_1_0.md) is the operational roadmap; this file is the **creative and player-experience blueprint**, not an alternative list of active tasks.

## 0. Creative thesis

**Player fantasy:** You arrive at an abandoned homestead and gradually build a life worth staying for. The house becomes a refuge, the farm becomes a livelihood, Wicker Cove becomes a community you help, and the wilderness and sea remain unsettling frontiers you may never fully understand.

**Single-sentence positioning:** *A rustic-gothic 3/4 top-down farming and survival life game where a working homestead supports a failing fogbound fishing village while an old folk-horror mystery unfolds over the seasons.*

**Emotion arcs:**
- **Beginning — Vulnerability:** You have a property but not yet a home; the first night has real stakes.
- **Middle — Competence:** Farming, cooking, shelter, tools and woodland preparation make you capable, not invulnerable.
- **Broadening — Belonging:** Town orders and personal relationships turn individual survival into shared purpose.
- **Later — Stewardship:** Your work reopens rooms, repairs boats and helps people recover livelihoods.
- **Ending — Choice:** The existing Hollow story ends according to your actions, but the player can remain, improve and belong afterward.

**Atmosphere rules:**
- Horror and warmth amplify each other; neither is mere decoration.
- Farmhouse cozy by design, with balanced eerie night lighting; lantern tiers extend radius rather than intensity.
- Wicker Cove always has dense coastal fog, independent of normal inland weather; accounts of its historical origin **contradict each other and remain unresolved**.
- Recovery of individual buildings does not turn Wicker Cove into a sunny theme-park town or explain the fog.
- Quiet work is not a punished alternative to danger. Optional journeys and civic projects should reward curiosity rather than be required for story endings.

## 1. What exists vs what this document proposes

### Current implementation / established canon from DESIGN.md and prior audits
- Godot 4.7 top-down 3/4 camera; 16 px world art/grid at 3×; rustic-gothic balanced HUD/diary/menu and static moonlit main-menu baseline; existing farm road and gate, NW cave/hillside, market stand near mailbox.
- Day 1 begins **October 1**. The day lasts **420 real seconds** (game 06:00 through 03:00); story/time and needs must be tuned against a short real playday.
- Existing farm, 4-stage farmhouse appearance (Decrepit, Boarded, Patched, Restored), crops, animals, crafting, fishing, mining, equipment, cave, foraging, weather, seasons, 10 current skills capped at 10, money/stand and daily house job, encounters, story, diary and walker relationships.
- Existing main story has **17 ordered chapters**, with late beats around day 240 (town letter), day 300 onward (mill meeting opportunity), day 370 (Davy's night) and second All Hallows around day 396 (crow bell). Three established outcomes: **The Hollow Sleeps**, **Two Came Home**, **The Line Under the Rooks**. Existing endings can return player to continued play.
- Original relationships: **Old Maren, Davy Tull, the vicar and postman**. Their dialogue, mystery evidence, location/time gates, chapel clapper, mill vote and ending flags are protected canon.
- Prior automated audit CCH-PLAYABLE-001 found 0 confirmed P0 but multiple gameplay usability/flow issues. CCH-PLAYABLE-002 repair work was reported and requires real owner/human acceptance. First harvest/trek and story reachability have different evidence levels (input-driven vs simulated). CCH-EVENING-002 is approved but its updated output not verified in the reviewed roadmap.
- Existing skill Cleaning and Forestry are **candidates for consolidation/removal**, not deletions; no saved XP, story rewards, or unlocks may break.

### Established owner direction not yet implemented
- Wicker Cove: failing seaside fishing village down winding mountain road from farm, permanent 24/7 fog, historical testimony/records about fog contradictory and uncertain, no established explanation.
- The player should be able to **repair/upgrade town owners' buildings** and earn meaningful rewards.
- Inn design should offer **client-briefed guest-room decoration** with persistent layouts; borrow the high-level creative mechanic, never another game's assets, UI, brand, or exact reward system.
- Someday join fishermen on **NPC-led voyages**, find fishing grounds and potentially improve off-map coastal trade routes.
- Preserve original farm/gameplay and aim for a finished indie-scale product instead of infinite AAA scope.

### Proposed concepts, not approved canon
- Wicker Cove's exact geographic layout, shore landmarks, town economic chronology, candidate new residents Edith Vale, Gideon Pike, Thomas Bellweather and Martha Fenwick, individual guest/story events, exact fog examples, coastal fishing locations, ship route names, new item IDs, and possible Seamanship skill.
- Exact game-day unlock times for Wicker Cove, production/cost/economy margins, NPC schedules, building and inn counts and voyage duration.

## 2. The player experience, act by act

### Act A — First hour / first four days: 'There's a house, but it doesn't feel like yours'
**What the player does:** Title → new game → first diary note and tools → move, plant a few seeds, gather from brush, craft hatchet, chop, drink, find bed; first night establishes discomfort/dread; early lantern and Maren's first edge walk establish the woods as a different kind of threat.

**What the player learns:** Basic survival needs; daytime makes room for peaceful activity; at night the landscape is changed; the diary belongs in daily gameplay; you cannot solve every threat by fighting.

**Must feel:** clear, not tutorial-spam. A player should be able to recover from mistakes, sleep, and have at least one small pleasant activity before dread. No early Sanity spiral due solely to unclear instructions.

**Existing anchors:** October 1 start, diary first-day eight steps, first nights, Chapter 1 Sleep, 2 Lantern, 3 Walk to Wood's Edge (day 4), first Hollow sighting after edge walk or later fallback. Protect timing.

**Design enhancements (future):** Meaningful first cozy evening signal, visible warmth of the hearth, accurate danger descriptions, explicit choice to rest/read/cook or confront what is outside.

**Acceptance:** input-driven and human first-hour test: no stuck onboarding, readable controls, viable first bedtime, appropriate balanced night brightness, clearly understood immediate goal.

### Act B — First fortnight: 'I can keep this place alive'
**Actions:** First harvested crop (after watered growth), modest fishing, daily survival, simple cooked meals, first house repairs, sell an actual harvest, occasional visitor/letter, first cave look if ready.

**New motivation:** Food is more than a bar. Regular cooking makes the house homely; saving extra produce matters. There should always be a goal, but none should require eight daily steps just to avoid punishment.

**Reward texture:** patched floorboards, cleaner windows, better water delivery, first sale, first lantern or tool tier, ordinary recognition from a familiar person.

**Proposed first Wicker Cove signal:** a request arriving at farm's existing mailbox/stand mentioning local food shortages, **without requiring the new town to exist on day one**. Orders should be optional and achievable with current crops/seasons.

**Acceptance:** a player can harvest, eat or cook, sell, save and return, complete/skip one optional request, and choose a meaningful use for an afternoon. Multiple viable play styles.

### Act C — First autumn → winter: 'The first hard season'
**Actions:** Learn crops' seasonal windows, harvest/storage decisions, build warmth reserves without turning them into relentless chores, winter meals, winter fishing/foraging as relevant, slow house transformation.

**Emotional beat:** The world outside gets colder; the home gets warmer because of the player's actual work. Winter should be quieter and distinct, not content-free or exclusively punitive.

**Potential Wicker Cove layer:** periodic food requests for cold-weather households and an innkeeper in need of heat/fuel; initially handled by stand/letters. Not mandatory or an infinite profit exploit.

**Acceptance:** winter supports meaningful but fewer/different pursuits, basic upkeep becomes easier with improvements, low-skill player is not soft-locked. Actual temperatures/needs/sanity must be verified with simulations and human play.

### Act D — Spring / early summer: 'Now other people rely on me'
**Actions:** More fields and produce variety, livestock produce, preservation, skill combinations, personal errands and repeatable town orders. Some woodland routes and character arcs develop.

**Design target:** Player discovers positive dependencies: Farming → Cooking → supply; Forestry/Carpentry/Smithing → useful repairs; Fishing → meals/market demand. Trading rewards added usefulness, not double XP faucets.

**Wicker Cove first visit (proposed timing, not canonical):** after basic survival is established and town map is playable: downhill road, fog swallowing horizon, useful store and market, small inn, docks. A first visit gives one trade advantage and one human encounter without forcing a story explanation.

**World response:** visible repaired shelves, an occasionally stocked counter, a first guest room becoming usable. The town still feels poor, salt-weathered and fogbound.

**Acceptance:** optional town visit and return consume a reasonable share of a 420s day; save transitions and controller support work; farm remains the home base. Existing walker schedules and trek gates unaffected.

### Act E — First summer / rest of year: 'I have something to offer'
**Actions:** House and worksite mastery, broader contracts, first small town-owner restoration project, the inn design prototype, other villagers' problems becoming personal. Woodland treks remain separate and increasingly meaningful.

**Village arc:** The player **helps residents help themselves**; each business owner contributes expertise and resources. The player is not sole savior.

**Town upgrades:** Each optional renovation must produce (1) visible change, (2) new or improved function, (3) a character acknowledgment. Repair → improve → restore is a candidate tier vocabulary, not mandatory identical art swaps.

**Inn experience:** One room; repair it structurally, then choose floor/wall/decor and arrange furnishings to satisfy a reasonable guest brief; save the layout. Creative freedom without punitive aesthetic scoring or new special currency.

**Acceptance:** successful completion without duplicate rewards; player can revisit room; characters react believably; at least one player who prefers farming over construction can still progress main story.

### Act F — The existing second-year story: 'What happened here, and who is responsible?'
**Hard canon:** Do NOT rewrite the 17 ordered chapters or existing conclusion routes. Around day 240 the town letter arrives, later the water rises, the Hollow knocks, the mill meeting and town vote become consequential, Davy's night occurs around day 370, the bell can be hung at second All Hallows, and grove-related endings branch by requirements already in `DESIGN.md`.

**New-town function:** Embody the town implicated by the farm/keeper and vote, **without** handing the player a simplified 'villain of the town' or invalidating established Maren/vicar/postman evidence. The added Wicker Cove cast may express nuanced views and partial recollections, but chapter conditions and endings remain the source of truth.

**Fog story:** Town and harbor rumors contradict on when the fog began; no player achievement or final lore diary entry must assert a definitive origin. The fog is not explained by the Rook bell unless the owner separately changes canon.

**Acceptance:** simulation + real-input accessibility for all existing ending conditions, cross-check character schedules, scenes, save flags, diaries and final texts with town presence. No requirement to complete the inn or all buildings to obtain an ending.

### Act G — After an ending: 'The farm goes on'
**Existing behavior:** Endings show a sequence/Afterword and then return to ongoing play.

**Long-term optional goals:** more comfortable home, all useful recipes, a specialty farm, trusted business relationships, one or more civic restorations, an inn room collection if extended, fishing mastery, fuller collection/seasonal endeavors, occasional town guests and coastal trade. Meaningful choices, not compulsory prestige grind.

**Mood:** A restored farm is safe *enough*, not a sterile fortress. The woods and sea retain mysteries and atmospheric tension, including after story resolution. Player can opt for a quiet evening by the hearth.

**Acceptance:** replaying after ending does not soft-lock time, diaries, trading, visits, saves, or previously earned building stages. No daily grind for the right to enjoy a completed home.

## 3. The daily gameplay heartbeat

The best normal day should have **three phases rather than a mandatory checklist**:
1. **Morning — Care / plan:** wake, check weather/needs, water/harvest or tend animals as available, choose an order or destination.
2. **Midday — Pursue your interest:** specialize in crops/cooking, craft/build, trade in Wicker Cove, investigate near farm/cave, meet NPC or take a woodland trek.
3. **Evening — Return / reckon:** sell/store and cook, light fire if desired, read diary, enjoy comfort/relationships, or choose a calculated night risk. Finish day with sense of accomplishment, not constant exhaustion.

**Daily choice test:** at least two meaningfully different viable plans should exist on normal days; improved infrastructure must *reduce* mandatory maintenance time. Long journeys must have clear payoff, and no obligatory town commute after each harvest.

## 4. Geographic and atmospheric composition

`Farmhouse → Farm fields and pond → Existing gate and mountain road → Wicker Cove's compact main street → working harbor → optional shore/boat spaces` (spatial exactness pending map audit). Woods/cave remain separate mountainward frontiers, woodland treks start at the farm. Nearshore coastal trips start at Wicker Cove's docks.

- **Farm:** continuity, warmth and customization; strong day/night and season shifts.
- **NW cave and Rookery woods:** grounded wilderness, danger, old pages, sense of being watched; no glittering magic cave.
- **Wicker Cove:** permanent thick *local* fog, damp salt-stained buildings, working inhabitants, lower income and repairs. Fog density may breathe locally for legibility but coast remains shrouded 24/7.
- **Working harbor:** tide-stained planks, boats and fish stalls; even a small functional berth matters.
- **Optional shoreline locations:** breakwater, tide pools, outer shoals (all working names). Prioritize one shore interaction over a giant coastal map.
- **Off-map coastal settlements:** optional future trade manifests, one destination at first; don't build entire secondary towns for 1.0.

**Visual asset rule:** strong pixel scale/proportion consistency, 3/4 top-down (not isometric), limited textured palette and clear silhouettes. Rendered concept art is mood/shape reference, not directly shippable sprite sheets.

## 5. Economy — How the world connects

`Farm produce → pantry, cooking and preservation → personal provisions OR modest home dispatch order → village kitchen/store → coins, reputation and specialty goods`.

`Wood/ore → tools, farm maintenance, crafted components → owner construction project → reopened function → new useful orders`.

`Pond/future sea catches → cooking / preservation / sale → market and inn supply → occasional new maritime opportunities`.

**No single dominant strategy.** Raw sale is easy and fair; processing yields practical benefits and modest incremental value after material/time costs; specific contracts pay a justified premium, not an unlimited money machine. Town contracts must reuse the existing rotating daily house job, stand demand and request systems where appropriate; prevent duplicate claims/XP.

**Farm and town feedback:** A repaired store may sell a few needed items, a functioning market can buy more fish and cold-store goods, one inn guest increases a small number of catering orders; no huge economy-sim complexity for release.

## 6. Skills — Fewer, better tracks

Current ten skills: Farming, Bushcrafting, Carpentry, Cleaning, Cooking, Fishing, Forestry, Mining, Smithing, Combat; cap 10. Their existing XP keys, current gates and story rewards remain until a source-verified migration is approved.

**Tentative redesign:** retire Cleaning as standalone skill while retaining tidy/cleanse/comfort; consider merging Forestry into Bushcrafting/Carpentry if distinct chopping/mastery loops are not compelling. Keep Farming/Cooking/Fishing/Carpentry/Bushcrafting/Mining/Smithing/Combat if useful. Conditional later Seamanship only if real boating/deck/route actions offer a distinctive mastery loop independent of catching fish. Avoid generic 'Trading' or 'Construction' if existing skills suffice.

**Reward rule:** levels should unlock ability, variety, convenience, identity or prestige; no arbitrary XP grind and no mandatory 10s for story closure. Honor existing level caps and thresholds unless measured evidence justifies change.

## 7. People — Community before content

Existing canon: Maren, Davy, the vicar and postman, plus known figures in the story. Their heart/schedule/request/ending systems are protected.

Candidate Wicker Cove working residents: **Edith** innkeeper, **Gideon** fisherman, **Thomas** storekeeper, **Martha** fishmonger (names NOT canon). Start with two working new residents only when the town slice exists, one order and one personal follow-up each. Reuse existing FolkSystem, not a parallel relationship mechanic.

**Relationship design:** You learn about their jobs before secrets. 0–10 hearts can open comfort, greater trust and optional requests, but a player should never need to grind friendship to buy basic supplies or beat the established story.

**World independence:** A fisherman can be away at sea without the player; shopkeeper tends shelves; innkeeper prepares rooms. Minimal believable schedules beat elaborate AI. Town can be friendly, skeptical or guarded, with different individual reasons.

## 8. Horror and uncertainty — A slow-burn grammar

- Every day is allowed to be mundane. If uncanny events are constant, they stop being uncanny.
- Prefer contradiction, environmental evidence, sounds, limits of visibility, old correspondence, and behavior to explicit explanatory exposition.
- Keep distinction between the **Hollow's authored bell/keeper lore** (revealed by current pages and endings) and the **fog mystery** (uncertain history, no official cause).
- Fog clue examples *only proposed*: incompatible harbor weather logs, a lookout facing the concealed sea, a recollected headland light, a chart mark not matched by current navigational story.
- An optional unusual sea trip may leave new questions, not overwrite the main story with a cosmic answer.
- Sanity is an existing mechanic; uncertainty should not automatically punish players who enjoy ordinary fishing, trading or decorating.

## 9. Maritime ambitions: a careful second frontier

**First step (not required for 1.0):** NPC-led fishing boat from Wicker Cove docks, short preparation, one useful deck task, one optional risk/reward choice, successful return and meaningful fish/relationship reward. No owner-controlled physics or own-boat requirement. A 'working day' should be worthwhile even if no supernatural event occurs.

**Later:** discover one nearshore ground → improve fish market demand → make an off-screen shipment to another seaside town → possibly encounter incompatible charts/visibility memories. Ships are not a replacement for farming; player can remain an inland specialist and still progress.

**Release guard:** If a voyage prototype hurts production of stable Wicker Cove, food/orders or inn system, defer it to post-1.0. Never require every new shore and second town for ship.

## 10. Three intertwined progression paths (not parallel quest clutter)

**A. Homestead:** Broken home → functioning crops/food → sheltered routines → upgraded buildings/gear/animal care → comfortable farm → optional mastery and decoration.

**B. Community:** Notice Wicker Cove's needs → farm dispatch → first visit → know merchant/innkeeper → one inn repair → one guest room and broader contracts → optional harbor or fish-market work → long-run relationships and recovery.

**C. Mystery:** First-night dread → Maren and early Hollow sighting → pages, cave, treks and relations → town letter/mill vote/Davy/bell/grove → existing endings and Afterword.

They should **share food/materials, places, time and emotional resonance** but never all be required in lockstep. A player may emphasize one and only sample others.

## 11. Content minimum: what must exist for a credible v1.0

**Release-target must-haves:**
- Stable farm + first-hour onboarding, full 4-stage home, meaningful cooking/storage/survival, playable core skills, seasons and balanced late-game.
- Existing cave, treks, night systems, 17 chapters and three endings remain reachable and tested, with ongoing play after ending.
- Optional home-dispatch order loop using existing stand/mailbox.
- Small usable Wicker Cove with road connection, foggy exterior, functional store/market/depot/inn/docks and a small working NPC cast.
- At least **one** town-owner repair with lasting practical and visual result.
- At least **one** guest-room creative brief with usable placement UI, saved layout and earned reward.
- Input-driven plus human playtest, controller, saves/migration, visual readability, performance/export/release QA.

**Stretch if validated, not obligatory:** more residents and interiors, additional rooms, second harbor district, shoreline interactions, NPC boat trip, new fish grounds, off-map route trade, extra skill, multiple festivals, expanded decorating sets and rare uncanny sea voyage.

**Not in target:** open-ocean physics, multiple large playable coastal towns, multiplayer, generic procedural 100s of villagers, constant raid events, new mandatory survival meters, new mandatory social currency, a redesigned farmhouse footprint/second story or new porch, a fully explained fog, AAA asset count.

## 12. Engineering and UX contracts

- Godot 4.7, locked UI theme, camera perspective and pixel scale; avoid scene rewrites if extension can be integrated.
- Preserve main-world timing and save data/older saves. Any removed skill requires explicit conversion and story achievement test.
- Farmhouse and NPC/contract status in data; scenes/visuals read state rather than duplicate progression flags.
- Single request system / reward ledger for daily job, walker help, contracts and building repairs where practical, so users can't exploit overlapping claims.
- Shared world time and transitions; entering Wicker Cove or a voyage shouldn't reset need timers or create untracked day skips.
- Avoid UI sprawl: existing diary, Building panel, NPC dialogue, stand/mailbox, skills/quests.
- Accessibility: never obscure critical interactions behind fog; high contrast for HUD/menus, clear controllers, pause behavior, warnings for risky travel.
- Preserve static main menu, balanced night brightness, lantern radius-only upgrades, farmhouse no second storey or porch scope.

## 13. Task ownership and priority gates

**P0:** Any crash, save corruption, progression block or regression takes precedence.

**P1 immediate/near-term:** CCH-EVENING-002 result review; CCH-FOOD-001 actual food/economy audit; CCH-SKILLS-REVIEW-001 current skill redundancy + save gate; CCH-ORDERS-001 dispatch design/prototype after price audit; CCH-SURVIVAL-001; CCH-PLAYTEST-001 first 14 days. Design-only P1 dependency work for Wicker Cove canon/lore (PEOPLE-001A, ECON-001, FOG-001 and COAST-WORLD-001).

**P2 core depth in targeted sequence:** daytime/seasonal/winter additions; LOWMERE-001 small district; PEOPLE-001B first NPCs; LOWMERE-BUILD-001 one inn repair; INN-001 first one-room decorating; selected fish-market and optional coastal shoreline loops; long-term world reactivity, story integration and economy balance.

**P3/stretch:** boats beyond first tested working trip, extra coastal routes/towns, deep water mysteries, countless decoration variants, expanded hotel guests/rooms, major festivals and nonblocking polish.

**Milestones (stop/go):**
- **M1 First fortnight is fun:** first harvest, first trek, night/home, saves, cooking.
- **M2 Work has economic purpose:** decent food/preservation and optional dispatch orders.
- **M3 A full seasonal cycle has choices:** winter and post-harvest afternoons, non-trek progress.
- **M4 Wicker Cove exists:** functional entry/trade/return, local fog and a person worth knowing.
- **M5 A real repair changes town:** visual/function/social consequences.
- **M6 One guest room feels creative:** layout, brief, feedback, persistence.
- **M7 Existing story complete & life continues:** all three endings with new world, no blockers.
- **M8 Distribution-ready:** human-playable, export, save/version, controller, perf, accessibility, art/audio/license and stability tests.

## 14. Concrete small content prototype: 'A reason to stay'

**First visit to Wicker Cove**, future approved vertical slice:
- The farmer walks downhill into the all-day fog; salt dampness, a lantern, a worn inn and 1–2 people working.
- An innkeeper offers a small produce order; the fishmonger or storeowner can buy an existing item; town interaction is immediately useful.
- The inn has one visibly boarded guestroom. A later material job makes it usable, and one customer asks for a small, functional, warm room.
- A fishing boat can be seen tied to a pier, suggesting future routes without requiring boat physics yet.
- A resident innocently disagrees about whether the sea has ever been visible from town. The dialogue offers no objective answer.
- Player returns to the farm with coins/materials or a purpose, and can still spend the evening at home.

**What this proves:** farm ↔ village commerce, friend/story tone, permanent fog, optional construction/creative loop, and a world promising more than one main quest.

## 15. Design principles for future brainstorming

Every proposed feature must answer:
1. What fantasy/feeling does it strengthen?
2. What meaningful player action occurs (not just a menu)?
3. What existing system does it deepen rather than duplicate?
4. What is the **smallest** playable slice?
5. What remains fun on the second/20th use?
6. Does it burden a relaxed farmer, destroy suspense or create an XP/coin exploit?
7. What source code, lore, asset and save gates need verification?
8. Is it necessary for 1.0, a post-launch opportunity or simply a mood concept?

**Creative north-star scene:** Late autumn after many seasons. A restored, inhabited farmhouse has food for winter and a warm hearth; a letter from Wicker Cove thanks the player for a useful repair; a fisherman returns safely from sea. The farm and village have become worth protecting. The woods remain dark, the fog remains permanent, and some things remain unexplainable. The player feels they **belong**, not that they have conquered everything.

**This document changes no code, story chapter, art or numeric gameplay balance.**


## 2026-11-14 — Owner-approved foundational pillar: player-authored adventure

**The experience should be choose-your-own-adventure across the entire world, with no universally right/wrong way to play.** Decisions should change outcomes over time across farming, trade, construction, personal relationships, exploration and story. Hidden tabletop/d20-inspired checks may resolve uncertain actions using **existing relevant skills, preparation, relationships and circumstances**, but never randomly determine the established story endings or soft-lock essential progression. Favor degrees of consequence, recovery paths and later callbacks over one-off flavor options. Protect a relaxed, careful player just as much as an adventurous risk-taker. All specific numbers and story branches require design approval before implementation.

Detailed foundational design: [CHOICE_CONSEQUENCE_SYSTEM_DESIGN.md](CHOICE_CONSEQUENCE_SYSTEM_DESIGN.md). **P1 CCH-CHOICE-001A/B** (existing choice/branch audit, hidden-resolution spec), **P1 CCH-CHOICE-001C** (three-decision farm-side prototype only after approval), **P2 CCH-CHOICE-LOWMERE-001** (town dilemma), **P3 CCH-CHOICE-MARITIME-001** (optional future crew decisions), **P1 CCH-CHOICE-QA-001** (branch/save/ending verification). This is an ongoing design lens, not a new enforced moral meter or replacement for the 17-chapter story.


## 2026-11-14 — Personal stories that persist in the diary

Player-created adventure is strengthened by **branching resident arcs** that preserve NPC agency and **a personal diary** of verified decisions and later consequences. The journal already has a full book/page-turn/handwriting engine; add compact, author-written memory pages from saved facts rather than rebuilding or generating ungrounded prose. Agnes Rook's pages and authoritative StoryAct lore remain immutable. See [BRANCHING_RESIDENT_ARCS_AND_PLAYER_DIARY.md](BRANCHING_RESIDENT_ARCS_AND_PLAYER_DIARY.md). P1 first gate: an existing farm choice with two distinct diary pages and a callback, before full Wicker Cove story lines. This is design-only.

## 2026-11-14 — First-year choose-your-own-adventure plan and pitch

Proposed back-cover synopsis and mapped October (first-night/neighbor), winter (provisions), spring (Wicker Cove approaches and fog accounts), summer (work/repairs/exploration), and September (truthful personal diary recap) are in [YEAR_ONE_BRANCHING_NARRATIVE_DESIGN.md](YEAR_ONE_BRANCHING_NARRATIVE_DESIGN.md). The story spine remains 17 chapters; the first-year optional web should eventually feed callbacks into year two without putting canonical mill/Davy/bell outcomes behind chance. Day 240 is late May in the actual calendar. No implementation authority.

## 2026-11-14 — Literary depth / plain-language style mandate

Owner established **literary ambition in plain English** as a core narrative quality requirement. [NARRATIVE_VOICE_AND_LITERARY_STANDARDS.md](NARRATIVE_VOICE_AND_LITERARY_STANDARDS.md) guides environmental text, speech, letters, Agnes's authored pages and the player's factual diary. No overwrought purple prose, generic atmospheric exaggeration, omniscient judgements of player emotion or definitive Wicker Cove fog answers. Small human actions carry meaning. Future spring story/first Cove arrival uses this rubric. Editorial design only; unchanged game scripts.

## 2026-11-14 — The second autumn and after the endings: personal consequences, canonical story preserved

[**YEAR_TWO_COST_OF_STAYING_DESIGN.md**](YEAR_TWO_COST_OF_STAYING_DESIGN.md) extends player-authored everyday life into second-calendar-autumn Davy and bell climax, then the continuing farm after any of the original three endings. The actual 'second-year story' code begins at day240 before year2 calendar October; do not defer its story triggers. Support quiet homesteaders as fully as community-minded or mystery-seeking players, keep Davy's original time-limited night and recoverable Hollow outcome, and make player history felt through small truthful memories rather than moral grading or rewritten Rook lore. Design only.

## 2026-11-14 — Living community / emotionally specific writing

The long-horizon character system is defined across [LIVING_COMMUNITY_RELATIONSHIP_WEB.md](LIVING_COMMUNITY_RELATIONSHIP_WEB.md), [SCENE_ANTHOLOGY_AND_CHARACTER_VOICE_BIBLE.md](SCENE_ANTHOLOGY_AND_CHARACTER_VOICE_BIBLE.md) and [RESIDENT_ARCS_TWO_YEAR_BLUEPRINT.md](RESIDENT_ARCS_TWO_YEAR_BLUEPRINT.md). Major residents have lives independent of player, practical desires and human limits; relationships exist *between* people. Community responses arise via traceable mail, workplace, witnessing and trade, never omniscient reputation. Twelve short, plain-language sample scenes reinforce work, humor, remembered objects and restraint. Eight linked optional arcs span year-one seasons, the second autumn and life after endings; don't add them wholesale before small proof. [LIVING_WORLD_PRODUCTION_BLUEPRINT.md](LIVING_WORLD_PRODUCTION_BLUEPRINT.md) defines smallest existing-farm side-branch + callback + personal diary test and staged expansion into logs/planks, orders and two-worker town. **Wicker Cove postman name/history conflict** recorded in [WICKER_COVE_POSTAL_LORE_CONTINUITY_AUDIT.md](WICKER_COVE_POSTAL_LORE_CONTINUITY_AUDIT.md); do not invent a second Lowmere or erase original bell/mail correspondence. Design only.

## 2026-11-14 — Ordinary life throughout every month and a sample complete inn story

[YEAR_ROUND_COMMUNITY_RHYTHMS.md](YEAR_ROUND_COMMUNITY_RHYTHMS.md) gives each of the 12 months an ordinary working rhythm, season changes and one small conditional callback without inventing monthly mandatory content. [WICKER_COVE_LIVED_IN_DISTRICT_BIBLE.md](WICKER_COVE_LIVED_IN_DISTRICT_BIBLE.md) translates a fogbound struggling harbor into one navigable useful first district rather than a horror park. [INN_ROOM_BRANCHING_STORY_PROTOTYPE.md](INN_ROOM_BRANCHING_STORY_PROTOTYPE.md) provides a specific plain-language example where workbench-made planks have real competing uses at farm and inn, an owner negotiates a paid repair, a guest has clear room requirements and one lit window remembers actual player labor into Year Two. These are proposals; new town/cast/quests are not implemented or blanket approved.

## 2026-11-14 — First-month grounded playable experience

[**FIRST_30_DAYS_LIVING_WORLD_VERTICAL_SLICE.md**](FIRST_30_DAYS_LIVING_WORLD_VERTICAL_SLICE.md) is the smallest integrated playable expression of the project: one visible forest woodcutting destination → logs → workbench-hewn planks → useful house improvement; an optional Old Maren choice at or after her real first woodland trek; one delayed verified response and personal diary; current first-night and first-crop chapter progression intact. New town/cast/guestroom design belongs later. Explicit source audit and owner approval per implementation slice. No script edits currently.

## 2026-11-14 — Player identity and the philosophical heart of the game

[PLAYER_IDENTITY_AND_HOME_STORY_BIBLE.md](PLAYER_IDENTITY_AND_HOME_STORY_BIBLE.md) makes **inheritance is not belonging** the creative organizing tension, with independent ownership/belonging/responsibility and five nonexclusive lives formed through observable acts, not classes. [HOUSE_MEMORY_AND_PLAYER_DIARY_ATLAS.md](HOUSE_MEMORY_AND_PLAYER_DIARY_ATLAS.md) uses house, table, hearth, workbench, gate and forest edge to return small true details at different stages. [MEANINGFUL_CHOICES_AND_REVELATION_ARCHITECTURE.md](MEANINGFUL_CHOICES_AND_REVELATION_ARCHITECTURE.md) maps original source beats and eight tangible tradeoffs to slow recontextualization; [NARRATIVE_QUALITY_BENCHMARK_AND_RED_TEAM.md](NARRATIVE_QUALITY_BENCHMARK_AND_RED_TEAM.md) defines anti-melodrama, agency, consequence and genuine playtest standard. Theme, sample lines and optional dilemmas are **design-only**. Do not move day240 letter, change town vote evidence, rewrite existing post_hand/Davy/grove, or solve permanent fog. The first-month playable proof remains the efficient next implementation review, after approval.

## 2026-11-14 — Interactive opening before first morning on the farm

[**PLAYER_ARRIVAL_INTERACTIVE_PROLOGUE_DESIGN.md**](PLAYER_ARRIVAL_INTERACTIVE_PROLOGUE_DESIGN.md) adds a short optional choice-shaped personal prehistory, modeled on Firewatch's interwoven text/travel **method** without copying its characters, tragedy or plot. Player can come for stability, work autonomy, life change, curiosity or straightforward opportunity and can preserve one relationship/keepsake or none. The ordinary offer to move onto town-held land is the common bridge to the unchanged first day; the legal word 'inheritance' requires caution because later deed purchase is currently canon. Later letters/diary references must depend on actual prologue choices and not infer grief, love or morality. This enhances the opening while the existing farm/forestry/story loops remain the next production priority. Design only.

## 2026-11-14 — Player's past is half the story, mandatory interlude

Owner rejected both our proposed **optional/skip** treatment and the idea that the player's reason for coming is secondary to why they stay. **Now required:** every new-game player experiences *The Road to Crow Creek Hollow* interlude in full with no Skip. Origin must be as narratively important as the life made here; opening decisions produce a recurring earlier-life strand with a meaningful midyear choice, first-year reflection and postending echo. Do not dictate one tragic origin or let the game judge a reason as right/wrong. Use the [PLAYER_ARRIVAL_INTERACTIVE_PROLOGUE_DESIGN.md](PLAYER_ARRIVAL_INTERACTIVE_PROLOGUE_DESIGN.md) owner-amended requirement, not earlier skippable proposal text. Support pause/resume/reading accessibility and no reduction of October1 gameplay. No code authorized.
