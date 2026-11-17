# CCH-WOODWORK-001 — Workbench, anvil, logging and planks (report)

**Date:** 2026-11-16. **By:** Claude Code. **Status:** implemented and tested by automation; **stopped for the owner's gameplay review.** No human has played it. ChatGPT has not reviewed it.
**Board rows:** R-P1-02 (stations) and R-P1-03 (logs → planks, forest woodcutting). Rules are in `DESIGN.md`, "Workbench, anvil and timber".

## 1. What was built

| Piece | Where | Notes |
| --- | --- | --- |
| Workbench | `FarmProjects.DECOR["workbench"]`, `WoodworkSystem` | Placed from Buildings → Workshop like decor: **4 sticks**, no level, one per farm, open grass, solid. Space opens its panel (hew 1, hew up to 5, Craft, take down). |
| Anvil | `FarmProjects.DECOR["anvil"]` | **8 stone, 2 copper bars, 4 planks, Smithing 1.** Space opens its panel (Forge → Craft Tools or Gear, take down). |
| Station rule | `WoodworkSystem.station_for` | By bill of materials: copper/iron bars → anvil; everything else in Craft (tools, lanterns, gear) → workbench. Bandage, rope, charm stay hand-made. Cooking, smokehouse, furnace, chopping log untouched. |
| Craft panel | `craft_system.gd` | Still browsable anywhere (no second crafting UI). Each card adds "At the workbench" / "At the anvil" (green when you're there); Make only within one tile of that station; away from it the message says where to go. |
| Metal decor | `FarmProjects._anvil_ok` | Lamp post, sprinklers, garden bench, birdbath, weathervane need an anvil on the farm before placing. |
| Logs | `materials["wood"]` | Same key (no migration, no stranded saves); shown as **"logs"** in costs and the inventory (`WoodworkSystem.label`). |
| Planks | `materials["planks"]` | New material. 1 log → **2 planks**, **15 min** at Carpentry 1 (−1.5 min/level, min 6), **+5 Carpentry XP** per log. Batch up to 5; refused within an hour of 03:00; never below 0 logs. |
| Nearwood | `nearwood_system.gd` | New away location (village pattern). Gap in the trees north of the farmhouse with a forester's sign; Space twice; 06:00–17:00; **15 min each way**. 8 marked firs (pale blaze), darker unmarked wood never cut. **4 logs/tree** (5 at Forestry 5), farm hardwood chance from copper hatchet, 20 Forestry XP. Stumps regrow in **4 days**. No walker, oil, foes or story beats; not a trek (doesn't touch the wood-encroachment clock). |
| Construction | `REPAIR_COSTS` | **Patched: 8 planks + 4 fiber** (was 5 wood). **Restored: 14 planks + 6 fiber** (was 8 wood). Boarded stays 3 logs. Completed stages are kept on old saves. |
| Repair transaction | `WoodworkSystem.try_repair` | Checks skill + materials, pays, passes bounded hours, gives XP, records once in `repairs` (`{id: {day, cost}}`). House stages record as `house_1..3`. Ready for Edith's inn repair (planks + hardware + Carpentry + hours), not used for it yet. |
| Saves | `save_system.gd` | New keys `woodwork` and `nearwood`; missing → safe defaults (old saves load with no planks, no stations, all trees standing, earlier house stages recorded). Garbage data is ignored. No version bump needed. |
| Guide | `GUIDE` | New step `g_bench` before the crude hatchet; counts as done if you already own a hatchet. |
| Art (temporary) | `art/farm/e3/workbench.png`, `anvil.png` (`tools/woodwork_art.py`) | Drawn pixel by pixel from the farm palette. No PixelLab/SpriteCook. Nearwood drawn from existing farm tree, stump, thicket, log pile and signpost sprites. |

## 2. Station recipes and conversions

- **Workbench:** hew planks; crude + stone hatchet; stone pick; willow + hardwood rod; Tin, Brass, Hollow lanterns; sharpened stick, hunting knife, resin cap, fiber wraps, bark wrap/boots/greaves, twine collar, resin amulet, reed leggings, hardwood shield.
- **Anvil:** copper + iron hatchet and pick; copper nozzle, spray head; every copper and iron armor/weapon piece; copper + iron shields.
- **Unchanged stations:** fire (cooking), smokehouse, furnace (smelting, bell metal), chopping log (1 log → 2 firewood).
- **Conversions:** tree (Nearwood) → 4–5 logs; grove tree (farm) → 3 logs; 1 log → 2 planks (workbench); 1 log → 2 firewood (chopping log); 1 log fuels one smelt.

## 3. Costs and time to planks (from a fresh game)

- Day 1: brush gives 7 sticks, 7 fiber → workbench (4 sticks) → crude hatchet (2 sticks, 2 fiber) → Tin Lantern and Boarded still affordable the same day.
- One Nearwood trip with the crude hatchet: ~0.5 h walking + ~7 real seconds a tree. The sim's full clear (8 trees, ~40 logs) averages ****2.65 h**** of game time. A single tree (4 logs) is enough for the Patched repair.
- Patched's 8 planks = 4 logs = **1 h** at the bench at Carpentry 3 (12 min/log).
- So **logs → planks for the first plank repair: about 2 game hours** including the walk.

## 4. Tests

| Test | Result |
| --- | --- |
| `tools/woodwork_test.gd` (new; slot 9) | **PASS, 0 failures** — fresh game → bench from day-1 brush → hatchet refused away / made at bench → trail both ways (time, needs, collision, every tree reachable) → felling with real harvest ticks → hewing (counts, time, XP, cap, no negative, refusals) → stone hatchet at bench, copper hatchet/helm refused at bench and forged at anvil → lamp needs anvil → Patched paid in planks and recorded once → repair API never pays twice → save/load of logs, planks, stations, stumps, repairs, skills, tools, gear → regrowth and a full second clear → day end / fall in the Nearwood → save made there puts you home → old save without new keys → garbage data → Wicker Cove gate, NW cave mouth, Maren's day-4 route still there. |
| `tools/audit_run_tests.sh` (now 21 suites, adds woodwork_test) | 20 of 21 pass; `aoh_trek_check` fails its 50 ms timing (54–69 ms). It fails the same way on the pre-change commit (46.9 / 56.1 / 54.1 ms over three runs): the known R-P5-04 cost, not this change. |
| `tools/menu_test.gd` | **PASS** incl. new Workbench and Anvil panels: focus on open, every entry reached, wrap, stick, nothing disabled in focus path, keyboard and pad footers, B closes, clock stops, player moves again. Craft-pad and placement cases now stand beside the stations. |
| `balance_sim` 400 days × engaged/ignore/earlybed, treks=3, before vs after | see §5 |

Not done: a human playtest; real windowed play with injected input through a whole trip (the panels were driven by injected keys/pad in menu_test, felling by the game's own harvest ticks).

## 5. Balance (sim, first day reached)

One seed, 400 days, treks=3. Logs: `art/style_tests/CCH-WOODWORK-001/logs/sim_{before,after}_{mode}.log` (before = `13749a79`).

| Milestone (day) | engaged before → after | ignore before → after | earlybed before → after |
| --- | --- | --- | --- |
| Workbench / anvil placed | — → 1 / 35 | — → 1 / 36 | — → 1 / 37 |
| Boarded | 1 → 1 | 1 → 1 | 1 → 1 |
| Coop | 7 → 7 | 7 → 7 | 7 → 7 |
| Patched (now planks) | 13 → 13 | 13 → 13 | 13 → 13 |
| Furnace | 36 → 34 | 35 → 35 | 36 → 36 |
| Smithing 2 (copper tools) | 36 → 34 | 36 → 35 | 36 → 36 |
| First lamp post | 113 → 65 | 114 → 65 | 113 → 66 |
| Barn | 79 → 75 | 80 → 76 | 80 → 77 |
| Restored (now planks) | 245 → 244 | 245 → 244 | 245 → 244 |
| Crow bell | 396 → 396 | 396 → 396 | 396 → 396 |
| Maren's edge trek | 4 → 4 | 4 → 4 | 4 → 4 |
| Nearwood trips (h total, h/trip) | — → 15 (39.9, 2.66) | — → 21 (55.5, 2.64) | — → 24 (63.5, 2.64) |
| Logs per trip | — → 38.9 | — → 39.2 | — → 39.3 |
| Logs hewn (bench hours) | — → 13 (2.0 h) | — → 13 (2.0 h) | — → 13 (2.0 h) |
| Logs held on day 400 | 26 → 67 | 28 → 68 | 28 → 83 |
| Min sanity; days under 60/40/20 | 37; 23/2/0 → 26; 36/6/0 | 32; 21/1/0 → 41; 11/2/0 | 31; 33/0/0 → 22; 14/2/0 |
| Hours with no food/water | 0 → 0 | 0 → 0 | 0 → 0 |

Reading: the story and homestead ladder keep their days; the plank repairs cost about an hour at the bench each. The baseline ran short of logs (2 held on day 201 in engaged); with the Nearwood the woodpile never empties, which brings the first lamp post (a log-hungry smelting chain) ~48 days earlier. Forestry is a supply trip every two or three weeks in the sim, not a daily chore. The sanity minimums move both ways between modes; with one seed and every random roll shifted, I read that as noise, not an effect (no human or multi-seed check). An early design used 3 sticks + 2 fiber for the bench; it pushed Boarded from day 1 to day 4 (day-1 fiber ran out), so the bench is now 4 sticks.

## 6. Known defects and limits

- The trail mouth is shown by the sign and a dirt patch, but the farm's tree line (concept scenery art) doesn't visibly open there.
- Station and Nearwood art are placeholders (R-P4-02). The Nearwood's deep wood is drawn as dark blocks.
- Many older messages still say "wood" where costs now say "logs" (same item).
- Large metal works (estate extensions, cistern, hoppers, trail works) don't require the anvil yet.
- The Nearwood has no ambience/music of its own (it uses the farm's outdoor tracks).
- Balance figures are sim, not human.

## 7. Deferred

Deep timber stand / hardwood grove (R-P2-04), handcart, Edith's inn repair (R-P2-02, will call `try_repair`), Living Memory hooks, proper station and grove art, station move without taking down.
