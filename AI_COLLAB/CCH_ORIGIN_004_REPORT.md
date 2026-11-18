# CCH-ORIGIN-004 — The First September: "One Year on the Road" (implementation report)

**Status:** implemented for all five origins and for legacy saves; **stopped for owner and ChatGPT review.**
Automated and input-simulated tests only; **no human has played it.**

Every page the test plays, with the closing lines offered for each, in full: [CCH_ORIGIN_004_SEPTEMBER.md](CCH_ORIGIN_004_SEPTEMBER.md)
(generated from the game's own code by `tools/first_september_test.gd -- dump=...`).

## What a player sees

1. On the morning of **September 24** (day 359) the morning report ends: *"It is almost a year since you first came
   up the lane. There is a blank page at the back of your diary."* The diary's seal shows a new page. Nothing opens.
2. The diary (J, or the desk) has a new section tab, **"One year"**, headed *One Year on the Road*, in the player's
   handwriting. It is put together each time it is read, from the save, so it is true on the day it is read. Its last
   page, until it is finished, says where the last lines are written.
3. At the **desk** (the Diary tab), the row *One Year on the Road* shows the whole page (it scrolls), and under it the
   closing lines, each a row with **Write it** (the list shows a short name, e.g. "Things not settled yet"; the whole line
   shows beside it). Choosing one takes no time.
4. The chosen line becomes the page's last paragraph. From then on the page is kept exactly as written: later work on
   the farm, a parcel opened, a reload or a new year never changes it. The desk row says "Written" and when.

It never opens itself, never closes, costs no time, gives nothing (no coins, sanity, skills, items or friendship), and
nothing in the story reads it.

## Calendar

Day 1 is October 1. September is days 336-365; the Harvest Moon is day 357 (Sept 22); StoryAct's meeting fallback
runs on the first morning after day 357 (day 358 on a normal save). The page opens on **day 359 (Sept 24)**, the
design's "Sep 23-30: A Year at the Farm" window, after both. The note is never given on the Harvest Moon's morning
(an old save loaded that day). If ignored, the page stays writable indefinitely; its opening says *"It's a year now"*
from Oct 1 (day 366) and, after Oct 7, *"It's more than a year … I meant to write this in September."*
Untouched: the parish letter (day 240), the mill meeting, the Harvest Moon, Davy (day 370), All Hallows, all 17
chapters and the three endings (the test checks StoryAct's dates and that neither `story_act.gd` nor `mystery.gd`
reads the page).

## How the page is made

Three parts, each from verified state only (`scripts/first_september.gd`; words in `scripts/first_september_script.gd`).

**A. The life before** (only for a known origin; a legacy save has none).
- The opening uses the interlude's own scenes and the road actually taken: A the old room's exit (more time / forwarding
  card / two boxes kept) and the two notices in one envelope; B how the job was left and the light turned off; C who the
  house was shared with and why, **only as far as the player told it** (private stays "someone", with no reason given),
  and the shorter list of things to move; D the photograph in the notice and what they hoped to find; E the Wednesday and
  Thursday of the closing date and what was left unfinished.
- Then the spring's own factual line (`PastSpring.september()`, the screenplay's September lines), **checked**:
  - a parcel paid for but not yet here is "with the carrier … hasn't come yet"; one that came but was never opened is
    "came … I haven't opened them yet" (whatever the route's line says). This guards a real gap found in the audit:
    ORIGIN-003's held-boxes "ship" line ("I unpacked them when they came") is set when the sender answers, before the
    boxes arrive;
  - a dated arrangement is told as what was said, with its date: C's "until the end of September", A's "ask at the old
    door until the end of summer" ("The summer is over now"), E's order kept for collection (after Sept 30: "I didn't go
    for it", never "is kept");
  - a letter still unanswered, or an answer still in the post, is said to be so.
  If the spring has no line, the winter's first letter is mentioned (only if it came and was read); D's untouched
  photograph is "still in the desk. I haven't written anything beside it."
- C adds the keepsake as the road described it ("a small notebook: names, measurements…"), a fact of what was packed.

**B. The life here** (two or three observations, never a list of everything).
- The player's own words at the gate, quoted back without comment (*At the gate I said, "First I'll make it fit to live in."*).
- The house as it is: restored / patched ("one more round of work") / boarded ("the roof still wants new shingles") /
  boards mended / "much as I found it. The roof has its hole, and the wind comes through the walls." (stage from
  `house_stage` and the woodwork repair record, as PastPost does).
- The field: "I've harvested N crops … more turnips than anything else", "one crop so far", or "Nothing has come out
  of the field yet."
- One person or place, by priority: **Edith's repair only if its record exists** (month, "She paid me for the work");
  a walker's errands from `requests_done` ("Maren asked me for eggs for the mill, and I brought them"; never "friend");
  **Wicker Cove only if visited** (count); the woods (Nearwood trips / treks / only the edge); or "I haven't gone far
  from the farm. The road down the hill is still there."
- Per origin: **A** adds the deed exactly as it stands ("The town still holds the deed" / "I've paid N of the town's
  12000 coins" / paid), never claiming ownership otherwise, and keeps to house and paper (no village/woods line);
  **B** adds planks hewn at the workbench (from its count) and Edith's paid job, contrasted only by fact; **C** puts a
  walker or place first, then the house; **D** sets the photograph against the house now ("It isn't the house in the
  picture any more" only after a real repair; never "better"); **E** house, field, then a person or place.

**C. What the player chooses to say** (one of five; no right answer, saved as said, not as a trait):
| id | line | adapted |
|---|---|---|
| finish | There is still work on this house I want to finish. | "…work here…" once the house is restored |
| keep | I want to keep some part of my old life. | offered only with a known past |
| unknown | I don't know what next year will bring. | — |
| unsettled | There are things from before that I haven't settled yet. | "There are things I haven't settled yet." when nothing from before is open |
| stay | I want to see what happens if I stay. | — |

## Editorial adaptations (design → game)

1. The September design's sample voices were used for tone and specific lines ("I haven't gone far…", "The road down
   the hill is still there", the woods "places I still don't understand"); lines needing unbuilt tracking ("kept the fire
   going through winter", "most of what I needed came from the land") were not used.
2. The screenplay's September lines are used as PastSpring already stores them; only where they would overstate the
   record (parcel not here / not opened; a dated arrangement after its date) does the page use a stricter line.
3. "The place in the photograph" contrasts the picture with the house now, from the interlude's gate line ("The roof was
   worse than in the photograph").
4. Origin E's "what became of the chance" is told by facts on both sides (the loose end's outcome; the farm's state),
   with no sentence weighing one against the other. A drafted line ("I don't know if the other way would have been
   better") was cut as an unchosen interpretation.
5. The choice is made at the desk, not inside the book: the book has no buttons, and the desk's Diary tab is where
   ORIGIN-003's photograph scene already asks the player to write. No new menu framework.
6. The design's "My Days" grouping is the diary section "One year".

## Save and state

Save **version 21** adds `first_september` (`FirstSeptember.to_save`); v18-v20 saves get `{}` and the page is made
from their records when read. Nothing is written for the player; a legacy save never gets a past.

| Key | Meaning |
|---|---|
| `v` | record version (1) |
| `state` | `""` (not written) or `written` |
| `noticed` | the morning the note was given (-1 before) |
| `written` | the day it was written (-1) |
| `reflection` | `finish` · `keep` · `unknown` · `unsettled` · `stay` |
| `words` | the closing line exactly as written |
| `paras` | the page exactly as written: paragraphs, each a list of sentences (the date is added on display) |
| `facts` | what it was made from: `day`, `origin`, `origin_status`, `intention` (gate words id), `keepsake`, `contact` (`named`/`private`/`none`, never who), `contact_intent`, `winter_state`, `spring_state`, `spring_variant`, `spring_outcome` (PastSpring's small outcome dict), `parcels` (pid → state), `past` (which line was used: `sept`, `parcel:<pid>:<state>`, `dated:<key>`, `unanswered`, `in_post`, `winter`, `photo_untouched`, `none`), `house_stage`, `mended`, `harvested`, `crop`, `people` (`inn`, `asked:<walker>`, `cove`, `woods:<id>`, `none`), `deed` (A), `hewn` (B) |
| `open` | matters from before still open when written: `matter:<thread>:<matter>`, `parcel:<pid>:<state>`, `until:<day>`, `letter_unanswered`, `reply_pending`, `winter_letter_open` |

Query API for CCH-ORIGIN-005: `written()`, `reflection()`, `facts()`, `open_matters()`; the origin, winter and spring
records stay queryable as before (no origin dictionaries copied). A damaged record (unknown closing, no words, no
paragraphs) is dropped (the note's day is kept). JSON's floats are turned back into whole numbers on load, so a loaded
record equals the written one.

## Tests

| Kind | What | Result |
|---|---|---|
| Automated + input-simulated | new `tools/first_september_test.gd` (slot 9; each origin plays the winter and spring through PastPost's and PastSpring's real mornings and answers): date (nothing on 358; note once on 359; still writable on 380 and 500, with the opening's tense; nothing on the Harvest Moon's morning); five origins open with five different passages and share no sentence; A paid/opened/thanked, boxes came but shut, boxes still with the carrier (and an open matter), opened → the route's line, send-on told as said and as over, deposit unsigned (still on account, not settled) and signed, deed in part, never owned; B paid work, boundary from the road, planks from the count, Edith only with the record, decline, method; C more time pending before Sept 30 and told as said after, relation told vs private (no who, no why), keepsake, walker's errand never "friend", boxes shut vs opened; D contact (what was told), the photograph vs the house, no-contact complete without letters, untouched photograph, woods' edge only, no Cove unvisited; E collection before/after the date, storage opened and given, storage shut, meeting closed, August list; farm: restored, boards, one crop, stayed close, Cove once, Edith only with the record, Davy's two errands; legacy (farm only, no "keep"), the quiet farmer; every closing line written as chosen, no coins/sanity/pack/time change, written once, re-reading adds nothing, wording follows house and open matters; save: unwritten and written pages load identically, later farm changes never alter the written page, the facts Year Two needs, v20 save loads with nothing written and can write, garbage / unknown closing / empty words dropped, legacy save; real `_end_day` from day 355: no note on 357 or 358, note on 359 once, the meeting still falls on its own, writing takes no time, the year turns to day 370, StoryAct dates and files untouched; input: desk opens with focus, Space writes, nothing disabled in focus, Esc closes, Xbox A writes, B closes (back one level), mouse click on the entry then **Write it**, J opens the diary with the section and the chosen words last; the longest page (6 pages) in the book: none scrolls, no blank page inside the entry, every sentence once and in order; every origin's written page in 20 cases (ten routes × worked and bare farms) opened in the book: none scrolls | **114 PASS, 0 FAIL** |
| Regression suite | `tools/audit_run_tests.sh` (now 26 suites incl. `first_september_test`) | **25/26 in the parallel run.** The one failure is pre-existing: `aoh_trek_check`'s 50 ms build-timing case (56.7 ms under parallel load; **38.1 ms, PASS, run alone**, as on earlier sprints). menu_test 883, save_test, mail_test 42, past_post_test 193 lines, past_spring_test 145 unchanged; menu_test and save_test rerun after the last desk-row change: pass. `diary_fit` reports 43 pages, 11 scrolling, **identical to the committed baseline log** (all pre-existing Notes / second year / Afterword pages; none are this page, which `diary_fit` doesn't reach because it doesn't advance to day 359; this page's fit is checked by the new test) |
| In-engine captures | `tools/origin004_shots.sh` (23 full-size shots via `tools/capture.gd sept=`, plus BEFORE shots from a HEAD worktree), four sheets and four masters (72%, 72%, 72%, 55%) in `art/style_tests/CCH-ORIGIN-004/review/` | 0 script errors. Found and fixed during review: the closing lines were cut off in the desk list (now short labels; the whole line shows beside it and on the page); pages were a third full; then, after filling them by an estimate of wrapped lines, B's second page scrolled. The fit check now covers every origin, and the budget is 7 lines under the first title and 8 on later pages |
| Human playtest | none | **not done** |

Input is injected (keyboard, Xbox buttons, mouse); no real controller hardware. The real-day case runs the original
story on an artificial save (only the parish letter set, nobody facing the night visitor): it reaches StoryAct's
existing "hollow" ending by neglect (the Hollow left at the door three times after day 240), which is pre-existing
behaviour, not touched or triggered by this page.

## Known limits and deferred

- No Year Two callbacks read the record yet (CCH-ORIGIN-005); the data and query API are in place.
- The choice is at the desk, not in the book itself.
- Relationships: only walkers' completed errands and Edith's repair are named; town talk and gifts are not summarised.
- "A working production routine" (animals, cooking, stall sales) is not mentioned; only harvests are.
- No new art; no sound beyond the existing panel sound when writing.
- Real controller hardware, screen readers and a human playthrough: not done.

## Files

New: `scripts/first_september.gd`, `scripts/first_september_script.gd`, `tools/first_september_test.gd`,
`tools/origin004_shots.sh`, this report, `AI_COLLAB/CCH_ORIGIN_004_SEPTEMBER.md`, `art/style_tests/CCH-ORIGIN-004/`.
Pagination: whole sentences; a page is filled by an estimate of wrapped lines (31 characters a line, 7 lines under the
first page's title, 8 on later pages, a blank line between paragraphs), checked in the book by the test.

Changed: `scripts/main.gd` (instance, reset, morning, `september:` action), `scripts/panel_rows.gd` (diary section,
desk rows), `scripts/save_system.gd` (v21), `tools/capture.gd` (`sept=`, `dsept=`, `spick`), `tools/audit_run_tests.sh`
(adds `first_september_test`), `DESIGN.md`.
