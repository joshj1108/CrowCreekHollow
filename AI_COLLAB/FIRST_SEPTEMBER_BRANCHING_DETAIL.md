# CCH-SEPTEMBER-BRANCH-001 — September: The Harvest of Choices

**Design date:** 2026-11-14. **Authority:** creative/worldbuilding design only. Existing canon is untouched, no implementation permission for Claude or gameplay scripts.
**Read with:** `YEAR_ONE_BRANCHING_NARRATIVE_DESIGN.md`, `FIRST_AUTUMN_BRANCHING_DETAIL.md`, `FIRST_WINTER_BRANCHING_DETAIL.md`, `FIRST_SPRING_BRANCHING_DETAIL.md`, `FIRST_SUMMER_BRANCHING_DETAIL.md`, `BRANCHING_RESIDENT_ARCS_AND_PLAYER_DIARY.md`, `NARRATIVE_VOICE_AND_LITERARY_STANDARDS.md`, `FOREST_LOGGING_EXPEDITIONS_DESIGN.md`, `WORKBENCH_ANVIL_WOODWORKING_DESIGN.md`, and `DESIGN.md`.

## Dramatic purpose
The year begins October 1 and its last month is **September**. September is not a 'you won year one' screen, nor a choice quiz that classifies the player. It is a month to feel a life accumulated: an ordinary harvest, visible repaired things, trust earned or declined, decisions not taken, questions that remain. Let the player recognize their personal history through the environment and their own authored diary. End-of-year theme: **'What did I make of this place?'**

**Owner-mandated voice:** literary depth in plain language. Specific details, memorable small actions, character priorities and subtext. No purple prose, omniscient personality statements or 'good/bad' moral scores. Some players care only about their homestead. They must receive an equally worthwhile reflection.

## Source-checked chronology and safeguards
- First autumn October–November, winter December–February, spring March–May, summer June–August, **September closes first Oct–Sep year**.
- `DESIGN.md`: **Harvest Moon occurs September 22**, gives **2 turnip hashes and +10 sanity** on its event start. Keep exact original event, not a newly invented town fair.
- `scripts/story_act.gd`: `HARVEST_MOON := 357`. If the parish letter exists and the mill meeting is not already held, the fallback is checked on morning **m.day > maxi(357, letter day+10)**; it is not guaranteed as an immediate cutscene on the 22nd. It calls `_hold_meeting(false)`; the meeting is won if and only if **Maren's minute book and vicar's register** were seen (existing `_ready_for_meeting()`), otherwise lost. Existing walker heart standing lines remain unchanged. Do not make Wicker Cove trade, woodworking, altruism, diary completion or any d20 roll override the result.
- Existing original Rook story comprises **17 ordered chapters, three endings**, and already has personal/Agnes/second-year diary pages. The in-game story label 'second year' is an existing category; do not change it or misdescribe the day-240 late-May letter due to a calendar-vs-story-label mismatch.
- From early **October of the next cycle**, existing story continues toward Davy's day370 night (conditional on prior orchard beat) and second All Hallows from day396. September must lead there naturally, not resolve final mysteries, Davy's fate or the bell.
- Wicker Cove is canonically named and permanently fogbound, but its map/new named residents/inn renovation currently are **planned**. Only record Wicker Cove scenes in a diary if actual gameplay/event history exists when implemented.
- User-approved future crafting/forestry: solo forest logging to supply raw logs, workbench to hew planks, workbench for tools not forged at anvil, metal tools at anvil. These are **design rules, not present gameplay**; don't assert new machinery was built or planks were cut unless save contains that event.

## Structure: four understated September movements

### P0. Sep1–10 — 'The Work That Remains'
Autumn crop preparations, seasonal scheduling, home upkeep, neighborhood requests, and normal forest/trek decisions continue. No mandatory 'year-end ceremony'. If the player's home is still in poor condition, do not force a repaired visual or congratulatory text.
**Optional interaction:** a neighbor notices something *true and specific*, such as a finished fence, a handled delivery, or the player's reliable absence from town. Responses change a later line, not universal reputation.
**Personal meaning:** someone can be rooted in their homestead without ever being famous in Wicker Cove.

### P1. Sep11–21 — 'The Things We Keep'
Optional short reference to prior choice without reciting all your decisions. The strongest callback involves an object that existed before the choice: Maren's dry wood stack, an unpaid work bill, planks at an inn, an old harbor chart, a parcel from the postman.
**Examples** (only if actually supported): a merchant returns a basket; the repaired inn room is now used; neighbor asks after the farm; the keeper of a record declines further discussion. If the player never went to the Cove, the home routine remains full.
**Diary:** player can review previously earned memories; don't re-trigger random encounters, duplicate reward, or flood journal with daily filler.

### P2. Sep22 / aftermath — 'Harvest Moon'
**Original systems take precedence:** keep the one-day Harvest Moon reward and story fallback behavior. The event's gift of **two turnip hashes and +10 sanity** occurs exactly as designed. The parish meeting can have already happened after day300; if not, the original day357/next-morning logic applies. It can be 'won' only through actual old evidence; if not, meeting proceeds with consequences already authored.
**Do not** use the personalized diary to suggest players with kind reputations automatically won; the meeting is about documented history and who will take responsibility for the bell.
**Optional tiny texture:** the player may have different contextual familiarity with village officials, but original meeting scenes and lines aren't overwritten. No compulsory festival/mass event or cinematic.
**Tone:** a harvest event provides a momentary breath of steadiness while the older Rook story runs its course.

### P3. Sep23–30 — 'A Year at the Farm'
An **optional, short first-year personal diary entry** becomes eligible only after its data is verified, preferably accessible from the existing book via a 'My Days' grouping; no intrusive popup during night or harvest gameplay.
It compiles at most 3–5 authored sentences or memory fragments from real durable facts:
1. **House / work:** restored stage, actual logged workshop/bench/plank activity (only after those features exist), crop/animal/food progress.
2. **People:** actual help/trade/independence with Maren or walkers, Wicker Cove contracts if town exists, no false claimed relationships.
3. **Risk & mystery:** actual forest treks, discovered pages, postman letter, actual ledger heard, distinguish player theory from evidence.
4. **What remains:** a task genuinely still incomplete, optional with gentle future hook.
No score, no judgment, no prize needed. Avoid giving a 'best ending' reward for having the longest diary. No fabricated regrets/attachments.
If nothing optional was attempted, show a truthful modest paragraph about basic survived seasons and work.
**Future echo:** exactly 1 or 2 year-two acknowledgments of particular choices, preferably in ordinary speech or visible unchanged repairs, never affecting Davy and Bell availability.

## Three strongly different sample journal voices (all proposed, not canon and only conditional on saved facts)

### Independent farmer, when home repairs and reserves truly completed
> The house was in poor shape when I arrived. I've repaired the roof and made a place for the firewood. There is still work to do, but I know what needs doing now.
>
> Most of what I needed this year came from the land. I kept some food, sold what I could, and learned how much work a small farm takes.

### Neighbor/craftsperson, ONLY if town and relevant repaired inn job actually happened
> I went down to Wicker Cove in the spring. The inn had an upstairs room that leaked. I brought the boards when I had them.
>
> There are people down the hill who know me now. I know a few of their troubles, too.

### Curious explorer, ONLY if the relevant forest+fog testimonies were actually witnessed
> I have walked the woods more times than I expected. I know some of the paths, though there are places I still don't understand.
>
> I've heard different stories about the fog over Wicker Cove. I wrote them down. I don't know which, if any, is true.

### Quiet farmer, little optional relationship content
> The year passed in ordinary work. I planted, harvested, fixed what I could, and kept the fire going through winter.
>
> There are people down the hill I haven't met. The road is still there. I may take it someday.

**Editorial caveat:** Each phrase above may contain details not all saves will support; actual entries must use conditional authored lines or omit the statement. Some facts ('kept the fire going through winter') require event tracking or may be paraphrased more neutrally.

## A readerly handoff to the next October

**Short original tone sample, not an in-game scene:**
> The last of the September rain tapped against the kitchen window.
>
> On the table lay a bill from Wicker Cove. Next to it, a small stack of receipts.
>
> Outside, the field had been cut back for the season. The woods were still there.
>
> You put the bills away and checked the latch before bed.

Change bill/receipts on a no-town or no-sales save! This is illustrative atmosphere, not a universal cutscene. Avoid implying the next year is a new game; survival and story continue without interruption.

## Persistent memory / design logic
Candidate memory facts (do not invent new save keys without audit):
- `home_stage` from existing estate progress; `food_produced` / `sales_made` if source stats actually persist.
- `autumn_maren_offer`, `winter_neighbor_supply`, `spring_cove_approach`, `summer_inn_boards` and `summer_evidence_stance` only after their optional prototype events are implemented and saved.
- `forest_logging_visits`, `logs_hewn_to_planks`, `workbench_built` are *future feature facts*, never inferred from current generic wood.
- Story canonical event flags `letter/shown/orchard/knock/meeting` referenced read-only, without re-displaying story spoilers before player knows them.
- Use one deterministic 'season reflection' snapshot id or compose from durable flags. Avoid changing diary outcome when player reloads, duplicate page entries or showing statements before an event occurs.
- Build 1 short page by default, with optional 'more' memory pages only after readability tests. Existing Agnes handwriting and narrative sections remain separate.
- Give an old save a reasonable partial reflection, not an invented one. The absence of new choice flags means 'not recorded' rather than a negative behavior.

## Four player test stories
1. **Farmer only:** never travels to a future Cove map, does ordinary farm/walker events; sees meaningful farm diary, original letter/meeting, full story viability.
2. **Town trade-focused:** real contracts and one remembered buyer; has ordinary town relationship and correct diary; original meeting evidence gates identical.
3. **Workshop/forest builder:** logs/bench/planks if *actually implemented*; player can choose farm vs inn with visible outcome; no fake claims or timber grind.
4. **Curious wanderer:** woods + optional conflicting Wicker Cove testimonies; evidence ambiguity preserved, original Agnes pages/meeting as authored.
Across all, the world is not judged 'saved' or 'failed' by an all-purpose meter.

## Roadmap tasks (not implementation authority)
- **CCH-SEPTEMBER-BRANCH-001 — P1 DESIGN:** this September arc and actual Harvest Moon+meeting chronology.
- **CCH-SEPTEMBER-BRANCH-002 — P1 DESIGN AUDIT:** trace current diary player pages, story event flags, season/day gating, persistent stats/old saves and next October state before choosing 3–5 truthful lines.
- **CCH-SEPTEMBER-DIARY-001 — P2 GATED CANDIDATE:** one optional season-year memory page integrating 2–3 verified personal facts, after approved P1 choice and diary prototype. Reuse `CCH-DIARY-LIFE-001B`; don't create a diary generator.
- **CCH-SEPTEMBER-CALLBACK-001 — P2 GATED CANDIDATE:** one year-two spoken/physical callback conditional on an existing saved decision, but never a substitute for `maren_book`, `vicar_register` or authored ending prerequisites.
- **CCH-SEPTEMBER-BRANCH-QA-001 — P1 eventual QA:** 4 playstyle checks, no-town-run, early-game fallback, missing facts, diary handwriting, save/version, September22 event gain, day357 next-morning meeting, year-two Davy/crow bell, all 17 chapter progression and endings, normal year rollover.

**Canon / proposal separation:** September Harvest Moon date and reward, story meeting code and prerequisites, Wicker Cove town identity/fog and home gameplay are established. 'My Days' yearly recap, sample lines and social/woodworking acknowledgments are conceptual features until actually implemented.

## 2026-11-14 — Mandatory origin memory is equally weighted in first-year reflection

Owner now requires *The Road to Crow Creek Hollow* as a **mandatory new-game interlude**. The player's reason for arriving is **as important** as what they chose to do or why they stay. The optional first-year diary reflection must include source-truthful aspects of **both** the chosen opening origin/meaningful later origin choice and the recorded first-year actions, without pretending a backstory was skipped or fixed. A pragmatic origin gets the same care as a painful one. If old save has no origin fields, do not fabricate one. Exact prologue and future source fields will be audited before implementation; do not change current September 22 Harvest Moon or day357 meeting fallback.
