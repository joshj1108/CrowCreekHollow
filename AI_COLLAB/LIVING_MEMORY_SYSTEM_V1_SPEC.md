# CCH-MEMORY-001 — Living Memory System
## World remembers deeds; people remember only what they could know
**Dated:** 2026-11-15. **Status:** Ready-for-review technical/game design, **NOT** approval to implement. Owner has explicitly invited design work, not source-code modification. Preserve all original story, visuals and saves.
**Reference:** `BRANCHING_RESIDENT_ARCS_AND_PLAYER_DIARY.md`, `HOUSE_MEMORY_AND_PLAYER_DIARY_ATLAS.md`, `CHOICE_CONSEQUENCE_SYSTEM_DESIGN.md`, `RESIDENT_ARCS_TWO_YEAR_BLUEPRINT.md`, `NARRATIVE_PRODUCTION_CONSEQUENCE_MATRIX.md`, `CLAUDE.md`, `DESIGN.md`.

## 1. Product promise
After a player repairs a house, trades with Maren, answers a letter, helps a shop or walks with Davy, **something specific and observable** can be different a week or a year later. The system gives continuity to ordinary life, not a morality score or AI dialogue generator.

A memory is an authored consequence of a **verified action**, not a generic NPC opinion, unobserved player's emotion, quest-completion toast or a recorded inventory click.

### Experience requirements
- **No moral alignment, favored life path or universal 'reputation.'** Character affinity remains the existing 0–10 hearts system. Event memory is separate.
- **No telepathy.** Who knows what depends on their witnessing it, being told in an explicit dialogue branch, or receiving a credible message.
- **No endless log.** Record selected meaningful events at their natural transaction boundary; no recording every tree felled or seed planted.
- **Consequences are scarce and readable.** Typically one immediate state difference, one later specific callback, and one longer-term physical or personal echo. Not weekly mail spam.
- **No deception.** A choice to *offer* aid differs from actually completing aid; a promised delivery is not an actual delivery.
- **The world moves without the player.** Other residents may solve an issue independently only if their alternative timeline was authored and simulated.
- **The Hollow plot stays independent.** Don't invent alternative Rook evidence, reveal postman handwriting prematurely, save Davy via generic social score or change the three original endings.
- **Current visuals remain.** Small physical states show on an existing farm/house or future built Wicker Cove. No new art engine, mega map or new handwriting style.

## 2. Current Godot integration findings, verified by direct repository reads Nov 15
- `scripts/folk_system.gd`: existing `IDS = ["mill", "orchard", "chapel", "post"]`; 0–10 heart/200-point standing, gift/request histories, season/heart-dependent dialogue, canonical scenes at 2/4/6/8 hearts. Reuse and preserve; memories are conditions, not replacement relationship currency.
- `scripts/story_act.gd`: owns dated original story beats, ending flags and meeting logic. Treat as read-only for first implementation and do not mutate its critical flags on memory callbacks.
- `scripts/diary_book.gd`: presentation layer supports the book's physical page turns and distinct Agnes/player handwriting. **Do not** rebuild this class to store memory records.
- `scripts/panel_rows.gd`: `_diary_sections()` composes page dictionaries; a future personal memory section can be generated here, with existing UI. Read existing section assembly fully before modifying.
- `scripts/estate_system.gd`: house stage, upgrades/furniture and title already exist; new world-memory visuals should query actual estate state, not independently pretend a repair exists. Historical porch/second-storey code is live and needs a separate migration review.
- `scripts/main.gd`: central game and save interaction surface is large; locate and inspect targeted save serialization and progress hooks, don't read/edit entire file blindly. A November 15 live runtime test has **not** been performed.
- Existing design library already proposes factual event history; this spec turns it into a bounded, interoperable implementation blueprint, not a second social/quest framework.

## 3. Architecture: four deliberately small layers
```text
TRUSTED GAME ACTIONS (existing systems)
  - repair transaction success / delivered contract / dialogue choice confirmed
  - letter actually sent or received / source story outcome actually occurred
                 |
                 v
LIVING MEMORY RECORDS  (new lightweight service; no duplicate inventories)
  durable event facts + provenance + idempotency + optional timers
                 |
       +---------+----------+-------------+
       v                    v             v
AUTHORED RESPONSE      WORLD STATE      DIARY PROJECTION
  NPC lines conditioned  existing props   short factual record
  on knowledge/time      /town repair     + optional chosen reflection
       |                    |             |
       +--------------------+-------------+
                 |
                 v
FIRST AUTUMN / WINTER / YEAR-TWO RECALL
```
- **Fact ledger:** small versioned persistent map of event facts, state and evidence. No free-text history generated by AI at runtime.
- **Per-character knowledge:** source + recipient + date known; NPC cannot react to a private event without delivery/witness. Knowledge does **not** override existing heart levels.
- **Consequence scheduler:** simple due-day queue or computed pending callback, not a second real-time calendar. Trigger only during existing eligible visits, mail reads, room inspections. Don't forcibly summon people.
- **Presentation adapters:** NPC conditional lines via existing `FolkSystem`; fixed art state from actual `EstateSystem` or future repairs; existing Diary via `PanelRows`. The memory service does **not** own visual items, currency or canonical `StoryAct` flags.

### Proposed service boundary (names illustrative, no source API yet)
- `LivingMemory.record(event_type, subject_id, outcome, evidence, day) -> bool` **only from completed game actions**, with validator and idempotency.
- `LivingMemory.has_fact(event_id, required_status) -> bool`
- `LivingMemory.knows(actor_id, event_id) -> bool`
- `LivingMemory.share(event_id, actor_id, channel, day) -> bool` after verified delivery/observed dialogue.
- `LivingMemory.available_callbacks(actor_id, day, location) -> Array`, sorted/deduplicated; checks source eligibility before authored text displays.
- `LivingMemory.complete_callback(callback_id, day)` marks only presentation, never re-credits reward.
- `LivingMemory.build_diary_projection(day, section) -> Array` creates factual prose from known events, respects Agnes/player section.
- `LivingMemory.serialize()/deserialize(data)` versioned, default-safe, resilient to unknown IDs/removed dialogue.

**Important:** avoid duplicating inventory state, house stage or relationships in memory. A memory can reference a completed repair ID; the actual repair component decides whether the physical change exists. If save state disagrees, **do not display unearned result**.

## 4. Event record contract
Conceptual event for eventual Godot typed dictionary or resource. Numeric values illustrative and not approved balance:
```gdscript
{
  "schema": 1,
  "id": "farm.first_roof_patch",    # stable author-defined event ID
  "kind": "repair_completed",
  "subject": "farmhouse",
  "outcome": "completed",           # offered|accepted|completed|declined|expired
  "day": 31,
  "source": "estate_repair_transaction",
  "witnesses": ["player"],
  "known_by": {"player": {"via": "performed", "day": 31}},
  "references": {"repair_id": "roof_patch"},  # valid id in existing game if introduced
  "priority": 30,
  "callback_seen": {},
  "data": {}                         # only small allowlisted fields, no free text
}
```
This example must not be pasted as an existing event or recipe; `roof_patch` is an illustrative ID. The real source currently tracks house restoration stages; the first slice should bind to a real completed stage/repair.

### Event life cycle
1. **Offered** can be logged as pending dialogue if needed, but offers do not create 'did it' memory.
2. **Accepted** stores an actual pending commitment but never states completed.
3. **Completed** records after **atomic** underlying transaction success (remove goods/charge coins/mark repair), not on menu selection.
4. **Observed/shared** updates recipient's knowledge with a real channel.
5. **Due** is derived from `completed_day + delay` or a fixed authored season gate; queue doesn't spawn NPCs.
6. **Recalled** displays one validated conditional line, checks source scene not mid-cutscene and marks callback seen after successfully rendered.
7. **Archived** retains high-value fact if needed for September or year-two, without repeated popups or infinite save growth.

### Save and integrity rules
- Stable prefix-based event IDs, e.g. `memory.farmhouse.first_repair`, `memory.maren.first_method`; event keys are not script labels accidentally regenerated on text edits.
- Unique event fact per bounded story action, not per click. `record` called twice with same completed transaction ID must be idempotent.
- Store **decision** and **completion** separately when they can diverge. Never count an abandoned proposal as fulfilled.
- Keep field names/version consistent, use existing save load pattern, preserve unknown IDs safely for compatibility.
- Missing `living_memory` on an older save loads an empty registry and infers **nothing** about unknown past choices. Existing source facts can optionally be projected read-only if certainty is strong, never fabricate origin decisions.
- One-off replayable dialogue can exist without creating duplicate rewards. Save/load and callback timing must not be exploitable.
- Event priority does not measure player's virtue. It only ranks importance for constrained UI space.
- Proposed first release cap: approx. 30–60 **significant** records per 2-year playthrough, not logs for every harvest; adjust from actual playtest.

## 5. Character knowledge and believable social propagation
**Scope:** allow only direct witness, completed transaction with NPC, explicit shared conversation, physical evidence plausibly visible, or actually delivered letter. Hearsay is optional later and must be authored as a **claim**, not source truth.

| Example | Who knows immediately? | Who can know later? | Who must not magically know? |
|---|---|---|---|
| Farmer repaired their own roof alone | Player | Maren if she visits and sees verified stage | Davy, vicar or distant resident automatically |
| Maren traded materials | Player + Maren on actual transaction | Ruth only if Maren specifically shares or record delivered | Entire village |
| Farmer sends old-work letter | Player; sender only after actual receipt | Recipient if forwarded with established channel | Maren and all Wicker Cove by default |
| Inn's window is repaired (future) | Player + owner/worker present | Guest sees room; Thomas if directly involved | Unmet villagers |
| Player privately chooses a family origin | Player | Person explicitly told with privacy consent | All new NPC introductions |
| Original story meeting occurred | Actual witnesses / source flags | Others if real public notice or authored exchange | Personal-origin contacts automatically |

**Known-but-mistaken facts:** A character can believe a rumor only when an authored rumor event is explicitly tracked as `heard_claim`. Their belief is not objective canon. The contradictory fog origin must stay contradictory.

**Relationship progression:** no new 0–100 reputation bar. Existing hearts determine closeness/line availability where already established; memory determines **specific** shared history, both independently.

## 6. Memory scopes and lifetimes
- **Momentary:** flavor reactions; don't save (e.g., rain remark).
- **Seasonal:** delivered goods, remembered repair choice, old-life reply; kept until response and diary reflection, with small id only.
- **Long-lived:** house stage work, key relationship choice, origin consequence, original story outcome. Retained to second autumn/afterword.
- **Canonical:** actual `StoryAct` and `FolkSystem` flags remain source of truth; **projected** into memory displays rather than copied as alternate authority.

### Seven meaningful locations
Bedroom, kitchen table, hearth, workshop, door/mailbox, farm stand/fields, and fence/forest edge. Different pages and ambient lines can reference these only if actual art/repair/inventory facts justify their state. Place matters because the player revisits it, not because the house magically speaks.

## 7. Content examples and measurable results

### Vertical slice #1 — Maren and a real repair
**Prereqs:** existing Maren day4 edge escort completed; safe follow-up visit; existing real repair stage/action available.
1. Maren offers advice / negotiates fair material trade / respects independent work.
2. Choice recorded only after player selects; materials exchanged **only** on actual UI confirmation.
3. Farmer completes a real repair through existing `EstateSystem`.
4. On a later source-eligible Maren visit (e.g. >= 7 days later), one of three **different** authored callbacks checks repair completed and method.
5. Diary lists factual action, not inferred emotions. If no repair, dialogue notes work is pending without accusation.
6. No effect on `maren_book`, `vicar_register` or mandatory original story.

### Vertical slice #2 — A letter from former life
**Future, after origin framework:** Origin selected in mandatory prologue. Winter letter received. Player chooses and actually sends a reply or lets deadline pass. Recipient learns after delivery. September diary refers to exact outcome; next autumn envelope/prop reflects closure or continued contact. No boxes on no-box route, no default forced tragedy.

### Vertical slice #3 — Inn room (after Wicker Cove district exists)
**Future, gated:** Inn owner (candidate Edith) offers a leaking-window job; player promises, pays/repairs, or declines. Actual paid completion changes the physical room. Only then does the inn book a guest; a light in the window and owner's later line reflect the guest. No ghost occupancy if owner-repair feature isn't live.

### Vertical slice #4 — Davy's ordinary memory (protected outcome)
Davy can remember a truthful pond conversation if it happened. On Day370 the original timed scene, prerequisites and potential loss are **unchanged**. Post-event commentary uses source outcome and may refer to the stone only if witnessed, without guaranteeing survival. Do not turn a small friendship memory into automatic rescue.

## 8. Player-facing design
- **No memory feed popups** for routine deeds. The primary visual is a changed world or specific spoken line.
- **Diary:** small `My Days` section (working label) in existing rustic-gothic book. 2–4 factual lines for each seasonal milestone; optional player-authored interpretation. Original Agnes and original story pages untouched.
- **NPCs:** one sentence of earned acknowledgment within their existing dialogue flow, occasionally an optional longer scene. A remembered interaction should be surprising but not impossible to miss forever if a major relevant arc.
- **World:** persistent actual house stages, furniture, repair props, inn window or stock changes. Memory is conditional rendering authority **only after** gameplay object owns the state.
- **Priority order for available callback:** original time-critical story event > active quest/shop fulfillment > due personal-life moment > local practical memory > ambient flavor.
- **Accessibility:** short text, screen-reader/focus support as current UI permits, gamepad selection, pause day clock during long readings per existing interaction rules; no missed day370 because a memory card stole focus.

## 9. Replayability, restraint and anti-exploit
- No procedural narrative generator and no randomized backstories; write small author-controlled content variants per event.
- No new global alignment or high-dimensional personality stats. Facts+player-selected interpretations create individuality.
- One household/repair memory should be reusable across diary, world and character without each subsystem recording its own competing copy.
- Residents continue living; deferred or declined contracts can progress via a **prewritten alternate route** rather than freezing their existence. 'Someone else repaired the inn' requires an actual scheduled and saved NPC outcome.
- Limits to save size, dialogue frequency and log spam; prefer reuse of existing event signals or explicit source calls.
- Relationships may change with actual interactions, not with all-pervasive virtue points.

## 10. Implementation sequence and precise acceptance
**M-0 Audit (read-only, first):** identify save/load contract, existing `DiaryBook` sections, `PanelRows`, `FolkSystem` extension points, estate transaction completion, `StoryAct` event priority, main clock and debug tooling. Confirm any source changes since this writing. Produce direct code references and risks.

**M-1 Minimal record utility (owner-approved slice only):** implement versioned memory store with two stable event types, no UI rewriting, save roundtrip, idempotency and default old-save behavior. Tests: duplicates no extra rewards, unknown event IDs ignored safely, original story flags unchanged.

**M-2 Maren playable proof (owner-approved slice):** one conversation after day4 with advice/trade/independence, one actual repair condition, one delayed callback, one diary fact. Test all 3 options x repaired/unrepaired + save/load mid-arc; six cases, plus day4 original escort and 2/4/6/8 heart scenes.

**M-3 Two more contexts (not automatic):** origin letter and an existing homestead interaction with no new map. Confirm player understands consequences through play and not debug output.

**M-4 Village memory (after Wicker Cove):** one inn contract with visible light, an owner who can make a choice without player, seasonal echo. Avoid general NPC scheduling engine until the one case is fun.

**M-5 System hardening:** ten event/four-playstyle long-play matrix, year-two/ending protection, reduced memory spam, old saves, input-device coverage, performance, human evaluation. Do not push a new full rewrite of `scripts/main.gd` to implement memory.

### Mandatory QA examples
1. Offer accepted but job unfinished -> *no* 'completed' memory or light.
2. Job completed and saved -> exactly one callback, even after repeated reload.
3. Letter drafted but never sent -> recipient doesn't know contents.
4. Reply sent and delivered -> exact origin route receives correct acknowledgment.
5. No-contact/no-keepsake origin -> no phantom person or prop.
6. Maren independence path -> no reputation penalty; original `maren_book` remains reachable.
7. Davy has not been met -> no invented pond friendship on year-two screen.
8. Day370 Davy missed -> original outcome preserved.
9. Original three endings reached -> afterword chooses correct memory variants without rewriting ending.
10. Old save without memory data -> loads and plays with blank supplemental history, not false memories.
11. NPC not present -> callback waits for a legal opportunity, no teleport.
12. Repeated town sale/harvest -> not thousands of memory objects.
13. Sanity/food or sleep failure -> never disables original survival/escape mechanics.
14. Player changes approach next season -> earlier facts retained, new preference not locked.

## 11. Risks and owner decisions
- **Proposed, not locked:** exact event schema, priority values, memory count cap, diary section name, 7-day Maren delay, whether NPCs may acquire secondhand knowledge, authoring tool and scene IDs.
- **Do not silently alter** house ownership, Wicker Cove/Lowmere postal geography, original Davy night, existing `StoryAct` vote/ending requirements, or farmhouse production art.
- One important historical note: earlier docs sometimes call the farm 'inherited'; `EstateSystem` describes town-held ownership/deed terms. Memory must not infer purchased title from residence.
- External dependency: actual logging/bench/inn systems are design proposals. First memory slice should use **already implemented** repair states, not force another subsystem's large rewrite.
- Suggested owner review gate: accept architecture, authorize code audit, then choose M-1+M-2 as one isolated Claude implementation batch after current outstanding fixes and human testing.

**Design success test:** After 30 days, a player should be able to point to one small memory of their own doing that the world accurately acknowledges, without being told what they ought to feel.
