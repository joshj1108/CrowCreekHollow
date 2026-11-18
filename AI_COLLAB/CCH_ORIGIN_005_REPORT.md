# CCH-ORIGIN-005 — The Second Year Remembers (implementation report)

**Status:** implemented for all five origins, legacy saves and saves with no September page; **stopped for owner and
ChatGPT review.** Automated and input-simulated tests only; **no human has played it.**

Every scene, every choice, what is written, the sender's answer and the diary after it, in full:
[CCH_ORIGIN_005_SCENES.md](CCH_ORIGIN_005_SCENES.md) (generated from the game's own code by
`tools/second_autumn_test.gd -- dump=...`).

## What a player sees

1. **October 2 of year two (day 367): one practical-life sentence** in the morning report, from one fact the save
   proves, by priority: Edith's inn repair (only with its record), the house's repairs, planks hewn, a walker's errands,
   Wicker Cove visits, or, for a farmer who stayed close, "Most of the valley past the gate is still unfamiliar." The
   same fact is kept as a diary page under Notes, *A year's work*. Once only. Legacy saves get it too (it is about the
   farm, not the past).
2. **October 7 (day 372): one scene from the life before**, chosen once from what the winter and spring really
   settled. A letter arrives in the mailbox (answered under it, or at the desk), or, where no letter is plausible, a desk
   scene waits in the desk's Diary tab ("Some papers from before are still in the desk"). Nothing opens by itself.
3. The player gives **one response**: a reply (left for the morning post; the sender's answer comes about a week later),
   a note (done at once, nothing sent), or opening a spring parcel that came and was never opened. Every choice says
   beside it what is written, what it costs, and that it is final. None is marked right.
4. The response goes into the diary (Notes, *A Year On*) in the player's hand, facts only. If the September page was
   written **before** the response, the entry quotes its last line, with when it was written, and adds one plain fact
   of how things stand now.
5. Ordinary play goes on: it takes no time, gives no skills, sanity, items, friendship or story progress, and coins move
   only as a letter states (coins the player encloses, or money that was already theirs coming back, credited once).

## Calendar (protected events untouched)

| Day | Date | What |
|---|---|---|
| 359 | Sept 24 | September page (ORIGIN-004). This sprint adds nothing that morning |
| 366 | Oct 1 | second calendar autumn begins; kept clear (ORIGIN-004's late note may fall here) |
| **367** | Oct 2 | the practical morning (first quiet morning from then) |
| 370 | Oct 5 | **Davy's night (20:00–01:00)**: nothing of this arrives, lapses or answers on 370 or 371 |
| **372** | Oct 7 | the scene from before (first quiet morning from then, once the spring is settled) |
| 393 | Oct 28 | the latest a sender's date can fall when the scene comes on 372 (C held, E collection: 21 days) |
| 395–397 | Oct 30–Nov 1 | **All Hallows and the bell**: nothing arrives, lapses or answers |

`SecondAutumn.busy(day)` covers 370, 371 and 395–397; any delivery, answer or lapse due then moves to the next clear
morning. The scene and the practical morning never share a morning with each other or with the September page's note.
The scene waits while anything from the spring is still open (an unanswered letter, an answer in the post, a parcel on
its way, a later letter still to come), so it never talks over the spring; a spring that hasn't even arrived is waited
for at most 60 days. A late save (loaded in, say, November) gets both on its next quiet mornings. Ignored, the scene
stays open indefinitely with no reminder, except where a sender has real terms (a date), which the letter states.

The story's dates, chapter gates, meeting requirements, Davy's window, evidence, bell and grove conditions and the
three endings are not touched: `story_act.gd`, `mystery.gd`, `night_system.gd` and `ending_screen.gd` do not read this
record (the test checks), and nothing here writes the story.

## The five continuations (16 routes)

Chosen by `SecondAutumnScript.pick` from the winter outcome (`PastPost`), the spring outcome, parcels and follow-ups
(`PastSpring`) and the interlude (`OriginState`). Letters only where a sender plausibly writes; otherwise the desk.

### A — The Cost of a Room
| Route | When | Scene | Choices (outcome) |
|---|---|---|---|
| `a_deposit` (letter) | spring deposit left on account | the yearly statement: 24 coins still in the player's name, nothing owed | sign and send back (the 24 coins come with their answer, once) · tell them to close it and keep the balance · file it unsigned (stays on account) |
| `a_send_on` (letter) | the keeper agreed to ask at the old door until the end of summer | they stopped in August, as they said; the seed catalogue named only if it came | have them give the new tenant the farm's address (a forwarding arrangement) · say there's no need · keep the letter unanswered |
| `a_papers` (letter) | the keeper kept the papers in a drawer (an open matter) | turning out drawers before winter; "I won't do anything until you do" | post them (the papers come with their answer) · the stove · keep them a while yet |
| `a_desk` (desk) | everything else, incl. no spring | the envelope with the two notices (the interlude's "One was no longer useful. You kept it anyway."), what really became of the old room's things (account closed / boxes opened, or **still shut** / given away / forwarding ended), the house now, the deed as it stands | open the boxes or the packet (only if they came and are shut) · file the old room's papers with the farm's · put the rent notice on the fire · leave it |

A settled account gets no new debt. Boxes that never came are never "in the house". Ownership is never claimed unless
the deed is paid, and the deed is stated as a fact, not as belonging.

### B — Work That Belonged to Everyone
| Route | When | Scene | Choices |
|---|---|---|---|
| `b_paid` (letter) | the March sheets checked and paid | the year's accounts: the slip for the 20 coins, for their records; the manager asks whether they may ask again (left out entirely if the player left with a boundary) | they can ask, case by case · the March sheets were the last · file the slip without answering (boundary version: thank them · file it) |
| `b_method` (letter) | the method was sent | the method still works; the new person learned it from the letter; "I don't need anything" | it's theirs now · write if it stops working · keep the letter |
| `b_closed` (letter) | declined, or the sheets sent back | a respectful closing note: the summer hire stayed; the instruction sheet is still used (only if one was left); "No need to answer" | good wishes · keep the note · don't keep it |
| `b_desk` (desk) | never answered, or let the sheets lapse; no spring | the old job's letters, how the job was left (the interlude), what happened in spring, planks hewn here (the bench's count) | write a short line closing it (only if a letter came) · file the letters · leave them |

No recurring remote work, no new paid task, no skill or reputation change.

### C — A House With One Less Person
| Route | When | Scene | Choices |
|---|---|---|---|
| `c_held` (letter, **dated**) | the player asked them to keep everything until the end of September | September has passed; they need the cupboard; send the boxes (20 coins) or the charity shop, by a date 21 days on; if no answer, the charity shop (their stated terms) | send the boxes (20 coins; they arrive with the answer, shut until opened) · give them away · *(no answer: they go, as said)* |
| `c_letter` (letter) | "now and then" correspondence | an ordinary letter: a year, near enough; the plum tree; the boxes in the hall cupboard | write back about the farm (the house and field as they are) · ask for the boxes now (20 coins) · say you'll stop writing for a while |
| `c_unanswered` (desk) | never answered in spring | their letter in the desk; the boxes in their cupboard; the keepsake | write for the boxes (20) · write that they can give them away · leave it |
| `c_keepsake` (desk) | closed, settled, sent; no spring | what was settled (or the boxes **still shut**, the key still wrapped), the keepsake from the case, the house | open what came and is shut · per keepsake: photo out / back; tool by the door / back; postcard line finished in pencil (not sent) / left unfinished; notebook line about the house / back; none: a line in the diary · leave it all |

A private relationship is never named or explained (sender "someone at the house you left"). Closed contact is never
reopened by a letter; it gets the keepsake at the desk. No reconciliation or emotional closure is written.

### D — The Place in the Photograph (every player, contact or not)
`d_photo` (desk): the photograph from the notice, what was written beside it in spring (or that nothing was; or that the
player wrote to the person who saw them off, and about what), the picture ("half the house behind trees, a fence nobody
had mended, a patch of open ground"), then **a year on**: the house now, the field's real harvest, the woods or Wicker
Cove only as far as they've been walked, Edith's repair only with its record.
Choices: add a factual note beside it (built from those facts) · file it with the farm notice · leave it as it was;
**with contact**, also copy the note into a letter: their answer refers to exactly what they were told in spring (the
crops, the repair, the place, "you'd rather not describe it yet", or "I'd stopped expecting a letter"). With no contact,
nobody is made up. No prophecy, no Rook connection, nothing about the fog.

### E — A Chance Before It Closed
| Route | When | Scene | Choices |
|---|---|---|---|
| `e_collect` (letter, **dated**) | the order was kept for collection until the end of September (not collected) | as agreed, it's still there; send it (balance and carriage, 24) or cancel (deposit 12 back), by a date; if no answer, cancelled and the deposit sent (their terms) | send it (arrives with the answer, then unwrap) · cancel and refund |
| `e_meeting` (letter) | they'd agreed to try in the autumn | they're back; a Saturday in November, where they live, nothing later; or write | say you can't come and write what it was for · ask to write now and then · leave it there (no trip is ever asked) |
| `e_desk` (desk) | everything else, incl. no spring | the notice taken out on the Thursday; what became of the chance, told by its outcome (seasonal work starting without them, the list "they write in August", the unit cleared / cartons kept / **still shut**, the order kept / returned / cancelled, "You never met", a kept address); the house and field | open what came and is shut · on the list: keep their letter for August / write to come off it · a kept address: write a short line · write down where it stands · put the notice away · leave it |

A closed opportunity stays closed; a list the employer said they'd write about in August gets no October letter.

## The September page, read against now

`FirstSeptember.reflection()` and its saved words are read, never written. When the response is made, if the page was
written before it, the entry adds:
- the quote: *At the end of September I wrote, "…"* — or, if it was finished in October or later, *On October 15 I
  finished the year's page with, "…"* (never "at the end of September");
- one fact by closing: **finish** — the house finished since / another round done / as it was, the work still there /
  already restored then (and crops brought in since); **keep** — "This is one of the things I kept." or "This one I
  closed." (from the response itself); **unknown** — "It is the next year now. This letter is part of what it has
  brought." (no fear, no indecision); **unsettled** — "This was one of them. It is settled now." / "This is still one
  of them." / "This wasn't one of the things still open then." / "Nothing from before was still open when I wrote it."
  (from the record's open matters then and the response now); **stay** — "I'm still here, N days after I first came up
  the lane." (no claim of a permanent commitment).
If the page was written after the response, or never, nothing is quoted and the scene works the same. The scene record
also keeps the closing as it stood on the scene's morning (`reflection`), for later work.

## Save and state

Save **version 22** adds `second_autumn` (`SecondAutumn.to_save`); a v18–v21 save gets `{}` and the scene is chosen on
its own morning from the save's records. A legacy or "none" past never gets a scene; a record for another origin, an
unknown route or a malformed one is dropped (the practical morning is kept on its own). JSON floats come back as ints.

| Key | Meaning |
|---|---|
| `v` | record version (1) |
| `world` | `{}` or `{day, id, line, diary}`: the practical morning (`id`: `inn`, `house:N`, `hewn`, `asked:<walker>`, `cove`, `farm`) |
| `route` | the scene's id (one of the 16 above), chosen once |
| `origin` | the origin it was chosen for |
| `medium` | `mail` or `desk` |
| `state` | `delivered` (waiting), `answered`, or `lapsed` (a sender's date passed) |
| `delivered`, `read`, `by` | the scene's morning; the day its letter was read (-1); the date to answer by (-1: none) |
| `prior` | what it was chosen from: winter outcome, spring outcome, parcel states, contact (`named`/`private`/`none`, never who), keepsake |
| `reflection` | the September closing as it stood that morning: `{}` or `{id, written}` |
| `choice`, `kind`, `answered`, `keeps`, `settles`, `said`, `text`, `refl`, `paid` | the response: its id, reply/note/open, the day, whether it keeps a connection / settles an open matter, the diary line, what was written, the two September lines (frozen), coins enclosed |
| `ack` | `{}` or `{due, delivered, title, text, diary, note, pay, parcel}`: the sender's answer |
| `parcel` | `{}` or a delivery the answer brought: `{…texts, state: received/inspected, received, opened}` |
| `credits` | `ack` / `lapse` → coins credited (once ever per key) |
| `lapse` | `{}` or `{day, text, diary}` |

Query API for CCH-ORIGIN-006: `route_id()`, `state()`, `answered()`, `choice()`, `world_moment()`, plus the record's
`keeps`/`settles`/`prior`. Winter, spring and September records are read in place, never copied whole.

## Tests

| Kind | What | Result |
|---|---|---|
| Automated + input-simulated | new `tools/second_autumn_test.gd` (slot 9; each case plays the winter and spring through PastPost's and PastSpring's real mornings and answers): dates (367 once, 372 once, nothing on 359/370/371/395–397, late save, a spring still open is waited for, ignored for months with no reminder); all 16 routes from their real pasts, **every choice of every route played** (its diary line, its answer, coins exactly as written, parcels only with the answer and shut until opened, opened once); A account settled → no new debt, boxes shut vs opened vs never came, the deed; B paid / boundary (no request) / method / declined / unanswered with planks; C held / letter / unanswered / closed / private (no who, no why) / sent-but-shut / nothing kept; D no contact (nobody made up), against today's facts, untouched, contact answer quoting what was told, unanswered; E collection / meeting (no trip) / list (no contradicting letter) / closed offer / storage shut / address kept / cancelled (no parcel); every September closing, unwritten, written late (dated), written after the answer (not claimed), never rewritten; deadlines, lapse by terms, deposit once across reloads, refused without coins; save/load before, during and after, later farm changes never alter what was written; v21 save; garbage, another origin, unknown route, half-answered record; legacy and no-interlude (no past), missed winter (a scene from the road only); the real `_end_day` from day 362 to 399: the morning and the scene on their days, nothing on Davy's day, the morning after or around All Hallows, at 20:00 on Davy's day nothing is open and he can be found, **the story's state identical with and without a past from the same saved morning**; source checks that the story, nights and endings never read this and this never writes the story, sanity, pack or friendship; input: desk with focus, Space answers, nothing disabled in focus, Esc closes, Xbox A answers, B back one level, mouse click then its button, mailbox answer, clearing read letters, J opens the diary at the entry under Notes, which doesn't scroll | **208 PASS, 0 FAIL** |
| Regression suite | `tools/audit_run_tests.sh` (now 27 suites incl. `second_autumn_test`), logs in `art/style_tests/CCH-ORIGIN-005/logs/` | **27/27 pass** in the parallel run (incl. `aoh_trek_check`'s timing case, which failed under load on earlier sprints). menu_test 883, save_test 66, mail_test 42, past_post_test 193, past_spring_test 145, first_september_test, interlude_test 101 unchanged. `diary_fit` 43 pages, 11 scrolling: **identical to the committed baseline** (all pre-existing pages; this entry's fit is checked by the new test) |
| In-engine captures | `tools/origin005_shots.sh` (full-size shots via `tools/capture.gd autumn=`, BEFORE shots from a HEAD worktree), four sheets and four masters (75%, 75%, 75%, 72%) in `art/style_tests/CCH-ORIGIN-005/review/` | 0 script errors |
| Human playtest | none | **not done** |

Input is injected (keyboard, Xbox buttons, mouse); no real controller hardware. In the real-day case the original
story, on an artificial save (letter shown, orchard done, nobody facing the night visitor), loses Davy by its own rules
and reaches its existing "hollow" ending by neglect; identically with and without a past.

## Editorial adaptations

1. **Two dated letters** (C held, E collection) use the senders' own earlier terms: the dates agreed in spring had
   passed, so the letter asks once more with a bounded date and says what happens otherwise (the charity shop; the
   order cancelled and the deposit returned, as the shop's April letter said). These are the only deadlines.
2. **The seasonal list (E)** gets no letter: the employer said they write in August, so an October letter would
   contradict them. The desk scene states the season starting and the list instead.
3. **Deliveries come with the answer**: papers posted, boxes or an order sent arrive with the sender's answer a week
   later (a parcel row under it, shut until opened), so nothing is in the player's hands before it has come.
4. **The diary entry is where the September line acts**, for every route alike, so the same moment differs only by the
   closing chosen (sheet 4 shows "keep" and "unsettled" on the same scene). The desk also shows the September line
   beside the scene while it waits.
5. **The world moment** is a morning sentence and a Notes page rather than resident dialogue: no character is given
   knowledge or a line they haven't earned, and no schedule changes.
6. **Davy is not mentioned** anywhere in this sprint's text; his scene and outcomes stay the story's own.

## Known limits and deferred

- No resident acknowledges the year (the world moment is narration); the "Spare Chair" and other Year Two design
  candidates are not built.
- Origin outcomes do not reach the endings or the afterword (CCH-ORIGIN-006).
- One scene per save: a route's later life (e.g. writing again after "case by case") is recorded but has no further
  scene.
- The detail panel for a long desk scene scrolls (PgUp/PgDn); the full text is in the scenes document.
- No new art, sound or UI framework; real controller hardware, screen readers and a human playthrough: not done.

## Files

New: `scripts/second_autumn.gd`, `scripts/second_autumn_script.gd`, `tools/second_autumn_test.gd`,
`tools/origin005_shots.sh`, this report, `AI_COLLAB/CCH_ORIGIN_005_SCENES.md`, `art/style_tests/CCH-ORIGIN-005/`.

Changed: `scripts/main.gd` (instance, reset, morning, `autumn:` action), `scripts/panel_rows.gd` (mailbox rows, desk
rows, Notes pages), `scripts/mail_system.gd` (read, keep while waiting), `scripts/save_system.gd` (v22),
`tools/capture.gd` (`autumn=`, `dautumn=`, `dworld`, `mpick=^`/`tpick=^`), `tools/audit_run_tests.sh` (adds
`second_autumn_test`), `DESIGN.md`.
