# Hallowvale — Design

A top-down farming game with heavy psychological horror, built in Godot 4.7.

## Pillars

- **Day is work, night is dread.** Each day is a farming shift. Night brings a horror encounter.
- **Atmosphere over jump scares.** Horror comes from lighting, sound, and escalating events.
- **Progress carries over.** Skills, the house, gear, quests, and sanity persist between sessions.
- **Homestead first.** Early quests teach the farm: planting, gathering, repairs, and light.

## Controls (Stardew-style)

- **Section wheel.** Shift, or a click on the left stick, opens a ring of the menus that aren't in the bag: Skills, Gear, Craft, Quests, House, Buildings, and Achievements. The mouse hovers and clicks a section. On a controller the left stick highlights one and A opens it. B or Esc closes the wheel, and from a section returns to the wheel. Choosing a section closes the wheel and shows that section alone. Sections can't be opened while the wheel is up, the bag is up, or another section is open.

- Move: WASD or arrow keys
- Hand actions (talk, sleep, tidy, cleanse, cook, gather brush, drink from the pond, open panels, confirm placement, rest at camp): Space or A, facing the tile.
- Tool and weapon actions (hoe, hose, trowel, axe, pick, rod, sword, bow): RT or a left click, facing the tile. A tool press on a tool target with the wrong tool in hand says which tool to select. With the trowel in hand, the D-pad up and down, or Z and X on the keyboard, cycle the seed you plant (the left stick does not) (turnip, then pumpkin once Farming reaches its level, skipping any you have none of), and do not walk you. A hand press on one says to use RT or click.
- Walk into the farmhouse door to go inside. Walk onto the exit mat to leave.
- The section wheel: Shift opens it (see Section wheel below). Settings is Esc only. The Inventory is opened from the bag (Tab).
- The bag (grid, bottom-right corner): Tab opens and closes it. Click a slot to use it, or move with the arrow keys and press Enter.
- Esc closes whatever is open, the bag, the wheel, or a section, one at a time. With nothing open, Esc opens Settings. Esc or Start closes Settings. B closes the same things as Esc, and dismisses a tip when nothing is open. On the keyboard, Backspace dismisses a tip (and does nothing else), so Esc stays free for Settings.
- Stuck while placing or boxed in? Esc opens Settings, which cancels any placement. The **Unstick** button in the Game section moves you to the nearest open ground (grass, path, soil, fallow) from the farmhouse door, and works on the farm only.
- Farming and gathering pause while a panel is open
- **Dev (debug builds only):** F4, or **Unlock** in the Game section of Settings, sets every skill to level 10 and gives 99,999 coins, 999 of each material and 99 of each seed. It also gives every tool, lantern and bag tier, restores the house, builds the pump, hose and storage buildings, and fills the needs. The coop and barn still need placing from the Buildings panel. Exported release builds ignore F4 and hide the button. It isn't on F9 because the Godot editor uses F9 to suspend a game running in its Game tab.

## Gamepad (Xbox layout)

- Move: left stick or D-pad (0.3 deadzone)
- Use, plant, harvest, gather, sleep: A
- Close the open panel: B
- Bag Y, section wheel left stick click, Settings Start, Close B
- The bag: Y opens and closes it, the D-pad moves between its slots, A uses the slot in focus, B closes it.
- While a panel is open, the D-pad or left stick moves focus between its buttons, and A presses the highlighted one. The first usable button is highlighted when a panel opens.
- Keyboard and gamepad share the same actions, so both work at once.

## Action bar

- Messages sit at the bottom-left of the screen, clear of the farm's labels. HUD and message text have a dark outline so they read over any ground.
- Trees are SpriteCook sprites (`art/farm/tree_*.png`), 32×48: two tiles wide and three tall, standing on the bottom centre of their tile. Kinds are autumn oaks, Douglas firs, willows and dead trees, picked by a hash of the tile. The forest border is mostly firs with oaks mixed in; the grove inside the farm is mostly oaks. Out of every twelve trees, one is dead. Willows grow where the layout lists them, by the pond. Each tree is nudged a few pixels by its position, and border trees overlap, so the outer forest reads as dense woodland. Trees block movement. Trees on or north of the player's row are drawn with the ground, behind the player; those south of it are drawn over the player (`tree_front_layer`). A felled grove tree leaves a stump.
- **The great tree** is a 3 by 3 block of trees in the middle of the yard. It can't be felled, and the game says so when you face it. The crows roost in its crown from 20:00 and leave at dawn. Their eyes glow red, bright enough to show through the night tint, and each roost perch has a faint red light while a crow sits there. Crows are SpriteCook art: a perched sprite, and a four-frame flight cycle that follows each crow's flap. The roost perches sit on the great tree's art (`ROOST_SPOTS`): the two bare branch tips and two spots on top of the crown.
- Rocks on the farm, and quarry rocks in the village, block movement like trees. You can still break a rock from the tile next to it.
- Storage labels (Cellar, Smoke, Furnace) stay on screen when their building is at the view's edge.
- The farm's buildings hug the house: the cellar against the west wall. The workshop is a walled building south-east of the farm centre, 7 by 6, with a door on its south side. Its furnace and smokehouse stand inside. The cooler is inside the house. The workshop, coop, and barn are built and moved from the Buildings menu (U).

- A small **Menu** button sits in the bottom-right corner for mouse players. It opens the section wheel, and hides while a section is open. A section is shown alone, full screen, with its options and a Close button. It never lists the other sections, so the only way to another section is to close it and open the wheel again.
- Quests are collapsed to a line: the title, and Done or the progress count. A Details button opens the story, reward, and progress bar, and Hide closes it. The current chapter starts open.
- Completed quests show their title struck through.
- Settings sections fold. Each header shows its item count and opens with Enter or A, or a click, so only the headings show until you open one. Every section starts folded.
- Each section lists its options as cards: name, value, and an optional button or progress bar. The Craft panel is the exception: it is a picture grid (see Gear and crafting). The other sections use the card layout.
- **Any open menu pauses the day.** While any section is open (Skills, Inventory, Craft, Quests, shops, the bank, Settings, and the rest) the clock stops, foes stand still, and the player can't move. Closing the menu resumes the day where it left off.
- Panels rebuild only when their content changes, so buttons don't disappear mid-click.
- The open panel is saved and reopened on load.

## Art

The farmer is a SpriteCook sprite (`art/player/`): a 16×32 figure in a straw hat, rust shirt and blue overalls, with 8-frame idles and walks facing down, up and right. Facing left mirrors the right-facing sheets. The idle facing away is one SpriteCook frame held still with a one-pixel breathing bob on the head and shoulders, because the generated back idles kept stepping in place. Tool actions have their own SpriteCook sheets, `farmer_<action>_<down|up|right>.png`, for the hoe, hose, axe, pickaxe, trowel, sword and casting: each plays across its action, and chop and mine loop with their cycle from frame 2 (the first two frames are the empty-handed idle). Waiting for a bite holds the cast's last frame, with a line drawn from the rod's tip to a bobber. The tool only shows while it is being used. A raised sword guard and firing a bow have no sheets yet, so those still draw the held tool in code over the sprite. There is no character creator: New Game goes straight into the game with this look. If the sheets are missing, the code-drawn farmer below is used. The code-drawn farmer has a straw hat with a band, a shirt under blue overalls with straps and a buckle, and boots. The face turns with the facing direction: eyes and a mouth when facing you, one eye to the side, and hair only from behind. While walking, the legs and arms swing in opposition and the body bobs with each step. A small marker in front shows what you'll interact with.

- 16×16 base tiles, scaled 3× in-game (`SCALE = 3`), nearest-neighbor filtering.
- Muted, desaturated daytime palette from the colour grade (see Graphics). Night uses a cool, shadowy tint via `CanvasModulate`.
- Placeholder art is drawn in code. Real licensed or commissioned pixel art replaces it later without touching game logic.

### UI skin

Menus, the bag, the hotbar, the HUD boxes, the tip card and the title screen use one SpriteCook UI kit: dark wood frames with iron corner brackets, wooden buttons (normal, hover, pressed, disabled; focus looks like hover), and framed slots with a gold edge when selected. The pieces in `art/ui/` are cut from the kit's component sheet at a third of its size and drawn as 9-slices whose edges stretch (`scripts/ui_skin.gd`). Cards inside a section use the slot frame. The food, water and warmth meters are the kit's bar: each bar is the channel, with tan, blue or orange fill, and the iron-capped frame is drawn around it so the fill's length matches the value. The minimap sits inside the panel's rail, drawn over its edges. The section wheel's curved segments can't be 9-sliced, so they are filled with the panel's wood grain (shaded, or lit when highlighted) with iron edges, gold on the highlight, and the section's name sits on a slot-framed plaque. Each segment's icon is SpriteCook art drawn at 3×: Gear and Craft use the shield and hammer item icons, and Skills, Quests, House, Buildings and Achievements use `art/ui/wheel_icons.png` (a journal, a sealed scroll, a farmhouse, a barn with a silo, and a trophy). If the art is missing, every control falls back to its flat style.

### Art style (locked)

All sprites are being remade in SpriteCook in one style. The older ChatGPT art in `art/farm/` is replaced piece by piece.

- **Chunky 16px pixel art.** Every sprite is drawn at 16 pixels per tile and shown at 3×. Never resample a sprite to fit: one art pixel is always three screen pixels.
- **Sizes are whole tiles.** A tile is 16×16. Characters are 16 wide and 32 tall (two tiles). Buildings and props are multiples of 16 where they can be, such as the farmhouse at 192×160 (12×10 tiles) and the well at 32×48 (2×3 tiles).
- **Straight-on top-down 3/4 view**, like Stardew Valley. Fronts face the camera. No angled or isometric views.
- **Muted, desaturated palette** with a Pacific Northwest autumn feel: mossy greens, weathered browns, grey stone. Dark outlines on every sprite. The horror comes from lighting and the night tint, not from gore in the art.
- **Style anchor:** `art/style_tests/house_chunky_b.png` (SpriteCook asset `f24bb014-3b8b-4d3c-9dde-a4a118c6d07d`). New sprites use it as a style reference.
- **Generation:** `pixel-engine-image-v1` for sprites drawn at an exact size. Models that take references use the style anchor. Every asset's ID is recorded in `spritecook-assets.json`.

## Map

- A 64×40 walkable farm surrounded by a tree border, so the camera stays centered on the player all the way to the farm's edge.
- Two plots: **Plot one** is tilled from the start. **Plot two** is overgrown and opens at Farming 2. A third fallow plot sits beside them and opens at Farming 4 once the house is Patched.
- The layout comes from a diagram (see Code layout). Fences and rocks block movement; the dock, the island and the path are walkable.
- Trees, water, the house walls, and brush piles block movement. The player slides along walls.
- A minimap in the top-right shows the farm, brush piles, the player, and the shadow on event nights. Its colours are graded toward the game's muted look (part way to grey, darker and a little cooler; `Minimap.grade`, also used for the world map), and each tile is shaded a little lighter or darker so fields and woods read as texture. The house, the well, the cave and the player are SpriteCook icons (`art/ui/minimap_icons.png`, four 16 px cells); without the art they fall back to blue squares and a dot.
- The farmhouse interior sits below the farm and has its own camera bounds. It is 22 by 20 tiles, sized for the two-tile-tall farmer.

## Day and night

- The day runs **06:00 to 03:00** the next morning.
- Darkness starts at 19:00.
- The bed can be used from **18:00 to 03:00**. Using it saves the game and ends the day.
- If you aren't in bed by **03:00**, you collapse. The day ends, the game saves, and your **sanity limit drops by 5 permanently**. A cleanse can recover it (see Sanity).
- Crops grow one watered day at a time: **turnips take 7 days** and **pumpkins take 10 days** from seed to ripe, with the four stages spread across those days. Brush piles respawn each morning. Thicket piles appear at Bushcrafting 3.
- Rain (drizzle, rain, or downpour) waters every crop as soon as it starts that morning, and a crop planted on a rainy day is watered too. Watered crops show a sparkle and a faint sheen (there is no blue drop), and the soil under them is darker. Turnips and pumpkins each have four stages: a sprout, leaves (pumpkins add a vine), a swelling fruit, and the ripe crop. Each crop's stages are one SpriteCook strip, `art/farm/crop_<kind>.png`, four 16-pixel frames side by side, so the stages match.

## Calendar, seasons, and weather

- Day 1 is **October 1st**, and months use their real lengths. The HUD shows the date and season, such as `Day 1, Oct 1 (Autumn)`.
- Seasons follow the Pacific Northwest: winter is December to February, spring is March to May, summer is June to August, and autumn is September to November.
- Each morning the weather is rolled from the season's weights, and it stays all day:
  - **Summer** is mostly sunny, with a few cloudy or foggy days.
  - **Spring and autumn** are cloudy, drizzly, and rainy, with the odd sunny or foggy day.
  - **Winter** is wet, with downpours, fog, and rare snow.
- Kinds of weather: sunny, overcast, foggy, drizzle, rain, downpour, and snow. Each has its own cloud cover, wash, edge darkening, rain or snowfall, and light colour.
- Weather is drawn in `scripts/weather.gd` and hidden inside the farmhouse and the mine.
- The weather of each day is saved. An older save with no weather gets a fresh roll on load.

## Sound effects

- Short sounds play for the things you do: footsteps (about every third of a second of walking), planting, harvesting, watering, eating, drinking, repairs, coins for catalog orders, opening and closing panels, entering and leaving the house, chopping and mining, gathering, achievements, goats bleating now and then, and thunder on some downpour mornings.
- The sounds are generated by `tools/make_sfx.py` (numpy synthesis, ffmpeg to OGG) and live in `audio/sfx/`. Each can be replaced by a file with the same name.
- A small pool of players lets sounds overlap, and each footstep and sound gets a little random pitch.
- **Sound effects** can be turned on or off under Game in Settings. The choice is saved with the music setting.

## Seasonal events

Each year has a few dated events. When one starts, the morning message announces it, the HUD shows its name while it lasts, and it counts toward the event achievements.

| Event | Date | Length | Effect |
|---|---|---|---|
| Harvest Moon | Sep 22 | 1 day | Two turnip hashes and +10 sanity when it starts |
| First Frost | Nov 10 | 3 days | Warmth drains 60% faster outdoors |
| The Longest Night | Dec 21 | 1 day | The night's sanity change is doubled |
| Spring Thaw | Mar 1 | 2 days | Watered crops grow an extra stage |
| Planting Fair | Apr 20 | 1 day | Five turnip seeds when it starts |
| Midsummer Heat | Jun 21 | 3 days | Every day is sunny |

- **All Hallows** (October 31): lanterns are lit along the road, so the dark costs half the usual sanity that night.
- **Winter Feast** (January 1): two grilled fish and a bandage go into the pack.

## Daily job

- The House panel (H) has one **daily job**, separate from the chores so skipping it adds no wear. It rotates each day through crops, fish, wood, stone, resin, cooked food, and preserves. Each asks for a few of those items, which are used up when you deliver them. Delivering pays coins and XP in the job's skill, and only one delivery counts per day.

## Music

- **Music** is a lo-fi loop (`audio/dreary_loop.ogg`) that starts on the title screen and loops quietly.
- It can be turned off in Settings under Game. The choice is saved to `user://hallowvale_settings.json`.
- The loop is generated by `tools/make_music.py` (numpy synthesis, seeded, 53 seconds). It is a placeholder that can be swapped for any OGG file at the same path.

## Story chapters

The story is taught through survival. Chapters run in order. The first unfinished one is the **Current chapter** at the top of the Quests panel, with its narrative beat. Each chapter pays a reward once, then the next one opens. The rest of the story is deferred.

| # | Chapter | Goal | Reward |
|---|---|---|---|
| 1 | Food Takes Time | Harvest 1 crop | 50 Farming XP |
| 2 | Light the Way | Build a Tin Lantern | 3 turnip seeds |
| 3 | Sleep Under Your Own Roof | Sleep in the bed before 03:00 | 40 Carpentry XP |
| 4 | The Overgrown Plot | Reach Farming 2 (opens plot two) | 3 pumpkin seeds |
| 5 | Feed Yourself Through the Cold | Harvest 10 crops | 60 Farming XP |
| 6 | Coin for Seed | Sell 5 items at the farm stand | 30 coins |
| 7 | Something Sweeter | Harvest a pumpkin (Farming 3) | 2 pumpkin seeds |
| 8 | Clear the Stain | Cleanse the house once | 40 Cleaning XP |
| 9 | A Home Worth Keeping | Restore the farmhouse fully | 60 Cleaning XP |

The first day's basics (planting, gathering, crafting, chopping, drinking) are taught by the guided first day under Tutorial tips, not by chapters.

Saves from before this change reset chapter progress. Stat-based achievements re-check from saved stats, so some rewards may be paid again.

## Money and the farm stand

- Coins are the money. The HUD shows them, and they're saved.
- The **farm stand** sits on the path east of the house. It is open **06:00 to 18:00**. Walk up to it and press Space to trade.
- The farm stand **only buys what you carry**. Take crops or fish out of storage first.
- Sell prices: turnips 8 each, pumpkins 30 each, fish 6 each, eggs 4 each, goat milk 6 each, and cooked food from 8 to 20 each, as listed on the Trade panel.
- The stand only sells. Seeds and livestock are ordered from the **catalog** at the desk (see Farmhouse).

## Pack, bags, and storage

- The **pack** holds crops, fish, eggs, milk, and every cooked food, each under its own name and picture. Seeds have their own pouch and don't count. Materials are uncapped for now.
- The pack starts at **20 slots**. Like items stack up to **28** to a slot, so a kind takes as many slots as its stacks need. Grid menus (Skills, Inventory, Craft, Gear) sit centred in the menu box. The Inventory panel (I) shows what you carry as a grid of picture tiles, one per kind with its count, like the Craft panel: the pack's crops, fish, meals, and preserved goods, then the seed pouch and the materials you hold. Every item has a drawn picture. The name shows only on the highlighted tile, and the bag works the same way: each slot shows a picture and count, with the name on the slot in focus. Picking a tile fills the detail card beside the grid, which holds the **Eat** button for crops and meals. The pack's slots used and the next bag are listed under the grid. The Body meters and the planting options sit below it.
- The seed pouch is a small grid with a count on each seed type.
- The Gear panel is a paper-doll grid of nine slots. The slots and crafting are described under Gear and crafting below.
- **Bags** (bought with coins, fiber, wood, and Carpentry level):

| Bag | Slots added | Cost | Carpentry |
|---|---|---|---|
| Satchel | +10 | 40 coins, 4 fiber | 1 |
| Haversack | +10 | 120 coins, 4 wood, 8 fiber | 3 |
| Backpack | +10 | 300 coins, 8 wood, 12 fiber | 5 |

- **Root cellar** (built from the House panel, stores **30 crops**): 25 coins, 4 wood, 2 fiber, Carpentry 1. It is dug against the house's west wall, so it reads as part of the house. Stand beside it, facing it, and press Space to store or take crops. Nothing spoils in the cellar. Storing is always manual: harvests go to the pack, and a harvest is refused if the pack is full.
- **Cooler** (built from the House panel, stores **10 fish**): 40 coins, 4 wood, 4 fiber, Carpentry 2. Fish kept in the cooler don't spoil. It sits inside the house, in the hall. Stand beside it, facing it, and press Space to store or take fish.
- **Fish spoil:** any fish still in the pack at the end of the day are lost. The end-of-day message says how many. Storing fish in the cooler is the only way to keep them overnight.
- **Full pack:** storage is always manual. A full pack stops harvesting and fishing with a message. Store fish in the cooler, or sell or cook them, to keep going.

**Smokehouse** (built from the Buildings menu, in the workshop): 60 coins, 5 wood, 3 fiber, Carpentry 3. Stand beside it, facing it, and press Space to preserve food. Preserved goods live in the pack and never spoil overnight.

| Method | Input | Needs | Makes | Sells | Skill |
|---|---|---|---|---|---|
| Smoke a fish | 1 fish | 1 wood | Smoked fish | 11 | Cooking 2 |
| Dry turnips | 2 turnips | none | Dried crops | 9 | Farming 2 |
| Can turnips | 2 turnips | 1 fiber | Canned turnip | 10 | Cooking 3 |
| Ferment turnips | 2 turnips | 1 wood | Fermented turnip | 11 | Cooking 4 |

Each press makes one item and gives XP in that skill. Preserved goods show in the pack and sell on the Trade panel.

## Achievements

Achievements are a tiered list toward 100% completion, shown in the Achievements panel (from the section wheel). The panel shows overall completion at the top, then four tiers with their own counts:

- **Tier I: Settler** (9): first steps such as planting, catching, cooking, sleeping, and a first repair.
- **Tier II: Homesteader** (9): steady use of the systems, such as 10 harvests, mending, and level 2 skills.
- **Tier III: Keeper** (9): full restoration, pumpkins, cleansing, and level 3 skills.
- **Tier IV: Hollow Hand** (9): mastery. Level 5 skills, 100 harvests, 50 meals, and finishing the story.

Achievements track stats and never reset. Each pays a small reward. Earning all 45 gives 100%. **Goat Keeper** is earned by buying a goat.

- New with the needs and well: **Cool Water** (drink from the pond or pump), **Hose Hand** (water a crop), **Working Pump** (repair the pump), **Garden Hose** (attach the hose), **Rain Keeps Them Green** (5 rainy days), and **Tender of the Plots** (water 50 crops). **Turning Seasons** (3 seasonal events) and **A Full Year** (6) count the events below.

## Firewood and warmth

- The **firewood store** and **chopping log** stand inside the workshop, on its two free floor tiles. Build them from the Buildings section (Shift, then Buildings) for 4 wood, 2 fiber, 40 coins, and Carpentry 2. They need the smokehouse or the furnace first.
- **Split wood** at the chopping log: hold the axe, stand beside the log, facing it, and press RT or click. Each press uses 1 wood and makes 2 firewood, stored up to 30 in the store. It gives Forestry XP.
- **Take firewood** from the store into your pack, or store what you carry, from the store's panel (Space).
- **Feed the hearth** in the house with one firewood (Space, facing the hearth). Each firewood burns for 3 hours, up to 12. The hearth's flames show only while it burns.
- **No fire, no warmth at home.** Indoors with the fire lit, you warm as before. With the fire out the house is as cold as outside, and sleeping does not restore warmth unless the fire is lit when you go to bed.
- You start with 4 firewood.

## Cooking

- Cooking is a skill (same level curve as Skills).
- Every cooked food is named for what made it and has its own picture. At the fire (the Craft panel's Cooking tab): **Grilled fish** (1 fish, 1 wood), **Turnip hash** (2 turnips, 1 wood), **Pumpkin soup** (2 pumpkins, 1 wood, Cooking 3), **Fish stew** (1 fish, 2 turnips, 1 wood, Cooking 3), and **Hearty stew** (1 smoked fish, 2 turnips, 1 wood, Cooking 5).
- At the smokehouse: smoked fish, dried turnip, canned turnip, and fermented turnip (see the table above).
- Each food has a difficulty (1 to 4) and the level needed to obtain it. Both set how much it restores, and cooking it gives XP in its skill.
- Foods are kept in the pack as their own stacks. Eat them from the bag or the Inventory panel.

## Farming and crops

- Three crop kinds:
  - **Turnip** (starter): yields 1 crop and 1 seed back. 25 XP. 7 days. Sells for 8.
  - **Corn** (Farming 2): yields 2 ears and 1 corn seed back. 30 XP. 8 days. Sells for 14. Seeds are 6 coins each, sold 4 at a time. Corn is food and animal feed like the other crops, but has no recipes and doesn't keep in the cellar. Art: `art/farm/crop_corn.png` (SpriteCook, four 16 px stages); its ripe frame is the corn icon in `art/ui/icons.png`.
  - **Pumpkin** (Farming 3): yields 3 crops and 1 pumpkin seed back. 40 XP. 10 days. Sells for 30.
- Planting uses the **selected seed**. Switch it in the Inventory panel once a second kind is unlocked; it steps through the unlocked kinds. If the selected kind isn't unlocked yet, turnip is planted.
- Feeding animals, offerings and Harrow's crops take turnips first, then corn, then pumpkins.
- Planting gives 5 XP.
- **Crops need water.** A crop grows overnight only if it was watered that day. A crop that wasn't watered stays at its stage, and the morning message says how many went thirsty. Watering is covered under Well and watering.
- Plot two stays overgrown until Farming 2. Walking up to it says so.

## Farmhouse

Inside, every room is drawn for the house's repair stage, so the rooms improve as you fix the house. The **bed** starts with a threadbare quilt and a darned patch, then gets a blue and then green quilt, and at Restored a fine red quilt with stitching. The **cleansing station** is a washstand with a basin of water, and at Restored it gets brass fittings, a mirror, and a candle. The **desk** has papers, an inkwell, and a lamp. The **fireplace** in the hall is cracked and cold when decrepit, has ash when boarded, burns when patched, and at Restored has a wooden mantel with candles and a warm glow. The hall has a table with chairs, and a rug from the Boarded stage. The walls and floors get lighter at each stage.

The house is drawn in SpriteCook art (`art/farm/int_*.png`, `_draw_interior_floor_sprite` and `_draw_interior_piece` in `main.gd`), sized against the farmer (16×32), like the farm was when he grew. The interior is 22 by 20 tiles: the bedroom, study and parlor (6 by 6 each) along the north, over a 20 by 6 hall. A wall facing a room shows three tiles of face (crown trim, plaster, wainscot), so the farmer stands about two thirds of its height; the wall between the rooms and the hall is a top row plus that face, with a two-tile doorway into each room. A room that isn't open yet is solid wall with no doorway. Floors are 32-pixel plank textures two tiles square: worn dark boards for Decrepit and Boarded, good boards for Patched and Restored, the first of each pair shaded a little darker. Walls are cracked plaster for the first two stages and clean after. Furniture stands on its footprint and rises over the wall behind it: the bed (32×47, one quilt per stage, 2 by 3 tiles), the desk (2 tiles wide, waist high), the washstand (plain, then restored), the cooler, the fireplace (32×57, two tiles wide: cracked and cold, cold, lit, mantel cold, mantel lit) and the dining set (a 48×32 table with two chairs facing you above it and two seen from behind below it, 3 by 4 tiles, all solid). The rug (6 by 3 tiles) lies in front of the hearth and the doormat sits in the south wall. Walls and furniture south of the farmer's row are drawn over him, so he walks behind the table and the wall into the hall. The furniture sprites replace the Bed, Desk and Cleaning labels; the cooler keeps its storage label.

The other buildings are drawn tile by tile, each tile showing its place in the building. The **coop** has a roofed top row, a hen door at the bottom-left, and a straw nest at the bottom-right. The **barn** has red boards, a roofed top row, an X-braced double door in the bottom-middle, and hay bales on the right. The **root cellar** is a planked hatch in a stone rim with an iron ring. The **workshop** floor is planked with staggered joins. The **furnace** shows a glowing firebox mouth, and the **smokehouse** has brick courses and slatted vents.

The house is drawn in four stages that match its repair level. **Decrepit** has a sagging eave, a missing roof patch, boarded windows, brick chimney, and a dark, planked door. **Boarded** has shingle courses on the roof and one board across each window. **Patched** has glazed windows with frames, green shutters, corner trim, and a panelled door with a brass knob. **Restored** adds window boxes of flowers, a ridge cap, a dark foundation, a lit lamp by the door, warm light in the windows, and a faint line of smoke from the chimney.

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
  - **Study (Restored):** an empty room. The desk stays in the bedroom.
  - **Pastimes:** the Desk panel has **Solitaire** (1 hour) and **Sudoku** (1 hour 30). They are not played out: Play passes that much time (needs drop and the fire burns as usual), closes the panel and entertains you for the day. Solitaire uses a game from the **pack of cards** (a worn pack with 5 games is in the drawer at the start; a new pack lasts 15). Sudoku uses a puzzle from the **sudoku book** (10 puzzles; none at the start). A pastime has to be over by 02:00.
  - **Catalog:** the Desk panel's catalog is where everything for the farm is bought. An order is paid at once and comes with the next morning's post, with a Delivery letter; animals go straight into their pens. It sells: a pack of cards (10 coins), a sudoku book (12), 5 turnip seeds (15), 4 corn seeds (24, Farming 2), 3 pumpkin seeds (30, Farming 3), a hen (12, needs the coop and room, counting hens on order), a goat (45, needs the barn and room). Nothing you can gather (wood, fiber, resin, stone, hardwood) is sold here. Pending orders are saved.
- A restored house softens the night overall.
- **Cleanse** (House panel): needs Cleaning 3 and 2 harvested crops. Once a day. Lifts the sanity limit by 5 and cures part of the collapse penalty.

## Skills (RuneScape-style)

- The Skills panel (K) is a grid of ten picture tiles, each showing the skill's drawing and its level. Picking one fills the detail card with what trains the skill, its XP bar, and the XP left to the next level.
- Ten skills, each with XP and levels. Each level costs more than the last: level 2 at 100 XP, level 3 at 300, level 4 at 600, level 5 at 1000, level 6 at 1500 (level L needs 50 × (L−1) × L XP in total):
  - **Farming:** planting gives 5 XP. Turnips give 25 XP and pumpkins give 40 XP on harvest. Level 2 opens plot two. Level 3 unlocks pumpkins.
  - **Bushcrafting:** gathering a brush pile gives 10 XP. Level 3 adds three thicket piles.
  - **Carpentry:** each house repair gives 30 XP. Mending a board (1 wood, 1 fiber, from the House panel) gives 15 XP, capped at 2 mends per day so the house can't be finished in one day. Training to level 2 takes about 3 days, and level 3 takes about a week.
  - **Cleaning:** each daily tidy gives 20 XP. At Cleaning 2, a tidy also gives +5 sanity. Cleaning 3 unlocks the cleanse.
  - **Cooking:** cooking a fish gives 15 XP and cooking crops gives 10 XP. See Cooking above.
  - **Fishing:** face a sparkling spot on the pond edge and press Space to start fishing it, like RuneScape. While you keep still and face the spot, you roll for a catch every 3 seconds. The chance starts at 50% and rises 3% per level, up to 90%. Each catch gives 15 XP. Each spot stays active for 15 to 30 seconds, then goes quiet and a new spot appears elsewhere on the pond edge. There are 3 spots, with one more at Fishing 3 and another at Fishing 5. Moving, going inside, opening a panel, or pressing Space again reels the line in.
- Levels will unlock new areas, tools, and fortifications.

## Survival (bushcrafting and lanterns)

- Brush piles give wood and fiber, and sometimes resin.
- Lanterns are built in the Craft panel, under Other. Each tier lights a ring around the player in the dark:

| Tier | Ring | Needs | Bushcrafting |
|---|---|---|---|
| Tin Lantern | 2.5 tiles | 2 wood, 2 fiber | 2 |
| Brass Lantern | 4 tiles | 4 wood, 4 fiber, 2 resin | 4 |
| Hollow Lantern | 6 tiles, flickers | 6 wood, 6 fiber, 4 resin | 6 |

- Hunger and thirst are covered under Body needs below.

- **Bandages** are in the Other tab (Bushcrafting 2: 2 fiber, 1 resin). Each heals 25 HP when used from the pack in the Inventory panel. A bandage is not used up when you are at full HP.
## Well and watering

- The **well** stands on the farm between plot one and the path, and starts seized. Stand beside it and press Space to open its panel.
- **Repairing the pump** costs 4 wood, 3 fiber, and Carpentry 2, and gives 30 Carpentry XP. It fills the tank, which holds 40 water.
- The tank refills each morning once the pump is working.
- **Attaching the hose** costs 3 fiber and 2 resin, and needs a working pump. The hose reaches every plot on the farm, so no plot is out of range.
- Once the hose is on, face a growing crop and press Space to water it. Each watering uses 1 water from the tank. A crop only needs one watering a day, and a second press that day says it's already watered.
- **Rain waters every crop** on a drizzly, rainy, or downpour day, so those crops grow without the hose. Sunny, overcast, fog, and snow days don't water.
- The Inventory's Planting section shows how many growing crops are watered today.
- The well's panel also drinks from the pump, for +35 water, at no cost.

## Body needs

- Three meters run from 0 to 100: **Food**, **Water**, and **Warmth**. They show on a line under the top bar, in red when one is under 25, and in full in the Body section of the Inventory menu (I), below the pack.
- **Food** drains about 2.4 an hour, so it runs out in about two days. Every food restores food, sanity and HP from its difficulty (1 to 4) and the level needed to obtain it: food = 10 + 12 × difficulty + 3 × level, sanity = 2 + 2 × difficulty + level, HP = difficulty. A raw turnip restores 22 food and a hearty stew 73. Eat food from the bag or the Inventory panel.
- **Water** drains about 3 an hour, and 1.6 times faster on hot days (75°F and up). Face the **pond** and press Space to drink, for +40 water.
- **Warmth** depends on the temperature. Outside it drains when it's below 50°F, faster the colder it gets. In mild weather it slowly refills. Inside the house it refills, faster once the house is patched. Sleeping in bed fills it to 100.
- If any need is empty, you lose 1 HP every 2 hours until it's filled. Dropping to 0 HP collapses you at the homestead, as in the wilds.
- **Temperature** is shown in °F. It's the season's average (winter 40, spring 51, summer 67, autumn 54), plus a daily swing of about 7 degrees, coldest near dawn and warmest in the evening, plus the day's weather (sun +6, overcast 0, fog −2, drizzle −3, rain −4, downpour −6, snow −10).

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
- **Boredom:** one pastime at the **desk** (Solitaire or Sudoku) entertains you for that day. A day without a finished game lowers the sanity limit by 1, at the end of the day, down to 40 points lost (a limit of 60). The limit recovers only through cleansing and the collapse relief, not through boredom.

## Tutorial tips

- **The guided first day.** A new game opens with eight steps on the tip card, one at a time: walk 10 tiles, plant 3 seeds with the trowel, open the bag, gather from 3 brush piles, open the section wheel, craft a crude hatchet, fell a tree, and drink from the pond. Each step stays up until it is done, shows "(n of 8)" in its title, and is followed by a "Done" message and a chime. A step already done ahead of its turn is passed over. Dismissing a step skips it. After the last step the card shows the current story chapter.
- **Later tips** appear as the player reaches each part of the farm: watering once 3 seeds are planted, food and water at 12:00, sleeping at 17:00, repairs on day 2, quests from 10:00 on day 2, chores from 14:00 on day 2, buildings on day 3, the mine on day 4, hens once a coop stands, goats once the barn stands, the cellar, and smelting and preserving once the furnace or smokehouse is built. Each shows for about 16 seconds. A waiting tip steps in front of a guide step, which comes back afterwards.
- The card sits at the bottom of the screen and steps aside while the bag, the wheel, a section or a placement is up. A tip's time doesn't run out behind a menu. B (or Backspace on the keyboard) dismisses it.
- Tip text names the controls for the device in use: tools are left click or RT, hand actions (gather, open, drink, place) are Space or A.
- Each tip shows once. The Settings menu lists the tips and guide steps already seen under **Tips**, so they can be read again.
- Saves keep the seen tips. Saves from before tips existed count the whole tutorial as seen, and saves from before the guided first day count it as done, so neither floods them.

## Saving

- The game opens on a **start screen**: **Continue** (the most recently saved slot), **New Game**, **Load Game**, **Settings** (the controls list), and **Quit**. The world is built only after you choose.
- There are **three save slots**. New Game asks for a slot, and a used slot takes two presses to overwrite. Then it asks for a save name, filled in as "Farm N" so a gamepad player can just press Begin. Load Game lists each slot with its save name, day, coins, and house stage. Older single-slot saves become slot 1. Pressing Overwrite keeps focus on the armed slot, so a gamepad's second press overwrites it. Crops from saves made before watering existed count as watered on the day they load, so they grow that night.
- The game saves **only** when you sleep in bed or collapse at 03:00, to the slot you're playing.
- The in-game Settings menu ends with a **Game** section that never folds. It holds **Music** (on or off), **Unstick me**, and **Quit to the main menu**. Quitting returns to the start screen without saving, and progress since the last sleep is lost. The slot you were playing stays selected. Sleeping is the only way to save.
- Saved: day, skill XP, inventory (including every food), coins, goats and their feeding, bag upgrades, root cellar, cooler, and smokehouse (built, and what they hold), materials, stats, story chapters done, achievements done, selected seed, lantern tier, house stage, house wear, coop and hens, barn (built, and where it stands), tidy/mend/cleanse days, sanity, sanity penalty, boredom loss and the day you were last entertained, animal ages (hens and goats), crop days, clean nights, property tax owed, its due day and reminder stage, the post on the desk, the cards and sudoku puzzles left, catalog orders, crops (with kind), brush piles, **player position**, whether you were **inside the house**, and the **open panel**.
- Quitting mid-day loses that day's progress since the last save. Position and panel are saved at the same moment, so they reflect the last sleep or collapse.

## The world: the portal, the road, and the wilds

**Currently off.** `WORLD_ENABLED` is `false`, so play stays on the homestead. The east portal is gone, the wider land and its towns are unreachable, and the Guardian of Lowmere quests are hidden. The code stays in place, and setting the flag back to `true` restores it.

- The farm's **east gate is a portal**. Walking through it takes you into the world, at the portal stone's east side. The portal shuts at 18:00.
- The **portal stone** in the world takes you back to the homestead.
- The **world is 768 by 912 tiles**, generated from a fixed seed with forest, lakes, and open ground. Its edge is a line of trees.
- **Lowmere** and **Ashford** are stamped into the world along a road. The road runs from the portal, through Lowmere, and east to Ashford. The towns have no walls: their houses, water and gates sit in the forest, and the road goes through their gates.
- **The minimap** shows the whole land in the world, with you as a dot. On the farm it shows the farm as before.
- You enter each village by walking into its area, and that sets its region. Hollows gather in Lowmere, and stalkers wait on the Ashford road. The open land has no foes yet.
- **Night:** from 18:00 the world sends you back to the homestead, unless you are at your campsite.
- The world draws only the tiles near the camera, so the full size stays fast.


## Combat (real time)

Combat happens while you move, in the style of Stardew Valley.

- **Swing:** press Space to swing your right-hand weapon in the direction you face. A swing reaches 1.5 tiles in a forward arc and has a 0.5 second cooldown. Villagers still take priority: if one is in front, Space talks to them.
- **Foes roam** their area and wander when you're far away. They **chase** you when you're within their aggro range. Each foe has a contact attack on a cooldown.
  - **Hollow** (Lowmere wood): 6 HP, slow, 2 damage, aggro 3 tiles.
  - **Stalker** (the Ashford road): 10 HP, fast, 3 damage, aggro 4.5 tiles, drops resin.
- **Damage:** a swing deals your weapon's damage plus a random bonus of up to half your Combat level. Foe hits are reduced by your total armor defense, with a minimum of 1.
- **Invulnerability:** after you're hit, you have 0.9 seconds of safety and you're knocked back a little.
- **Kills** give Combat XP (20 for hollows, 30 for stalkers) and sometimes a material drop: fiber from hollows, resin from stalkers.
- **Combat** is a skill (same level curve as Skills). Each hit gives 4 XP. Max HP is 10 plus Combat level − 1.
- Food heals HP by its difficulty, from 1 to 4. Sleeping restores full HP. Losing all HP sends you home, shaken, with a 10 sanity penalty.

## Gear and crafting

The Gear panel has ten slots in four columns: Back (your bag), Head, Neck, Belt (lantern), Off hand (shield), Chest, Main hand (weapon), Wrist, Legs, and Feet. The lantern hangs from the belt, so the offhand is free for a shield.

The Gear panel (G) is laid out as a person. Head, neck, chest, legs, and feet run down the middle. The back (your bag) sits beside the neck, the main hand beside the chest on the left, and the gloves beside the legs on the left. The off hand sits beside the chest on the right, and the belt (lantern) beside the legs. The toolbelt (hoe, axe, and pickaxe) sits in a row below. Each worn piece shows its drawing, and an empty slot is dim. Picking a tile fills the detail card with the piece's damage and armor, and its Craft button opens the Craft panel. Defense and hit damage are listed under the figure. The wrist slot is the gloves slot.

**The Craft panel is a grid of pictures.** Each sub-tab shows its recipes as tiles, four across: a drawn picture of the item with its name under it. Items you can't make yet are dimmed, but they still show, so you can see what they need. Picking a tile fills the detail card on the right: the picture, its name, what it does (damage, armor, or what it yields), its level requirement (green-red coloring shows whether you meet it), each material with how much you hold against how much it costs, and a single button (Make, Build, Cook, Upgrade, or Best when a tool is at its top tier). The card stays on the screen while you pick another tile, so you can compare recipes without scrolling. The Campsite section still sits below the grid on the Other tab. Pictures are SpriteCook icons from `art/ui/icons.png` (52 icons, 16 pixels, drawn at a whole multiple so they stay crisp); ore and bars pick their iron or copper icon by the item's tint. An item kind without icon art falls back to the shapes drawn in code (the RecipeIcon in the action bar). The same icons show in the bag, the hotbar and the Inventory. Every picture has a soft shadow beneath it and a dark outline around its filled shapes, so they stay readable at the small tile size.

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

## Towns, shops, and the bank

The whole land is filled with towns, planned from a fixed seed so every game gets the same map.

- **Towns:** about 70 towns sit on a grid across the world, never overlapping. There are four kinds: hamlets (about 28 by 20 tiles), towns (about 40 by 28), castles (about 34 by 26, with a wall and a keep), and manors (about 20 by 16, walled, with a manor house). Each town is named, and a castle or manor takes "Keep" or "Manor" after its name.
- **Layout:** a cross of streets runs through every town. Houses sit in the spaces between them, with trees on the open ground.
- **Roads:** a road network joins every town and village, so the whole land is reachable on foot from the portal. Roads are always walkable, and no building covers one.
- **Villagers:** each town has homeowners who chat. A town also has, depending on its kind:
  - a **general store** (hamlets and towns): buys materials and sells wood, fiber, resin, stone, and hardwood. You buy 10 at a time, and sell all you hold at half price.
  - a **grocer** (towns): opens the trade panel, to sell crops, fish, and cooked food.
  - a **banker** (towns and castles): see below.
  - a **lord** (castles and manors) at the keep door.
- **The bank:** deposit and take back materials and coins. Banked goods are kept safe and saved with the game.
- **Safety:** generated towns have no foes. The wilds between them are open land with the usual wild spaces.

## Campsites

A campsite lets you stay out in the wider land overnight. It is built, not placed by the map.

- **Setting up:** from the Craft panel's Other tab, Campsite section, while in the world. Face open ground (grass or path) and press Camp. It costs 4 wood and 3 fiber, needs Bushcrafting 2, and gives 15 Bushcrafting XP.
- **One at a time:** setting up a new campsite moves your camp. The old tile goes back to grass.
- **Safe:** foes cannot attack you while you stand at the campsite, and they will not enter within 3 tiles of it.
- **Resting:** face the campsite and interact with it from 18:00, as you would a bed. It saves the game, advances the day, and keeps you in the wider land. The dusk rule does not send you home from it.
- **Saved:** the campsite is kept with the game and returns when you load.
- The homestead keeps its own bed, which still works only at the homestead.

## Forestry and tools

- **Forestry** trains by felling trees. A grove of twelve trees is scattered across the property. Each tree gives 3 wood, and 2 hardwood with a copper hatchet or better, and 20 Forestry XP. Felled trees come back each morning.
- **Hatchets** and **picks** are tools with tiers. They are crafted from the Tools tab of the Craft panel and are kept by tier rather than worn in a slot. Hatchet tiers: crude, stone, copper, iron. Pick tiers: stone, copper, iron.
- A hatchet is needed to fell trees. Hardwood needs a copper hatchet or better.

- **Fishing rods** are in the Tools tab too. A **Willow rod** (Fishing 2: 2 wood, 2 fiber) adds 10% to each catch chance. A **Hardwood rod** (Fishing 5: 2 hardwood, 2 fiber, 1 resin) adds another 10%. The rod sits in the toolbelt on the Gear panel.
## Mining

- **Rocks** sit on the farm at five spots. Each one comes back each morning, like brush piles.
- Breaking a rock **by hand** gives 1 stone. That gets you the first stone pick.
- With a **pick**, a rock gives 2 stone and 12 Mining XP.
- From **Mining 2**, a pick also gives a 15% chance of **copper ore** per rock. Farm rocks never give iron.
- Stone is worth little on its own. It goes into the stone hatchet and stone pick.

## Smithing and metal gear

- **Furnace** (built from the Buildings menu, in the workshop): 80 coins, 6 wood, 4 stone, Carpentry 4. Stand beside it, facing it, and press Space to smelt.
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

- The Craft panel's **Tools** tab holds them. Hatchets and picks are upgraded there one tier at a time, in order.
- The action bar panel now scrolls, so long crafting lists fit on screen.

## Shields and ranged weapons

- **Shields** go in the **off hand**. Hardwood shields (Forestry 4) use hardwood and fiber. Copper (Smithing 3) and iron (Smithing 6) shields are heavier and give more defense.
- **Bows** (hardwood, Forestry 3) and **crossbows** (hardwood and copper, Smithing 3) go in the **main hand**. The attack button fires them in the direction you face, and only in Lowmere and Ashford, where the foes are. A bow fires every 0.6 seconds for 3 damage. A crossbow fires every 1.2 seconds for 6 damage.
- **Arrows** (wood and fiber, Bushcrafting 2) and **bolts** (hardwood and copper, Smithing 2) are fletched from the Craft panel's Tools tab, Ammunition section. Each shot uses one. Shots that miss are lost, since there is no pickup yet.
- Melee and ranged attacks both use the same button. The bow or crossbow in the main hand decides which one you get.

## The Ashford quarry

- Four **quarry rocks** sit in Ashford, and they come back each morning.
- You need a pick. Without one, a quarry rock is too hard to break.
- At **Mining 3**, a quarry rock gives copper ore. At **Mining 5**, with a copper pick or better, there is an even chance of iron ore instead.
- The quarry works in Ashford only. Farm rocks never give iron.

## Gathering and metal

Bark is the starting tier and metal is the later one. Each bark piece has a metal piece for the same slot. The metal piece is better, needs Smithing, and takes that slot once you have it. Bark pieces stay craftable early on.

Each gathering skill has its own tool. The tool's material sets what it can break.

| Skill | Gathered from | Tool | Gives |
|---|---|---|---|
| Bushcrafting (existing) | Brush piles, thickets | None | Wood, fiber, resin |
| Forestry | Trees on the farm edge and in the Lowmere wood | Hatchet | Wood, hardwood |
| Mining | Rocks on the farm, the Ashford quarry | Pick | Stone; copper and iron ore |
| Smithing | A furnace built from the Buildings menu | None | Bars from ore and wood; metal gear and tools from bars |

**Hardwood is a key material.** It goes into tool handles and smithing fuel, and into the weapons and gear below.

- **Shields** (offhand) are made from hardwood and metal.
- **Bows and crossbows** (ranged, right hand) are made from hardwood. Crossbows also need metal parts. Both need ammunition, which is not designed yet.
- **Wands and staves** (magic) are made from hardwood once magic exists. Magic is not designed yet.

**Ore never comes from the farm.** Copper and iron come from the Ashford quarry only.

**Farm rocks** are cleared like brush piles and mostly give stone, which is worth little. From Mining 2 there is a small chance of copper ore instead.

**Tool tiers:** a stone hatchet or pick (from farm stone) comes after the first tools. Copper tools come from Smithing, and iron tools after that. Trees need any hatchet. Hardwood needs a copper hatchet or better. Copper ore needs a pick. Iron ore needs a copper pick or better.

Levels are first-pass values and will be tuned in playtesting. Ammunition arrows and bolts are used up on shots, and there is no pickup yet. Magic (staves and wands) is not designed.

**Decided:** the offhand (left hand) is for the shield. The lantern moves to a **belt** slot, so it can be worn without taking a hand. The lantern keeps its light ring and upgrades as before. Moving it is a grid change to be made when shields are built.

## The mining cave

A cave on the homestead, entered from the farm's west edge. It is the only place to get iron ore, and the only place to fight.

- **Entrance:** step onto the cave mouth on the farm's west edge. The exit mat inside takes you back out to the farm.
- **Layout:** the cave is laid out fresh each day, so the tunnels, ore, and creatures change overnight. The same day always gives the same cave.
- **Ore:** copper and iron set into the rock walls. Copper needs a stone pick and Mining 2. Iron needs a copper pick and Mining 5, and only sits deeper in the cave. Each node gives one ore and 12 Mining XP. Broken nodes stay broken until the next day, and that holds through a save.
- **Creatures:** ordinary animals, no supernatural ones. Three bats (fast, weak), two lizards (slow, tougher), and two snakes (quick, hard-hitting). They spawn away from the entrance, and each visit starts with them back in their places. Kills give Combat XP and a small chance of fiber or resin.
- **Saving:** a save made in the cave returns you to the homestead when loaded.

## Upkeep, hens, and the third plot

**Goats (the barn)** — The barn holds up to **3 goats**, ordered for **45 coins** each from the catalog at the desk. Feed them **2 crops each, once a day**. A **grown** goat (10 days old) gives **1 milk each morning** when fed, stored as milk. Young goats give nothing. A grown goat sells for **70 coins** from the Barn panel, against 45 to buy. Two unfed days in a row and a goat wanders off. Goats wander in the yard in front of the barn and keep about half a tile between them, so they never stand on the same spot. Each goat that is unfed counts as a missed chore that night, like the hens.


Keeping the homestead running is the daily work. Each part is at base level for now, to be deepened one project at a time.

- **Chores:** each day has a short list, shown at the top of the House panel. Tidy the house and mend a board every day. Once you have hens, feeding them is listed too, but it is done at the coop. Each chore left undone adds 1 wear overnight. A night with every chore done brings back 5 sanity.
- **Wear:** the house wears by 1 each night, plus 1 for each chore left undone, up to 10. Mending a board takes 2 off, a tidy takes 1, and a repair takes 3. At wear 6 or more, rain ruins a random crop overnight. The Upkeep section of the House panel shows it.
- **Buildings menu (U):** the workshop, the coop, and the barn are built and moved from here, not from the House panel. Each one is placed the same way: building it starts placement, a green or red preview follows the tile you face, and Space places it on open grass. A spot can't cover plots, crops, rocks, brush, fishing spots, or you. B cancels. The Move button relocates a standing building for free. A building that was paid for but never placed (older saves) shows Place instead.
- **Coop:** 6 wood, 4 fiber, and Carpentry 2. A 2 by 2 building. Stand beside the coop, facing it, and press Space to open its panel, where you feed the hens (they are ordered from the catalog). The hens wander inside it, walking to a spot, pausing, and walking on.
- **Barn:** 10 wood, 6 fiber, and Carpentry 4. A 3 by 2 building of red boards. Stand beside it, facing it, and press Space to open its panel. It holds the goats, which are ordered from the catalog, and it is separate from the coop.
- **Hens:** 12 coins each from the catalog, up to four in the coop. Feed them once a day from your crops (1 crop per hen). Hens are grown after a week (7 nights), and only a grown hen that is fed lays an egg overnight, which goes into your pack as an egg, as far as there is room. A grown hen sells for **20 coins** from the coop panel. Two unfed days in a row and a hen wanders off.
- **Predators:** at wear 4 or more, a fox can get into the coop on a given night and take a hen.
- **Post and the desk:** post comes through the mail slot in the front door and lands on the **desk** in the bedroom, which is there from the start. Each morning's new letters are announced in the morning message. Unread post turns on a **red light** at the desk, blinking, while you are in the house. Using the desk opens the Desk panel (post, property tax, pastimes, catalog), which marks the post read and lists it. Read letters go in the drawer with the Clear button.
- **Property tax:** a bill arrives on the 1st of January, April, July, and October (not on the first day of the game). Its amount is the **property value** at that moment. The value starts at **40 coins**, then: it **multiplies by 1.8 with each house upgrade** (exponential), gains **5% per building** (coop, barn, cellar, cooler, smokehouse, furnace, woodshed), gains **25% per farm plot past the first** (plot two at Farming 2, plot three at Farming 4), and gains **1% per clean night** in a row, up to 20 nights, where a clean night is one with every chore done. The Desk panel shows the value and its breakdown. It is due 14 days after it arrives. Pay it from the Desk panel. Unpaid, a reminder comes the day after it is due, a final notice 7 days late, and at 14 days late the **land is lost**: the save is removed and the start screen says why.
- **Third plot:** opens at Farming 4 once the house is Patched. It sits between the two paths, south of the first plot.

## Graphics and atmosphere

The farm reads as a finished picture rather than flat colour blocks. Four layers do this, all on the farm view.

- **Colour grade.** A full-screen pass (`shaders/grade.gdshader`) sits on a CanvasLayer under the HUD, for a grim, overcast mood: it pulls saturation well down (0.62), darkens the scene (0.84), adds a little contrast, faint warmth in the highlights and cold blue-grey in the shadows, a heavy vignette, and fine film grain. The grass is also tinted darker and mossier as it is drawn (`GRASS_TINT`). The HUD stays unfiltered so text remains sharp.
- **Ground detail.** Grass is tinted per tile (±2% so it does not checkerboard), with tufts and small pebbles on the path. Soil and path keep their own texture so they never blend into grass.
- **Shadows.** Trees cast a soft ground shadow, drawn in a separate pass beneath their canopy. Rocks and brush cast small shadows too.
- **Seasonal particles.** Each one follows the camera and only runs in its season. Autumn drops SpriteCook leaves (`weather_leaves`: maple, oak, elm and birch, one picked per particle) that spin as they fall. Spring drifts SpriteCook petals (`weather_petals`). Summer dusk brings blinking fireflies. Particles are CPU-driven and stay small in number, so they cost little.
- **Weather sprites.** The weather overlay (`scripts/weather.gd`) draws from SpriteCook art. Rain falls as crisp streaks one art pixel wide, each landing at its own spot on screen and playing the last three frames of `weather_splash` (a burst, a ring and a ripple). Snow uses the flake cells of `weather_drops`: mostly small clumps, some nearer and doubled, and a few full flakes. Fog rolls by in faint wisps (`weather_fog`, drawn 2.5 to 4 times its size). Clouds are shadows passing over the land: the SpriteCook `weather_cloud` (128×64), darkened to the shadow colour and drawn at 3× or 4×, some mirrored. Without the art, the old soft shapes are drawn.

Particles do not run indoors, in the cave, or in the village. Nothing in the grade pass changes game logic, so the save and the rules are untouched.

## Code layout

`scripts/main.gd` (`class_name MainGame`) is the scene root. It owns the shared state, the drawing, the input and panel glue, the HUD, the world and map build, the lights, the crows, and the title and settings flow. The rules for each domain live in their own `RefCounted` script, which is built once in `_ready` and kept as a member on main:

- `panel_rows.gd` (`panels`): the row lists for every panel.
- `desk_system.gd` (`desk`): pastimes, the catalog and its deliveries, mail, the property tax and eviction.
- `animal_system.gd` (`animals`): hens and goats, feeding, ageing and sales.
- `farm_system.gd` (`farm`): seeds, planting, watering, harvest and crop unlocks.
- `firewood_system.gd` (`firewood`): chopping, the fire, and warmth.
- `sanity_system.gd` (`sanity_sys`): the day's events, tidying, cleansing and the night relief.
- `stall_system.gd` (`stall`): the farm stand, cooking, food, the pack and the bank.
- `progression_system.gd` (`progression`): skill XP, levels, story, achievements and rewards.
- `save_system.gd` (`saver`): saving, loading and the saved position.
- `craft_system.gd` (`crafting`): recipes, gear, tools and bandages.
- `fishing_system.gd` (`fishing`): fish spots, casting and reeling, and the cooler.
- `mining_system.gd` (`mining`): rocks, the Ashford quarry, cave ore, smelting and brush gathering.
- `combat_system.gd` (`combat_sys`): foes, shots and weapon damage.

Each class holds `var m: MainGame` and reads main's state through it. A member is named after its job, and never after a name main already uses as a local or variable (main has a local `combat`, which is why the combat member is `combat_sys`). Drawing (`_draw_*`), the engine callbacks, and anything connected to a signal stays on main, because it needs the node.

## Farm layout

The farm is a hand-read grid. `tools/farm_grid.txt` holds one character per inner tile (64×40). It was first read tile by tile from the layout diagram at 40×24, then spread out to 64×40 by the one-off `tools/grow_farm.py` when the farmer became a full-tile sprite. `tools/hand_layout.py` reads that grid, derives the anchors (plots, house, porch, well, stall, great tree, grove spots) and writes `scripts/farm_layout.gd`. Regenerate with `python3 tools/hand_layout.py`; edit the grid, not the generated file.

- Terrain codes are listed in the header of `scripts/farm_layout.gd`. The roof (`O`) is a separate tile from the house body (`H`), so the two can differ in colour. The roof is walkable: the player walks over it, the walls and door block. The roof art is drawn in its own layer, over the player while they are north of the walls and under them on the walls, the same rule as the great tree's canopy. The stall is 3×2, as wide as its art. The well is 2×2; `WELL_IX` is its top-left tile.
- The farmhouse footprint is 11 tiles wide: five rows of roof, then two of wall with the door in the middle of the bottom row, and the porch below the door. Its sprite is 12 tiles wide and 10 tall, shifted half a tile so the steps sit on the door tile. The door is a little taller than the farmer, so the house reads at the farmer's scale. Each repair stage is a SpriteCook edit of the ruined house (`gemini-3-pro-image`, since the exact-size model stops at 128 pixels), placed on the same 192×160 canvas with the door and steps lined up. The Boarded stage came out about 11 pixels narrower; it is centred on the door.
- The plots are 15×7 (plot one), 15×6 (plot two) and 12×6 (plot three).
- Split-rail fences (`X`, blocking) run along the top of plot one and the bottom of plot two, one tile out from the soil; the plots stay open on their sides. A scarecrow (`Y`, blocking, drawn two tiles tall with the trees) stands just east of plot one.
- Ground clutter (pebbles, fallen leaves, mushrooms, dry grass tufts; `art/farm/clutter.png`) is scattered on about one open grass tile in eleven, chosen by a hash of the tile, and only where all eight neighbours are grass. It is drawn under everything and never blocks.
- Rocks and brush are SpriteCook sprites: breakable boulders (`boulder_*`), brush piles (`brush_*`) and a bramble thicket (`thicket_0`) on the thicket spots. The cave's outcrop (`K`) uses mossy cliff rocks (`rock_*`).
- The rocks around the cave are one 96×80 SpriteCook hillside (`hillside`): mossy stone ledges six tiles wide and five tall, its foot level with the entrance sill, so the cave reads as cut into a hill. The rock tiles under it are drawn as grass; the rocks in the row below keep their own boulder sprites at its base.
- The cave entrance is a 64×48 SpriteCook sprite (`cave_mouth`): a timber-framed doorway in a mossy rock face, four tiles wide and three tall, its doorway (about the farmer's height) centred on the cave-mouth tile. Inside, the exit is a 32×32 sprite (`cave_exit`) of stone steps up into daylight, over two exit tiles in the middle of the south wall, where you arrive; leaving puts you on the path just south of the cave mouth.
- Inside, the cave is drawn in SpriteCook art too: a packed-earth floor everywhere, the rock walls laid over it on the dual grid (darkened by `CAVE_WALL_TINT` so the tunnels read), copper and iron ore sprites on the ore tiles, and wooden steps up into daylight on the exit tile (`_draw_cave_sprites` in `main.gd`).
- Hens and goats are SpriteCook walk cycles (`hen_walk`, `goat_walk`, four frames facing right). Each faces the way it is walking, steps while it moves and stands on its first frame while it waits; the flock starts its cycles out of step. Bats, lizards and snakes are SpriteCook animations (`foe_<kind>.png`, four frames): the bat flaps all the time, the lizard and snake animate only while they move and face the way they last moved sideways, and all three turn pale when hit. Hollows and stalkers keep their drawn shapes.
- The coop is a 3×2 footprint and the barn 5×3, sized so a hen fits the coop's door and a goat the barn's. Each is one SpriteCook sprite (`coop` 48×64, `barn` 80×80) as wide as its footprint, standing on its bottom edge with the roof rising above, and sorted with the trees so the farmer walks behind it from the north. The hens peck in the yard in front of the coop and the goats graze in front of the barn. A coop or barn from an older save that no longer fits where it stood is moved to the nearest clear grass.
- The great tree's base is a 3 by 3 block. Its middle and bottom rows (`B`) block movement; its top row (`b`) is walkable grass. Its art (a SpriteCook sprite, 128×128) is drawn larger than that base, 8 by 8 tiles, with the base at the bottom centre. The art above the base does not block. The player walks behind the canopy when north of the base, and in front of the base when south of it (`_update_big_tree_depth` in `main.gd`).
- Plot one and plot two are soil (brown in the diagram); plot three is fallow (olive).
- The grove keeps twelve trees. The thirteenth tree in the diagram, at the top-left of the field, is dropped.
- The workshop, furnace, smokehouse, woodshed, chopping log and cellar are not on the grid. Their spots are open grass, listed as reserved, so a coop or barn is never placed on them. Once built, the cellar, smokehouse, furnace and woodstore are SpriteCook sprites (`cellar`, `smokehouse`, `furnace`, `woodstore`, 16×32), about the farmer's height: each stands on its one-tile footprint and rises over the tile above, sorted with the trees. The chopping log (`chopping_log`) is 16×16. The cellar stands on grass and the workshop pieces on its floor. The workshop is 7 by 6 tiles: a two-row back wall, about the farmer's height, low side and front walls, and a 5 by 3 floor with the door in the middle of the front wall. Its walls and floor are one SpriteCook sprite (`workshop`, 112×96) drawn under the player. The furnace, smokehouse and woodstore stand in a row against the back wall, and the chopping log in the front right corner.
- Rocks and brush spots are kept only where they still sit on open grass.

Farm art. `art/farm/` holds the farm's pixel art: 16-pixel tiles at native size, and props with transparent backgrounds. `FARM_SPRITES` in `main.gd` switches the farm from the flat view to this art, and `scripts/farm_sprites.gd` loads it. Tiles without art (coop, barn, workshop and other unlocked buildings, decorations) keep the flat colour until they get their own art.

The ground is five SpriteCook 15-piece dual-grid tilesets, `art/farm/ground_*.png`, each a 4 by 4 atlas of 16-pixel frames. Grass is drawn under every ground tile, using the filled frame of its set, mirrored by position. Water, fallow, soil and path (the porch counts as path) are laid over it in that order, each on the dual grid: a frame sits on every corner where four map tiles meet, half a tile up and left of a map tile, chosen by which of the four tiles are that material (`_draw_dual_ground` in `main.gd`). Edges, corners, inner corners and one-tile paths all come from the same 15 frames, and the path goes last so the dock and porch cross the shore and the plot edges.

The older `tools/farm_layout.py` converter sampled the diagram by colour. It produced too many misreads and is no longer the source of the layout.

A save records the layout's version. When the version changes, the save is migrated: crops, brush and felled trees reset, the player starts at the farm centre, and the coop and barn move to the nearest clear grass. Money, skills, tools and animals are kept, and the player is told what happened.

## Deferred

- The story beyond the survival chapters: mystery and horror escalation.
- **A cave system for combat.** A place to fight, and Combat's main source of XP. It would also restore the Combat training that the hollows and stalkers used to give.
- **Wolves that threaten livestock.** Needs livestock first. Wolves would come after the cave system, so there's a reason to guard the animals.

## Open decisions

- Whether the house interior should become a separate scene.
- Whether the tile map moves to a `TileMapLayer` with a real `TileSet` once art is in.
