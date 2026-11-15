# CCH-30DAY-SLICE-001 — The First 30 Days: A Playable Life Worth Continuing

**Created:** 2026-11-14. **Status:** design/implementation brief **awaiting specific owner authorization**. Not a direct instruction to Claude. Do not rewrite existing scenes, throw away production art or build all year-two concepts first.
**Purpose:** Translate months of coherent narrative/production design into one small slice a real player can understand, enjoy and finish. Real human review before expanding.
**Dependencies:** `DESIGN.md`, `LIVING_WORLD_PRODUCTION_BLUEPRINT.md`, `FOREST_LOGGING_EXPEDITIONS_DESIGN.md`, `WORKBENCH_ANVIL_WOODWORKING_DESIGN.md`, `FIRST_AUTUMN_BRANCHING_DETAIL.md`, `CHOICE_CONSEQUENCE_SYSTEM_DESIGN.md`, `SCENE_ANTHOLOGY_AND_CHARACTER_VOICE_BIBLE.md`.

## What already exists in current game and must not be lost
- Day1 begins October 1; guided diary teaches plant/gather/craft/chop/drink.
- Chapter 1 **Sleep Under Your Own Roof** (bed before 03:00), Chapter 2 **Light the Way** (Tin Lantern), Chapter 3 **To the Wood's Edge** (Old Maren day4), Chapter 4 **Food Takes Time** (first crop around day8), and the rest of 17 sequential chapters with existing rewards.
- First night has fixed scare, first subsequent Hollow sighting after Maren edge trek as designed. Day length ~420s; existing early playable milestones ~25–30 real minutes.
- Day14 earliest mill route after proper prerequisites; Davy farm visits from day20 if selected; postman day6, vicar day40, Maren after edge/day5. No guaranteed visitors.
- Current forestry: 12 far-flung grove trees, generic `wood`; current tools are made from Craft panel. User requires **forest logging**, **logs→planks at workbench**, **non-anvil tools at bench**, **metal tools at anvil** in future target design. Conversion/save audit required.
- User wants balanced eerie lighting (not pitch-black), lantern tier extends radius not brightness, static main menu, cozy lived-in interiors, good indie quality and not endless polish.

## What 30 days must prove — player outcomes
At end of day30, a first-time player should be able to say:
1. 'I know where to cut trees, and I don't have to hunt for the few trees at the edge of the farm.'
2. 'I made a tool at a workbench and turned logs into real planks; I used them for one useful thing.'
3. 'I can grow food, meet my needs and sleep without spending every evening in repetitive chores.'
4. 'I met Maren through an existing story beat, and one thing I chose changed a later comment or message.'
5. 'The woods are unsettling but not so dark or punishing that I never want to leave the house.'
6. 'I know at least one worthwhile thing to do tomorrow beyond following the next chapter.'
7. 'The game's actual main story and save system still work. I didn't get stuck making my first lantern or visiting the wood's edge.'

These are *future acceptance goals*, not statements of current build status.

## Proposed day windows — NOT new compulsory schedule

### Day1: A house and a little work
- Preserve guided first-day diary. Teach only first basic farming, inventory and survival.
- **Workbench access** must exist immediately or require a simple starter repair possible with free gathered materials and no bench-made tool. Ideal: old usable bench in a sheltered part of property (must fit current interior/workshop layout after audit).
- Do not require hewn planks to build the one and only workbench. No circular recipe.
- Player's first axe or starter axe viable. Basic planting and water do not become gated behind a new crafting tutorial.
- Night scare unchanged, readable in balanced lighting.
- **Test:** Day1 player can go to bed, save and begin day2.

### Day2–3: A reason for a tool
- Introduce an obvious **forest logging access** on farm's edge through visual sign and a short readable pathway. Early nearwood trees visible and clearly harvestable, 6–10 good targets in proposed first slice.
- Player can also gather initial small wood from remaining homestead grove trees as safety valve.
- Bring raw logs home, interact with workbench, hew first planks. Show recipe where planks will be useful.
- **Tin Lantern crafted at correct early physical station** (likely bench assembly) without needing a late metal anvil; never undermine original Chapter 2.
- **Test:** first lantern can be obtained with realistic day1–3 effort for new player, not just debug menu.

### Day4: Old Maren and the woods
- Preserve Maren edge escort/TrekSystem original. Optional human choice at a safe conversational beat, after the required walk if necessary: accept practical guidance, exchange work fairly, or work independently. **No new option may cancel escort, block original Hollow sighting or deliver `maren_book` prematurely.**
- Conversation UI currently may not support general options. Prototype uses existing UI or adds one small reusable selection control, test with keyboard/gamepad.
- Record exactly one chosen fact and any real paid materials. User may skip optional choice without penalization.
- **Test:** Chapter 3 remains complete, first night after as canon, no duplicate walker XP/reward.

### Day5–10: A harvest and an echo
- Turnip harvest ordinarily around day8; Chapter 4 follows actual crops, not forced day8 dialogue.
- Workbench/plank recipe usable for one modest real home repair, balancing game costs so a single useful logging trip matters.
- One callback from Maren's earlier choice via reliable mailbox/morning note (not dependent on `FolkSystem` random visits), with a short factual player diary memory.
- Leave ordinary farm market sale and basic cooking intact.
- **Test:** old save and new save both work; no player path gets rich for free from doing the Maren choice.

### Day11–20: Different afternoons
- A simple loop players can choose among: nearwood woodcutting, basic farming, fish pond, one existing walker journey when eligible, minor home repair, small contract through stand/mailbox **only after approved home dispatch**.
- Day14 mill access threshold as existing conditions, not a forced day14 trek.
- Davy first farm-visit eligibility day20 but seeded visit may not occur; don't force him to appear to tick a day20 checklist.
- One ordinary optional scene (stone skipping) can wait for real Davy visit; no new story gate.
- **Test:** 10-minute unscripted play segment with 2–3 appealing alternatives, not a blank afternoon.

### Day21–30: The land begins to recognize the player
- One small physical change persists: finished workbench, stacked lumber or valid home improvement.
- One real remembered social choice remains visible in diary and/or a related walker/morning message.
- No new Wicker Cove map required for this first version. Optional letter/order can suggest goods from downhill community without pretending first-time player can travel there today.
- Normal game loop supports farm-only play. Every harvest doesn't become a mandatory delivery quest.
- **Test:** player voluntarily begins day31 with a meaningful next project.

## Exactly one connected vertical-slice scenario
**'The Dry Boards' — not a new chapter.**
1. Player is told the roof or a shelter part needs dry lumber, while wood is hard to locate on farm.
2. Clear forest path leads to nearwood; fells one or two trees, obtains raw logs.
3. Bench hews some logs to planks; the game's *real recipe* accepts them and one useful improvement appears.
4. During Maren edge trek she makes an optional comment about dry wood; player's answer determines an actual small help/trade/independent approach.
5. At a later eligible day a note references **what actually happened**, not assumed motivations. Diary likewise says what they did.
6. If player never spoke to Maren, skip related memory. No mandatory new narrative reward.

**This scenario combines three existing approved future goals: meaningful forest lumber, workbench crafting and player-authored memory—rather than building three isolated prototypes.**

## Required cross-team audits and implementation gates
1. **Tree/woods:** examine `FarmLayout.GROVE_SPOTS` and trees, tile collisions, routing to a compact nearwood scene; no change to original escorted TrekSystem or NW cave/hillside.
2. **Materials/recipes:** enumerate all `wood` uses (fuel, building, tools, farm repairs, catalog, furnace, lanterns), new log/plank keys or migration strategy, item/art/UI; compare 14/90/365-day economy.
3. **Station placement:** where bench and future anvil fit (current workshop/house interiors); no incorrect player clipping or cut-off sprites. Support standard action button and gamepad.
4. **Dialogue:** determine one safe callback integration without duplicating `FolkSystem` scene logic, scripted lore revelations or gift points.
5. **Diary:** one factual player-hand page, not Agnes page, no false emotion/spoiler.
6. **Testing:** 30-day first-time player sequence with actual controls; headless simulations for year-long survival and three story endings; save migration and regression.
**Each implementation slice must have owner approval and image review when owner asks.**

## Priority checklist for a responsible build
- [ ] Current gameplay first-hour baseline captured and reviewed for actual playability (not just scripts).
- [ ] P1 audit first hatchet/lantern/workbench resource cycle.
- [ ] P1 nearwood logging access + 1 harvest-to-inventory chain approved.
- [ ] P1 workbench hewing + 1 non-anvil tool approved.
- [ ] P1 one practical repair consumes real planks without economy inflation.
- [ ] P1 one optional Maren choice + later recall + factual diary approved.
- [ ] P1 old save & chapter 1–4 tests pass.
- [ ] P1 30-day relaxed/cautious/explorer player playtest passes.
- [ ] P2 only after slice: home dispatch orders, first Wicker Cove visit and two-worker scene, guest room in later phase.

## Not for this slice
- New NPCs/romances or 12-scene anthology implementation.
- All four Wicker Cove residents, offshore trips or large coastal economy.
- Hidden skill-check engine or random failure on baseline woodcutting/bench crafting.
- New mandatory winter chore loops, extra survival bars, giant festivals.
- Moving day240+ story events into this period.
- Renaming old Lowmere runtime postal lines without full continuity decision.
- Changing original chapter order, all three endings, or main-menu animation.

## Success metrics (proposed and testable)
- **Findability:** novice navigates to nearwood and spots first harvestable tree without external map/wiki; take note of time and confusion, not arbitrary precise seconds requirement.
- **Satisfaction:** one tree→log→plank→repair loop gives visible progress and consumes reasonable portion of afternoon.
- **Agency:** at least 2 different meaningful optional afternoon activities by day10; not endless forced button prompts.
- **Social:** two runs with distinct Maren approaches give distinguishable later factual response even after reload.
- **Safety:** no case where bench requires its own planks, a tool requires late anvil, or forest log unavailable in time to complete lantern/day4.
- **Stability:** original day1/scare/day4/first harvest, input/save, story timeline and three endings continue.

## Tasks
- `CCH-30DAY-SLICE-001` P1 Design: this first 30-day playable experience and test matrix.
- `CCH-30DAY-SLICE-AUDIT-001` P1: current tree/wood/bench/lantern/first day UI code audit.
- `CCH-30DAY-SLICE-FOREST-001` P1 gated: one nearwood woodcutting area (reuse CCH-FOREST-LOGGING-003).
- `CCH-30DAY-SLICE-WORKBENCH-001` P1 gated: log/plank processing+one tool/one repair (reuse CCH-WORKBENCH-001).
- `CCH-30DAY-SLICE-STORY-001` P1 gated: Maren one-time choice, delayed callback, diary (reuse CCH-DIARY-LIFE-001B).
- `CCH-30DAY-SLICE-QA-001` P1 eventual: first 30 day and full ending legacy regression.
**Design complete as proposal. No script edits, new assets or gameplay actions authorized in this writing pass.**
