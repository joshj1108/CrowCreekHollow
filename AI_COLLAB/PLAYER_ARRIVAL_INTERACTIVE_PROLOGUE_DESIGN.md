# CCH-PROLOGUE-001 — The Road to Crow Creek Hollow
## Interactive Player Backstory and Arrival — Literary/Narrative Design

**Date:** 2026-11-14. **Status:** Story design only. User asked for a Firewatch-like reason the player moves to the farm. The following **is not approved final canon dialogue, gameplay implementation, cutscene content or character-creator spec**. Preserve original day-1 guided onboarding, first night, 17 story chapters, three endings, farm/town legal history, and all existing sources.

## 1. Why the prologue matters
An empty vessel produces generic diary entries. An overdetermined hero destroys agency. We need a middle ground: **a person with a past that the player helps author through 4–6 high-signal choices**, with enough common grounding for the world to respond credibly.

**Firewatch technique, not copied events:** short second-person textual life vignettes; small choices become more personal; interleave travel/walk segments; finish with physical arrival so player knows *why this person came*. Campo Santo's official audio tour discusses Sean Vanaman drafting the original Twine prologue to prevent a blank-slate protagonist; analyses of Firewatch distinguish choice-shaped past from an exhaustive biography. Reference for inspiration only:
- https://projectfirewatch.com/cdn/FirewatchAudioTour.pdf
- https://magazines-static.raspberrypi.org/issues/full_pdfs/000/000/365/original/Wireframe38.pdf
No copying of Firewatch's Henry, Julia, dementia, dog, precise text, dialogue or exact timeline; our protagonist's circumstances and narrative are original.

## 2. Source-grounded canon conflict and clean resolution
**Important correction to generalized pitch language such as 'inherited farmhouse':** Current `scripts/estate_system.gd` explicitly says the farm is held from the **town** on quarter tax. The clerk offers outright purchase **only after house is Patched**, at **12,000 coins** in 500-coin increments, and deed letter later names the bell as having been sold for iron. The original `scripts/story_act.gd` parish letter later addresses 'To the tenant at Rook's farm.' The original game does **not** yet specify a detailed personal legal inheritance, relationship to Agnes or a family benefactor. Some earlier creative pitch calls it 'inherited'; that should not override source legal mechanics. **Do not silently canonize that the player inherited free title.**

**Proposed common fact:** The farmer responds to an old town listing for the right to occupy and work the neglected Rook homestead, on the town's existing terms, with ownership potentially available later under the existing deed purchase. The listing source could be a printed notice/catalogue or a letter sent through ordinary post; **who offered the farm is not a secret conspiracy hook by default**. Owner must specifically approve exact legal terminology and route, so the prologue uses only 'the place is available', 'the town handles the terms', and 'you can live and work there' until the town/deed audit confirms formal wording.

The player starts October 1, before guided day1. No inherited personal kinship to Agnes/Elias, no fixed surname, gender, spouse, child, illness, death, criminal past or military career. Only the agreed starting situation is shared: **they choose to go to Crow Creek Hollow and are allowed to begin at the old Rook property**.

## 3. The emotional question
**'What made leaving possible—and what made staying where you were harder?'**

A player can move for a positive reason. We must not assume every life needs grief to deserve a new beginning. Several options may carry loss or regret, but all are dignified and replayable. We should aim for genuine dramatic specificity, not a generic dropdown personality survey.

### Four backstory strands (starting *reasons*, never classes)
1. **A Life Interrupted** — The player left a relationship, shared household, ordinary plan or place that could no longer continue as before. Causes can include a separation, a family move, or an ending the player does **not** have to explain. Never assign death/dementia/abuse as generic fate. Distinct callback: a sealed letter, postcard or unresolved contact that can be left unanswered without punishment.
2. **Nothing Left to Prove** — After years doing work for other people, the player wanted less noise, a different pace or more control. Could be a failed job, successful but exhausting career, or life spent being relied upon. Distinct callback: old work card, tool, former coworker's innocuous note, practical competence without free skill-level bonuses.
3. **A Place to Call Your Own** — Expensive or unstable housing and a limited budget made a remote farm a practical chance. A player does not need a tragic identity to want independence. Distinct callback: ledger of savings, old rental key, moving bill, newspaper clipping. Does not contradict actual starting resources or create fake debt mechanic.
4. **Something About the Place** — A photo, a story of the mountains, a desire to farm or an old pamphlet drew them to the property. May carry a forgotten childhood visit **only if the player explicitly selects it**, and must never imply secret blood relationship to Rooks, predestination or knowledge of fog cause. Distinct callback: photo/pamphlet, memory of trees or rural summers. The farm is no occult summons.

**Player may decline personal disclosure, but NOT the interlude:** all new playthroughs must complete the opening interlude and commit to a reason for coming. They can choose a private or understated answer about particular relationships or keepsakes; this does not skip the origin story.

## 4. Design format: playable literary travel, 5–8 minutes target (subject to playtest)
- Opening scene: near-empty rented room, workroom or household; a few packed belongings. Text on dark parchment or existing diary-inspired interface, not a complex new character creator.
- Four to six *short* vignettes, each 2–5 sentences, interleaved with simple travel movement—loading a vehicle, passing the last town, entering the forest road, reaching the gate. **Do not build a full 3D drive / train system.** In a top-down 3/4 Godot game, 2–3 static location cards or a short existing map transition can suffice.
- Begin with an easy choice about why a listing caught their attention. Then select one ordinary personal relationship or item. Then a choice about whether to keep in contact or leave the past quiet. Then a practical decision about starting.
- The *last beat* shifts from narration to player agency: **gate, mailbox, path and farmhouse; fade to ordinary Day 1 guided diary**. No added prologue hour that loses planting daylight. At launch, all players start in same opening place with same tutorial, inventory, starting coins, basic tool access and story flags.
- **Presentation:** existing Rustic Gothic Balanced UI; understated ambient sounds and nature. The existing static moonlit main menu remains unchanged. Prologue itself doesn't require GIF/video or cinematic.
- **Mandatory interlude, accessible presentation:** no Skip or bypass for a new game. Allow players to advance text at their reading pace, use gamepad/keyboard/mouse, change text speed, revisit the previous vignette before confirming their origin, access readable contrast and pause/resume. A Resume action restores progress; it does **not** bypass any narrative beat. Keep prose concise and humane rather than padding mandatory scenes. No forced survey about personal trauma. The player can make strong decisions about what to say without narrating feelings the user didn't select.

## 5. Six-beat screenplay — original draft, **all tentative**

### BEAT P0 — The listing
*Setting: a quiet room, daylight, partially packed shelf. The game's season is approaching October; no arbitrary fixed year required.*

> The notice was folded beneath three others.
>
> **Old farmhouse available. Land to work. Terms through the parish office.**
>
> It was farther away than anywhere you'd lived before.
>
> You read it again.

**Choice 1: Why do you keep the notice?**
- 'I need somewhere I can afford to begin again.' → `arrival_reason=security`
- 'I want work that belongs to me.' → `arrival_reason=work`
- 'There isn't much here I still want to stay for.' → `arrival_reason=change`
- 'I want to know what it's like up there.' → `arrival_reason=curiosity`
- 'It's just a chance. That's enough.' → `arrival_reason=pragmatic`

**Design rule:** These are **spoken/interpreted intentions selected by player**, so future diary may quote them. None grants a +5 alignment/starting skill or changes canonical eligibility.

### BEAT P1 — The life you have been living
The next scene branches into **one compact real-world anchor**, not a sprawling biography.

**Security:**
> The rent notice sat on the table beside your pay.
>
> By the end of the month, the numbers would no longer work.
>
> You could stay and look for another room. You could try the farm.

**Work:**
> You finished the last shift after everyone else had gone.
>
> They left a list of things for tomorrow.
>
> You had your own list, and it hadn't grown shorter in years.

**Change:**
> You kept finding things that belonged to someone who no longer lived there.
>
> Some went into a box. Others stayed where they were.
>
> The house felt different with half the shelves empty.

**Curiosity:**
> The picture in the notice was little more than a roof between dark trees.
>
> You found yourself looking at it during lunch.
>
> There was no reason to think you knew that place.
>
> Still, you wanted to see it.

**Pragmatic:**
> The job where you lived would last another season, maybe two.
>
> The farm was available now.
>
> You made a list of what it would cost to move.

**Editorial:** Branches are text examples, not confirmation that the protagonist was employed, rented, or married in all saves. Avoid 'the player knew X' unless the selected setup actually supports it.

### BEAT P2 — A person from before
The player should have **one human connection** to the former place, without an obligatory spouse/parent/child plot. Present a source-safe generic outgoing scene with variable relationship selected first:
- A friend
- A family member
- A former coworker/neighbor
- Someone from a relationship that ended
- No one they want to discuss

*Example of choosing a friend:*
> Someone knocked on the half-open door.
>
> 'So you're really going?'
>
> You folded the last shirt into the case.
>
> 'I think so.'
>
> 'It's a long way.'

**Choice 2 — How do you part?**
- 'You'll hear from me.' → commitment to contact; future outgoing option, **no forced letter sent**.
- 'Come visit if you ever want.' → invitation; **do not promise an unimplemented physical NPC visitor**.
- 'I don't know when I'll be back.' → candid uncertainty.
- 'I'd rather not make plans.' → boundaries, accepted.
- 'There's nobody here to say goodbye to.' → no-person branch with suitable alternate scene, no implied tragedy.

**No relationship punishment:** The past connection can have its own life, but the farmer is not graded for how often they write. No homecoming guilt narrative.

### BEAT P3 — What fits in a box
**One selected keepsake** that can later be inspected in the farmhouse, perhaps a UI book memory without an inventory slot, so it doesn't become an unfair starting item:
- A faded photograph — tied to person, place or shared ordinary day the player chose.
- A small tool with worn handle — work and competence, *not* a free forged tool.
- A postcard with an unfinished message — a choice about communication, not magic letters.
- A notebook/recipe card — practical memory, *not* Agnes's diary or a secret extra Rook clue.
- Nothing — a deliberate lean start, **not punished or defined as emotionally empty**.

**Choice 3 — Leave it out or pack it?** Either one chosen keepsake with one minor later callback, or none.
**Physical rule:** no new permanent inventory slots, storage boost or secret attribute. Future visual could be a small object placed on an existing table if sprite/placement system supports it; otherwise a personal diary keepsake tab.

### BEAT P4 — The road
Use the same brief journey for everyone but one line conditioned on the selected origin. No author-imposed emotions, no magical compulsion.

> The last filling station was miles behind you.
>
> The road narrowed, then turned through the trees.
>
> There was a painted sign near the bend, half hidden by wet leaves.
>
> **Crow Creek Hollow.**
>
> Beyond it, the mountains climbed into cloud.

**One choice, no personality verdict:** 'Stop and look at the sign' / 'Keep going'. A tiny cinematic pause or image, not a story gate.

**Optional Wicker Cove glimpse:** The farm sits uphill of a fogbound coastal village. Player might glimpse a bend descending toward harbor, but no fabricated sight of the sea from an impossible altitude or premature village exposition. The town's fog must remain permanently unexplained.

### BEAT P5 — The threshold
> The gate was open.
>
> Grass grew along the hinges. The path to the farmhouse was marked by two wagon ruts.
>
> The roof had lost shingles. One window was boarded, and another stood open to the weather.
>
> Someone had left a bucket inside the gate, turned upside down.
>
> There was no one waiting.

*Last action:* player moves the character toward the house, collects existing first-day diary at desk and begins Day1. **Do not** add a novel prologue-only item to the inventory or alter the existing first chapter Sleep Under Your Own Roof.
If the current map doesn't have these precise props (gate ruts, bucket), revise the prose to match the actual assets; samples not final canon.

**Final optional line in personal diary, one phrase only:**
> The farm is in worse shape than the notice said. I can work with that.
The second sentence should only be used if player chose an optimistic/working response; default simply records condition.

## 6. Four long-range callback threads — subtle, never punitive

### Contact thread
A player who selected a prior connection may find **one ordinary letter** available from old acquaintance after a season, or be able to write one using the mailbox if the system exists. This should be optional, infrequent, grounded and non-supernatural. No one should blackmail farmer into returning or force trauma dialogue. If no contact was selected, no letter appears.

**Example callback:** 'Heard you found somewhere with trees. I hope the roof holds.' It may be warm, awkward or brief according to player choice, never manufactured melodrama.

### Work thread
A player who came from a job or craft may use that history in a **single mild line** when working at the bench or talking shop to a resident. The game still teaches tool progression normally; do not grant a skilled player an unearned Smithing boost or imply all occupations were woodwork.

**Example:** 'I used to spend my days fixing things that weren't mine,' if player explicitly selected that past, not universal narration.

### Home thread
A player who arrived for financial independence may keep a note of the first seed sale or deed installment. When the town deed is finally purchased (if purchased), it can connect to the opening notice without making the town's original bell authority vanish.

**Example after paid deed:** 'This time the paper has my name on it.' Only if protagonist name and deed state genuinely exist; otherwise avoid unverified name.

### Memory thread
A player who brought a photo/tool/card can optionally inspect it in winter or after an ending, and the text shifts only with **actual chosen item and current context**. No item reveals Agnes's identity, the fog origin, postman's handwriting clue, or prior supernatural connection.

**Key rule:** callbacks are **1–3 precise reappearances across a full playthrough**, not one reminder every week. The past remains part of a life without becoming a second required campaign.

## 7. How the opening creates new literary reversals

**Opening:** farmer sees a listing describing a usable place with land to work. **Later:** the town clerk's day240 letter addresses them as a tenant and forbids hanging bell. **Still later:** the vicar's fixed register can reveal repeated town transfers. The earlier listing was ordinary and lawful-looking; the player now understands the history behind how that place became available. This thematic reversal works for every chosen origin without inventing a supernatural recruiter or invalidating the deed.

**Opening:** one keepsake chosen from prior life. **September:** same object is now sitting in a room the player may have repaired; if no kept object, another actual farmhouse milestone stands instead. **After ending:** player can inspect it again, but its significance is theirs to decide. Don't auto-describe it as healing grief.

**Opening:** the player may want solitude. **Later:** neighbors recognize them and some depend on their work, but **solitude can still be a valid choice**. One old friend can be important without forcing all town relationships.

## 8. Three fully alternate mini-journeys for literary testing

### A — The practical newcomer
Reason: affordable independence. Connection: a sibling. Keepsake: notebook or no item. Depart: 'I don't know when I'll be back.'
**Arrival diary:** 'The town let me take up the old farm. The roof needs work. I have enough to start.'
**Midyear response:** letter about bell feels like an unexpected term in an already complicated local arrangement. Deed payment, if chosen, becomes a thematic continuation.
**Potential final question:** 'What is mine, and what does the town expect me to carry?' Not an objective personality tag.

### B — The exhausted worker
Reason: work that belongs to them. Connection: coworker. Keepsake: old hand tool (nonfunctional). Parting: 'You'll hear from me.'
**Arrival diary:** 'I left the last job behind. There will be plenty to do here.'
**Midyear response:** turning forest logs to planks is tangible labor, not an escape from work; the same labor may help others via voluntary contracts.
**Potential final question:** 'When does meaningful work become a duty other people pass to you?' No forced bitter ending.

### C — The person making space
Reason: life interrupted. Connection: someone from former household. Keepsake: faded photograph. Parting: 'I'd rather not make plans.'
**Arrival diary:** 'I packed what I could carry and came to the farm.'
**Midyear response:** one personal relationship letter may come if specifically selected, but silence can be right for this player.
**Potential final question:** 'Is starting again the same as leaving something behind?' Do not write 'I finally healed' without player expression.

### D — The curious newcomer
Reason: drawn to quiet mountains and farm. Connection: close friend or none. Keepsake: picture of place. Parting: 'Come visit if you want.'
**Arrival diary:** 'The notice made the farm sound smaller. It's a long road into the woods.'
**Midyear response:** original Agnes pages/Rook history provide mystery but player was not secretly related or called by the Hollow.
**Potential final question:** 'Why did I come here, and why did I choose to stay?' The answer belongs to player, not narrator.

## 9. Art, pacing and UI integration
- **Opening medium:** short text/prose with pixel-art travel cards as optional art, using existing fonts, page turns and rustic graphic style. No separate giant player creator. Could be one 2D Godot `ProloguePanel` using data-driven branching paragraphs after approval.
- **Duration:** initial pacing target roughly 5–8 minutes for a first reading, to refine through actual testing; **mandatory on every new game**, no Skip option. Branch depth 1–2 per selected memory, with meaningful information rather than many questionnaire screens. Never speed-run a person's past to get to the 'real game'.
- **World transitions:** 2–3 reusable views (packed room, road in woods, farmhouse gate) can be static tile/scene art matching current pixel camera. Main menu remains static.
- **Choice UX:** one question at a time, Save/Continue/pause with controller focus and no time pressure; previous button before final confirmation. **New-game completion requires confirmed arrival_reason and progression through all authored interlude beats.** A player can choose 'private' on particular disclosures, but cannot bypass the interlude or default to an unchosen origin. Never assign trauma, money or a hidden moral trait.
- **Gameplay starts intact:** day1 06:00/normal source clock as applicable, original inventory, original guided diary at desk, first sleep/scare and day4 Maren trek. No prologue travel clock consumption.
- **Replaying:** a start-menu backstory history option can replay without overriding save; don't expose final Rook mystery spoilers when rewatching.
- **Localization:** concise prose, grammatical option texts, avoid embedding player name/pronouns in passages when not yet supported; no assumptions of player gender/sexuality/family situation.

## 10. Scope and anti-railroading safeguards
- Backstory choices do **not** determine moral alignment, strength, appearance, starter money, gear, initial house stage, village reputation, hidden supernatural affinity or which of 3 original endings are available.
- Do **not** combine them into a fixed 'tragic past' and then tell player they feel guilty all game.
- Do not say player **inherited** the deed unless owner deliberately changes existing legal story; 'old farm available on town terms' is safer.
- No forced romantic plot with a former partner, no illness/death, mandatory family bonds or violence. Let people choose change because of curiosity, opportunity and work too.
- No dramatic narrator statement that the Hollow or Agnes summoned the protagonist. Existing postman's handwriting twist remains as original mystery and must not be 'explained' by the prologue.
- No early 'foreknowledge' of 31-to-4 vote, Elias, minute book, register or missing Davy: player learns through original beats.
- The parent project may use 'inherited farmhouse' in promotional shorthand. Reconcile prose with game deed mechanics in an owner review, not by silently changing code.

## 11. Narrative QA and tests
**A. Five new starts:** change, work, security, curiosity, pragmatic; each produces distinct authentic prologue without changing core game state.
**B. With and without past contact:** future letter only if justified, no mandatory response; save/load and no ghost NPC.
**C. Keepsake and no keepsake:** inventory and visual state correctly grounded; no opening item exploit or diary falsehood.
**D. Interrupted:** resume at the saved beat with chosen selections preserved; no 'Skip' and no loss of first-day time or starting resources. If the user chooses private responses, preserve privacy without bypassing the interlude. Player cannot retroactively reshape finished selections unless using an explicit New Game.d facts.
**E. First 30 days:** first-night, Tin Lantern, Maren day4, crop/stand and bench/forest gates unchanged.
**F. Year one later:** May day240 clerk letter arrives; vicar records and meeting still independent of background.
**G. Three endings:** `bell`, `elias`, `hollow` still reachable, Wicker Cove fog origin remains unanswered, post-ending personal item may be seen.
**H. Old saves:** default `arrival_reason=unspecified`, no retrospective backstory and no missing key crash.
**I. Literary:** each passage fits natural voice and visible environment; 2–5 sentence rhythm, zero unchosen sadness/motive.

## 12. Priorities and integration decisions
- `CCH-PROLOGUE-001` **P1 Design** — this document, Firewatch-inspired noncopied interactive backstory, multiple origins and callback arcs.
- `CCH-PROLOGUE-002` **P1 editorial/canon decision** — approve one common lease/occupancy explanation, exact number of origins, player history intensity, and whether keepsake is only diary entry or existing house prop.
- `CCH-PROLOGUE-003` **P1 technical audit** — current New Game transition, first-day tutorial and Save/Load structure, existing intro art/UI, controller focus.
- `CCH-PROLOGUE-PROTOTYPE-001` **P1 gated** — mandatory branching narrative interlude with substantive origin choice, no Skip/bypass, saved resume state, natural pace and transition to unchanged October 1. **No oversized biography engine.**
- `CCH-PROLOGUE-REMEMBER-001` **P1/P2 gated** — an origin thread of comparable dramatic weight to new-home story, including spring/winter developments, one consequential later decision and afterword, using Mail/Diary when possible, not just a token keepsake.ne.
- `CCH-PROLOGUE-QUALITY-001` **P1 QA** — five origin paths, mandatory complete interlude and interruption/resume, no skip, no compulsory personal trauma, repeated callbacks with a meaningful later choice, original day1, vicar/deed/letter/ending compatibility and replay truth.

**Creative goal:** The player reaches the gate with a meaningful personal reason to be there. That reason is **as narratively important** as the later reasons for staying. Neither cancels the other; both reach meaningful development through the full story.

## Owner correction — Mandatory, equal-weight origin interlude (2026-11-14)

**This section supersedes every earlier optional/skip/minimal-callback suggestion in this file.**

### Non-negotiable
1. **Every new player plays the interlude in full; no Skip, fast-bypass or substitute neutral origin.** All authored narrative beats must be experienced, with free reading pace, pause, resume, accessible input and a Previous option during selection. A user can decline to explain one relationship or choose not to carry a keepsake, but **cannot opt out of having a reason to come**.
2. The starting reason is **not a disposable tutorial hook**. **Why they came and why they stay are equally important, neither subordinated**. The origin story must have its own developing causes and consequences, not merely 1–3 flavor callbacks.
3. Origin choices must create distinct **recurrent narrative threads** with meaningful decisions and responses, yet not change starting money, equipment, original Rook beats, endings, or force love/grief/trauma on every person.
4. The interlude is still **narratively economical**: deep does not mean needlessly long or uninterruptible. No cutscene skip or prose bypass, but full Pause, Save/Resume where technically possible, readable text and flexible speed. **No prologue time deducted from October 1 day one.**
5. Existing saves are a separate compatibility problem: an old playthrough **must not be broken or forced into a contradictory retrospective prologue**. Opening is mandatory for new games; old saves can retain unknown origin or receive a non-retroactive optional continuity policy after audit.

### Origin arc structure: a parallel 'life before' narrative, equal to 'life here'
- **At arrival:** establish exactly what changed, who or what matters, and one unresolved human question of the player's choice.
- **Early winter:** a concrete consequence of departure arrives through ordinary means (letter, payment record, unfinished work, absence of expected contact, or a physical keepsake), with at least one small player response or real decision.
- **Spring/summer:** the past makes a *meaningful* demand or offers an opportunity: answer/decline a letter, renegotiate an old commitment, give someone truthful news, settle a practical matter, share or retain a keepsake. At least one specific outcome must persist.
- **First September:** diary includes a factual reflection on **both** where the player came from and what they did here. The original motive can evolve, be reaffirmed, questioned or left unresolved according to actual chosen responses.
- **Second autumn and after ending:** one final authored echo changes according to origin decisions, the farmhouse life and any actual main-story ending. This is **not** a stock 'you learned to love this place' resolution.

### Strong candidate origin payoffs, without one universal tragedy
| Origin | Unfinished question | Midyear interaction | Late development |
| --- | --- | --- | --- |
| Security / affordability | Is stability the same as owning a place? | An old housing/billing issue is resolved or deferred, separate from the existing farm deed | A chosen response to new security, not compulsory self-sufficiency |
| Work autonomy | Can work belong to you if other people still need you? | Former coworker asks for one specific piece of advice or help, with genuine room to decline | Player decides what responsibilities to retain; parallels current farm/inn work |
| Life interrupted | What remains of a relationship or shared household after leaving? | A grounded contact or object resurfaces with a concrete request; separation need not mean abuse/death | Reconnect, set boundaries, or leave some things without resolution; no guilt scoring |
| Curiosity | Is seeking somewhere new enough reason to change a life? | An old friend asks what was worth the journey; player selects one truthful experience to share or keeps private | A response to arrival's original question, not an occult destiny |
| Pragmatic chance | What did you give up or risk by taking an uncertain offer? | Something from prior circumstances remains unsettled—a work contract, storage box or small practical claim | Player accepts, resolves, or relinquishes an ordinary claim based on actual circumstances |

**All rows are writing proposals, not new canon or guaranteed mandatory mail quests.** Exact events require design and implementation review. Equal narrative weight means each strand has a beginning, a complicating moment, at least one consequential later choice, and an echo; not necessarily equal word counts per chapter.

### New acceptance criteria
- Player can tell another person **why they arrived** without relying on an achievement description.
- Player can point to at least **two story moments beyond opening** where their chosen reason affects dialogue, a decision or tangible personal history.
- Player makes at least **one later meaningful choice involving their earlier life**, not just reads a message.
- A quiet/pragmatic origin feels as serious as a dramatic one.
- End of first year can acknowledge a persistent past and newly built life **without narrating player feelings**.
- No character can magically know the protagonist's private past if it has not been disclosed or delivered through a plausible channel.
- First day tutorial, Day4 Maren, canonical letter/meeting/Davy/grove and the three original endings still function.
