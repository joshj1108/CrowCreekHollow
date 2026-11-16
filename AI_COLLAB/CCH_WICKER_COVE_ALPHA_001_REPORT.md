# CCH-WICKER-COVE-ALPHA-001 — The first playable Wicker Cove

**Status:** built 2026-11-15 by Claude Code; review requested. Owner-authorized implementation and PixelLab use (up to 12
requests). The owner's final authority stands; nothing here is accepted until the owner says so.
**Built on:** `1d3f632` (origin/main, fast-forwarded before starting). The owner's uncommitted work in the tree (the
CCH-EVENING-002 refinement and the sunset experiment in `main.gd`, `evening_system.gd`, `night_system.gd`,
`panel_rows.gd`, `desk_system.gd`, `grade.gdshader`, `balance_sim.gd`, `capture.gd`, `evening_*.gd`, `DESIGN.md`) was
left in place and is in none of these commits: only this task's hunks were committed.
**Design:** `DESIGN.md` › "Wicker Cove (alpha)". **Review package:** `art/style_tests/CCH-WICKER-COVE-ALPHA-001/review/`
(`CCH-WICKER-COVE-ALPHA-001_master.png`).

## What is genuinely playable

- **Travel.** From day 2, Space facing the farm's closed east gate asks once, then walks you down (half an hour, needs
  as they go; nothing refilled or given). The road at the top of the village walks you home to the road inside the
  gate (half an hour). The gate keeps its art and collision; a walker waiting there is still asked first. The road is
  shut from 20:00. Played with injected keyboard/mouse and with an Xbox controller: both pass.
- **The village:** one outdoor map (40 × 30 tiles): road and sign, general store, square, four nonenterable homes
  (one boarded), the inn, the fish market, quay, pier, two moored dories, nets, crates, bollards, a bench, lamp posts.
- **Enterable:** the inn's common room only (hearth with fire, Edith's counter, two tables, barrels).
- **Residents:** Thomas Bellweather (store) and Edith Vale (inn): a first-meeting scene each in the existing dialogue box
  with code-drawn portraits in the walkers' style, then a daily word (rotating, seasonal, late-hour, a callback after
  you've traded, a line after the order).
- **Trade (existing coins, items and inventory functions):**
  - Store buys produce (crops, eggs, milk) at the farm stand's full price, up to 12 a day; sells lamp oil 9, turnip
    seeds 3, flour 6, rope 7, bandage 12, trail ration 14 (a few a day).
  - Fish market (honesty tin, nobody at the stall) buys fish at their stand price, up to 8 a day; sells perch 8 and
    smoked fish 15.
  - Inn sells food to carry home: fish stew 17, bread 18, rose hip tea 11. No new recovery mechanic.
  - Every purchase re-checks stock, coins and pack room; sales never exceed what is held or the day's limit.
- **Delivery:** "Turnips for the store": six turnips, all at once, for 70 coins (54 at the stand). Complete, persistent
  across save/load, done once only (a second hand-in is refused). On the notice board while it stands.
- **Fog and light:** fog every hour, season and weather (a shader: thin near the farmer, thicker with distance and over
  the water); the village's light leans to a cool grey and has a night floor; warm windows and lamp posts; the inn lit
  by its fire. Rain and snow show in the street.
- **Saves:** under `town`, save version 17 (migration step added). A save is only made in bed; one made away records the
  homestead. Old saves start with a fresh village.

## Artwork and generation count

PixelLab: **10 requests** (cap 12), no retries, subscription generations only (117 generations; USD 0). Style image: a
board of the farm's own art (farmhouse, stand, well, mailbox). Kept: store, inn, four cottages (all four candidates),
market stall, two dories, Thomas, Edith, harbour props (halved: they came out ~2× the farm's scale), two Wang tilesets.
Both tilesets came back with their terrains swapped and darker than the farm's ground; the code maps them and the art
script lifts them. Reused: firs, boulders, lantern post, barrels, bench, the farmhouse interior's floor, wall, hearth,
fire and furniture. Every job is in `pixellab-assets.json` under `CCH-WICKER-COVE-ALPHA-001`.

## Tests run

| Test | Result |
| --- | --- |
| `tools/town_test.gd` (new, headless, slot 9) | 64 checks, 0 failures |
| `tools/town_play.gd` (new, played, kbm and pad, throwaway profiles) | PASS both |
| `menu_test.gd` (with the four village panels added) | 0 failures (855 PASS lines alone; 854 in the suite run) |
| `save_test`, `interior_test`, `mail_test`, `debug_menu_test`, `diary_test`, `wheel_test`, `layout_test`, `farmer_test`, `creature_test`, `aoh2_e2/e3/e5_check`, `diary_fit` (suite runner, isolated profiles) | all pass |
| `evening_test`, `playable002_test` | pass |
| `aoh_cave_check`, `aoh_trek_check` | failed only their build-time thresholds in the parallel run (75.5 ms, 127.8 ms) under load; **pass alone** (12.8 ms / 60, 34.8 ms / 50) |
| `balance_sim` engaged, 400 days, treks=3 | every chapter, the second year's beats and the Elias ending (day 399); the sim never visits the village |
| `capture.gd ending=bell / elias / hollow` | each ending sequence plays, no script errors |

Limitations: the sim's strategy reaches one ending; the bell and Hollow endings were checked as sequences, not reached
by play. No human has played it. Slot-9 tests must not run in parallel without separate profiles (they share files).

## Known issues (honest)

- The ground tiles are darker and blockier than the farm's hand-painted ground, and the cobble street has round-blob
  edges from the tileset's corners.
- The sign's words use the UI font, smooth rather than pixel-drawn.
- At night without a lantern the street is readable but dim between lamps.
- Thomas never leaves his doorway and Edith never leaves her counter (no schedules).
- Night visitors still come to the farm at 22:00 if you stay in the village that late (as when in the mine); the road
  down is shut from 20:00 and the village says it's getting late from 19:00.
- `menu_test` needed its small-panel loop moved into a helper to add the village's panels.

## Deferred on purpose

Saltwater fishing (the pier end is look-only; it needs new fish, spots and saves), more orders and partial deliveries,
the inn's repairs and guest rooms, more residents (Martha, Gideon), schedules, a store interior, harbour sounds, a
travel unlock other than day 2. The Lowmere postal continuity question
(`WICKER_COVE_POSTAL_LORE_CONTINUITY_AUDIT.md`) is untouched: no historical dialogue was renamed, and nothing says why
the fog is there or when it came.

## Hooks for later

`TownSystem.flags` records the day of: first arrival (`arrived`), first trade (`traded`), first delivery
(`delivered`), first word with each resident (`met_thomas`, `met_edith`). Repairs would add their own keys. Nothing
reads them yet; no event registry was added.
