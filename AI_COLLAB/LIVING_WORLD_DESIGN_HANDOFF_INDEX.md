# Crow Creek Hollow — Living World Design Handoff Index
**Last compiled:** 2026-11-14. **Authority:** DESIGN MATERIALS ONLY. No feature, dialogue, character, map, sprite or save schema in this index is automatically approved for implementation.

## The agreed creative direction (owner-set)
- Top-down 3/4 rustic-gothic cozy farm/survival/life game; playable indie-quality, not perpetual polishing.
- Literary ambition with plain natural language, meaningful player-authored memories and character life beyond player; no good/bad alignment or class lock.
- Original Agnes/Elias Rook 17 chapter story, original Davy/Old Maren/vicar/postman roles, original three endings and their flags protected.
- Wicker Cove is official name for downhill deteriorating coastal fishing village, under permanent fog with contradictory fog-history testimony. Cause/date unknown.
- Farm/cave/hillside and static main menu visual direction kept. Eerie but balanced lighting; lantern upgrades expand radius, not brightness.
- New woodworking owner rule: logs hewn to planks **at workbench**, every non-anvil tool made at workbench, metal tools forged at anvil, specialized fuel/smelting/cooking stations preserved. Timber should come primarily from accessible intentional **forest logging** excursions rather than searching a dozen farm trees.
- New residents Edith Vale, Thomas Bellweather, Gideon Pike, Martha Fenwick remain **tentative candidates**, not finalized owner-named canon or existing script characters.

## Read-first source of truth
1. `../DESIGN.md` — currently implemented player/stories/features (including older-current crafting; newer owner-design addenda are not implemented).
2. `scripts/story_act.gd`, `scripts/folk_system.gd` — actual story, timing, save flags and walker dialogue. **Always re-fetch live before modifying**.
3. `MASTER_ROADMAP_TO_1_0.md` — long-range milestone/priority plan; `DEVELOPMENT_ROADMAP.md` — detailed task backlog.
4. `MESSAGE_BOARD.md` and current Claude notes — prior implementation activity, state to reconcile.
5. This index — where new authored design work lives, not a secondary implementation authority.

## Design library, grouped by job

### The story's emotional structure
- `YEAR_ONE_BRANCHING_NARRATIVE_DESIGN.md` — back-cover synopsis, Oct-to-Sep thematic question, choice table and timeline.
- `FIRST_AUTUMN_BRANCHING_DETAIL.md` — Day1–Nov30 story-safe Maren/harvest/wood edge/frost.
- `FIRST_WINTER_BRANCHING_DETAIL.md` — Dec–Feb resources, optional shortage, December21/Jan1 calendar.
- `FIRST_SPRING_BRANCHING_DETAIL.md` — March–May first optional Wicker Cove visit and May28 town letter.
- `FIRST_SUMMER_BRANCHING_DETAIL.md` — June–Aug livelihood/inn repairs/conditional original orchard/knock/mill events.
- `FIRST_SEPTEMBER_BRANCHING_DETAIL.md` — factual player diary, Harvest Moon and next-year handoff.
- `YEAR_TWO_COST_OF_STAYING_DESIGN.md` — second calendar autumn, original Davy Oct5, second All Hallows, three original endings and postending continuation.

### Character literary standard and content
- `NARRATIVE_VOICE_AND_LITERARY_STANDARDS.md` — plain-language editorial standard.
- `LITERARY_STRUCTURE_AND_HORROR_PACING.md` — wood/light/paper/water/sound motifs, ordinary life and controlled horror tension.
- `CHARACTER_LIVES_AND_RELATIONSHIPS_DESIGN.md` — four existing walkers and tentative new residents as working human beings.
- `LIVING_COMMUNITY_RELATIONSHIP_WEB.md` — indirect knowledge and 10 plausible NPC-to-NPC ties, small social stories.
- `SCENE_ANTHOLOGY_AND_CHARACTER_VOICE_BIBLE.md` — 12 compact proposed scenes, voice scorecards and integration gates.
- `RESIDENT_ARCS_TWO_YEAR_BLUEPRINT.md` — 8 bounded character-based arcs with choice/result/echo patterns.
- `YEAR_ROUND_COMMUNITY_RHYTHMS.md` — realistic month-by-month lived-in routines without adding mandatory holidays.
- `INN_ROOM_BRANCHING_STORY_PROTOTYPE.md` — fully worked Edith/Thomas repair, guest brief, winter response and later lit-window sample.

### Game world and physical actions
- `WORKBENCH_ANVIL_WOODWORKING_DESIGN.md` — required logs/planks/bench/non-anvil tools and metal anvil policy, migration/gating checks.
- `FOREST_LOGGING_EXPEDITIONS_DESIGN.md` — repeatable nearwood primary timber source and optional deeper hardwood.
- `LOWMERE_FIRST_DISTRICT_DESIGN.md` — Wicker Cove first street and orders, legacy stable filename.
- `LOWMERE_RESIDENTS_DESIGN.md` — tentative resident identities/roles and owners' outstanding decisions, legacy stable filename.
- `LOWMERE_ECONOMY_HISTORY_DESIGN.md` and `LOWMERE_COASTAL_WORLD_DESIGN.md` — working harbor economy and optional voyage ideas.
- `WICKER_COVE_LIVED_IN_DISTRICT_BIBLE.md` — practical map, warm windows and dense readable fog, work and inn-room UX.

### Implementation pathway / canon safety
- `CHOICE_CONSEQUENCE_SYSTEM_DESIGN.md` and `BRANCHING_RESIDENT_ARCS_AND_PLAYER_DIARY.md` — one persistent choice + later echo + truthful existing diary, not a new quest factory.
- `LIVING_WORLD_PRODUCTION_BLUEPRINT.md` — six acceptance outcomes and staged source-first delivery.
- `FIRST_30_DAYS_LIVING_WORLD_VERTICAL_SLICE.md` — **best next production review brief** connecting forest logs, workbench planks, first basic repair and one Maren choice-memory prototype, without town.
- `WICKER_COVE_POSTAL_LORE_CONTINUITY_AUDIT.md` — **mandatory unresolved** original script vs renamed town lore: postal letters, bell crate, 'over hills' phrase. Recommended Option A (same place over ridge descending to coast) **not owner-approved yet**. Raw repository search required because indexed search gave false negatives.

## Recommended near-term order (not implicit approval)
1. Inspect **current working Godot build** with screenshots/input and actual code; audit 30-day first-hour resource/chapter issues and postal lore, not merely old design docs.
2. Ask owner to approve a very small **first-month source-safe** patch brief: usable early workbench/hatchet, visible nearwood timber source, logs→planks and one real repair; independent safe migrations.
3. Implement/test one **Old Maren choice + future callback + factual diary** using existing UI and save architecture, no Wicker Cove and no major story change.
4. Validate 30-day human play. Make sure normal evenings and independent farming are enjoyable.
5. Only then create first compact **Wicker Cove** scene with 1–2 approved resident identities, actual order, short return road, readable permanent fog; reconcile postman geography first.
6. Add one room/repair brief with guest feedback; test long-term saved state and postending continuity.
7. Gate optional deeper maritime routes and larger cast behind existing farmer/town fun and original story completion.

## Non-negotiable QA gates
- Chapter 1 sleep, chapter 2 Tin Lantern, Maren edge trek from day4, first harvest around day8; no axe→bench→plank→axe deadlock.
- Existing story day240 letter, day265 conditional orchard, knock threshold, day300+ meeting with **maren_book+vicar_register**, Sept22 fallback, conditional Davy Oct5 day370 20:00–01:00, day396 crow bell and ending routes.
- All three endings: `bell`, `elias`, `hollow`, including recoverable Hollow ending and postending free play; no moral/reputation/roll overrides.
- No player diary invents a player emotion, unknown secret, completed action, Wicker Cove encounter, fog answer or made planks that weren't actually saved.
- Wicker Cove coastal fog constant while farm weather seasonal; clean route home, gamepad readable, 420-second day viable.
- Workbench/anvil production station rules and forestry source after implementation, old-save wood migration without resource loss/duplication.
- Static main menu and source-consistent balanced gothic visuals maintained; no spontaneous animation or wholesale art refactor.

## Pending owner decisions (do not silently settle)
- First two Wicker Cove resident identities/confirmed names, first interior (inn vs store), and any appearance/ages.
- Runtime postman Lowmere correspondence/iron over-hills geography reconciliation (Option A recommended; original scenes untouched).
- Actual workbench location and starter access, exact log-to-plank yields/material pricing, forest tree regrowth and travel time.
- Whether first actual new personal scene is Maren advice/trade/independence and exact resource reward, based on practical UI/save audit.
- What is safe/relevant to implement in next Claude Code batch after visual review and test gate.

## Completion accounting
As of this date, the linked work is **writing, design and roadmap updates only**. The repo's live game code was not changed by this pass. Avoid reporting an idea as playable simply because a Markdown document describes it.

## November 14, 2026 — Deep thematic and player-identity story design

A further research-grounded narrative pass expands the project's *emotional structure*, without implementing anything:
- [PLAYER_IDENTITY_AND_HOME_STORY_BIBLE.md](PLAYER_IDENTITY_AND_HOME_STORY_BIBLE.md): central idea **inheritance ≠ belonging**; distinct ownership/belonging/responsibility questions; five tensions of shelter, reliance, records, keeping, inherited duty; farmhouse as repeated setting; deed/tenant contrast; player identity emerges from *recorded behavior*, never a class/moral label; original 17 chapters and endings mapped to emotional reversals.
- [HOUSE_MEMORY_AND_PLAYER_DIARY_ATLAS.md](HOUSE_MEMORY_AND_PLAYER_DIARY_ATLAS.md): seven remembered spaces (bedroom, kitchen, hearth, workshop, door/mailbox, stand/fields, forest edge), sample conditional prose, factual event ledger vs explicit player opinion, reliable diary page composition, alternate/no-town/old-save safety and one small vertical-slice proposal. No invented log→plank, inn repair or deed state.
- [MEANINGFUL_CHOICES_AND_REVELATION_ARCHITECTURE.md](MEANINGFUL_CHOICES_AND_REVELATION_ARCHITECTURE.md): eight-step **existing canon** reveal ladder, six types of player decisions, eight fully sketched optional situations, narrative causality, Davy safeguarding and three original ending meanings without ranking lives.
- [NARRATIVE_QUALITY_BENCHMARK_AND_RED_TEAM.md](NARRATIVE_QUALITY_BENCHMARK_AND_RED_TEAM.md): concrete anti-melodrama, anti-railroad, anti-punishment, pacing and continuity tests; 12-point scene grading; four contrasting playthrough matrix; recurring-object payoff and three release gates.

New design IDs: `CCH-STORY-LIFE-001`, `CCH-HOUSE-MEMORY-001`, `CCH-STORY-CHOICES-001`, `CCH-STORY-QUALITY-001` P1 editorial design recorded. Source audits: `CCH-STORY-LIFE-002`, `CCH-HOUSE-MEMORY-002`, `CCH-STORY-CHOICES-AUDIT-001`, `CCH-STORY-QUALITY-002` P1 proposed. First real code slice is still one existing-farm choice/memory and separate forestry/workbench audits after **explicit approval**, not wholesale new lore. `CCH-LORE-NAME-001` postal Lowmere/Wicker Cove conflict remains pending owner resolution.

## 2026-11-14 — Before Day One: personal arrival prologue

[**PLAYER_ARRIVAL_INTERACTIVE_PROLOGUE_DESIGN.md**](PLAYER_ARRIVAL_INTERACTIVE_PROLOGUE_DESIGN.md) documents *The Road to Crow Creek Hollow*: Firewatch-inspired **form**, original story. Player chooses a grounded reason for moving, one prior relationship or no disclosure, and a keepsake or none; sees short interleaved travel/arrival segments, then resumes the unchanged October 1 guided day. Four possible optional later life echoes (contact/work/independence/memory) do not classify their morality or affect original 17 chapters/three endings. **Canon/legal guardrail:** `EstateSystem` currently leases town-held land with 12,000 coin optional later deed purchase; the new personal past cannot declare a free inherited deed or blood relation to Agnes. `CCH-PROLOGUE-001` P1 design complete, `-002/-003` P1 audits/owner decision, prototype and memory P2 gated, QA P1. This is planning only.

## 2026-11-14 — Definitive owner correction: non-skippable past, equally important

Earlier index prose describing the new prologue as **'short optional'** is now **superseded**. The [PLAYER_ARRIVAL_INTERACTIVE_PROLOGUE_DESIGN.md](PLAYER_ARRIVAL_INTERACTIVE_PROLOGUE_DESIGN.md) *Road to Crow Creek Hollow* is a mandatory, non-skippable interlude for **every new game**. Reason for arriving is as significant as reason for staying, with an origin story that advances throughout the seasons and at least one meaningful later choice; not a few decorative echoes. Accessible reading pace, pause/resume and no loss of day1 time remain required. A player may withhold individual private details but cannot skip why they came. Old saves remain compatible without inventing retroactive histories. The existing town-held estate and later deed purchase remain source canon. Current change is **approved creative direction / documentation, NOT implemented or approved game code**.

## 2026-11-14 — Two complete lives, not a disposable prologue

Read [**TWO_LIVES_INTERWOVEN_ORIGIN_ARCS.md**](TWO_LIVES_INTERWOVEN_ORIGIN_ARCS.md) after the mandatory [PLAYER_ARRIVAL_INTERACTIVE_PROLOGUE_DESIGN.md](PLAYER_ARRIVAL_INTERACTIVE_PROLOGUE_DESIGN.md). Five origin types now have complete proposed interlude→autumn→winter→midyear agency→September→year2/afterending arcs. Neither the reason for arrival nor the life built on farm dominates the story, and the earlier life remains active independent of supernatural fate. P1 design `CCH-TWO-LIVES-001` drafted; P1 narrative/engine audits, gated playable prologue and later actual consequences remain. No code modified.

## 2026-11-14 — New first authored opening screenplay

[**ROAD_TO_CROW_CREEK_HOLLOW_BRANCHING_SCREENPLAY_DRAFT.md**](ROAD_TO_CROW_CREEK_HOLLOW_BRANCHING_SCREENPLAY_DRAFT.md) is the principal **working dialogue/prose script** behind the mandatory, no-Skip `PLAYER_ARRIVAL_INTERACTIVE_PROLOGUE_DESIGN`. It contains a common opening, five distinct origin departures, realistic parting relationship or no-person scene, keepsake, road scenes, threshold and first-winter letters/decisions. Use as *proposed literature* only, pending scene/voice/legal and implementation review, and pair with `TWO_LIVES_INTERWOVEN_ORIGIN_ARCS.md` for full autumn-through-afterword development. Existing October1 and original endings protected.

## 2026-11-14 — Companion spring screenplay

[**ROAD_TO_CROW_CREEK_HOLLOW_SPRING_RETURN_SCREENPLAY.md**](ROAD_TO_CROW_CREEK_HOLLOW_SPRING_RETURN_SCREENPLAY.md) is the midyear counterpart to [**ROAD_TO_CROW_CREEK_HOLLOW_BRANCHING_SCREENPLAY_DRAFT.md**](ROAD_TO_CROW_CREEK_HOLLOW_BRANCHING_SCREENPLAY_DRAFT.md): five meaningful new personal-history decisions and consequences based on selected opening and winter events. Read both for the owner's **mandatory interlude and equal-weight former-life** rule. Both are source-safe editorial proposals, not shipped text or features.
