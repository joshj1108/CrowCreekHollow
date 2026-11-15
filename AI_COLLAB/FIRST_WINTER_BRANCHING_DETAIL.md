# CCH-WINTER-BRANCH-001 — First Winter: The Keeper

**Planning date:** 2026-11-14. **State:** Narrative and gameplay design only. **No approval for Claude implementation, code, art, NPCs, quests, rewritten chapters, changes to RNG or story outcomes.**
**Companions:** `FIRST_AUTUMN_BRANCHING_DETAIL.md`, `YEAR_ONE_BRANCHING_NARRATIVE_DESIGN.md`, `CHOICE_CONSEQUENCE_SYSTEM_DESIGN.md`, `PLAYER_PATHS_AND_CONSEQUENCE_WEAVE.md`, `MASTER_ROADMAP_TO_1_0.md`.
**Owner principle:** choose-your-own-adventure throughout, consequential and persistent decisions, no universally right/wrong path; D&D-style rolls may resolve occasional uncertain work behind the scenes.

## Emotion and narrative stakes
Autumn asked: 'What kind of life will you build?' Winter asks: **'When keeping that life going becomes difficult, what matters most to you?'** Rather than introducing a new big villain, winter should show believable costs and rewards of weather, preparation, cooperation, protection and exploration. It must not force players to be altruistic, extremely social or daredevil.

The farm is the emotional core. One cold night with fire, hot food and a personal diary should feel special. Character priorities should matter as much as supernatural events; quiet winter play should remain fully enjoyable.

## Source-grounded existing facts (checked 2026-11-14)
- Game starts October 1. Winter spans December–February. Current day is **420 real seconds**. A new activity must leave usable daylight.
- Existing `DESIGN.md`: rain/downpour/fog and rare snow; temperature winter baseline about **40°F** plus daily/weather variation; below 50°F outside Comfort drains. Hearth needs firewood; one firewood burns 3 in-game hours, up to 12. Bed can't restore comfort if hearth is unlit according to the current firewood notes. Cooking includes warming tea/soups and fish.
- **Dec 21 The Longest Night** existing event: night's sanity change is doubled. Preserve this exact mechanic; optional player reflection must not re-trigger night effects or spawn obligatory penalties.
- **Jan 1 Winter Feast** existing event: two grilled fish and a bandage added to pack. Preserve and acknowledge; do not invent a town-wide banquet as implemented.
- **Mar 1 Spring Thaw** existing event: watered crops grow an extra stage. This is the handoff to spring. Preserve.
- `TrekSystem` starts 'wood comes closer' pressure from first winter **day 62** (~Dec 1) and only after 12 days without a trek. This is core existing tension; don't promise safely avoiding it without engaging with trek mechanics. But new optional choices must never secretly worsen it beyond existing rules.
- Existing first-winter `Trail works` panel unlock and winter trail risk, including cold; repair options already use actual resources and persistent build flags. New side story should ideally reuse that system, not fabricate a second replacement route upgrade.
- Existing `FolkSystem` residents and availability: Maren after edge walk/day5; postman day6; Davy day20; vicar day40. Farm visitor appearance is seeded, intermittent; essential future callbacks must not rely solely on randomly scheduled visits.
- Canonical 17 chapters and the three endings, including Maren book, vicar register and later Davy/postman hooks, must remain unaffected by optional winter side arcs.
- Wicker Cove is official name, a struggling fogbound fishing town downhill. The actual town map and new named residents are design candidates, not currently available play. Winter prototype must be valid on existing farm, gate, mailbox, walker and trail content.

## Seasonal act structure

### W0. Dec 1–10 — 'A New Kind of Cold'
**Shared:** The player discovers how autumn preparation affects pantry, roof, firewood and excursions; actual Hearth/Comfort/weather systems do the heavy lifting. A short diary page can acknowledge what the player truly has (without judging preparation).
**Optional choice:** Spend modest resources first on own warmth/workshop convenience, an **existing** route improvement (if unlocked and affordable), or reserve them. These are different investments; not a false 'help neighbors or starve' binary.
**Callback:** Later weather/route/daily interaction reflects existing upgrade if genuinely bought; no extra abstract reputation unless player interacted with someone.

### W1. Dec 11–20 — 'A Knock Before the Storm' (proposed main choice)
**Availability:** Only if accessible via existing walker/gate/mailbox and if inventories and early resources allow sensible stakes. If shortage is detected, offer smaller service/time-only alternatives; never remove needed materials on acceptance without checking quantities.
**Premise:** A neighbor down the lane needs dry wood and some food before cold weather. This should be an **ordinary human need**, not a supernatural trap. Who is affected and how they ask must be reconciled with FolkSystem/Maren/postman and actual town access.
Distinct viable responses:
1. **Offer some provisions:** voluntarily provide bounded actual stock, one-time transfer. Can create trust and later reciprocity; household reserve decreases.
2. **Arrange an exchange:** fair compensation via ordinary coin/materials/service, actual cost/value audited; relationship framed as mutual responsibility, not greed.
3. **Keep own reserve:** neighbor pursues another solution; player protects own readiness, retains relationship opportunity later; no scolding or karma flag.
4. **Find another solution:** optional inquiry into an ordinary supply delay or damaged trail; consumes time/prep; may lead to different resolution, but not mandatory endless errand.
**No hidden roll on the four moral/economic priorities.** Only if investigating repair/route contains actual uncertainty may one bounded behind-scenes existing-skill check affect cost/clarity; offer explicit risk language. No auto-failure of generosity or 'critical good deed.'
**Immediate reaction:** a few distinct dialogue lines or note; actual inventory/money effects where appropriate, only if implemented and tested.
**Delayed callback:** during Jan via reliable mail/diary or scheduled interactions; by spring a small changed neighbor exchange or practical opportunity. A neighbor who wasn't helped is not frozen waiting.
**Diary:** player's own writing based on factual choice and observed results; never assign guilt, love or selflessness by script.

### W2. Dec 21 — 'The Longest Night'
**Existing canon:** nightly Sanity effect doubled. Do not replace, duplicate or add an extra drain. The existing lamp, hearth, food and optional risk choices are the drama.
**Optional moment:** At dusk player could choose to tend hearth/prepare, remain indoors, or venture to the edge with existing safety tools; no need to invent a separate event UI. Variation in a later diary page should be based on real actions/visited area, not a scripted assumption.
**Story safety:** Do not use RNG to decide canon first Hollow encounter or later necessary chapter evidence.

### W3. Jan 1 — 'Winter Feast'
**Existing canon:** two grilled fish + bandage. Preserve quantities; event currently does not establish a village banquet.
**Future scene seed:** A neighbor mentions how villagers distribute food in winter; player may share a meal, barter, or keep supplies. This is OPTIONAL and only possible when items and consent/interaction exist; never remove the event reward through forced side narrative.
**Economy/agency:** Sharing should have a balanced human callback without making free donations the highest-value economy path.

### W4. January — 'What the Neighbors Remember'
**Payoff:** If W1 happened, one distinct local report, brief letter, or NPC dialogue acknowledges what was actually done. It should be plausible for a reliable postal system and existing characters, not require new accessible Wicker Cove.
**Consequence types:** a household is stocked sooner, a modest trade offer, a useful tip, or evidence others helped when player kept stores. No single positive consequence should be pure cash/XP inflation.
**Choice:** Accept follow-up help, decline politely, or propose practical work; no pressure to repeat donation.
**Use existing daily visits as bonus flavor, not sole delivery.**

### W5. February — 'What Endures'
**Shared:** winter season offers legitimate play via existing winter-available crops, fishing, preserved food, upgrades/trail works, tools, comforting recipes and woodland treks. Focus on usefulness, not dozens of pop-ups.
**Optional priority:** invest limited spare resources in farm efficiency, trails, or future town trade preparation (town plans may be hinted via mail but don't claim town is playable). All are recoverable; no hard irreversible exclusivity.
**Diary:** brief season recap reflects verified winter actions and actual shortage outcome. If the player ignored events, record only what is known. Do not create false 'you fed the village' text.
**Spring handoff:** first request/conversation in March can differ by winter outcome; March 1 Spring Thaw original crop bonus remains.

## Concrete winter choice web
| Stable candidate ID | Prerequisite | Player options | Immediate meaningful effect | Jan/Mar callback | Roll | Invariant |
|---|---|---|---|---|---|---|
| `winter_house_priority` | actual materials/works state | improve home / trail work / save | actual purchased upgrade or retained supplies | different convenience and diary | no | farm and original trail remain playable |
| `winter_neighbor_supply` | a valid offer with quantity cap | contribute / trade / reserve / investigate | real stock/money/time, distinct response | neighbor/mail + spring opportunity | only optional investigation | no forced generosity or permanent lock |
| `winter_longest_night` | real Dec21 event | not a new forced decision; use actual play style | existing night consequences | truthful note if recorded | none additional | no double sanction |
| `winter_feast_followup` | Jan1 and real neighbor interaction | share / barter / keep / skip | optional resource/social consequence | later ordinary recognition | no | grant original two fish+bandage |
| `winter_spring_preparation` | February resources | farm / trail / savings | infrastructure/stock different | March affordance | no | all paths viable |

These are **candidate IDs**, not implemented save flags.

## Side-story voice examples (original illustrative lines only)
**Neighbor's request:** 'This weather has worked its way into every wall on the lane. They're short of dry logs down at the cottage. I'm asking everyone I pass, not just you.'
- Give: 'I can spare a little.' — 'Then it'll be put to use. Thank you.'
- Trade: 'I can part with some if there's work to exchange.' — 'That's fair. They have hands even if their shed is empty.'
- Reserve: 'I don't have enough to risk it.' — 'I understand. I'll ask down the road.'
- Investigate: 'What happened to the last load?' — 'Nobody knows for sure. The trail washed out, I think. Could be worth a look when the rain lets up.'
**Later Maren or postal note:** In spring: 'I remember the winter you kept your roof warm first. Looks like it was worth the effort.' OR 'The house had wood when the thaw came. There were other hands in it too.' Both are observations, not scripted moral verdicts.

## Winter atmosphere and useful play
- Warm window and hearth contrasts wet exterior, wind in boards, frost on interior windows, cooking steam and lamps; use existing house stages and seasonal art; any new art requires later owner approval and screenshot review.
- The persistent 24/7 fog is specific to Wicker Cove. Farm's ordinary winter fog weather can vary; never replace it with permanent coastal whiteout.
- Offer 2–3 realistic meaningful choices for afternoon after mandatory maintenance: winter crops (kale/leek/parsnip depending levels), winter fish (black crappie, lamprey at relevant levels), tea/soup/smoked food, simple repairs, existing treks and friendships. Audit recipe items/skill gates before claiming starter availability.
- Repair a real route once rather than create endless snow shoveling. Stage-based infrastructure reduces chores, not increases them.
- The horror intensity of Dec21 is already real; do not pile a new required chase or surprise death onto it. Quiet players and high-risk players should both have legitimate activities.

## Persistence, hidden rolls and diary rules
- One stable choice/outcome recorded once, including actual transfer and how solved. Restore same outcome on reload; no free rerolls of checks or duplicating gifts/XP.
- A delayed callback must be deterministic and reachable even if NPC doesn't visit randomly; morning mail/diary can deliver if appropriate.
- Existing player-hand diary sections and Agnes-hand pages remain unchanged. Add only selected authored journal lines based on verified facts and intention.
- Never assert Wicker Cove fog history, Agnes/Elias chronology or main-story outcomes as definite through random options or flavor.
- Year-one 'no right/wrong' means no silent morality/charisma tracker, not equal material payoffs or immunity from harsh weather.

## Smallest feasible prototype and gates
- **FIRST:** verify whether `CCH-AUTUMN-BRANCH-003` one-choice+callback prototype exists and passes human tests; reuse its mechanism. Do not build winter-exclusive dialogue or dice infrastructure first.
- **WINTER FIRST SLICE:** one `winter_neighbor_supply` with two or three choices feasible with real items, one callback weeks later via reliable delivery, one accurately authored diary variant; safe if skipped. Keep scene under a minute of reading.
- **REGRESSION:** December 21 still doubles original night Sanity effect once; Jan1 still gives two grilled fish + bandage; Mar1 original thaw; day62 wood encroachment; equipment/Comfort/Hunger/Thirst, older saves, early-game winter economy and chapter/endings access intact.
- **PROPOSED:** add more season-specific arcs only if players feel remembered, not nagged or punished.

## Task IDs and priority
| ID | Priority | Status | Dependency |
| --- | --- | --- | --- |
| `CCH-WINTER-BRANCH-001` | P1 **design** | This document | Original autumn and season source |
| `CCH-WINTER-BRANCH-002` | P1 **design** | Next: resource/event/folk-save audit and bounded first winter decision spec | CCH-AUTUMN-BRANCH-002, CCH-FOOD-001 |
| `CCH-WINTER-BRANCH-003` | P2 idea / gated prototype | One household supply choice, Jan callback, personal diary | CCH-CHOICE-001C + CCH-DIARY-LIFE-001B |
| `CCH-WINTER-BRANCH-004` | P2 idea | Existing Longest Night/Feast personal reflection | Diary/event integration |
| `CCH-WINTER-BRANCH-005` | P2 idea | February preparation, March callback, low-chore winter loop | CCH-WINTER-001 |
| `CCH-WINTER-BRANCH-QA-001` | P1 eventual QA | Save/choices/rolls, no-branch play, winter cost, story/event/trek validation | Approved prototype |

**Canon established:** event dates/effects, current farm/walker systems, 17 chapter story, Wicker Cove name and fog lore. **Proposed only:** dialogue, story incident, options, reward amounts, and journal entries.
