# CCH-AUTUMN-BRANCH-001 — First Autumn: The Stranger

**Created:** 2026-11-14. **State:** Narrative/UX **design only**, no implementation, game code, sprites, quest/dialogue or canon rewrite approved.
**Parent:** `YEAR_ONE_BRANCHING_NARRATIVE_DESIGN.md`; `CHOICE_CONSEQUENCE_SYSTEM_DESIGN.md`, `BRANCHING_RESIDENT_ARCS_AND_PLAYER_DIARY.md`, `MASTER_ROADMAP_TO_1_0.md`.
**Owner philosophy:** choices shape a different life without right/wrong moral scoring; later callbacks matter, optional hidden rolls only for uncertain efforts.

## Actual source constraints checked 2026-11-14
- `DESIGN.md`: Day 1 Oct 1, 420-second day, bed at 18:00+, first-day guided actions, chapters 1–10 ordered. Chapter 3 **To the Wood's Edge** = escort Maren from day 4; chapter 4 **Food Takes Time** = first harvest around day 8. Chapter 9 cleanse, 10 restore fully; untouched.
- `scripts/folk_system.gd`: Maren key `mill`, `from: 5`, `edge: true` (farm *visits* require edge walk done); **her required day-4 edge walk is through TrekSystem and should remain**, not an invented farm visit day 1. Existing `FolkSystem._start_day()` may randomly schedule visitors, seeded by day; Maren does NOT visit every day. Conversation ordinarily once per day; heart/scene and requests are saved. Postman can start day 6; Davy day 20; vicar day 40. Do NOT overwrite their real start days.
- `DESIGN.md` events: Oct31 **All Hallows** lanterns/halved dark sanity; Nov10 **First Frost** for 3 days causes faster outdoor warmth drain; Dec21 Longest Night. Oct/Nov is actual first autumn. Harvest Moon Sept22 is **later** than the first autumn, don't insert it now.
- Early scary sequence already includes first night and later Hollow sighting after edge walk; don't substitute a new creature/scene that alters timing. Early farm materials, hunger/sanity, first chapter and lighting work must remain viable.
- `StoryAct` begins later in existing chronology. Original 17 chapters/endings and `maren_book`, `vicar_register`, `davy_turn`, `post_hand` cannot be gated by new side choices.
- Wicker Cove is official seaside village name, always covered in fog, with contradictory fog history. The town isn't implemented yet, so **first-autumn prototype must function entirely on existing farm and walkers**; Wicker Cove dispatch letter is a *future* optional side hook after orders work.

## Emotional target
Not heroic chosen-one framing. The player is an outsider making a shelter and routines. Their early choices change the *relationship to the place*: resourceful independence, practical exchange, human connections and cautious curiosity can all be admirable and worthwhile. Warmth is modest and earned. Let the original psychological horror land in contrast to simple daytime tasks.

## Seven-part authored beat outline

### A0 — Oct 1, 'The Empty House' (shared, no major branch)
- Guided first day, find diary, move and plant, gather/tidy, drink, prepare for bed. Give player clarity and agency; one small optional nonbinding reaction like 'fix/clean/cook first' can change an immediate journal sentence if later implemented, but **do not overload day one with a full dialogue wheel**.
- First-night original encounter remains; player's choice of rest vs night preparedness is in current systems. No new hidden d20 for mandatory sleep/chapter 1.
- Diary note: observational; avoid telling player they love or fear the property if they haven't said so.

### A1 — Oct 4+ at the existing Maren edge trek, 'A Hand or a Trade' (first meaningful branch, proposed)
**On Maren's existing mandatory escort interaction, add one OPTIONAL conversation at an appropriate safe point** (the same day/scene, or follow-up once the trek is completed); do not displace or delay the escort.
Options:
1. **Accept practical guidance:** Maren offers a mundane repair/wood-storage tip; player chooses help, some modest time/resource benefit if balanced. She regards the new farmer as willing to learn.
2. **Propose a fair exchange:** player offers available ordinary supplies/service in return for help. If no suitable inventory, alternative trade with work rather than hard fail. Maren respects competence/mutuality, no social demerit.
3. **Prefer to learn independently:** player thanks her and carries on; no forced 'pride' label or point loss. Player may spend more time/materials, gains firsthand experience.
**Immediate:** concise distinct response; modest optional practical effect; no nontrivial advantage that creates meta 'right answer'.
**Delayed:** one reliable mailbox/note or scheduled game-state callback around Oct14–Nov10; visits may also reference choice if encountered. No dependence on random Maren visitation.
**Winter echo:** later optional support opportunity wording varies, but Maren's gate visits, heart ladder, and `maren_book` route remain attainable regardless.
**Diary:** one truthful personal page with selected choice; no invented thanks/regret; only record if actual scene completed.
**Check:** story chapter 3 works and all endings remain possible in each option, no duplicate rewards, save/load one-shot flag.

### A2 — Oct 8 onward, after first actual crop harvest, 'The First Surplus'
**Availability:** player has something genuinely spare after survival, and a mechanism for optional delivery/trade exists; do not offer a contract requiring future crops or hard-coded day 8 if not harvested. Original `Food Takes Time` chapter is automatically achieved based on actual crop growth, not controlled by this arc.
Options:
1. **Store it** for winter; practical home safety and an eventual self-sufficiency diary memory.
2. **Sell it** at existing farm stand, receive ordinary fair coins. Later recognition from the buyer only if an orders/business system can truthfully support it.
3. **Share through an optional neighbor request** using existing `FolkSystem` or later home dispatch, not magic removal of food. Tangible relationship/return benefit, not morally better.
**No d20 for selecting allocation.** Never duplicate income or XP. Require in-hand item counts and deliberate confirmation.
**Callbacks:** optional early-Nov diary/letter and a winter follow-up, conditional on actually fulfilled request. If option unavailable because no surplus, skip/deferral is valid and not a moral failure.

### A3 — Oct 14 onward, 'Which Path Is Safe?'
**Existing source:** mill route from day 14 after real trek prerequisites; avoid claiming it must happen precisely Oct14 (simulation often later).
**Branch:** bring sufficient provisions and take prepared route / examine an optional side detail cautiously / defer exploring it. This affects optional time/risk, not original trek access or essential story pages. Maren's help and woods encounters stay their original systems.
**Hidden roll candidate:** optional identification of weathered marks using existing Bushcrafting, items, conditions; complication could be uncertain clue or lost daylight. No randomized blocked chapter or guaranteed supernatural fact.
**Callback:** one conditional weathered note or walker response weeks later. No new monsters required.
**Diary:** player's actual approach and observed outcome, not assumed motive.

### A4 — Oct 31 All Hallows, 'The Road of Lanterns' (shared event with side reflection)
Existing All Hallows is already lantern-lit and reduces dark cost. Preserve exact effect. Add OPTIONAL warm/dread flavor in player's diary based on decisions and whether they were in at night. No unique paid quest or forced choice.
Possible contrasting sentences: 'The road glowed beyond the gate. I stayed by the fire.' vs 'I walked beneath the lanterns before coming home.' Only if actual game position/time supports it.
**No automatic 'old town festival' claim:** Wicker Cove is still in future design, not a current accessible map.

### A5 — Nov 10 First Frost, 'What I Saved'
**Existing event:** Nov10 for 3 days, outdoor Comfort/Warmth drains faster. Do not invent new temperature mechanic. First Frost provides consequence opportunity:
- Prepared household has practical buffer (food/firewood/gear) and optional diary affirmation.
- Player with sparse stores can gather/buy/support using existing systems; no punitive irreversible starvation due to an earlier generous decision.
- A neighbor may ask for modest assistance later **only if actually accessible and consent-based**.
- 'Help someone else vs repair own roof/gate first' is a possible later optional choice if supplies are available; not a first-frost forced morality check.
**Roll:** none required. Preparation is deterministic.

### A6 — Late Nov, 'A Place to Return To' (end-of-autumn callback)
A single optional diary page summarizes **2–3 remembered decisions actually taken** plus observable state (first crop, first repair, named neighbor interactions if seen), not a personality classification. Avoid revealing Agnes's hidden pages or saying which version of fog history is true.
A one-sentence notice/letter from Maren can recall initial help/exchange/independence and give a tangible or emotional callback, but should never be the only way to unlock her existing scenes.
The player's **winter starting state** reflects resources, improvements and actual decisions, not a pre-scripted 'good' route.

## Compact branch matrix
| Event ID candidate | Option flags | Same-day result | Later callback | Critical no-break invariant |
| --- | --- | --- | --- | --- |
| `autumn_maren_offer` | learn / exchange / independent | differing ordinary reply, small time/material effect | conditional letter or line Oct14–Nov30 | day-4 edge trek still completes; Maren scene ladder intact |
| `autumn_first_surplus` | stock / sell / share / deferred | actual inventory/coins/request result | Nov/Dec dialogue or journal | harvest chapter still based on crop; no duplicate rewards |
| `autumn_woodside_detail` | prepare / investigate / defer | resource/time + optional skill-conditioned resolution | optional line/diary weeks later | original trek route/page not behind roll |
| `autumn_hallows_reflection` | computed from real actions | brief note only | none required | existing event unchanged |
| `autumn_frost_preparedness` | computed from resources | real weather challenge | end-season page | no hidden irrecoverable survival penalty |
| `autumn_retrospective` | actual prior flags | short 'my days' entry | winter callbacks | no fabricated memory or hidden story spoilers |

**All IDs and options are placeholders for design, not actual save keys.**

## Example original dialogue (design-only, not copied from existing scenes)
**Maren, at the end of the first walk:** 'The house has been standing empty long enough to forget what a dry winter feels like. There's a way to stack the firewood where it won't drink the rain.'
- **Take her advice:** 'Show me, if you've a moment.' Maren explains a storage trick; later, 'Keep the lower logs off the ground. You remembered.'
- **Offer an exchange:** 'Would you take a hand with the mill in return?' She considers it, then nods; later she remembers the work rather than a gift.
- **Go independently:** 'I'd like to see if I can put it right myself.' Maren: 'Then do. Call if it proves stubborn.' Later: 'Looks like you've found your own way with it.'
No NPC scolding or universal best path; options do not require Maren visiting the farm early.

**Diary variations (only conditional on real event):**
- 'Maren showed me how to keep the wood dry. I tried her way when I got home.'
- 'We made a fair trade. I helped where I could, and she gave me good advice.'
- 'I chose to learn the repair myself. It took more work, but it is standing.'

## Practical authoring/persistence design
- Small in-scene 2–3-option UI over existing dialogue (which currently supports **line/scene/again**, not a confirmed general choices menu). Do **not** assume this UI already exists.
- Unique choice ID, chosen option, resolved cost/reward, day, later callback state. Use existing save architecture as audited; never roll or reassign outcome on opening same prompt.
- Do not create parallel friendship values or change already-saved `FolkSystem.bonus`, `seen`, `requests_done` identities without deliberate compatible mapping.
- Diary via existing sections/page renderer; set hand to 'yours', not Agnes; only show verified facts, restrained first-person wording.
- Rare optional uncertain woodworking/mark-reading check may use a bounded behind-the-scenes d20 with Bushcrafting/tool/preparation bonus and fail-forward, **only if warranted after human testing**.
- Existing gameplay has 420 seconds per day. Favor one 15–30-second optional choice rather than lengthy text sequences that interrupt first-hour learning; dialogue/menu pauses game under existing behavior.
- Prefer a reliable callback mechanism (mailbox/morning report/diary) over a visitor scheduled by seeded RNG. No added compulsory reminder.
- Test first harvest accessibility, controller dialogue choice navigation, old saves, branching outcome persistence and original story ending flags.

## Minimum prototype recommendation and boundaries
**P1** prototype only **A1 `autumn_maren_offer`** after first checking TrekSystem's exact day-4 integration and available dialogue surfaces; 3 brief choices, immediate response, one late-Oct callback via reliable source, two/three page variants. Add resource effect only if economy audit supports it. No Wicker Cove map.
Then **P2** add A2 inventory-based choice through existing stand/requests, A3 optional Bushcrafting check, and A6 autumn reflection, after gameplay validation. A4/A5 can remain ambient and responsive without major quest scripting.
**Definition of done:** two human playthroughs choose different responses and see different verified later text without save corruption, blocked chapter/ending, hidden roll gambling, bad UI layout or increased compulsory chores.

## Roadmap tasks
- **CCH-AUTUMN-BRANCH-001 — P1 Design:** first-autumn beat and choice matrix, source-reconciled with real day gates and events (this document).
- **CCH-AUTUMN-BRANCH-002 — P1 Design audit:** verify TrekSystem day-4 dialogue flow, actual choice UI limitations, save insertion point and reward balancing; draft exact A1 option/response script.
- **CCH-AUTUMN-BRANCH-003 — P1 candidate prototype (NOT approved):** A1 single Maren decision + reliable callback + diary variants, reuse `CCH-YEAR1-BRANCH-003` and `CCH-DIARY-LIFE-001B` rather than creating an unrelated engine.
- **CCH-AUTUMN-BRANCH-004 — P2 Idea:** inventory-driven A2 surplus decision (safe/sell/share); align with CCH-FOOD-001 and CCH-ORDERS-001.
- **CCH-AUTUMN-BRANCH-005 — P2 Idea:** A3 optional preparedness/exploration decision and one uncertain roll, only if fun.
- **CCH-AUTUMN-BRANCH-006 — P2 Idea:** A4/A5 All Hallows + First Frost personalization without rewriting existing event effects.
- **CCH-AUTUMN-BRANCH-007 — P2 Idea:** optional end-of-autumn diary and winter follow-up.
- **CCH-AUTUMN-BRANCH-QA-001 — P1 eventual QA:** original chapter order, day4 trek, day14 mill, harvest ~day8, Maren availability, Oct31/Nov10 effects, old-save round trips, branch coverage, later endings, 420s daily pacing.

**Canon vs candidate reminder:** Day gates, event dates, existing folk roles, story and Wicker Cove name are established. Maren's help offers, decisions, distinct dialogue, resource outcomes and new diary entries are proposed and must not be described as already playable.
