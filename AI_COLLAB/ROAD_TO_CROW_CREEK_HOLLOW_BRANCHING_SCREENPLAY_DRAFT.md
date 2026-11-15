# CCH-ROAD-SCREENPLAY-001 — The Road to Crow Creek Hollow
## Mandatory Interactive Interlude — First Full Screenplay Draft

**Drafted 2026-11-14. EDITORIAL DRAFT / NOT FINAL CANON OR IMPLEMENTED GAMEPLAY.** The user's binding direction is that **every new player experiences the interlude with no Skip**, and the reason for coming carries **equal narrative importance** to the life the player later builds. This is an **original** screenplay using a text/travel interplay in the general tradition of narrative adventures, not copied from Firewatch.

**Companions:** `TWO_LIVES_INTERWOVEN_ORIGIN_ARCS.md`, `PLAYER_ARRIVAL_INTERACTIVE_PROLOGUE_DESIGN.md`, `NARRATIVE_VOICE_AND_LITERARY_STANDARDS.md`, `PLAYER_IDENTITY_AND_HOME_STORY_BIBLE.md`, `LIVING_WORLD_DESIGN_HANDOFF_INDEX.md`.
**Canon constraints:** Oct 1 starting gameplay and guided first day untouched. Farm currently held from town on tax terms and outright deed purchased later after Patched; player has no verified inherited title or Rook kinship. Actual legal notice wording is provisional pending owner approval. No pre-discovery knowledge of the old bell vote, Agnes/Elias lore, postman handwriting, Davy's fate, or Wicker Cove's fog cause. No new fixed tragedy, job occupation, gender or romance. Every narrative choice has privacy-friendly paths without bypassing the required scenes.

## Production script grammar
- **[SCENE]** visual/world state, **NARRATION** ordinary second-person descriptions of visible facts and actions, **[CHOICE]** mutually exclusive first-person voiced intentions, **[STATE]** proposed *editorial IDs*, not implemented save keys.
- **[BRANCH]** one of five full origin-specific sequences; other players do not see those paragraphs in their new game.
- **[COMMON]** required for all new games, then small variants keyed to actual earlier choices.
- **[DIEGETIC TRANSITION]** short noninteractive visual move / moving illustration; not a separate 3D driving system.
- **NOT A QUESTIONNAIRE:** Every question follows physical action and concrete context. The interlude has no timed responses and no skip. Back/Previous and Pause/Resume preserve entered choices. An undisclosed detail is allowed *within* a path; a player must still choose a true starting reason.
- **Length target:** 7–10 minutes at ordinary reader pace as **editorial goal subject to actual playtesting**, not a hard unskippable ten-minute cinematic. Written prose must be ruthlessly trimmed if tested duration/engagement indicates strain.
- **Source truth:** props (ruts, photograph, envelope, telephone, packing cases, travel views) are **concept art goals** and must be matched to the eventual illustrated scenes before import. The default date is late September preceding Oct 1; avoid claiming year.

---

# ACT 0 — A Place on Paper

### SCENE 00 — INT. FORMER HOME / DAY [COMMON]

[SCENE] A simple view of a table, a chair, a folded notice. Other belongings are visible without specifying profession, relationship or wealth.

**NARRATION**
> The notice had arrived with the usual post.
>
> It was folded between an advertisement and a bill that had nothing to do with you.
>
> **Old farmhouse. Fields and outbuildings. Available for occupation and work. Terms through the town office.**
>
> The picture showed a roof above a fence and a stand of dark trees.
>
> You left it on the table.
>
> Three days later, it was still there.

[CHOICE C00 — WHY HAVE YOU KEPT IT?]
- **A.** "I need a place I can afford to live." → `origin=security` → **ACT 1A**.
- **B.** "I want my work to belong to me." → `origin=work` → **ACT 1B**.
- **C.** "The life I had has changed." → `origin=household` → **ACT 1C**.
- **D.** "I want to see that place for myself." → `origin=curiosity` → **ACT 1D**.
- **E.** "The chance is here, and it may not be again." → `origin=chance` → **ACT 1E**.

**NARRATIVE CONTRACT:** These five statements are equivalent in seriousness. The first is not a "poor" class, the second not an automatic expert crafter, the third not universal bereavement, the fourth not occult predestination, and the fifth not an origin with no story.

---

# ACT 1 — The Reason for Leaving

### SCENE 1A — THE NEW RENT [BRANCH: SECURITY]

[SCENE] Same table later, two paper notices. The numbers are a legible visual symbol but do not show a specific currency or an impossible contractual claim.

**NARRATION**
> The new terms were printed on one sheet.
>
> You laid it beside the old one. Most of the words were the same.
>
> The amount at the bottom had changed.
>
> You counted what you had saved. Then you counted it again.
>
> There were other rooms to look at. The farm was the first place you had seen with land you might work.

[CHOICE C1A — WHAT DO YOU DO BEFORE LEAVING?]
- **"Ask for more time to arrange the move."** → `security_exit=extension`. You draft a short note. The answer arrives days later: "Until the end of the month. No longer." No eviction or villain speech; just terms.
- **"Arrange a forwarding address and go."** → `security_exit=forward`. You write the farm's address on a card and place it with the bills.
- **"Ask someone to keep two boxes until you're settled."** → `security_exit=stored`. One ordinary person agrees, no romantic assumptions; their specific relationship chosen at next shared beat.

**END BEAT**
> You put the two notices into the same envelope.
>
> One was no longer useful. You kept it anyway.

### SCENE 1B — THE LAST SHIFT [BRANCH: WORK]

[SCENE] A small workroom/counter after everyone has gone. No recognizable uniform or specialized professional equipment.

**NARRATION**
> There was a list of things to do tomorrow.
>
> There had been one yesterday, too.
>
> You finished the last task on today's page and put the pencil down.
>
> Someone had written a note asking if you could come in early.
>
> In your coat pocket was a folded copy of the farm notice.

[CHOICE C1B — HOW DO YOU LEAVE THE WORK?]
- **"Finish the job I promised to finish."** → `work_exit=finish`. You finish a specific ordinary inventory/order handoff over several days. The last page is signed.
- **"Give notice and leave clear instructions."** → `work_exit=instructions`. You write the next steps on a clean sheet and leave it by the work list.
- **"Tell them I can't keep doing this."** → `work_exit=boundary`. A supervisor accepts the notice but asks who will take over. "I don't know yet," you say. They must choose someone themselves.

**END BEAT**
> You turned the light off when you left.
>
> Someone else would turn it on in the morning.

### SCENE 1C — THE CHANGED HOUSE [BRANCH: HOUSEHOLD]

[SCENE] A lived-in room with one emptied shelf and a second cup or hook. The player's relationship to the person who used it is not assumed.

**NARRATION**
> The shelf was still marked where the other things had been.
>
> You tried the empty space with your hand, as if something might fit there.
>
> It didn't need filling.
>
> On the table lay a photograph of a farmhouse in the hills.
>
> You had already begun packing when you found the notice.

[CHOICE C1C-1 — WHO HAD SHARED THIS PLACE?]
- **"Someone I loved."** → `household_relation=partner`; no gender, marriage, breakup cause or death.
- **"A friend."** → `household_relation=friend`.
- **"Someone in my family."** → `household_relation=family`.
- **"I'd rather keep that private."** → `household_relation=private`, but changed household is still the chosen origin.

[CHOICE C1C-2 — WHAT CHANGED?]
- **"We agreed it was time to live separately."** → `household_change=separate`.
- **"They had somewhere else they needed to be."** → `household_change=moved`.
- **"The arrangement couldn't continue."** → `household_change=ended`.
- **"I don't want to explain it."** → `household_change=private`.

**SHORT SCENE VARIANT:** If an identified person and continued contact were selected, there may be a knock at the door:
> "You don't have to get rid of everything," they said.
>
> "I know."
>
> They stood beside the empty shelf for a moment.
If private, instead:
> You closed the box, wrote the address on it, and put it beside the door.

**END BEAT**
> You made a list of what needed moving.
>
> There was less on it than there had been in the spring.

### SCENE 1D — THE PHOTOGRAPH [BRANCH: CURIOSITY]

[SCENE] The listing photograph, shown beside another ordinary view of road/fields. No uncanny distortion.

**NARRATION**
> The photograph wasn't a good one.
>
> Half the farmhouse was hidden by the trees. The fence looked as though it hadn't been fixed in years.
>
> There was a patch of open ground beside the house.
>
> You kept returning to that part of the picture.
>
> The listing told you almost nothing about the place.

[CHOICE C1D — WHAT DID YOU HOPE TO FIND THERE?]
- **"Land where I could grow something."** → `curiosity_interest=growing`.
- **"Time away from noise and traffic."** → `curiosity_interest=quiet`.
- **"A place where I could learn to work with my hands."** → `curiosity_interest=making`.
- **"A road I hadn't taken before."** → `curiosity_interest=exploring`.

**END BEAT**
> You wrote to ask whether the place was still available.
>
> The answer was short.
>
> It was.

### SCENE 1E — THE CLOSING DATE [BRANCH: CHANCE]

[SCENE] A notice with a date circled, calendar and a plain key on the table. No false claim that a prior job was guaranteed.

**NARRATION**
> You had not made plans to move that year.
>
> There was work where you lived, for the moment. Your days had a useful order.
>
> The farm notice said the opportunity would close at the end of the week.
>
> You put it under a pile of papers on Wednesday.
>
> On Thursday, you took it out again.

[CHOICE C1E — WHAT WILL YOU LEAVE UNFINISHED?]
- **"An offer of seasonal work."** → `chance_loose_end=work_offer`.
- **"A small storage arrangement."** → `chance_loose_end=storage`.
- **"An order or deposit for something I'd intended to buy."** → `chance_loose_end=order`.
- **"A meeting I had agreed to."** → `chance_loose_end=meeting`.

**END BEAT**
> You wrote to the town office before the post went out.
>
> There was no answer that day.
>
> When the reply came, you read it standing beside the door.

---

# ACT 2 — Someone Who Knows You

### SCENE 20 — THE LAST CONVERSATION [COMMON, ORIGIN-TUNED]

The narrative interlude **must present an actual human scene**, not only 'choose friend/family' menus. The person has one normal concern; there is no forced bereavement or scripted manipulation.

**NARRATION (common, with origin-specific local detail)**
> Someone came by while the last boxes were open.
>
> They looked at the room, then at the folded farm notice.
>
> "That's a long way," they said.
>
> "It is."
>
> They picked up a book from the table and put it back.

[CHOICE C20 — WHO ARE THEY TO YOU?]
- **A friend** → `contact=friend`.
- **A relative** → `contact=family`.
- **Someone you've worked or lived beside** → `contact=colleague_or_neighbor`.
- **Someone from a changed relationship** → `contact=former_household`, only if prior origin/relationship logically supports it; else use 'a friend'.
- **Someone whose name you'd rather not say** → `contact=private`.
- **No one is here** → `contact=none`; replace scene with the following:
> You set a final box beside the door.
>
> There was nobody to say goodbye to that afternoon.
>
> You checked the address and shut the room behind you.
This is **not a Skip**; it is a completed distinct scene about solitude.

**Dialogue continuation if contact present:**
> "Write when you get there," they said.
>
> They did not make it a question.

[CHOICE C21 — YOUR PARTING REPLY]
- **"I will."** → `contact_intent=promise`. Do not automatically send a letter; future player still acts.
- **"I don't know how often."** → `contact_intent=uncertain`.
- **"Come up sometime, if you'd like."** → `contact_intent=invite`. No promise a visit NPC is implemented.
- **"I'd rather start without making plans."** → `contact_intent=boundaries`.
- If no contact: **"I'll make the arrangements myself."** → `contact_intent=none`.

**Branch-specific one-liners:**
- Security: "You could have stayed here another month," they might say if extension granted. "Another month," you answer. If no extension, no such line.
- Work: "They'll find someone," they say. "They'll have to," you answer.
- Household: "You can send word when you're ready." / "I know." No assumption reconciliation is desired.
- Curiosity: "You don't know what the place is like." / "No. I don't."
- Chance: "You always said you might do something different." / "I didn't say when."

**After:**
> You shut the last box.
>
> The room was ready for whoever came after you.

---

# ACT 3 — What Comes Along

### SCENE 30 — THE OPEN CASE [COMMON]

[SCENE] A case/satchel is half packed. A single player-selected personal memento will be stored in backstory records, not in a tool/equipment slot.

**NARRATION**
> The large things had gone already.
>
> There was room for one more small thing in your case.
>
> You looked through what was left.

[CHOICE C30 — WHAT DO YOU TAKE?]
- **A photograph.** → `keepsake=photo` (only if not falsely depicting the Rook family). The faded corner has been folded twice.
- **An old work tool.** → `keepsake=tool` (sentimental, not an in-game useable axe/hammer). The handle is smooth near the thumb.
- **A postcard or unsent note.** → `keepsake=postcard`. One line is unfinished; no written supernatural prophecy.
- **A small notebook.** → `keepsake=notebook`. Names/measurements/memories, not Agnes's separate diary.
- **Nothing.** → `keepsake=none`. The player closes the case and takes it; this is a valid choice, with a later written/behavioral origin thread still available.

**NARRATION**
> You closed the case and lifted it from the floor.
>
> You had more than you could carry in one hand.
>
> You carried it anyway.

**Production note:** This last line might imply the weight of multiple items, which should be illustrated. If no suitable art, revise to simply "You picked up the case."

---

# ACT 4 — The Road

### SCENE 40 — THE LAST STOP [COMMON]

[DIEGETIC TRANSITION] Road into hills, not an interactive vehicle simulation.

> By the time you stopped for fuel, the town behind you was too far away to go back for anything forgotten.
>
> You bought a drink and asked how much farther the road went.
>
> "To the farms," the attendant said. "After that, mostly trees."
>
> You checked the directions again.

**Private origin echo** — one small conditioned line:
- Security: "You had copied the terms of the farm onto the back of the notice."
- Work: "The last page of instructions was still in your coat pocket."
- Household: "You checked that the box was closed."
- Curiosity: "You took the photograph out to check whether the road looked familiar. It didn't."
- Chance: "The acceptance note had been folded and unfolded enough to soften its corners."

### SCENE 41 — DOWN THE HILL, UP THE ROAD [COMMON]

> The road crossed a ridge before turning between tall trees.
>
> You passed a junction where another road led downhill.
>
> You couldn't see where it went.
>
> Ahead, an old sign stood beside the ditch.
>
> **CROW CREEK HOLLOW**

**Geography caveat:** the downhill route may be the future road to Wicker Cove; no scripted statement that it visibly leads there unless real map/world route corroborates. Don't assert Lowmere/Wicker Cove postal lore resolution. The road crossing a ridge is a proposed visual consistent with terrain but not license to silently settle the old postman script's 'over hills' issue.

[CHOICE C41 — HOW DO YOU APPROACH THE TURN?]
- **"Stop and look at the sign."** → `road_pause=look`. One beat:
> The paint was flaking around the letters.
>
> Someone had cleared the brush from the lower half.
- **"Keep driving."** → `road_pause=drive`.
> You checked the sign through the side window and took the turn.

This is a small pacing/character detail, not a hidden bravery stat.

### SCENE 42 — THE FARM GATE [COMMON]

[DIEGETIC TRANSITION] Vehicle/silhouette stops out of frame; player approaches real starting area.

> The farmhouse appeared slowly between the trees.
>
> The roof was worse than in the photograph.
>
> Weeds stood along the path. The fence ran past the fields and disappeared into the brush.
>
> There was no one waiting at the gate.
>
> You found the latch and opened it.

[CHOICE C42 — A LAST ORIGIN-SPECIFIC THOUGHT, NOT AN EMOTION TEST]
The screen shows **only the origin's own three statements**. Player chooses what they intend *at that moment*, not what they will feel forever.

- **Security:** "First I'll make it fit to live in." / "I'll see what the land can provide." / "I'll take one day at a time."
- **Work:** "I'll do what needs doing, on my terms." / "I'll start with one repair." / "I don't have to decide everything today."
- **Household:** "There is room for a new routine." / "I can keep some things from before." / "I'll see how it goes."
- **Curiosity:** "Now I can find out what the photograph left out." / "First I'll learn the land." / "I have no idea what to expect."
- **Chance:** "The choice is made. The work comes next." / "I can find out whether this was worth doing." / "I'll start with what I have."

[STATE] `arrival_intention` recorded only as *chosen statement*. This is **not** an invisible personality score.

**END NARRATION**
> The farmhouse door was not locked.
>
> Inside was a bed, a desk, and work you would have to begin for yourself.

**TRANSITION:** fade from illustrated interlude to the source Oct 1 morning at the existing player spawn, with **all standard starting inventory, original game clock, Day1 guide, story, first-night scare intact**. If the real layout has no desk/bed at scene start, adapt wording after checking art; source currently indicates bedroom and hall accessible.

---

# ACT 5 — The Old Life Starts Answering Back
## First winter, five distinct future scene drafts — NOT part of the opening interlude; this is the follow-through

### WINTER W-A — SECURITY / THE FORWARDED BOX
**Prerequisite:** player chose security, and either stored boxes or left forwarding detail. Event channel ordinary Mail after current postal system supports it; not an Agnes/secret letter.

> **From the address you left**
>
> The last notice was settled. There are two boxes here under your name. I can keep them through the end of winter. After that you'll need to tell me what to do.
>
> No hurry until then. I thought you'd want to know.

[CHOICE W-A] **Arrange shipment at stated optional small cost** / **Ask for another short period** / **Tell them the boxes can go**. The world state must track cost and real later reply; if boxes were never stored, use an equivalent forwarding-account closing letter without inventing boxes. The player can keep the letter unopened for a short period but a real winter change exists.

**Callback:** Spring response reflects choice, and a later deed purchase *may* resonate but does not complete this origin arc automatically.

### WINTER W-B — WORK / THE OLD ORDER BOOK
> **From someone at the old job**
>
> You left the order book in good shape. One thing doesn't add up. I found your notes but I still can't see why the Thursday totals were different.
>
> I thought I'd ask before I start changing the figures.

[CHOICE W-B] **Send a short explanation** / **Ask which page they mean** / **Say you cannot take it on**.
- Sending help requires the player to choose, not automatic.
- If the player asks for page, they receive a bounded response, then decide; no infinite lore/mail chain.
- Refusing does not ruin the old coworker's life. They may ask someone else.

**Callback:** A later note reveals how the figures were handled; ongoing contribution is one of several possibilities.

### WINTER W-C — HOUSEHOLD / THE SECOND KEY
> **From the person who used to live with you** *(sender only identified if the player chose that relationship)*
>
> I found another key while clearing the drawer. I don't think it opens anything here anymore.
>
> Did you want it, or shall I put it away?

[CHOICE W-C] **Ask for it** / **Ask them to keep it** / **Say there's no need** / **Don't reply yet**.
Do not imply estrangement has to heal or that the key proves grief. If a player chose `relation=private`, letter can use "Someone from the house you left" instead of defining who.

**Callback:** Spring letter/keepsake state and relationship tone depend on player reply, not heart meter.

### WINTER W-D — CURIOSITY / THE PLACE ITSELF
> **From the person you told about the move** *(if contact chosen)*
>
> Did it look like the picture? You told me there were trees and a field, but I can't picture how far the house is from everything.
>
> Tell me one thing about it when you get a chance.

[CHOICE W-D] **Write about your actual crops** / **Write about a real repair** / **Describe the woods if actually visited** / **Say it's hard to put into words**. The first three must check real gameplay. If no acquaintance selected, replace with a concrete, non-social continuation: a notice correction or the original folded photograph next to real repaired farm improvements and a player-chosen short diary statement. **Every origin still has a winter development** without compulsory friendship.

**Callback:** Their next letter refers only to the thing player told them. Curiosity has tangible interpersonal choice, not a paranormal secret.

### WINTER W-E — CHANCE / THE OLD OFFER
> **From the place you left**
>
> The arrangement you had asked about has been closed. I've enclosed the balance and the address to write if you need anything else.
>
> Thank you for letting me know.

**Variant:** If old work offer, "We filled the position." If storage, "The unit needs to be cleared by spring." If order, "The item arrived; please confirm delivery or refund." If meeting, "They couldn't hold the time; write if you want another." Don't use a generic single paragraph that contradicts selected `chance_loose_end`.

[CHOICE W-E] **Close it** / **Ask for return of your property/deposit** / **Request a new date/arrangement**. Consequences recorded, no hidden penalty for picking the farmhouse.

**Callback:** A specific spring message confirms closure, return or continuing arrangement, not simply 'You made the right choice.'

---

# ACT 6 — The Later Choice Must Be a Scene, Not a Postcard

**Proposed spring/summer follow-through** (implementation later; editorial sequence now):
- **Security:** a final winter deadline or affordable forwarding option forces meaningful choice about tangible possessions, independently of farm deed; player can request modest terms instead of losing all.
- **Work:** coworker asks whether the player will handle a limited paid task next season; choose one-time advice, defined job, or refusal; later work carries on under others.
- **Household:** former household person proposes a clear correspondence arrangement or request for shared property; choose terms, return it, keep limited contact or close it. Boundaries honored, no forced romance.
- **Curiosity:** prior contact asks for an account of the move and perhaps an invitation. Player can answer based on actual experiences, send a picture with a particular truthful detail, or say they prefer privacy. Even without contact, a factual comparison of photo and actual land gets a personal expression choice.
- **Chance:** old practical opportunity can be restored partly, settled or declined after actual deadline; choice materially affects future correspondence or a small credited balance.

**All origins:** one early winter development + one midyear consequential reply + September true diary passage + year-two or postending echo. These are an equal second plot axis rather than 1–3 token callbacks.

---

# Editorial and technical QA

## Screens / flow
```text
NEW GAME (no Skip)
  → C00 reason (mandatory)
  → branch ACT1A/B/C/D/E (mandatory with real scene)
  → C20 personal context / no-contact scene (mandatory)
  → C21 parting reply or independent departure (mandatory)
  → C30 keepsake or no keepsake (mandatory)
  → ACT4 travel with C41 small observation (mandatory)
  → C42 one present-tense arrival intention (mandatory)
  → Confirm arrival
  → existing October 1 morning, unchanged
```

**No skip** means cannot bypass interlude, but game must allow Pause and Resume. **Do not let New Game bypass by loading a prologue-complete template or cutscene shortcut.** Old saves load normally; the missing origin is unknown and doesn't force a retrospective rewrite. No timed choices; no emotional confession mandatory beyond reason.

## A playable narrative must earn its duration
- The five branches above are read **one at a time**, not five sequential screen stories for one playthrough.
- Avoid line-by-line fades that make mandatory reading tedious. Allow instant reveal of current paragraph and advance at reader pace, with controller focus.
- Text should be revisited via Previous until final confirmation; choice history should be displayed in a compact recap only if it helps, not a form that reduces story to fields.
- Actual prose length, art and sound must be reviewed at game resolution; mandatory dialogue cannot be hidden under unreadable type or long hold delays.
- Each origin option should produce at least one distinctive Act1 scene, one winter difference, a midyear practical/social dilemma and later echo.
- Privacy choice changes descriptions, not validity of origin.
- If seasonal Mail has time-gated story scenes, don't schedule important personal-origin letter on exact day240 or timed Davy night; prevent interruption of authored high-priority scenes.
- No letter accidentally claims personal contact knows the fog, the Rooks, the player's secluded forest trips or their ending if not told.
- No obligatory origin perks, dialogue checks on source critical `maren_book`/`vicar_register`/`post_hand`, first-year rewards or Wicker Cove access.
- Verify exact town notice/deed legal wording with owner before runtime; this draft says 'available for occupation and work' to avoid incorrectly granting full inheritance/deed.
- Validate under first-day guide, existing first-night scare, seasonal old saves and all three endings.

## Creative editorial questions still open
1. How much of the interlude should be prose cards vs tiny navigable scene? Current draft assumes prose + two static travel transitions to control costs.
2. Should all five origin paths ship, or select fewer with equal depth? This draft demonstrates all five; the owner has not confirmed exact origin count.
3. Will one past connection have a real name and portrait? Current script keeps identities flexible; naming them could improve specificity but risks forced gender/relationships and art costs.
4. Does the common listing say 'parish', 'town', or 'clerk'? **Source estate letter says town**; drafted 'town office' pending legal/geographic review.
5. How to keep winter contact letters persistent in Mail without overwhelming story-important parish correspondence? The existing mail system must be audited.
6. What is the exact beginning time/scene? Preserve Oct1 game start; do not assume a pre-game specific day/time or a drivable vehicle if art disallows it.

## Task handoff (all gated / not implementation)
- `CCH-ROAD-SCREENPLAY-001` — P1 editorial draft of common spine, five origin branches, and first-winter scenes (this file).
- `CCH-ROAD-EDIT-001` — P1 line-by-line character/editorial audit for voice, possible unchosen emotions, length and branch coherence.
- `CCH-ROAD-UX-001` — P1 actual New Game/Diary/Mail/save/controller source audit; ensure non-skippable but pause/resume works.
- `CCH-ROAD-LEGAL-001` — P1 owner-confirm exact offer/town-held land context, preserving future deed.
- `CCH-ROAD-SPRING-001` — P1/P2 future full spring screenplay with one real consequence per origin, not a placeholder note.
- `CCH-ROAD-PROTOTYPE-001` — P1 gated owner-approved Godot first playable interlude for 2 original branches, then full five, all new games mandatory.
- `CCH-ROAD-QA-001` — P1 five paths, interrupted-resume, no trauma forcing, earlier-life winter/midyear branch integration, first day and canonical ending regression.

**Two equal narrative truths:** The player had a life before they came. What they do in Crow Creek Hollow becomes another part of that life. Neither erases the other.
