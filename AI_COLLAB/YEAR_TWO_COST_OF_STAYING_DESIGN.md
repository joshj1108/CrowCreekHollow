# CCH-YEAR2-NARRATIVE-001 — Year Two: The Cost of Staying

**Date:** 2026-11-14. **Status:** Creative and branching narrative design ONLY; no implementation approval, no changes to existing scenes, ending conditions, quest flags, art or saved outcomes.
**Owner north star:** Literary depth, everyday language, fully consequential choose-your-own-adventure experiences without a moral alignment meter or single correct life. Maintain a viable quiet farmer, merchant, builder, explorer and socially rooted player. Read alongside `NARRATIVE_VOICE_AND_LITERARY_STANDARDS.md`, `FIRST_SEPTEMBER_BRANCHING_DETAIL.md`, `BRANCHING_RESIDENT_ARCS_AND_PLAYER_DIARY.md`, `CHOICE_CONSEQUENCE_SYSTEM_DESIGN.md`, `DESIGN.md`, and **current** `scripts/story_act.gd`.

## Central question
**Year One:** Can I make a life here? **Year Two:** What happens when this place needs something from me?

The player may already have rebuilt a home, kept a pantry, known neighbors, supplied Wicker Cove or remained contentedly independent. The Hollow's older history now has consequences for a life they can identify as their own. Do not tell every player they are 'committed to saving Wicker Cove' or that helping the town earns the true ending. Every personal approach may produce real benefits and costs; the original story has its own evidence and action requirements.

## Crucial distinction: calendar year vs existing 'second-year story'
- In-game starting date: **October 1, day1**. Second calendar autumn begins around day366, **October 1 of year two**.
- The story code calls the mid/late chapter arc `The second year`, but its first beat is **day240, around May28 in the first Oct-to-Sep calendar year**. The existing diary category and chapter naming must be preserved. This new year-two storytelling *deepens the latter portion and post-ending life*, not displaces chapters 11–17 or postpones their triggers.
- Day240/May28 parish letter signed E. Pell; showing it to an existing neighbor is the story beat.
- Orchard rise: next eligible orchard trek from **day265 (~June22)** *after letter shown*. Davy's ongoing storyline depends on it.
- Hollow mimics Elias's knock: earliest **day285 (~July12)** and at least **4 nights after orchard beat**; specific night depends on existing conditions.
- Mill re-vote: available from **day300 (~July27)** on eligible mill trek if **`maren_book` and `vicar_register`** have been seen; alternatively automatic after the **day357 (~Sept22)** threshold (the source does `m.day > maxi(HARVEST_MOON, letter day+10)`). Existing vote resolves via original records, not a charisma/repair/social score.
- Davy: from **day370 (~October5 of second calendar autumn)** if orchard event occurred and narrative remains open; appears at great tree from **20:00 until 01:00** during that one night. If not found, he goes into wood; this is an existing real outcome, not a gratuitous new fail branch. He may eventually come home from the grove in existing outcomes.
- Bell: second **All Hallows October31**, around **day396**, subject to existing requirements. Grove journey/ending only at valid later progression, often day397+.
- All original **17 sequential chapters and three existing endings** remain, including afterword and free play.

## What the three endings ALREADY are — do not invent a morality hierarchy

### `bell` — The Hollow Sleeps
Bell is hung; woman in grey is walked to the grove; the Hollow sleeps. If meeting won, town rings the bell in turns; if lost, player rings it alone. If Davy went into the grove and comes home, original ending says he returns changed. Two lower and late answering notes remain in the forest. This is an authored satisfying ending without requiring every optional social/building arc.

### `elias` — Two Came Home
Requires the **night** grove walk, meeting **won**, existing `davy_turn`, `post_hand`, and all five wood trek pages. Agnes and Elias come out together; Davy and Pip can appear if matching actual state; town rings together. Do not present as the universal moral 'good' ending or let new town reputation substitute for any conditions.

### `hollow` — The Line Under the Rooks
Hollow left at door **three** times after day240 before bell; farm becomes its next keeper. **This is not a game over**: farm play continues, sanity limit/shadow reset in the existing story, and ringing the bell later can bring another ending. A new optional character diary may acknowledge what happened only as the player knows it; it must not overwrite the existing afterword.

## Narrative movements

### Y2-A — Oct1–4: 'Things Not Finished'
The last September diary reflection may exist, but there is no new mandatory 'Year Two' opening screen. Autumn weather, crop rotation and house routines continue. One quiet non-spoilery moment can recall a season-specific object if actually saved: a stacked pile of logs/planks at the bench **only if feature implemented**, an inn room repaired, a posted invoice, or the fact that the farmer has kept to themself.
**Tone sample:** 'The apples were dropping again. You brought in the ones you could reach. There was still work to do before dark.'
**Choice:** How to spend an ordinary afternoon—harvest, visit a resident, take a timber trip or inspect evidence—is gameplay-driven and not a dialogue quiz. No one is graded for declining a social quest.

### Y2-B — Oct5 conditional: 'Davy at the Tree'
Existing source: `StoryAct.DAVY_FOUND`, `DAVY_FOUND_YOURS`, `_davy_waiting()`, `_lose_davy()` and the original recorded diary. Keep exact timing and original five-page scene as authoritative until later line-level editorial audit.
**New possible *separate* texture:** Previous Davy/Tull contact may make a brief pre/post encounter line different; no extra timer, roleplay check, teleport, hidden dice, automatic rescue, or reinterpretation of 'found'. The main scene already has emotional weight; don't dilute with a 'correct words' puzzle.
**If missed:** original loss stands. The postman's route, village work, the farm and later grove remain meaningful. Optional understated memory is allowed, but no systemic scolding or punish loop. Absence can be felt in one unoccupied familiar place, not a wall of text.
**If found:** existing return home scene remains. A later ordinary callback may remember walking together; no 'Davy cured of fear' claim.

### Y2-C — Oct6–30: 'The Work of Keeping'
Farm/forest/cove remain ordinary systems even with the larger mystery looming. A player may:
1. **Prepare the farmhouse and bell physically** (farming, crafting, forest logging, workbench planks, anvil tools, **only if implemented**).
2. **Care for or keep distance from people** (walker friendships, optional contracts/inn room where feature exists).
3. **Seek documents and walk the woods** for existing endings.
4. **Keep living and avoid the dangerous road**, while allowing actual Hollow night consequences under original rules.
These are play styles, not newly hardcoded four choices. Time/material effects are real and carry forward. Existing evidence gates, night threats, and original NightSystem remain fixed.
**Potential optional vignette:** old Maren returns a borrowed tool or asks whether the gate lamp was repaired; only if plausible state/character availability. No new scene may convey `maren_book` or `vicar_register` without the original scene being seen.

### Y2-D — Oct31/after: 'The Bell and the Ring'
**Original crow bell timing and grove event are non-negotiable.** Whether player can hang bell/approach grove follows existing project/story mechanics. The new narrative layer should make the final sequence feel like a consequence of time spent living here: what food was cooked, what structures remain, which people can recognize the player.
**Important:** The bell's ending wording and afterword must remain truthful. Optional visual detail or tiny post-ending NPC line can follow existing ending state; don't inject a pre-rendered story where Edith/Thomas/Martha/Gideon act like canon witnesses unless those candidate NPCs were approved and actually present.
**Do not:** make Wicker Cove fog clear, have a d20 'solve' Elias, tell the player the entire town is rescued by donating vegetables, or rewrite established credits.

### Y2-E — After the ending: 'The Farm Goes On'
The existing screen explicitly says **'Your diary has an Afterword. The farm goes on.'** Take this seriously:
- Crops, seasons, animals, cooking, forest logging and bench/anvil production if built, trade with Wicker Cove if playable, and building/decor projects continue.
- **Different memories of the same farm** based on actual ending(s). The Hollow ending is recoverable; don't describe it as permanent exile/game over. The town may ring in turns or not according to original meeting result. Davy's fate follows original state.
- Optional post-ending resident line or item of mail can reflect a genuine prior exchange, without resetting NPC hearts, reproducing gifts or replacing supernatural lore.
- No postgame moral grading, giant 'save town' bar or endless obligations.
- Respect ambiguous Wicker Cove fog, which persists irrespective of Rook mystery ending.

## One tightly scoped human arc across the ending

**Candidate: 'The Spare Chair' — a recurring object, not a quest chain.**
- **Before Oct5:** if Davy has actually visited the farm/pond, a simple view of an ordinary place he occupied can be remembered.
- **After Oct5 if Davy found:** his later presence and any separate line should be supported by existing return state. No false assertion that all is well.
- **After Oct5 if Davy lost:** an unobtrusive absence or short diary note carries weight. Do not show Davy sitting at a chair he never used, or assume automatic death.
- **After grove:** if original story returns Davy and Pip, one ordinary moment can show that he is home but changed; if not, do not fabricate him. The meaning of the object changes with actual outcome.
- Use existing pond/trek/folk positions and dialogue where possible. Do not require new family NPC sprites to communicate the story.
- **Quality test:** useful quiet scene, no compulsory camera takeover, no emotional lecture, no new 'Davy affection' score, truthful for all cases.

## Cross-system player memories (candidates, not installed)
| History actually saved | Possible later-world echo | Never replace |
| --- | --- | --- |
| Player made farm repairs | house condition materially reflects work | original bell requirements |
| Player made forest logging trips / hewed planks | workshop and material inventory reflect action; maybe an NPC mentions specific repaired item | original story treks, need for actual evidence |
| Helped one Wicker Cove business | owner remembers the paid job or supply contract, room stays repaired | night/bell/meeting flags |
| Kept to the homestead | a full farm, ordinary independent routines | Davy night availability and endings |
| Spoke with Maren / vicar | their *existing* scene state/heart system determines actual events | `maren_book`/`vicar_register` |
| Resolved and/or missed Davy's night | found/lost state produces genuine difference in afterword/future dialogue | original Davy window |
| Triggered Hollow ending | existing farm continues and later bell ending remains reachable | original `hollow` recovery |

Only instantiate callbacks for implemented and recorded actions; don't invent logs, Wicker Cove trades, new people or positive feelings.

## Scene-writing examples (illustrative only)
**At the farm, with quiet work:**
> The apples were falling again.
>
> You brought in a basket before the rain started. The house still needed a few boards.
>
> There was time to work on them tomorrow.

**Davy's emotional register (do NOT overwrite the existing scripted scene):**
> Davy sat between the roots, his lantern unlit.
>
> 'I thought somebody ought to come,' he said.
>
> You waited beside him.

**After a difficult choice:**
> The kettle had gone cold. You took it off the hearth and put more wood on.
>
> Outside, the road was empty.

Avoid attributing regret/comfort/fear to the player. 'Someone had gone' is not a cue for author to narrate the player's grief.

## Technical and creative guardrails
- Core story continues through original `StoryAct` and `FolkSystem`. No second act controller, moral reputation score, hidden charisma roll for end conditions, duplicated quest chain or separate town ending.
- Existing `_ready_for_meeting()`, `_elias_ready()`, `_on_hollow()`, `_davy_waiting()` and save flags are source of truth; never alter them as part of this creative planning.
- New authored player diary in separate 'My Days' section, preserving Agnes and second-year pages; only facts known to player and source-verified, perhaps 6–12 total meaningful pages in initial prototype.
- Distinguish town's **permanent coastal fog** from inland farm weather. No single revealed fog cause; do not tie it automatically to bell/Hollow.
- Coexist with 420-second game days, original character schedules, night Sanity system and the planned woodland/bench manufacturing loops without making the game grindy or inaccessible.
- Existing day240 letter is within first October–September cycle. Do not 'move all year-two chapters' to the day366 cutoff because this design is titled Year Two.
- Honor owner-approved static main menu; unrelated visual/menu work is out of scope.

## Small playable story proof (candidate after approval)
1. Reuse already-tested autumn choice+later callback state system.
2. Choose ONE existing late beat to add **a separate conditional diary or resident line** based on verified earlier choices, with no branch inside mandatory beat.
3. Show one persistent world state (existing repair or actually implemented inn room/bench) alongside it.
4. Test two different player histories, plus one no-town/old-save history; every original chapter and all three ending routes remain viable.
5. Keep optional story additions tiny enough to avoid turning the second autumn into mandatory text-heavy gameplay.

## P1/P2 task breakdown (not implementation permission)
- **CCH-YEAR2-NARRATIVE-001 — P1 design:** this document, source-verified second-autumn/ending mapping and lasting player histories.
- **CCH-YEAR2-NARRATIVE-002 — P1 audit:** inspect actual event-state, dialogue collisions, first-year flags, save migration and postending scenes; propose *one* human callback with no core edits.
- **CCH-YEAR2-DAVY-001 — P2 candidate:** one subtle conditional pre/post-Davy callback built *around* existing one-night scene, not replacing it.
- **CCH-YEAR2-CHOICE-001 — P2 candidate:** one remembered farm/town practical choice acknowledged during second autumn.
- **CCH-YEAR2-AFTER-001 — P2 candidate:** one post-ending daily-life recognition supported by existing ending and world state.
- **CCH-YEAR2-QA-001 — P1 eventual QA:** late letter/orchard/knock, meeting records and fallback, Davy found/lost 20:00–01:00, crow bell and grove, three endings + possible later recovery, old save and no-town runs, diary truth, controller timing, forestry/crafting not blocking ending.

**Nothing here is a new canon scene or authorization to implement.**
