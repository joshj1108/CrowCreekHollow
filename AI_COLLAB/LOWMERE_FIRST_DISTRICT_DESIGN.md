# LOWMERE — First District and Farm-to-Town Economy Design

> **Naming update (2026-11-14):** **Wicker Cove** is the official in-world name. Legacy `CCH-LOWMERE-*` task IDs and `LOWMERE_*` document paths are retained as stable project identifiers; they do not indicate a second town. All previous lore and design commitments are preserved.
**Version:** 0.1 — 2026-11-14  
**State:** DESIGN ONLY. No Claude implementation authorization.  
**Parent:** `AI_COLLAB/DEVELOPMENT_ROADMAP.md`.

## Established owner canon
- Wicker Cove is a dreary, failing seaside fishing village **down the mountain road** from Crow Creek Hollow farm.
- Crow Creek Hollow is the last homestead/closest settled stop before the woods; wilderness treks rightly start at the farm.
- Wicker Cove is covered by a dense, persistent fog bank **24/7**. The town/coast would otherwise be visible from the elevated farm.
- Preserve the approved farm map, gate, road, original treks and art direction. The farm remains the emotional home base.
- The supplied Wicker Cove concept art is a **mood and composition reference**, not pixel-perfect production assets or binding map geometry.

## First playable district — proposed, not canon geometry
The descending mountain road enters the upper/landward edge; a muddy, modestly sloped village street leads to a short harbor frontage. The permanent fog obscures the water beyond nearby boats and piers. Buildings are worn, salt-stained, repaired with mismatched timber and metal; warm interior light implies people still endure there. Avoid a bustling or magically glowing port.

**Five functional anchors, minimum viable slice:**
1. **General store:** supplies, basic trade, selected resident contracts.
2. **Fish market:** fish/coastal ingredients, seller interaction, fish-related requests.
3. **Delivery depot / order handoff:** town orders, partial fulfillment, direct handoff.
4. **Inn/tavern:** small social space, conversation/rumors, optional modest food/recovery; first or second interior if resource budget permits.
5. **Dock edge:** visible boats/nets, modest fishing/forage interaction, occasional environmental clue; not sea travel.

**Build strategy:** prototype one compact outdoor district, 1–2 interiors maximum, a very small NPC cast, scene transition from existing farm gate via a short road approach. Verify actual clock/travel time, map perspective and tile scale, saves and collisions before integrating production art. Do not add a second farm or large town sim.

## Exchange: why Wicker Cove needs the farm
- **Farm → village:** vegetables, fruit, eggs, goat products, firewood, cooked meals and preserved food, chosen from goods actually present in the game.
- **Village → farm:** saltwater fish, salt, rope, select hardware/fishing supplies and information, contingent on existing item audit before introducing new inventory types.
- Use the existing **coins** economy and farm market stand/mailbox; no second money system or standalone duplicate quest engine.
- Preserve the ability to sell surplus quickly. Specific orders grant *bounded* extra value/relationships/skill experience after economy tuning, not extreme multipliers.

## Orders system — first prototype BEFORE town map
- **Household request:** small, forgiving everyday produce/fish request, no harsh miss penalty.
- **Business contract:** medium mixed-goods request encouraging skill/production variety; optional deadline only if comfortably achievable.
- **Community commission:** rare milestone contract with narrative acknowledgment, not routine grind.
- Offer a small pool of rotating requests adjusted to player's unlocked crops, seasons, inventory and production ability. Player may accept, decline and deliver in parts. Prevent save-scumming rerolls, repeat-turn-in rewards, impossible deadlines, accidental sale of reserved goods, and overwhelming requests.
- **Farm dispatch** through existing stand/mailbox; **direct town delivery** once Wicker Cove opens. Neither route should dominate by compulsory travel. Test baseline sale income versus order premiums using CCH-FOOD-001 audit.
- The source design inspiration is Molehill Empire customer orders; don't reproduce proprietary art, names or exact mechanics.

## Progression and character integration
- Skill mastery remains compatible with current XP, levels, saves and unlocks; audit first. Farming+Cooking+Trading / Fishing synergies are design candidates only. Prefer capability unlocks over repetitive XP-only grinding.
- Reconcile existing canon: Agnes Rook, Maren, Davy, the vicar and postman, chapel/mill, the town vote, the farm's repeated ownership and the 'keeper' mystery. Their current events and travel timing must not be rewritten casually.
- First arrival should provide one useful purchase, one achievable order and one subtle context-setting conversation/discovery (not a story reveal or forced combat encounter).
- **Atmospheric contrast:** the farm is solitary but becoming welcoming; Wicker Cove is inhabited yet slowly failing. Fog is constant across time/season but may change density locally; do not imply a known supernatural cause unless the owner later chooses one.
- Distinctive early town narrative: declining catch, patchwork repairs, shortages, boarded structures, ongoing domestic life. Keep mystery emerging from consequences and behavior, not staged jump scares.

## First visit — experience storyboard
1. Complete morning chores and leave via farm gate.
2. Walk downhill; coastal damp, muted gulls and sound; the fog bank progressively conceals distance.
3. Enter a compact harbor street, find the store/market/depot.
4. Meet a local seller, hear a grounded hint, get access to one reasonable order.
5. Return home in time to choose how to spend the evening; no punitive travel grind.

## Design and feasibility gates
1. **CCH-FOOD-001:** audit existing foods, cooking, crops, fishing, price and hunger effects. Establish profitable-but-bounded order values.
2. **CCH-ORDERS-001:** design and then separately approve farm-only 2–3-template order slice. Test actual acceptance, partial turn-ins, funds, save/load, early accessibility.
3. **CCH-SKILLS-001:** audit skill XP and progression; develop milestones relevant to trade and food without replacing saved levels.
4. **CCH-LOWMERE-001:** technical and lore audit of road, scenes, dialogue, time use, 16 px world tiles at 3× and art memory; only then separately authorize district implementation. Do not start with a giant seamless map.
5. Test in-game a 14-day farm loop with orders, first-town visit, return before night, and different play styles. Human playtesting remains necessary.

## Open owner decisions (not canon)
- How/when town visits unlock and whether daily access should be easy.
- Whether the first district includes any accessible indoors besides store/inn.
- How long mountain travel takes and whether a fast, non-punitive return path is needed.
- The number and identities of new town residents; overlap with existing vicar/postman.
- Whether players can fish from the Wicker Cove docks and how saltwater catches differ from the farm pond.
- What is behind the persistent fog, if anything; preserve mystery rather than assign a definitive explanation.
- Exact town map geography, harbor orientation, architecture palette and NPC schedules.

**No code, map, art production or quest rewrites authorized by this document.**


## 2026-11-14 — Owner request: construction assistance and inn guest-room design

**Owner-directed feature concept (design approved for exploration; NOT an authorization to code):**
- The farmer should be able to use construction/building capability to **renovate Wicker Cove buildings on behalf of their owners**, for meaningful compensation and community progress.
- The Wicker Cove inn should offer a **client-briefed hotel room decorating mode**, inspired by Animal Crossing: New Horizons 3.0's themed guest rooms and Happy Home Paradise's interior design freedom, but with original presentation, assets, guests, economy and fiction.
- These are distinct but integrated loops: **structural restoration** unlocks usable room/facility space; **interior commissions** let the player design, furnish and revisit specific rooms. Keep town economically struggling: visible gradual improvement rather than an instant fully restored tourist destination.

### Proposed town restoration loop
1. Speak to an owner about a concrete need (leaking roof, rotten dock, ruined cold room).
2. Accept an optional construction contract; owner contributes some materials, the player contributes gather/craft resources, labor/time and existing relevant progression.
3. Repair stage visibly changes specific tiles/art and restores a basic service.
4. Upgrade stages add capabilities, orders, inventory or improved trade terms, not only cosmetic points.
5. Completion rewards a bounded mix of coins, appropriate **existing** skill XP (verify Construction skill actually exists; do not invent/migrate a skill without design approval), owner relationship progress, furniture recipes, and access to new orders.

**Candidate businesses:** inn (first), fish market, general store, docks. Recommended shared staged renovation framework **Repair → Improve → Restore**; costs/reward figures remain provisional and require an economy and progression audit. Distinguish town business stages from farm's four restoration stages. Preserve owners and their agency.

### Proposed inn-room design loop
- Player first repairs an inn room structurally, then receives a theme/needs brief from a guest or innkeeper.
- A **small grid-based room layout editor** uses existing Godot furnishing/panel input and tile art when feasible; supports valid floor placement, rotations where supported, rugs, wall/floor options and lighting.
- Each brief has a few **objective minimums** (usable bed, path to door, appropriate light, theme request); optional creative bonus, no harsh aesthetic scoring or copying Animal Crossing's exact UI/economy.
- Players may rearrange and revisit completed rooms. Save per-room furniture layout and unlocked theme; protect older saves.
- **No special currency necessary**: coins, modest relevant skill XP and furnishings/recipes/town reputation are possible. Avoid a separate mandatory hotel ticket grind.
- **Prototype:** one inn structural repair + one furnished guest room + two original guest briefs using a small existing furniture set; demonstrate persistent layout, reward, character response and visual before/after. No hotel management empire, tourism simulation, infinite procedural guests, or major new sprite pipeline initially.
- Optional later: several rooms, returning guests, request variety, coastal furniture, inn food orders, subtle mystery encounters. Town always stays dreary and fogbound.

### Relevance to ongoing progression
- **Food:** visiting guests and inn meals can create food delivery demand using CCH-FOOD-001.
- **Orders:** building owners can issue supply contracts within the common CCH-ORDERS-001 framework.
- **Skills:** construction repair and furnishing should support CCH-SKILLS-001's existing progression review; verify actual skills first, do not assume Construction currently exists.
- **World:** repairs visibly improve individual buildings, open services and draw occasional visitors without curing Wicker Cove's decline or fog.
- **Mystery:** guest interactions or a closed room can organically reveal story clues, but not every contract becomes supernatural.
- **Scope gate:** Wicker Cove base map and town service loop must exist before attempting a substantial free-placement designer; avoid making furniture editor a dependency for first playable town.

**New candidate tasks:** CCH-LOWMERE-BUILD-001 (P2, town-owner building repair prototype) and CCH-INN-001 (P2, one-room guest design prototype). Both **Design**, no coding authorization. Owner reviews layout/edit controls, save behavior, rewards and actual game visuals before committing production art.

## Fog history — owner-approved narrative canon (2026-11-14)

**Always fogbound in play, history contested.** Residents' memories and historic records disagree on whether the Wicker Cove fog has always been present or emerged later. The actual history and reason are deliberately undecided; avoid dialogue, signage or level design that inadvertently confirms a date, supernatural cause, or direct link to Agnes's bell. Suggested optional discoveries are a debated childhood sea view, discrepant harbor weather records, and a once-used lookout. All examples remain noncanonical until owner review. See [LOWMERE_ECONOMY_HISTORY_DESIGN.md](LOWMERE_ECONOMY_HISTORY_DESIGN.md) for CCH-LOWMERE-FOG-001/002/003. Fog visually persists across town time/weather/season, while local density can vary for playability.
