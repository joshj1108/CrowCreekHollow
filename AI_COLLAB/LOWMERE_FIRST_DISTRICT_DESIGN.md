# LOWMERE — First District and Farm-to-Town Economy Design
**Version:** 0.1 — 2026-11-14  
**State:** DESIGN ONLY. No Claude implementation authorization.  
**Parent:** `AI_COLLAB/DEVELOPMENT_ROADMAP.md`.

## Established owner canon
- Lowmere is a dreary, failing seaside fishing village **down the mountain road** from Crow Creek Hollow farm.
- Crow Creek Hollow is the last homestead/closest settled stop before the woods; wilderness treks rightly start at the farm.
- Lowmere is covered by a dense, persistent fog bank **24/7**. The town/coast would otherwise be visible from the elevated farm.
- Preserve the approved farm map, gate, road, original treks and art direction. The farm remains the emotional home base.
- The supplied Lowmere concept art is a **mood and composition reference**, not pixel-perfect production assets or binding map geometry.

## First playable district — proposed, not canon geometry
The descending mountain road enters the upper/landward edge; a muddy, modestly sloped village street leads to a short harbor frontage. The permanent fog obscures the water beyond nearby boats and piers. Buildings are worn, salt-stained, repaired with mismatched timber and metal; warm interior light implies people still endure there. Avoid a bustling or magically glowing port.

**Five functional anchors, minimum viable slice:**
1. **General store:** supplies, basic trade, selected resident contracts.
2. **Fish market:** fish/coastal ingredients, seller interaction, fish-related requests.
3. **Delivery depot / order handoff:** town orders, partial fulfillment, direct handoff.
4. **Inn/tavern:** small social space, conversation/rumors, optional modest food/recovery; first or second interior if resource budget permits.
5. **Dock edge:** visible boats/nets, modest fishing/forage interaction, occasional environmental clue; not sea travel.

**Build strategy:** prototype one compact outdoor district, 1–2 interiors maximum, a very small NPC cast, scene transition from existing farm gate via a short road approach. Verify actual clock/travel time, map perspective and tile scale, saves and collisions before integrating production art. Do not add a second farm or large town sim.

## Exchange: why Lowmere needs the farm
- **Farm → village:** vegetables, fruit, eggs, goat products, firewood, cooked meals and preserved food, chosen from goods actually present in the game.
- **Village → farm:** saltwater fish, salt, rope, select hardware/fishing supplies and information, contingent on existing item audit before introducing new inventory types.
- Use the existing **coins** economy and farm market stand/mailbox; no second money system or standalone duplicate quest engine.
- Preserve the ability to sell surplus quickly. Specific orders grant *bounded* extra value/relationships/skill experience after economy tuning, not extreme multipliers.

## Orders system — first prototype BEFORE town map
- **Household request:** small, forgiving everyday produce/fish request, no harsh miss penalty.
- **Business contract:** medium mixed-goods request encouraging skill/production variety; optional deadline only if comfortably achievable.
- **Community commission:** rare milestone contract with narrative acknowledgment, not routine grind.
- Offer a small pool of rotating requests adjusted to player's unlocked crops, seasons, inventory and production ability. Player may accept, decline and deliver in parts. Prevent save-scumming rerolls, repeat-turn-in rewards, impossible deadlines, accidental sale of reserved goods, and overwhelming requests.
- **Farm dispatch** through existing stand/mailbox; **direct town delivery** once Lowmere opens. Neither route should dominate by compulsory travel. Test baseline sale income versus order premiums using CCH-FOOD-001 audit.
- The source design inspiration is Molehill Empire customer orders; don't reproduce proprietary art, names or exact mechanics.

## Progression and character integration
- Skill mastery remains compatible with current XP, levels, saves and unlocks; audit first. Farming+Cooking+Trading / Fishing synergies are design candidates only. Prefer capability unlocks over repetitive XP-only grinding.
- Reconcile existing canon: Agnes Rook, Maren, Davy, the vicar and postman, chapel/mill, the town vote, the farm's repeated ownership and the 'keeper' mystery. Their current events and travel timing must not be rewritten casually.
- First arrival should provide one useful purchase, one achievable order and one subtle context-setting conversation/discovery (not a story reveal or forced combat encounter).
- **Atmospheric contrast:** the farm is solitary but becoming welcoming; Lowmere is inhabited yet slowly failing. Fog is constant across time/season but may change density locally; do not imply a known supernatural cause unless the owner later chooses one.
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
- Whether players can fish from the Lowmere docks and how saltwater catches differ from the farm pond.
- What is behind the persistent fog, if anything; preserve mystery rather than assign a definitive explanation.
- Exact town map geography, harbor orientation, architecture palette and NPC schedules.

**No code, map, art production or quest rewrites authorized by this document.**
