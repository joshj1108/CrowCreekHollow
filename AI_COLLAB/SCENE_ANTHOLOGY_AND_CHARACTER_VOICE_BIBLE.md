# CCH-SCENES-001 — Character Voice Bible and Twelve Small Scenes

**Created:** 2026-11-14. **DESIGN/EDITORIAL SAMPLES, NOT IMPLEMENTED DIALOGUE OR FINAL CANON.** No game-code authorization. Existing `FolkSystem` scenes and `StoryAct` beats prevail.
**Goal:** A memorable literary story in plain language. Work first, backstory second; a small human want in every encounter; dialogue brief, readable and performed at the pace of a 420-second game day. These examples are not promises that all named candidates or schedules are approved.

## Primary voice scorecards

| Voice | Sentence rhythm | What they notice | What they avoid saying | Avoid writing |
|---|---|---|---|---|
| Maren | short, matter-of-fact; wry afterthought | roofing, weather, Ruth, woodpiles | direct confession until her existing scenes | magical prophecy and nonstop warnings |
| Davy | quick questions, literal jokes, abrupt sincerity | skipping stones, Pip, fish, feet in water | that he's afraid, until original scenes earn it | wise-beyond-years adult speeches |
| Vicar | measured, careful, few contractions when troubled | names, hands, hymns, practical charity | personal complicity until authored scenes | sermon as quest exposition |
| Postman | route-focused, dry and exact | weather, names, delivery, addresses | the old hand and letters until original reveal | cryptic fortune-cookie mail |
| Edith (candidate) | direct, tired humor, hospitable without theatrics | sheets, food, guests, leaks, payment | anxiety the inn may close | tragic soliloquy |
| Thomas (candidate) | exact terms, fair but cautious | stock, credit, dates, promised deliveries | how precarious his store is | stingy caricature |
| Gideon (candidate) | sparse, practical, sea-weather language | knots, tides, seam, crew | fear of unnecessary risks as fear | nautical pirate slang |
| Martha (candidate) | brisk, concise, dry concern | fish quality, salt, spoilage, who needs food | tenderness in public | rude bully/authoritative fog oracle |

For existing walkers, verify each proposed line against exact `FolkSystem` heart and seasonal gates. Ruth/Mrs Tull/grandfather may remain **offscreen**; scenes involving them require delivery via existing NPC or new approved assets, not spontaneous walk-on sprites.

## Twelve original scenes (all optional or tone-only)

### Scene 01 — Autumn / Maren: 'Dry Wood'
**Trigger candidate:** after real Maren edge trek, if player has an actual loose/uncured timber repair; otherwise generic advice about rain. Does not override `maren_lamp` or first story gate.

> Maren stopped beside the woodpile.
>
> 'Turn those logs.'
>
> 'Why?'
>
> 'Because the bottom ones are wet.'
>
> She tapped one with her stick.
>
> 'I learned that by spending a winter being cold. You can learn it that way if you'd rather.'

**Player options, if dialogue UI eventually supports it:** 'Show me' / 'I'll trade you a hand with your chores' / 'I'll work it out.' Different short responses, no morality.
**Callback:** later remark about wood *if player actually stacked it*, or no special line if not. No generic +10 righteousness points.

### Scene 02 — Autumn / Davy: 'Three Skips'
**Trigger:** early pond visit, from existing Davy eligibility; short enough to ignore.

> Davy held up two stones.
>
> 'This one or that one?'
>
> 'The flat one.'
>
> He threw the round one. It skipped three times.
>
> 'Knew it,' he said.
>
> Then he went looking for another.

**Callback:** later a small flat stone on pond bank or a conversational line. Only if source state can prove the encounter. Do not make Davy a guaranteed daily visitor.

### Scene 03 — Late autumn / vicar: 'The Book'
**Trigger:** vicar legitimately met; not the `vicar_register` reveal.

> He had been straightening the hymn books when you came by.
>
> 'How many people come?' you asked.
>
> 'Some months nobody.'
>
> He set one book down.
>
> 'I still put them out. It's simpler that way.'

**Callback:** a hymn book moved into place, not a new confession.

### Scene 04 — Winter / postman: 'Wet Letter'
**Trigger:** delivered ordinary parcel, not `post_hand` or old Lowmere mail. Avoid revealing private correspondence.

> The postman shook water from his cap.
>
> 'The road's worse than it looks.'
>
> 'Is the post all right?'
>
> 'The post's dry.'
>
> He looked down at his boots.
>
> 'One of us is.'

**Callback:** later he notes the farm gate was passable, only if truly repaired. Postman remains distinct from Wicker Cove's tentative resident cast.

### Scene 05 — Winter / Maren-Ruth: 'The Wrong Recipe'
**Trigger:** actual Maren request/gift completed; Ruth offscreen, no new NPC needed.

> 'Ruth says this needs more salt,' Maren said.
>
> She took another spoonful.
>
> 'She says that about everything except her own cooking.'
>
> Maren took the jar home anyway.

**State:** small variation if player provided actual cooking vs bought finished item; no invented meal.

### Scene 06 — Winter / Davy: 'What Floats'
**Trigger:** Davy actually present by pond on winter day, weather can vary; if no ice, don't mention ice.

> 'The pond looks smaller when it's cold,' Davy said.
>
> You looked at it.
>
> 'Does it?'
>
> 'I think so. Everything else is the same size.'
>
> He considered that.
>
> 'Maybe I'm getting taller.'

**Callback:** one later line about his growth or his grandfather's caution; do not manufacture character age progression.

### Scene 07 — Spring / Edith-Thomas: 'The List'
**Trigger:** candidate town store + inn built, both introduced, real incoming order.

> 'It's missing flour,' Edith said.
>
> Thomas looked at his list.
>
> 'It says flour.'
>
> 'A list isn't a bag of flour.'
>
> Thomas turned the page over.
>
> 'No,' he said. 'But it's what I have until Tuesday.'

**Player involvement:** supply an actual ingredient, accept one paid delivery, or leave dispute alone. No mandatory choice. **Callback:** one accurate pantry/shelf change, not town saved.

### Scene 08 — Spring / Gideon-Martha: 'The Tide'
**Trigger:** candidate harbor scene after boat/market available.

> 'Another hour,' Gideon said.
>
> 'Another hour and I can't sell half of it fresh,' Martha replied.
>
> 'I don't decide when the fish come.'
>
> 'Neither do I. I decide what happens when they get here.'
>
> They both went back to work.

**Choice:** player could buy/smoke catch or help with storage *if the economy supports it*. No hidden supernatural explanation of tides or fog.

### Scene 09 — Spring / Maren-vicar: 'The Old Book'
**Trigger:** only **after** original `maren_book` and `vicar_register` facts known to player; no shortcuts. This is an after-the-fact supplementary line, not a new proof.

> Maren put her hand on the book.
>
> 'Ruth wrote it down.'
>
> The vicar nodded.
>
> 'I know.'
>
> 'Then we ought to stop talking as though nobody remembers.'

**Callback:** conditional one-line acknowledgment after canonical meeting, independent of outcome. Do not change _ready_for_meeting.

### Scene 10 — Summer / Edith: 'Too Many Buckets'
**Trigger:** first inn-room repair offered, owner cast approved, roof not yet repaired.

> 'Three buckets,' Edith said.
>
> 'For one leak?'
>
> 'For three leaks. One's just better at finding the floor.'
>
> She shifted a bucket with her foot.
>
> 'I'll pay fair for the work. Can't pay much more than that.'

**Choices:** paid work / barter a stated service / postpone / decline. Roof changes only on actual completion; cut logs → workbench planks only once that chain is truly implemented.

### Scene 11 — Summer / Thomas-Martha: 'Half a Crate'
**Trigger:** candidate farm produce supply contract actually fulfilled.

> Martha sorted the vegetables into two piles.
>
> 'You ordered a whole crate,' Thomas said.
>
> 'I bought a whole crate. These aren't all going to keep.'
>
> Thomas looked at the bruised leaves.
>
> 'I'll tell the farmer.'
>
> 'Tell them to bring them before the sun's high. The rest is fine.'

**Value:** market feedback without antagonism, ability to improve future delivery timing. Don't introduce spoilage as an invisible new penalty without UI.

### Scene 12 — Second autumn / Davy, if existing encounter **already** resolved
**Trigger:** after `StoryAct` scene, not during Davy's timed night; if found, any later Davy talk only if allowed by original location/availability. Do not claim he is present when story `davy == lost`.

> The flat stones were still by the pond.
>
> You turned one over with your boot.
>
> The water moved against the bank.
>
> Nothing else.

**Meaning:** absence is an observation; don't tell the player they are grieving. If Davy has returned through the actual grove state, an entirely different line can be written using real location and visit schedule. Missing Davy is not proof of death.

## Micro-branch example: same dialogue, three remembered histories
**Situation:** weeks after inn work, Edith encounters player. Only one line should appear, as appropriate.

- **Paid repair completed:** 'Water stayed out last night. First time in months. I put your payment by the till.'
- **Player offered materials but work not complete:** 'Boards came in. I've put them upstairs, out of the rain.'
- **Declined or never engaged:** 'Still got the buckets. They do the job until I can pay for better.'
- **Town not implemented/player never visited:** **no line**, no ghost NPC or diary.
Never mistake option *selected* for job *completed*, nor promise coins already given twice.

## Short scene architecture and camera/UI constraints
- Aim for 4–9 lines for a tiny interaction, one readable detail, 0–3 options, a quick return to control. Existing gameplay days run 420 real seconds and pauses during menus; player should not spend their entire afternoon reading mandatory popups.
- Every character gets at least one wholly ordinary scene, one practical conflict, one optional memory echo. Not every character needs a major tragic secret.
- Each scene should give character something to do before player appears. The postman carries, vicar sets out books, Maren tends firewood, Davy plays, Edith counts rooms, Thomas checks stock, Gideon repairs nets, Martha preserves fish.
- Write conditioned diary notes only when a fact was observed by player; no emotional assumptions or fog causation.
- Prefer *one quiet line* per memory to repeated exposition. If more dialogue cannot meaningfully differ by history, leave scene shared.
- Review all tone-only samples before claiming canonical names, scenes, dates or rewards.

## Voice review checklist
1. Could this person say it aloud without sounding like a written monologue?
2. Does this fit their existing `FolkSystem` words and milestones?
3. Is the speaker's information plausible and earned?
4. Does the action or object do more work than a paragraph of explanation?
5. Does the player retain agency, including the option to do nothing?
6. Does any potential memory rely on an unimplemented village, logging area, workbench, anvil or guest room?
7. Does a player without relevant state see no false claim?
8. Does Davy, the meeting, the bell, post_hand or the fog remain governed by original canon?

## Tasks
- `CCH-SCENES-001` P1 editorial design: 12-scene tone anthology and voice table (this document).
- `CCH-SCENES-AUDIT-001` P1: compare 12 samples against actual words, skill/dialogue UI capacity and original scenes before any adoption.
- `CCH-SCENES-PROTOTYPE-001` P1 gated: adopt at most ONE small farm-side scene plus one reliable callback through shared choice/diary engine, owner approval required.
- `CCH-SCENES-COVE-001` P2 gated: one two-NPC harbor/store/inn conversation after owner cast selection and functional town.
- `CCH-SCENES-QA-001` P1 eventual: 420s pacing, scene skip/repeat, readability, input/controller, original character gates, save/load, no-town run.

**Samples are entirely optional writing material. They are not ready-to-insert script code.**
