# CCH-COAST-WORLD-001 — Lowmere Coast, Fishing Grounds, Voyages and Quiet Mysteries

**Creative exploration draft:** 2026-11-14  
**State:** DESIGN/IDEAS ONLY; no new production map, dialogue, art, NPC, code or feature authorized.
**Related design:** `LOWMERE_FIRST_DISTRICT_DESIGN.md`, `LOWMERE_RESIDENTS_DESIGN.md`, `LOWMERE_ECONOMY_HISTORY_DESIGN.md`, `SKILL_ROSTER_AND_MARITIME_DESIGN.md`, `MASTER_ROADMAP_TO_1_0.md`.

## North star
Make the coastline feel like part of the same inhabited world as the Hollow: ordinary work, seasonal routines, imperfect repairs, community ties, and intermittent unanswerable contradictions. The farm remains the home base; the mountain's forest treks start from the farm, and sea trips start from **Lowmere's harbor**. Players can be a homesteader who never sails, a cook/supplier who supports fishing crews, or a frequent deckhand who occasionally seeks new waters. None needs a separate campaign or skill tree.

## Owner canon (immutable unless owner changes)
- Lowmere is a struggling seaside fishing village below the Crow Creek Hollow farm, at the end of a descending mountain road; the farm is the last inhabited homestead before the forest.
- Lowmere has **a dense coastal fog 24/7**. This is not merely a weather roll or occasional mist; it must not require the farm to be dark or foggy.
- **Fog origin/history is intentionally contradictory.** Some residents sincerely claim it was always present, others remember clear sea horizons, and documents may conflict. **Do not establish an objectively true onset, cause, supernatural explanation, time anomaly or direct tie to Agnes's bell.**
- Original 17 story chapters, four existing walker relationships, Maren/Ruth's minute book, vicar's register, town vote, E. Pell's letter, Agnes/Elias and all three endings remain intact and accessible.
- The inn, merchant, fishmonger and boat captain names proposed in resident docs are **candidates**, not final canon.

## Tentative coastal geography and place identities
1. **The Working Harbor (first Lowmere district):** a working slipway, fish market, receiving counter, nets, aging boats, inn uphill. Trade, contracts and first boat boarding; a few warm windows against cold damp morning.
2. **The Old Breakwater:** stone and timber storm barrier protecting the mouth of the harbor; cracked walkways and a modest old light/beacon, never an obligatory lighthouse/giant landmark. Shore fishing and a possible safe, visible repair.
3. **The Tide Pools:** a small sheltered strand accessible on foot from Lowmere when safe; seaweed, shells, occasional bait or edible coastal foraging after an item-economy audit; not a new exhaustive survival meter.
4. **The Outer Shoals:** nearby low-risk-to-moderate-risk fishing area reached in a brief NPC boat trip. A specific buoy, headland contour or bell-like sound is an *optional detail*, not evidence of fog cause.
5. **The Far Channel:** optional later waterway to a named off-screen settlement; working trade route/manifest rather than a full additional town map. No unlock until basic coastal activity has proved fun.
6. **The Unmarked Water:** *long-term story candidate* for one optional mysterious voyage where mismatched charts and testimony create uncertainty; no objective proof of paranormal causation.

The exact names, coast orientation, inlet shape, distances, lighthouse existence and accessibility are all **not canon**. Avoid placing the mountains inland incorrectly: farm elevated; road descends to town; town opens to the coast; woods extend above/behind farm.

## Concrete working-voyage vertical slice
**A Morning With the Fisherman**, working character concept Gideon Pike if owner approves him:
- Player accepts optional invitation at Lowmere docks; receives understandable prerequisites, supplies and return estimate; no boat ownership required.
- Short loading action (nets, provisions or fuel), departure into permanent fog; harbor visibility fades without going fully unreadable.
- One approachable, player-controlled deck interaction (haul/sort nets or place a catch, with standard controls; no high-action minigame mandatory).
- One real choice: return with the dependable catch or make a longer attempt at a nearby ground, with costs/benefits previewed and a safe route home.
- Return to Lowmere for bounded Fishing XP, share of fish, modest coins and relationship acknowledgment. If eventually Seamanship exists, only distinct seamanship actions award that XP.
- Preserve time-of-day, player health/needs, boat location and loading behavior; explicit save/load handling. No seasickness meter, forced combat, open ocean physics, or irreversible travel lock.
- **Success:** player finds the work cozy even with no supernatural event; at least one useful reward; a second trip offers some variety, not identical dead time.

## Three voyage categories (stage-gated)
**Working trip:** reliable local catch, moderate time investment, economic utility; safe harbor return.
**Survey trip:** locate or recheck a possibly productive ground; daylight and seasonal planning; change in fish types or supply availability.
**Coastwise shipment:** accept a manifest of farm goods, timber or preserved fish destined for an off-screen coastal settlement; return with payment/supplies and possibly traveler rumors. No need to visit a new town map.
A **rare uncertain voyage** is an optional variant and never replaces regular sea work.

## Lowmere's rhythms by season (suggestions, not implementation mandates)
- **Autumn:** active fish preservation, repairs before winter storms, stacked traps, inn's seasonal demand; some fair mornings still fogbound.
- **Winter:** fewer outings and shorter fishing windows, warmer inns, storm repairs and preserved-food contracts; alternative shore tasks for non-sailors.
- **Spring:** crews refit boats and try new grounds; village notices deliveries and the first practical repaired dock.
- **Summer:** longest working days, more coastal trade, inn guests, a livelier (still weathered) harbor.
Avoid simulating a full ocean tide/weather system for v1.0. Reuse seasonal/weather signals and add small deterministic scene states if playtesting proves valuable.

## Relationship and restoration integration
- **Inn candidate (Edith):** restoration allows a real guest; guest supplies modest meal orders or a town rumor, but room decorating remains optional.
- **Fisherman candidate (Gideon):** requires deckhand help, useful boat materials and possibly repair; invites player onto the first working trip. Is not simply an exposition oracle.
- **Fishmonger candidate (Martha):** pays for real catch, processes/preserves fish, participates in the market's recovery; new fishing ground affects a few practical contracts.
- **Store owner candidate (Thomas):** sells needed supplies and handles manifests, trade is about keeping shelves stocked; not a duplicate currency.
- **Existing four walker relationships:** continue their original farm visits and treks. Town sightings cannot conflict with fixed schedules or story scenes.
- Player should help people **help themselves**; town does not miraculously recover because a global bar reaches 100%.

## Optional 'quiet contradiction' encounters — no objective answers
1. **The Unused Lookout:** a repaired or derelict observation post faces a harbor view nobody now sees. One resident says it was for spotting incoming boats through breaks in the weather; another insists those breaks never happened. The structure itself is not proof of an onset.
2. **Two Harbor Logs:** separate ledgers for the same period disagree over visibility. Both could be mistaken, recording different vantage points, using different conventions, or reflect something stranger. Do not force one interpretation.
3. **The Buoy That Isn't on the Chart:** during a safe voyage, a working buoy is sighted or heard at a place marked differently on another chart. Could be navigation error, old mapping, relocated equipment, unreliable memory, or unknown. Nothing definitively bends reality.
4. **A Room Facing the Sea:** an inn's old furniture layout/painting implies a better harbor view; guest and keeper recall it differently. Could be design aesthetics rather than lost clarity.
5. **The Returning Boat:** locals disagree about how long an old vessel was away. Keep the ambiguity about recordkeeping and memory, not a conclusive time-loop reveal.
**All these are story seeds, not written facts/quests.** Use at most 1–3 early, and avoid duplicating the original crow-bell's central sound/signature as a cheap explanation.

## Small-scale world reactivity
- One repaired gangway provides safe access to a boat berth.
- The fishmonger receives additional stock or opens a sensible preservation contract after a working voyage.
- An occupied inn room shows a lit window and occasional guest without adding a sprawling traveler AI simulation.
- A modest shop shelf/notice board changes after a contract; no exponential town economy simulation.
- Ambient work can vary by season and completed buildings, with fog always in place.

## Practical design hazards / tests
- Do not turn the coastal excursion into a separate game that outshines farming, food or woodland survival; first voyage is a prototype after Lowmere is stable.
- Maintain current camera perspective, 16px world art style, Godot scene conventions and stable saves; no full sailing physics or player boat ownership required.
- The world clock is short (~7 real minutes per day per DESIGN.md). Prototype voyage duration must be meaningful *in game* without consuming most of the day or causing punitive late arrivals.
- Coastal fog should support orientation through near-field landmarks and consistent route cues, readable in different accessibility settings; avoid blank white screens.
- Use same coin economy and existing tasks/quests; no extra mandatory currency, hunger meters or nuisance resource upkeep.
- Discovering places should provide usefulness even if no horror clue spawns.
- Old players and saves must retain original story progression and ending routes; new places need explicit scene transfer/save testing.

## Candidate task backlog — priority & status
| ID | Priority | Status | Scope / first gate | Dependencies |
| --- | --- | --- | --- | --- |
| **CCH-COAST-WORLD-001** | P1 **design-only prerequisite** | Design | Lock a compact coast geography and lore compatibility matrix; owner reviews first district and coastal concept | CCH-LOWMERE-001, FOG-001 |
| **CCH-COAST-SHORE-001** | P2 | Idea | Prototype one shore-side location (breakwater OR tide pools), 1 interaction, reward and return | Lowmere town |
| **CCH-COAST-VOYAGE-001** | P2 | Idea | One short crewed nearshore fishing voyage with a meaningful decision and save-safe return | CCH-MARITIME-001, dock access, Fishermen-001 |
| **CCH-COAST-GROUNDS-001** | P2 | Idea | One discoverable fishing ground affecting actual fish catch and market demand | CCH-COAST-VOYAGE-001 |
| **CCH-COAST-RHYTHMS-001** | P2/P3 | Idea | Seasonal harbor work, inn trade and local ambient improvements | Lowmere services |
| **CCH-COAST-CHARTS-001** | P2/P3 | Idea | Optional contradictory chart/log/lookout clues, story-canon audit required | CCH-LOWMERE-FOG-001/002 |
| **CCH-COAST-ROUTES-001** | P3 | Idea | Off-map coastal shipping route manifest, one named destination | Orders and working voyage |
| **CCH-COAST-DEEPWATER-001** | P3 / stretch | Idea | Rare mysterious offshore trip after regular fishing is demonstrably fun | Voyage, lore, player testing |

**Scope for v1.0:** the town and working waterfront are in target; nearshore voyage, outer grounds and other sea locations are **optional/promotable**, not release blockers. No new open-water map/second town until current loops are demonstrably enjoyable.

## Owner decisions remaining
- Which shoreline mood/location is strongest: a breakwater, tide pools, working slipway, or a mixture?
- Should working voyages be a 90-second game session, a few in-game hours, or a longer optional expedition?
- What should drive new fishing grounds: player Fishing mastery, relationship trust, repair work, and/or a documented route?
- Are the coastal places named as above, or should names tie to historic Lowmere families?
- Should post-ending free play eventually expand to nearby off-screen trade towns, and how much detail is needed?
