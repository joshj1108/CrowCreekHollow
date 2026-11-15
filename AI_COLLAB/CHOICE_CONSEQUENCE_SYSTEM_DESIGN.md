# CCH-CHOICE-001 — Living Choose-Your-Own-Adventure and Hidden Resolution Rolls

**Owner design direction:** 2026-11-14. **Status:** P1 systemic **Design**; **NO implementation approval**.  
**Creative principle (owner-set):** Crow Creek Hollow should feel like a choose-your-own-adventure throughout the playthrough. There is **no objectively right or wrong way to play**. Decisions have meaningful, persistent consequences; hidden tabletop/D&D-inspired rolls may resolve uncertain outcomes.

## What this DOES and DOES NOT change
- Adds **agency to the core game vision**, not merely more dialogue options.
- **Existing source-verified reality:** 17 ordered chapters, original ending routes `bell` (The Hollow Sleeps), `elias` (Two Came Home), `hollow` (The Line Under the Rooks); current meeting `won/lost` depends on `maren_book` + `vicar_register`; Davy and postman hooks, walker hearts, night interactions and exploration decisions already create some conditional variation. Existing story/folk code includes seeded daily encounter/request randomness. **This is NOT currently a general narrative choice-and-roll engine.**
- Preserve existing storyline, event gates, old saves and three endings as the foundation; any expansion of their conditions, texts or timing requires **separate owner-approved narrative redesign and regression audit**.
- No moral alignment/good-evil meter, no globally optimal ending, no new Charisma/Intelligence/Deception skill tree by default, no mandatory D&D branding, UI, visible dice, or licensed mechanics.
- Choices should have tradeoffs, not always symmetrical rewards. A dangerous option can still have worse outcomes; **no right answer** means meaningful alternatives and respectful playstyles, not removing stakes.

## Five layers of persistent choice
1. **Personal:** help, listen, conceal or reveal information; relationships, later dialogue and trust.
2. **Economic:** sell stock, fulfill town commission, save for own farm, supply inn/fisher; opportunity costs and different service recovery.
3. **Community:** choose building project order (inn/store/harbor) and owner cooperation; localized world-state changes, alternate routes to services.
4. **Exploration:** safe/dangerous woods, attempt/decline a route, preparation, interpretation of traces; different rewards and hazards.
5. **Narrative:** who you believe, evidence you bring, commitments you make, the town vote and Davy's decision; preserve canonical authored outcomes unless separately approved changes.

**Follow-through requirement:** Each major decision has a same-session response, one later callback in a resident/world/letter/diary, and (where feasible) a lasting gameplay state or opportunity. Not every small choice needs permanent save state.

## Resolution without arbitrary punishment
- **Do not roll for everything.** Deterministic success for normal skills, menu use, reliable work and obvious tasks. Roll when both success/complication are narratively plausible and interesting.
- Suggested internal calculation for uncertain scenes: `d20 + relevant_existing_skill_modifier + documented_preparation_bonus + relationship/aid_bonus + specific_world_modifier` versus a designer-authored difficulty band. Exact formulas/DCs to be audited/approved before code.
- Use **existing** Farming/Bushcrafting/Carpentry/Cooking/Fishing/Mining/Smithing/Combat, relevant gear/items, known evidence, weather and hearts, rather than creating an arbitrary RPG stats layer. Cleaning/Forestry are under review; rolls must adapt to eventual roster.
- Never secretly punish roleplaying by making the allegedly favorable choice a trap. Let prior actions and consequences influence odds. UI should communicate meaningful risks and advantages in ordinary language (e.g., 'You have the proper tools', 'The tide is rising') even if numeric dice remain hidden.
- Degrees of outcome: **strong success**, **ordinary success**, **partial success / complication**, **setback with a different available path**. Side content may be permanently missed through informed choices, but essential chapters, original endings and fundamental farm progression never become unreachable due to a single random low roll.
- Different approaches (practical, empathetic, cautious, risky) must be viable. Early-player low skills should not make roleplay a series of failed checks.
- No arbitrary critical-success supernatural truth. Even a perfect roll cannot definitively settle Wicker Cove's fog onset/cause, which is owner-set ambiguous.
- **No rewards for spamming** decision prompts or repeating failed actions without new preparation/resources. An outcome is committed and saved *atomically*, with a saved decision ID/outcome/dice evidence so reloading cannot reroll indefinitely.
- Persistent reproducibility: evaluate a one-time scene roll using save-stable seed or generated result persisted immediately; reopening the dialogue returns its resolved state. For debugging/tests, expose roll inputs and outputs in **developer-only logs**.

## Example choice web (original concepts, not canonical scenes)
### Inn supply choice
Player has a small winter food surplus. Options: help inn guest kitchen, fill general store order, save for winter, gift to a household. Each action has a valid use and practical tradeoff. **Normally deterministic**, no dice for selecting whom to help; weather/supply logistics could occasionally introduce an optional roll with warning. Later callbacks mention changed meal availability, shop stocking or personal preparedness. Unchosen residents continue living and can recover later; no indefinite punishment.

### Harbor boat repair
Approaches: apply trained Carpentry, inspect damage first, ask experienced fisherman to assist. A single optional hidden roll reflects preparation. Failure produces additional materials needed or delayed trip, not permanent inability to sail. Completing repair visibly changes berth access and trust; riskier choice may save time at expense of resource risk.

### Witness memory and fog
Villagers disagree about historic visibility. Player can ask, compare logs, defer judgment, or believe one resident. Outcomes affect testimony access, warmth/trust and possible future maritime directions, **not a canonical objective explanation**. Do not make 'accuse person of lying' secretly the only way to obtain a clue.

### Existing mill vote / Davy
Current narrative uses established `maren_book`, `vicar_register`, Davy and postman flags, three endings. The player already affects whether the vote is won by finding evidence. A future narrative design can add **character-specific reactions, optional support and diary wording** without replacing `_ready_for_meeting()`, forcing village restoration, or making vote depend on hidden d20. **Major canonical meeting and ending outcomes should be earned by story conditions, not decided by chance.**

## Choice topology: branches that reconverge thoughtfully
- Structure as interconnected **choice → consequence → callback** motifs, not a binary branch explosion. Many decisions alter *how* a mission unfolds or who assists, then reconverge on a shared major event with differentiated dialogue, resources and relationships.
- Keep a **small number of persistent state keys**, for example `choice_outcomes[event_id]`, `town_project_states`, `resident_trust` through the existing FolkSystem, `known_clues` through diary, but first audit actual save architecture; do not invent duplicate save sources.
- Story spine 17 chapters remains; optional side arcs and local reactions form the living web. If later user wants genuinely altered chapter order or new endings, request explicit design authorization and regression plan.
- Use observed world changes: moved boats, repaired windows, inventory changes, letters, changed resident work schedule, remembered dialogue. Rare multi-day consequences and seasonal callbacks create weight.
- Do not pretend every choice branches indefinitely. Make 3–5 excellent consequences per arc rather than 100 shallow dialogue forks.

## Decision design / authoring template
| Field | Purpose |
| --- | --- |
| Unique decision ID | Stable id, save compatibility and testing |
| Trigger/availability | Location, day/season, relationship, required preconditions |
| Player goal | What is at stake, why player cares |
| Options (2–4) | Distinct viable intentions, including defer/decline if applicable |
| Visible stakes | Plain-language resource/time/social risks; never fake percentages |
| Resolution | Deterministic / optional hidden roll; skill, prep, DC, modifier caps |
| Outcomes | strong, standard, mixed, setback; meaningful alternative route |
| Immediate effects | resources/time/relationship or scene response |
| Future callbacks | specific scene/letter/economy/world art change and when |
| Save flags | stable id/outcome and one-time rewards, no reroll exploitation |
| Recovery | how a player can recover from complication or avoid soft-lock |
| Validation | expected branch matrix, input, save/load, older saves, endings |

## P1 design and implementation gates

**CCH-CHOICE-001A — P1 Design:** audit existing `StoryAct`, `FolkSystem`, `TrekSystem`, `NightSystem`, `ProgressionSystem`, reward systems and saves. Produce a branch graph for the existing 17 chapters and three endings; catalog actual choices versus automatic gates, and note exactly which lore/story outcomes cannot be affected by dice.

**CCH-CHOICE-001B — P1 Design:** create a resolution spec with difficulty bands, bounded modifiers from **existing** skills, meaningful odds, warnings, persistent roll results and debug/simulation hooks. Avoid releasing a general dice engine before one decision proves fun.

**CCH-CHOICE-001C — P1 prototype candidate (not approved):** three connected decisions in **existing farm/walker content** (not dependent on Wicker Cove art): e.g., an optional resource allocation, a supportive vs practical answer, and a prepared vs risky exploration action. At least one deterministic tradeoff, one reasonable hidden roll, and one callback a few days later. Preserve existing story states and save migration. One small and testable vertical slice; existing features don't break.

**CCH-CHOICE-LOWMERE-001 — P2:** one early-town character dilemma with visible delayed callback, tied to inn or fish market. Reuse 001's same engine and order/relationship tools.

**CCH-CHOICE-MARITIME-001 — P3 conditional:** choices on future crew fishing voyage (stay/return, help crew, use equipment, route survey) that use preparation and possibly hidden roll. Only after first boat prototype is enjoyable.

**CCH-CHOICE-QA-001 — P1 eventual QA:** deterministic tests for all options/outcomes (incl minimum/maximum roll, save/load, old saves, resuming dialogues, event triggered twice, completing three endings, farming-focused player, nonviolent player, low-skill player, controller and UI). Monitor that no major event becomes mathematically impossible/unreasonably rare.

## Proposed player-facing expression
- Standard UI remains rustic-gothic, with concise option buttons/text in existing DialogueBox/Quests/Diary; menus pause time as currently designed.
- Hidden rolls are **truly behind the scenes** by default. Optional developer toggle can show diagnostic dice details; optional later accessibility/help setting could show confidence bands or contributing factors, not dice spam.
- Response text should convey outcome, not 'you rolled 7 and failed persuasion' unless player asks for visible rolls as a future feature.
- Optional diary reflection should recount the player's *intention* and the *actual outcome*, in their own hand, not declare a universal moral.
- For player choices with no right/wrong answer, avoid moral colors, victory/failure UI badges, alignment points or a best-choice marker.

## Exit criteria for CCH-CHOICE-001 vertical slice
1. Player selects among distinct options with clear stakes; no red/green morality labeling.
2. Outcomes use coherent deterministic or hidden bounded resolution; an unlucky roll never blocks a required ending.
3. Player receives immediate reaction **and** at least one delayed callback in later gameplay.
4. Choice and random resolution survive save/load and reload attempts consistently, without double rewards.
5. Playtest demonstrates two different player strategies yield distinct but enjoyable stories.
6. Existing gameplay tests and all 17 chapters/three ending pathways remain intact.
7. No new major map, UI redesign, skill tree, combat overhaul, or arbitrary supernatural exposition.

## Priority relationship to current roadmap
This is a **foundational P1 design concern** that influences food/orders, Wicker Cove contracts, residents and maritime quests, but **does not replace urgent CCH-EVENING-002 evaluation, CCH-FOOD-001 or stability fixes**. Design it before adding many new town NPC quests so future content can use shared decisions, persistence and callbacks rather than being rewritten.

**Owner direction is canon as a game-design pillar; numerical d20 formula, example dialogues and specific branches are candidate designs, not code authorization.**


## Companion design: lives that remember (2026-11-14)

[PLAYER_PATHS_AND_CONSEQUENCE_WEAVE.md](PLAYER_PATHS_AND_CONSEQUENCE_WEAVE.md) defines a deeper cross-season framework for personal, economic, community and story callbacks, including three sample CYOA mini-arcs. It distinguishes incidental NPC text from lasting state changes and includes a first-week review gate. These are proposals only; owner has approved the **principle of meaningful choose-your-own-adventure**, not the specific missions or dice probability formula.
