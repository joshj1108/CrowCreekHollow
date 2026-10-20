# Hallowvale — Design

A top-down farming game with heavy psychological horror, built in Godot 4.7.

## Pillars

- **Day is work, night is dread.** Each day is a farming shift. Night brings a horror encounter.
- **Atmosphere over jump scares.** Horror comes from lighting, sound, and escalating events.
- **Progress carries over.** Skills, the house, gear, quests, and sanity persist between sessions.
- **Homestead first.** Early quests teach the farm: planting, gathering, repairs, and light.

## Controls (Stardew-style)

- Move: WASD or arrow keys
- Use, plant, harvest, gather, sleep, tidy, cleanse, cook, talk, swing, or read: Space / Enter (face the tile)
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
- The Gear panel is a paper-doll grid of nine slots. The slots and crafting are described under Gear and crafting below.
- **Bags** (bought with coins, fiber, wood, and Carpentry level):

| Bag | Slots added | Cost | Carpentry |
|---|---|---|---|
| Satchel | +10 | 40 coins, 4 fiber | 1 |
| Haversack | +10 | 120 coins, 4 wood, 8 fiber | 3 |
| Backpack | +10 | 300 coins, 8 wood, 12 fiber | 5 |

- **Root cellar** (built from the House panel, stores **30 crops**): 25 coins, 4 wood, 2 fiber, Carpentry 1. They sit on the farm beside the house, so you can see them from the homestead. Stand beside the cellar, facing it, and press Space to store or take crops. Nothing spoils in the cellar. Storing is always manual: harvests go to the pack, and a harvest is refused if the pack is full.
- **Cooler** (built from the House panel, stores **10 fish**): 40 coins, 4 wood, 4 fiber, Carpentry 2. Fish kept in the cooler don't spoil. Stand beside the cooler, facing it, and press Space to store or take fish.
- **Fish spoil:** any fish still in the pack at the end of the day are lost. The end-of-day message says how many. Storing fish in the cooler is the only way to keep them overnight.
- **Full pack:** storage is always manual. A full pack stops harvesting and fishing with a message. Store fish in the cooler, or sell or cook them, to keep going.

**Smokehouse** (built from the House panel, beside the house): 60 coins, 5 wood, 3 fiber, Carpentry 3. Stand beside it, facing it, and press Space to preserve food. Preserved goods live in the pack and never spoil overnight.

| Method | Input | Needs | Makes | Sells | Skill |
|---|---|---|---|---|---|
| Smoke a fish | 1 fish | 1 wood | Smoked fish | 11 | Cooking 2 |
| Dry crops | 2 crops | none | Dried crops | 9 | Farming 2 |
| Can crops | 2 crops | 1 fiber | Canned crops | 10 | Cooking 3 |
| Ferment crops | 2 crops | 1 wood | Fermented crops | 11 | Cooking 4 |

Each press makes one item and gives XP in that skill. Preserved goods show in the pack and sell on the Trade panel.

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
- Saved: day, skill XP, inventory (including meals), coins, bag upgrades, root cellar, cooler, and smokehouse (built, and what they hold), materials, stats, story chapters done, achievements done, selected seed, lantern tier, house stage, tidy/mend/cleanse days, sanity and sanity penalty, crops (with kind), brush piles, **player position**, whether you were **inside the house**, and the **open panel**.
- Quitting mid-day loses that day's progress since the last save. Position and panel are saved at the same moment, so they reflect the last sleep or collapse.

## The roads: Lowmere and Ashford

The homestead is your base. Past the east end of the farm path is a gate onto the road to **Lowmere**. East of Lowmere, the road continues to **Ashford**.

- **Daytime only.** Walk the roads between 06:00 and 18:00. At dusk a gate pushes you back, and if night falls while you're in a village, you're driven home.
- **Sleep and storage stay at the homestead.** You can't sleep in a village.
- **Villagers** talk with you when you face them and press Space. Their lines change as the guardian quests advance.
  - Lowmere: Mara the Reeve, Tomas the Baker (takes a cooked meal), Elsie.
  - Ashford: Harrow the Miller (takes five crops for flour), Wren.

## Combat (real time)

Combat happens while you move, in the style of Stardew Valley.

- **Swing:** press Space to swing your right-hand weapon in the direction you face. A swing reaches 1.5 tiles in a forward arc and has a 0.5 second cooldown. Villagers still take priority: if one is in front, Space talks to them.
- **Foes roam** their area and wander when you're far away. They **chase** you when you're within their aggro range. Each foe has a contact attack on a cooldown.
  - **Hollow** (Lowmere wood): 6 HP, slow, 2 damage, aggro 3 tiles.
  - **Stalker** (the Ashford road): 10 HP, fast, 3 damage, aggro 4.5 tiles, drops resin.
- **Damage:** a swing deals your weapon's damage plus a random bonus of up to half your Combat level. Foe hits are reduced by your total armor defense, with a minimum of 1.
- **Invulnerability:** after you're hit, you have 0.9 seconds of safety and you're knocked back a little.
- **Kills** give Combat XP (20 for hollows, 30 for stalkers) and sometimes a material drop: fiber from hollows, resin from stalkers.
- **Combat** is a skill (`Level = 1 + XP / 100`). Each hit gives 4 XP. Max HP is 10 plus Combat level − 1.
- A meal heals 4 HP. Sleeping restores full HP. Losing all HP sends you home, shaken, with a 10 sanity penalty.

## Gear and crafting

The Gear panel has ten slots in four columns: Back (your bag), Head, Neck, Belt (lantern), Off hand (shield), Chest, Main hand (weapon), Wrist, Legs, and Feet. The lantern hangs from the belt, so the offhand is free for a shield.

Gear is crafted from the Gear panel with wood, fiber, and resin. Crafting equips the piece at once and replaces whatever was in that slot.

| Piece | Slot | Effect | Bushcrafting | Cost |
|---|---|---|---|---|
| Hoe | Right hand | 1 damage (starting) | 1 | free |
| Sharpened stick | Right hand | 2 damage | 2 | 2 wood, 1 fiber |
| Hunting knife | Right hand | 3 damage | 4 | 2 wood, 2 resin |
| Resin cap | Head | +1 defense | 2 | 2 resin, 2 fiber |
| Fiber wraps | Wrist | +1 defense | 1 | 3 fiber |
| Bark wrap | Chest | +2 defense | 3 | 3 wood, 3 fiber |
| Bark boots | Feet | +1 defense | 3 | 2 wood, 2 fiber |
| Twine collar | Neck | +1 defense | 2 | 3 fiber |
| Resin amulet | Neck | +2 defense | 5 | 3 resin, 2 fiber |
| Reed leggings | Legs | +1 defense | 1 | 4 fiber |
| Bark greaves | Legs | +2 defense | 4 | 3 wood, 3 fiber |

Crafting gives 10 Bushcrafting XP.

Quests in the Quests panel, under Guardian of Lowmere, run in order:

| # | Quest | Goal | Reward |
|---|---|---|---|
| 1 | Meet the Village | Talk with villagers (3 conversations) | 20 coins |
| 2 | The First Horror | Defeat 3 hollows | 60 Combat XP |
| 3 | Bread for Tomas | Bring a meal to Tomas | 40 coins |
| 4 | Hold the Road | Defeat 10 hollows in total | 80 coins, 3 pumpkin seeds |
| 5 | The Road East | Reach Ashford | 50 coins |
| 6 | Flour for the Mill | Give 5 crops to Harrow | 60 coins, 2 pumpkin seeds |
| 7 | Stalkers on the Road | Defeat 5 stalkers | 120 Combat XP |

Later: more villages and roads, more creatures, and guardian quests that need combat or exploration. Defense stacks across slots, so a full set can turn most hits into single points of damage. That needs a playtest before it is tuned.

## Forestry and tools

- **Forestry** trains by felling trees. A grove of five trees sits in the top-left corner of the farm. Each tree gives 3 wood, and 2 hardwood with a copper hatchet or better, and 20 Forestry XP. Felled trees come back each morning.
- **Hatchets** and **picks** are tools with tiers. They are crafted from the Tools section of the Gear panel and are kept by tier rather than worn in a slot. Hatchet tiers: crude, stone, copper, iron. Pick tiers: stone, copper, iron.
- A hatchet is needed to fell trees. Hardwood needs a copper hatchet or better.

## Mining

- **Rocks** sit on the farm at five spots. Each one comes back each morning, like brush piles.
- Breaking a rock **by hand** gives 1 stone. That gets you the first stone pick.
- With a **pick**, a rock gives 2 stone and 12 Mining XP.
- From **Mining 2**, a pick also gives a 15% chance of **copper ore** per rock. Farm rocks never give iron.
- Stone is worth little on its own. It goes into the stone hatchet and stone pick.

## Smithing and metal gear

- **Furnace** (built from the House panel beside the house): 80 coins, 6 wood, 4 stone, Carpentry 4. Stand beside it, facing it, and press Space to smelt.
- **Smelting** turns one ore and one wood into a bar. Copper needs Smithing 1. Iron needs Smithing 4. Smelting gives 10 Smithing XP.
- **Metal gear replaces bark slot by slot.** Each bark piece has a metal version in the same slot:

| Slot | Bark | Copper (Smithing 2 to 3) | Iron (Smithing 5 to 6) |
|---|---|---|---|
| Head | Resin cap | Copper helm, 2 defense | Iron helm, 3 defense |
| Neck | Twine collar, resin amulet | Copper torc, 2 defense | Iron torc, 3 defense |
| Chest | Bark wrap | Copper cuirass, 3 defense | Iron cuirass, 4 defense |
| Main hand | Sharpened stick, hunting knife | Copper sword, 4 damage | Iron sword, 6 damage |
| Wrist | Fiber wraps | Copper bracers, 2 defense | Iron gauntlets, 3 defense |
| Legs | Reed leggings, bark greaves | Copper greaves, 2 defense | Iron greaves, 3 defense |
| Feet | Bark boots | Copper boots, 2 defense | Iron sabatons, 3 defense |

- The Gear panel has a **Tools** section. Hatchets and picks are upgraded there one tier at a time, in order.
- The action bar panel now scrolls, so long crafting lists fit on screen.

## Gathering and metal (planned)

Bark is the starting tier and metal is the later one. Each bark piece has a metal piece for the same slot. The metal piece is better, needs Smithing, and takes that slot once you have it. Bark pieces stay craftable early on.

Each gathering skill has its own tool. The tool's material sets what it can break.

| Skill | Gathered from | Tool | Gives |
|---|---|---|---|
| Bushcrafting (existing) | Brush piles, thickets | None | Wood, fiber, resin |
| Forestry | Trees on the farm edge and in the Lowmere wood | Hatchet | Wood, hardwood |
| Mining | Rocks on the farm, the Ashford quarry | Pick | Stone; copper and iron ore |
| Smithing | A furnace built from the House panel | None | Bars from ore and wood; metal gear and tools from bars |

**Hardwood is a key material.** It goes into tool handles and smithing fuel, and into the weapons and gear below.

- **Shields** (offhand) are made from hardwood and metal.
- **Bows and crossbows** (ranged, right hand) are made from hardwood. Crossbows also need metal parts. Both need ammunition, which is not designed yet.
- **Wands and staves** (magic) are made from hardwood once magic exists. Magic is not designed yet.

**Ore never comes from the farm.** Copper and iron come from the Ashford quarry only.

**Farm rocks** are cleared like brush piles and mostly give stone, which is worth little. From Mining 2 there is a small chance of copper ore instead.

**Tool tiers:** a stone hatchet or pick (from farm stone) comes after the first tools. Copper tools come from Smithing, and iron tools after that. Trees need any hatchet. Hardwood needs a copper hatchet or better. Copper ore needs a pick. Iron ore needs a copper pick or better.

**Build order:**
1. Forestry, starting with a crude hatchet made from wood and fiber.
2. Mining on farm rocks, which gives stone and the first pick.
3. Smithing and the furnace, with copper bars and the first metal pieces.
4. The Ashford quarry, with iron ore and the top metal tier.

Levels here are placeholders and will be tuned once the systems exist.

**Decided:** the offhand (left hand) is for the shield. The lantern moves to a **belt** slot, so it can be worn without taking a hand. The lantern keeps its light ring and upgrades as before. Moving it is a grid change to be made when shields are built.

## Deferred

- The story beyond the survival chapters: mystery and horror escalation.

## Open decisions

- Whether the house interior should become a separate scene.
- Whether the tile map moves to a `TileMapLayer` with a real `TileSet` once art is in.
