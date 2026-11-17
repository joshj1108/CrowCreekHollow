# CCH-WICKER-COVE-002 — Edith's inn repair and the first Living Memory loop (report)

**Date:** 2026-11-16. **By:** Claude Code. **Status:** implemented and tested by automation; **stopped for the owner's review.** No human has played it. ChatGPT has not reviewed it.
**Board row:** R-P2-02. **Scope note:** `AI_COLLAB/CCH_WICKER_COVE_002_SCOPE.md` (A + B batch). Rules are in `DESIGN.md`, "Wicker Cove (alpha)", under "Edith's leak".

## 1. The loop

Nearwood logs → planks at the workbench → iron bars at the furnace → Edith's counter (the quote) → **Do the work** (two hours) → the stain and bucket go, a new board shows → Edith pays 60 coins → she remembers (that day; that it held, the next time; after rain, that it held through the rain) → Thomas hears it from her (a later day, once) → a diary page in your hand.

## 2. What was built

| Piece | Where | Notes |
| --- | --- | --- |
| The job | `TownData.INN_REPAIR` | **8 planks, 2 iron bars** (hardware), **Carpentry 2**, **2 hours** begun by **17:00**, **+30 Carpentry XP** (`XP_REPAIR`, the house repairs' figure), **60 coins** once. |
| The quote | `TownSystem._leak_rows` | "The leak" section on Edith's counter, under her word: her explanation, the pay, each need ticked against what you hold, **Do the work** (enabled only when everything is met), **Not now**. |
| Declining | `town:leave` | Takes and records nothing; Edith shrugs; the offer stands. No "accepted" state exists, so accepting can never be mistaken for completion. |
| The work | `TownSystem.repair_inn` | Re-checks everything, then one `WoodworkSystem.try_repair("inn_roof", …)` (skill, materials, hours, XP, recorded once), then the coins. Refused with nothing changed: no or short materials, Carpentry 1, after 17:00, away from the inn, already done. The completion line is kept as a notice. |
| The record | `woodwork.repairs["inn_roof"]` | `{day, cost, paid, rain}`: the single truth that it happened. `town.flags["inn_roof"]` = the day (memory hook). No new save keys. |
| Before | `TownArt._draw_leak` | Code-drawn on the art-pixel grid: a ragged brown stain from the ceiling line down the north wall (left of Edith's counter), a wet streak, a puddle, a wooden bucket with an iron hoop on local tile (5, 3) (solid while there), a drop every 1.6 s (0.8 s on a rainy day). Facing the bucket describes it. |
| After | same | Stain, streak, puddle, bucket gone; the tile opens; a pale new board with two iron nail heads at the ceiling line. Drawn from the record, so it survives visits and loads. |
| Edith remembers | `TownSystem._memory_line` | Same day: `LEAK_SAME_DAY`. First word on a later day: `LEAK_HELD`, or `LEAK_HELD_RAIN` if a rainy day has been counted since the work (`stats.rain_days` vs the record's `rain`). Once (`flags["inn_roof_edith"]`); the line holds for the rest of that day. After that her bucket line and her spring "money for the roof" line become `LEAK_AFTER` / `LEAK_AFTER_SPRING` (the back room is dry, not let, wants a bed). Her other lines, and the unready upstairs rooms, stay. |
| Thomas hears | same | Only on a day after the work (he hears it from Edith), once, at any hour: `LEAK_THOMAS`. Nothing on the day itself. |
| The diary | `TownSystem.diary_pages`, `PanelRows._diary_sections` | A Notes page in your hand, **The leak at the inn**: "Day N, Month D. I mended the leak over the back room at the inn in Wicker Cove, for Edith Vale. It took 8 planks, 2 iron bars, and two hours of the day. She paid me 60 coins." Built from the record only; marked new. No feelings written for the player. |
| Small fix | `WoodworkSystem.amount_text` | Costs now say "2 iron bars", not "2 iron bar" (any "… bar" material). |
| Capture | `tools/capture.gd` | `tready`, `tfixed=N`, `trained`; `tab=` takes `_` for a space (`tab=The_inn`). |

Nothing else changed: no guest system, no other rooms, no friendship meter, no story gate, no change to the 17 chapters or 3 endings, no new art files, no PixelLab or SpriteCook use.

## 3. Balance and attainability

From the CCH-WOODWORK-001 sims (one seed, engaged / ignore / earlybed, 400 days; this job is not modelled in the sim):

| Need | First reached (engaged) | Route |
| --- | --- | --- |
| Carpentry 2 | day 2 | Boarded repair, bench, hewing |
| 8 planks | day 13 (Patched uses 8) | one Nearwood tree (4 logs) + 1 h at the bench |
| 2 iron bars | ~day 34 | copper pick + Mining 5 (day 29) + furnace (day 34) |
| 60 coins | — | coins held on day 41: 439, so it pays about a seventh of that; about a good day's stand takings |

So the job opens around day 35 for an engaged player, a little later for the others. No impossible chain: every input is on the existing ladder. The 2 iron bars are the gate; if the owner wants the job earlier (first-week village loop), swapping them for 2 copper bars changes nothing (same day, same furnace) — the real lever would be a non-smelted hardware such as rope or Thomas selling nails. I left the brief's baseline as is.

## 4. Tests

| Test | Result |
| --- | --- |
| `tools/inn_repair_test.gd` (new; headless, slot 9) | **PASS, 86 checks, 0 failures.** Quote shows exactly "8 planks", "2 iron bars", "Carpentry 2", "2 hours, begun by 17:00" and "pays 60 coins"; looking records nothing; refusals (none, planks only, one plank short, Carpentry 1, too late, away, unknown id) change nothing; Not now changes nothing and the offer stands; Do the work through the panel's own action string takes 8 planks and 2 bars, passes 2.00 h, pays 60, gives the XP, records day/cost/pay, flags the day, adds a new diary page; never twice by panel, call or `try_repair`; bucket tile solid before and open after, look text both ways; diary text (day, date, materials, hours, pay, no feelings, one page); Edith same day / next day / once / after rain / never the bucket line again / other lines intact; Thomas not same day, next day, any hour, once; save writes the record; load brings back record, flags, page, open tile, no second payment; a save without the record (with or without stray flags), a save from before the village and woodwork, and garbage repair data all remember nothing and show the bucket; afterwards the workbench hews, the road down and up, the store, notice board and inn shop still work. |
| `tools/audit_run_tests.sh` (now 22 suites, adds `inn_repair_test`) | **21 of 22 pass.** Run 1 had `aoh_cave_check` (65.8 ms vs 60) and `aoh_trek_check` (107 ms vs 50) fail their timing thresholds with five suites running at once; alone, `aoh_cave_check` passes (21 ms) and `aoh_trek_check` still fails (72.8 ms). The trek timing is the known pre-existing R-P5-04 (it failed identically before CCH-WOODWORK-001); neither touches the village. |
| `tools/menu_test.gd` (in the suite) | **PASS (883 lines)**, including the inn panel with its new rows: focus on open, every entry reached, wrap both ways, left stick, nothing disabled or hidden in the focus path, keyboard and pad footers, B closes, clock stops, nothing left focused. |
| `town_test`, `orders_test`, `woodwork_test`, `save_test`, `diary_test`, `playable002_test`, `evening_test` | PASS (65, 46, 93, 66, 63, 79, 166 lines). Story chapters and endings: no story, chapter or ending code was touched (`story_act.gd`, `mystery.gd`, `ending_screen.gd`, `main.gd` unchanged); `playable002_test` passes. No balance sim was rerun: the job isn't in the sim and nothing it reads changed. |

Not done: a human playtest; a windowed run pressing **Do the work** with a real controller (menu_test drives the panel by keys, pad and stick; the work is driven through the same action string the button sends).

## 5. Screenshots (`art/style_tests/CCH-WICKER-COVE-002/`)

- `shots/01_inn_before.png`, `01b_inn_before_close.png` — the inn before the repair (full size crop).
- `shots/02_quote.png` — Edith's counter, "Mend the leak" selected, every need ticked.
- `shots/03_inn_after.png`, `03b_inn_after_close.png` — after: no stain, no bucket, the new board.
- `shots/04_edith_callback.png` — Edith two days later, after rain.
- `shots/05_thomas_callback.png` — Thomas the day after.
- `shots/06_diary.png` — Notes: "The leak at the inn".
- `review/CCH-WICKER-COVE-002_master.png` (sheets at 72%): baseline `401031af` vs the leak, day and night; leaking vs mended, day and night; the drip as six frames. `review/CCH-WICKER-COVE-002_master_2.png` (100%): the quote, both callbacks, the diary. `review/drip_after.gif`.
- Caveat: the mended captures are on day 3 (the record needs a day before), so their weather (overcast) differs from the day-1 leak captures (sunny/drizzle); the room's light is the fire's and barely changes.

## 6. Known limits and pre-existing issues found

- **Found, not fixed (pre-existing):** `TownSystem._line` picks the season line whenever `day % 4 == 1`, and the everyday line is `LINES[day % 4]`, so each resident's second everyday line (`LINES[1]`: Edith's "Sit by the fire…", Thomas's "Flour's late again…") can never be shown. Changing it would shift which line shows on which day, so I left it for the owner.
- The stain and bucket are code-drawn placeholders on the art grid; they read at play size in the captures but are not final art.
- The memory is specific to this one job (no general event framework, by the brief). The next consumer should decide whether `woodwork.repairs` + `town.flags` is enough or a small registry is due.
- The quote panel's detail card is tall: with the offer text the ledger grows a little toward the top of a 720p window (it fits).
- Thomas's line is gated by "a later day", not by Edith having been seen to talk to him (residents have no routines yet, R-P2-03).

## 7. Deferred

Harbour fishing (R-P2-05), resident routines (R-P2-03), guest rooms, a letter or mailbox callback, a later "leak" spring act, final art for the leak.
