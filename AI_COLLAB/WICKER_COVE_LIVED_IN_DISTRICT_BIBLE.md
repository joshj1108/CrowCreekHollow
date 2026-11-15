# CCH-COVE-LIFE-001 — Wicker Cove as a Real Working Village

**2026-11-14. Design-only environment, social and economic brief.** This does not finalize exact town map, new residents, dates, quests or art nor authorize Godot/PixelLab implementation.
**Respect owner canon:** Wicker Cove is a struggling seaside fishing village down the mountain road from the homestead, constantly under a dense fog bank. Different people and old records disagree about when the fog began. The actual start and cause remain unanswered. Farm is last homestead before woods; treks begin at farm; boating would begin at harbor; existing Rook events/endings remain unchanged.
**Existing source:** `LOWMERE_FIRST_DISTRICT_DESIGN.md`, `LOWMERE_ECONOMY_HISTORY_DESIGN.md`, `LOWMERE_COASTAL_WORLD_DESIGN.md`, `LOWMERE_RESIDENTS_DESIGN.md`, `LIVING_COMMUNITY_RELATIONSHIP_WEB.md`, `RESIDENT_ARCS_TWO_YEAR_BLUEPRINT.md`, `NARRATIVE_VOICE_AND_LITERARY_STANDARDS.md`.

## Identity in one sentence
**A harbor that still works, even though fewer people come home to it every year.** Not cursed theme park, abandoned fishing ghost town, prosperous resort, city of perpetual gloom or extension of the Rook farm's supernatural logic.

## Three things the player should notice before speaking to anyone
1. **Work:** someone repairing nets, sorting fish, sweeping steps, or bringing in crates, even though business is quiet.
2. **Wear:** a patched roof beside a boarded window, repairs of different ages, usable dock sections beside unsafe timbers.
3. **Warmth:** at least two interior windows glow through fog. Someone is making soup. The village is still someone's home.

**Arrival tone:** 'You smelled the sea before you saw the water.' That is enough. Let footsteps, gulls and industry tell story; don't deliver a lore monologue at entrance.

## Compact physical district, proposed / not final map
Use a short, readable downhill approach transitioning from tree-lined mountain road to a single crooked village main street that terminates near a working harbor edge.
- **Landward road entrance:** winding road behind, hand-painted sign with **Wicker Cove**, damp stone, perhaps a visible delivery cart. The player can easily recognize route back to farm; no maze.
- **General store:** first functional stop near route entrance, door and counter clearly readable. Outdoor sacks/rope, stocked and empty shelves inside. Basic shop remains available even if seller doing an ambient task.
- **Inn:** farther downhill, slightly uphill relative to docks but within compact village; common room with hearth and one persistent upper room later used for renovations. Should not resemble a luxury hotel.
- **Fish market:** close to working pier, timber awning, scales, sturdy boxes, fish smell/flies/cleaning water, but art readable at game resolution.
- **Orders depot/receiving point:** may share store or market rather than be a large new building. Route for farm stand/mailbox dispatch fits.
- **Working slipway and small pier:** boats of credible size, some usable/other laid up, modest mooring posts; not giant shipyard.
- **A few homes:** small, lived-in with smoke, washing and repaired shutters. Most nonenterable; interior focus stays on useful core buildings.
- **Small public notice board** optional: actual orders, one announced festival date if ever approved, no infinite daily errands.

**First slice** requires 1 outdoor scene, 1–2 enterable interiors, store trade, one useful order and one human conversation. Other anchors can exist visually until later.

## Scale / pixel art notes
Top-down 3/4 view, the same camera/proportions/tile density as current farm/player, not isometric or a detailed illustrated map that cannot produce sprites. Keep lantern and window lighting warm without overwhelming fog at normal day brightness. No big purple crystal formations, giant skeletal ships, or every building flying tattered banners.
Fog should conceal depth but not hide collisions, doors, shop names, NPCs or exits. Use ground layers and clear silhouette/interaction prompt, not text-only guidance for a navigation maze.
Architecture: modest painted/shingled clapboard, salt-darkened wood, slate or patched roofs as appropriate for a PNW harbor, dirty glass, ropes and timber posts; **not** all-black gothic fantasy architecture. Rustic gothic emerges from age, damp and unspoken history.

## Sound and everyday atmosphere
- **Approach:** wind through firs changes to gulls, wet road and distant hammer.
- **Market:** crates set down, hand scales clink, a small trickle of wash water, muffled talk.
- **Pier:** water lapping timbers, rope rubbing post, net repair, distant boat horn only if technology/style supports it.
- **Inn:** dishware, hearth, chair scrape; full warm soundscape contrasts outside fog.
- **Store:** page turn, wooden drawer, coins, a bell at door if it fits established art.
- **Fog:** not inherently an ominous drone every hour. Sometimes people are simply working. Rare wrong-sounding moments more effective if ordinary sounds are familiar first.
- **Seasonal difference:** cold winter winds and fewer boats, spring paint/repairs, summer more stacked fish baskets, autumn preservation; fog remains constant.

## What each resident's location communicates (candidate)
- **Edith (inn):** buckets under leak *only until repaired*, folded sheets, borrowed chair from lobby, common room warm. Her hospitality is practical.
- **Thomas (store):** empty shelves not empty life, some handwritten account slips, a repaired scale. His caution is tangible.
- **Martha (market):** she cleans the space, keeps fresh/old fish distinct, doesn't tolerate wasted catch. Her work is skilled.
- **Gideon (slipway):** nets, a patch on hull, worn coat hung where reachable, boat prepared despite fog. He is competent, not a mad sea seer.
**Initial cast:** only owner-approved two have full dialogue and tasks. Other two may be later placed as ambient workers only with explicit approval/art.

## A realistic 1-visit loop, 420-second day compatible
1. Player completes some morning farm tasks.
2. Travel via short transition with enough visual changes to imply downhill distance, **not** literal real-time hour walk. Use existing farm gate, preserving mailbox/stand locations.
3. First time: one short scene at pier or store (3–5 lines), readable sign for shop and route home.
4. Buy something legitimately useful, or deliver/sell actual held goods. An optional small request can be accepted without penalty for declining.
5. Walk by harbor, see fish market and inn from street, possibly learn a name and one contradictory ordinary claim.
6. Return to farm before dark unless player deliberately chose late travel. Day clock, hunger, thirst and comfort remain consistent; don't teleport to wrong date.
7. **One later human callback** when player repeats a real transaction. No forced 'welcome to our community' speech.

## The inn's first guest-room story
**Precondition:** owner-approved inn and repair system, available planks through real workbench (if implemented) and real furniture/items.
**Part 1, 'Dry Walls':** Edith requests repair estimate. Player sees actual bill of materials with a real project cost. Choices: do paid work, exchange goods, defer. There is no hidden social demerit. Edith may patch temporarily.
**Part 2, 'A Room for Someone':** after structural work complete, one room now persistent and accessible. A client brief asks for **clear necessities** (bed, accessible entry, light) and one personal preference (e.g. quiet corner for writing, a chair near window). These are judgeable from actual layout, not arbitrary attractiveness score.
**Part 3, 'The Guest':** completed room earns bounded coins/experience and a later guest response; guest is a person with a need, not a 10-point satisfaction bar. Player can adjust/decorate later, at valid cost. Never force huge hotel empire loop.
**Example guest briefs (candidate):**
- A working crew member wants a dry bed, a hook for coat/boots and a light by the door.
- A traveling schoolteacher or bookkeeper wants a writing table and window lamp, without promising the fog ever clears.
Each brief should be doable with limited starter furniture and a few optional decorative extras.

## Work contracts as social storytelling
Store, inn, market and harbor each need **one tangible functional improvement** that is visible and useful. First release should only complete one or two:
- Store shelf: stocks 1–2 useful items after repair/regular supply.
- Inn roof/room: a guest stays and one new order becomes available.
- Market cold room: preserves some fish longer using already supported spoilage/item system (if none exists, avoid invented 'spoilage metric' until separately specified).
- Pier rail/small slip: safe access to one boat interaction if sea feature built later.
The farmer should be able to earn wages for skilled work; don't force voluntary free labor as moral default. Owners contribute their own materials and decisions.

## How the town lives without the player
The village must not wait silently for one farmer:
- Thomas sometimes gets a shipment from another supplier (delayed and smaller).
- Edith can use buckets and patch her own room slowly if not hired.
- Martha sells/gives/preserves what fish she has; Gideon adjusts fishing hours.
- An ordinary household can refuse help or find someone else, without locking entire service indefinitely.
- Work progresses in *small predetermined steps*, not a resource-accurate simulation for every offscreen NPC. Avoid punishing the player for skipping weeks.

## Layers of Wicker Cove's unanswered fog
**Ordinary working adaptation:** residents know to tie bright rope or sound horns when visibility poor; this is practical response to dense fog.
**Contradictory witness memory:** older fishermen recall seeing headland, another resident sincerely insists it was never clear, ledgers disagree.
**Material evidence:** harbor chart bearing an obsolete sightline, inn painting facing sea, old watchpost; none proves historical onset, let observer assess.
**Respect unknown:** no roll, bell repair, elder NPC speech or hidden ending reveals the objectively true date/cause. Do not secretly imply that the fog must dissipate after Grove ending.

## Five original visual micro-moments
1. **Two pairs of boots drying near the inn stove** even on a nearly empty night; people still meet.
2. **A wooden counter repaired with a different kind of wood** after one actually paid contract.
3. **A boat's net lifted with a handful of small fish**, not a magically overflowing catch after one task.
4. **A harbor chart inked over and annotated**, but not an objective mystical map.
5. **A lit upper inn window** where a boarded room used to be, if completed. A simple image can be stronger than fifty lines of congratulations.

## Geography / lore safeguard
The postman's `post_round/post_crate/post_dead` originally refer to old Lowmere over hills, Agnes correspondence and bell iron. Official Wicker Cove is downhill coastal. This **must be reconciled** through `WICKER_COVE_POSTAL_LORE_CONTINUITY_AUDIT.md` before adding new shipping or ledger narratives. Don't pre-emptively declare bell forged locally, old women living on a particular street, an older hidden lighthouse, a second village or fog origin.

## Playability and test gates
- **Map:** one clear road in/out, no collision traps, camera/scale same as farm.
- **Daily life:** 2 workers present in sensible locations at accessible hours; basic services reachable; player retains agency.
- **Economy:** 1 actual purchase + 1 bounded order/contract; save/transaction cost exact; no infinite payment loop.
- **Art:** fog readable, silhouettes accessible, true PNW/coastal mood and warm inn windows.
- **Social:** one human exchange and one later reliable callback from a plausible contact.
- **Story:** original walker/letter/meeting/grove unaffected; permanent fog without resolved date.
- **Town without player:** at least one offscreen owner contingency, no dead town.
- **Future proof:** room layout persists if room feature built, future boat only if tested.

## Tasks / dependencies
- `CCH-COVE-LIFE-001` P1 Design: this working district identity and loop.
- `CCH-COVE-LIFE-002` P1 Audit: existing farm gate/scene transition and map scale; site plan/one street.
- `CCH-COVE-CAST-DECISION-001` P1 Owner decision: first two character identities, names/appearance and which first interior.
- `CCH-COVE-LIFE-SLICE-001` P2 gated: one street, functional store/inn, one resident, one order, warm fog and return.
- `CCH-COVE-INN-ROOM-001` P2 gated: actual room structural repair then layout/client brief only after successful first visit.
- `CCH-COVE-HARBOR-001` P2/P3 conditional: working pier, one compact genuine crew trip only if worthwhile.
- `CCH-COVE-LIFE-QA-001` P1 eventual: first-visit and long-play integration, seasonal fog/weather, control/readability, choice memory, no town visit branch and original endings.

**The district is design proposal; Wicker Cove's owner-confirmed location, name, permanent fog and uncertain chronology remain canon.**
