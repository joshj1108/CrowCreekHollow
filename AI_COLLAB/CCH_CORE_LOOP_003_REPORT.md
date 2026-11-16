# CCH-CORE-LOOP-003 — Food economy, repeatable village orders, gameplay stability

**Status:** built 2026-11-15 by Claude Code; stopped for gameplay review. The owner's final authority stands;
nothing here is accepted until the owner says so.
**Built on:** `477dde3`. The only uncommitted files before starting were `project.godot` and `scenes/main.tscn`
(editor noise, left out as `CLAUDE.md` says); the sunset and CCH-EVENING-002 work was already committed
(`3d565fa`, `63e2d34`) and is untouched.
**Evidence:** `art/style_tests/CCH-CORE-LOOP-003/` — `logs/` (food audit before/after, every test log, sims, played
logs), `play_kbm/`, `play_pad/` (played screenshots), `review/` (sheet and master PNG).

Kinds of evidence, kept apart: **Played** = the real windowed game driven by injected keyboard/mouse or Xbox input
(`tools/town_play.gd`, a bot, not a human); **Direct state** = headless tests that set state and call the game's own
functions (`tools/orders_test.gd` and the suite); **Simulated** = `tools/balance_sim.gd`; **Data** = numbers printed
from the game's own tables (`tools/food_audit.gd`). **No human has played this.**

## 1. CCH-EVENING-002 verification status

**Implemented, committed and simulated; played verification never finished; the owner and ChatGPT haven't reviewed it.**

- Code: committed in `63e2d34` (farmhouse shelter, Quiet Hour, rest scene, clue readability, onboarding tip). The
  sunset preview is `3d565fa`. Both are on `main`; nothing of either was uncommitted when this sprint started.
- Direct state: `evening_test` passes now (166 ok lines, 0 FAIL), as does `playable002_test` (79 / 0).
- Simulated: 28 sim runs in its report (first-week sanity, styles, shelter sensitivity).
- **Played: incomplete.** The report still has unfilled `{PLAYED}`, `{PLAYED_BED}`, `{PLAYED_IDLE}`, `{PLAYED_MIN}`
  and `{PLAYED_TESTS}` placeholders. The played logs in `art/style_tests/CCH-EVENING-002/play_*` cover only **1-2
  evenings per style** (`python tools/evening2_played.py`: cozy 1, cautious 2, curious 1, balanced 2, minimal 2),
  not the 14 the report planned. So the first-week sanity progression, Quiet Hour use and the hearth benefit are
  backed by the simulation and tests only, not by a played fortnight.
- What I did: **left it untouched.** Finishing it means five 14-evening windowed runs plus report edits. That's
  CCH-EVENING-002's own scope, and the gameplay calls in it (shelter values, Quiet Hour) belong to the owner's review.
  Nothing in this sprint changes evening, sanity, shelter or night code.
- First-14-days survival today (Simulated, this sprint's code, `balance_sim`): engaged lowest morning sanity 85 by
  day 21, ignore and cozy dip to ~50 on day 11 and recover to 87-91 by day 21; no food or water ever empty. Cozy ran
  out of Comfort (warmth) for 54 hours across its first 180 days and lost 24 HP to needs: a winter warmth gap that
  predates this sprint (the sim cooks none of the turnip dishes changed here). The warm turnip hash is one cheap
  answer a player now has.

## 2. CCH-FOOD-001 — food economy audit (Data, from `tools/food_audit.gd`)

Hunger drains about 2.4 an hour, **58 a day**. Every food restores `10 + 12 × difficulty + 3 × level` Hunger
(`Foods.food_restore`); a cooked dish uses its own difficulty and level, **not its ingredients'**. Full tables:
`logs/food_audit_before.txt` and `logs/food_audit_after.txt`.

**What an early farmer can actually eat (October, days 1-14):** turnips (22 Hunger, 9 coins at the stand), pond fish
(perch/bluegill 25, 5-6 coins), nettles/rose hips/pears/blackberries foraged (25, 2-3 coins), kale from Farming 1
(25, 7). Cooking 0 dishes: grilled fish and turnip hash. Eggs need the coop (Carpentry 2, 6 wood, 4 fiber, 12 a
hen); milk needs the barn (Carpentry 7, late). Turnips and fish carry the first month: about **2.6 turnips or 2.3
fish a day**, i.e. ~23 coins a day of turnips not sold, or ~14 of fish.

**Cost per 10 Hunger (coins given up by eating instead of selling):** forage 0.8-1.8, eggs 1.4, perch/bluegill
2.0-2.4, peas/potato/kale 2.0-2.9, turnip 4.1, corn 4.6, garlic 5.2. Eating forage and fish and selling turnips is
already the efficient play, and the sim does exactly that.

**Recipes against their raw inputs (before this pass):**

| Finding | Numbers |
| --- | --- |
| **Almost every fire recipe loses Hunger.** 21 of 24 fire dishes restore less than their ingredients eaten raw. | median −28 Hunger; worst roast roots −53, rose hip tea −50, colcannon −48, corn chowder −48 |
| **Turnip hash, the first meal (Cooking 0), was strictly worse than raw.** No effect, half the Hunger, less coin. | 2 turnips (44 Hunger, 18 coins) → 22 Hunger, sells 8 |
| **Fish stew, the inn's dish, lost Hunger and coin.** | fish + 2 turnips (69 Hunger, 23 coins) → 55 Hunger, sells 13 |
| Grilled fish is close to neutral and **keeps** (raw fish spoil in the pack overnight). | 25 → 22 Hunger, 5 → 8 coins |
| The dishes that pay come later and lean on effects: warmth, water, calm, nerve. | sturgeon steak, ghost tincture, smoked lamprey, pies, cobbler |
| **Preserved food is already worth making** once the smokehouse stands (Cooking 4 build, 60 coins): smoked fish +15 Hunger and keeps; canned +11, fermented +14 over two turnips. | smoked fish 25 → 40 Hunger |
| **Dried turnip is redundant:** 2 turnips → 40 Hunger (−4); turnips already keep in the pack and cellar. | flagged, not changed |
| Bread is the only big Hunger gain early (+33 over one egg), but it costs 12 coins of flour. | 2 flour + egg → 55 Hunger, sells 14 |
| Hens are Hunger-neutral (1 crop fed → 1 egg, both 22) and lose coin unless fed cheap crops; eggs are worth it in bread, rations and pies. | egg 3 coins, turnip 9 |
| **No recipe makes runaway profit.** The stand takes only 2 cooked foods a day at full price (pooled), so cooking for coin is capped. Biggest coin gains: sturgeon steak +11, ghost tincture +22, smoked lamprey +22, apple crumble +16. | `StallSystem.STAND_DEMAND["cooked"] = 2` |
| **Winter:** turnips grow all year and keep, kale/leeks/parsnips/garlic grow in winter, and the cellar keeps roots. Food is not the winter constraint; warmth and sanity are. | sim, section 7 |
| **Expeditions:** trail rations (egg + turnip, Cooking 2) are the trek food; bread for a walker with none. Both reachable in the first month with a coop. | — |

**Reading:** the food economy isn't broken, but cooking everyday food isn't worth doing. Food comes cheap and
cooking costs Hunger, so the sensible player eats raw and cooks only for effects later on. That's the defect worth
fixing, and only at the entry point. Changing the restore formula would ripple through every food, the walkers'
gifts and the sims, so I left it.

## 3. Food adjustments made (two recipes, nothing else)

| Dish | Before | After | Hunger vs raw | Coin vs raw | Why |
| --- | --- | --- | --- | --- | --- |
| **Turnip hash** (Cooking 0) | 2 turnips + wood → 22 Hunger, no effect | **1 turnip** + wood → 22 Hunger, **+10 warmth** | −22 → **±0** | −10 → −1 | The first meal is now hot food for a stick of wood, not a loss: a cold-evening meal, Cooking XP, nothing unbalanced. |
| **Fish stew** (Cooking 3) | fish + 2 turnips + wood → 55 | fish + **1 turnip** + wood → 55, +10 warmth (unchanged) | −14 → **+8** | −10 → −1 | The one early prepared dish with a real advantage: more Hunger than its parts, warming, and it keeps where the raw fish would spoil overnight. |

Unchanged on purpose: every other recipe, every price, the restore formula, Hunger drain, the stand's demand, the
inn's prices (its stew stays 17). Raw food stays as good as it was. Side effects checked: the daily job's "Deliver
meals" (grilled fish + turnip hash, 34 coins) now costs one turnip less; the walkers who love fish stew are
unchanged; a neighbour's gift of turnip hash and the sanity collapse's 2 hash are unchanged items. `DESIGN.md`
(Cooking table) updated.

## 4. CCH-ORDERS-001 — repeatable village notices

Built on the Wicker Cove turnip order, in `TownData.REPEAT_ORDERS` and `TownSystem` (no new panel: two new row
kinds in the existing notice-board and store ledgers). Thomas is the contact: notices go up on his board and are
handed in at his counter.

| Kind | Asks for (one, all at once) | Premium | Week 1 of a new game |
| --- | --- | --- | --- |
| **Produce for the store** | 6 turnips · 5 kale · 6 potatoes · 4 corn · 3 leeks · 3 pumpkins · 3 parsnips | ×1.3 | 6 turnips, **70** (stand 54) |
| **A pot for the inn** (Edith's) | 3 turnip hash · 2 grilled fish · 2 fish stew · 2 smoked fish | ×1.5 | 2 grilled fish, **25** (stand 16) |
| **Household supplies** | 3 fish (any) · 4 eggs · 2 jugs of milk | ×1.3 | 3 fish, **25** (stand 18) |

Every possible notice and its reward (stand price × premium, to the nearest 5, at least 3 over):
produce — turnips 70 (54), kale 45 (35), potatoes 60 (48), corn 70 (52), leeks 70 (54), pumpkins 75 (57), parsnips
60 (45); prepared — turnip hash 35 (24), grilled fish 25 (16), fish stew 40 (26), smoked fish 35 (22); household —
fish 25 (18), eggs 15 (12), milk 15 (12).

**Rules:**
- The board fills once the turnip order is in (the alpha's order stays the introduction, and stays done in old saves).
- Only what you could fill now is asked: crops in season and within your Farming level, dishes within their skill
  level (smoked fish needs the smokehouse), eggs need hens, milk goats. No impossible early asks (tested).
- **Week** = 7 days from day 1. A notice not taken comes down at the week's turn. **Take it** at the board (it stays
  yours until handed in or given up, past the week's turn), **Hand in** at Thomas's counter, **Decline** /
  **Give it up** with no penalty. **Defer** = leave it up.
- A kind handed in or turned down gets its next notice at the next week's turn: **at most 3 notices pay a week**,
  never twice, never re-rolled. The ask is picked from the week and the kind (not random) and saved, so loading or
  walking away and back changes nothing.
- All at once (partial delivery deferred: reliability first). Hand-in re-checks the pack, spends through the game's
  own `_spend_recipe_input` (groups cheapest first), pays, then clears the notice before anything else.
- Thomas, the day of and after a delivery: *"The turnips you brought sold before noon…"*, *"Edith served your
  grilled fish last night and never said whose they were…"*, *"The fish went out of here nearly as fast as they
  came in…"*, naming what was really handed over (read from `history`, written only by a delivery that went through).

**Profitability (Data):** a notice pays 1.3-1.5× the stand for the same goods, and works around the stand's daily
caps (2 cooked, 6 fish, 15 of a crop at full price). The walk costs an hour of the day there and back. Gross, notices pay
up to ~120-145 coins a week, but the goods would sell anyway: **the real gain is the premium, about 30-45 coins a
week** (week 1: 16 + 9 + 7 = 32), plus selling past the stand's caps. That's a worthwhile reason to visit and
doesn't replace the stand (the sim's engaged farm ends day 41 with 789 coins, about 20 a day net).
Cooking for a notice beats selling the raw parts: 3 turnip hash = 35 coins for 3 turnips (27 raw), 2 fish stew = 40
for 2 fish + 2 turnips (30 raw).

**Bug fixed on the way:** the alpha's turnip order asked for `"crops"`, which `MainGame._held` counts as any crop
while `FolkSystem._take` took only turnips, so six kale could hand it in and leave the turnip count at −6. It now asks
for `"turnips"` and spends through `_spend_recipe_input`. Old saves are unaffected (`orders_done` is keyed by id).

## 5. Wicker Cove integration and the memory hook

No art, layout, resident, schedule or inn change. The board's pinned paper is the alpha's existing drawing, shown
while any notice is up and not taken (`TownSystem.notices_up`, was `order_open`). `TownSystem.flags` is kept and
gains `order_produce` / `order_prepared` / `order_household` (first day). **`TownSystem.history`** (the last 30
deliveries: day, kind, food, count, coins, label) is the documented integration point for CCH-LIVING-MEMORY-001: a
delayed callback, a letter or a diary line can read what was really delivered and when. Nothing else reads it yet.

## 6. Save / version

New keys under `town`: `board`, `slot_week`, `history`. **No save-version bump**: `_from_save` defaults them and
validates every field (unknown kinds and foods, counts or coins ≤ 0, wrong types are dropped). A Wicker Cove alpha
save with the turnips done keeps them done and gets this week's notices; one with the turnips open keeps the order
and gets no notices yet (tested). Saves made before the village (version < 17) migrate as before.

## 7. Tests

**Direct state (headless, each in its own throwaway profile, slot 9; slots 1-3 never touched):**

| Test | Result |
| --- | --- |
| `tools/orders_test.gd` (**new**) | **46 ok, 0 FAIL**: turnip hash and fish stew through `_make_food` and `_eat_food`; the any-crop turnip bug; board empty before the turnips; three notices with coins over the stand and no impossible asks; take, short refusal, hand-in, never twice; any fish spent cheapest first, nothing negative; a prepared notice cooked at the fire and handed in; rotation, decline without penalty, no same-week re-roll; expiry (untaken replaced, taken kept); save/load with taken notices and history, no re-roll after loading; alpha saves with the turnips done and open; malformed notice data dropped; panel action strings; Thomas's line naming the delivery, and not days later |
| `town_test` | 65 / 0 |
| `save_test` | 66 / 0 |
| `menu_test` | 854 / 0 (every panel incl. the village's, keys, pad, mouse) |
| `evening_test`, `playable002_test` | 166 / 0, 79 / 0 |
| `interior`, `mail`, `debug_menu`, `diary`, `wheel`, `layout`, `farmer`, `creature`, `aoh2_e2/e3/e5`, `aoh_cave_check`, `diary_fit` | all pass, 0 FAIL |
| `aoh_trek_check` | **FAIL on its timing threshold only**: slowest trek build 55-67 ms alone (limit 50; 190 ms in the parallel run). The alpha report measured 34.8 ms alone. No trek code changed here (`git diff` of `trek_system.gd`/`trek_art.gd` is empty); see known issues |

Logs: `art/style_tests/CCH-CORE-LOOP-003/logs/test_*.log`, `suite_summary.txt`.

**Played (injected input, a bot, not a human; `tools/town_play.gd -- scenario=orders`, windowed, 60 fps fixed):**
keyboard/mouse **PASS** and Xbox controller **PASS**, 19 steps each. SETUP (controlled): day 2, 09:00, 14 turnips,
3 perch, 40 coins. Played: the east gate (asked once, then walked down), Thomas's first scene, the turnip order
handed in (+70), **the notice board opened by facing it** (three notices: 6 turnips 70, 2 grilled fish 25, 3 fish
25), two taken, one declined (coins unchanged), back to the counter, **produce handed in (+70, 6 turnips gone)**,
**household handed in (+25, all fish gone)**, no second payment, Thomas's line names the fish, up the road home.
Logs `play_kbm/log_orders.txt`, `play_pad/log_orders.txt`; screenshots alongside. A fog-pinned rerun
(`work/orders_fog/`) supplies the review sheets.
The first played pass caught a real bug: on the day of both the turnip order and a notice, Thomas spoke of the
turnips. The newest delivery's line now wins, and `orders_test` checks the exact line (the old check matched the
word "turnips" in the wrong line).

**Simulated (`balance_sim`, the game's own functions, no village visits):** engaged 400 days treks=3; cozy 180;
ignore 160. Every chapter and the second year's beats and the Elias ending (day 399) in the engaged run, as
before; hours with food empty: 0 in all three; water 0; warmth 1 / 54 / 1.25. Winter: coins and sanity follow the
known pattern (sanity dips at the first Hollow nights around day 81-101). Food is not a winter constraint;
warmth is. The sim never visits the village, so it says nothing about notices.

**Data:** `tools/food_audit.gd` (**new**), before/after tables in `logs/`.

**Story chapters and endings:** not re-run as sequences; the engaged sim reaches all chapters and the Elias
ending. Nothing in story, night or ending code changed.

## 8. Known issues and deferred work

- **Fixed after the first commit: the village washed out from a player's second launch.** Played runs on a reused
  profile showed the street under a pale wash with lamp-sized light squares. It isn't weather: an overcast rerun on
  the same profile did it too. A fresh profile, or the same profile with its `shader_cache` folder deleted, rendered
  normally, and the second launch on that profile turned pale again (screen brightness 152 against 52-65 normal).
  So Godot's GL Compatibility shader cache brings something back wrong on load; the village shows it in daylight
  because its windows and lamps are lit all day. Neither filling in the fog shader's uniforms nor rewriting its
  Bayer table helped (both tried and reverted). **Fix:** `rendering/shader_compiler/shader_cache/enabled=false` in
  `project.godot` (only that line committed; the owner's other `project.godot` edits stay uncommitted). Shaders now
  compile at each start; the played run took 22-32 s either way. Verified: two launches on the old warm keyboard
  profile and one on the warm controller profile, all normal and PASS; `orders_test`, `town_test`, `save_test`,
  `menu_test` pass again. Sheet: `review/sheet3_shader_cache.png`. Not checked: whether the farm's night lights
  were affected on later launches (likely, as the same lights path), or whether a Godot update fixes the cache.
- `aoh_trek_check` misses its 50 ms build threshold alone (55-67 ms) on this machine today; trek code untouched.
  Not investigated further.
- Notices are all-at-once; no partial delivery. Taking notices from the farm (mailbox) was not built: the
  existing daily job (House panel) already gives the farm a daily delivery, and a second farm-side order screen
  would be a new interface.
- The notice board lists a "Leave it" row under each open notice (the ledger has one button per row), so it
  scrolls with three notices.
- Dried turnip stays redundant (2 turnips → 40 Hunger, less than raw, and turnips keep anyway). Most fire dishes
  still restore less Hunger than their raw parts; that's the restore formula, left alone on purpose.
- Prepared notices are delivered to Thomas on Edith's behalf; Edith herself says nothing about them yet.
- CCH-EVENING-002's played evidence is still incomplete (section 1).
- No human has played any of this.

## 9. Changed files

- `scripts/foods.gd` — turnip hash (1 turnip, +10 warmth), fish stew (1 turnip); two descriptions.
- `scripts/town_data.gd` — the turnip order asks for `"turnips"`; `ORDER_WEEK`, `ORDER_KINDS`, `REPEAT_ORDERS`,
  `REPEAT_DONE_LINES`.
- `scripts/town_system.gd` — the board, take/decline/hand in, rotation, Thomas's line, `history` memory hook,
  save/load with validation; the turnip order spends through `_spend_recipe_input`.
- `project.godot` — the shader cache off (one line).
- `scripts/town_art.gd` — the pinned paper shows while any notice is up (`notices_up`); drawing unchanged.
- `DESIGN.md` — Cooking table; Wicker Cove › repeatable notices, saving, tests, deferred.
- `tools/orders_test.gd` (new), `tools/food_audit.gd` (new), `tools/town_play.gd` (`scenario=orders`,
  `weather=` to pin the day's weather).
- `AI_COLLAB/CCH_CORE_LOOP_003_REPORT.md` (this), `AI_COLLAB/MESSAGE_BOARD.md`.
- `art/style_tests/CCH-CORE-LOOP-003/` — logs, played screenshots, review sheets and
  `review/CCH-CORE-LOOP-003_master.png` (no production art).

Commit links are on the message board.
