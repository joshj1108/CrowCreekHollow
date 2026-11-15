# CCH-HOUSE-MEMORY-001 — The Farmhouse Remembers Work, Not Motives
## Environmental Memory, Diary Composition and Character Reactions

**Draft:** 2026-11-14. **Status:** DESIGN ONLY, no code, art, save migration, or diary-text implementation approval.
**Read with:** `PLAYER_IDENTITY_AND_HOME_STORY_BIBLE.md`, `DESIGN.md`, `scripts/estate_system.gd`, `scripts/panel_rows.gd`, `scripts/diary_book.gd`, `FIRST_SEPTEMBER_BRANCHING_DETAIL.md`, `CHOICE_CONSEQUENCE_SYSTEM_DESIGN.md`, `WORKBENCH_ANVIL_WOODWORKING_DESIGN.md`.

## A house with a history is more than a repair bar

The player does not need the building to speak. Their decisions leave observable changes in it. The same place is seen many times under different weather and social circumstances. This is the architectural backbone of the emotional story.

**State must have precedence over prose.** No automatic statement about candle, curtain, stove, plaster, tool, woodpile, painting, lamp, dog, guest, taxes or neighbors unless saved physical or witnessed facts are sufficient. The current EstateSystem already tracks house stage, paint, wallpaper, some furniture and deed; planned forest/workbench/guestroom stages do not exist merely because documented.

## The seven rooms/places of memory (not new rooms required)

### 1. Bedroom / the first roof
**Early physical truth:** the player has a bed and shelter in a damaged farmhouse. The chapter begins with sleeping under their own roof, not a scripted relationship.
**Later physical truth:** house-stage repairs; actual furnishings or added bed when purchased.
**Narrative function:** the bed is where the player returns after exploring. A game that has other people should also make solitude inviting.
**Scene variants:**
- Decrepit: 'Wind moved behind the loose boards. You checked the latch before sleeping.'
- Boarded: 'The boards across the window rattled when it rained. They held.'
- Patched: 'The rain stayed outside tonight.'
- Restored: 'A little of the warmth from the hearth reached the bedroom.'
These are candidate environmental lines; check actual warmth mechanics/room visuals before adding.
**Never say:** 'You finally felt safe'; safety is the player's interpretation.

### 2. Kitchen / the table
**Early:** an old table can hold ordinary food if it visibly exists in current layout.
**Middle:** the player has meals, work orders and letters.
**Later:** a deed or the parish letter can be placed/mentioned only when real state exists.
**Narrative function:** ordinary documents beside ordinary food make a powerful image. 'The letter stood beside last night's dishes' is stronger than a speech announcing social betrayal.
**Three genuinely different interpretations:**
- Trader's diary: 'I counted what the inn paid and bought seed for next week.'
- Homesteader's diary: 'The roof used most of the planks. There were still enough logs for the fire.'
- Explorer's diary: 'I took the clerk's letter out again and compared it with Maren's account.'
All require exact transactions, logs and witnessed sources—not inferred class.

### 3. Hearth / fuel
**Early:** firewood is needed for heat and winter survival under existing Hearth/Comfort mechanics.
**Later:** proper storage, chopping log and a maintained fire are ordinary competence.
**Narrative function:** a shared material—wood—can heat farmer's house or be traded/given to someone else. A fire can be warm without a sacred meaning.
**Candidate micro-memory:** 'The last armful of firewood lasted through the night.' Only if the game really stores burn/usage event, otherwise 'You put another log on' at actual player action.
**Never:** represent keeping warmth for yourself as morally wrong.

### 4. Workshop / workbench
**Present system:** furnace, smokehouse, chopping log in workshop; no fully approved implemented log→plank bench or anvil workflow yet.
**Future target rule approved by owner:** forest logging primary timber source; hew logs into planks physically at workbench; all tools not forged at anvil made at bench; anvil metal forging later.
**Narrative function:** visible raw logs and finished planks are proof of labor. The same player may make a shelf for a neighbor, a farm repair or a fishing tool.
**Candidate action text:** 'You laid the log across the bench. The first cut wandered. The second went straighter.' Only when bench actually performs the action.
**Callback variant:** Maren sees an actual repaired roof and says something specific. She can't know about a private timber collection deep in forest unless told or witnessed.

### 5. Door and mailbox
**Existing:** farm entrance and mailbox at gate are central. First night and special knock; official day240 letter and postman visits.
**Narrative function:** the door means safety and the possibility of another person arriving; the mailbox holds the outside world's claims and requests.
**Never:** make new year-two letters override fixed clerk letter or reveal postman's final handwriting scene early.
**A strong but simple reversal:** first 'someone is at the door' is strange; later an ordinary postman visit becomes familiar; in the main story Elias's copied knock makes the same sound frightening again.

### 6. Farm stand and fields
**Existing:** stand is economic outlet and Maren's farm-visit anchor; first turnip takes days, plots/skill unlocks and crop seasons.
**Narrative function:** work becomes a livelihood; selling and sharing are different choices with different costs, not moral ranks. A worn stand can stay worn if player doesn't repair it.
**Concrete return:** a crate from a real order is returned; a new crop replaces last season's; Maren sits and talks. Never invent a business contract if only generic stall sales were made.

### 7. Fence, road and forest edge
**Existing:** last homestead before wilderness, farm gate, existing treks, NW cave/hillside, wooded perimeter with sparse harvestable trees.
**Future:** accessible nearwood grove, separate from escorted story treks; don't erase the cave and sense of enclosing woods.
**Narrative function:** every trip outward has an opportunity cost, and every homeward trip offers contrast.
**Micro-reversal:** on Day1 the woods might make a new player uneasy. On Day120, the same path may be the place they gather needed logs. On Day370, the great tree has different stakes because of Davy. These are conceptual comparisons, not forced feelings.

## Player diary: two layers, no fabricated identity

### Layer A — Permanent factual event record
A minimal event record stores action, resolved state, day, target, cost, reward and witness/provenance where meaningful. Example:
```text
event_id: inn_upstairs_repair
status: completed
day: 227
materials_spent: planks 8, nails 4 # EXAMPLE ONLY, NOT AN ACTUAL RECIPE
paid_coins: 90                 # EXAMPLE ONLY, NOT CURRENT ECONOMY
witness: edith                # proposed, not implemented
```
**All numbers and save keys above are conceptual and NOT valid production recipes or a tested serializer schema.** They illustrate the difference between accepting a job and finishing it. Prefer reusing common existing choice/quest/save infrastructure rather than duplicating logs.

### Layer B — Authored interpretation selected by player
If player chose 'I don't trust the clerk's account', the diary can say 'I told Maren I didn't trust the letter.' It cannot say 'Pell lied' as objective truth.
If player made no interpretation, factual line: 'The clerk said the old vote stands. Maren remembered the meeting differently.'
No inferred sadness, relief, romance, generosity, selfishness, intelligence, cowardice or resentment.

## Page composition: short, seasonal, true

**Recommended structure (future prototype):**
- **First page:** 1–2 universal true sentences about arriving; use existing guide/chapter facts only if player actually reached that step.
- **Season page:** 2–4 snippets from high-salience confirmed actions, max one per project/relationship category (no repeated crop grinding).
- **Special page:** official story chapter and Agnes original diary page stay in their existing book sections.
- **First-year reflection:** 3–5 authored facts plus optionally one player-chosen interpretation. Keep content based on saved history; no visible 'identity score'.
- **Post-ending page:** refer to actual `bell`/`elias`/`hollow` reached, meeting and Davy state as source; distinguish first ending achieved from any later possible recoverable ending.

**Presentation:** existing DiaryBook already has page-flips and distinct Agnes/player handwriting. Preserve it; do not launch new physical notebook UI. A personal section should not steal the main story page's spotlight or render every day as a flood of writing.

## A 10-entry memory candidate priority list
In order of narrative value, not gameplay score:
1. Day1 actually slept (first chapter).
2. Built first Tin Lantern (chapter2).
3. Walked Maren to edge (chapter3).
4. First own crop harvested (chapter4).
5. First home-stage repair actually completed.
6. First meaningful player-selected Maren response and its later concrete outcome (only after feature exists).
7. Received & showed parish letter (fixed StoryAct flags).
8. Finished one chosen forest→planks repair (after mechanics exist).
9. Repaired a room or fulfilled a Wicker Cove commission (after town features exist).
10. The mill vote and Davy/grove outcomes where actually seen, with original authored diary pages taking precedence.
Only 3–5 of these should occupy one first-year summary, chosen by meaning and chronological coherence; do not imply all happened.

## One shared factual moment, four possible private lives

**Moment:** rain begins while the player is home during first spring.

- **Home repaired, no town:** 'Rain started during supper. The new boards kept the window dry.' Only if a relevant visible house repair truly matches this.
- **Home still damaged, supplies invested in inn:** 'Water came through the kitchen wall again. I'd used the last planks on the inn job.' Requires both facts and a matched specific cost.
- **No repair work recorded:** 'Rain tapped at the window. You shut it and went back to the table.' Does not assert false building state.
- **Player exploring outdoors:** no indoor kitchen scene at all. Weather is experienced outside and journal may mention actual trek if recorded.

**Goal:** adapt to actions and location, not stylistically rewrite the player's entire persona.

## Reward visibility and emotional payoff
A meaningful decision should provide:
- **Immediate recognition:** paid job says what it paid, roof consumes real planks, dialogue acknowledges actual request.
- **Practical outcome:** comfort/shelter/stock, space unlocked, coins, inventory or a usable changed prop.
- **Later recognition:** one line or physical change from someone who plausibly knows.
- **Optional memory:** a few words in personal diary, not compulsive page spam.
At least two of these layers for a meaningful choice, three or four for centerpiece arcs.

**Timing:** prefer a later 7–30 day callback in existing reliable morning/mail/log pathway; don't depend on random visits, nor create a monthly barrage of forced scenes. The diary and room can provide a callback even when character isn't encountered.

## The price of a choice: stories must have material truth
The inn's upstairs leak vs farm roof dilemma only works if:
- Planks have credible cost in forest gathering and workbench processing, with reasonable hauling and no busywork.
- Paying the inn contract truly compensates time and costs.
- Repairing one roof visibly changes its state.
- Deferring is allowed, and innkeeper may independently make a smaller fix later.
- Postponing house repairs can leave a real cost but doesn't make game unsalvageable.
- A completed job is not mislabeled 'a generous gift' if player accepted wages.

A story without a real tradeoff is merely an extra dialogue window.

## Communication provenance: where NPC knowledge comes from
- **Direct witness:** Maren visited the house and saw the repair.
- **Workplace:** Edith received planks/paid invoice and Thomas knows via her order slip.
- **Household:** Ruth can hear Maren's account after she returns home; not automatically all of Wicker Cove.
- **Parcel/mail:** postman can know delivery logistics, not automatically read sealed letter secrets.
- **Public meeting:** those present can discuss public decision, but private reactions require separate encounter.
**Not permitted:** all villagers suddenly know what the player whispered to a single witness or what happened inside the Hollow alone.

## Avoid scope traps
- Don't add a hidden personality radar chart and claim that makes characters literary.
- Don't require five identical delivery contracts to unlock one sentence.
- Don't force the player to decorate the farmhouse to be worthy of an ending.
- Don't turn every owned piece of furniture into a bespoke prose page.
- Don't demand new menu animations; existing diary page flip already supports the style.
- Don't silently change legacy `wood` saves or anvil tool progression.
- Don't treat existing text's **Lowmere** postal geography as resolved; owner decision pending.

## Practical staged proof
1. Audit existing save fields / diary IDs / house stage.
2. Build ONE case: actual completed house repair → one visible/recorded difference → a later Maren line if she visited OR a deterministic truthful diary reflection independent of visit luck.
3. Add ONE option selected in actual dialogue after source-safe Maren scene; save it and produce distinct later callback.
4. Test home-only/inn-only/no-repair saves, old saves, state across year and after one ending.
5. Expand only after player notices and cares about the effect.

## Tasks
- `CCH-HOUSE-MEMORY-001` P1 design: seven repeated places, truthful scene rules (this doc).
- `CCH-HOUSE-MEMORY-002` P1 source audit: what each real house/deed/furniture/material key can prove; current diary format.
- `CCH-DIARY-TRUTH-001` P1 design: event/stance separation and one page per milestone, not a generator.
- `CCH-HOUSE-MEMORY-SLICE-001` P1 gated: one completed home change + later callback + player note.
- `CCH-HOUSE-MEMORY-QA-001` P1 eventual: truthful branches, reloading, alternate home stages, old saves, no-town, Davy/meeting/ending flags and UI readability.

**A house feels like home because players see what they've done there—not because the narrator tells them it's home.**
