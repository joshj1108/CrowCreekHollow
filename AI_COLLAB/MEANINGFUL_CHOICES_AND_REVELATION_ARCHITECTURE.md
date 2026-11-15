# CCH-STORY-CHOICES-001 — Choice, Consequence, Revelation and the Art of Not Explaining Everything

**2026-11-14 — Deep story design / not implemented.** Preserve established 17 story chapters, their exact original gates, existing 3 endings and all original authored scenes. Wicker Cove first cast/names and new scenes below remain tentative. Owner-approved direction: no moral labels, storytelling in plain language with meaningful persistent decisions, optional bounded behind-the-scenes rolls for uncertain technical acts.

## 1. Why interactive stories often feel weaker than novels

Interactive fiction can fail four ways:
1. **The false choice:** two dialogue choices produce the same response and the same world.
2. **The perfect solution:** one apparently correct answer satisfies everyone, so sacrifice has no weight.
3. **The moral scoreboard:** NPCs and menus reduce a complex decision to 'good +5' or 'mean -5'.
4. **The exposition cascade:** every mystery is explained in long dialogue, leaving the player nothing to notice or interpret.

Crow Creek Hollow should instead build **situations** with materials, responsibilities, time and partial knowledge; give real alternatives; allow consequences to emerge several days or seasons away; then trust the player to infer meaning.

## 2. Six categories of authored choice
- **Priority:** which project gets scarce time/planks/coins first? Changes physical world and opportunity.
- **Commitment:** accept a contract, promise, repair, walk or order? Commitments have real costs and voluntary withdrawal; making a promise differs from completing it.
- **Method:** trade/gift/produce/repair/investigate; the result can be similar with different costs and future social context.
- **Disclosure:** share a public record, ask a witness, withhold uncertain gossip, or say you aren't sure. A speaker's trust should react to actual words, not player thought.
- **Risk:** proceed with prepared tools or wait/seek help; only genuinely uncertain actions warrant a hidden roll, no faked 50/50 morality.
- **Time:** choose not to engage right now; a world can progress modestly without you. Some offers close naturally but most ordinary opportunities recur.

One 420-second day should typically contain **zero or one** major authored choice, not six consecutive "what sort of person are you?" prompts.

## 3. What makes a decision interesting: real conflict without a villain
Consider four people:
- Farmer needs boards for shelter.
- Edith needs a dry guestroom to earn a living.
- Thomas needs payment to buy more goods.
- Martha needs winter-preserved fish for household demand.

None wants to hurt the others. Player has limited time and materials. **Choosing one useful action alters opportunities elsewhere.** That is naturally complex and avoids easy moral binaries.

A genuinely good branching scene states stakes plainly:
> 'I can pay for the boards,' Edith said. 'I can't pay for the walk up to the woods. You'll have to decide whether it's worth it.'
Here the player knows price/time, then chooses. Game can show inventory cost, day use, and owner share. No hidden extra punishment.

## 4. The eight-act revelation ladder already inside the original spine

This is a map for *audience understanding*, not permission to add eight new quests or move reveals.

| Dramatic question | Existing source beat | What becomes clearer | What must stay unconfirmed |
| --- | --- | --- | --- |
| Why does the farm feel occupied by history? | first night, Agnes pages, edge trek | something is wrong at this homestead; original memories matter | exact complete cosmic mechanics |
| Who was Agnes as a human being? | Maren hens/lamp scenes and Agnes diary | someone with habits, a home, friends and unfinished work | what every person thought about her |
| Why was the bell removed? | Maren hands, town letter | people feared its answering sound; official vote 31 to 4 | fog origin or whether all voters shared same motive |
| What happened to Elias? | orchard and Davy's grandfather accounts | the orchard/lantern/walking burden connect to history | every detail until original grove scene |
| Why do records matter? | Maren minute book and vicar register | the town's decisions and farm transactions have a written trail | extra arbitrary hidden documents |
| How did the town justify the burden? | vicar register, E. Pell letter, mill meeting | old institutional fear, repeated transfer of farm duties | a cartoon secret mastermind |
| What has the past demanded of Davy? | `davy_turn`, day370 possible night | child hears adult burden as a turn he could take | absolute fate until actual found/grove state |
| What can the player change? | meeting, crow bell, grove, existing endings | actions/evidence and old relationships create specific outcomes | Wicker Cove fog's onset/cause, player's private interpretation |

**Critical ordering:** `post_hand` handwriting reveal belongs to existing late postman scene and is among conditions for `elias` ending. We can *foreshadow* writing through mundane tax slips and careful paperwork only with source-safe original scene timing; never let Thomas casually identify the strange handwriting before its reveal.

## 5. The reveal must reframe a concrete earlier detail
A powerful reveal does not merely add information; it makes an earlier action or word change meaning.

### Example: the parish letter and deed
First, the farmer seeks ownership for security through existing deed payments. Later, the letter addresses them as *tenant* and forbids a bell. When vicar discloses repeated deed transfers, the earlier purchase/repair questions feel different. **The exact letter is always received regardless of town visits or deed status.** Do not create unsupported claim that purchased deed is invalid or text magically changes.

### Example: Maren's lamp and minute book
First, a woman keeps a lamp in her window. Later, records show exactly who stood or didn't stand at the meeting. Her lamp was an action she took to live with that night; it does not excuse or erase the vote. Preserve the original `maren_lamp`, `maren_hands`, `maren_book` reveal order.

### Example: Davy's whistle and lantern
First, Davy whistles for missing Pip, an ordinary boy behavior. Later, the player sees an unlit lantern in his lap at the great tree if original day370 event occurs. His earlier play has prepared an emotional connection. Never turn skipping stones or a high friendship score into a required rescue key.

## 6. Eight branching situations that build human meaning

### Case 01 — The Dry Wood (first autumn; existing-farm vertical slice)
**Conflict:** workbench/roof preparation vs saving time; a neighbor has a practical opinion.
**Options:** ask Maren how she would stack wood; offer fair small trade for advice/help; work alone; defer. Original day4 edge escort always available.
**Immediate:** practical information or transaction only when actual system supports; perhaps bench help is learned through standard UI regardless of answer—no soft-lock.
**Two-week callback:** Maren can observe properly sheltered wood if she visits, but reliable diary note is based on actual completed repair; no false assumption about her feelings.
**Later:** winter stores or roof reflect materials spent. **No magic trust score** for obeying advice.

### Case 02 — The Winter Request (December, existing winter plan)
**Conflict:** another household needs dry wood/food; farmer's reserves finite.
**Options:** gift supplies, fair exchange, conserve for farm, investigate a missing delivery, or postpone.
**Immediate:** item/coin transfer, risk/next work, reliable feedback.
**Winter callback:** household found another source if player declined; farmer with extra wood remains warmer; trade can create later reciprocal service.
**Spring echo:** one person remembers actual interaction; no arbitrary announcement the village 'respects' donor.
**Agency:** this is not an exam in generosity. If player had too little, dialogue recognizes reality.

### Case 03 — First Wicker Cove Order (spring; town unimplemented)
**Conflict:** store needs crops, inn needs fresh meal ingredients, farmer needs seed money.
**Options:** sell at normal price, fulfill a bounded order, keep harvest, take paid repair instead.
**Immediate:** different real coins/items/opportunity with no automatic reputation grade.
**Summer echo:** Thomas/Edith mention only delivered goods; stock visuals match.
**No-town run:** farm stand remains functional; missing town area doesn't invent social memories.

### Case 04 — The Wrong Date (spring; optional fog witness)
**Conflict:** a harbor worker remembers visibility; an old ledger reports different conditions.
**Options:** ask details, examine document, listen to second worker, set it aside.
**Immediate:** source-qualified testimony, no objective verdict.
**Later:** exact resident reacts only if player spoke with them/was seen consulting records.
**Optional d20:** decipher damaged digits on a receipt with relevant ability/tool; difficulty could vary; success changes *legibility*, not historical truth. Failure leaves follow-up path. No reroll exploit.
**Canonical truth:** Wicker Cove remains permanently fogbound and fog onset/causation unresolved.

### Case 05 — The Boards We Have (summer; inn after town/workbench)
**Conflict:** planks for farm or Edith's leaky room.
**Options:** farm first, paid inn repair, shared materials/work, wait/decline.
**Immediate:** resource costs and physical improvement that truly completes; no fictional automatic building.
**Fall/winter echo:** room dry → guest lodging request; house first → own stage improves; owner may patch room herself later.
**Year2 echo:** an actually lit upper window, not a full restored city.
**Fallback:** absent implemented inn, do not show this case.

### Case 06 — The Late Return (summer; optional Gideon boating later)
**Conflict:** more fish vs reliable daylight/safety; Gideon and Martha have different practical priorities.
**Options:** return now, attempt another safe ground, inspect conditions, decline voyage.
**Immediate:** honest time, catch and crew risk signals. Hidden technical roll only where genuinely uncertain; never forced danger for basic fish resources.
**Autumn:** market preservation/stock changes if catch truly delivered.
**Safeguard:** neither outcome reveals fog origin; no boat trip required to finish Rook main story.

### Case 07 — The Town's Letter (fixed day240, not a new branch)
**Conflict:** public authority tells the farmer what they cannot do with the bell.
**Player expression optional after original SHOWN scene:** 'I want the record', 'I want to understand', 'I don't plan to let them decide', or no response; **do not** make this replace showing letter or alter original meeting.
**Consequences:** which optional supporting dialogue is seen; one selected stance can enter diary; actual meeting requires two original records.
**No false canon:** town did not necessarily *know* farm was purchased; Edwin Pell wasn't adult voter 30 years earlier; preserve original signature/wording.

### Case 08 — What Remains After the Grove (post-ending)
**Conflict:** no binary objective here; the player decides whether to continue farming, spend next summer with neighbors, work on a room, or leave projects unfinished.
**No required menu:** player exercises freedom through gameplay.
**Later:** one true line from town/walkers if actual relevant state present; house and town improvements persist.
**Safeguard:** `hollow` outcome remains recoverable, `bell` with lost vote can leave farmer ringing alone, `elias` is earned by all original conditions. No universal celebration, fog clearing, life-reset, or unearned friendship.

## 7. Consequence topologies: branches then reconverge with memory

**Structure example:**
```text
Common farm work (player has some raw timber)
  ├─ keep boards for house ──────────────> better shelter, delayed inn opportunity
  ├─ paid inn contract ──────────────────> coins, dry guestroom, deferred shelter
  ├─ shared project with Edith ──────────> agreed split of time/materials
  └─ decline / come later ───────────────> no job; Edith patches what she can
                    |
          same main seasonal world continues
                    |
          conditional daily physical state
                    |
          one optional delayed dialogue/diary echo
                    |
        original Rook story unchanged
```

The game should reconverge at the season and central plot level while **not** reconverging the inventory, business state, relationships, diary or small things players notice. This controls narrative complexity and preserves replay value.

## 8. A 4-part standard for every major reveal
1. **Question:** what fact is unclear but meaningful *before* the scene?
2. **Evidence:** what exactly changes knowledge? Who saw it? What original scene can provide it?
3. **Reframe:** which earlier event/object now means something else?
4. **Aftermath:** what person, daily routine or decision feels different afterward?

**Example, source-backed:** the vicar's original register reveals repeated sales of the farm to outsiders and the town's role. It reframes the cheap property, annual taxes/deed and official letter. The next day the player is still watering crops. The bigger truth hasn't removed ordinary obligations.

## 9. A difficult story should not make player helpless
A narrative can be morally complicated and still fair:
- Tell player material cost and approximate timing of optional work.
- Guarantee default forestry/tool crafting and baseline trade.
- Preserve original mandatory story triggers, including Davy's one-night event after its actual prerequisites.
- Avoid irreversible harm from purely random optional checks.
- Let characters sometimes refuse unfair terms; that is their agency.
- Give players chances to revisit ordinary missed opportunities without erasing the cost of timing.
- Let some historically specific one-time events remain one-time, with advance in-world signal where possible.
- Never imply the player can choose not to trigger night danger if the current source says the Hollow already comes under particular conditions.

## 10. Davy: an emotional dilemma the game should handle carefully
The existing code gives Davy a precise one-night window and consequences; altering it for drama would risk making a child a prop for emotional blackmail.

**Better direction:**
- Many earlier ordinary boy moments, not all about danger.
- A late story that arises from what Davy has actually heard from adults, not a mystical 'you failed to be his friend' meter.
- When found, existing scene means player chooses to go to him through action, not a timed correct dialogue quiz.
- When lost, grief/absence appear without narrator claiming the farmer is guilty.
- In the original grove ending, eventual return depends on actual original conditions and is described as changed.
**We should never sell the game as a moral test of whether the player 'saved a child by being good'.** That would flatten everything.

## 11. The three endings as different questions
- **The Hollow Sleeps / bell:** Can a longstanding duty be carried, either jointly after a vote or alone despite it? The result depends on records and actions, not kindness points.
- **Two Came Home / elias:** What is possible when history is faced, people act together, and the player completes particular hard tasks? Keep original special requirements; don't label this 'the only moral ending.'
- **The Line Under the Rooks / hollow:** What happens when the old pattern repeats? This is a legitimate, **recoverable** story outcome, not a punishment for morally wrong playstyle.
The endings differ in material and supernatural results. Do not assert they are equally pleasant; instead respect them as **meaningful**, with clear consequences and continuing gameplay.

## 12. Blueprint for source-safe production
- One event ledger records chosen option, execution/completion, payment and credible witnesses; avoid duplicating `FolkSystem.seen`/quest flags.
- One communication path connects an action to a second person only where ordinary relationships support it.
- One deterministic callback within 7–30 days; one physical change or economic effect.
- One authored short player diary sentence from recorded facts. No GPT-like generation in runtime required.
- Optional skill/roll only for materially uncertain, well-signposted task, with saved result.
- Existing `StoryAct` canonical scenes remain priority over optional chats.
- Reuse existing chat UI/DiaryBook; new input/controls must be separately approved and tested.
- Tests: all choice options, skip, return, old save, no town, first-year game day, 17 chapters and three endings.

## Proposed tasks
- `CCH-STORY-CHOICES-001` P1 **design** — this library and revelation ladder.
- `CCH-STORY-CHOICES-AUDIT-001` P1 — match each optional action to available current or planned code, resource keys, source scenes and risks.
- `CCH-STORY-REVEAL-001` P1 editorial review — prevent all new lines from leaking post_hand, vicar_register, maren_book and Davy future.
- `CCH-STORY-CHOICES-SLICE-001` P1 gated — existing farm one real cost + delayed callback + authored memory.
- `CCH-STORY-CHOICES-QA-001` P1 eventual — consequence, replay and original-plot regression.

**Depth comes from the price, specificity, and memory of a decision—not the number of choices displayed on screen.**
