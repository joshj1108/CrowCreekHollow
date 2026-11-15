# CCH-SUMMER-BRANCH-001 — First Summer: The One Who Stays

**Creative planning:** 2026-11-14. **State:** **DESIGN ONLY.** No game code, assets, dialogue, story condition or quest implementation authorized.
**Read with:** `YEAR_ONE_BRANCHING_NARRATIVE_DESIGN.md`, `FIRST_SPRING_BRANCHING_DETAIL.md`, `FIRST_AUTUMN_BRANCHING_DETAIL.md`, `FIRST_WINTER_BRANCHING_DETAIL.md`, `NARRATIVE_VOICE_AND_LITERARY_STANDARDS.md`, `CHOICE_CONSEQUENCE_SYSTEM_DESIGN.md`, `PLAYER_PATHS_AND_CONSEQUENCE_WEAVE.md`, and operational roadmaps.

## The central literary question
Autumn: **Can I live here?** Winter: **What do I keep?** Spring: **Who are my neighbors?** Summer: **What am I willing to become responsible for?**

This is **not** an oath to always protect the town. Summer is when actions begin to have visible permanence: a full pantry, a repaired room, a farm more efficiently cared for, an owner who remembers the player's work, and evidence that people on the mountain have histories the farmer did not know. No player must volunteer, investigate, donate, sail or renovate in order to be 'good'.

**Narrative thesis:** Staying is a series of ordinary actions before it becomes a choice in any dramatic sense.

## Verified existing spine and chronology
- Actual play begins **October 1, Day 1**, so this first summer is **June–August** in the first Oct-to-Sept play cycle. Existing chapters 11–17 are labeled 'The second year' in game, even though the first letter, on day240, falls in late May of the *first calendar cycle*. Preserve both actual day gates and existing chapter names; don't silently rename them.
- **Day240 (~May28):** E. Pell's parish letter appears in the farm mailbox and must remain available irrespective of whether Wicker Cove exists or was visited. Showing it to a neighbor is an authored main story beat.
- **June21 Midsummer Heat:** existing **3 sunny days**; do not invent a playable beach festival or a mandatory heat-quest. Existing weather/needs remain authoritative.
- **Day265 (~June22):** the water rising at the orchard occurs on a **qualifying subsequent orchard trek after the letter has been shown**, not unconditionally at midnight on June22.
- **Day285 (~July12):** earliest threshold for the Hollow's copied knock, but actual onset is **max(day285, orchard-beat day+4)**. Keep existing night system; don't randomize this mandatory beat via new dialogue.
- **Day300 (~July27):** mill meeting can occur on eligible mill trek if the **Maren minute book** and **vicar register** scenes have been seen. These are existing evidence gates, not reputation, donations, Wicker Cove construction or d20 rolls.
- **Day357 (Sept22):** Harvest Moon automatic meeting fallback occurs **after** the threshold (morning condition checks day greater than max(357, letter day+10)). Avoid guaranteeing exact meeting on the morning of Sept22; wording is 'at/after Harvest Moon' and triggered by existing code. All 17 original chapters and three endings are protected.
- First farmhouse **Restored** stage currently has **summer-only** final repair/paint condition (`DESIGN.md`). There is no current approval to rewrite that condition.
- Summer crops include turnip/corn/potato/pumpkin/strawberry/blueberry subject to levels; summer fishing and wild flax vary with actual skill and timing. Don't script requests for unavailable goods.
- The day is ~420 real seconds, so a town trip needs a compact, worthwhile loop. Wicker Cove map, named new residents and construction commissions are **proposed**, not implemented.
- Wicker Cove stays permanently foggy even in inland sunny heat, with conflicting memories/records about fog history and no definitive cause.

## Summer arc structure: seven beats

### U0 — Early June: 'The Letter on the Table'
The farm is busy, but the recently delivered clerk's letter can turn the player's sense of ownership inside out. People who came to Wicker Cove for trade may realize its local government is implicated; people who remained at the farm learn the same facts through the original letter.
**Optional interpretation choice:** Show/ask one already-available walker about the letter now or continue ordinary work and seek answers later. Do not alter letter content, `shown` trigger, receipt or necessary progression. Side dialogue can reflect whether the player earlier traded in Wicker Cove, repaired an inn room, or knew no one there, if that state truly exists.
**Diary:** 'The letter came up from the town. They voted against the bell. I had thought of them as the people who bought my crops.' Only if this player's history supports that thought; otherwise neutral factual phrasing.

### U1 — June, 'Where the Harvest Goes'
One meaningful **economic priority**, not a morality test:
1. **Keep/build farm reserves:** grow/livestock/food/repair needs, get more independence.
2. **Sell direct or through ordinary house dispatch:** cash, a reliable customer relationship, more seed/tool buying capacity.
3. **Process/cook for a targeted inn or local request:** stronger Cooking and a useful contract if unlocked, with time/material overhead.
4. **Prepare materials for selected Wicker Cove repairs:** an optional investment with clear time and cost, dependent on a built town.
Each remains available in other weeks; a player isn't locked to a class. Favor real costs and relevant current systems rather than abstract 'influence' currency.
**Callback:** buyer remembers a delivery, more food is available, pantry stays stocked, or future repair progresses—no exaggerated global town prosperity for one shipment.

### U2 — June21–23: 'Three Hot Days'
Existing Midsummer Heat keeps farm weather sunny for three days. Wicker Cove's permanent fog **does not lift**, providing a quiet visual contrast on an optional trip.
Possible **textured scene**: farm crops need ordinary attention while workers near the harbor dry nets in the same grey air. 'Sun above the road. Fog below.' Avoid claiming this proves supernatural chronology or cause.
No new seasonal festival, scripted heat disaster, or forced additional thirsty meter.

### U3 — After day265/qualifying orchard trek: 'The Water Rises'
**Original story event unchanged:** Davy's drowned orchard and Elias lantern. This can be the first moment that a thriving daily life collides with serious consequences of the old Rook history.
Allow player to **react** in a non-blocking line after required authored scene, perhaps offer Davy company, ask a practical question, or leave him some space. These can set small relationship/diary callbacks without changing the canonical `orchard` beat or `davy_turn`.
No dice to read the lantern's 'truth'; avoid assuming a family secret NPC should reveal.
**Theme:** Working neighbors can have lives and memories that are painful, even if the player has helped them.

### U4 — Mid/late July: 'A Sound at the Door'
The Hollow's Elias knock remains an authored night beat after `knock_from`; don't replace, reroll, soften by buying a town upgrade, or turn into a moral-choice test.
Preparations (hearth/fire, tools, lighting, sanity, treks and risk) are legitimate existing player choices. New scene text may mention aftermath, not rewrite core rules.
**Plain-language example:**
> You had been counting the boards you still needed for the roof.
>
> There was a knock at the door.
>
> Three slow taps.
>
> A voice you hadn't heard before said your name.
Keep any actual voice/dialogue contingent on real game canon; this is tone-only and may not reflect exact implemented encounter.
**Diary:** avoid saying player opened/answered unless that actually happened.

### U5 — From day300 (late July) through August: 'At the Mill'
Maren's minute book and vicar's register remain two earned documents for successful re-vote; no d20, harbor reputation, renovation, donation, romance, 'good alignment' or high skill can replace them.
The player may arrive as someone who has made friendships, spent seasons alone, or prioritized commerce. Optional callback lines can reflect those ties without changing **eligibility, fixed vote outcome, or one-time rewards**.
Some walkers stand with you at heart threshold in existing lost-vote scene; **do not silently overwrite existing dialogue, `STAND_HEARTS` or mechanic**. Extra resident reactions should be separate non-authoritative follow-ups if desired.
The contrast: a person can have many neighbors, yet truth still needs evidence.

### U6 — August end: 'What Stays Repaired'
The player sees **real consequences** of year-one investment: an actually improved house, a harvest/pantry, a paid contract, a specific repaired room in the future town, a resident's ordinary thanks, or a journal note about evidence found. No automatic 'town restoration complete' meter.
Optional summer diary reflection can pull 2–4 verified facts and one authored player-expressed stance. Avoid telling players they feel home, guilt, bravery, or love.
Bridge into **September — 'What You Have Become'** and Harvest Moon without ending the game early.

## A connected summer choice case: 'The Boards We Have'
**Proposed once Wicker Cove's inn and small project commission exist.** Edith needs a few usable boards for a leaky upper room; the player is also saving timber for their own farm.
- **Repair the farm first:** player secures own structure and gains comfort/time. Edith uses buckets, does a smaller repair herself or seeks a different supplier; no permanent penalty or moral judgment.
- **Supply boards to the inn for fair payment:** money + owner's genuine gratitude, postpones farm upgrade; visible section of roof/room improves if completed.
- **Offer help for a shared job:** contribute materials and labor within existing skill boundaries; opens one later guest-room brief and a reciprocal business relationship, after normal costs.
- **Decline for now:** choice remains available at a later valid stage if building still needs repair; town continues its life.
**Hidden roll candidate:** a genuinely uncertain roof inspection may use bounded existing Carpentry/tools/weather bonus. A bad roll could increase a reasonable repair cost or require another method, not make Wicker Cove inaccessible or decide the mill vote.
**Immediate outcome:** repaired detail on actual room, a paid contract, or retained lumber.
**Late August callback:** Edith or customer mentions actual work done; when absent, no false thank-you.
**Second-year echo:** brief conditional dialogue/letter referencing help, **without making Edith a substitute for Maren, vicar or postman evidence**.

## A second connected case: 'How Much Do You Need to Know?'
After receiving E. Pell's letter and meeting villagers with uneven memories, player can:
- **Ask** how a public record was kept,
- **Compare** an old ledger to spoken accounts,
- **Protect** a source who prefers privacy,
- **Wait** and keep running the farm.
The player's chosen stance affects which *optional* discussions follow; **Maren's minute book and vicar's register remain obtainable by original methods**. Contradictory fog recollections cannot establish a real fog onset. This arc is a character/voice feature, not a second competing quest spine.

## Distinct summer trajectories (illustrative)
| Previous history | Summer focus | Visible/usable consequence | September line or later callback |
| --- | --- | --- | --- |
| Independent homesteader | Farm upgrades and storage | less maintenance, food/tool readiness | diary accurately names repairs and what remained unfinished |
| Reliable merchant | Useful orders and sales | bounded coins, stock/customer dialogue | merchant recognizes sustained practical work |
| Village craftsperson | One inn/store repair if commissioned | real before/after and service | owner notes specific repair without declaring town saved |
| Friend of walkers | More talks and guarded knowledge | known evidence/relationship scenes | extra acknowledgment but no replacement of evidence |
| Curious explorer | Wood/optional chart investigation | real supplies/clues/risk; incomplete answers | diary distinguishes observation from theory |

**All five are approaches, not permanent classes or moral ranks.**

## Writing samples (plain-language literary, *not canon dialogue*)
**Inn repair:**
> 'There are three buckets upstairs,' the innkeeper said.
>
> 'How bad is it?'
>
> 'Bad enough that I ran out of buckets.'

**Market seller:**
> 'You could sell me the corn now,' the merchant said. 'Or bring it down when the next boat's due. I won't pay extra for a promise.'
>
> He looked at the crates.
>
> 'But I'll pay fair for what's here.'

**Davy's ordinary silence (do not replace his main story scene):**
> Davy did not ask you to explain the lantern.
>
> He pulled his coat tight and watched the water.

**A summer night at home:**
> The kitchen window was open. The last of the light caught on the table.
>
> You set down the day's earnings.
>
> Then someone knocked.

These should be edited for actual character voices/context and only attached after story event validation.

## Choice consequence structure
- Same-day player-meaningful cost and response.
- 7–30 days later: 1 reliable echo (letter, schedule, NPC line or environmental change, as fits feature).
- September: one truthful personal diary sentence acknowledging actual summer priority, with no hidden moral label.
- Later year two: optional single line or physical town state maintained.
- Use **one shared choice+memory+save system** from P1 choice prototype; no duplicate 'summer choice manager' or 'town influence' bar.
- New village cast are still **candidate** NPCs with tentative names; details need approval before canon.
- Main story dialogue/flags are authoritative. Do not automatically deliver or reroll beat achievements from an added side event.

## Player-facing playability / production budget
- Summer must improve useful everyday loop, not be a chain of long mandatory cutscenes.
- Existing weather, farm crops, specialty foods, fishing, cellar/house restoration, night encounter, trek requirements remain functional independently.
- Wicker Cove remains an optional economic/social location; once built, first town proof is compact street + inn/store/market/dock, not full ocean travel.
- Each new town event should take at most one short interaction and a later conditional sentence in v1 test, not four multi-page speeches.
- No 'right' choice, but outcomes can be materially unequal as a credible consequence of costs and preparation.
- P1 story QA must use actual day-gated conditions, input tests and save/load replay checks for no-visit, farmer-only, builder and investigator playthroughs.

## Proposed priorities and tasks (no implementation approval)
| ID | Priority | Status | Scope |
| --- | --- | --- | --- |
| **CCH-SUMMER-BRANCH-001** | **P1 Design** | Documented | This source-reconciled Jun–Aug narrative structure |
| **CCH-SUMMER-BRANCH-002** | P1 Design | Proposed | Audit precise StoryAct beats, early summer resources and callable optional reaction points |
| **CCH-SUMMER-BRANCH-003** | P2 Idea | Candidate | One economic allocation decision (farm/contract/repair), later owner acknowledgment, truthful diary |
| **CCH-SUMMER-BRANCH-004** | P2 Idea | Candidate | Conditional Rook-letter/ordinary villager response while preserving fixed story |
| **CCH-SUMMER-BRANCH-005** | P2 Idea | Candidate | One town inn repair preference when CCH-LOWMERE-001 + CCH-LOWMERE-BUILD-001 exist |
| **CCH-SUMMER-BRANCH-006** | P2 Idea | Candidate | August personal memory and September bridge from actually saved events |
| **CCH-SUMMER-BRANCH-QA-001** | **P1 eventual QA** | Proposed | Day240, 265 conditional orchard, 285 and +4 knock, 300 meeting, autumn fallback, 17 chapter endings, saves and all player styles |

## Spring-to-autumn throughline
- **Spring:** A village recognizes the Rook farmer; new business/social opportunities open.
- **Summer:** It starts relying on the *work* the farmer chooses to contribute; existing letter/woods story grows sharper.
- **September:** The player can see in real saved game state what they built, traded, repaired, learned and left alone.
- **Second autumn:** Existing Davy night and bell decisions bring original story consequences; optional social memory may alter human context, never the existing chapter logic.

**Editorial reminder:** Literary ambition comes from credible details, cause and effect, distinct practical voices and restraint—not from long dialogue or mandatory bleakness.
