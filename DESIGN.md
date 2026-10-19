# Hallowvale — Design

A top-down farming game with heavy psychological horror, built in Godot 4.7.

## Pillars

- **Day is work, night is dread.** Each day is a farming shift. Night brings a horror encounter.
- **Atmosphere over jump scares.** Horror comes from lighting, sound, and escalating events.
- **Progress carries over.** Skills, the house, gear, quests, and sanity persist between sessions.
- **Homestead first.** Early quests teach the farm: planting, gathering, repairs, and light.

## Controls (Stardew-style)

- Move: WASD or arrow keys
- Use, plant, harvest, gather, sleep, tidy, cleanse, cook, or read: Space / Enter (face the tile)
- Walk into the farmhouse door to go inside. Walk onto the exit mat to leave.
- Action bar (click or key): Skills K, Inventory I, Gear G, Quests Q, House H, Achievements J, Settings
- Esc opens Settings, or closes it if it's already open
- Farming and gathering pause while a panel is open

## Gamepad (Xbox layout)

- Move: left stick or D-pad (0.3 deadzone)
- Use, plant, harvest, gather, sleep: A
- Close the open panel: B
- Inventory X, Skills Y, Gear left bumper, Quests right bumper, House Back/View, Settings Start
- While a panel is open, the D-pad or left stick moves focus between its buttons, and A presses the highlighted one. The first usable button is highlighted when a panel opens.
- Keyboard and gamepad share the same actions, so both work at once.

## Action bar

- Tab buttons along the bottom. A panel opens above the bar for the active tab.
- Each panel lists rows: name, value, and optional buttons or progress bars.
- Panels rebuild only when their content changes, so buttons don't disappear mid-click.
- The open panel is saved and reopened on load.

## Art

- 16×16 base tiles, scaled 3× in-game (`SCALE = 3`), nearest-neighbor filtering.
- Warm, saturated daytime palette. Night uses a cool, shadowy tint via `CanvasModulate`.
- Placeholder art is drawn in code. Real licensed or commissioned pixel art replaces it later without touching game logic.

## Map

- A 40×24 walkable farm surrounded by a tree border, so the camera stays centered on the player all the way to the farm's edge.
- Two plots: **Plot one** is tilled from the start. **Plot two** is overgrown and opens at Farming 2.
- Trees, water, the house walls, and brush piles block movement. The player slides along walls.
- A minimap in the top-right shows the farm, the house, brush piles, the player, and the shadow on event nights.
- The farmhouse interior sits below the farm and has its own camera bounds.

## Day and night

- The day runs **06:00 to 03:00** the next morning.
- Darkness starts at 19:00.
- The bed can be used from **18:00 to 03:00**. Using it saves the game and ends the day.
- If you aren't in bed by **03:00**, you collapse. The day ends, the game saves, and your **sanity limit drops by 5 permanently**. A cleanse can recover it (see Sanity).
- Crops grow one stage per day, and brush piles respawn each morning. Thicket piles appear at Bushcrafting 3.

## Story chapters

The story is taught through survival. Chapters run in order. The first unfinished one is the **Current chapter** at the top of the Quests panel, with its narrative beat. Each chapter pays a reward once, then the next one opens. The rest of the story is deferred.

| # | Chapter | Goal | Reward |
|---|---|---|---|
| 1 | Unfamiliar Ground | Plant 3 seeds | 5 turnip seeds |
| 2 | Food Takes Time | Harvest 1 crop | 50 Farming XP |
| 3 | Wood Before Walls | Gather from 3 brush piles | 2 wood, 2 fiber |
| 4 | Hold the Door | Repair the house to Boarded | 2 wood, 2 fiber |
| 5 | Work the Pond | Catch 3 fish | 40 Fishing XP |
| 6 | A Fire and a Pan | Cook a meal | 30 Cooking XP |
| 7 | Light the Way | Build a Tin Lantern | 3 turnip seeds |
| 8 | Sleep Under Your Own Roof | Sleep in the bed before 03:00 | 40 Carpentry XP |
| 9 | The Overgrown Plot | Reach Farming 2 (opens plot two) | 3 pumpkin seeds |
| 10 | A Clean Start | Repair to Patched and tidy once | 40 Cleaning XP |
| 11 | Feed Yourself Through the Cold | Harvest 10 crops | 60 Farming XP |
| 12 | Coin for Seed | Sell 5 items at the stall | 30 coins |
| 13 | Something Sweeter | Harvest a pumpkin (Farming 3) | 2 pumpkin seeds |
| 14 | Clear the Stain | Cleanse the house once | 40 Cleaning XP |
| 15 | A Home Worth Keeping | Restore the farmhouse fully | 60 Cleaning XP |

Saves from before this change reset chapter progress. Stat-based achievements re-check from saved stats, so some rewards may be paid again.

## Money and the stall

- Coins are the money. The HUD shows them, and they're saved.
- The **stall** sits on the path east of the house. It is open **06:00 to 18:00**. Walk up to it and press Space to trade.
- The stall **only buys what you carry**. Take crops or fish out of storage first.
- Sell prices: crops 4 each, fish 6 each, meals 8 each.
- Buy seeds: 5 turnip seeds for 15 coins, or 3 pumpkin seeds for 30 coins at Farming 3.

## Pack, bags, and storage

- The **pack** holds crops, fish, and meals. Seeds have their own pouch and don't count. Materials are uncapped for now.
- The pack starts at **20 slots**. The Inventory panel shows it as a grid of slots, one per unit, like a bag in World of Warcraft or Old School RuneScape. Filled slots show what they hold, and empty slots are dark. The next bag is listed under the grid.
- The seed pouch is a small grid with a count on each seed type.
- The Gear panel is a paper-doll grid: Head, Back (your bag), Light (your lantern), Hand (hoe), and locked Body and Feet slots for later.
- **Bags** (bought with coins, fiber, wood, and Carpentry level):

| Bag | Slots added | Cost | Carpentry |
|---|---|---|---|
| Satchel | +10 | 40 coins, 4 fiber | 1 |
| Haversack | +10 | 120 coins, 4 wood, 8 fiber | 3 |
| Backpack | +10 | 300 coins, 8 wood, 12 fiber | 5 |

- **Root cellar** (built from the House panel, stores **30 crops**): 25 coins, 4 wood, 2 fiber, Carpentry 1. Stand at it and press Space to store or take crops. Nothing spoils in the cellar. Storing is always manual: harvests go to the pack, and a harvest is refused if the pack is full.
- **Cooler** (built from the House panel, stores **10 fish**): 40 coins, 4 wood, 4 fiber, Carpentry 2. Fish kept in the cooler don't spoil. Stand at it and press Space to store or take fish.
- **Fish spoil:** any fish still in the pack at the end of the day are lost. The end-of-day message says how many. Storing fish in the cooler is the only way to keep them overnight.
- **Full pack:** storage is always manual. A full pack stops harvesting and fishing with a message. Store fish in the cooler, or sell or cook them, to keep going.

Later preservation (smokehouse, dehydrating, canning, fermenting) is planned but not built.

## Achievements

Achievements are a tiered list toward 100% completion, shown in the Achievements panel (J, or the right stick click on a gamepad). The panel shows overall completion at the top, then four tiers with their own counts:

- **Tier I: Settler** (9): first steps such as planting, catching, cooking, sleeping, and a first repair.
- **Tier II: Homesteader** (9): steady use of the systems, such as 10 harvests, mending, and level 2 skills.
- **Tier III: Keeper** (9): full restoration, pumpkins, cleansing, and level 3 skills.
- **Tier IV: Hollow Hand** (9): mastery. Level 5 skills, 100 harvests, 50 meals, and finishing the story.

Achievements track stats and never reset. Each pays a small reward. Earning all 36 gives 100%.

## Cooking

- Cooking is a skill (`Level = 1 + XP / 100`).
- In the Inventory panel, **Cook a fish** uses 1 fish and 1 wood for 1 meal (15 XP). **Cook crops** uses 2 crops and 1 wood for 1 meal (10 XP).
- **Eat a meal** uses one meal for +8 sanity.

## Farming and crops

- Two crop kinds:
  - **Turnip** (starter): yields 1 crop and 1 seed back. 25 XP.
  - **Pumpkin** (Farming 3): yields 3 crops and 1 pumpkin seed back. 40 XP.
- Planting uses the **selected seed**. Switch it in the Inventory panel (Farming 3 and up). If you pick pumpkin before Farming 3, turnip is planted.
- Planting gives 5 XP.
- Plot two stays overgrown until Farming 2. Walking up to it says so.

## Farmhouse

- Starts at its final size in a **Decrepit** state. Repairs change its condition, not its footprint.
- Stages: Decrepit → Boarded → Patched → Restored.
- Repairs cost wood and fiber and need a Carpentry level:

| Repair to | Wood | Fiber | Carpentry |
|---|---|---|---|
| Boarded | 3 | 2 | 1 |
| Patched | 5 | 4 | 2 |
| Restored | 8 | 6 | 3 |

- The hall and bedroom are open from the start, so the bed is usable right away. Other rooms open as the house is repaired:
  - **Hall:** open from the start, with the exit mat.
  - **Bedroom:** open from the start. The bed saves and ends the day.
  - **Parlor (Patched):** a cleaning station. Tidy once a day for Cleaning XP.
  - **Study (Restored):** a desk.
- A restored house softens the night overall.
- **Cleanse** (House panel): needs Cleaning 3 and 2 harvested crops. Once a day. Lifts the sanity limit by 5 and cures part of the collapse penalty.

## Skills (RuneScape-style)

- Five skills, each with XP and levels (`Level = 1 + XP / 100`):
  - **Farming:** planting gives 5 XP. Turnips give 25 XP and pumpkins give 40 XP on harvest. Level 2 opens plot two. Level 3 unlocks pumpkins.
  - **Bushcrafting:** gathering a brush pile gives 10 XP. Level 3 adds three thicket piles.
  - **Carpentry:** each house repair gives 30 XP. Mending a board (1 wood, 1 fiber, from the House panel) gives 15 XP, capped at 2 mends per day so the house can't be finished in one day. Training to level 2 takes about 3 days, and level 3 takes about a week.
  - **Cleaning:** each daily tidy gives 20 XP. At Cleaning 2, a tidy also gives +5 sanity. Cleaning 3 unlocks the cleanse.
  - **Cooking:** cooking a fish gives 15 XP and cooking crops gives 10 XP. See Cooking above.
  - **Fishing:** face a sparkling spot on the pond edge and press Space to start fishing it, like RuneScape. While you keep still and face the spot, you roll for a catch every 3 seconds. The chance starts at 50% and rises 3% per level, up to 90%. Each catch gives 15 XP. Each spot stays active for 15 to 30 seconds, then goes quiet and a new spot appears elsewhere on the pond edge. There are 3 spots, with one more at Fishing 3 and another at Fishing 5. Moving, going inside, opening a panel, or pressing Space again reels the line in.
- Levels will unlock new areas, tools, and fortifications.

## Survival (bushcrafting and lanterns)

- Brush piles give wood and fiber, and sometimes resin.
- Lanterns are built in the Gear panel. Each tier lights a ring around the player in the dark:

| Tier | Ring | Needs | Bushcrafting |
|---|---|---|---|
| Tin Lantern | 2.5 tiles | 2 wood, 2 fiber | 2 |
| Brass Lantern | 4 tiles | 4 wood, 4 fiber, 2 resin | 4 |
| Hollow Lantern | 6 tiles, flickers | 6 wood, 6 fiber, 4 resin | 6 |

- No hunger or thirst.

## Sanity and horror

- Sanity runs from 0 to a maximum that drops with each collapse. It shows in the HUD as `Sanity current/max`.
- Outdoors in the dark, sanity drains slowly. Indoors it recovers, faster once the house is boarded. Tidying gives +10 (+5 more at Cleaning 2), and sleeping gives +25.
- Below 30 sanity, the whole screen gets darker.
- Night events vary by day and change sanity:
  - Something at the edge of the field (−5)
  - Knocks on the house wall (−10)
  - A figure watching by the house (−15)
  - A quiet night (−3)
- The field shadow creeps closer each night.
- **Collapse penalty:** missing the bed by 03:00 lowers the sanity limit by 5 permanently. A **cleanse** (see Farmhouse) lifts it by 5 per use, once a day.

## Saving

- The game saves **only** when you sleep in bed or collapse at 03:00.
- Saved: day, skill XP, inventory (including meals), coins, bag upgrades, root cellar and cooler (built, and what they hold), materials, stats, story chapters done, achievements done, selected seed, lantern tier, house stage, tidy/mend/cleanse days, sanity and sanity penalty, crops (with kind), brush piles, **player position**, whether you were **inside the house**, and the **open panel**.
- Quitting mid-day loses that day's progress since the last save. Position and panel are saved at the same moment, so they reflect the last sleep or collapse.

## Deferred

- The story beyond the survival chapters: mystery and horror escalation.

## Open decisions

- Whether the house interior should become a separate scene.
- Whether the tile map moves to a `TileMapLayer` with a real `TileSet` once art is in.
