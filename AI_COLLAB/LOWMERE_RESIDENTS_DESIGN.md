# CCH-LOWMERE-PEOPLE-001 — Residents, Relationships and Working Village

**Draft date:** 2026-11-14. **Status:** DESIGN ONLY; no authorization to implement new NPCs, art, quests or dialogue.
**Sources checked:** `DESIGN.md` sections **Folk**, **Story chapters**, **Endings**, **Groves and treks**; `AI_COLLAB/LOWMERE_FIRST_DISTRICT_DESIGN.md`; `AI_COLLAB/MASTER_ROADMAP_TO_1_0.md`.
**Canon distinction:** Existing walker identities, relationships and story hooks below are current code/design canon. All new character names, roles, costumes, stories, sample hooks and encounter arrangements are **candidate concepts**, not canon until owner approves. Concept portrait references are mood only, not production assets.

## Design goal

Make Lowmere a failing but inhabited fogbound seaside fishing village whose people have believable work, relationships, hardships and occasional warmth. Player trade, cooking, carpentry, fishing and hospitality should improve particular livelihoods while **not eliminating Lowmere's permanent fog or making it a cheerful resort**. Ordinary everyday life must remain enjoyable independent of the main mystery.

### Existing story anchors — PRESERVE
- **Old Maren:** edge and mill walker, her sister and Ruth's minute book; sees the 31-to-4 vote and can help overturn it. Her already-existing `maren_book` scene is essential to winning the meeting.
- **Davy Tull:** orchard walker, Pip and family; `davy_turn`, his night at the great tree and possible loss/recovery are important to endings. Existing mother **Mrs Tull** is mentioned; don't replace her or erase the current dog/family story.
- **The vicar:** chapel route, clapper, church register, `vicar_register`; essential to existing bell and meeting narrative. Preserve blessing and food requests.
- **The postman:** carries 30 years of letters to the Rooks; `post_hand` is a key ending clue, existing periodic farm visits and parcel mechanics remain.
- **E. Pell, town clerk:** existing day-240 letter and vote; no arbitrary retcon or replacement as a benevolent merchant.
- **Agnes and Elias Rook:** pre-existing histories, bell and 'keeper' mystery; new town dialogue should reveal rather than replace the truth.
- **FolkSystem:** existing 0–10 hearts, first daily conversation, weekly gift, requests, four gated scenes and scene/ending flags. Extend or reuse this framework rather than create a duplicate friendship meter. Current walkers remain available at farm gate/visits/treks on their established schedules; any town representation must not make them unavailable on required days.

## New proposed principal residents (all tentative)
| Candidate | Profession and daily life | Main mechanical purpose | Personal arc (optional) | Low-key mystery link (optional) |
| --- | --- | --- | --- | --- |
| **Edith Vale** | Careworn innkeeper who inherited an almost-empty harbor inn | Inn catering orders, one structural repair, guest-room design commission; occasional lodging/food service | Reopen one boarded guest room, regain confidence and welcome a visitor | Historic guest ledger entry with an inconsistent date; avoid violating established timelines |
| **Gideon Pike** | Aging fishing-boat operator with failing catches and too-small crew | Fishing advice, NPC-led nearshore trip, crew work, discovered grounds | Restore one dependable boat and establish a viable route without player owning ship | Old safe route no longer traveled; player can learn why, no origin of fog revealed |
| **Thomas Bellweather** | Struggling general store proprietor with dwindling stocks | Crop/produce order contracts, basic imports, trade improvements, building repair | Revive practical supply deliveries; rebuild trust with local producers | Old accounts show unusual supplies headed up mountain road; tie to established town ownership history after lore review |
| **Martha Fenwick** | Blunt veteran fishmonger who buys and preserves catch | Fish market, salting/smoking demands, storage renovation, coastal supply chains | Keep market supplied through bad seasons and losses | Remembers missing boats/fishermen; grounded, not every omission supernatural |

**Scope:** Four new named working residents is a candidate *full* cast; **initial vertical slice uses only Edith + one merchant/fisherman**, possibly one ambient extra, to reduce dialogue/schedule/portrait cost. Name clearance and differentiation from existing `E. Pell` and families should be verified before canonization. No romances, marriage, children/family features or full NPC household simulations are implied.

## Resident design template (one per candidate)
- **Where/when:** primary workplace, simple grounded day/night schedule, weather/season behavior, reliable interaction windows.
- **What they need:** at least one small order that uses existing crops/materials and offers fair payment; not a mandatory chore.
- **How they change:** one visible workplace improvement, one service improvement, one meaningful personal scene and one optional deeper follow-up.
- **How to befriend:** greet, fulfill order, occasionally gift, one genuine scene (use existing hearts and persistence). Friendship grants optional content, **never blocks buying essential goods or the main story**.
- **What they know:** mundane firsthand memories and incomplete rumors; no new NPC should know everything about the Hollow, explain the fog, or overwrite the original revelations.
- **What they give back:** usable goods, recipes, supplies, access or a furnishing; coins alone aren't enough for a major relationship arc.

## Social fabric
- Edith and Thomas depend on farm produce and seasonal goods.
- Gideon brings catch to Martha; market storage improvements should benefit both.
- Martha's processed fish can feed the inn or supply voyages.
- The postman's known rounds and letters connect Lowmere to Crow Creek Hollow without changing the existing visit scheduler.
- The vicar's chapel charity and old town vote cast a long shadow; one resident may hold a different perspective on it without contradicting literal facts.
- Maren and Davy have credible reasons to know the community; their main already-built trek gates are authoritative.
- Distinguish villagers' individual relationships with Agnes from rumor; avoid unanimous collective amnesia or four simultaneous 'secret villains'.

## Gameplay flows
**Small daily loop:** speak to merchant / see available supplies → accept a reachable order → return to farm or fulfill from home dispatch → modest coin and relevant existing skill XP, possible friendship advancement.
**Longer personal loop:** improve one relationship → learn a real material need → complete one Carpentry contract → see permanent visual/functional change → unlock a higher-value service or guest request.
**Inn loop:** help Edith repair one guest room → arrange existing furniture to meet a brief → receive guest feedback and revisit the persisted room. One-time XP for successful completion; no exploit through rearrangement.
**Maritime loop (stretch):** earn Gideon's trust through a modest fish/supply contract → join short working boat voyage → help with catch/crew choice → return to the fishmonger → possible new fishing ground. Needs Lowmere harbor before implementation.
**Narrative loop:** subtle inconsistencies in ledgers, route memories, decades-old letters and votes may connect to existing Agnes / town-keeper lore, but keep hard revelations in current pages, walker scenes and StoryAct.

## Example small story arcs (not canon, no dates/mandatory branches)
- **Edith:** roof leak → repaired room → first guest brief → occupied room → a more personal conversation about why she kept the inn.
- **Gideon:** trade bait/provisions → short safe fishing trip → chart a new spot → choose to attempt a harder tide, with risk forecast rather than forced horror.
- **Thomas:** first crop order → reopen store shelf → supply rural household needs → discovery of an old shop receipt related to farm ownership.
- **Martha:** sell catch → restore ice storage → stable fish supply → help a family through a poor winter season; older memories available later.

## Mechanical and lore safeguards
1. **Use existing FolkSystem/quest infrastructure** or extend generically; don't create a second independent friendship/requests/portrait scheduler.
2. New residents must not change Maren's, Davy's, the vicar's or postman's already established visit times, heart milestones, trek gates or ending flags.
3. New friendships and town upgrades must **not** become mandatory to reach any of the original three endings.
4. Do not award coins and XP twice for one delivery through overlapping old daily jobs and new town requests.
5. New dialogue requires a season/time/story state matrix; check references for spoilers and consistency (especially Agnes's 30-year absence, the four family names, town-vote records and E. Pell's letter).
6. One new meaningful interaction per new resident is better than dozens of hollow filler lines.
7. Do not render all buildings spotless because repaired; town remains failing, damp and perpetually foggy.

## Task list and gates
| Task | Priority | Status | First testable outcome |
| --- | --- | --- | --- |
| CCH-LOWMERE-PEOPLE-001A | **P1 (design prerequisite)** | Design | Character roster + lore compatibility matrix vs existing four walkers and story flags |
| CCH-LOWMERE-PEOPLE-001B | **P2** | Idea | Edith + merchant NPC: short daily schedule, one conversation, one order and save persistence |
| CCH-LOWMERE-PEOPLE-002 | **P2** | Idea | One owner relationship arc and building restoration acknowledgment |
| CCH-INN-GUESTS-001 | **P2** | Idea | Two distinct guest briefs plus returning/occupied room feedback linked to `CCH-INN-001` |
| CCH-FISHERMEN-001 | **P2** | Idea | Gideon + fishmonger contracts and one dock interaction; prerequisite to `CCH-MARITIME-001` |
| CCH-LOWMERE-RUMORS-001 | **P2/P3** | Idea | Original story-safe short town rumor/ledger discovery chain; no retcons |
| CCH-LOWMERE-SCHEDULES-001 | **P3** | Idea | Seasonal weather/workday ambient schedules, only after functional town slice |

**Priority nuance:** P1 lore/roster *design* prevents expensive retcons; the actual new town NPCs are P2 and depend on the first Lowmere district. No phase should add all four as fully featured NPCs before the first two are engaging.

## Decisions reserved for owner
- Confirm/change the four suggested names, appearance and ages.
- Choose Lowmere's main emotional tone: guarded but helpful, suspicious, or divided among generations. Recommendation: guarded but helpful, different residents have divergent opinions.
- Decide whether Edith's inn or Thomas's store is the first fully working interior.
- Decide whether any new resident ties to the old 31-to-4 town vote; if so, keep evidence in original stories.
- Determine which resident first introduces the player to the harbor and future fishing voyages; recommendation Gideon after an ordinary job.

## Owner-set fog testimony direction (2026-11-14)

**CANON:** Lowmere is permanently fogbound; local memories and records about *when* this began contradict each other, and the truth is unresolved. This is a trait of the community, not a reason for every NPC to have a supernatural secret.

**Tentative voice design, not canon individual histories:**
- Edith (proposed innkeeper) has guest logbooks or old room views that might conflict with community claims; let her treat the records pragmatically.
- Gideon (proposed boat operator) may recall visibility markers and navigable routes differently from other seasoned fishermen; he should remain a competent worker.
- Martha (proposed fishmonger) can challenge Gideon's certainty using market history or other fishermen's accounts without either being confirmed correct.
- Thomas (proposed shopkeeper) may find weather/shipping annotations that conflict with firsthand memories; preserve mundane possibilities.
- Existing Maren, Davy, vicar and postman retain their established scenes and ending flags. Any added observations of Lowmere fog must be reconcilable with their currently written ages, history, travel schedules and records.

**CCH-LOWMERE-FOG-001 P1 Design:** testimony/conflict matrix required before writing these dialogues. **CCH-LOWMERE-FOG-002 P2 Idea:** micro-conversations and records after town slice works. Preserve ambiguity and ordinary human tone; don't imply a false or definitive backstory.
