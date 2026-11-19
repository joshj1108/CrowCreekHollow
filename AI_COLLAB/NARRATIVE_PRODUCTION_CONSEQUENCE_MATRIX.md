# Crow Creek Hollow — Narrative Production & Consequence Matrix
**Date:** 2026-11-14 | **Status:** DESIGN-TO-PRODUCTION PLANNING, NOT CODE AUTHORIZATION
**Companion:** INTEGRATED_NARRATIVE_BIBLE_VOL_1.md; preserved original longform source docs and screenplay drafts remain primary.

## 1. Definition of an earned consequence
An event is not 'branching' merely because it displays different words. For each high-value choice, define the initiating action, an actual cost or opportunity, the durable event record, a later response, and at least one player-visible artifact/relationship difference where practical. Track exact proof of player action; never assume the player gave, sent, learned, built or felt anything.

Recommended minimal event model (conceptual; **not** an existing save schema):
- stable event identifier
- action variant and factual result (completed/deferred/declined; sometimes failed/recoverable)
- in-game day/season and origin where relevant
- whether a recipient plausibly knows
- any validated item/currency/recipe/house/outcome changes
- consumed pending callback marker for deduplication
- one short truthful diary fragment if user interface supports it

IDs below are **editorial planning IDs only**, not keys to add directly to code. Claude must map them to current systems after audit and avoid collisions.

## 2. Five origins: cross-season consequence acceptance table

| Origin | Mandatory opening action choices | Autumn physical callback | Winter external complication | Spring/summer meaningful decision | September factual check | Second autumn / afterword |
|---|---|---|---|---|---|---|
| A / housing | Negotiate extension, forward address, or ask trusted person to hold two boxes | Notice/forward card/box-related paper only if selected | Old account or stored belongings have real deadline | Pay shipment, extend, release; **no-box** route gets ledger settlement/contest | Did shipment actually arrive or account actually settle? | Shelf holds received item, or letter records closure; no false boxes |
| B / work | Finish promised task, write successor instructions, or set boundary | Work notebook/tag if actually taken | Former colleague reports concrete work snag, perhaps resolved without farmer | Paid limited work, answer once, refer to notes, or decline | Only record actual reply, hours/payment if implemented | Colleague can continue work independently; contact respects selected limit |
| C / household | Establish changed shared daily arrangement without assuming death or romance; concrete leave-taking | Item, changed address or ordinary absence appropriate to selected relationship | Another person's living circumstances progress independently | Return/keep/reassign a shared object; respond or set a boundary | Record what was said/done, not inferred grief | A changed item or occasional contact, no 'healed' label |
| D / photograph | Choose to follow up on a real photographed place and what to tell an earlier contact | Photograph, map or note if actually brought | Sender asks about journey; no magical knowledge of farmhouse | Share an observed detail, offer a visit/message, or keep private | Compare actual visited places to reported account | Old picture and present scene in conversation; no chosen-one destiny |
| E / opportunity | Accept chance in a defined time window, choose what to leave unresolved | Practical paper/contract/object | Deadline or chance changes without player | Finalize, ask for time, or let opportunity lapse with plain terms | Record what choice finalized and what remains | Clear result or open but bounded thread; not a vacuous route |

### Origin acceptance test set
For EACH origin:
- opening is materially distinct (not five paraphrases of one sentence)
- at least one player-chosen prior connection or justified no-contact path
- autumn object or true observation visible at one documented location
- winter event changes independently of farmer's choices
- spring/summer decision has at least **two genuinely different viable outcomes** and bounded costs
- one delayed acknowledgement only after it is actually sent, delivered, or witnessed
- September diary composes a true fact
- second-autumn or post-ending echo works under bell, elias, and recoverable hollow outcomes
- the player may remain private without the narrator or town inventing knowledge
- legacy saves load with no fake origin selected retroactively

### Origin episode QA combinations
For each of A–E, test at least:
1. contact+keepsake, response completed
2. no-contact or private+no keepsake, response declined/deferred
3. interrupted opening and resumed
4. endgame after original bell ending
5. endgame after elias branch, if source-prerequisites reachable
6. recoverable hollow branch without overwrite
These are *test case categories*, not a declaration that implementation exists.

## 3. Main story and side-life event isolation

| Protected source/event | What optional origin/resident content may do | What it must never do |
|---|---|---|
| Day 1 tutorial / Chapter 1 sleep | Provide prior-life prologue before game clock; minor opening prop when owned | Lose time, tools, first-night access or survival |
| Chapter 2 Tin Lantern | Introduce workbench assembly only after guaranteed early availability | Require later anvil/planks inaccessible without axe, block chapter |
| Day 4 Maren forest edge | Add one AFTER-scene advice/trade/independence choice | Cancel escort, replace first sighting, force alternative walker |
| Maren minute book | Add later human response after original scene | Substitute a kindness score for evidence |
| Vicar register | Add grounded chapel/service context | Permit random check or town repair to supply evidence |
| Day240 E. Pell letter | Add recognized sender/arrival texture when verified | Override content, date, receipt or 'letter shown' flag |
| Day265 orchard | Add earned dialogue only after actual orchard beat | Schedule supernatural water rise on origin mail |
| Knock | Support routine mail/door contrast | Trigger additional knock that changes original sequence |
| Day300/day357 meeting | Reflect observed resident connection after resolution | Change voting result by character class, hidden roll or town reputation |
| Davy day370 | Rare contextual pre/post line around exact source event | Add timer, auto-save Davy, teleport, claim found if missed |
| Postman handwriting | Narrow later conversational references to proven revelations | Reveal twist early, silently rewrite Lowmere letters/iron |
| Day396 bell and subsequent grove | Contextual atmosphere and true afterword details | Reorder chapter, replace three endings, impose new morality hierarchy |

## 4. The first 30 days: practical playable proof

**A full new-game run should prove the loop before adding a full town or all five origin packages.** The existing FIRST_30_DAYS_LIVING_WORLD_VERTICAL_SLICE.md is the parent acceptance brief.

| Slice | Observable player outcome | Technical dependency | What would fail acceptance |
|---|---|---|---|
| First day | Can plant/gather/drink/sleep and reach day2 | Actual tutorial, game clock, input | New intro consumes day time or blocks sleep |
| First workbench | Can craft a basic viable tool without recipe deadlock | Existing crafting inventory and unlock architecture | Need plank to make bench, need bench to make axe, no starter axe |
| Nearwood | Clearly marked accessible cutting grove, useful 2–5 tree trip | Travel map/collision, harvesting, inventory | Hunt scattered decorative homestead trees for every repair |
| Hewing | Player converts raw logs into planks at physical station | New resource/migration design, animation/UI | Auto-convert in inventory, eat old save wood, duplicate items |
| First repair | At least one real home improvement using planks | Existing repair systems, balance and saved art state | Cosmetic sentence with no material/visual consequence |
| Maren choice | Advice/trade/independence changes a later line | Existing FolkSystem conversation, factual persistent event | Generic thank-you regardless of choice, escort blocked |
| Diary | Records only completed work/choice | Existing diary/save plumbing | States feeling or event never experienced |
| Long play | Day30 still produces useful tasks and varied evenings | Farming/needs/market/day balance | All 420 seconds swallowed by repetitive survival |
| Regression | Main story lantern, day4 escort, saves operate | StoryAct, equipment, save QA | Original canon becomes unreachable |

The player-approved **design direction** for workbench/forest is not itself authorization to implement an entire replacement economy. Exact log/plank conversion rates, migration policy, forest entrance, daily regen and crafting station positions require technical and owner review.

## 5. Choice→response sample: the first Maren conversation
**EDITORIAL PROTOTYPE, no original dialogue overwritten.**
- Prerequisite: original day4 escort completed, next safe farm visit after player has control.
- Situation: Maren notices a specific visible failing board or roof repair need; must correspond to true present house stage.
- Option A, advice: listens to practical fix. Result: a recipe hint or material source the player could already access; later Maren asks whether the boards held. No automatic repair.
- Option B, exchange: arranges a fair small material/trade exchange with explicit goods and UI. Result: one fulfilled trade, later line acknowledges honest work.
- Option C, independence: declines without antagonism. Result: player retains goods and must source own materials. Later line respects completed repairs without shaming.
- All three retain original Maren evidence, escort, hearts and story reachability; resource difference balanced so no 'correct' option.
- The callback occurs only if condition met and state persisted. If a roof never gets fixed, line references the unresolved problem rather than assuming success.
- Diary writes 'Maren offered advice; I took it', 'I traded for materials', or 'I did the repair myself' only if each precise action and completion exists. Player interpretation is optional.

**Scale constraint:** one concrete choice, one delayed callback, one fact-based diary entry, one completed home improvement. Human review first.

## 6. Wicker Cove: community work that can be observed
**Gated on actual playable town implementation, official resident identity approval, and postal continuity decision.**

A minimal first district should offer:
- a coherent downhill/return road from the homestead, seasonal inland weather vs persistent coastal fog;
- one or two people with independently believable work;
- one practical order or fair trade with exact cost/reward;
- a usable inn/shop interior (which first remains open);
- a visual outcome from one completed repair (for example, an actual lit window rather than just a completion toast);
- the ability to return safely within 420-second day pacing without stranding the player;
- readable controller navigation and accessible text.

Suggested first compact test (NOT approved): Edith+Thomas inn room repair. Request clarifies intended guest use and actual materials, player chooses repair now, trade help, or defer; guest can make another arrangement if declined. Seven to thirty days later an earned and visible window/ledger/different occupancy line shows the choice. The source INN_ROOM_BRANCHING_STORY_PROTOTYPE.md contains a much richer version and is the proper basis for eventual production.

**Fog rule:** every resident may sincerely disagree on what they remember, but no side quest, ledger or hidden d20 reveals an objectively verified onset/cause. The game must not turn a grim fishing village into a generic cheerful market simply because one room was restored.

## 7. Four existing walkers and eight proposed resident arcs: authority matrix
| Person/arc | Status | Early safe addition | Absolute source limitation |
|---|---|---|---|
| Maren / Ruth | Existing person/story and proposed human texture | Actual repair commentary, mundane traded supplies | maren_book mandatory evidence unchanged |
| Davy / Tulls / Pip | Existing people and timed fate | Pond habits and contextual familiar lines | day370 turn and possible loss intact |
| Vicar / postman | Existing people and evidence | Separate chapel/postal daily labor | vicar_register, post_hand and bell text intact |
| Edith / Thomas | Candidate town cast | One practical room/shop contract after district approval | Do not assert residents are finalized |
| Gideon / Martha | Candidate town cast | Seafood/tide work and bounded tradeoffs | Do not force maritime expansion before core loop |
| Thomas / households | Candidate | Ledger/service exchange visible in stock | No invented universal debt-collector morality |
| Edith / Martha | Candidate | Room/meal availability after real deliveries | No fake guest stays if town isn't implemented |
| Player / village | Future systemic arc | One visible restored place after earned work | No new main-story ending gate |

## 8. Literary review test: does the same scene respect different players?
Read each scene through four playstyles:
1. **Quiet farmer:** sold produce, made no town friends, worked at home. Does the diary respect that life?
2. **Community builder:** helped residents but delayed Hollow evidence. Are side actions valued without inventing canon clues?
3. **Explorer:** read original evidence and took risks but did not restore inn. Does the final scene refrain from calling them selfish?
4. **Unresolved past:** selected no contact, declined a late letter, kept an earlier-life object in a box. Does the story allow ambiguity instead of forced closure?

Reject any scene where NPCs know unseen deeds, every route produces the same praise, personal origin magically predicts Elias, or a later chapter demands a quest whose implementation was merely a design note.

## 9. Implementation staging — owner decision gates
**Stage A: source and playable baseline audit.** Re-fetch scripts/main.gd targeted functions, story_act.gd, folk_system.gd, estate_system.gd, diary_book.gd, save tests, current scene assets and art. Report what exists, what runs, what is proposed. No production change from this matrix.

**Stage B: practical 30-day loop.** Owner authorizes narrow crafting/nearwood/workbench slice after dependency review. Keep current materials until safe migration, old saves and tool sequence tested.

**Stage C: one human choice.** Build Maren advice/trade/independence fact, response and diary using actual original dialogue systems; screenshot/run. No bulk rewrite.

**Stage D: prototype the opening framework.** Audit pre-day1 entry, save/progress/Back/Resume/no-skip and legacy-save handling. Implement **one** approved origin branch and shared structure for editorial/playtest validation without requiring a five-origin production push that obscures issues.

**Stage E: complete all five origins with parity.** Each has source-reviewed opening, distinct winter complication, spring decision, response and September fact. Test privacy and multiple outcomes.

**Stage F: expand town and side arcs.** Resolve Lowmere/Wicker Cove postal geography, approve resident identities, add modest district, then one inn/story arc with visible effect.

**Stage G: long-form narrative QA.** Preserve original story endings and partial/late saves; time-window QA for Davy, meeting and second All Hallows, then editorial consistency across all past-life branches.

No stage starts solely because this document exists. Explicit owner authorization of scope and human acceptance at gates remain required.

## 10. Progress accountability
Track future work in TASKS.md/MESSAGE_BOARD.md under owner-approved IDs with:
- design source and exact section
- owner approval reference
- code/art paths changed, branch/commit
- tests actually run, including failures/limitations
- before/after captures for any visuals
- evidence of acceptance or requested changes

The source documents already contain rich material. Preserve full texts. When refining dialogue, propose diffable edits to specific original screenplay passages, not a re-written 'summarized version'. Keep production rollout smaller than narrative ambition until the core loop has earned it.
