# CCH-TWO-LIVES-001 — Two Lives, One Road
## The Mandatory Interlude and Five Equal-Weight Origin Arcs

**Date:** 2026-11-14. **Authority:** design writing, not a code instruction or final approved dialogue. Supersedes *optional / skippable / one-token letter* framing found in earlier drafts. Read with `PLAYER_ARRIVAL_INTERACTIVE_PROLOGUE_DESIGN.md`, `PLAYER_IDENTITY_AND_HOME_STORY_BIBLE.md`, `FIRST_SEPTEMBER_BRANCHING_DETAIL.md`, `YEAR_TWO_COST_OF_STAYING_DESIGN.md`, `NARRATIVE_VOICE_AND_LITERARY_STANDARDS.md`, `scripts/story_act.gd`, and `scripts/estate_system.gd`.

## Creative contract: the user's corrected vision
The player's reason for coming is **just as narratively important as why they stay**. The opening is a **mandatory, unskippable interactive interlude** for every new game. It is not a cosmetic character creation survey. The chosen origin gets a complete beginning, tension, material or interpersonal midgame decision, changed relationship or circumstances, and season/year-two response. An origin is not automatically healed, transcended, discarded, disproven or folded into the Rook mystery.

**The two stories are distinct and in conversation:** a person arrives with obligations, connections and reasons. Their farm life creates another set of actions, relationships and obligations. A player may honor one life and reject parts of the other; remain connected to both; or make a new practical arrangement. The game never scores this as maturity or virtue.

**No single canonical tragedy, kinship, sex/gender, crime, fixed romance, parenthood, occupation, occult destiny or illness.** Players may decline disclosing the *details* of one prior connection, but cannot bypass the prologue or choose that they had no reason to arrive. The positive/practical options must be written as seriously as the painful ones.

## Source-grounded continuity
- Current `EstateSystem` owns the town-held farm **on the town's terms**, charging quarter tax until the deed is eventually **purchased** (current purchase cost 12,000 coins, 500 increments after Patched house). An interlude about 'inheriting free title' or being Agnes's child **would contradict the current game**. **Proposed shared anchor:** answered an ordinary notice for a neglected farm to occupy/work. Exact legal copy needs owner approval before runtime.
- The original player begins **October 1**. Mandatory interlude occurs *before* the day clock and ends at original guided first day with no loss of supplies, time or existing story opportunities.
- The original parish letter **day240** and subsequent book/register meeting, Davy event, bell and grove endings have fixed independent conditions. Origin stories cannot bypass or vary them.
- Existing `FolkSystem` walkers (Maren, Davy, vicar, postman) have original words and heart gates. A past acquaintance is not automatically a new walker or an NPC physically present at farm.
- Existing `Mail`, `DiaryBook`, `EstateSystem` and save data might be reusable after source audit. New backstory flags and delivery mechanisms are **illustrative contracts, not verified keys**.
- Wicker Cove is fogbound coastal village below farm; its true fog origin remains unknown. Old postman Lowmere postal/geography conflict is independently pending.

## Structural spine: five beats each origin must actually earn

### 0. Mandatory opening: What made the move possible?
A scene **happens**, then player chooses among actions/utterances in it. First choose a reason to consider the notice. The subsequent prose and one human exchange are tailored. Origin is a lived circumstance, not a 'personality class'.

### 1. First autumn: What does the past look like in a new room?
A specific brought object, uncompleted paper or chosen personal connection appears naturally when unpacking. It must be visible or inspectable through existing interfaces after implementation. The player can choose to put it away, display it, answer someone or leave it unfinished; all are choices without preassigned emotion. A player who chooses no keepsake receives origin-specific recollection through actual remembered action, not a blank text.

### 2. Winter: An old life moves without you
The past produces an **external change**. Someone writes, a practical deadline arrives, an item is forwarded, a successor resolves part of an old work problem, or the player realizes an old opportunity has passed. The world before the farm still exists. The player can respond then or defer, with a limited honest consequence.

### 3. Spring/summer: One significant origin decision
A genuinely different **choice with a cost** rather than a letter to read: spend a day's time and postage to settle a commitment, provide advice without promising ongoing labor, send a parcel back, reclaim or relinquish something, invite a conversation or set a boundary. The exact choice depends on origin, and **the player never has to leave the farm or travel to a second fully realized city**. Later response changes due to their action. No roll of luck for relationship honesty.

### 4. September / second autumn / afterword: Two lives remain
An authored passage can juxtapose a verifiable origin decision and a real farm action. Neither life is the 'real' one. At the end, a small specific consequence persists: a person sometimes writes; a claim is settled; a keepsake changes where it rests; an old contract is closed or left open; the original question remains unresolved by conscious choice. This is not a universal 'I found myself at last' speech.

## Origin A — The Cost of a Room
**Dramatic question:** Is a stable place defined by a legal paper, by work, or by a person's ability to remain?
**Not a poverty morality story:** Player did not necessarily lose job, go bankrupt, or make bad choices. Housing terms simply changed; the farm offered a real alternative.

**Interlude scene, proposed:**
> The new rent notice arrived on a Thursday.
>
> You placed it beside the last one and compared the figures.
>
> There was a little difference in the ink. A great difference in what you would have left.
>
> The farm notice lay beneath them, still folded.
>
> You opened it again.

Player chooses whether to **negotiate more time**, **move on before the next bill**, or **ask a trusted person to hold two boxes**. All end with moving; each creates a different practical thread without financial penalty to starter stats.
- If negotiate: departing landlord/agent responds with a final ledger; exact legal wording flexible.
- If move directly: forwarding-address issue for one small legitimate possession or final charge.
- If ask for help: a friend stores two boxes and later needs a pickup/decision.

**First autumn:** the paper comes out of a packed folder; farmer chooses whether to file it away, reply, or leave it on the desk (if interface supports). New home has leaks; that does **not** prove moving was a mistake.
**Winter:** forwarding mail arrives: the held items may need to be moved, the old account may have been reconciled, or an address expires, according to earlier selection.
**Spring/summer choice:** pay a limited, explicit amount for shipment vs release an ordinary kept object vs ask person to keep it until later. Give a path possible without much money (written reply/partial package), and no obligation to sacrifice farm survival.
**September:** player may have made steady farm progress while still not owning deed. Reflection can report that both questions remain open. Purchasing the future deed has strong *optional* resonance but is not prerequisite for personal closure.
**Year-two echo:** forwarded personal object now on shelf, account closed, or an envelope with return address but no demand to write.
**Two end-variations (only if verified):**
> 'The last box came in the spring. I set it beside the workbench and left it there until the rain stopped.'
> 'I sent word that I could not pay to move the boxes. They were given away. I kept the letter.'
No assertion of regret or belonging.

## Origin B — Work That Belonged to Everyone
**Dramatic question:** What does freedom from a former job mean when people will always ask for your time?
**Not a billionaire-burnout story:** Work may have been useful and coworkers decent; player wants autonomy rather than hating all labor.

**Interlude scene:**
> There were three notes on your desk when the shift ended.
>
> One was from someone who needed your help tomorrow. One was a reminder about a deadline you'd already met.
>
> The third was the farm listing.
>
> You folded that one and put it in your coat.

Player chooses a truthful exit: **give two weeks' notice**, **finish a project and leave**, or **leave instructions for whoever comes next**. The former work is deliberately left unspecific enough not to claim skills or new crafting bonuses.
**First autumn:** unpack a pencil, little notebook or unused work tag. This must not become a free metal axe.
**Winter:** old colleague asks for advice on one concrete problem (an invoice mismatch, scheduling, a missing instruction); they have tried to solve it independently. The player can send advice, refer to their old notes, or decline without ridicule.
**Spring/summer choice:** receive a chance to return for seasonal work or become a paid remote consultant (only if resource/economy balanced), offer a one-time answer, or close the contact. This isn't a choice between 'money' and 'happiness'; honest time and payment must be visible.
**September:** player may find that fixing a neighbor's roof resembles old work while feeling different in terms of agency—but **do not write they enjoyed it more unless chosen**. Their current workshop can provide factual contrast.
**Year-two echo:** colleague managed the task without them; a periodic invoice arrives if contract accepted, or a last brief note from someone grateful for clear instructions. No universal demand for constant service.
**Example:**
> 'The job went on without me. They wrote in February about the order book. I sent back the page they needed.'
This origin can be beautifully ordinary and still be a complete narrative.

## Origin C — A House With One Less Person
**Dramatic question:** Can a relationship change without being erased or turned into a wound the story must heal?
**Not mandatory bereavement:** One former housemate, friend, partner or family member moved away or the arrangement ended. **No forced death, illness, infidelity, abusive situation or heterosexual romance.** Relationship type chosen separately.

**Interlude:**
> There had been two cups on the shelf.
>
> There was one now.
>
> You put the other in a box. Then you took it back out.
>
> The farm notice was on the table.
>
> You had not decided what to write in reply.

Player selects relationship type **only if comfortable**, then a concrete reason the household changed: **mutual decision to separate**, **their move for work**, **different needs for living space**, or **prefer not to explain**. The chosen reason must affect later contact tone; never assume former person is malicious or dead.
**First autumn:** one letter or object is packed or left, with a short player choice about keeping in contact.
**Winter:** other person has begun a different practical routine; their letter is not a guilt trip. May request a shared item or ask whether farmer wants to keep receiving news.
**Spring/summer:** reply openly, set terms, return a shared item, ask for time, or end correspondence. The specific choice has mutually exclusive later outcome but not a universal 'right way to move on.'
**September:** factual reflection about continuing, changing or closing the correspondence and the actual farm life. The person before may have made a new home too.
**Year-two echo:** possible ordinary postcard if contact ongoing; a returned object if closed; silence as a valid outcome.
**Example:**
> 'A letter came in January. We settled what to do with the books. There hasn't been another.'
or
> 'We still write sometimes. Mostly about ordinary things. I told them what grew well this summer.'
Only if what the player actually wrote/witnessed is logged.

## Origin D — The Place in the Photograph
**Dramatic question:** Is choosing a place out of curiosity less serious than leaving under pressure?
**Reject destiny:** The player was not secretly summoned by Agnes or related to Elias; the photograph cannot foretell the fog/bell truth.

**Interlude:**
> There wasn't much of the farmhouse in the photograph.
>
> The roof, part of the fence, trees.
>
> You could have put it back with the other listings.
>
> Instead, you wrote the address on a clean piece of paper.

Player chooses what drew them: **the land**, **the chance to grow food**, **the remoteness**, or **something ordinary they remember from a former rural visit**. The last is optional and not a secret kinship.
**First autumn:** expectation vs actual work, e.g. a place in the photo isn't the same after first rain; no narrator says the farmer was naive.
**Winter:** past friend asks what the place is actually like, or an old photo's publisher sends a correction about the listing; player's chosen interest returns.
**Spring/summer choice:** tell an old friend one accurate specific thing about farm, woods, Wicker Cove if visited, or choose not to send photos/description. The friend can ask whether the player wants a visitor, but there is **no unimplemented arriving NPC**.
**September:** journal juxtaposes original picture with genuine changed building/field, *without claiming that things are better*. A player who never repaired house still has a valid changed understanding: practical distance, weather, seasonal harvest.
**Year-two echo:** photo can be compared with original landscape; player can keep or give away postcard, not objective mysterious foreshadowing.
**Example:**
> 'I came because of a photograph. It did not show the wet ground or the work. I still have it.'
This is not a weak origin; choosing a place can be an active commitment.

## Origin E — A Chance Before It Closed
**Dramatic question:** What does it mean to take an uncertain opportunity before you know how it will turn out?
**Pragmatic without flatness:** The player was at a legitimate life crossroads; the farm notice had a deadline, an offer or a short window. No melodramatic ultimatum.

**Interlude:**
> The notice said applications closed Friday.
>
> You had a place to live and enough work for now.
>
> You didn't know if that would still be true in a year.
>
> On Thursday you wrote to the parish office.

Player chooses what was left unfinished: **a small standing order**, **a rented storage unit**, **a modest ordinary job offer**, or **a promised meeting with someone**.
**First autumn:** keeps one piece of paperwork from this unfinished choice.
**Winter:** prior decision produces a real message: old order fulfilled, storage billing closes, old job filled, meeting date passes. Not everything waits indefinitely for player.
**Spring/summer:** player chooses whether to correct one outstanding matter, reclaim a small deposit, keep a relationship open, or let it lapse; each with concrete time/material or communication consequence.
**September:** departure was not an objectively perfect gamble; what player built at the farm coexists with what they declined.
**Year-two echo:** last invoice/receipt or one ordinary message; no supernatural explanation or mandatory regret.
**Example:**
> 'The old shop filled the position in February. They wrote to say so. I sent back the key.'
This origin's ordinary stakes are real and complete.

## Significant cross-thread scenes

### The first severe winter evening (optional personal interior moment)
Use actual weather and location. An old acquaintance's letter, work note, or forwarded parcel may be **eligible** when truly delivered; player can read/respond now or later.
> The mail had dried by the stove.
>
> You moved it to the table to make room for supper.
>
> Outside the window, the wind turned.
>
> The letter was still there.
The letter's subject differs by origin; nobody is coerced into reading during a timed nighttime encounter.

### The parish letter in late May
The original `StoryAct.LETTER` must arrive exactly as coded. A prior-life thread may provide **a contextual contrast** (the reason to seek refuge vs the town's legal claim) but cannot rewrite, prevent, reschedule or improve it. This is an excellent opportunity for juxtaposition through two documents on the desk, never a forced lecture about feelings.

### First September reflection
The diary should devote **comparable narrative care** to chosen earlier-life developments and actual work at Crow Creek Hollow. One paragraph need not cover every chosen detail; meaningful scenes earlier carry much of the weight. Optional diary reflection remains truthful for old saves (no retroactive invented origin).

### Second autumn after a canonical ending
One postending origin correspondence or inspectable object can be revisited. Its status (ongoing, resolved, suspended, unanswered) is independent of which of `bell`, `elias`, `hollow` occurred, but optional language may acknowledge public events *only if sender could plausibly know* and player told them.
**Neither the past nor the current farm life is 'finalized' simply because the bell story has ended.**

## Three layers of story consequence for each origin

**Personal:** a past relationship changes (continued, renegotiated, ended), or a material obligation resolves.
**Practical:** small fair time/coin/resource choice **only when implemented and presented transparently**. Default can be mail response, not high-cost mandatory travel.
**Reflective:** one diary passage and one later remembered object/letter, conditional on actual chosen response. Do not narrate feelings.
A major origin should achieve at least **two of these three**. Decorative letter-only origins do not meet owner intent.

## Story implementation constraints — no five gigantic separate games

Suggested data model for later audit (illustrative, not existing code):
```
origin = {
  reason: "work" | "security" | "interrupted" | "curiosity" | "chance",
  prior_connection: "friend" | "family" | "colleague" | "former_household" | "private",
  departure_choice: "notice" | "finish" | "instructions" | ...,
  keepsake: "photo" | "notebook" | "hand_tool" | "postcard" | "none",
  winter_beat_seen: false,
  later_choice: "reply" | "settle" | "defer" | "release" | ...,
  later_outcome: "ongoing" | "resolved" | "unanswered",
  interlude_progress: 0,
  interlude_complete: false
}
```
- Exact keys and option enums TBD from save audit. Preserve **one concrete choice per stage**, don't expose a global origin morality index.
- Interlude always completes on a **new game**. Interrupted progress must **resume**, not skip. Pause and text speed allowed; no timed personal choices. Legacy saves may lack origin state and should remain loadable with honest no-origin fallback, not be retrospectively forced into an incompatible backstory.
- Avoid a full extra-town map: former life expressed through interlude scenes, letters, a retained object and 1–2 authored choices.
- Current game starts October1 with its existing tutorial. The prologue takes **no world-clock time or starting money**; it is emotionally important, not a survival tax.
- Use existing DiaryBook, Mail, and maybe a small table prop. No new romance system, trauma simulator, cross-country travel map, or full correspondence UI.
- The story can ask the player to continue reading through each mandatory beat but **cannot forcibly remove pause/exit/resume**.
- Each origin needs different **content and consequences**, not just different first paragraph followed by identical post.
- Original Rook main-story evidence, original three endings and permanent Wicker Cove fog remain completely independent.

## Show-don't-tell acceptance matrix

| Test | Evidence that it works |
| --- | --- |
| Initial feeling | Player describes who they were before, what changed, and why they answered notice |
| Distinct origin | A security player and a work-autonomy player encounter different winter situations |
| Midyear agency | Each origin presents a specific later choice that changes correspondence, obligations or material outcome |
| Continuity | Their chosen prior contact writes appropriately or stays silent; no invented relationships |
| Equality | A pragmatic/no-tragedy origin has an arc with equal beginning, complication and resolution opportunities |
| Gameplay respect | No missed first-day planting, first-night scare, Maren day4, fixed Davy or bell gates |
| Ending respect | After Rook ending, origin thread can continue or remain open in an intentionally player-selected way |
| Accessibility | No skip, yes pause/resume/read-speed and text accessibility |
| Retention | Player can mention one ordinary detail from origin and one from new home, unprompted |

## Recommended production order (pending owner approval)
1. **P1 script audit:** new-game route, text UI, pause/resume, save/flag logic, old saves.
2. **P1 creative selection:** confirm five origin strands or condense to 3 highly distinct and fully authored ones; names/details/scene text. **Do not** treat this draft as a finished screenplay.
3. **P1 prototype:** one mandatory interlude and 2 complete distinct origins, without shortcuts or gameplay stat advantages; all origins must be authored before claiming finished feature.
4. **P1 origin follow-through proof:** one winter development + one consequential spring decision for 2 chosen origins, one later diary/letter, then expand to five.
5. **P1 QA:** genuine player testing, control/pause/resume, five paths, no trauma forced, no town required, origin/status after all Rook endings.
6. **P2 polish:** extra scene variants and player-chosen correspondence details, only if they're materially useful.

## Task IDs
- `CCH-TWO-LIVES-001` — **P1 Design:** five fully structured life-before arcs plus one life-here interplay framework (this document).
- `CCH-TWO-LIVES-002` — **P1 editorial audit:** compare chosen origins to existing narrative voice/first-season pacing and source legal premises.
- `CCH-TWO-LIVES-003` — **P1 technical audit:** new-game, dialogue/book/mail/save mechanisms and interruption/resume, legacy saves.
- `CCH-TWO-LIVES-INTERLUDE-001` — **P1 gated implementation:** one mandatory scene system and approved origin scripts; source audit first.
- `CCH-TWO-LIVES-WINTER-001` — **P1 gated:** one proper winter complication per implemented origin, not random cosmetic postcards.
- `CCH-TWO-LIVES-MIDYEAR-001` — **P1/P2 gated:** one human decision about prior life with downstream practical and written effects per origin.
- `CCH-TWO-LIVES-RETURN-001` — **P2 gated:** September and year-two/postending truth-based echo with original three-ending compatibility.
- `CCH-TWO-LIVES-QA-001` — **P1 QA:** five origins, two different resolutions each, privacy/legacy, canon, full opening and long-play read.

**Last editorial principle:** The old life should never become a footnote that says 'this is who you used to be'. The player can be more than one person at the same time.

## 2026-11-14 — Full authored opening + winter screenplay available

[**ROAD_TO_CROW_CREEK_HOLLOW_BRANCHING_SCREENPLAY_DRAFT.md**](ROAD_TO_CROW_CREEK_HOLLOW_BRANCHING_SCREENPLAY_DRAFT.md) develops the five origin pathways into staged **original second-person scenes**, dialogue, individual practical choice options, a shared goodbye/person-or-no-person scene, selected keepsake, two road transitions, the farm-gate arrival and five distinct **first-winter** follow-through scenes with real later response choices. **Mandatory for all new playthroughs, no Skip, but pause/resume/back/read-speed support.** This screenplay is **editorial draft, not approved final narrative or implemented content**; later spring/summer screenplay is separately required. Exact town legal listing text remains owner review, and the source day1, original seventeen chapters/three endings and old save compatibility remain intact.
