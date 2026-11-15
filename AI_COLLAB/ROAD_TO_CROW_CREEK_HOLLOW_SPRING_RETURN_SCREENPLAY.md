# CCH-ROAD-SPRING-001 — Letters That Require an Answer
## Midyear Consequence Screenplay: The Player's Previous Life Remains in Motion

**2026-11-14, editorial draft. NOT approved in-game script, canon or implementation permission.** Continues the mandatory, non-skippable opening [ROAD_TO_CROW_CREEK_HOLLOW_BRANCHING_SCREENPLAY_DRAFT.md](ROAD_TO_CROW_CREEK_HOLLOW_BRANCHING_SCREENPLAY_DRAFT.md) and the five equal-weight origins in [TWO_LIVES_INTERWOVEN_ORIGIN_ARCS.md](TWO_LIVES_INTERWOVEN_ORIGIN_ARCS.md). This screenplay is intended to prove **the reason for coming is as important as the reason to stay**, not to turn the old life into decorative letters.

**World and scheduling constraints:** All five follow-through choices occur during routine spring/early summer when the player initiates reading/replying from an ordinary desk/mailbox/diary system after a letter arrives. **Never** use timed Davy night or override the original `StoryAct` day240 parish letter, `maren_book`, `vicar_register`, `post_hand`, three original endings, city fog uncertainty, original Oct1 game start, 420-second day or player saved stats. Old life is not the Rook mystery or a supernatural clue by default. The farm is town-held under current estate mechanics with later deed purchase; nothing here gives a deed by inheritance.

## Shared direction: a reply has practical consequences

**SCENE S0 — THE MAIL AND THE TABLE**

[On the day the origin-specific follow-up arrives; access when player chooses, without forced dialogue during nights.]

> The post was inside the mailbox.
>
> One envelope had a return address you knew.
>
> The paper was a little heavier than the usual notices.
>
> You put it on the table and opened it.

**Only narrate "address you knew" if prior contact or account is established; for no-contact curator use a plain official sender.** No forced subjective feelings. Keep all earlier choices distinct: never claim boxes exist on a `security_exit=forward` path, a person still writes if `contact=none`, or a former coworker reached an agreement that was never made.

### SCENE S-A — SECURITY: THE TWO BOXES

**Prereq:** `origin=security`, old housing departure route verified, winter mail received. Use a no-box alternate when `security_exit!=stored`.

> There was a charge for sending the two boxes.
>
> The price was written carefully under the address. There was also a date.
>
> "After that," the letter said, "I won't be able to keep them here."
>
> It wasn't a threat. There was simply no more room.

**Player choices, no hidden virtue score:**
- **"Pay to have them sent."** Cost shown in real coins, delivery due after stated delay, only if affordable; an optional pay-later arrangement can exist at clear terms. Delivered small memento/letter not a new free tool/stat.
- **"Ask for one more month."** Sender may agree once, with clear new date; response path closes after that, so choice has a cost without eternal punishment.
- **"Tell them to give the things away."** Sender acknowledges and resolves storage; player may choose whom or may simply let items go. Diary says items released, never claims grief.

**No-box route** if `security_exit=forward/extension`:
> The final account from your old room was enclosed. The amount was smaller than the one you had expected.
> 
> There was a line for your signature and a return date.

Choices: confirm/contest reasonable accounting with real evidence/leave as is if no action required. Outcome: settled or disputed account, no high-risk debt trap.

**Later consequences:**
- Shipment makes a specific old object inspectable in farmhouse only if art exists.
- Extension means a future clear deadline, but not loss of main-story resources by surprise.
- Release produces a single later note and closes that material thread.
- The deed's existing eventual purchase remains a **separate** question of current legal ownership.

**September factual lines** (conditional):
> "I paid to bring the boxes up. They are by the workbench now."
> "I told them they could give the boxes away. The account is closed."
> "The old account took another two letters. It is settled now."
Do not insert a note if player's record doesn't prove it.

### SCENE S-B — WORK: THE OFFER TO HELP AGAIN

**Prereq:** `origin=work`, winter old order-book note resolved or still awaiting reply. Former colleague **can manage independently**, and must not be emotionally dependent on farmer.

> They had worked out the Thursday figures.
>
> The note explained what was wrong. It was a number copied twice.
>
> Below that was another line.
>
> "There will be more of this at the end of summer. I could pay you to check the books if you're interested. No trouble if not."

**Three meaningful choices:**
- **"Take one clearly defined paid task."** Transparent time cost and fair payment; player chooses a specific day/fee or confirms task, rather than opening a permanent daily-duty grind. No invisible Smithing/carpentry bonus because origin selected work.
- **"Give them the method, not the labor."** Send practical instructions; colleague can do later work themselves. May become one late note of independence rather than payment.
- **"Decline and wish them well."** They proceed and hire someone else. A respectful goodbye can be genuinely final.
- **"Ask for more detail."** If UI supports, receive one explanation first; no infinite chain.

**Substantive difference:** income/time vs skilled transfer vs a deliberately ended work connection. In all paths, the former workplace continues; no punishment for not answering their request.

**September factual lines**:
> "I checked another page for them in June. They paid for my time."
> "I sent the method back. They wrote later that it worked."
> "I told them I couldn't take the job. Someone else did."

### SCENE S-C — HOUSEHOLD: THE THINGS THAT BELONG TO BOTH

**Prereq:** `origin=household`, selected relationship remains type-appropriate; no spouse/death/abuse assumption.

> A small parcel arrived with the letter.
>
> Inside was a key wrapped in a piece of cloth.
>
> "I found this with the things we never sorted out," the note said.
>
> "Do you still want it? I can send the rest if you tell me where."

**If winter player said don't send key:** the physical parcel **must not appear**. Instead, the sender writes:
> "I put the key away as you asked. I found the other things too. Should I keep them together?"

**Choices:**
- **"Send the rest of my things."** Could require explicit postage or space; sender sends only their agreed belongings, no implied betrayal.
- **"Keep the things we shared. We can write now and then."** Relationship continues on mutually agreed terms; not compulsory reconciliation.
- **"We should close the matter."** Decide what to return, what to keep, one factual closure; silence can be respected.
- **"I need more time."** Honest one-step defer; sender has their own needs and a reasonable later date.

**Meaning:** prior connection can endure, change or conclude. No romantic 'right' ending. If prior `contact=none`, the practical shared-property matter can be handled via ordinary written contact from the original household **only if player explicitly established a person existed**; private identity is not zero human history.

**September factual lines**:
> "We decided who would keep the books. That was the last thing left."
> "We still exchange letters. I wrote about the first spring planting."
> "I asked for more time. They agreed until autumn."
Only if chosen and true.

### SCENE S-D — CURIOSITY: WHAT THE PICTURE LEFT OUT

**Prereq:** `origin=curiosity`, chosen reason subtype + actual farm history. Do not assume meaningful town trip or forest log activities unless implemented.

> The picture was folded along the roofline.
>
> You set it beside a newer page in the diary.
>
> The roof was still there. The rest of the place had changed less than you expected.
>
> There was something missing from the picture, though. The sound of the wind at the back fence.

**If old friend/contact existed:** they ask for one truthful account of what the farmer has actually found. If none, the player decides whether to add a note in their own diary or send a non-named short note to a previously selected contact channel; don't create a random stranger who knows them.

**Choices, condition-checked:**
- **"Write about the first harvest."** Only if first crop was actually harvested; line reflects crop kind where source supports.
- **"Write about a repair I've finished."** Only when a real home stage/furnishing/repair state changed.
- **"Write about a place I actually went."** Forest edge, original trek or future Wicker Cove, only if entered. No objectively true fog account.
- **"I don't want to describe it yet."** Honored; player chooses to keep image, file it or make a neutral personal note without forced relationship.
- **"I was wrong about what this place would be."** Only if player explicitly selects that interpretation; text may record it without treating it as universal fact.

**Material change:** letter sent with one verified detail leads to different natural human response ("Sounds like work", "I can imagine the garden", etc.). If keeping it private, personal diary/picture annotation provides a meaningful written choice; not another blank or downgraded origin.

**September factual lines:**
> "I kept the advertisement. It showed the house before I arrived."
> "I sent them a picture of the new fields."
> "I wrote that the road was farther than it looked."
The second requires an actual mechanic for sending images and factual field change; substitute a text note if not built.

### SCENE S-E — CHANCE: THE LAST CLAIM

**Prereq:** `origin=chance`, specific old loose end is one of work offer, storage, order/deposit, missed meeting; variant-specific copy required.

**If old work offer:**
> "We hired someone in February. The work is going well. Thank you for your reply. The offer cannot be held, but you are welcome to write in future."

**If storage:**
> "The unit is paid to the end of the month. Let me know whether to forward the remaining contents or close it."

**If order/deposit:**
> "The item has arrived. Please confirm delivery or request the refund by the date printed below."

**If meeting:**
> "We missed you in the spring. If you want to speak again, write with a day that suits you. I can't promise I'll be free."

**Choices are specific, not forced universal:**
- Work: accept closure / request a future simple contact / decline follow-ups. No magically held offer.
- Storage: retrieve with known bounded costs / donate or dispose of contents / ask one brief extension.
- Order: fulfill and ship / request an explicit refund / leave order at pickup if fees are disclosed; no phantom money.
- Meeting: propose a new time / write what the meeting was for / decline. Other person's availability respected.

**Substantive consequence:** an item/money/contact settled or unresolved; farmer didn't merely read a history reminder. Personal stakes equal in literary attention even if no tragedy.

**September factual lines**:
> "They filled the job in February. I wrote back and closed the matter."
> "The old order came through. I had it sent to the farm."
> "We agreed to speak again. We haven't chosen a day."

---

## Common ending beat — A letter answered or deliberately filed

After chosen midyear action:
> You put the paper back into its envelope.
>
> Outside, there was work to do.
>
> The mail could go out tomorrow.

**Conditional:** if the player actually sent the letter, substitute "You left it by the door for the post." If not, text must not falsely claim reply was dispatched. No narrator assigning joy/relief/regret.

**All five origin arcs** must produce one later world response:
- practical shipment/inventory item or settled account
- paid job/time use or transferred instructions
- negotiated correspondence/shared property
- truth-based friend reply or diary annotation
- resolved, reopened or explicitly discontinued offer

## What this contributes to the Rook story (without hijacking it)
The current town-held farm later may be purchasable. The clerk's letter around day240 makes a demand in official voice. A player who has independently dealt with an old lease, workload, relationship, photograph or time-limited offer may read the parish letter against that experience. **The writing does not say their earlier choice caused the letter, gives them supernatural insight, or changes the vote conditions.**

In September, the diary uses a concise **paired passage**: one verified fact about former life, one about farm/people/woods. The player should not be required to choose "I'm happy here" or "I regret moving" to continue. At a later ending, the former-life contact does not mysteriously know the Rook events unless told through credible channels.

## Branch truth and save tests
1. Former person never assumed dead, evil, estranged or loved unless player explicitly defined relation or event.
2. A no-contact curiosity player has real internal origin story, not empty letters.
3. No boxes arrive if never stored or if player chose give away. No duplicate cash for refunds or paid work.
4. No player sends a photograph unless mechanism supports it. Descriptions can reference actual crop/house/woods only.
5. No letter says an agreed relationship continued if player chose closure. Deferred choices have real but nonpunitive deadlines.
6. The farmer begins Oct1 normally in all origin choices. Original first crop, Maren day4, Tin Lantern and first-night systems untouched.
7. Day240 Rook letter is original priority; new personal origin mail can be rescheduled a day with no lost choice, not crowded onto mandatory plot.
8. No changed original `maren_book`/`vicar_register` evidence, `post_hand` reveal, Davy night, bell or three endings.
9. Old saves without origin keys remain playable without invented backstories.
10. Save/load with pending origin response, choice selection and post-dispatch letter doesn't duplicate events.

## Tasks
- `CCH-ROAD-SPRING-001` **P1 editorial screenplay design** — this five-origin midyear decision and consequence set.
- `CCH-ROAD-SPRING-EDIT-001` **P1 audit** — replace conditional placeholders after earlier choices/actual saving syntax; ensure five scenes are each compelling.
- `CCH-ROAD-SPRING-PROTOTYPE-001` **P1/P2 gated** — one fully playable origin reply with single stateful consequence after owning/approving full mandatory opening.
- `CCH-ROAD-SPRING-QA-001` **P1 eventual** — test five origins and each meaningful outcome, save/load, late-May clerk letter priority and endings.
