# CCH-ORIGIN-002 — The Past Doesn't Stay Still (implementation report)

**Status:** implemented for all five origins; **stopped for owner and ChatGPT review.** Automated and input-driven
tests only; **no human has played it.** Spring/summer follow-through (CCH-ORIGIN-003) is not built.

Every letter, reply, answer and "no answer" outcome, in full and readable: [CCH_ORIGIN_002_LETTERS.md](CCH_ORIGIN_002_LETTERS.md)
(generated from the game's own script by `tools/past_post_letters.gd`).

## What a player sees

On **January 12 of the first winter (day 104)** the morning report says "A personal letter has come in the mailbox."
The letter is in the ordinary mailbox by the east gate, beside the tax bills and receipts. Opening the mailbox reads
it (no time passes; the panel holds the clock as every panel does). Under the letter, its answers are listed as rows:
the reply's own words show in the detail page, with any coins it encloses, and a note gives the date to answer by
(February 28). Choosing **Write it** leaves the reply in the mailbox; the **next morning's post takes it** (until then
**Take it back** undoes it, coins included). About **six days** after it goes, the sender's answer comes. A factual
page in the player's own hand is added to the diary's **Notes**, and grows as things actually happen.

If nothing is sent by February 28, on March 1 the sender acts on their own stated terms (or, where the letter
already closed the matter, nothing more comes). The player is never forced to answer and loses nothing for waiting.

## Timing audit

Day 1 is October 1 and months have their real lengths (`MainGame._calendar_date`). Winter is days 62-151.

| Day | Date | What is there | Letter timing |
|---|---|---|---|
| 82 | Dec 21 | The Longest Night (dread) | avoided |
| 93 | Jan 1 | Quarterly tax bill + Winter Feast | avoided |
| **104** | **Jan 12** | — | **letter arrives** (`PastPost.LETTER_DAY`) |
| 140 | Feb 17 | — | last day a first letter can still arrive (`LAST_DELIVER`) |
| 150 | Feb 28 eve | Maren's minute book becomes available (a folk scene, not post) | untouched |
| 151 | Feb 28 | end of winter | **answer-by date** (`ANSWER_BY`) |
| 152 | Mar 1 | Spring Thaw (a crop effect) | "no answer" outcome, if any |
| 240+ | | Parish letter, register, postman's hand, Davy, bell | untouched (checked by test) |

The parish letter (day 240), the tax and clerk letters, Agnes's pages and the postman's scenes run exactly as before:
the new post is added after them in the same morning routine and uses its own letter ids.

## The five threads (screenplay W-A…W-E)

| Origin | Variant (from the road) | Answers | Real state change |
|---|---|---|---|
| **A** The Cost of a Room | `security_exit=stored`: "About the two boxes" (screenplay text) | ship (30 coins) · more time (to end of April) · let them go | boxes `to_ship` (paid, arrive in spring) / `held` until day 212 / `released`; no answer → held to end of April |
| | `forward` / `extension`: "Forwarded post" (no boxes anywhere) | renew forwarding (12 coins, to end of August) · let it end | `renewed` / `ended`; no answer → `lapsed`, account closed |
| **B** Work That Belonged to Everyone | `work_exit` sets the opening line (finish / instructions / boundary); W-B's Thursday totals | short explanation · ask which page · can't take it on | "ask" brings **one** follow-up (page 41) with only explain / decline; `explained` / `declined`; no answer → they find it themselves (`sorted_without_me`) |
| **C** A House With One Less Person | sender named only as far as the player named them (private → "someone at the house you left"); "A line will do" only if *this* person was told "no plans" | ask for it · keep it · no need · **don't reply yet** | key `to_send` (comes with their other things, spring) / `kept_by_them` / `let_go`; defer is recorded and the other answers stay open; no answer → `put_away_unanswered` |
| **D** The Place in the Photograph | contact → "Did it look like the picture?" (parting words remembered: promise / invite / boundaries); **no contact → the town office's correction to the notice** | crops · a repair · the woods · hard to put into words (contact); diary notes beside the photograph or a line to the office (no contact) | `told` / `noted` with the exact facts told; the answer and diary speak only of those, even if the farm changes later |
| **E** A Chance Before It Closed | `chance_loose_end`: seasonal place / storage unit / order / meeting | work: close · stay on next season's list. storage: renew 15 · send 30 · clear. order: send 24 · refund deposit · hold. meeting: close · try again in spring | as listed; the order's 12-coin deposit is the player's (stated in the letter) and comes back once with the answer; no answer → each sender's stated terms |

**Verified facts (D).** Crops: the most-harvested crop kind (`stats["crop_<kind>"]`). Repair: the house's recorded stage
repairs (`woodwork.repairs["house_N"]`), else boards mended, else (friend only) Edith's inn roof. The photograph's
note accepts only the house itself. Woods: Nearwood trips, else a finished trek, else the walk to the wood's edge
(which says only "walked out to where they begin"). Rows for things not done are hidden, with a note saying what is
not yet true. Nothing supernatural is in any letter; the test checks every variant for fog, crows, bell, Rook, Agnes,
residents' names, death, romance and assigned feelings.

## Editorial adaptations (screenplay → letters)

1. W-A gives no figures; the shipping cost (30), forwarding renewal (12), storage (15 / 30), order balance (24) and
   deposit (12) are new and modest (a day or two of stand sales by winter). Owner may change them in
   `scripts/past_post_script.gd`.
2. W-A for `forward` and `extension` ("an equivalent forwarding-account closing letter") is new text: a post office
   (forward) or letting office (extension, which also confirms the agreed extra month).
3. W-B's follow-up page ("page 41, eleven short") and the answer ("one delivery went in twice") are new; the cause
   matches the spring screenplay's "a number copied twice". The player's explanation is authored text.
4. W-C's "ask for it" answer says the key will come *with the other things*, so the spring screenplay's parcel
   (S-C) can deliver it; nothing appears now. "No need" is answered plainly ("I won't keep it for you, then").
5. W-D no-contact: the screenplay offers "a notice correction or the original folded photograph"; both are used: the
   office's correction arrives, and the player's answer is a note beside the photograph (or a line back to the office).
6. W-E's generic "Thank you for letting me know" was dropped where the player never wrote to them.
7. Each sender's "no answer" letter is new, in their own practical terms, never a penalty.

## Correspondence states and save keys

Save **version 19** adds `past_post` (`scripts/past_post.gd`, `PastPost.to_save`). Older saves get `{}`, rebuilt
from the save's origin on load: `legacy`/`none` → nothing; a save first seen after day 140 → `missed` (no letter).

| Key | Meaning |
|---|---|
| `v` | record version (1) |
| `state` | `none` (no known past) · `waiting` (scheduled) · `delivered` · `missed` |
| `thread`, `variant` | `OriginState.thread()` and the variant id (`boxes`, `forward`, `extension`, `finish`/`instructions`/`boundary`, `key`, `friend`/`notice`, `work_offer`/`storage`/`order`/`meeting`) |
| `scheduled` | the delivery day (104) |
| `letters` | `[{id, day, read}]`: `first`, `page` (B's follow-up), `ack` (their answer), `lapse` (their last word); `read` = day the mailbox was opened with it (−1 unread) |
| `decisions` | `[{stage, id, kind, day}]`: every choice made, including `defer` and `take_back` |
| `outgoing` | the reply written and not yet answered: `{stage, id, written, sent, coins, facts}`; `sent` −1 until the morning post |
| `replies` | every reply the post actually took |
| `answered` | stage → the day the sender's answer (or follow-up) came |
| `stage`, `stage_day` | the open stage (`first`, `page`) and when it opened |
| `lapsed` | the day the "no answer" outcome happened, or −1 |
| `matter` | `pending` · `open` · `arranged` · `awaiting_sender` · `resolved` · `closed` |
| `outcome` | what is settled for later scenes, e.g. `{"boxes": "held", "until_day": 212}`, `{"key": "to_send"}`, `{"told": "crops"}`, `{"order": "refunded", "returned": 12}` |
| `facts` | exactly what the player told (crop, repair, woods ids and words) |
| `credited` | coins a sender has returned (credited once) |
| `note_day` | the day a photograph note was written (D, no contact) |

Mailbox letters keep a `post` key (the letter id above) through `MailSystem.migrate`. The diary page id is
`post_winter`. Coins: paid once when a reply is written, given back once if taken back before the post, deposits
credited once on the answer's morning; tests cover repeats across save/load.

**For CCH-ORIGIN-003:** read `MainGame.past_post.rec()` — `outcome`, `matter`, `facts` and `until_day` say what
spring must honour: boxes / storage contents / an order `to_ship` (paid, not yet arrived); a key `to_send` or
`kept_by_them`; boxes or an order `held` until April 30 (day 212; note the parish letter is day 240); storage
held to March 30 (day 181); B's figures settled either way (S-B's prerequisite); D's `told`/`noted`; E's
`on_list` (August) and meeting `spring`.

## Tests

| Kind | What | Result |
|---|---|---|
| Automated + input-driven | new `tools/past_post_test.gd` (slot 9): timing and gating (before day 104, once only, legacy/none never, late first sight `missed`, mid-winter old save); every origin and variant gets only its own letter; A boxes vs no-boxes, coins once, take back, unaffordable refused, more time / ship / release / lapse; B each exit's opening, ask → bounded page → explain / decline, late ask gets its own two weeks; C private and partner senders, boundaries line only for the right person, defer then answer, defer then lapse; D nothing claimable until done, real crop named, told facts kept after the farm changes, inn roof vs house, wood's edge wording, parting words, no-contact correction and notes, office reply; E all four loose ends, refund once (also across loads), lapses; honesty sweep of all text; no sanity/skill/friendship/pack change; save/load at written, sent and answered; v18 and legacy saves; damaged records; the real day (`_end_day`): Jan 1 tax bill still arrives, the letter on day 104, reading costs no time or food, clearing keeps the pending letter, Notes page in the player's hand, post and answer in the morning report, the parish letter on day 240; the mailbox driven by Space, Enter, Xbox A and B, Esc and a mouse click, clock held, nothing disabled in the focus path | **all PASS** (see the board for the count) |
| Regression suite | `tools/audit_run_tests.sh` (now 24 suites incl. `past_post_test`) | see the board entry: `aoh_trek_check`'s 50 ms timing case is the only failure and fails the same way on the baseline run made before any change |
| Human playtest | none | **not done** |

Not covered: real controller hardware (input is injected); screen readers; window sizes other than 1280x720; a full
year of play through the real day for every origin (the real-day path is run for origin A; the others are driven
through the same `PastPost._morning` the day calls).

## Known limits / incomplete consequences

- **Nothing physical arrives yet.** Boxes, storage contents, an order and the household key are recorded as coming
  in spring; their arrival (and any item or inspectable object) is CCH-ORIGIN-003's job.
- A diary record longer than a page continues on the next page (", continued") rather than scrolling.
- The mailbox's notes (answer-by date, "not yet" list) sit under the list and are cut off at the bottom when a
  letter has five or more rows; the list scrolls, but the last note can need a scroll to read.
- D's no-contact "follow-up" for a diary note is one morning-report line ("The photograph is still on the desk…")
  plus the office's routine letter only if the player wrote to it; there is no second letter.
- Winter only. No spring/summer scenes, September passage or year-two echoes.

## Files

New: `scripts/past_post.gd`, `scripts/past_post_script.gd`, `tools/past_post_test.gd`, `tools/past_post_letters.gd`,
this report, `AI_COLLAB/CCH_ORIGIN_002_LETTERS.md`, `art/style_tests/CCH-ORIGIN-002/` (shots, crops, sheets, three masters).
Changed: `scripts/main.gd` (PastPost instance, morning post, `post:` actions, reset on new game),
`scripts/mail_system.gd` (read hook, keep pending letter, `post` key kept), `scripts/panel_rows.gd` (reply rows,
diary Notes), `scripts/save_system.gd` (v19, `past_post`), `tools/capture.gd` (`past=`, `pfacts=`, `pans=`, `pans2=`,
`pflow=`, `mpick=`, `dpost`), `tools/audit_run_tests.sh` (adds `past_post_test`), `DESIGN.md`.
