# CCH-ORIGIN-003 — The Lives We Left Behind (implementation report)

**Status:** implemented for all five origins (21 routes); **stopped for owner and ChatGPT review.** Automated and
input-driven tests only; **no human has played it.** No September passage or Year Two echo is built: each route
leaves a factual September line and a saved outcome for that work.

Every scene, choice, answer, parcel, later letter and "no answer" outcome, in full: [CCH_ORIGIN_003_LETTERS.md](CCH_ORIGIN_003_LETTERS.md)
(generated from the game's own script by `tools/past_spring_letters.gd`).

## What a player sees

Once the winter letter is settled (answered and the answer received, lapsed, or a note written), the spring's route
is fixed from what the winter actually recorded. On its day the morning report says so ("The carrier brought two
boxes up the lane, with a letter.", "A personal letter has come in the mailbox.", or for the no-contact photograph,
"The photograph from the notice has slipped out of the diary in the desk."). The letter is in the same mailbox, with
its answers as rows under it, exactly as in the winter: reading and choosing take no time; a reply waits for the
next morning's post (and can be taken back until then, coins included); the sender's answer comes about six days
later. A parcel that came has an **Open** row under its letter. Paid work and the no-contact photograph are done at
the **desk** (its Diary tab), where the row states the hours, the clock times and the pay before anything happens.
The diary's **Notes** get a page in the player's hand ("post_spring") that grows only from what really happened.

## Calendar audit

Day 1 is October 1 (`MainGame._calendar_date`). Spring is days 152-243, summer 244-335, September 336-365.

| Day | Date | Existing | This sprint |
|---|---|---|---|
| 152-153 | Mar 1-2 | Spring Thaw; winter "no answer" outcomes | nothing (a spring route can't be made before the winter settles) |
| 160 | Mar 9 | — | E storage held to March 30: the yard's reminder |
| 166 | Mar 15 | — | **paid winter shipments arrive**: A boxes, E storage contents, E order |
| 175 | Mar 24 | — | C: the promised key, in a small parcel with the letter |
| 181 | Mar 30 | winter storage deadline | E storage: cleared on the 31st if nothing is done |
| 185 | Apr 3 | — | A deposit letter; E meeting "About April" |
| 190 | Apr 8 | — | A held boxes / papers; B the offer; C the shared things; D photograph (desk); E order held, storage papers |
| 195 | Apr 13 | — | D contact letter; E place filled, order resale, meeting (lapsed / closed) |
| 202 | Apr 20 | Planting Fair | untouched |
| 212 | Apr 30 | winter box / order deadline | A held boxes; E order held: the sender's terms on May 1 |
| 222 | May 10 | — | E storage renewed to May 31 |
| 232 | May 20 | — | A's single extension (only if the winter went unanswered) |
| **240** | **May 28** | **the parish letter** | **nothing arrives or lapses** (moved to day 241; tested for every route) |
| 243 | May 31 | — | E storage renewed: lapse on June 1 opens "held to June 30" |
| 264-266 | Jun 21-23 | Midsummer Heat | untouched |
| 306 | Aug 2 | — | E on next season's list: the August letter (by Aug 20) |
| 357+ | | Harvest Moon meeting, Davy, the bell | untouched |

Rules in code: a route's first scene comes on its date or at least 5 days after the winter settles (B's late
follow-up page can push its offer past April 8); a stage always leaves at least 7 days; the town's day 240 morning is
skipped for every arrival, answer, parcel, later letter and lapse.

## The five origins

| Origin | Winter outcome → spring route | Decision (and what each does) |
|---|---|---|
| **A** The Cost of a Room | `boxes=to_ship` → **boxes_arrived**: the two boxes come on day 166, paid in the winter, nothing more to pay; Open row | write that both came (closed) · ask them to send on anything that comes to the old room until end of summer (50 days later: a seed catalogue) · no answer (nothing more) |
| | `held` → **boxes_deadline** (by April 30) | ship (30) → carrier → boxes arrive 5 days after their answer · give away. **No extension**: they already asked for one and the sender said "not much past it". No answer → the sender gives them to the charity shop on May 1, as stated |
| | `held_unanswered` → **boxes_deadline_unanswered** | ship · give away · **one** extension to May 20 → final stage (ship / give away only); after May 20 they are given away |
| | `released` → **boxes_papers** (no parcel, no charge) | the shop wouldn't take papers with a name on them: post them (free; a packet arrives) · burn them. No answer → they keep them in a drawer |
| | forward / extension (no boxes) → **deposit** | the old room's deposit, 30 less 6 for a window catch: sign (24 back, once) · say the catch was loose (they check and share it: 27, once) · put it away unsigned (the money stays on account, recorded). Opening differs: letting office (extension, "your rent was settled"), forwarding renewed, or the address given with the notice |
| **B** Work That Belonged to Everyone | `explained` / `declined` / `sorted_without_me` → **offer** (opening respects each; for `declined` it acknowledges the boundary) | take one paid task (June sheets, 3 hours, 20 coins) → sheets by post → **desk**: "Check the June sheets (3 hours)", from/to times shown, refused after 23:00 → posted → 20 coins once · send the method → 40 days later "they balance" · decline → someone else is taken on · ask once what it involves → one answer, then take / method / decline only. Sheets not done in 21 days → they use their carbon copies |
| **C** A House With One Less Person | `to_send` → **things** + the key in a small parcel (day 175); `kept_by_them` (the screenplay's "I put the key away as you asked"), `let_go`, `put_away_unanswered` → **things**, no key | ask for your two boxes (20 coins; they keep the clock and shelf books) → boxes arrive · keep everything for now and write now and then → 60 days later an ordinary letter · settle it, they keep everything, closed · more time, until end of September (no further) |
| **D** The Place in the Photograph | contact (opening per winter answer, incl. unanswered: "I'll ask once more") → **friend** | crops · repair (house, or the inn roof with its own answer) · a place (Wicker Cove if visited, else the woods) · not yet · "it isn't what I expected" (an explicit interpretation the player picks). Only what is true is offered; the answer and diary keep what was told |
| | no contact → **photograph** (desk, no letters) | compare it with the farm now (only with a real house repair or harvest; lists them) · write what it left out ("the sound of the wind at the back fence") · fold it away without writing. A written note brings it back 90 days later: add what has been harvested since (only if more has) or leave it |
| **E** A Chance Before It Closed | seasonal: `closed` / `filled` → **work_closed** (the screenplay's "We hired someone in February"); `on_list` → **work_list** (Aug 2) | close · stay on next year's list · off the lists. August: not this year, stay on · off. No job is ever held; taking a place is not offered (the game has no way to leave the farm for six weeks) |
| | storage `to_ship` → **storage_arrived** (day 166, paid) | after opening: keep it all · some / all to the charity shop with the carrier (a receipt) |
| | `renewed` → **storage_renewed** (May 10) | send (30) · clear · one more month (5) → final stage. No answer → held to June 30 (the letter comes June 1, after the parish day) → cleared |
| | `held_unanswered` → **storage_held** (Mar 9, by Mar 30) | send (30) · clear · hold to end of April (5) → final stage. No answer → cleared |
| | `cleared` → **storage_cleared** | the yard won't dispose of personal papers: post (free) · shred. No answer → shredded, as they said |
| | order `to_ship` → **order_arrived** (day 166, paid) | keep · return within 30 days (6 carriage, 30 refund of its price, once; the parcel is marked returned) |
| | `refunded` → **order_resale** | the unsold item for 20 · no thanks. No refund ever again |
| | `held` / `held_unanswered` → **order_held** (by April 30) | send (24) · cancel and refund the 12 (once) · keep for collection until end of September (4). No answer → cancelled, 12 returned once |
| | meeting `spring` → **meeting_spring** | their availability: a Saturday in April, then away until autumn. April is too far, the autumn? · say it was to tell them you might move away · leave it |
| | meeting `lapsed` → **meeting_lapsed** ("once more, then I'll leave it") | the autumn · the purpose · leave it |
| | meeting `closed` → **meeting_closed** | not reopened: they are moving in June and send the new address. Write back with good wishes · keep the address · don't keep it |

Every route has: a spring development from its winter, the promise kept (or honestly absent), a decision with at least
two different saved outcomes, a later acknowledgment (the sender's answer, a parcel, a later letter or, for the desk
photograph, its return), a factual diary page, and a `september` line.

## Editorial adaptations (screenplay → game)

1. **S-A boxes.** The screenplay's April price letter is used for held boxes; for paid boxes (winter `to_ship`) the
   boxes simply arrive and the decision is the keeper's offer to send on later post. Its "one more month" exists only
   where the winter went unanswered (May 20): a sender who already said "not much past April" is not asked again.
   The September line "They are by the workbench now" is not used: no box is drawn in the house.
2. **S-A no-box route.** The screenplay's "final account" is the deposit (30, 6 kept for a window catch). The query
   is answered by the office checking its own move-in record (stiff, not broken) and sharing the cost.
3. **Released boxes** get the one credible new reason: papers a charity shop won't take (the screenplay's "single later note").
4. **S-B** uses its offer line ("I could pay you to check the books... No trouble if not.") with concrete terms
   (June sheets, three hours, 20 coins) so they are visible before confirmation. The "ask" is the bounded
   clarification. Payment comes once, with their answer.
5. **S-C.** The key comes with this letter only if promised in winter ("the key will come with the other things").
   The belongings are named plainly (boots, papers, books; shared: the clock, the shelf books). "Agree to limited
   correspondence" became "keep everything for now and write now and then"; "close" settles who keeps what.
6. **S-D.** "Write about a place I actually went" uses Wicker Cove only if visited (no fog), else the woods. The
   inn roof is a repair in the village, answered as such. "Sent them a picture" is not offered (no mechanism). The
   no-contact desk scene uses the screenplay's prose (folded along the roofline; the wind at the back fence).
7. **S-E.** Storage "one brief extension" costs 5 coins and is final. "Leave the order at pickup" became collection
   until the end of September for 4 coins. Seasonal work never offers taking a place. A closed meeting is not
   reopened: the new credible reason is the other person's own move.
8. **Common ending beat** ("You put the paper back...") is not a separate screen: each message line after a choice
   says only what was done ("You write your answer and leave it in the mailbox for the morning post.", "You fold
   the photograph back into the diary.").
9. Figures are new and modest (owner may change them in `scripts/past_spring_script.gd`).

## Deliveries (the reusable record)

`PastSpring.data.parcels[pid] = {state, promised, dispatched, due, received, opened}`; state is `promised` →
`dispatched` (with the carrier) → `received` (here, an Open row under its letter) → `inspected`, or `returned` /
`cancelled`. A parcel exists only when the winter paid for it (the route's `carrier`) or a reply sends for it; a
taken-back reply never creates one. Opening writes the diary line and the record; nothing goes in the pack, and no
text claims a box is standing in the house.

## Save and state

Save **version 20** adds `past_spring` (`PastSpring.to_save`). Older saves get `{}`; the record is made the first
morning on or after March 1 when the save's winter is settled, from the winter's own outcome, which is copied in
(`winter`, `wfacts`) so the route never changes afterwards. The winter record is only read. Legacy / "none" pasts
get nothing; a "missed" winter has no spring; a record first made more than 30 days after its route's date is
"missed". A saved record whose thread or route doesn't match its origin and winter is dropped and made again.

| Key | Meaning |
|---|---|
| `state` | `waiting` (route fixed, before its day) · `delivered` · `missed` (stand-ins `none` / `pending` are never saved) |
| `variant`, `thread`, `winter`, `wfacts`, `created`, `scheduled` | the route and what it was made from |
| `letters`, `decisions`, `replies`, `outgoing`, `answered` | as in the winter; ids are `s_first`, `s_<stage>`, `s_ack_<stage>`, `s_parcel_<pid>`, `s_follow_<choice>`, `s_lapse_<stage>`. A decision keeps the facts told with it |
| `stage`, `stage_day`, `stage_by`, `lapses` | the open stage, each stage's date, and which stages lapsed when |
| `outcome`, `matter` | what is settled, e.g. `{"boxes": "to_ship", "paid": 30}`, `{"work": "paid", "paid": 20}`, `{"belongings": "held", "until_day": 365}`, `{"order": "for_collection", "until_day": 365}`, `{"offer": "on_list", "until_day": 670}` |
| `parcels`, `credits`, `follows` | deliveries; coins credited once per `stage:choice` or `lapse:stage`; later letters/pages |
| `september` | the factual line for the September passage, set by the last thing that really happened |
| `noted` | (D photograph) the harvest count when the first note was written |

## Mailbox readability

The cause of the winter clipping: the ledger's detail page had no scroll, so a long letter grew the whole panel (it
pushed the HUD and footer), and the list's notes take no focus, so a pad or keys could not bring the last one into
view. Fixed in the shared panel code (`scripts/action_bar.gd`), not the mailbox alone, without restyling:
- the detail page's text is in a ScrollContainer; the button row (and an amount line) sits below it, always in view;
- mouse wheel scrolls it where it is; **PgUp/PgDn** and the **right stick** scroll it (or the list when the page
  fits); a **"PgUp PgDn / RS — Scroll"** prompt appears in the footer only when the page overflows;
- focusing a tab's last entry scrolls the list to its end, so the notes under it (deadlines) are readable;
- scrolling never presses anything; focus stays on the entry; nothing new takes focus.
menu_test (883 cases over every panel) and mail_test pass unchanged.

## Tests

| Kind | What | Result |
|---|---|---|
| Automated + input-driven | new `tools/past_spring_test.gd` (slot 9), each case playing the winter through PastPost's real mornings and answers and the spring one morning at a time: gating (legacy, none, missed winter, unsettled winter holds spring back, nothing before its date); every A route (paid boxes arrive uncharged, Open row, kept while unopened, send-on and the later catalogue; held: no second extension, ship 30 once, take back, parcel 5 days after the answer, lapse gives them away, no parcel; unanswered: one extension to May 20, final stage; released: papers only; forward and extension roads, renewed / ended / lapsed: no boxes anywhere, sign 24 once across a load, query 27, unsigned keeps the money on account); B three openings, terms in the letter, take → desk row with hours, clock times and pay, refused late, exactly 3 hours, no take-back of done work, 20 once across a load, method's later letter, ask → bounded page, decline, work lapse; C key only when promised, boxes for 20, private and partner senders, the screenplay's line, write → ordinary later letter, more time to Sept 30, close, boundaries line; D winter facts remembered, nothing claimable until true, village vs woods, answer and diary keep what was told, inn roof answered as the village, no-contact desk scene with no letters, compare only with real changes, the photograph returns, "more" counts only new harvests, kept without writing → nothing follows; E all four loose ends and every winter outcome (filled / closed / August list; storage paid, opened before deciding, receipt; renewed → month once → lapse after day 240 → cleared; held to Mar 30; cleared papers; order paid → return 30 once; refunded → resale, never a second refund; held → refund once across load; unanswered → 12 once; meeting availability, autumn, purpose, closed not reopened); honesty sweep over all 21 routes (death, romance, the mystery, assigned feelings), every route has September lines; nothing arrives or lapses on day 240 for any route; no sanity, skill, friendship or pack change; save/load at written, sent, dispatched, arrived; winter record untouched; v19 save gets its spring from its winter with nothing paid again; damaged and garbage records dropped; legacy save never; the real day (`_end_day`): the letter on day 190, reading costs no time, Notes page, the post takes the reply, parish letter on day 240; input: Space opens a parcel, A writes, Enter takes back, mouse click and its button, nothing disabled in focus, B and Esc close, a long letter overflows and shows Scroll, the page stays no taller than the list, the button stays in the page, PgDn scrolls and changes nothing, last entry brings the notes into view, Space at the desk does the work | **145 PASS, 0 FAIL** |
| Regression suite | `tools/audit_run_tests.sh` (now 25 suites incl. `past_spring_test`) | **25/25 pass.** menu_test 883 and mail_test 42 unchanged with the scrolling detail page; past_post_test 192 unchanged; `aoh_trek_check`'s 50 ms timing case passed on this run (it has failed under load before, R-P5-04) |
| In-engine captures | `tools/origin003_shots.sh` (19 shots via `tools/capture.gd spring=`), sheets and two masters in `art/style_tests/CCH-ORIGIN-003/review/` | 0 script errors. Found and fixed during review: the scroll area painted a dark box over the parchment; C's labels were too long for the list; C's later letter said "summer" when it could come in May; B's "June sheets" would have come in April (now the March sheets) |
| Human playtest | none | **not done** |

Input is injected (keyboard, Xbox buttons, mouse); no real controller hardware. Window sizes checked: 1280x720 and
1024x576 (captures). Story progression to the endings, Wicker Cove orders, Edith's repair, Nearwood and woodworking are
covered by the unchanged suites above (town_test, orders_test, inn_repair_test, woodwork_test, playable002_test,
evening_test); the three endings themselves were not replayed for this change, which doesn't touch StoryAct.

## Known limits

- No September passage, Year Two callbacks or ending afterword read these records yet (the data and lines are there).
- The B work happens at the desk as one action (time passes, needs drop as at a pastime); it is not a minigame.
- D's no-contact return is a desk page, not a letter; nobody else knows about it.
- The extension road's deposit letter and the forward road's differ only in sender and opening.
- Real controller hardware, screen readers and a human playthrough: not done.

## Files

New: `scripts/past_spring.gd`, `scripts/past_spring_script.gd`, `tools/past_spring_test.gd`, `tools/past_spring_letters.gd`,
this report, `AI_COLLAB/CCH_ORIGIN_003_LETTERS.md`, `art/style_tests/CCH-ORIGIN-003/`.
Changed: `scripts/main.gd` (instance, morning post, `spring:` actions, reset), `scripts/mail_system.gd` (read, keep),
`scripts/panel_rows.gd` (mailbox rows, desk rows, diary Notes), `scripts/save_system.gd` (v20), `scripts/action_bar.gd`
(scrolling detail page, list notes, Scroll prompt, PgUp/PgDn), `tools/capture.gd` (`spring=`, `dspring`, `tpick=`),
`tools/audit_run_tests.sh` (adds `past_spring_test`), `DESIGN.md`.
