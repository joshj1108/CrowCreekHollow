# CCH-MEMORY-002 — The World That Answers Back
## Living-memory scene catalog, daily rhythms and environmental persistence

**Created:** 2026-11-15. **Status:** Narrative/content prototypes for review, NOT implementation permission. Companion to `LIVING_MEMORY_SYSTEM_V1_SPEC.md`, `CHARACTER_RELATIONSHIPS_BIBLE_VOL_2.md`, `INTEGRATED_NARRATIVE_BIBLE_VOL_1.md` and existing `FolkSystem`/`StoryAct`. All new lines are original and optional, not established canon.

## Five design pillars
1. **A repair tells a story twice:** first when it changes state, then later when someone uses or notices it.
2. **People have work beyond you:** they do chores, disagree, choose alternatives and preserve their privacy. The player participates rather than directs every life.
3. **A promise is different from the work:** offer, accept, act, finish, witness and remember are distinct facts.
4. **Seasonal repetition gives events weight:** rain on the same repaired roof next winter is more meaningful than a congratulatory popup.
5. **Uncertainty belongs to the Hollow, not to ordinary accounting:** gameplay must reliably know whether materials were spent, deliveries made and letters sent, even when characters disagree on lore.

## A. Twelve candidate memories, ranked by playable value

| ID (editorial only) | True trigger | Immediate consequence | Character who may know and how | Delayed echo | Environmental/journal payoff | Stage |
|---|---|---|---|---|---|---|
| M01 First real roof/house repair | Existing estate stage transaction completed | New actual house appearance/function | Maren observes at eligible visit | One response based on advice/trade/independence | Stage art remains; diary records completed stage | **First prototype** |
| M02 First harvest used | Crop harvested then actually sold/used | Food/coins inventory changes | Buyer or recipient directly involved | Limited repeat buyer/neighbor comment only if real sale | Seasonal diary fact | Early |
| M03 First Maren method | After original day4 trek; player chooses advice/trade/independent | Knowledge/trade or unchanged inventory | Maren hears choice directly | Repair success/failure callback | Factual player diary | **First prototype** |
| M04 First winter endured | Actually slept through winter day/night; normal survival state | No artificial bonuses | Player; close person sees house only | Spring observation about supplies, not fear | Visible home stage / selective winter diary | Early |
| M05 Old-life letter | Actual origin-specific mail send/receive/resolve | Status+legitimate sender response | Player, recipient after delivery | September/Y2 echo | Original letter or keepsake if actually owned | After prologue |
| M06 Kept a promise to Davy | Actual eligible action with Davy | Correct existing gift/request effect | Davy directly witnesses | Later ordinary recognition | Story-safe pond line if Davy actually present | Later |
| M07 Original mill result | Source meeting flag determined | Canon meeting outcome | Actual attendees | Source-endgame variation only | Original diary and afterword retained | Read-only projection |
| M08 Inn window | Completed future paid structural repair | Physical window stops leaking | Owner/worker on scene | Real guest booking and later thank-you | Light only when room occupied | After Wicker Cove |
| M09 Village harvest order | Actual contract complete, with items removed | Paid goods exchanged | Recipient/owner directly | New buyer request or supply-specific dialogue | Different stock/ledger, no universal reputation | After contracts |
| M10 Woodland craft | Workbench log→plank conversion truly executed | Log count down, plank count up | Player; later witness if told/seen | Repair material matches player work | Visible pile/workbench only if art+state exists | After forestry |
| M11 Prior-life boundary | Player actually chooses closure or deferred reply | Sender's request status updated | Sender after real delivery | Next season less/more contact as authored | Factual mail/diary; no 'healed' tag | After prologue |
| M12 Ending and next morning | Source ending actually recorded | Existing afterword/free play | Source witnesses only | Contextual ordinary line | Player-selected closing reflection | Read-only projection |

**Ranking:** M01+M03 together make one bounded first slice. M02 is natural follow-up after economy audit. M04 can initially be diary-only. M07 and M12 are *projections* from source, never duplicated ending writers. Other entries are gated on real feature implementation.

## B. Three authored memory chains, designed to survive refusal

### Chain 1 — Maren and the weak corner
**Act 1: the choice** (after original day4 edge trek, on a new eligible interaction):
> "Water's coming in there," Maren said. "Or it will when the rain turns."
>
> "There's a good deal that needs fixing."
>
> "Then start with what keeps you dry."

Player chooses **listen**, **trade** or **do it alone**. Listening records advice but not repaired work. Trade must call a genuine transaction, not an implied inventory grant. Independence doesn't change hearts downward.

**Act 2: the player's work**
The house repair can be completed through the current stage/repair mechanism regardless of choice. The memory system listens to success and records `repair_completed` once. It does not change the cost of repairs or grant unstated rewards.

**Act 3: the callback (on normal visit 7+ days later if eligible)**
- **Advice + repair:** Maren: "That patch held." Player: "So far." Maren: "That's what you ask of a patch."
- **Trade completed + repair:** Maren: "You put those materials to use." Player: "I did." Maren: "Good. That makes the counting worthwhile."
- **Independent + repair:** Maren: "Found the weak part, then?" Player: "Eventually." Maren: "Most of us do."
- **Advice + no repair:** Maren: "I'd still start where it leaks." No shaming.
- **Trade offered but not completed:** She must *not* say "the boards I sold you." Neutral line instead.
- **No visit:** callback stays available; it must not interrupt original story or teleport Maren.

**Act 4: winter return**
If roof/house repair genuinely improves physical conditions, cold-weather scene can mention its true art/weather state. If no repair, house still wears its original damage. **No guilt narration either way.**

**Tests:** all three choices × repaired/unrepaired; trade offered but not bought; old save; reload before callback; double dialog; original day4 / hearts / book scenes.

### Chain 2 — A room that can be rented (future Wicker Cove)
**Act 1:** candidate innkeeper (name TBD) presents an actually uninhabitable upper room and contract. A traveler has a realistic requirement (dry room, accessible bed, affordable stay).
**Act 2:** player pays/repairs, helps with part of work, or declines. With decline, innkeeper can redirect lodging only if an **alternate authored option** exists; not everyone freezes.
**Act 3:** after completed physical room repair, owner inspects the actual window. No 'completed' status from promising.
**Act 4:** only after a booked guest appears does the upstairs window show warm light and the inn ledger reflect occupancy.
**Act 5:** next season, innkeeper quotes exact past fact: "That room stayed dry through the rain." If the room never repaired, no false occupied window, and owner may plausibly talk about a different use of the room.
**Loop:** later client briefs are optional; same generic repair-contract architecture, no separate inn management RPG for v1.

### Chain 3 — The letter that required an answer
**Act 1:** origin choice creates a specific past with optional keepsake/contact details.
**Act 2:** the matching winter letter arrives with an actual practical need (stored box, former job, household arrangement, photograph or expiring chance). Exact script already exists.
**Act 3:** player may read, defer, respond, close or not respond according to authored branch. Only completed sending updates recipient knowledge.
**Act 4:** plausible return mail and/or bounded deadline. If the player doesn't reply, the other person's life still progresses independently.
**Act 5:** September diary reflects **the actual result**, no personal diagnosis or 'now you belong here'. Year-two object/letter may reappear after a real state change.
**QA:** five origins, each contact/no-contact and keepsake/none where offered, delivered/non-delivered, 3 original ending statuses, legacy saves.

## C. The Living World heartbeat, without expensive autonomous NPC simulation

Do not promise continuous AI schedules, real-time offscreen entity navigation or full agent-based town economy. For v1 a **deterministic authored routine table** can make 2–4 characters feel alive with minimal integration.

### Candidate weekly routine schema (design only)
- actor ID / approved home and workplace
- allowed day part (morning, afternoon, evening) using the same game clock
- season/day exceptions (known original story events override)
- job/activity anchor; one line of dialogue and a short idle animation if actual art exists
- bounded alternative if location unavailable due to repairs/weather/known story outcomes
- known memories that may condition a **single** line
- no hidden teleport during a player-witnessed interaction

### Existing four walkers must keep current implementation
The current `FolkSystem` provides visit windows, spots, seasonal lines, requests and 2/4/6/8-heart revelations. A new routine should first **decorate** legal visits (e.g., Maren counts goods at stand; Davy selects stones at pond; postman sorts mail by door; vicar tends a lantern under great tree), not replace their schedules or alter their chapter timing.

### Village routine examples, all gated on approved identities and a real built district
- **Innkeeper:** opens shutters, airs linen, checks reservations, shuts window in rain; handles direct repair outcome.
- **Storekeeper:** checks delivery ledger, puts stock out, closes early when deliveries missed; stock change requires actual order state.
- **Fishmonger:** morning catch sorting, afternoon sale/food storage, winter preservation; uses actual fish inventory if available.
- **Harbor worker:** inspects line or boat, changes departure according to coastal fog/weather; no boat leaves player stranded.
- **At least one meaningful NPC→NPC beat per week** can be a preauthored short conversation at existing shared location, not a fully simulated background drama. Example: innkeeper and storekeeper disagree about overpromised flour; both retain plausible work.

A scene should not spawn a character at two different locations or overrun Maren's first trek or Davy's timed night. Day length 420s constrains route travel: favor compact schedules and representative scene blocks.

## D. Environmental memory layers
| Layer | Visual implementation | Gameplay authority | Memory condition | Risk |
|---|---|---|---|---|
| House restoration | Existing stage art/comfort | EstateSystem | Real stage completed | Don't duplicate stage |
| Furniture and keepsake | Existing furniture/optional new sprite | Estate/inventory | Truly bought/kept | No phantom prop |
| Farm stand/field | Existing objects/crops | Farm crop/market systems | Actual sale/harvest | Don't infer customer |
| Fire/light | Existing Light2D/rendering | Hearth and lighting systems | Fire lit, lamp present | Don't increase lantern brightness |
| Forest logging | Future compact grove/real stumps | Real tree/resource state | Cut/return performed | No fake forest regrowth |
| Village shop | Future stock/repair art | Shop/contract system | Delivery or repair completed | No global 'town restored' flag |
| Inn upstairs | Future actual room + guest | Inn bookings | Repair plus actual occupancy | No light if room vacant |
| Seasonal landmarks | Existing landmarks/weather | Weather/calendar | Appropriate season/event | Don't attribute fog cause |

**Visual principle:** one persistent changed object can do more emotional work than ten congratulation lines. Reuse art/tiles and place a subtle prop or variation when actual system state changes.

## E. How a memory feels in play
**Day 5:** Maren gives advice about the roof. The player decides not to take it.
**Day 14:** Farmer spends real materials to repair the farmhouse after harvesting food and chopping wood.
**Day 22:** Maren visits normally. "Looks like you found your own way around it." Dialogue ends. No cutscene, no reward or morality change.
**Midwinter:** The room looks warmer and functions better because of estate stage, not because memory invented an effect. The diary records "I repaired the farmhouse before the cold came." A writer may choose how to interpret it.
**Year Two:** A player seeing the same corner knows exactly why it is different; the game doesn't need another paragraph.

This is the target for a *small* memory system: ordinary specific continuity that feels personal.

## F. Build smallest first, scale only with evidence
1. **Audit current save, original quests, relationship visits and first repair event** to identify usable hooks. Avoid writing patches from this prose.
2. **Implement one stored Maren decision + one verified repair result**, and one conditional follow-up line. No new assets or NPCs.
3. **Add one truthful diary memory** through existing book page builder, keeping Agnes and original story pages intact.
4. **Play 30 days with multiple approaches**, validate that players notice the callback without being bombarded, and that they don't feel punished for independence.
5. **Only then** generalize to an origin letter and one later village contract. Don't build a world-scale event dispatcher first.

### Stop conditions
- If a memory requires more work than the actual player action it remembers, simplify.
- If a callback must interrupt an existing story scene, defer it.
- If a diary sentence could be false for some save, remove it until correct.
- If village character routines make travel or time-critical story worse, narrow their scope.
- If testing reveals repetition or no added enjoyment, prefer stronger authored scenes to more generic memory records.

**End-state objective:** A character may remember one real choice from two seasons ago while the player stands in a house they repaired, with the original mystery still intact. No new second game hidden inside the first.
