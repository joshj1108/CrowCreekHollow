# CCH-YEAR1-BRANCH-001 — First-Year Branching Narrative + Back-Cover Synopsis

**Date:** 2026-11-14. **Status:** DESIGN ONLY — no code, quests, scripted dialogue, assets or revised canon endings authorized.  
**Owner direction:** A choose-your-own-adventure world where personal, practical and story decisions meaningfully alter lived experience. No universal right or wrong way to play; hidden D&D-inspired checks may resolve occasional uncertain attempts, never major authored ending gates.

## Marketing copy — proposed first official back-cover draft (not locked)

> *Some places are abandoned for a reason.*
>
> You've inherited an old farmhouse tucked away in the mountains above Wicker Cove, a struggling fishing village shrouded in a fog no one remembers quite the same way.
>
> The land is overgrown. The house is falling apart. And when the sun goes down, something moves beyond the fields.
>
> By day, carve out a life of your own. Grow crops, raise animals, fish, explore the wilderness, restore your home, and build relationships with the people who call this forgotten corner of the world their own.
>
> But the deeper your roots grow, the more you discover about those who came before you—and the choices that left this place the way it is.
>
> Every decision has consequences. Friendships change, opportunities emerge, and the world remembers what you've done. There is no single right way to live, and no guarantee that every mystery has an answer.
>
> Will you make a quiet life on the farm, help a fading community find its footing, or follow the secrets waiting beyond the lantern light?
>
> **The land is yours. The story is what you make of it.**

Do not promise implemented interactive branching, new accessible town or boat trips in a public marketing listing before those features have been approved, built and playtested. This is positioning copy for the planned finished game.

## Canon / chronological guardrails

From current `DESIGN.md`, `scripts/story_act.gd`, existing seasonal calendar:
- Day 1 = **October 1**. First year is Oct through next Sep; second autumn begins October around day 366. Normal year, no leap-day drift in this model.
- Day 4 / Oct 4: Old Maren edge trek opening. First Hollow sighting linked to this or fallback; **do not replace**.
- Day 14 / Oct 14: earliest mill route access after edge prerequisite.
- Day 152 / March 1: orchard walker route threshold in current design.
- Day 240 / **May 28**: town letter from clerk E. Pell. Some source comments call it 'early summer', but the actual calendar mapping is late spring; **game-day trigger is authoritative**.
- Day 265 / June 22: rising orchard story beat can occur on next eligible orchard trek.
- Day 285 / July 12: earliest knock-from threshold (actual knock depends on other events).
- Day 300 / July 27: mill meeting becomes available with original `maren_book` and `vicar_register` evidence; without the requirements the scene cannot be forced by a roleplay check.
- Day 357 / Sep 22: Harvest Moon meeting automatic fallback, subject to existing requirements.
- Day 370 / Oct 5 **year two**: Davy's night, existing story.
- Day 396 / Oct 31 **year two**: crow bell's second All Hallows schedule in existing story.
- Original **17 ordered story chapters and three endings** remain authoritative. Year-one optional branches should not restructure them.
- Wicker Cove is official name and permanently fogbound; residents/records disagree about fog history, with no objective onset or cause.
- Names Edith, Gideon, Thomas and Martha remain candidate new residents; new port interactions require town prototype first.
- Existing four walkers (Maren/Davy/vicar/postman), story hints, hearts and save keys must remain reachable on their original schedule.

## Year-One emotional acts and branch intent

### Autumn I — October–November, 'The Stranger'
**Shared baseline:** property is in disrepair; guided first day; survive early nights; meet Maren on day 4; make first crops/tools/meals and learn the diary.
**Candidate choice A (early farm side, playable first without new art):** A neighbor notices the struggling house; player chooses **accept advice/help**, **trade materials fairly**, or **politely work independently**. All make progress toward repairs. Difference: slight resource/time/relationship texture and a delayed neighbor callback. Do not grant/deny Maren's mandatory edge trek based on answer.
**Candidate choice B (daylight exploration):** prepare supplies for woodland edge vs cautiously scout vs wait until better equipped. The scripted first edge trek remains accessible; any optional prep yields real risk differences, but no d20 may block Chapter 3.
**Diary sample:** 'I made my first repairs alone' vs 'Maren helped me learn what needed fixing' — conditional on *actual* choice, no invented emotion.
**Callback:** A follow-up in late autumn reflects the player's approach; first frost/winter hints may differ.
**Minimum slice for testing:** One decision, two viable options, one delayed line, one truthful journal page. No new game features yet.

### Winter I — December–February, 'The Keeper'
**Shared baseline:** cold, hard food preservation, firewood, survival, staying Hale or vulnerable, ordinary winter chores.
**Candidate choice A, 'The Winter Shortage':** optional bounded request *only if home dispatch / town orders exist*, among (1) contribute to inn kitchens, (2) sell through store, (3) keep own stores, (4) help households directly. All have meaningful tradeoffs; **no alignment score**; never require free gifts, never randomly destroy supplies just for choosing self-sufficiency.
**Candidate choice B, 'A light at the gate':** choose to spend spare repair materials on the safer route/gate or own household convenience; both have tangible value and can be built later. Should use existing works when feasible, not a new competing replacement build system.
**Callbacks:** later winter acknowledgement, spring request/relationship, environmental difference where production cost is justified.
**Diary:** facts about food allocation and consequences, no prewritten guilt or generosity label.
**Roll:** none for food allocation. If meaningful repair uncertainty exists, show preparation risk in language and allow recovery.

### Spring I — March–May, 'The Neighbor'
**Shared baseline:** first spring cultivation, orchard-related trek possibilities from March, expanded personal connections and production.
**Candidate choice A, 'A reason to go downhill':** optional first Wicker Cove contact after the town exists, either responding to a customer contract, pursuing supplies, or visiting without a job. **Never gate base town travel purely by reputation.** Return to farm on same coherent world clock.
**Candidate choice B, 'Whose word to trust':** townfolk disagree on harbor fog history. Player listens to one, compares records or declines to pick a side. This alters interactions, not objective truth or original Agnes lore.
**Canonical collision check:** May 28 day 240 letter should still arrive at farm mailbox regardless of optional village contact; having previously met a villager may change *a side line*, not the clerk's content or story triggers.
**Callback:** a resident's later response, one useful economic invitation, or one more question to consider.

### Summer I — June–August, 'The One Who Stays'
**Shared baseline:** farm is increasingly productive, wood/woodland challenges and social story arcs deepen; orchard water beat may follow June 22; knock can occur later from July.
**Candidate choice A, 'Who needs the harvest?':** sell crops raw for quick income, cook/fulfill inn orders for better relationship/value, or reserve supplies for household/crafting; availability based on actual established products/contract support. Never make one path permanently optimal.
**Candidate choice B, 'First town repair':** if Wicker Cove development is ready, help one of inn/store/fish market with distinct costs and services; choose which project to prioritize rather than make other choices permanently inaccessible.
**Candidate choice C, 'How far to investigate':** examine unsettling evidence in woods, accompany an existing walker, or focus on grounded daily life; story-critical baseline narrative stays reachable. Dice may affect optional expedition complications, not whether Elias can be recovered or the bell hung.
**Callback:** inn/store stock or visual repairs, returning character letter; player diary summarizes verifiable actions rather than declaring values.

### Autumn II — September, 'What you have become'
**Shared baseline:** year's harvest, remaining character scenes, Harvest Moon Sept 22; the formal meeting branch is part of original story.
**Candidate reflection, 'Looking back':** year-end diary entry collates 3–5 highest-value decisions actually made: home self-sufficiency, neighbor support, optional Wicker Cove trade/repairs, risk/exploration, evidence seen. No generated generic compliment or invented regret.
**Canonical collision check:** Sept 22 existing automatic meeting vote follows **Maren's minute book and vicar's register**, not hidden d20, reputation points, housing restoration or community kindness. Optional dialogue can mention specific side relationships, but evidence requirements unchanged.
**Promise into year two:** select callbacks that naturally resurface in second autumn: a winter food supplier remembered, a shopkeeper's delivered goods still available, a repaired inn window lit, an old fog conversation raised again. **Do not retcon Davy's Oct 5 night or Oct 31 bell requirements**.

## Choice system / consequence matrix prototype

| Season/arc | Decision kind | Immediate state | Later callback | Roll? | No-softlock invariant |
| --- | --- | --- | --- | --- | --- |
| Oct neighbor support | Accept/independent/trade | cost/time + local impression | one late-autumn line | no | early repairs + Maren edge trek still possible |
| Oct trek prep | gear/route readiness | supplies/time + actual hazards | walker response | optional on noncritical event | chapter 3 remains completable |
| Dec food surplus | gift/sell/save/direct aid | food/coins + relevant neighbor connection | spring request/thanks | no | winter survivable by realistic planning |
| Winter gate vs home | project order | works investment | safer trail or more comfort | maybe uncertain labor | can pursue other project later |
| Spring approach to Cove | contract/shop/social | trade and relationship | return interaction | no | town access and basic shopping not blocked |
| Spring fog account | believe/compare/reserve judgment | knowledge/intention flag | later conflicting testimony | maybe record reading | mystery explanation remains open |
| Summer produce use | sell/cook/save | money/crafting/needs | order availability | no | no strategy forced |
| Summer town repair | prioritize building | repairs/world state | visible service and owner response | optional physical task | no existing ending depends on town upgrades |
| Summer evidence | investigate/hold off | cost/clue knowledge | next conversation/diary | occasional optional hazard | keep established chapter/ending path intact |
| September reflection | compiled lived facts | journal page | year-two memory callbacks | no | accurate source facts only |

**All choices above are proposed, not existing quests.** Roll outcome committed once, saved with stable ID, predictable on reload; no repeat bonus for re-talking NPC.

## One small multi-season sequence to prove the design
1. October: optional advice vs independent repair with immediate dialogue and one resource/time tradeoff.
2. November: same existing walker mentions it once, avoiding scripted guilt/praise.
3. Winter: optional same-neighbor supply/help offer changes *wording* based on prior history, but not baseline survival.
4. Spring: if relationship appropriate and player engaged, receive a modest different follow-up; no new lore needed.
5. September: the diary includes actual approach and one sentence about the later encounter; no impossible spoilers.
6. Existing StoryAct later still functions. Add this to tests before multiplying arcs.

## Work plan
- **CCH-YEAR1-BRANCH-001 — P1 Design:** this matrix, calendar/canon reconciliation, story milestones and sample chain.
- **CCH-YEAR1-BRANCH-002 — P1 Design prerequisite:** audit actual first-year triggers, existing UI/dialogue affordances, resources and quests; select one pre-Lowmere October optional decision with a November callback, no chapter rewrite.
- **CCH-YEAR1-BRANCH-003 — P1 prototype candidate:** 1 early choice, save-safe outcome, diary page + later callback (reuse CCH-DIARY-LIFE-001B / CHOICE-001C, not a duplicate quest system), after owner approval.
- **CCH-YEAR1-BRANCH-WINTER-001 — P2 Idea:** winter food/supplies choice after farm orders and economy audit.
- **CCH-YEAR1-BRANCH-COVE-001 — P2 Idea:** first Wicker Cove visit with optional multiple motives and fog testimonies, after district works.
- **CCH-YEAR1-BRANCH-SUMMER-001 — P2 Idea:** trade-vs-house-vs-town investment choices after economy and resident support.
- **CCH-YEAR1-BRANCH-REFLECT-001 — P2 Idea:** truthful September year-end diary and minimal year-two callback, after journal data prototype.
- **CCH-YEAR1-BRANCH-QA-001 — P1 eventual QA:** branch table coverage, 420-second daily schedule, Old Maren day-4 gate, first harvest, spring route, story letter day240, meeting day300/357, Davy day370, second All Hallows day396, save and controller, NPC interactions/negative no-choice test.

## Criteria for 'no right/wrong way'
- Selling to the general store is not treated as morally inferior to donating to the inn.
- Staying on the farm is a supported vocation, not social or mystery failure.
- Risky exploration can reward discovery but safe preparation still matters and remains viable.
- The player can recover from imperfect choices with effort, not by rerolling conversations.
- The game remembers player intentions and objective outcomes without asserting false psychological states.
- Major story-critical votes/endings are based on evidence/actions in the authored narrative, not a random charisma check.

**Marketing and title caution:** Back-cover synopsis is a planned-game pitch, not proof all advertised branches/town content currently exist. Wicker Cove name is confirmed canon; details of town residents, buildings, economics, seasonal side arcs are design-stage candidates.
