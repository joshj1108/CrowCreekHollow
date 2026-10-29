# Crow Creek Hollow — Design

A top-down farming game with heavy psychological horror, built in Godot 4.7.

## Pillars

- **Day is work, night is dread.** Each day is a farming shift. Night brings a horror encounter.
- **Atmosphere over jump scares.** Horror comes from lighting, sound, and escalating events.
- **Progress carries over.** Skills, the house, gear, quests, and sanity persist between sessions.
- **Homestead first.** Early quests teach the farm: planting, gathering, repairs, and light.

## Controls (Stardew-style)

- **Section wheel.** Shift, or a click on the left stick, opens a ring of the menus that aren't in the bag: Skills, Gear, Craft, Quests, Diary, House, Buildings, and Achievements. The mouse hovers and clicks a section. On a controller the left stick highlights one and A opens it. The D-pad, the arrow keys or WASD step the highlight round the ring (right and down clockwise), and Enter or Space opens it too. B or Esc closes the wheel, and from a section returns to the wheel. Choosing a section closes the wheel and shows that section alone. Sections can't be opened while the wheel is up, the bag is up, or another section is open.

- Move: WASD or arrow keys
- Hand actions (talk, sleep, tidy, cleanse, cook, gather brush, drink from the pond, open panels, confirm placement): Space or A, facing the tile.
- Tool and weapon actions (hoe, hose, trowel, axe, pick, rod, sword): RT or a left click, facing the tile. A tool press on a tool target with the wrong tool in hand says which tool to select. With the trowel in hand, the D-pad up and down, or Z and X on the keyboard, cycle the seed you plant (the left stick does not) (turnip, then pumpkin once Farming reaches its level, skipping any you have none of), and do not walk you. A hand press on one says to use RT or click.
- Walk into the farmhouse door to go inside. Walk onto the exit mat to leave.
- The section wheel: Shift opens it (see Section wheel below). J opens and closes the diary (see The diary). The Pause menu is Esc only. The Inventory is opened from the bag (Tab).
- The bag (grid, bottom-right corner): Tab opens and closes it. Click a slot to use it, or move with the arrow keys (or WASD) and press Enter. Empty slots are out of the focus path; an empty bag opens on its Inventory button, and using the last of something moves focus back to the nearest slot that still holds something. The corner Bag button, like the Menu button, never takes focus, so a click on it always lands.
- Esc closes whatever is open, the bag, the wheel, or a section, one at a time. With nothing open, Esc opens the **Pause menu** (see Settings and pause). From Settings or Controls, Esc or B goes back to the Pause menu. B closes the same things as Esc.
- Stuck while placing or boxed in? Esc cancels any placement and opens the Pause menu. Its **Unstick** button moves you to the nearest open ground (grass, path, soil, fallow) from the farmhouse door, and works on the farm only.
- Farming and gathering pause while a panel is open
- **Dev (debug builds only):** F4, or **Unlock** at the bottom of the Pause menu, sets every skill to level 10 and gives 99,999 coins, 999 of each material and 99 of each seed. It also gives every tool, lantern and bag tier, restores the house, builds the pump, hose and storage buildings, and fills the needs. The coop and barn still need placing from the Buildings panel. Exported release builds ignore F4 and hide the button. It isn't on F9 because the Godot editor uses F9 to suspend a game running in its Game tab. **Shift+F4** jumps to the next morning a trek walker waits (08:00, standing below them) and packs a lantern, a hatchet, 2 lamp oil and 2 trail rations, changing nothing else, for testing the treks.

## Gamepad (Xbox layout)

- Move: left stick or D-pad (0.3 deadzone)
- Use, plant, harvest, gather, sleep: A
- Close the open panel: B
- Bag Y, section wheel left stick click, Pause menu Start, Close B
- The bag: Y opens and closes it, the D-pad moves between its slots, A uses the slot in focus, B closes it.
- While a panel is open, the D-pad or left stick moves focus between its buttons, and A presses the highlighted one. The first usable button is highlighted when a panel opens. On the keyboard the arrow keys or WASD move focus, and Enter or Space presses. A disabled button is out of the focus path, so focus never stops on something that can't be pressed. A panel with nothing to press (the farm stand with nothing to sell) focuses its Close button.
- In a ledger panel, LB and RB switch tabs, the D-pad moves between entries, and A presses the focused entry's action.
- Keyboard and gamepad share the same actions, so both work at once.

## Action bar

- Messages sit at the bottom-left of the screen, clear of the farm's labels. HUD and message text have a dark outline so they read over any ground.
- **The window** opens maximized and can be resized. The game is laid out for 1280 by 720 and scales to fill the window; a window of another shape shows more of the world instead of black bars, and the HUD keeps to its corners.
- **Text colours** follow the UI kit everywhere (HUD, hotbar, panels, the bag, the section wheel and the title menu): titles and highlights in gold (`d8b050`, or `f2d27a` for the brightest), body text in cream (`e8dcc0`), and notes, hints and labels in a muted tan (`9a8a6a`). Labels in a row are centred on the icon beside them. Text that might be too long for its box steps down a font size or two, then ends in an ellipsis, and never runs over a frame.
- **The hotbar** shows ten framed slots with each tool's icon centred in its slot and the slot number small in the top-left corner. The active tool's name sits **under** the slots, in gold.
- Trees are SpriteCook sprites (`art/farm/tree_*.png`), 32×48: two tiles wide and three tall, standing on the bottom centre of their tile. Kinds are autumn oaks, Douglas firs, willows and dead trees, picked by a hash of the tile. The forest border is mostly firs with oaks mixed in; the grove inside the farm is mostly oaks. Out of every twelve trees, one is dead. Willows grow where the layout lists them, by the pond. Each tree is nudged a few pixels by its position, and border trees overlap, so the outer forest reads as dense woodland. Trees block movement. Trees on or north of the player's row are drawn with the ground, behind the player; those south of it are drawn over the player (`tree_front_layer`). A felled grove tree leaves a stump.
- **The great tree** is a 3 by 3 block of trees in the middle of the yard. It can't be felled, and the game says so when you face it. The crows roost in its crown from 20:00 and leave at dawn. Their eyes glow red, bright enough to show through the night tint, and each roost perch has a faint red light while a crow sits there. Crows are SpriteCook art: a perched sprite, and a four-frame flight cycle that follows each crow's flap. The roost perches sit on the great tree's art (`ROOST_SPOTS`): the two bare branch tips and two spots on top of the crown.
- Rocks on the farm block movement like trees. You can still break a rock from the tile next to it.
- Storage labels (Cellar, Smoke, Furnace) stay on screen when their building is at the view's edge.
- The farm's buildings hug the house: the cellar against the west wall. The workshop is a walled building, 7 by 6, with a door on its south side, placed and moved like the coop and barn, so it can stand by the house. Its furnace and smokehouse stand inside. The cooler is inside the house. The workshop, coop, and barn are built and moved from the Buildings menu (U).

- A small **Menu** button sits in the bottom-right corner for mouse players. It opens the section wheel, and hides while a section is open. A section is shown alone, full screen, with its options and a Close button. It never lists the other sections, so the only way to another section is to close it and open the wheel again.
- Controls sections are ledger tabs in the game (the start screen lists them with headings).
- Each section lists its options as cards: name, value, and an optional button or progress bar. The Craft panel is the exception: it is a picture grid (see Gear and crafting). Sections not yet moved to the ledger use the card layout.
- **The ledger layout** (replacing the cards one panel at a time; every card panel is done; the diary is a book, see The diary). A section is split into tabs, switched with LB/RB or Q/E (Q and E are free while a panel is open, and LB/RB don't change the hotbar since the day is paused) or by clicking a tab. The tab strip hides when there's only one tab. Each tab lists one-line entries on the left: the name, and a status on the right in green (ready, or the button's word), rust (short, "Not yet"), grey (done, built) or gold (information). Every entry takes focus, so a gamepad can read the ones without a button too. Down from the last entry wraps to the first, and up from the first to the last. A tab with only notes (Folk before anyone is met) shows them as one entry, so something always has focus. The right side is the detail page for the focused entry: its name, status, what it does, a "Needs" list with each cost ticked (have) or crossed (short, with how many you have), a progress bar, the longer note, and the button with its prompt. A or Space on an entry presses its action; a click only picks it, and the detail button acts. A tab's general notes sit small under its entries. The footer shows button prompts (Select, Close, Tabs, Sections) in keyboard or Xbox names, following whichever was used last. A change of device relabels the prompts and tab glyphs in place without rebuilding the panel, so the press that changed device still acts on the entry in focus. The open tab is remembered per panel until the game closes and isn't saved.
- **House tabs:** Home (the farmhouse, the next repair, including the summer-only restore, wear, the sanity limit and the bed, cleansing), Chores (the chores and the daily job), Storage (root cellar, cooler), Features (what each repair stage unlocks).
- **Buildings tabs:** Homestead (steps done with a bar, and the next step), Extensions (the cellar room, porch and second storey, each with its needs), Furnishing (furniture, then the outside paint and the wallpaper), Workshop (the workshop's Move row once it stands, then smokehouse, furnace, firewood store; the first of the smokehouse or furnace places the workshop, and the store needs one of them first), Animals (coop, barn: build, then place or move), Decor (lamp post, flower bed, gravel path, fence, the two sprinklers, apple tree, bench, birdbath, weathervane, crow bell, each with its skill, season or All Hallows need), Crow bell (its three parts and the clapper, until the bell is hung), and Trail works (from day 14, when the mill path opens).
- **Desk tabs:** Post (the diary, each letter as an entry marked New or Read with its text on the detail page, and Put letters away), Tax (property value, the tax owed with Pay, and the land deed with what is paid and Pay 500), Pastimes (played today, any limit lost to boredom, solitaire and sudoku), Catalog (grouped by Pastimes, Supplies, Seeds and Livestock, each with its price and anything else it needs, and what's on order).
- **Small panels:** Furnace (a "Bars left today" line with a bar, then each smelt with its ore, wood, Smithing level and the day's limit), Smokehouse, Coop (Hens), Barn (Goats), Root cellar, Cooler and Firewood store are one tab each, so they show no tab strip. The Well has Pump and Hose tabs. An entry whose button can't be pressed shows its short value in rust (such as "0 held"), or "Not yet".
- **Pause** is one ledger tab with no status on its lines, so it reads as a plain menu, and its prompts leave out Sections. A quit waiting for its second press shows "Press again" in rust, and its detail page says progress since the last sleep is lost.
- **Grid panels with tabs:** Inventory, Gear and Skills share a tab strip (in that order), so LB/RB or Q/E step between them in place. Craft's tab strip (its own sub-tabs) steps the same way. Their tab buttons are out of the focus path (the D-pad stays on the grid), carry the tab keys at their ends, and these panels show the prompt bar instead of the old hint line.
- **Quests** has a Story tab: the current chapter first, then every chapter with Done or its count. The detail page tells the current chapter's story, the goal, a bar and the reward. The old Details and Hide buttons are gone. Its second tab is **Folk** (see Folk): giving to whoever you last spoke to, the walkers with their hearts, and their requests.
- **Achievements** has a tab per tier (Settler, Homesteader, Keeper, Hollow Hand), each achievement with Done or its count, and a note giving the tier's count and the overall total.
- **Settings and Controls** keep their rows shared with the start screen, which still shows headings. In the game each heading becomes a tab (Sound, Display, Messages; Keyboard, Gamepad, Saving) and each line shows its value on the right. A volume line steps down and up with left and right (its detail page has - and + for the mouse). From these two, the prompt reads Back, since B returns to the Pause menu.
- Needs lines are marked [x] (have) and [ ] (short), since the default font has no tick or cross.
- **Ledger plan:** every panel is moved; the diary is a book with its own tab markers (see The diary). What's left is the SpriteCook art. Skills, Inventory, Gear and Craft keep their picture grids and take the tab keys and prompt bar. Art to make in SpriteCook later: tab planks (normal, open), a 16 px strip of prompt glyphs (A, B, LB, RB, L3, Q, E, Space, Esc, Shift) and a strip of tab icons; until then they are drawn in code.
- **Any open menu pauses the day.** While any section is open (Skills, Inventory, Craft, Quests, the Pause menu, Settings, and the rest) the clock stops, foes stand still, and the player can't move. Closing the menu resumes the day where it left off.
- Panels rebuild only when their content changes, so buttons don't disappear mid-click.
- The open panel is saved and reopened on load.

## Art

The farmer is a SpriteCook sprite (`art/player/`): a 16×32 figure in a straw hat, rust shirt and blue overalls, with 8-frame idles and walks facing down, up and right. Facing left mirrors the right-facing sheets. The idle facing away is one SpriteCook frame held still with a one-pixel breathing bob on the head and shoulders, because the generated back idles kept stepping in place. Tool actions have their own SpriteCook sheets, `farmer_<action>_<down|up|right>.png`, for the hoe, hose, axe, pickaxe, trowel, sword and casting: each plays across its action, and chop and mine loop with their cycle from frame 2 (the first two frames are the empty-handed idle). Waiting for a bite holds the cast's last frame, with a line drawn from the rod's tip to a bobber. The tool only shows while it is being used. A raised sword guard has no sheet yet, so it still draws the held tool in code over the sprite. There is no character creator: New Game goes straight into the game with this look. If the sheets are missing, the code-drawn farmer below is used. The code-drawn farmer has a straw hat with a band, a shirt under blue overalls with straps and a buckle, and boots. The face turns with the facing direction: eyes and a mouth when facing you, one eye to the side, and hair only from behind. While walking, the legs and arms swing in opposition and the body bobs with each step. A small marker in front shows what you'll interact with.

- 16×16 base tiles, scaled 3× in-game (`SCALE = 3`), nearest-neighbor filtering.
- Muted, desaturated daytime palette from the colour grade (see Graphics). Night uses a cool, shadowy tint via `CanvasModulate`.
- Placeholder art is drawn in code. Real licensed or commissioned pixel art replaces it later without touching game logic.

### UI skin

Menus, the bag, the hotbar, the HUD boxes and the title screen use one SpriteCook UI kit: dark wood frames with iron corner brackets, wooden buttons (normal, hover, pressed, disabled; focus looks like hover), and framed slots with a gold edge when selected. The pieces in `art/ui/` are cut from the kit's component sheet at a third of its size and drawn as 9-slices whose edges stretch (`scripts/ui_skin.gd`). Cards inside a section use the slot frame. The food, water and warmth meters are the kit's bar: each bar is the channel, with tan, blue or orange fill, and the iron-capped frame is drawn around it so the fill's length matches the value. The minimap sits inside the panel's rail, drawn over its edges. The section wheel's curved segments can't be 9-sliced, so they are filled with the panel's wood grain (shaded, or lit when highlighted) with iron edges, gold on the highlight, and the section's name sits on a slot-framed plaque. The plaque is sized to its text and stays inside the ring: a long name steps down a size and the subtitle wraps. Each segment's icon is SpriteCook art drawn at 3×: Gear and Craft use the shield and hammer item icons, and Skills, Quests, House, Buildings and Achievements use `art/ui/wheel_icons.png` (a journal, a sealed scroll, a farmhouse, a barn with a silo, and a trophy). The Diary has no art yet and draws a leather book with a red ribbon in code. If the art is missing, every control falls back to its flat style.

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
- Two plots: **Plot one** is tilled from the start. **Plot two** is overgrown and opens at Farming 2. A third fallow plot sits beside them and opens at Farming 9 once the house is Patched.
- The layout comes from a diagram (see Code layout). Fences and rocks block movement; the dock, the island and the path are walkable.
- Trees, water, the house walls, and brush piles block movement. The player slides along walls.
- A minimap in the top-right shows the farm, brush piles, the player, and the shadow on event nights. Its colours are graded toward the game's muted look (part way to grey, darker and a little cooler; `Minimap.grade`), and each tile is shaded a little lighter or darker so fields and woods read as texture. The house, the well, the cave and the player are SpriteCook icons (`art/ui/minimap_icons.png`, four 16 px cells); without the art they fall back to blue squares and a dot.
- The farmhouse interior sits below the farm and has its own camera bounds. It is 22 by 20 tiles, sized for the two-tile-tall farmer.

## Day and night

- The day runs **06:00 to 03:00** the next morning: **7 real minutes** (`DAY_LENGTH`, 420 seconds), so a game hour is 20 seconds. It was 4 minutes until October 2026; the longer day gives room to fish, walk and explore around the chores.
- What is timed in game hours costs the same as before: needs, sanity's drain and recovery (`DARK_SANITY_DRAIN` and the indoor rates are per game hour), the fire, pastimes, the first night's beats, the trek clock (`TIME_SCALE` 0.44, about 45 real seconds a game hour in the wood, so a trek still takes the same game hours) and the "too quiet" night's hush (160 seconds, about 8 hours). What is timed in real seconds stays real, because it is the pace of play rather than of the clock: fishing rolls and spot lives, chopping and mining rolls, combat, the walker's nerve, lamp oil, crows and messages. So a day holds more fishing, chopping and cave time than before.
- **Sim after the longer day and the chore upgrades** (October 2026, 400 days, `treks=3`, engaged / ignore / earlybed; the sim is hour-based, so the day length itself doesn't move it, but the hose heads, sprinklers, cistern, hoppers and the eased chores do): day 400 ends with **24,440 / 20,426 / 21,254 coins**, against 4,259 for engaged at the commit before (and 4,493 / 1,428 / 2,659 at day 420 in the run before that). Sanity is no lower than **76 / 53 / 57** (was 72 / 43 / 55). Farming 10 comes on day 86 / 90 / 84 (was 107). The homestead steps are done on days 1, 6, 6, 11, 18, 19, 32, 61, 63, 78, 109, 156, 244 and 396 (engaged), as before within a few days. The nozzle comes on day 34 to 37, the first five sprinklers on day 39 to 42, the cistern on day 44 to 47, the spray head on day 49 to 52, the coop hopper on day 32 to 35 and the barn hopper with the barn on day 109 to 111. Over the year the sim presses the hose about 5 to 6 times a day (from about 40 on a dry day), feeds by hand 47 to 86 times in all (from twice a day) and fills the hoppers 125 to 136 times.
  - **Why the coins jump:** before, the sim ran short of crops (215 days short for a trek's rations), so the hens and goats often went unfed, wandered off and were bought again (2,346 coins on animals), and the kept-well streak broke every winter. With the hoppers and the cistern's 24 more crops a dry day they are fed every day: eggs and milk earn about 20,000 (from 10,000), animals cost 183, and the kept-well streak holds most of the year (about 20 coins a night). Crops themselves about break even against seed costs (7,700 sold, 7,677 on seeds). This is for the economy rebalance to settle; copper still piles up (about 1,940 bars at the end, from 2,150), and hardwood (about 2,190).
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

- Short sounds play for the things you do: footsteps (about every third of a second of walking), planting, harvesting, watering, eating, drinking, repairs, coins for catalog orders, opening and closing panels, entering and leaving the house, chopping and mining, gathering, achievements, goats bleating now and then, and thunder on some downpour mornings (muffled, with a rattling window, if you wake inside).
- Tools sound on every swing, in time with the animation (when the blade or point lands, with the camera jolt): an axe biting wood, a pick clacking on stone, a hoe turning soil. A tree comes down with a crack, a rush through the air and a heavy thud; a rock or cave ore breaks with a crack and tumbling pieces. These have a bright bite on top, so they carry on laptop and phone speakers.
- Fighting: a swing whooshes, blows land with a thud, a block knocks and rings, being hit gets a pained breath, and foes die with a falling wail. Each foe calls out when it notices you: dogs growl, bats shriek, lizards and snakes hiss.
- Chores and crafts: casting, reeling in and a fish splashing up; feeding the hearth, splitting firewood, smelting, whittling tools and gear, tearing a bandage, cooking, scattering feed, sweeping when you tidy, and a soft shimmer when you cleanse. Every sale and purchase chinks coins, and hens cluck now and then.
- Moments: a hollow gust stepping into the cave, a falling lullaby when you sleep, a deep boom and pounding heart when you collapse at 03:00, and a dread swell when you fall in a fight.
- Night events have their own sound: a dread swell for the figures, three slow knocks on the wall, and for the "too quiet" night, the crickets and wind fall silent for a while.
- The sounds are generated by `tools/make_sfx.py` (numpy synthesis, written to OGG with soundfile) and live in `audio/sfx/`. Each can be replaced by a file with the same name.
- They are built to sound physical rather than beepy: filtered noise and crackle for dirt, leaves and food, struck wood and metal partials for hammers, tools, coins and latches, a plucked note in the harvest, a music-box run for achievements, a formant voice for the goats, and a short room or outdoor reverb on each. Each is levelled to the loudness the game's per-sound volumes were tuned for.
- A small pool of players lets sounds overlap, and each footstep and sound gets a little random pitch.
- **Sound effects** have their own volume in Settings (0 is off). It covers the ambience too.

### Ambience

`scripts/ambience_system.gd` keeps the world sounding alive and uneasy. Its loops live in `audio/ambience/` (12 s each, built to join without a seam by `tools/make_sfx.py`) and fade in and out as you move, the hour turns, the weather changes and sanity falls.
- **Outside:** a breeze by day that gives way to a low, cold night wind from dusk; crickets at night outside winter and heavy rain; rain on the ground at three strengths (drizzle, rain, downpour); and a beating low drone of dread that rises with the dark, with low sanity and with fog.
- **In the farmhouse:** still, cold air with wind whistling through the boards (louder at night), rain drumming on the roof and tapping the window glass, and the hearth crackling while the fire is lit.
- **In the cave:** a heavy, hollow drone with air breathing through the tunnels, and the dread drone under it.
- **Now and then**, from off to one side of the screen: crows calling by day and far off at any hour; at night an owl, a branch snapping in the trees and something howling far away, and once sanity is low, slow footsteps behind you and whispering. In the house, floorboards and beams creak (more often at night) and the whole house groans as it settles. In the cave, water drips, claws skitter over stone, pebbles trickle down, the tunnels moan and the mountain rumbles. Thunder rolls on rainy and stormy days, muffled when you're inside.
- Below a quarter of your sanity you hear your own heartbeat, faster the lower it goes.
- `tools/capture.gd` takes a `sound` option that prints each loop's level, to check the mix in a scene.

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

- The House panel (H) has one **daily job**, separate from the chores so skipping it adds no wear. It rotates each day through crops (any), fish (any), wood, stone, resin, forage (any), cooked food, and preserves. Each asks for a few of those items, which are used up when you deliver them. Delivering pays coins and XP in the job's skill, and only one delivery counts per day.

## Music

- **Music** is a lo-fi loop (`audio/dreary_loop.ogg`) that starts on the title screen and loops quietly.
- Its volume is set in Settings (0 is off). See Settings and pause.
- The loop is generated by `tools/make_music.py` (numpy synthesis, seeded, 53 seconds). It is a placeholder that can be swapped for any OGG file at the same path.

## Story chapters

The story is taught through survival. Chapters run in order. The first unfinished one is the **Current chapter** at the top of the Quests panel, with its narrative beat. Each chapter pays a reward once, then the next one opens. Chapters 11 to 17 are the second year (see The second year below) and the end.

| # | Chapter | Goal | Reward |
|---|---|---|---|
| 1 | Sleep Under Your Own Roof | Sleep in the bed before 03:00 | 40 Carpentry XP |
| 2 | Light the Way | Build a Tin Lantern | 3 turnip seeds |
| 3 | To the Wood's Edge | Walk Old Maren to the wood's edge (from day 4) | 20 Bushcrafting XP |
| 4 | Food Takes Time | Harvest 1 crop | 50 Farming XP |
| 5 | The Overgrown Plot | Reach Farming 2 (opens plot two) | 3 pumpkin seeds |
| 6 | Feed Yourself Through the Cold | Harvest 10 crops | 60 Farming XP |
| 7 | Coin for Seed | Sell 5 items at the farm stand | 30 coins |
| 8 | Something Sweeter | Harvest a pumpkin (Farming 3) | 2 pumpkin seeds |
| 9 | Clear the Stain | Cleanse the house once | 40 Cleaning XP |
| 10 | A Home Worth Keeping | Restore the farmhouse fully | 60 Cleaning XP |
| 11 | The Town Writes | Show the town's letter (from day 240) to a neighbour | 60 Bushcrafting XP |
| 12 | The Water Rises | Walk Davy to the drowned orchard (from day 265) | 6 feathers |
| 13 | His Knock | Face the Hollow when it knocks like Elias | 80 Bushcrafting XP |
| 14 | The Meeting at the Mill | Have the vote put again (from day 300; held anyway on the Harvest Moon) | 80 coins |
| 15 | Keeping Company | Find Davy at the great tree on his night (from day 370) | 80 Bushcrafting XP |
| 16 | The Second All Hallows | Hang the crow bell | 10 feathers |
| 17 | The Hollow's Grove | Walk the woman in grey to the grove | 200 Bushcrafting XP |

The first day's basics (planting, gathering, crafting, chopping, drinking) are taught by the guided first day in the diary (see The diary), not by chapters.

**The first hour** (October 2026, so a demo can show the horror): the guided first day, the first night's scare (see Nights), then the chapters in order: the bed that night, a lantern (its story recalls the figure at the field's edge, and its prompt says where it is built), the walk to the wood's edge with Old Maren from day 4 (see Groves and treks), and that night the first Hollow sighting (see Nights), which leaves Agnes's page 7. A player reaches the walk about 25 minutes in and the sighting about 30. Food Takes Time, first until then, now follows the walk: the first turnips ripen around day 8. Story Complete needs all ten chapters; a save from version 11 or older that is past day 4 has To the Wood's Edge done by the migration.

**The second year** (`scripts/story_act.gd`, `StoryAct`, `m.act`, November 2026). The homestead ladder is mostly done by about day 250, and the bell can't be hung before day 396; the act fills that wait with five beats that give the bell a cost and the systems a purpose. Each beat comes on its own day (or the first morning after, so an old save past those days isn't stuck) and is recorded in `beats` (id -> day; -1 when closed quietly). Chapters 11 to 15 read them (`act_<beat>` stats in `ProgressionSystem._stat_value`), so a beat met before its chapter is current still counts. Story Complete's goal is 17, the size of `STORY`.
- **The letter** (day 240, `FROM`): the parish meeting writes through the mail slot (signed E. Pell, clerk) that the vote of thirty-one hands to four stands and no bell is to be hung. The next walker you talk to on a farm visit reads it (`SHOWN`, a scene each; `FolkSystem._talk` asks `_folk_scene` first): Maren wonders who the four were, Davy asks why Mr Pell is so cross about a bell that does nothing, the vicar says to go to the mill with something they can't vote away, the postman watched Agnes burn hers and order the iron.
- **The water rises** (the first orchard trek from day 265): the drowned orchard has come up to Elias's eleventh row, nothing walks it, and his lantern hangs dry on a branch. Davy: "He's stopped. He's looking at your farm." (`_on_trek_arrived`).
- **His knock** (a night from 4 nights after, not before day 285, `knock_from`): the Hollow comes to the door whatever the shadow (`KNOCK`, from `NightSystem._pick`) and knocks like Elias. Faced, it leaves his thirty-year-old seed catalogue; left there, it comes back 5 nights later (`KNOCK_AGAIN`) and counts toward the Hollow's ending.
- **The meeting** (from day 300): walking Maren to the mill holds it there, once Maren has shown you Ruth's minute book (`maren_book`) and the vicar his register (`vicar_register`); short of either, Maren turns back at the mill door and says which is missing. Otherwise the town meets on the Harvest Moon (day 357) without you. With both scenes seen the vote goes the other way (`meeting` "won": the town will hang and ring the bell in turns); without, it stands ("lost": you hang it alone, against the lane), and the walkers at 6 hearts or more (`STAND_HEARTS`) are named as standing with you.
- **Davy's night** (day 370, October 5, once the orchard has risen): Mrs Tull says at dawn that Davy has gone with a lantern. From 20:00 he sits in the roots of the great tree (a night visit: `FolkSystem._visiting`, at `_spot_at("tree")`); press Space beside him before 01:00 and you talk him home (+1 heart; with the postman's last scene seen, you say the turn is yours). Missed, he goes in (`davy` "lost"): he doesn't visit and the orchard route is closed until the grove, where he comes home.
- Hanging the bell closes whatever beats are left (`_close`: no pages for them, the meeting "lost" if it was never held).

Saves from before this change reset chapter progress. Stat-based achievements re-check from saved stats, so some rewards may be paid again.

## Money and the farm stand

- Coins are the money. The HUD shows them, and they're saved.
- The **farm stand** sits on the path east of the house. It is open **06:00 to 18:00**. Walk up to it and press Space to trade.
- The farm stand **only buys what you carry**. Take crops or fish out of storage first.
- The Trade panel lists only what you carry that the stand buys, each with **Sell all**. Sell prices:

| Kind | Each |
|---|---|
| Crops | turnip 9, kale 7, peas 5, corn 13, potato 8, leek 18, pumpkin 19, parsnip 15, strawberry 12, garlic 24, blueberry 13 (`CROP_VALUE`) |
| Animals | egg 3 (`SELL_EGG`), goat milk 6 (`SELL_MILK`) |
| Fish | perch 6 (`SELL_FISH`), bluegill 5, crappie 8, bullhead 9, trout 10, lamprey 12, pale carp 26, sturgeon 45 |
| Forage | rose hips and nettles 2, salmonberries, blackberries and fiddleheads 3, huckleberries 4, yellowfoot 5, oyster mushrooms 6, chanterelles 7, morels 10, ghost pipe 14 (cut by about 40% in the economy pass) |
| Cooked | 8 (grilled fish, hash, tea) to 80 (sturgeon steak); see Cooking |

- Apples aren't sold at the stand.
- **Demand** (`StallSystem`, October 2026 economy pass): the lane takes only so many a day at full price (`STAND_DEMAND`): **15 of each crop**, **2 eggs**, **1 milk**, and **6 fish, 3 forage and 2 cooked food** each counted together. Past that each one sells for less, falling to 30% of the price (`STAND_FLOOR`) by the time it is sold as many again; each morning the lane takes back a day's demand. The Trade panel shows what the next one fetches, the price when wanted, and how many more the lane takes today at full price; a sale under full price says the lane has had its fill. So it pays to grow a spread of crops, to keep the keepers in the cellar (the cellar room keeps every crop) for another day, and to cook eggs, milk and surplus into rations and recipes. The covered porch raises every demand by a quarter. Trek trade ignores the curve (see Groves and treks).
- **Crops are the main income.** Each crop's first harvest pays at least twice its seed (turnip 9 for a 3-coin seed, corn 26 for 6, pumpkin 38 for 10, garlic 48 for 12, leek 18 for 7); strawberries (12 a picking, 14 a seed) and blueberries (26 a picking, 25 a seed) pay back over their regrowing. Kale regrows every 5 days (4 until the economy pass, when it was a third of every harvest).
- **Eggs and milk** sell under the crops a hen or goat eats (an egg 3 against a turnip's 9), and the lane wants few: they are worth most in rations, bread, colcannon, chowder, pies and cobbler. Before the economy pass they earned 20,000 a year, 2.5 times the crops.
- **Targets** (an engaged player walking 3 treks a week; checked with `tools/balance_sim.gd`): coins in the low thousands for most of the first year, with a next thing to save for at every point (the catalog and furniture early; the cellar room and porch from the second week; the mill path's trail works from day 14; the second storey and the summer works once the house is restored; and the land deed, open from the first weeks, taking what is spare); no stockpile of any material over a few hundred by day 400; the land deed and the three extensions done in the second year.
- **Balance check (October 2026, the economy pass).** Before it, 400 days with treks=3 ended with **41,400 / 40,042 / 40,387 coins** (engaged / ignore / earlybed): eggs and milk 20,032, cooked 10,467, crops 8,023, forage 7,410; copper bars 1,960, hardwood 2,143, iron ore 907 unsmelted, sticks 1,086, feathers 1,056; tax 1,350 a year. After it (`tools/balance_sim.gd`, `days=400 every=40 treks=3`):
  - **Coins** stay between about 150 and 2,500 all year in every mode (engaged at days 41/81/121/161/201/241/281/321/361/400: 679, 808, 1,035, 956, 1,116, 1,398, 1,066, 1,743, 1,097, 1,226; ignore ends at 1,161, earlybed 476).
  - **Income, engaged:** crops 6,323, forage 4,152, eggs and milk 4,138, cooked 3,570, trek trade 1,824 (ignore and earlybed alike, crops 6,354 and 7,353). **Spent:** the estate 10,900 (cellar room day 102, porch day 140, all six pieces of furniture, wallpaper, paint, and 7,000 of the deed, begun on day 38), trail works 6,050 (the six old ones, the handcart and the oil tins; ignore built all nine, 7,550), tax 2,357, seeds 2,012, oil 960.
  - **Materials at day 400:** copper bars 355 to 427, iron bars 327 to 354, hardwood 226 to 311, stone 345, sticks 186 to 301, feathers 81 to 208 (with 145 to 234 crow charms made), resin about 220, wood about 200.
  - **Homestead ladder** unchanged: the lamp post on day 67 to 69 (smelting XP doubled to keep Smithing's pace), the barn 112 to 113, the house restored 244, the bell 396. Sanity no lower than 75 / 55 / 58.
  - **With the mill path from day 14** (October 2026, the first-hour session; same command): the edge walk on day 4, the first mill trek on day 21 (the sim waits for an egg for its ration), waymarks day 22, footbridge 29, gate lamp 44 to 55, so the first winter's coins go into the wood five weeks sooner. Coins, engaged at days 41 to 400: 419, 1,380, 1,175, 939, 1,482, 1,081, 1,037, 150 (the chapel steps, handcart and oil tins all come in late summer), 1,498, 336; ignore ends at 597, earlybed 621, and both stay between about 250 and 2,100 all year. Mill treks 52 / 55 / 61 (from about 40), trail works 7,550 / 4,550 / 6,050 (engaged now builds all nine, by day 394), deed 5,500 / 7,500 / 3,500 paid by day 400, the grove walked on day 399 / 399 / 400, sanity no lower than 76 / 55 / 68. The targets above still hold.
  - **Year two** (engaged, 730 days): the second storey on day 481 and the land deed owned on day 598; after that coins rise to about 4,500 by day 730, and copper (814), iron (691) and hardwood (503) build up again, which the mid-game act should give a use.
- The stand only sells. Seeds and livestock are ordered from the **catalog** at the desk (see Farmhouse).

## Pack, bags, and storage

- The **pack** holds crops, fish, eggs, milk, and every cooked food, each under its own name and picture. Seeds have their own pouch and don't count. Materials are uncapped for now.
- The pack starts at **20 slots**. Like items stack up to **28** to a slot, so a kind takes as many slots as its stacks need. Grid menus (Skills, Inventory, Craft, Gear) sit centred in the menu box. The Inventory panel (I) shows what you carry as a grid of picture tiles, one per kind with its count, like the Craft panel: the pack's crops, fish, meals, and preserved goods, then the seed pouch and the materials you hold. Every item has a drawn picture. The name shows only on the highlighted tile. The bag is kept small: twenty square 52-pixel slots, four across, each with a centred picture and its count in the corner, and the name of the slot in focus (or under the mouse) in one gold line under the grid. Picking a tile fills the detail card beside the grid, which holds the **Eat** button for crops and meals. The pack's slots used and the next bag are listed under the grid. The Body meters and the planting options sit below it.
- The seed pouch is a small grid with a count on each seed type.
- The Gear panel is a paper-doll grid of nine slots. The slots and crafting are described under Gear and crafting below.
- **Bags** (bought with coins, fiber, wood, and Carpentry level):

| Bag | Slots added | Cost | Carpentry |
|---|---|---|---|
| Satchel | +10 | 40 coins, 4 fiber | 1 |
| Haversack | +10 | 120 coins, 4 wood, 8 fiber | 3 |
| Backpack | +10 | 300 coins, 8 wood, 12 fiber | 5 |

- **Root cellar** (built from the House panel, stores **30 crops** of the kinds that keep: turnips, potatoes, leeks, parsnips and garlic, counted by kind in `cellar`): 25 coins, 4 wood, 2 fiber, Carpentry 1. It is dug against the house's west wall, so it reads as part of the house. Stand beside it, facing it, and press Space to store or take crops. Nothing spoils in the cellar. Storing is always manual: harvests go to the pack, and a harvest is refused if the pack is full.
- **Cooler** (built from the House panel, stores **10 fish** of any kind, counted by kind in `cooler`): 40 coins, 4 wood, 4 fiber, Carpentry 2. Fish kept in the cooler don't spoil. It sits inside the house, in the hall. Stand beside it, facing it, and press Space to store or take fish.
- **Fish spoil:** any raw fish of any kind still in the pack at the end of the day are lost. The end-of-day message says how many. Storing fish in the cooler is the only way to keep them overnight.
- **Full pack:** storage is always manual. A full pack stops harvesting and fishing with a message. Store fish in the cooler, or sell or cook them, to keep going.

**Smokehouse** (built from the Buildings menu, in the workshop): 60 coins, 5 wood, 3 fiber, Carpentry 4. Stand beside it, facing it, and press Space to preserve food. Preserved goods live in the pack and never spoil overnight.

| Method | Input | Needs | Makes | Sells | Skill |
|---|---|---|---|---|---|
| Smoke a fish | 1 fish (any) | 1 wood | Smoked fish | 11 | Cooking 2 |
| Dry turnips | 2 turnips | none | Dried crops | 9 | Farming 2 |
| Can turnips | 2 turnips | 1 fiber | Canned turnip | 10 | Cooking 3 |
| Ferment turnips | 2 turnips | 1 wood | Fermented turnip | 11 | Cooking 4 |
| Make jam | 3 berries (any) | 1 fiber | Bramble jam | 10 | Cooking 2 |
| Dry mushrooms | 2 mushrooms (any) | none | Dried mushrooms | 12 | Cooking 3 |
| Smoke a lamprey | 1 lamprey | 1 wood | Smoked lamprey | 34 | Cooking 4 |

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
- Every cooked food is named for what made it and has its own picture. Recipes are in `Foods.RECIPES` (`scripts/foods.gd`). A recipe input is a pack key (turnips, potatoes, trout...), a material (wood, fiber, flour), or a **group**: *fish (any)*, *berries (any)* (strawberries, blueberries, salmonberries, huckleberries, blackberries) or *mushrooms (any)* (chanterelles, yellowfoot, oyster mushrooms, morels). A group is spent cheapest first.
- Some foods do more than fill you (`effect` in `Foods.LIST`): **warm** (warmth), **water**, **calm** (sanity on top of the usual; below zero it unsettles you) and **nerve** (eaten on a trek, it steadies the walker too). The detail card lists them.
- At the fire (the Craft panel's Cooking tab):

| Dish | Needs | Level | Sells | Also |
|---|---|---|---|---|
| Grilled fish | 1 fish (any), 1 wood | Cooking 0 | 8 | |
| Turnip hash | 2 turnips, 1 wood | Cooking 0 | 8 | |
| Baked potato | 1 potato, 1 wood | Cooking 1 | 9 | +10 warmth |
| Rose hip tea | 3 rose hips, 1 wood | Cooking 1 | 8 | +15 warmth, +20 water, +4 calm |
| Nettle soup | 2 nettles, 1 wood | Cooking 1 | 10 | +10 warmth, +15 water |
| Trail ration | 1 egg, 1 turnip, 1 wood | Cooking 2 | 10 | steadies a walker (trek) |
| Pea soup | 3 peas, 1 wood | Cooking 2 | 12 | +15 warmth |
| Fiddlehead fry | 2 fiddleheads, 1 egg, 1 wood | Cooking 2 | 14 | |
| Farmhouse bread | 2 flour, 1 egg, 1 wood | Cooking 3 | 14 | for a walker with no rations |
| Pumpkin soup | 2 pumpkins, 1 wood | Cooking 3 | 12 | +10 warmth |
| Fish stew | 1 fish (any), 2 turnips, 1 wood | Cooking 3 | 13 | +10 warmth |
| Colcannon | 2 potatoes, 1 kale, 1 milk, 1 wood | Cooking 3 | 18 | +10 warmth |
| Leek and potato soup | 1 leek, 2 potatoes, 1 wood | Cooking 3 | 20 | +25 warmth, +10 water |
| Roast roots | 2 parsnips, 1 turnip, 1 wood | Cooking 3 | 22 | +15 warmth |
| Bullhead fry | 1 bullhead, 1 corn, 1 wood | Cooking 3 | 16 | +10 warmth |
| Corn chowder | 2 corn, 1 potato, 1 milk, 1 wood | Cooking 4 | 24 | +20 warmth |
| Forager's stew | 2 mushrooms (any), 1 leek, 1 wood | Cooking 4 | 22 | +25 nerve, +10 warmth |
| Garlic trout | 1 trout, 1 garlic, 1 wood | Cooking 4 | 26 | +6 calm |
| Apple crumble | 2 apples, 1 flour, 1 wood | Cooking 4 | 22 | +8 calm |
| Hearty stew | 1 smoked fish, 2 turnips, 1 wood | Cooking 5 | 20 | +15 warmth |
| Pumpkin pie | 1 pumpkin, 1 flour, 1 egg, 1 wood | Cooking 5 | 30 | +10 calm |
| Berry cobbler | 3 berries (any), 1 flour, 1 egg, 1 wood | Cooking 5 | 30 | +10 calm, +15 nerve |
| Ghost pipe tincture | 1 ghost pipe, 2 rose hips, 1 wood | Bushcrafting 5 | 40 | +20 calm, +40 nerve |
| Sturgeon steak | 1 sturgeon, 1 garlic, 1 wood | Cooking 6 | 80 | +20 warmth, +10 calm |

- At the smokehouse: smoked fish, dried turnip, canned turnip, fermented turnip, bramble jam, dried mushrooms and smoked lamprey (see the table under Pack, bags, and storage).
- Each food has a difficulty (1 to 5) and the level needed to obtain it. Both set how much it restores, and cooking it gives XP in its skill.
- Foods are kept in the pack as their own stacks. Eat them from the bag or the Inventory panel.

## Farming and crops

- Eleven crop kinds, each with the Pacific Northwest seasons it grows in (`CROPS` in `main.gd`, days in `CROP_GROW_DAYS`, prices in `CROP_VALUE`). **Planting out of season is refused**, and a crop still in the ground when its seasons end **withers** the next morning. The morning note warns three days before a season turns, and again on its last day, while any crop would wither. Turnips grow in every season, so the trail rations always have their staple.

| Crop | Seasons | Farming | Days | Yield | Regrows | Seed back | XP | Sells | Seeds (catalog) | Cellar |
|---|---|---|---|---|---|---|---|---|---|---|
| Turnip | all year | 0 | 7 | 1 | | 50% | 25 | 8 | 5 for 15 | keeps |
| Kale | autumn, winter | 1 | 6 | 1 | every 4 days | 10% | 14 | 6 | 5 for 20 | |
| Peas | spring | 1 | 6 | 2 | every 3 days | 10% | 12 | 3 | 5 for 15 | |
| Corn | summer, autumn | 2 | 8 | 2 | | 50% | 30 | 10 | 4 for 24 | |
| Potato | spring, summer | 2 | 8 | 3 | | 50% | 30 | 6 | 4 for 20 | keeps |
| Leek | winter, spring | 2 | 9 | 1 | | 50% | 32 | 14 | 4 for 28 | keeps |
| Pumpkin | summer, autumn | 3 | 10 | 2 | | 50% | 40 | 15 | 3 for 30 | |
| Parsnip | winter, spring | 3 | 9 | 2 | | 50% | 38 | 11 | 4 for 32 | keeps |
| Strawberry | spring, summer | 4 | 8 | 1 | every 4 days | 5% | 18 | 9 | 3 for 42 | |
| Garlic | autumn, winter | 4 | 12 | 2 | | 50% | 45 | 17 | 3 for 36 | keeps |
| Blueberry | summer | 5 | 10 | 2 | every 5 days | none | 20 | 8 | 2 for 50 | |

- **Regrowing crops** stay in the ground after picking and go back to `CROP_GROW_DAYS - regrow` watered days, so they ripen again after that many more watered days, until their season ends. The rest come up when harvested.
- What each season offers: spring has turnips, peas, potatoes, leeks, parsnips and strawberries; summer turnips, corn, potatoes, pumpkins, strawberries and blueberries; autumn turnips, kale, corn, pumpkins and garlic; winter turnips, kale, leeks, parsnips and garlic. A new game starts on October 1st, so the first crops past turnips are kale (Farming 1), corn (2) and pumpkins (3), and the first winter has leeks, parsnips and garlic to grow.
- Planting uses the **selected seed**. The trowel's cycle (and the Inventory panel's Switch) steps through the seeds you hold that are unlocked and in season. If the selected kind isn't unlocked, turnip is planted. The seed tiles in the Inventory panel give each kind's seasons, days and yield.
- Seeds come from the catalog at the desk, one pack per kind (`pack` and `seed_price` in `CROPS`), and can be ordered out of season to plant when it comes.
- Feeding animals and offerings take crops **cheapest first** (peas, kale and potatoes before turnips; garlic last). Apples aren't crops for this.
- Planting gives 5 XP.
- Art: turnip, corn and pumpkin have SpriteCook strips (`art/farm/crop_<kind>.png`, four 16 px stages). The other eight are drawn in code (`FarmArt.draw_crop`) until their strips are made; `FarmSprites.has` picks the strip when one exists. Their pack icons are code-drawn too (`ActionBar.RecipeIcon`: leafy, pod, potato, leek, root, berry, bulb, seed_t).
- **Crops need water.** A crop grows overnight only if it was watered that day. A crop that wasn't watered stays at its stage, and the morning message says how many went thirsty. Watering is covered under Well and watering: by hand one crop a press at first, then a nozzle (3 a press, Smithing 3), a spray head (9 a press, Smithing 6) and sprinklers that water each morning (Smithing 4). The tank (40, or 64 with the copper cistern) is still what limits how many crops can grow on a dry day.
- Plot two stays overgrown until Farming 2. Walking up to it says so.

## Fishing

- How fishing works (spots, rolls, rods) is under Skills. Every catch is now one of eight pond fish (`FishingSystem.FISH`; names, prices and food in `Foods.LIST`). When a roll lands, a fish is drawn by weight from the ones biting: those in season, at the right hour, and at or under your Fishing level. Perch always bite, so there is always something. The cast message lists what is biting.
- "Day" is 06:00 to dusk (19:00), "night" from dusk to 03:00, "late" from 22:00, when the night visitors come.

| Fish | When | Fishing | Weight | Sells | Notes |
|---|---|---|---|---|---|
| Yellow perch | all year, any hour | 1 | 40 | 6 (`SELL_FISH`) | the old "fish" key |
| Bluegill | summer, day | 1 | 35 | 5 | |
| Cutthroat trout | spring and autumn, day | 2 | 22 | 10 | garlic trout |
| Black crappie | winter and spring, any hour | 2 | 28 | 8 | the winter fish |
| Brown bullhead | summer and autumn, night | 3 | 40 | 9 | bullhead fry |
| Lamprey | winter and spring, night | 4 | 22 | 12 | -2 calm raw; smoked lamprey |
| Pale carp | all year, late | 5 | 7 | 26 | landing one costs 3 sanity, eating it raw 8 |
| White sturgeon | all year, day | 6 | 3 | 45 | sturgeon steak |

- XP is 15 a catch plus 5 for each Fishing level the fish needs past the first. Night catches are counted (`stats["night_fish"]`).
- Every raw fish **spoils** in the pack overnight. The cooler keeps 10 fish of any kind; the dearest go in first and come out first. Raw fish can be eaten ("Eat raw"), sold, smoked, or cooked into any fish (any) recipe, and the vicar buys all but the pale carp on a chapel trek.

## Forage

- Wild food comes up at the edges of things (`scripts/forage_system.gd`). Each morning **2** forageables, plus one per three Bushcrafting levels (at most 5; 3 and 7 until the October 2026 economy pass), come up on open grass beside the farm's trees; yesterday's unpicked ones go over. Each trek clearing has **2** beside the trail. Face one and press Space to pick it (no tool): **8 XP plus 3 per level** the find needs, in Bushcrafting. A full pack leaves it where it is.
- What comes up is drawn by weight from what's in season and known at your Bushcrafting level. The day's farm finds are saved with the day.

| Forage | Seasons | Bushcrafting | Weight | Sells | Used in |
|---|---|---|---|---|---|
| Stinging nettles | spring | 1 | 30 | 2 | nettle soup |
| Fiddleheads | spring | 1 | 24 | 3 | fiddlehead fry |
| Salmonberries | spring, summer | 1 | 24 | 3 | berries |
| Blackberries | summer, autumn | 1 | 30 | 3 | berries |
| Rose hips | autumn, winter | 1 | 30 | 2 | rose hip tea, tincture |
| Chanterelles | autumn | 2 | 20 | 7 | mushrooms |
| Yellowfoot | winter | 2 | 22 | 5 | mushrooms |
| Huckleberries | summer | 3 | 18 | 4 | berries |
| Oyster mushrooms | winter, spring | 3 | 16 | 6 | mushrooms |
| Morels | spring | 4 | 8 | 10 | mushrooms |
| Ghost pipe | summer, autumn | 5 | 5 | 14 | ghost pipe tincture (not eaten raw) |

- Forage is drawn in code on its own layer (a rosette, a mushroom cluster, a berry cane, fern curls or white pipes, in the find's colour). The daily job can ask for 3 forage of any kind.

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
| Patched | 5 | 4 | 3 |
| Restored | 8 | 6 | 8, in summer only (the paint needs a dry season) |

- The hall and bedroom are open from the start, so the bed is usable right away. Other rooms open as the house is repaired:
  - **Hall:** open from the start, with the exit mat.
  - **Bedroom:** open from the start. The bed saves and ends the day.
  - **Parlor (Patched):** a cleaning station. Tidy once a day for Cleaning XP.
  - **Study (Restored):** an empty room. The desk stays in the bedroom.
  - **Pastimes:** the Desk panel has **Solitaire** (1 hour) and **Sudoku** (1 hour 30). They are not played out: Play passes that much time (needs drop and the fire burns as usual), closes the panel, and the day's first game gives sanity and some lost limit back (see Sanity and horror). Solitaire uses a game from the **pack of cards** (a worn pack with 5 games is in the drawer at the start; a new pack lasts 15). Sudoku uses a puzzle from the **sudoku book** (10 puzzles; none at the start). A pastime has to be over by 02:00.
  - **Catalog:** the Desk panel's catalog is where everything for the farm is bought. An order is paid at once and comes with the next morning's post, with a Delivery letter; animals go straight into their pens. It sells: a pack of cards (10 coins), a sudoku book (12), 5 turnip seeds (15), 4 corn seeds (24, Farming 2), 3 pumpkin seeds (30, Farming 3), a hen (12, needs the coop and room, counting hens on order), a goat (45, needs the barn and room), and lamp oil for treks (8 a flask). Nothing you can gather (wood, fiber, resin, stone, hardwood) is sold here. Pending orders are saved.
- A restored house softens the night overall.
- **Cleanse** (House panel): needs Cleaning 3 and 2 harvested crops. Once a day. Lifts the sanity limit by 5 and cures part of the collapse penalty.

## Skills (RuneScape-style)

- The Skills panel (K) is a grid of ten picture tiles, each showing the skill's drawing and its level. Picking one fills the detail card with what trains the skill, its XP bar, and the XP left to the next level.
- Ten skills, each with XP and levels. Each level costs more than the last: level 2 at 100 XP, level 3 at 300, level 4 at 600, level 5 at 1000 (50 × (L−1) × L XP in total). Past level 5 each level costs 1.8 times the one before (`STEEP_GROWTH` in `progression_system.gd`): level 6 at 1720, 7 at 3016, 8 at 5349, 9 at 9548, and level 10, the highest (`LEVEL_CAP`), at 17106:
  - **Farming:** planting gives 5 XP, and each harvest its crop's XP (12 to 45, see Farming and crops). Level 2 opens plot two. Levels 1 to 5 unlock the crops.
  - **Bushcrafting:** gathering a brush pile gives 10 XP; picking forage 8 plus 3 per level the find needs (see Forage). Level 3 adds three thicket piles.
  - **Carpentry:** each house repair gives 30 XP. Mending a board (1 wood, 1 fiber, from the House panel) gives 15 XP, capped at 2 mends per day so the house can't be finished in one day. Training to level 2 takes about 3 days, and level 3 takes about a week.
  - **Cleaning:** each daily tidy gives 20 XP. At Cleaning 2, a tidy also gives +3 sanity. Cleaning 3 unlocks the cleanse.
  - **Cooking:** each recipe gives its own XP (10 to 40). See Cooking above.
  - **Fishing:** face a sparkling spot on the pond edge and press Space to start fishing it, like RuneScape. While you keep still and face the spot, you roll for a catch every 3 seconds. The chance starts at 50% and rises 3% per level, up to 90%. Each catch gives 15 XP, plus 5 for each level the fish needs past the first; which fish it is depends on season and hour (see Fishing). Each spot stays active for 15 to 30 seconds, then goes quiet and a new spot appears elsewhere on the pond edge. There are 3 spots, with one more at Fishing 3 and another at Fishing 5. Moving, going inside, opening a panel, or pressing Space again reels the line in. The spot you fish looks like any other spot: no ring is drawn around it, and the cast line and bobber show which one you're on.
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
- **Hose heads** (Craft panel, Tools; `TOOL_TIERS["hose"]`, saved in `tool_tier`): the **copper nozzle** (6 copper bars, 2 fiber, Smithing 3) waters the three crops in a line running away from you with one press, and the **spray head** (10 copper bars, 2 iron bars, Smithing 6) the 3 by 3 whose near middle is the crop you face. Each crop still takes 1 water, and crops already watered or ripe are skipped. With a head on, pressing on a watered crop still waters the rest of its spray.
- **Copper cistern** (Well panel, 40 copper bars, 4 iron bars, Smithing 5, a working pump): the tank holds **64** instead of 40 (`CISTERN_CAPACITY`). It is where the cave's copper goes, and it lets more crops grow on a dry day.
- **Sprinklers** (Buildings, Decor; 5 copper bars and 1 iron bar each, Smithing 4, up to 12): placed on an empty plot tile instead of grass, piped from the well. Each dry morning (after the tank refills; rain has already watered everything) each sprinkler waters the growing crops on the 8 tiles around it, a water each from the tank, and the morning message says how many (and if the tank ran dry). With the hose not attached they do nothing. They block walking, like lamps; Space twice takes one down. Drawn in code (a copper riser and spinning head) until its SpriteCook art.
- **Rain waters every crop** on a drizzly, rainy, or downpour day, so those crops grow without the hose. Sunny, overcast, fog, and snow days don't water.
- The Inventory's Planting section shows how many growing crops are watered today.
- The well's panel also drinks from the pump, for +35 water, at no cost.

## Body needs

- Three meters run from 0 to 100: **Food**, **Water**, and **Warmth**. They show on a line under the top bar, in red when one is under 25, and in full in the Body section of the Inventory menu (I), below the pack.
- **Food** drains about 2.4 an hour, so it runs out in about two days. Every food restores food, sanity and HP from its difficulty (1 to 4) and the level needed to obtain it: food = 10 + 12 × difficulty + 3 × level, sanity = 1 + difficulty + level ÷ 2, HP = difficulty. A raw turnip restores 22 food and a hearty stew 73. Eat food from the bag or the Inventory panel.
- **Water** drains about 3 an hour, and 1.6 times faster on hot days (75°F and up). Face the **pond** and press Space to drink, for +40 water.
- **Warmth** depends on the temperature. Outside it drains when it's below 50°F, faster the colder it gets. In mild weather it slowly refills. Inside the house it refills, faster once the house is patched. Sleeping in bed fills it to 100.
- **Hale:** while food, water and warmth are all at 70 or more, every skill gains 20% more XP. A gold **Hale** tag shows beside the meters while it lasts.
- If any need is empty, you lose 1 HP every 2 hours until it's filled. Dropping to 0 HP collapses you at the homestead, as losing a fight does.
- **Temperature** is shown in °F. It's the season's average (winter 40, spring 51, summer 67, autumn 54), plus a daily swing of about 7 degrees, coldest near dawn and warmest in the evening, plus the day's weather (sun +6, overcast 0, fog −2, drizzle −3, rain −4, downpour −6, snow −10).

## Sanity and horror

- Sanity runs from 0 to a maximum that drops with each collapse. It shows in the HUD as `Sanity current/max`.
- Outdoors in the dark, away from a lamp, sanity drains 0.91 a game hour (`DARK_SANITY_DRAIN`). Indoors it recovers 0.46 a game hour, 0.69 once the house is boarded (`INDOOR_SANITY_RATE`, `SHELTER_SANITY_RATE`); daylight outdoors neither drains nor restores it. Tidying gives +3 (+3 more at Cleaning 2), a night with every chore done +2, and sleeping +8 (`SLEEP_SANITY`), plus 0.2 for every point you are under 60 (`LOW_REST_GAIN`), so a run of bad nights settles into a trough instead of spiralling. (Until November 2026 tidying gave 5, a kept night 3, sleep 12 and a pastime 5: the day refilled whatever the night took, and sanity never got low enough to matter.)
- The day gives back about 25 sanity. A summer night takes about 9 to 44, a winter night twice that (capped at 45 for one visitor, `NIGHT_CAP`), so winter and runs of skipped treks wear you down and spring lets you recover. Balance sim, 400 days with treks=3 (November 2026): facing the visitors, sanity sits at 67 to 96 at the sample days and bottoms out at 26 in midwinter (11 days under 60, 2 under 40, none under 20); ignoring them, it bottoms at 16 (88 days under 60, 10 under 40, 2 under 20); going to bed early, at 7 (66 / 19 / 5 days), with the vicar's blessing taken 4 times. No run lost any sanity limit, and every mode was back near full by spring. Coins at day 400: 769 / 1,118 / 1,144. Facing is the safer choice, and the nights are what moves sanity.
- Below 30 sanity, the whole screen gets darker.
- **Low sanity changes the world** (`scripts/madness_system.gd`), in tiers under 60, 40 and 20. None of it costs anything by itself; it tells you how far gone you are. Under **60**: crows sit on the roof and the tree tops by day with their heads turned to you (two, three under 40, five under 20, red-eyed at the last), and you hear footsteps behind you by day. Under **40**: a figure stands at the edge of the screen for a moment and is gone if you walk toward it (every 30 to 70 seconds, 12 to 30 under 20); once a day the tool in your hand is not the one you picked up; something knocks at the door, and at night the hens or goats cry out. Under **20**: the HUD lies, the clock showing the wrong hour for a few seconds now and then, and a ripe pumpkin stands on an empty plot tile until you come near ("You're sure there was."); the door opens on its own. The false sounds are ambience events with a `fear` (`AmbienceSystem.EVENTS`). `tools/capture.gd` shows a tier with `sanity=N madness`.
- **The vicar's blessing** (the way back from the bottom): waking under 20 sanity (`BLESS_BELOW`), the vicar is at the gate that day, at most once a week (`BLESS_WAIT`; saved as `bless_offer_day` and `bless_day`). The House section then offers his blessing for 3 crops for the poor box: +30 sanity, 5 of the lost limit back, and that night's losses halved like a crow charm (without using one up).
- At 22:00 something comes to the farm. See **Nights** below.
- **Collapse penalty:** missing the bed by 03:00 lowers the sanity limit by 5 permanently. A **cleanse** (see Farmhouse) lifts it by 5 per use, once a day.
- **Pastimes:** the day's first finished game at the **desk** (Solitaire or Sudoku) gives +3 sanity (+5 until November 2026) and wins back 2 points of lost sanity limit (boredom loss from older saves first, then the collapse penalty). A day without one costs nothing.

## Nights

Nights are a choice, not just a sanity cost (`scripts/night_system.gd`). At 22:00 one visitor comes. **Facing it** costs a little sanity now, leaves **crow feathers**, and pushes the field shadow back. **Ignoring it**, by waiting until 01:00 or going to bed (even before 22:00: the visitor still comes to a sleeping house), costs more sanity and lets the shadow creep closer.

- **The first night** (day 1) is always the same short scare instead of a random visitor, and teaches the dark, sanity and the bed. It runs on the game clock, so the pause menu or any open panel holds it, and it plays only once (a save made after 22:00 on day 1 doesn't replay it). Beats, in game hours after 22:00 (about 20 seconds each): at 0, the crows stop calling and the farm goes quiet; at 0.4, footsteps behind you outdoors or three knocks indoors (2 sanity); at 0.9, the figure appears at the field's edge with a sting (seen "through the window" from inside); at 1.5, a whisper and a note that the dark wears at your Sanity and that the house and bed put it right, plus a nudge to build a lantern if you have none. The figure can be faced like the field figure (2 sanity, 1 feather) or left (3 sanity, at bed or 01:00); it never moves the field shadow. Going to bed before 22:00 on day 1 skips the scare and costs the same 3. `tools/capture.gd` shows it with `visitor=first beat=N`.
- **The first Hollow sighting** (`SIGHTING`, once: `sighting_seen`, saved from save version 12): on the night of the walk to the wood's edge (see Groves and treks), or on day 9 (`SIGHTING_BY`) if Maren hasn't been walked, it comes instead of a random visitor, in beats like the first night (`SIGHTING_BEATS`, game hours after 22:00). At 0, every crow in the great tree goes up at once. At 0.5, the Hollow's crow-black shape (drawn as the Hollow, with its red glow) stands at the field's far edge, where the shadow starts, and only looks at the house (seen "through the window" from inside). At 1.3, it comes apart into crows that pour into the great tree's roots, and Agnes's page 7, "What the crows bring", about the hollow under the tree, is caught on the fence wire where it stood (`Mystery._on_sighting`). Walking out at it (Space within 6 tiles) ends it early the same way, and counts as faced. It costs 2 sanity before the night multipliers (about 1.5 after the walk's halving), never moves the field shadow and leaves no feathers. Asleep, it is told in the morning message (the grass at the far edge pressed flat in a wide ring) and the page is found then. `tools/capture.gd` shows it with `visitor=sighting beat=N` (0 to 2) and a `tile=` near the far edge, such as `tile=54,17`.
- **How to face each one** (November 2026; before then each was one Space press). Every visitor is a short piece of play with light and where you stand, under a minute of real time, run on the game clock (a game hour is 20 seconds) so menus hold it. Your **light** is your lantern's ring (2.5, 4 or 6 tiles for the Tin, Brass and Hollow lanterns), or arm's length (`NEAR`, 1.4 tiles) without one; a **lamp post** (or the restored house's porch lamp) lights its spot on its own at half strength (`LAMP_HOLD`). The first three times you meet each one (`seen`, saved), its messages say what to do.
  - **The field figure** (and the first night's): hold it in your light until it fades (`HOLD_HOURS` 0.4 game hours, the first night's 0.3). A pale ring fills round its head. Twice it slips back into the dark, four to six tiles on and away from you, and has to be found again, so a bigger lantern makes it quicker. Space face to face adds a quarter.
  - **The knocking:** indoors, the latch rattles three times (`KNOCK_TIMES`, 0.3 game hours apart); stand by the door (within 2 tiles of where you come in) to hold it shut each time. Held at all but one, it's answered; each one missed swings the door a hand's width open (a strike). Outdoors, or if you go out, the knocker stands at your door and is held in the light like the field figure.
  - **The crows:** three crows drop onto your growing crops nearest the great tree, one at a time (`CROW_TIMES`). Get each into your light, or Space at it, within 0.4 game hours or it pecks that crop back a stage. Two of three scared off answers it, with a feather for each.
  - **The pond lights:** they swell and fade every 3 seconds (`PULSE_HOURS`). Face them from the bank and press Space as they swell brightest (a ring shows the moment); three right answers it (two fish), three wrong (each a strike) and they go out.
  - **The tall watcher:** hold it in your light for 0.5 game hours, but while lit it steps toward you; if it reaches you it lunges (a strike, a third of the hold lost) and is back by the house. Back away as it comes: the Hollow Lantern's six tiles make it easy, the Tin Lantern's hard.
  - **The footsteps:** pale prints circle you, closing in while you're in the dark (`STEPS_CATCH`, 0.7 game hours, slower with a Brass lantern or better). Reach the house, or stand in a lamp post's light for 0.35 game hours until they pass. Caught, it counts as ignored.
  - **The Hollow:** held like the field figure but for 0.9 game hours, slipping away twice near the house and lunging like the watcher.
  - A **strike** costs 3 sanity (`STRIKE_SANITY`) before the night multipliers. A lost encounter counts as ignored: its loss, its creep and the shadow's blight.
- **Visitors** (sanity lost facing / ignoring or losing, before `NIGHT_LOSS_MULT`, which scales every night loss by 2.2, 1.5 until November 2026):
  - Always: the figure at the field's edge (4 / 10, 1 feather), knocks on the front door (5 / 12, 1 feather), and a quiet night (3, nothing to answer).
  - After 7 nights: the crows wake in the great tree (4 and a feather for each one scared off / 7, and the crops they were on, or up to three, pecked back a stage, losing that growth), pale lights in the pond (5 and two fish / 8), and a tall watcher beside the house (10 and 2 feathers, pushes the shadow back 2 / 20).
  - After 14 nights: footsteps follow you when you're outdoors (4 / 18).
  - Newer visitors are likelier, the same one never comes two nights running, and the pick is fixed by the day.
- **The field shadow** starts at the far east of the field and moves 4 tiles toward the house for each ignored or lost visitor (knocks, field figure, watcher, footsteps), and back for each faced one. **Its blight:** each step it creeps, the grass it crosses dies, and it reaches for the 2 crops nearest it (`BLIGHT_PER_STEP`): each wilts back a stage (a seedling dies), with a line of dead grass from the shadow to it. The dead grass shows by day and fades over 6 days (`BLIGHT_DAYS`, saved as `night_blight`), so a run of ignored nights is written across the farm. After 8 steps it reaches the house, and that night **the Hollow** comes to the front door: a towering cloud of crow-black with red eyes. Facing it costs 20 sanity, gives 5 feathers, and sends the shadow back to the far edge. Ignoring it costs 30 and lowers the sanity limit by 5 (lifted by cleansing), blights the 4 crops nearest the door (`BLIGHT_HOLLOW`), and the shadow only falls back halfway.
- **Seen in the dark:** visitors are drawn above the buildings, with a faint red glow at eye height (pale blue for the pond), so their outline and eyes show at night.
- **Crow charm** (Craft, Other tab; Bushcrafting 2): 4 crow feathers bound on 1 stick (3 feathers and 1 fiber until the October 2026 economy pass, which made it the steady use for spare feathers and sticks). One charm carried at 22:00 is used up and halves everything that night takes from your sanity. Facing 10 visitors earns the **Into the Dark** achievement (3 feathers and 3 fiber).
- **Raids** (from the 7th night, once there are hens or goats): some nights, at 23:00 to 23:30, something comes for the animals: a **fox** at the coop door, **crows** on the coop roof, or something low at the **barn** door. The chance is 12% a night (`RAID_CHANCE`), +12% once the house is at 4 wear (`WEAR_FOX`), +2% a shadow step, halved by a lamp post lighting the spot. Get there and light it (or Space at it) within an hour of game time to drive it off (the crows leave a feather). Lost, the fox takes a hen, the crows cost the next morning's eggs, and the thing at the barn the next morning's milk (and a goat, at 4 wear or more): all of it can be bought back from the catalog. Asleep, a raid is lost, unless a lamp post lights the spot: then it keeps the thing off on its own. This replaced the old rule that a fox took a hen half the nights at 4 wear.
- **The long dark:** winter nights take half again (`SEASON_MULT`), autumn's 15% more, from every night loss and strike and from the dark's own drain.
- Dread and All Hallows still double or halve the losses, as before. The crow bell (see Homestead projects) takes another quarter off and keeps the Hollow away.
- **Treks** (see Groves and treks) hold the nights back: the night after a trek takes half and the shadow falls back a step; 12 days without one and the wood comes closer, so nights take a quarter more and the shadow creeps every night. Walking Agnes to the grove puts the Hollow to sleep for good.

## Daily happenings

One surprise a day (`scripts/daily_happenings.gd`). From day 2, each morning picks a happening by the day, never the same one two days running, and the morning message announces it. Most leave something in the yard: walk up to it and press Space. Leaving the house by day reminds you while one waits. A happening left alone is gone the next morning.

- **Pedlar** (by the farm stand, until 18:00): sells one odd thing for the day: a crow charm (25 coins), three pumpkin seeds (18), a sudoku book (6), three crow feathers (12), or five turnip seeds (8).
- **A glint in the grass** (a random open grass tile): a purse of 10 to 25 coins, three crow feathers tied with red thread, a sealed seed tin (4 turnip and 2 corn seeds), or a warm tin soldier (−5 sanity, +15 coins).
- **A fallen branch** across a path: clearing it gives 3 wood, 1 hardwood and Forestry XP.
- **The crows' gifts** under the great tree: 5 to 15 coins and a crow feather.
- **A mushroom ring** at the edge of the wood: two times in three, +20 food and +5 sanity; otherwise −10 sanity and a crow feather.
- **Fish frenzy:** the day's catch chance is 25% higher (still capped at 90%).
- **A neighbour** stops by in the morning with a gift (eggs, turnip hash, kindling or a few coins) and a line about the farm.
- **The walkers' visits** are not happenings: on days nobody waits at the gate, one of the walkers may come by the farm as well as the day's happening (see Folk). The morning message names them after the happening. Their spot keeps clear of the happening's tile and the pedlar's.
- **Storm oak** (spring only): lightning split an oak at the edge of the wood. With a hatchet, it gives 1 storm oak (for the crow bell's frame), 2 wood and Forestry XP.
- **Wild flax** (summer only): blue flax in flower at the edge of the wood. It gives 3 wild flax (for the crow bell's rope) and Bushcrafting XP.
- Rarer: the mushroom ring has half the weight of the others. The pedlar and the glint are the most common, and in their seasons the storm oak and the flax are as common.
- The pedlar, branch, glints and mushrooms are drawn in code for now, at the farmer's scale with dark outlines; they are candidates for SpriteCook sprites.

## Homestead projects and decor

Long-term goals you can see on the farm (`scripts/farm_projects.gd`).

- **Homestead progress:** a ladder of 14 steps, shown on the Homestead tab of the Buildings section with the count done and the **next step** and how to do it: board up the house, open the second plot, build the coop, patch the house, the smokehouse, the firewood store, the furnace, light the yard (a lamp post), open the third plot, the barn, the Hollow Lantern, four flower beds, restore the house, and the crow bell. The ladder is paced over the first year by the levels each step needs and by the seasons. In the balance sim an engaged player finishes them on days 1, 6, 6, 11, 18, 19, 32, 61, 63, 78, 109, 156, 244 and 396 (October 2026): the house and first buildings in the first autumn, the lamp and third plot as winter starts, the lantern and barn in midwinter, the flower beds in spring, the restored house in summer (it can only be done then), and the bell on the second All Hallows. Skills reach level 10 between day 86 (Farming) and the second autumn; Smithing climbs about a level a week once the furnace stands. Steps can be done in any order; the next step is the first one not done. Each step done pays 20 coins and names the next. Steps already done in an older save are recorded without paying.
- **Decor**, placed like the coop (Buildings section, Decor; face open grass, Space places, B cancels):
  - **Lamp post** (3 wood, 1 iron bar, Smithing 7; up to 8): lights a ring 3 tiles across after dusk. Standing in its light, the dark doesn't drain sanity.
  - **Flower bed** (1 wood, 2 turnip seeds, Farming 2; up to 6; planted in spring or summer only): each gives +1 sanity every morning, except in winter, when they're bare.
  - **Gravel path** (1 stone a tile): turns grass into path. Placing carries on tile after tile until the stone runs out or B is pressed.
  - **Crow bell** (the bell metal, frame and rope, 20 crow feathers, 150 coins, Carpentry 6; one): a tall post with an iron bell. It is a year's work, made one part a season and hung only on **All Hallows** (October 31). The Hollow comes to it that night, one last time. While it stands, the field shadow stops a step short of the house, so the Hollow no longer comes, and every night loss is a quarter less.
  - **Its parts** (Buildings section, Crow bell tab, shown until the bell is hung; `BELL_PARTS` in `farm_projects.gd`): **bell metal** (4 iron bars, 2 copper bars, 10 crow feathers, Smithing 6, the furnace; only in winter, when it can cool in the frost), **bell frame** (1 storm oak, 6 hardwood, Carpentry 6) and **bell rope** (9 wild flax, 2 resin, Bushcrafting 5), with **the old clapper** below them, given by the vicar on a chapel trek (see Groves and treks). Storm oak and wild flax come from daily happenings in spring and summer. A game starts on October 1st, so the bell can't be hung before the second All Hallows, day 396. The balance sim hangs it on day 396 whether you face the nights or not.
- Lamps, flower beds and the bell block movement; paths don't. Face one and press Space to see what it does; press again within a few seconds to take it down and get its materials back.
- Decor is drawn in code for now, at the farmer's scale with dark outlines.
- **More decor** (October 2026, the economy pass; Buildings, Decor): the **wattle fence** (2 sticks and 1 wood a tile, up to 300; it keeps placing tile after tile like the path, and joins the fences beside it), the **spray sprinkler** (15 copper bars, 3 iron bars, Smithing 8, up to 6: waters the 24 crops in the five by five around it, the copper sprinkler tier), the **garden bench** (6 hardwood, 1 iron bar, Carpentry 4), the **birdbath** (12 stone, 3 copper bars) and the **weathervane** (8 copper bars, 2 iron bars, 60 coins, Smithing 5). Only the sprinkler does anything; the rest are for the look of the farm.

### The estate: extensions, furnishing and the land deed

The long goals once the homestead stands (`scripts/estate_system.gd`), each shown with its cost and what it needs, so there is always a next thing to save for. Built from the Buildings section (**Extensions** and **Furnishing** tabs) and the Desk (**Tax** tab), and saved (`estate`, from save version 11).

- **House extensions** (each adds 15% to the property value until the deed is bought), drawn in code on the house:
  - **Cellar room** (house Patched and the root cellar built; 700 coins, 60 stone, 20 hardwood, 20 copper bars, Carpentry 5): the root cellar holds **80** crops instead of 30 and keeps **every** crop, not only the ones that store, so crops can wait for the stand to want them again. Slanted cellar doors by the west wall.
  - **Covered porch** (house Patched; 1,200 coins, 60 wood, 40 hardwood, 40 copper bars, Carpentry 6): the farm stand takes **a quarter more** at full price each day, and **+2 sanity** every morning. A copper roof on posts along the front.
  - **Second storey** (house Restored, after the porch; 3,000 coins, 100 wood, 80 hardwood, 60 stone, 60 copper bars, 20 iron bars, 60 crow feathers, Carpentry 8): **+6 sanity** from each night's sleep, and the night takes **a tenth less** (`STOREY_NIGHT_MULT`, beside the bell's). A gabled dormer with two lit windows on the roof.
- **Furniture** (Furnishing tab; bought once each, drawn in its room, **+1 sanity every morning** each): oak dresser (150 coins, 12 hardwood, 2 copper bars), feather bed (250, 6 hardwood, 40 feathers; from Boarded), armchair (200, 8 hardwood, 20 feathers), long-case clock (350, 10 hardwood, 8 copper, 2 iron), a painting of the farm (400; from Patched) and a bookshelf for the study (300, 16 hardwood; from Restored).
- **Paint and wallpaper:** the outside paint (Restored; 200 coins and 2 copper bars a coat: weathered, whitewash, barn red, sage, slate blue, ochre), a tint on the house; and the wallpaper (Patched; 150 coins and 2 fiber: bare, rose sprig, green damask, ochre stripe, blue toile), over every wall face inside. Changing either again costs again.
- **The land deed** (Desk, Tax tab): the morning after the house is patched, a letter from the town clerk explains that the farm is held from the town on the quarter's tax, that the town took Agnes Rook's bell in lieu when she fell behind in her last year, and that the council will sell the deed outright for **12,000 coins**, paid at the desk **500 at a time** (not while tax is owed). Once paid, **no tax bill comes again**, and a last letter says what became of her bell. It is the big late goal and the place spare coins always have to go: open from the first weeks, finished in the second year. At the restored farm's tax of about 3,000 to 3,800 a year it pays for itself in about three and a half years.

## The farm's past

The mystery comes out in torn pages from **Agnes Rook's** journal (`scripts/mystery.gd`). Agnes and her husband Elias farmed here before you. The crows fed a hollow under the great tree; Elias walked into it; Agnes kept it under by ringing an iron bell every night, until the town made her take the bell down, and then she went after him. Her last page asks whoever comes next to hang the bell again, which is the crow bell project.

- **Ten pages**, each found through something the player already does, with a line saying where: (1) day 3, through the mail slot; (2) after the first knocking, answered or not; (3) facing the figure in the field; (4) holding 3 crow feathers or a crow charm; (5) the first sale at the farm stand; (6) patching the house; (7) the crows, at night or their gifts by day; (8) the first visit to the cave; (9) the first time the Hollow comes; (10) restoring the house.
- Pages are found one at a time (checked every half second), each with a chime and a message, and go in the diary under **Agnes Rook's pages (n of 10)**, in page order, with "Missing" for the gaps. New ones are marked like any diary page.
- **Epilogue:** hanging the crow bell adds a page in your own hand: the bell rings, something under the great tree answers, and the field is only a field. Walking Agnes to the grove adds the last, "The Hollow sleeps" (`GROVE_PAGE`), longer with all five pages from the wood.
- **The second year** adds a diary section of its own (The second year): the town's letter in the clerk's hand and a page in your own for each beat (the eleventh row, his knock, the mill, Davy). The ending pages go in the Afterword (see Endings).
- **The timeline:** Agnes went into the wood about thirty years ago (the postman has carried her letter every autumn of his thirty years on the round), so the act's text says thirty years throughout. Before the Rooks came the Askews, Lindqvists, Harrows and Moores, over sixty years (page p5); after Agnes the farm stood empty until you.
- Neighbours drop hints too: Old Maren remembers Agnes keeping hens, and the postman says the crows haven't liked the farm since the Rooks.
- Older saves file the pages they've already earned quietly when loaded; the ones tied to a night or the crows come the next time it happens.

## Endings

Three endings (`StoryAct`), each decided by what the player did, each played as a short **ending sequence** over the farm, after which the game goes on. The endings reached are saved (`endings`, id -> the day, and the `endings` stat) for achievements.

| Ending | Id | How |
|---|---|---|
| The Hollow Sleeps | `bell` | The crow bell hung and the woman in grey walked to the grove (the old ending, coloured by the meeting and Davy). |
| Two Came Home | `elias` | The grove walked **by night**, with the meeting won (Maren's and the vicar's last scenes), Davy's and the postman's last scenes seen, and all five pages from the wood (`_elias_ready`). |
| The Line Under the Rooks | `hollow` | The Hollow left at the door 3 times (`HOLLOW_TAKES`) from day 240, before the bell is hung (`_on_hollow`, from `NightSystem._resolve`). |

- **The Hollow Sleeps:** the grove as before (Agnes takes up the path behind Elias; the field shadow is gone for good). The town rings with you if the meeting was won ("thirty-one hands went up the other way"), or you ring alone; Davy, if he went in, comes home from the grove thin and quiet and doesn't whistle now. Something in the wood rings back, two notes, lower and late.
- **Two Came Home:** at the grove you read the letter in your own hand (the postman's autumn letter) and step onto the ring behind Elias, and he stops. The town is ringing the bell at the farm all night in turns, Maren first, so the ring has no need of a keeper: at first light you walk out, and Agnes and Elias walk out behind you (with Davy and Pip, if Davy went in). The grove's arrival, the grove page ("The ring") and the Afterword (a letter to Mrs Agnes Rook, care of the chapel, about her hens) are its own, and Agnes's "Keep them. Someone will need to follow." isn't said. The Hollow sleeps as in the bell's ending, and the orchard gives 3 apple saplings.
- **The Line Under the Rooks:** for a player who leaves the nights to the Hollow. One night you go out to the field like the four families; the postman finds you at dawn at the field's edge; the vicar writes your name on the line he left under the Rooks. It is a real ending, not an eviction: the save stays, the Hollow has had what it came for (the shadow goes back to the field's edge and the sanity limit it took is given back), and the bell can still be hung on All Hallows, so the bell's (or Elias's) ending after it is the way back. It happens once.
- **The sequence** (`scripts/ending_screen.gd`, `EndingScreen`, a CanvasLayer): the farm darkens to 78%, the ending's title fades in, then its lines one at a time (Space, Enter, A or a click for the next), then the credits roll up (Space hurries them), then the dark lifts: "Your diary has an Afterword. The farm goes on." The day is held while it plays (`StoryAct.playing()` in main's pause check). An ending reached in the night (the Hollow's) or on a trek (the grove) waits in `pending` (saved) until nothing covers the farm.
- **The Afterword** gains a page in your own hand for each ending reached, in order (`_afterword`).
- Check it with `tools/capture.gd`: `ending=bell|elias|hollow` with `epage=N` (-1 the title; past the last line, the credits).
- **Sim** (`tools/balance_sim.gd`, 420 days, `treks=3`, engaged / ignore / earlybed; the summary prints a "second year" line, and the milestones `act: <beat>` and `ENDING: <id>`). The sim now models Agnes's pages in the hollow trees (half the time while one waits on the route), engaged walks the grove by night once Elias's homecoming is ready, and engaged finds Davy at 21:00 while the others are in. Engaged: letter 240, shown 244, orchard 273, knock 290, the meeting won on the Harvest Moon (358), Davy stopped on 370, **Two Came Home on day 399**. Ignore: the knock left at the door every 5 nights, **The Line Under the Rooks on day 290**, the meeting won at the mill on 316, Davy lost on 371, then **The Hollow Sleeps on day 407**. Earlybed: **the Hollow's ending on day 283**, the meeting won on 329, Davy lost, **The Hollow Sleeps on day 399**. Coins stay between about 285 and 1,800 from day 240 (420 ends 341 / 873 / 1,783), and sanity is no lower than 26 / 16 / 9, as before the act.

## Groves and treks

**The walk to the wood's edge** (`edge` in `ROUTES`, October 2026): the first trek, in the first week, so the game's signature horror shows in its first hour. The morning of day 3 says Old Maren will come; from day 4 (`EDGE_DAY`) she waits at the gap in the trees **every** day until 15:00, until she has been walked (`edge_done`, saved from save version 12). She asks only for the wood's edge, by daylight: two short clearings (layouts 7 and 8 in `CLEARINGS`), about a minute's walk.
- **Gates:** a lantern (a Tin Lantern, Bushcrafting 2: chapter 2 asks for it, and her refusal says where it is built) and no Bushcrafting. If you have fewer than 2 lamp oil she gives you enough (`EDGE_OIL`), so nobody is stuck without coins; the oil burns as on any trek, so the second flask is usually lit on the way. Asking her says what her nerve is and how to keep it (your light, the trail, a word).
- **The walk:** the first clearing always has a **fallen tree** (cut through with the crude hatchet from the first day, or take the way round). The second has the stile at the top, drawn in code (`_draw_stile`), and **a glimpse of the tall one**: 6 seconds in, its red eyes show high in the trees and stay put for 7 seconds, then go (`_glimpse`); lifting the lantern at it (Space within 3 tiles) sends it off at no cost. It never moves or touches her. The wood is lighter there (`EDGE_GLOOM` 0.45). Her two words say who she is and point at the mill; at the stile she ends on the hook: the town met at the mill the night they voted Agnes Rook's bell down, she was there, and she'll want walking all the way in a week or so.
- **After:** 10 coins, 2 fiber and 25 Bushcrafting XP (`_edge_pay`), the diary's note on the wood and chapter 3, and half an hour home. It does **not** count toward the dread or the walkers' standing, but it pushes the field shadow back a step and halves that night like any trek, and that night the first Hollow sighting comes (see Nights). Until she has been walked the mill route stays shut.
- Check it with `tools/capture.gd`: `walker wedge` (day 4, below her), `trek=0 troute=edge` (the fallen tree) and `trek=1 troute=edge tall` (the eyes). The trailer (`tools/trailer.ps1`) has an `edge` shot and a `sighting` shot, and its walker shot is now Maren on day 4.

**Built (steps 1 to 4, `scripts/trek_system.gd`):** the mill path first, then the other routes (step 3, below). From day 14 (`FROM_DAY`; day 62, the first winter, until October 2026), once Maren has been walked to the wood's edge, on about one day in three (`COME_EVERY`), **Old Maren** waits at the gap in the trees on the farm's north edge, above the house, until 15:00; the morning message says so. Space beside her shows the route and your supplies, and Space again sets out. She needs your lantern and 1 lamp oil.
- The clearings are laid into the cave's grid while trekking (`in_cave` is set), so walking, the camera and the minimap work as underground. Each is a long, switchbacking trail through dense wood given as points (`CLEARINGS`), with room carved around it, the way on at the top and the way back (giving up) at the bottom. The last ends at the mill, drawn in code with its wheel turning. The wood is dim by day (`GLOOM`), the lantern glows a little stronger there (`TREK_LANTERN_BOOST`), and **the clock runs slow** (`TIME_SCALE` 0.44, about 45 real seconds a game hour), so the walk of about two minutes takes about three hours.
- **Lamp oil** (catalog, Supplies, 8 coins): a flask burns 75 seconds in the wood (`FLASK_SECONDS`), and you refill as it gutters. The mill takes about two. Without oil the lantern goes out, and the dark is where her nerve goes.
- **Trail ration** (Cooking, at the fire: 1 egg, 1 turnip, 1 wood; Cooking 2).
- **Maren** walks slower than you (`WALKER_SPEED`, 2.6 tiles a second against your 3.75), so you keep stopping for her. **Her nerve** shows beside the needs, starting at 70. Each second: −0.4 even in your lantern's light (the ring plus a tile), −2 out of it, −1.5 more while either of you is off the trail (cutting across the grass between bends, or the way round an event; she begs you back the first time in each clearing), −3 more when you're over 6 tiles ahead, −1 more while your sanity is under 40, −5 more while the crows mob her. Under 25 she **freezes** and won't take another step until a ration brings her back over 35. Space beside her gives a ration (+35) when her nerve is under 70 or she is frozen, or else a word (+10, once a clearing, with a line of her story). **At 0 she runs**: the trek is over, the oil and rations are spent, and you lose 10 sanity. The wood also takes 0.1 sanity a second, twice that unlit.
- **The fork** (step 2): the first clearing ends at an old fingerpost with two ways on. The **marked trail** (`MARKED_ROUTE`) is two more clearings before the mill, with pale blazes on the trunks and gentler events; the **dark trail** (`DARK_ROUTE`) is one, darker (`GLOOM_DARK`), with the wood's sanity drain half again (`DARK_SANITY`), the tall one faster and sooner, harder events, and better pay (+30 Bushcrafting XP, +1 feather, richer hollow trees). Which arm is marked changes with the day. The sign reads (its carvings show, and Space says which way is which) with **Bushcrafting 3** (`SIGN_LEVEL`) or, later, the Waymarks trail work: the hook is `TrekSystem._can_read_sign()`. Event severity scales with `_harsh()`: 0.7 on the marked trail, 1.4 on the dark, 1 in the first clearing (crows: one wave fewer or more).
- **Events**, one in each clearing before the mill, picked by the day with no repeats (`_plan(day)`, which the balance sim reads too): the first clearing and the marked trail draw from tree, crows, flood, cairn and hollow; the dark trail from crows, flood, lights, fog and hollow. Summer skips the flood and the fog (`SEASON_SKIPS`). Coming within 4 tiles of an event says what it is.
  - A **fallen tree** across a narrow stretch: with a hatchet, Space cuts through for 2 wood and Forestry XP; or take the faint way round through the trees (laid only for this event), off the trail, where her nerve falls faster.
  - **The crows** find her at their spot and then mob her in waves: Space beside her drives them off (−3 sanity, +1 feather), and they come back 8 seconds later until driven off three times.
  - A **flooded hollow** across the trail: Space at the water with a **rope** ties it across (−1 rope, +10 Bushcrafting XP, both cross dry); without one, Space twice wades it with her on your back: −10 warmth (×`_harsh`, and ×3.5 in winter, so 24 to 49 then) and −10 nerve (×`_harsh`). The mill footbridge will make the hollows dry (planks over a dry bed): the hook is `TrekSystem._hollows_dry()`. **Rope** is Craft, Other: 2 fiber, Bushcrafting 3.
  - **Lights off the path** (dark trail): pale lights wait in the trees beside the trail, wearing on her nerve while she is near them. Space near them follows: half the time they lead you to the way on; otherwise you are lost an hour (the clock moves on), −20 nerve, −5 sanity, 30 seconds of oil, and back at the start of the clearing.
  - A **cairn of crow skulls** beside the trail: Space leaves 5 coins (or a ration if you have no coins): +6 sanity, +15 nerve. Walk on past and, once she is 6 tiles beyond it, she takes it badly (−10 nerve, ×`_harsh`).
  - A **fog bank** (dark trail) blocks the trail: a Brass Lantern or better burns a way through; otherwise it thins 18 seconds (×`_harsh`, so 25) after you reach it, while the oil burns and her nerve wears.
  - A **hollow tree** beside the trail: Space reaches in, once: a feather bundle (+3, +5 on the dark trail), old coins (6 to 12, doubled on the dark trail), or one time in five a nest of small bones (−4 sanity, −8 nerve). While one of Agnes's **pages from the wood** waits on this route, it holds that instead half the time (`HOLLOW_PAGE`; see The diary below).
  - Blocking events (tree, flood, fog) close every open tile around the narrow stretch, so nothing slips past at the edges.
- **The tall one** walks the trees from the second clearing on, 8 seconds in: a thin dark shape twice your height with red eyes, only its eyes showing out of your light. It comes straight through the trees for Maren (1.6 tiles a second in your light, 2.4 out of it). Space within 3 tiles drives it off for 9 seconds (−3 sanity). If it reaches her, her nerve drops 30.
- **Dread:** the wood learns you. Each trek you finish (`treks_done`, saved) raises its dread by one, up to 6 (`MAX_DREAD`). Per point: her nerve wears 0.08 a second faster even in your light, the tall one walks 0.15 tiles a second faster, shows a second sooner and stays back half a second less after being driven off, and every two points the crows need driving off once more. From dread 2 the tall one walks the first clearing too. Setting out says the dread. The pay rises with it: 15 more Bushcrafting XP a point, and a feather more every two.
- **Arriving:** 4 turnip seeds, a crow feather (more with dread), a fiber for each clearing walked and 60 Bushcrafting XP (more with dread). You are back at the north edge an hour later. Bed or a collapse while in the wood ends the trek.
- **Tested with a bot walking at your speed** (careful play, lowest nerve by dread: 0 → 66, 2 → 53, 4 → 49, 6 → 41, when it also needs both rations and both flasks): played carefully (waiting for her, words, a ration under 50, turning on the crows and the tall one at once), it arrives in about 95 seconds with her nerve no lower than 66, one ration used and both flasks burned. With one flask the last clearing is dark and costs her about 37 more. Played carelessly (just walking), she breaks in the second clearing when the tall one reaches her twice. A person reacts slower than the bot, so expect closer calls.
- **Step 3: the other routes and the seasons.** Every route (`TrekSystem.ROUTES`) has its walker, its clearings by each trail, its oil, its Bushcrafting level, its talk and its pay. On a walker day every walker whose route is open waits at their own spot along the gap (Maren in the middle, the Tull boy to her left, the vicar to her right, the woman further left, the postman further right), and the morning message names them all: **Space beside one picks that route** (a first Space says where they want walking, the clearings by each trail and your supplies; Space again sets out). A walker whose route needs more Bushcrafting says so.
  - **The drowned orchard** (from spring, day 152, Bushcrafting 4, 2 lamp oil): **the Tull boy** (Davy), looking for his dog. 5 clearings by the marked trail, 4 by the dark. Pays 120 XP, a feather more, 2 hardwood (old applewood), and in summer 2 wild flax.
  - **The chapel on the hill** (from summer, day 244, Bushcrafting 5, 2 lamp oil): **the vicar**, who cut the bell down and kept its clapper. 6 or 5 clearings. Pays 200 XP, two feathers more, 2 lamp oil from the vestry, and in spring a storm oak from the split tree in the churchyard. The first time (until the bell is hung), he also gives **the old bell's clapper** (`bell_clapper`), the crow bell's fourth part: the bell can't be hung without it, so one chapel trek is needed before the second All Hallows. The Crow bell tab lists it beside the three parts ("With the vicar", then "Given"). A save from before it (version 5) that had already made all three parts gets it, so a farm ready for All Hallows stays ready.
  - **The postman's round** (`post`, from the second autumn, day 336, Bushcrafting 5, 2 lamp oil, by day only): **the postman**, with a letter for the chapel. 5 clearings by the marked trail, 4 by the dark, his own mix of the layouts, ending at the chapel on the hill (drawn as for the vicar; the dogs walk it too). Pays 160 XP, a feather more and a **crow charm** ("The crows let me be."). His talk: he has carried the lane's post thirty years; the crows follow him as far as the chapel; it was he who brought the torn page through your mail slot on your third morning, unstamped, in her hand; and every autumn since she went he has carried a letter to "Mrs Agnes Rook, care of the chapel", in a hand that isn't hers. He slides it under the locked vestry door, and it is back in his sack by morning. Once Agnes is walked to the grove, the sack is empty (`arrive_after_grove`): "Somebody's had it at last."
  - **The Hollow's grove** (once the crow bell is hung, so from day 397, the day after the second All Hallows; once only, `grove_done`, saved): **a woman in a grey shawl**, who gives no name. 7 or 6 clearings. Pays 300 XP and five feathers more, and ends with her walking into the grove: she is Agnes Rook. Walked by night with everything Elias's homecoming needs, it gives that ending instead (see Endings). With all five of her pages from the wood, you hold them out and she gives them back ("Keep them. Someone will need to follow."). **The Hollow sleeps** from then on: the field shadow is gone for good (`shadow_steps` stays 0) and the Hollow never comes again, every night takes a quarter less (`GROVE_NIGHT`, on top of the bell), the crows' gifts come three times as often (`CROW_GIFTS_AFTER_GROVE`), the wood never comes closer, and a last diary page, "The Hollow sleeps", closes the story (a longer one, about Elias walking the ring, with all five pages). Walkers keep coming after it.
  - The new clearings: two more layouts (a marked switchback and a dark one) and the old ones mirrored (layout `FLIP + i`), so the long routes don't repeat a clearing as it was. The end clearing is the mill's, with the route's destination drawn over the top (the drowned orchard's water and bare apple trees, the chapel with its empty bell-cote, the ring of black trunks at the grove). A flood-fill check of every layout and blocking event passes (no leaks past a block, a way round a fallen tree, the exit open after).
  - **Walker talk** on a trek (a word, Space beside them) shows in the dialogue box with their portrait (see Folk), worried when their nerve is under 40; the woman in grey's portrait shows only her eyes. Everything else on a trek is still a message.
- **Night treks** (chapel and grove): their walkers wait until 22:00. Between 15:00 and 18:00 they say it's too late for daylight; **from 18:00** you can set out by night with a flask more oil (`NIGHT_OIL`): **twice the pay** (XP, feathers, fiber and gifts, `NIGHT_PAY`), the wood's sanity drain doubled (`NIGHT_SANITY`), and the tall one 0.3 tiles a second faster. The chapel's window is lit at night.
  - **Feral dogs** (`dogs`, an event on the orchard, chapel and grove routes, every trail): 2 dogs on the trail at the event, 3 on the dark trail, a dog more in winter. They are cave foes (`FOES["dog"]` in `main.gd`: 5 HP, 2 damage, quick to chase, 16 Combat XP), fought with the sword as in the cave. The walker's nerve falls 4 a second faster while a dog is within 4 tiles of them. Kill them all and the walker steadies; or hurry past, as they don't follow far. A collapse ends the trek.
  - **Seasons** (`_plan(day, route)`): summer still skips the flood and the fog; each season counts two events twice in the draw (`SEASON_MORE`: spring floods and fallen trees, summer crows and hollow trees, autumn fog and lights, winter dogs and cairns). The wood is lighter in summer and darker in autumn and winter (`SEASON_GLOOM`), and in winter the cold takes 0.06 warmth a second (`WINTER_COLD`), on top of the deeper wading. When a long route runs out of fresh events, they can repeat.
  - **Hooks for the trail works**: `_walker_day()` (a lamp at the gate, `gate_lamp`: walkers two days in three instead of one), `_orchard_shorter()` (`boardwalk`: `_steps` drops the clearing before the orchard), `_rests_halfway()` (`waystation`: on routes of 5 clearings or more, the halfway clearing gives a half-hour rest, nerve and warmth full, no oil), `_night_sanity()` (`chapel_steps`: the chapel by night without the doubled drain). `_hollows_dry()` (`footbridge`) is now the mill path only.
  - **Sim** (400 days, `treks=3`, by day only; the sim now walks every route from the real plan, steps and gifts): engaged / ignore / earlybed walked 40 / 43 / 40 mill, 25 / 21 / 20 orchard and 12 / 9 / 14 chapel treks, about half by the dark trail, with 21 to 24 dog fights and 32 to 38 floods; the ignore run hung the bell on day 396 and walked the grove on day 399. Oil cost 800 to 880 coins (the vicar's oil pays some back). The year ends with 4,124 / 1,574 / 1,288 coins and sanity no lower than 61 / 39 / 46. About 95 trek days were skipped, nearly all for want of spare crops for the rations.
- **Treks and the nights** (`TrekSystem._on_arrived`, `_night_mult`, `_wood_close`): treks are how the farm keeps the wood back.
  - **Coming home** from any trek pushes the field shadow back a step (`TREK_PUSH`), and that night's visitor takes half (`WALKED_NIGHT`). The arrival message says so.
  - **The wood comes closer:** after 12 days without a trek (`WOOD_DAYS`, counted from the first winter, day 62, `WOOD_FROM`, though the mill opens on day 14, so the early weeks aren't pushed; `last_day`, saved as `trek_last_day` from save version 6, which an older save starts at the day it was saved), the morning message says the wood has crept up to the north fence with crows along it. Until someone is walked, every night takes a quarter more (`WOOD_CLOSE_NIGHT`) and pushes the shadow a step nearer whatever the visitor (never past where the bell stops it). The next trek draws it back.
  - Sim (420 days, `treks=3`, engaged / ignore / earlybed): all three walk the grove (day 399 / 399 / 420), sanity no lower than 69 / 43 / 45. With no treks (ignore, `treks=0`) the Hollow came 93 times against 25 with them, sanity fell to 37, and the bell was never hung (no chapel trek, no clapper).
- **Walker standing** (`TrekSystem.STANDING`, `_standing_gifts`): each route counts its walks (`walked`, saved as `trek_walked` from save version 6; older saves start from none). Once a walker knows you, every walk to their route gives something only that route gives. **Since save version 14 standing is friendship** (see Folk): a walker knows you at STANDING's `at` in **hearts**, and the first three walks give a heart each, so `at` walks still get there, but a word, gifts and their requests get there too. Asking a walker says how many hearts it takes; the Trail works tab lists the walkers under **Walkers** with their walks, hearts and what they give.
  - **Old Maren** (3 walks): her sister mills for you, 2 **flour** a walk (doubled by night). **Farmhouse bread** (Cooking 3, at the fire: 2 flour, 1 egg, 1 wood; difficulty 3) is a good food, and on a trek it is the fallback ration once the trail rations are gone: +50 nerve (`BREAD_NERVE`) against a ration's 35.
  - **Davy, the Tull boy** (3 walks): his mother sends an **apple sapling** from the drowned orchard each walk, or 3 apples once you hold saplings for every tree the farm can take. An **apple tree** is placed from Decor (1 sapling, Farming 4, up to 6) and drops an **apple** (difficulty 2, Farming 4) each autumn morning per tree. Drawn in code: a round crown, red apples in autumn, bare in winter.
  - **The postman** (2 walks): a **parcel addressed to the Rooks** each walk, from the unclaimed post still in his sack, in turn (`PARCELS`): 4 corn seeds, 2 pumpkin seeds, a bandage, a rope.
  - Sim (420 days, `treks=3`, engaged / ignore / earlybed; the sim walks the postman every other trek at most once he waits, so the vicar is still walked): 2 / 5 / 3 postman walks from day 336, all three walk the grove (day 406 / 401 / 406), sanity no lower than 72 / 43 / 55, and day 420 ends with 4,493 / 1,428 / 2,659 coins (the ignore run's fall from 1,804 is chapel trade and vestry oil the postman's walks don't bring).
  - **The vicar** (2 walks): his **blessing** each walk gives +10 sanity and up to 5 lost sanity limit back (`BLESS_LIMIT`), like a cleansing that the wood pays for.
  - Sim (420 days, `treks=3`, engaged / ignore / earlybed): the year's walks give 92 / 70 / 80 flour, and sanity is no lower than 72 / 43 / 47. The sim doesn't bake bread or plant apple trees. (The sim then missed the grove for want of crops for its rations; see Trade below for how it now bakes them ahead.)
- **Trade** (`TrekSystem.TRADE`, `_trade`): each destination buys some of what you carry, at a quarter more than the farm stand's full price (`TRADE_MULT` 1.25; it ignores the stand's demand curve), up to 8 items a walk (`TRADE_MAX`; 14 with the mill handcart), best-paying first, always keeping 4 of each kind back (`TRADE_KEEP`, since eggs go into rations). It happens on arriving and counts as selling. Asking a walker says what their destination buys. Turnips aren't bought anywhere: they are the rations' staple.
  - **The mill** (Maren's sister): corn, for the mill. Corn doesn't keep in the cellar, so the mill is where a big corn harvest goes.
  - **The drowned orchard** (the Tull family): eggs and milk, since the dogs took their hens.
  - **The chapel** (the vicar): pumpkins and fish, for the soup he gives out. Walking the postman there sells nothing: the chapel is locked and the vicar is at the vicarage.
  - Sim (420 days, `treks=3`, engaged / ignore / earlybed): day 420 ends with 4,463 / 1,804 / 2,685 coins and sanity no lower than 72 / 43 / 55; all three walk the grove (day 406 / 407 / 401). The hens and goats leave few crops spare on any one day, so the grove's 4 rations were never there at once; the sim now bakes them ahead, one a day once the woman waits (`grove_rations`), as a player would, and logs why the grove was put off (`grove short ...`: 2 to 4 days short of crops). An earlier run with the mill also buying turnips took crops the rations needed, which is why turnips were dropped.
- **Step 4: the trail works** (`TrekSystem.WORKS`, the table below). A **Trail works** tab in the Buildings section, from the first winter, lists each work with its cost and what it does; Build pays for it (`_build_work`, `_work_why`), once, from the day its route opens (`"route"`). The built set is `works`, saved as `trek_works` (save version 4; older saves have none). The hooks above read it: Waymarks through `_can_read_sign()`, the footbridge `_hollows_dry()`, the gate lamp `_walker_day()`, the boardwalk `_orchard_shorter()`, the waystation `_rests_halfway()` and the chapel steps `_night_sanity()`. The works are paid in the Buildings section rather than at a signboard by the gate, and nothing is drawn for them on the farm or in the wood yet. The balance sim builds them through the same functions, in order, so the boardwalk and footbridge change its routes and floods. Sim (400 days, `treks=3`, engaged / ignore / earlybed): all six works are built by day 245 to 252 (waymarks 62, footbridge 73, gate lamp 74, boardwalk 160 to 162, waystation 244), 4,550 coins in all; floods met fall to 16 / 7 / 10 (from 32 to 38) with the footbridge; the year ends with 3,435 / 1,395 / 2,148 coins and sanity no lower than 60 / 45 / 48. The sim keeps its own trek schedule, so the gate lamp and the waystation's rest don't show in it.
- Not yet: art for the built trail works, and SpriteCook art for the walkers (the postman too), the dogs, the logs and the destinations (all drawn in code at the farmer's scale). Storm oak and wild flax are now also trek gifts, but the yard happenings still give them too.
- Check it with `tools/capture.gd`: `walker` (with `wday=N` for a later day, `wbell` for the grove), `trek=N`, `troute=orchard|chapel|post|grove`, `tday=N`, `tnight`, `tevent=tree|crows|flood|lights|cairn|fog|hollow|dogs` (with `tsearch` to reach into the hollow tree), `tpages=N` (with `diary`), `tdark` (the dark trail), `tsign` (stand below the fingerpost), `tread` (the sign reads), `nooil`, `tall`. Shift+F4 in a debug build jumps to a walker morning.

The rest of this section is the plan. The woods past the farm are walked as **treks**: you guide someone from the lane through the Rookery Wood, one clearing at a time, with what you packed. Loosely inspired by escort treks in other games, but built from this game's own parts: the lantern, sanity, the crows, the seasons and Agnes Rook's story. Treks are where coins go (supplies and trail works), where Bushcrafting is trained, and where the story deepens between the homestead steps.

**Why people walk the wood:** since Agnes's bell came down, nobody from the lane crosses the Rookery Wood alone. They come to the farm, the last house before the trees, and ask you to walk them. A **walker** waits by the north gate on some mornings (a daily happening, from day 14, after Maren's walk to the wood's edge in the first week). Each walker has a reason, and their talk on the way tells the story: Old Maren visiting her sister at the mill, the postman with a letter for the chapel, the Tull boy looking for his dog, the vicar who took the first bell down. Late in the second autumn, a woman in a grey shawl asks to be walked to the Hollow's grove and gives no name.

**The routes**, through the north gate past the great tree:

| Route | Clearings | Opens | Supplies (typical) | Walker gives |
|---|---|---|---|---|
| The wood's edge (once) | 2 short | day 4 | a lantern (she brings the oil) | a few coins, the story's hook |
| The mill path | 3 | day 14 | 1 lamp oil, 1 trail ration | seeds, eggs, honey, a few feathers |
| The drowned orchard | 4 | spring (Bushcrafting 4) | 2 lamp oil, 2 rations, 1 rope | wild flax (summer), orchard saplings, pages |
| The chapel on the hill | 5 | first summer (Bushcrafting 5) | 2 lamp oil, 3 rations, 1 rope, 1 bandage | storm oak (spring), the old bell's clapper, pages |
| The postman's round (to the chapel) | 4 or 5 | second autumn (Bushcrafting 5) | 2 lamp oil, 3 rations | crow charms, the Rooks' old parcels |
| The Hollow's grove | 6 | second autumn, after the bell's three parts | 2 lamp oil (more at night), 4 rations, 2 rope, 2 bandages | the story's end |

Storm oak and wild flax, the crow bell's frame and rope, move here from the yard happenings once treks are built, so the year-long bell sends you into the woods.

**How a trek plays:**
- **Setting out:** talk to the walker at the gate and pick the route. A trek takes 3 to 6 hours and must start by 15:00. Starting after 18:00 is allowed on the chapel and grove routes: night treks pay double and cost far more sanity.
- **Clearings:** each is a small hand-made map (built like the cave), joined by a trail. Between clearings the path **forks**: a marked trail (one more clearing, gentler events) or a dark trail (shorter, harder events, better finds). The fork signs can be read with Bushcrafting.
- **The walker's nerve:** a bar shown while trekking, from 0 to 100. It drops in the dark, at bad events, while your own sanity is under 40, and if you get far ahead. It comes back with a trail ration, inside your lantern's light, and with a word (press Space beside them). At 0 the walker bolts home, the trek ends, and the supplies are spent.
- **Events**, one per clearing, picked by the day and season:
  - A fallen tree across the trail: chop through (wood) or lead them round (nerve).
  - A flooded hollow: a rope across, or wade (warmth, and in winter a lot of it).
  - Crows mobbing the walker: face them (feathers, sanity) or hurry them through (nerve).
  - Lights off the path: follow them (a shortcut, or lost an hour in the dark) or keep to the trail.
  - A cairn of crow skulls: leave a ration or a coin (sanity back, the walker steadies) or walk past.
  - A fog bank: only the Brass Lantern or better finds the way; otherwise wait it out.
  - Feral dogs (a fight, using the cave's combat) or something tall between the trees (stand still until it passes).
  - A hollow tree with something in it: a torn page, a feather bundle, or old coins.
- **Arriving:** the walker thanks you and pays in kind, not coins. You walk back alone by the short trail, quickly.
- **Sanity:** the deep wood drains sanity like the dark, faster on dark trails and at night. Treks are what makes sanity matter by day.

**Supplies (the coin sink):** packed before setting out and used up on the way.
- **Lamp oil** (catalog, 8 coins a flask): the lantern burns a flask every three clearings in the woods. Without oil it goes out, and the walker's nerve falls fast.
- **Trail ration** (cooked at the fire: 1 egg, 1 turnip, 1 wood; Cooking 2; a milk version later): the walker eats one when their nerve is low. Hens and goats are what make treks possible.
- **Rope** (Craft, Other: 2 fiber, Bushcrafting 3), **bandages** as now. Brush along the trail gives 1 fiber a clearing, so treks pay for their own rope and help the house and barn, which need fiber too.
- A typical trek costs 8 to 32 coins in oil and the crops, eggs and milk in the rations, and pays in materials, seeds, feathers, pages and Bushcrafting XP (60 to 200 a trek), not coins.

**Trail works (the big sink):** paid in the Buildings section (Trail works), each once, from when its route opens. They make the treks safer and are the farm's long-term coin goals beside the ladder.

| Work | From | Coins | Materials | Effect |
|---|---|---|---|---|
| Waymarks | day 14 | 150 | 10 wood | The marked trail's fork signs read without Bushcrafting |
| The mill footbridge | day 14 | 300 | 12 wood, 6 rope | Flooded hollows on the mill path are dry |
| A lamp at the gate | day 14 | 400 | 2 iron bars | Walkers come twice as often |
| The orchard boardwalk | spring | 700 | 20 wood, 8 rope | The orchard is one clearing shorter |
| The waystation hut | summer | 1200 | 30 wood, 10 hardwood | Rest halfway: nerve and warmth refill, no oil burned |
| The chapel steps | summer | 1800 | 30 stone, 4 iron bars | The chapel route opens at night without the double sanity |
| The mill handcart | day 14 | 600 | 30 hardwood, 10 iron bars | Each destination buys 6 more a walk (`_trade_max`) |
| Oil tins at the stiles | spring | 900 | 40 copper bars, 4 iron bars | A flask of oil lasts 110 seconds instead of 75 (`_flask_seconds`) |
| Lamps on the post road | second autumn | 1500 | 16 iron bars, 30 copper bars, 20 hardwood | Walkers set out with nerve 90 instead of 70 (`_nerve_start`) |

**Balance (sim, 400 days, 3 treks a week; before the October 2026 economy pass, see Money and the farm stand for the current numbers):** the sim walked 42 mill, 25 orchard and 19 chapel treks. Oil took about 1,200 coins and trail works 4,550. Coins peak at about 5,000 in early spring, then the summer works spend them; the year ends with 800 to 3,500, against 14,500 with no treks. Sanity's lowest is 64 to 70, from about 83. Treks give Bushcrafting XP and fiber, so the Hollow Lantern comes around day 90 and the restored house around day 190.

**Story:** each route ends somewhere that matters to the Rooks. The mill is where the town met to vote the first bell down. The orchard was Elias's. The chapel kept the old bell's clapper, which the crow bell can't ring without: the vicar gives it on a chapel trek, and the bell needs it beside its three parts. The Hollow's grove is where Elias walked in, and the nameless woman is Agnes. Her pages, now spread across treks as well as the farm, are read in the diary as before.

**Building it, in order:** (1) one route, the mill path, with three clearings, the walker and nerve, lamp oil and rations, two events; (2) the remaining events and forks; (3) the other routes and seasons; (4) trail works. All four are built. Each step is checked with `tools/balance_sim.gd`, which already models the supplies and trail works (`treks=N`).

## Folk

The walkers are the farm's neighbours, not only its escorts (`scripts/folk_system.gd`, November 2026). There are four of them: **Old Maren**, **Davy Tull**, **the vicar** and **the postman**. The woman in grey is not one: she gives no name, and the grove walk is her whole story.

- **Friendship:** 0 to 10 hearts a walker, 20 points a heart (`FolkSystem._points`, `_hearts`). Walks count from the walks saved since version 6 (`TrekSystem.walked`): the first three give a heart each (`WALK_POINTS`), later ones 4 points (`WALK_POINTS_AFTER`), and a walk by night 8 more. Maren's walk to the wood's edge gives her 8. On top of that: the day's first word with them, at the gate or on a visit, 1; a gift 10 if loved, 5 if liked, 2 for anything else edible, −8 if disliked (one a week each, `GIFT_DAYS`); a request done 20. The extra points are saved as `bonus`, kept so the total never falls under nothing or goes past 200, so later walks always count.
- **Standing is friendship** (see Groves and treks): a walker knows you at STANDING's `at` in hearts (3 for Maren and Davy, 2 for the vicar and the postman). Walking them still gets there in the same number of walks; being a good neighbour gets there sooner.
- **Gifts:** anything in the pack you can eat. Talk to someone on the farm, then press Space again: the **Folk** tab (Quests) opens on "Give Maren something", a line for each food you hold, with Give. One gift a week each. What they think of it shows from then on (Loved, Liked, Neutral, Disliked), and the walker's own entry lists what you've learned they love and like.

| Walker | Loves | Likes | Dislikes |
|---|---|---|---|
| Old Maren | rose hip tea, bramble jam, apple crumble | leek soup, blackberries, apples, garlic, baked potato, bread | pale carp, lamprey, ghost pipe, ghost pipe tincture |
| Davy Tull | strawberries, salmonberries, pumpkin pie, berry cobbler | apples, corn, huckleberries, blueberries, grilled fish, bluegill, apple crumble | kale, nettle soup, parsnips, ghost pipe tincture, fermented turnip |
| The vicar | pumpkin soup, sturgeon steak, chanterelles, fish stew | leeks, parsnips, trout, crappie, pea soup, bread, smoked fish | pale carp, lamprey, smoked lamprey, fermented turnip, ghost pipe |
| The postman | corn chowder, smoked lamprey, hearty stew | potatoes, garlic trout, yellowfoot, morels, roast roots, eggs, colcannon | bramble jam, rose hip tea, strawberries, ghost pipe |

- **Farm visits** (`_pick`, `_start_day`): on a day nobody waits at the gate (not a walker day, or before the mill path opens), one day in two (`VISIT_EVERY`) one walker comes by from 09:00 to 16:00: **Maren** sits by the farm stand (from day 5, once walked to the wood's edge), **the postman** waits by your door (from day 6), **Davy** skims stones at the pond (from day 20) and **the vicar** stands under the great tree (from day 40). They come before their routes open, so you know them before you walk them. A walker with a scene due is picked 7 times in 10 (`SCENE_PICK`). The morning message says who has come; they stand on the open tile nearest their place (`_spot`), drawn as on the treks. Space beside them plays a scene if one is due, or else hands over a request you carry, or else gives the day's line. Lines (`LINES`, about a dozen each) change with the season, their hearts and the story (walked, the bell hung, the grove walked); season and story lines come up twice as often.
- **Requests** (`REQUESTS`, three each): on the first word of a visit, half the time, a walker with nothing waiting asks for the next one their hearts allow (some only in a season). Bring it to them on the farm (a visit, or the gate): talking hands it over, or use the Folk tab's Hand over. They pay in coins and kind, and 20 points.
  - Maren: six eggs for the mill (30 coins, 2 flour), three garlic for the sill in autumn (25 coins, 2 feathers), two rose hip teas (40 coins, 2 bread).
  - Davy: three perch (25 coins), four salmonberries for Pip in summer (15 coins, an apple sapling), two rope for the sunk boat (3 hardwood, 20 coins).
  - The vicar: four pumpkins for the soup in autumn (45 coins), two lamp oil for the chapel lamp (10 sanity, 10 coins), a white sturgeon for the harvest supper (80 coins).
  - The postman: five potatoes for the stove (25 coins), six firewood in winter (35 coins), a smoked lamprey (60 coins, a crow charm).
- **Scenes** (`SCENES`): four each, at 2, 4, 6 and 8 hearts (`SCENE_HEARTS`), at least 10 days apart (`SCENE_GAP`), the last not before a day of its own. A scene plays in the dialogue box on a visit, page by page (Space or A), and holds the day while it is open. The Folk tab lists the ones heard, by title.
  - **Maren:** *Ruth's lamp* (she left a lamp in the mill window for Agnes the night after the vote; someone went by at dusk and didn't knock, as in page t2). *Agnes's hens* (her hens are the great-grandchildren of Agnes's; Agnes sang hymns at them; Elias cut his marks so the wood wouldn't forget the way; 4 eggs). *Thirty-one hands* (it was never the noise: when Agnes rang, something in the wood rang back, lower and a beat late, and that is what they voted against). *The minute book* (from day 150: Ruth wrote down every name and hand at the vote; a vote can be put again, and Maren will stand).
  - **Davy:** *Two notes* (Pip's two-note whistle is the old bell's sound: it was cracked and rang two notes, one for here and one for somewhere his grandad won't name; the woman in grey hums the same). *Eleven rows* (Elias planted a row for each year of the marriage; the orchard flooded in one night with no rain, the year Agnes went). *The man in the rows* (Davy saw a tall man walking the drowned rows with an unlit lantern: page t3's prints). *Keeping company* (from day 200: Pip walks at the man's heel; the man can't stop or something gets out, unless someone takes a turn, and Davy could).
  - **The vicar:** *The names* (before the Rooks, four families kept the farm, the Askews, Lindqvists, Harrows and Moores, and one of each went out and didn't come in; he has left a line under the Rooks). *The ladder* (rope burn on his palms; Agnes held the ladder steady while he cut her bell down). *What I struck* (he refused Agnes the clapper, as in page t4, then struck it once on the font and something rang back, two notes). *The register* (from day 250: the town has sold the farm six times, always cheap and to someone from away, with his father or himself as witness, yours too: the town hands it on to a keeper so the rest needn't).
  - **The postman:** *The round* (the Rooks' post: Elias's seed catalogues, Agnes's weekly letters to the old women of Lowmere). *The crate* (the bell's iron came on his round from Lowmere, with a card: "It wants ringing by someone who stays"). *Dead letters* (the Rooks' post still comes and he keeps it; unstamped letters for whoever is at the farm turn up in his sack, the torn page of your third morning among them). *The hand* (from day 280: the autumn letter to "Mrs Agnes Rook, care of the chapel" is addressed in your handwriting).
- **Hooks for the endings** (the mid-game act builds on these; each is the last scene's id in `FolkSystem.seen`, holding the day it was seen):
  - `maren_book`, **Maren stands**: a town meeting at the mill can put the vote again, with Ruth's minute book of every name. This is the town's ending: the bell hung by the town, the keeping shared.
  - `vicar_register`, **the register**: proof that the town hands the farm on to a keeper. With Maren's book it is what turns the mill meeting; without it, the town won't hear it.
  - `davy_turn`, **Davy's turn**: someone must take a turn walking the ring for Elias to come home, and Davy means to if nobody else does. The ending must let the player stop him, or fail to.
  - `post_hand`, **your hand**: the letter that comes back every autumn is in the player's own hand, which points at the ending where the player takes the turn (and writes it). The postman won't open it.
  - Hearts at the end (`_hearts`): walkers at 6 hearts or more are named as standing with you at a meeting that is lost.
  - The second year reads all four (see Story chapters and Endings): `maren_book` and `vicar_register` win the meeting; `davy_turn` and `post_hand` are two of the conditions for Elias's homecoming, and with `post_hand` seen you tell Davy on his night that the turn is yours.
- **The dialogue box** (`DialogueBox`): bottom centre over the hotbar, in the UI kit's panel, with a framed portrait on the left, the name in gold and the words in cream. A passing line fades like a message; a scene shows its page count and "Space: next" (Enter, A or a click turn the page too). Visitors' lines, gift replies, request thanks, scenes and the walkers' words on treks use it; everything else stays a message.
- **Portraits** (`Portraits`, drawn in code for now): a framed bust on a 48 by 48 grid, shown at 2x, in five expressions (neutral, smile, worry, grim, far). Maren: white bun, grey shawl. Davy: flat cap, freckles, red scarf. The vicar: wide hat, long face, white collar. The postman: peaked cap with a gold band, grey moustache, satchel strap. The woman in grey: the shawl over her head, only her eyes showing.
- **Future SpriteCook section: the portraits.** One strip per walker of 48 by 48 cells, `pixel-engine-image-v1`, in the locked art style, with the frame left to the code: Old Maren, Davy Tull, the vicar and the postman in neutral, smile, worry, grim and far (5 cells each), and the woman in grey in neutral, grim and far (3 cells). That is 23 portraits in all, going into `art/ui/portraits/`. Draw them behind a check in `Portraits.draw`, keeping the code bust as the fallback, as the farm sprites do.
- **Sim** (`tools/balance_sim.gd`, `_folk`): 400 days, `treks=3`, engaged / ignore / earlybed (November 2026). At midday the sim has a word with everyone at the gate or come by, sees any scene due, hands over requests it holds, and gives each walker the loved or liked food it holds most of (keeping 3 back, `GIFT_KEEP`): 61 / 81 / 80 gifts in the year (23 to 32 of them loved), 73 visits, but only 1 to 3 requests done, since the sim sells what it grows. Hearts (Maren / Davy / vicar / postman) at days 81, 161, 241, 321 and 400: 10/0/0/0, 10/3/0/1, 10/10/0/1, 10/10/10/2, 10/10/10/10 (engaged; the others end 10/10/10/9 and 10/10/10/8). Maren is walked from day 14 and is a friend by the first winter; Davy comes with the orchard in spring, the vicar with the chapel in summer, the postman with his round in the second autumn. Scenes, engaged: Maren's on days 24, 37, 49 and 163; Davy's 164, 180, 202 and 220; the vicar's 253, 267, 300 and 310; the postman's 259, 342, 353 and 371, so every ending hook is seen before the second All Hallows (earlybed hears the postman's last on day 388 or later). Coins engaged at days 41 to 400: 504, 1,023, 1,213, 728, 1,099, 1,030, 685, 911, 2,450, 941; ignore ends at 612 (dipping to 79 on day 321, after the summer works), earlybed 292. Sanity no lower than 26 / 16 / 9 (from 26 / 16 / 7), the grove walked on day 399 / 400 / 399. The economy and sanity targets still hold.
- Check it with `tools/capture.gd`: `folk=mill|orchard|chapel|post hour=11` (a visit), with `fscene=N fpage=P` (a scene, turned to a page) or `fsay` (the day's line). The save test checks that friendship round-trips and that a version 13 save keeps its standing.

## The diary

There is no tip card: everything the game teaches is written in the **diary**, so nothing covers the play area.

- **It is a book** (`ActionBar._build_book`, rows from `PanelRows._diary_sections`). A leather cover holds a spread of two parchment pages either side of the spine, with ribbon **tab markers** down its right edge, one per section: **First day** (or **The farm asks** once it's done), **Notes**, **Agnes Rook**, **The wood** (once one is found), **The second year** (from the town's letter) and **Afterword** (once the bell is hung, the grove is walked or an ending is reached: each ending adds a page there). Each section keeps its ribbon colour; the open one sticks out further with a gold edge, and one holding a page not read yet has a red dot. Each page has the section's heading along the top of the left page, a title with "new" in red ink or "done" in faded ink, the text, and its page number at the foot. Agnes's pages are in brown ink and your own last pages in blue-black. A page not found yet is torn out: a ragged stub at the spine over the bare cover, with its number and "Not found yet." (or "In a hollow tree somewhere.") in faded ink. A section with an odd number of pages ends on a blank page.
- **Turning pages.** Left and right (arrow keys or A and D, the D-pad or the left stick), the mouse wheel, or the < and > at the pages' outer corners turn a spread, with a soft page sound. Turning past a section's last spread runs on into the next section; the arrows hide at the very start and end. LB/RB or Q/E jump to the previous or next section, as in the ledger's tabs, and a click on a marker opens that section. The footer shows Turn page, Close, Tabs and Sections in the device's names. Opening the diary turns to the first page not read yet; otherwise it opens where it was left (kept until the game closes, not saved). Text that runs past a small window's page scrolls.

- **Finding it.** A new game starts with the diary in the desk drawer in the bedroom. Until it is found, the desk's red light blinks while you are in the house, and a message every 90 seconds says where it is. Using the desk the first time finds it ("You find a diary in the desk drawer") and opens it. From then on it goes with you.
- **Opening it.** J on the keyboard, the **Diary** section on the section wheel (the only way on a gamepad), or **Read** at the top of the Desk panel. It is a wheel section, so B or Esc goes back to the wheel.
- **The first day.** Eight steps: walk 10 tiles, plant 3 seeds with the trowel, open the bag, gather from 3 brush piles, open the section wheel, craft a crude hatchet, fell a tree, and drink from the pond. The diary lists the steps done ("1 of 8. Find your feet: done") and writes out the next one in full; later steps stay hidden. A step done ahead of its turn is passed over. Steps can't be skipped. Finishing a step in play says "Done: <step>. Your diary has the next step." with a chime. Steps done before the diary is found count quietly.
- **During the first day** the First day section has a page for each step done (marked done) and one for the next.
- **After the first day** the diary shows the current story chapter, its story and its prompt, on one page under "What the farm asks". Each new chapter adds a page, with a "Next: <chapter>" message.
- **Notes** are written as the player reaches each part of the farm, a page each in the order written: watering once 3 seeds are planted, food and water at 12:00, sleeping at 17:00, repairs on day 2, quests from 10:00 on day 2, chores from 14:00 on day 2, buildings on day 3, the mine on day 4, hens once a coop stands, goats once the barn stands, the cellar, and smelting and preserving once the furnace or smokehouse is built. The Rookery Wood (`wood`: walkers, the oil, nerve, words and rations, the tall one) is written on coming back from the walk to the wood's edge. A note met before the diary is found is waiting in it; one met after says "A new page in your diary: <title>."
- **The cue.** Once found, a small diary icon sits in the vitals row (after the coins). While a page is unread it shows "New" and a blinking red dot. New pages are marked "new" in red ink, and their section's marker has a red dot; they count as read when the diary closes.
- Text names the controls for the device in use: tools are left click or RT, hand actions (gather, open, drink, place) are Space or A.
- **Agnes Rook's pages** (`scripts/mystery.gd`): ten pages, each tied to a farm moment, and a last page when the bell is hung. Page 7, "What the crows bring" (the hollow under the great tree), is left by the first Hollow sighting in the first week or two (see Nights), or by the crows otherwise; so the first week has page 1 through the mail slot on day 3 and page 7 on the night of the walk to the wood's edge. Then **pages from the wood** (`TREK_PAGES`), five she wrote after the bell came down, following Elias, and left in the hollow trees so someone could follow: Into the wood, Past the mill, The drowned rows, The vicar, The ring of trees. They are found in order on treks, in hollow trees (`TrekSystem._search_hollow`), each from its route on (1 and 2 from the mill path, 3 the orchard, 4 and 5 the chapel; the grove trek can give any), and read in the diary's The wood section ("Pages from the wood, n of 5"). They are saved with the other pages (`rook_pages`).
- Saves keep the pages written, whether the diary is found, and which pages are new. Saves from before the diary count it as found. Saves from before tips existed count every note as written, and saves from before the guided first day count it as done, so neither floods them.

## Settings and pause

- **Pause menu.** Esc or Start with nothing open (Esc closes an open panel first). Like every panel it stops the day: the clock, needs, nights, happenings and foes all wait, and you can't move. It lists **Resume**, **Settings**, **Controls**, **Unstick me**, **Quit to the main menu** and **Quit the game** (plus the dev **Unlock** in debug builds). Both quits need a second press ("Yes, quit"), and say that progress since the last sleep is lost.
- **Settings** (`GameSettings` in `scripts/game_settings.gd`): music volume and sound-effect volume (0 to 100% in steps of 10, with − and + buttons; 0 mutes), Screen (Fullscreen or Windowed), Window size (Fill the screen, 1280×720, 1600×900, 1920×1080; shrunk to fit the screen, centred), Screen shake (on or off), and How long messages stay (Short ×0.7, Normal, Long ×1.6). Each change applies and saves at once.
- They are saved to `user://settings.cfg` (ConfigFile), apart from the save slots, and applied at launch. An old `hallowvale_settings.json` is read once: music or sound turned off becomes volume 0.
- Volumes work through the **Music** and **SFX** audio buses, made at launch. The music player is on Music; the sound-effect pool and the ambience loops are on SFX.
- The start screen shows the same Settings rows, and a Controls page. B or Esc goes back a page there. The Settings page scrolls to follow focus; the Controls page has only its Back button, so up and down (or the mouse wheel) scroll its list. Continue and Load with no saves, and empty slots under Load, are out of the focus path.
- Mouse, keyboard and gamepad all work: the D-pad or arrows move focus (left and right between − and +), A or Enter presses, B or Esc goes back. Pressing a setting keeps focus on that button, so + can be pressed again.
- `tools/capture.gd` sizes its own window, so the window settings are only applied when the game scene is the current scene.

## Test builds

- `application/config/version` in `project.godot` (now `0.1.0`) is shown as `v0.1.0` in the start screen's bottom-right corner, so feedback names its build. Raise it for each build sent out, and match `application/file_version` in `export_presets.cfg`.
- The "Windows Desktop" preset in `export_presets.cfg` builds one exe with the pack embedded, leaving out `art/style_tests/` and `tools/`: `godot --path . --headless --export-release "Windows Desktop" builds/CrowCreekHollow.exe`. `builds/` is git-ignored. The templates live with the Steam editor (`editor_data/export_templates/4.7.2.stable`).
- Release builds hide the dev Unlock and ignore F4 and Shift+F4 (`OS.is_debug_build()`).
- Godot logs to `user://logs/godot.log` on PC (default, keeps 5). `application/run/flush_stdout_on_print` is on so the log survives a crash. `TESTERS.md` tells testers what to try and what to send back.

## Saving

- The game opens on a **start screen**: **Continue** (the most recently saved slot), **New Game**, **Load Game**, **Settings** (the same settings as in the game, and a **Controls** page), and **Quit**. B or Esc goes back a page. The world is built only after you choose.
- There are **three save slots**. New Game asks for a slot, and a used slot takes two presses to overwrite. Then it asks for a save name, filled in as "Farm N" so a gamepad player can just press Begin. Load Game lists each slot with its save name, day, coins, and house stage. Older single-slot saves become slot 1. Pressing Overwrite keeps focus on the armed slot, so a gamepad's second press overwrites it. Crops from saves made before watering existed count as watered on the day they load, so they grow that night.
- The game saves **only** when you sleep in bed or collapse at 03:00, to the slot you're playing.
- The **Pause menu** (Esc or Start) holds **Quit to the main menu** and **Quit the game**, each taking a second press. Quitting to the menu returns to the start screen without saving, and progress since the last sleep is lost. The slot you were playing stays selected. Sleeping is the only way to save.
- Saved: day, skill XP, inventory (including every food), coins, goats and their feeding, bag upgrades, root cellar, cooler, and smokehouse (built, and what they hold), materials, stats, story chapters done, achievements done, selected seed, lantern tier, house stage, house wear, coop and hens, barn (built, and where it stands), tidy/mend/cleanse days, sanity, sanity penalty, boredom loss and the day you were last entertained, animal ages (hens and goats), crop days, clean nights, property tax owed, its due day and reminder stage, the post on the desk, the diary (found, pages written, pages new), the cards and sudoku puzzles left, catalog orders, crops (with kind), brush piles, the house extensions, furniture, paint, wallpaper and land deed (`estate`, version 11), the farm stand's demand (`stand_glut`), **player position**, whether you were **inside the house**, and the **open panel**.
- Quitting mid-day loses that day's progress since the last save. Position and panel are saved at the same moment, so they reflect the last sleep or collapse.
- **Saves are safe against crashes.** Each save is written to `hallowvale_save_N.tmp.json`, read back and checked, and only then moved over the real file; the save it replaces becomes `hallowvale_save_N.bak.json`. Only a good save becomes the backup, so a damaged file never pushes the last good one out.
- **Recovery.** Before the start screen lists the slots, each slot is checked: the file must be JSON, hold a day of 1 or more and an inventory, and have the right type for each list and table the loader reads. A damaged or missing save comes back from its backup (or from a complete `.tmp` save left by a crash mid-move, which is newer), and the start screen says once which slot was restored and to what day. A damaged save with no backup is kept as `.broken.json` and the slot shows empty, so Continue never starts a new game over it by mistake. Loading does the same check, in case the start screen didn't.
- **Save versions.** Each save records `save_version` (now 15; version 15 added the second year and the endings, `act`: a save with the bell hung has the act closed quietly, and one past the grove has the bell's ending recorded without its sequence; saves without one count as 1). On load, `SaveSystem._migrate` lifts an old save one version at a time: version 2 added the crow bell (`bell_day`) and treks (`treks_done`), and older saves start with neither begun. Version 8 cut the wider land (the towns, the bank, the campsite, the Lowmere quests, the bows and crossbows): an older save's banked goods and coins go back to the pack and purse, a bow or crossbow in hand is taken apart for what it cost, arrows and bolts are dropped, and a save made out in the land wakes at the homestead. Materials and items an old save never had (lamp oil, storm oak, flax, bell parts, trail rations) keep their new-game amounts. Version 10 added the seasonal crops, fish and forage: the cellar and cooler are kept by kind (`cellar`, `cooler`), an older save's cellar count becomes turnips and its cooler count perch, and today's forage is saved with `forage_day`. Version 11 added the estate (`estate`: extensions, furniture, paint, wallpaper, the land deed) and the farm stand's demand (`stand_glut`); an older save has none of them. Version 12 added the walk to the wood's edge (`trek_edge_done`) and the first Hollow sighting (`sighting_seen`): an older save past day 4, or that has walked anyone, has both done and the chapter To the Wood's Edge with them, so nothing replays and the mill path isn't held back; one from before day 4 plays them as a new game would. Version 13 made the nights played: which visitors have been met, for the prompts (`night_seen`; an older save has met each as often as it faced any, up to 3), the shadow's blight on the ground (`night_blight`) and the vicar's blessing (`bless_offer_day`, `bless_day`); an older save has no blight or blessing. Version 14 made the walkers neighbours (`folk`: friendship beyond the walks, walkers met, scenes seen, gift tastes learned, requests asked and done, the day's word and gift, gifts given, and today's visitor); friendship counts the walks already in `trek_walked`, so an older save keeps every walker's standing, and has met each walker it has walked (and Maren once she was walked to the wood's edge). A save from a newer build still loads; keys this build doesn't know are ignored.
- Saving in the mining cave records the homestead as your position. A trek still going at day end is called off before the save, so you wake at home. When the farm is taken for unpaid tax, the save, its backup and any `.tmp` are all deleted, so nothing brings the farm back.
- `tools/save_test.gd` checks all of this headless in slot 9 (truncated, empty and garbage files, wrong types, a missing save with a backup, a crash mid-move, an old save, a version 7 save made in the wider land, the walkers' friendship and a version 13 save without it, cave and trek saves, eviction).

## Combat (real time)

Combat happens while you move, in the style of Stardew Valley. There are two places to fight: the creatures in the mining cave, and the feral dogs on some treks (see Groves and treks).

- **Swing:** with the sword slot selected, press RT or click to swing your right-hand weapon in the direction you face. A swing reaches 1.5 tiles in a forward arc and has a 0.5 second cooldown. Only the player's swing animation shows it; no arc is drawn on the ground.
- **Block:** hold LT or right click with a weapon in hand to raise a guard. A blow from the front is turned aside.
- Foes have no health bars. A hit makes them flash pale, and that is the only sign of damage.
- **Foes roam** their area and wander when you're far away. They **chase** you when you're within their aggro range. Each foe has a contact attack on a cooldown. Their stats are `FOES` in `main.gd`:
  - **Bat** (cave): 4 HP, fast, 1 damage.
  - **Lizard** (cave): 8 HP, slow, 2 damage.
  - **Snake** (cave): 6 HP, quick, 2 damage.
  - **Dog** (treks): 5 HP, quick to chase, 2 damage.
- **Damage:** a swing deals your weapon's damage plus a random bonus of up to half your Combat level. Foe hits are reduced by your total armor defense, with a minimum of 1.
- **Invulnerability:** after you're hit, you have 0.9 seconds of safety and you're knocked back a little.
- **Kills** give Combat XP (12 to 18 by kind) and sometimes fiber or resin.
- **Combat** is a skill (same level curve as Skills). Each hit gives 4 XP. Max HP is 10 plus Combat level − 1.
- Food heals HP by its difficulty, from 1 to 4. Sleeping restores full HP. Losing all HP sends you home, shaken, with a 10 sanity penalty; on a trek it ends the trek.

## Gear and crafting

The Gear panel has ten slots in four columns: Back (your bag), Head, Neck, Belt (lantern), Off hand (shield), Chest, Main hand (weapon), Wrist, Legs, and Feet. The lantern hangs from the belt, so the offhand is free for a shield.

The Gear panel (G) is laid out as a person. Head, neck, chest, legs, and feet run down the middle. The back (your bag) sits beside the neck, the main hand beside the chest on the left, and the gloves beside the legs on the left. The off hand sits beside the chest on the right, and the belt (lantern) beside the legs. The toolbelt (hoe, axe, and pickaxe) sits in a row below. Each worn piece shows its drawing, and an empty slot is dim. Picking a tile fills the detail card with the piece's damage and armor, and its Craft button opens the Craft panel. Defense and hit damage are listed under the figure. The wrist slot is the gloves slot.

**The Craft panel is a grid of pictures.** Each sub-tab shows its recipes as tiles, four across: a drawn picture of the item with its name under it. Items you can't make yet are dimmed, but they still show, so you can see what they need. Picking a tile fills the detail card on the right: the picture, its name, what it does (damage, armor, or what it yields), its level requirement (green-red coloring shows whether you meet it), each material with how much you hold against how much it costs, and a single button (Make, Build, Cook, Upgrade, or Best when a tool is at its top tier). The card stays on the screen while you pick another tile, so you can compare recipes without scrolling. Pictures are SpriteCook icons from `art/ui/icons.png` (52 icons, 16 pixels, drawn at a whole multiple so they stay crisp); ore and bars pick their iron or copper icon by the item's tint. An item kind without icon art falls back to the shapes drawn in code (the RecipeIcon in the action bar). The same icons show in the bag, the hotbar and the Inventory. Every picture has a soft shadow beneath it and a dark outline around its filled shapes, so they stay readable at the small tile size.

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

Defense stacks across slots, so a full set can turn most hits into single points of damage. That needs a playtest before it is tuned.

## Forestry and tools

- **Forestry** trains by felling trees. A grove of twelve trees is scattered across the property. Each tree gives 3 wood, and with an iron hatchet a 40% chance of 1 hardwood (`HARDWOOD_CHANCE`; 2 every tree until the October 2026 economy pass, when hardwood piled up past 2,000), and 20 Forestry XP. Felled trees come back each morning.
- **Hatchets** and **picks** are tools with tiers. They are crafted from the Tools tab of the Craft panel and are kept by tier rather than worn in a slot. Hatchet tiers: crude, stone, copper, iron. Pick tiers: stone, copper, iron.
- A hatchet is needed to fell trees. Hardwood needs a copper hatchet or better.

- **Fishing rods** are in the Tools tab too. A **Willow rod** (Fishing 2: 2 wood, 2 fiber) adds 10% to each catch chance. A **Hardwood rod** (Fishing 5: 2 hardwood, 2 fiber, 1 resin) adds another 10%. The rod sits in the toolbelt on the Gear panel.
## Mining

- **Rocks** sit on the farm at eight spots. They come back every 14 days (`ROCK_REGROW_DAYS`), except on a spot with a growing crop.
- Breaking a rock **by hand** gives 1 stone. That gets you the first stone pick.
- With a **pick**, a rock gives 2 stone and 8 Mining XP (`XP_MINE`).
- From **Mining 2**, a pick also gives a 15% chance of **copper ore** per rock. Farm rocks never give iron.
- Stone is worth little on its own. It goes into the stone hatchet and stone pick.

## Smithing and metal gear

- **Furnace** (built from the Buildings menu, in the workshop): 80 coins, 6 wood, 4 stone, Carpentry 5. Stand beside it, facing it, and press Space to smelt.
- **Smelting** turns ore and one wood into a bar: **3 copper ore** or **2 iron ore** a bar (`SMELT_ORE`; one each until the October 2026 economy pass, when copper bars piled up to 2,000). Copper needs Smithing 1. Iron needs Smithing 4. Smelting gives 20 Smithing XP (10 before copper took three ore a bar). The furnace makes at most 8 bars a day (`SMELT_DAILY_LIMIT`) before it must cool overnight, so a stockpile of ore trains Smithing over weeks, not in one afternoon.
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

## Shields

- **Shields** go in the **off hand**. Hardwood shields (Forestry 4) use hardwood and fiber. Copper (Smithing 3) and iron (Smithing 6) shields are heavier and give more defense.
- A shield adds its defense like any worn piece. Blocking needs only a weapon in hand, not a shield.

## Gathering and metal

Bark is the starting tier and metal is the later one. Each bark piece has a metal piece for the same slot. The metal piece is better, needs Smithing, and takes that slot once you have it. Bark pieces stay craftable early on.

Each gathering skill has its own tool. The tool's material sets what it can break.

| Skill | Gathered from | Tool | Gives |
|---|---|---|---|
| Bushcrafting (existing) | Brush piles, thickets | None | Wood, fiber, resin |
| Forestry | The grove's trees on the farm | Hatchet | Wood, hardwood |
| Mining | Rocks on the farm, ore in the cave | Pick | Stone; copper and iron ore |
| Smithing | A furnace built from the Buildings menu | None | Bars from ore and wood; metal gear and tools from bars |

**Hardwood is a key material.** It goes into tool handles, rods and **shields** (offhand, hardwood and metal).

**Ore comes from the farm's rocks and the cave.** Farm rocks give a little copper; the mining cave gives copper and is the only source of iron.

**Farm rocks** are cleared like brush piles and mostly give stone, which is worth little. From Mining 2 there is a small chance of copper ore instead.

**Tool tiers:** a stone hatchet or pick (from farm stone) comes after the first tools. Copper tools come from Smithing, and iron tools after that. Trees need any hatchet. Hardwood needs a copper hatchet or better. Copper ore needs a pick. Iron ore needs a copper pick or better.

Levels are first-pass values and will be tuned in playtesting. Ranged weapons and magic are not in the game.

**Decided:** the offhand (left hand) is for the shield. The lantern moves to a **belt** slot, so it can be worn without taking a hand. The lantern keeps its light ring and upgrades as before. Moving it is a grid change to be made when shields are built.

## The mining cave

A cave on the homestead, entered from the farm's west edge. It is the only place to get iron ore, and the main place to fight (the feral dogs on treks are the other).

- **Entrance:** step onto the cave mouth on the farm's west edge. The exit mat inside takes you back out to the farm.
- **Dark:** the cave is always open, but it has no daylight at any hour. Without a lantern it is pitch black; a lantern lights its usual ring, glowing stronger than outdoors (`CAVE_TINT`, `CAVE_LANTERN_BOOST`). Sanity still follows the time of day, not the cave's dark.
- **Daylight at the exit:** by day a very faint, cool glow spills up the exit steps (`cave_mouth_light`, `CAVE_MOUTH_ENERGY`). It fades out with the dusk and is gone at night.
- **Layout:** the cave is laid out fresh each day, so the tunnels, ore, and creatures change overnight. The same day always gives the same cave.
- **Ore:** copper and iron set into the rock walls. Copper needs a stone pick and Mining 2. Iron needs a copper pick and Mining 5, and only sits deeper in the cave. About 5% of the rock walls along the tunnels hold ore (`CAVE_ORE_CHANCE`), and deep ore is iron about 1.5% of the time (`CAVE_IRON_CHANCE`): about 9 copper and 3 iron nodes a day. Each node gives one ore and 8 Mining XP. Broken nodes stay broken until the next day, and that holds through a save.
- **Creatures:** ordinary animals, no supernatural ones. Three bats (fast, weak), two lizards (slow, tougher), and two snakes (quick, hard-hitting). They spawn away from the entrance, and each visit starts with them back in their places. Kills give Combat XP and a small chance of fiber or resin.
- **Saving:** a save made in the cave returns you to the homestead when loaded.

## Upkeep, hens, and the third plot

**Goats (the barn)** — The barn holds up to **3 goats**, ordered for **45 coins** each from the catalog at the desk. Feed them **2 crops each, once a day**, by hand from the Barn panel or from its feed hopper. A **grown** goat (10 days old) gives **1 milk each morning** when fed, stored as milk. Young goats give nothing. A grown goat sells for **70 coins** from the Barn panel, against 45 to buy. Two unfed days in a row and a goat wanders off. Goats wander in the yard in front of the barn and keep about half a tile between them, so they never stand on the same spot. Each goat that is unfed counts as a missed chore that night, like the hens.


Keeping the homestead running is the daily work. Each part is at base level for now, to be deepened one project at a time.

- **Chores:** each day has a short list, shown at the top of the House panel. **Tidy the house** is a chore once the house is Patched (before then it can't be tidied, so it isn't listed). **Mend a board** is a chore only when the house has 2 or more wear (`MEND_DUE_WEAR`), so about every other day; otherwise the House panel still offers it, for Carpentry. Once you have hens or goats, feeding them is listed too, but it is done at the coop or barn, or by its hopper. Each chore left undone adds 1 wear overnight. (Until October 2026 tidying and mending were daily, and the tidy was counted missed before the house could be tidied.)
- **Chores pay** (`scripts/homestead_rewards.gd`):
  - **Finds:** the day's tidy turns up something small: a few coins under the rug, two firewood, two turnip seeds, a crow feather, or a pressed flower (+5 sanity). The day's first mended board does too: hidden coins, two sticks, a resin bead, or a crow feather. The find is picked by the day.
  - **Kept well:** a night with every chore done brings back 2 sanity (`WELL_KEPT_SANITY`, 3 until November 2026) and pays odd-job coins in the morning, 1 for each night of the streak, up to 8 (2 up to 20 until the October 2026 economy pass: about 7,000 coins a year). Every 7th night in a row, someone leaves a **crow charm** on the step. Missing a chore resets the streak; a night with no chore due (early on, before the house is Patched, on a day with nothing to mend) neither adds to it nor breaks it.
- **Wear:** the house wears by 1 each night (a Restored house only every other night, so its mending comes about every fourth day), plus 1 for each chore left undone, up to 10. Mending a board takes 2 off, a tidy takes 1, and a repair takes 3. At wear 6 or more, rain ruins a random crop overnight. The Upkeep section of the House panel shows it.
- **Buildings menu (U):** the workshop, the coop, and the barn are built and moved from here, not from the House panel. Each one is placed the same way: building it starts placement, a green or red preview follows the tile you face, and Space places it on open grass. A spot can't cover plots, crops, rocks, brush, fishing spots, or you. B cancels. The Move button relocates a standing building for free. The workshop has no price of its own: building the first of the smokehouse or furnace starts its placement, the piece is paid for when it is placed, and moving it takes every piece inside along. A building that was paid for but never placed (older saves) shows Place instead.
- **Coop:** 6 wood, 4 fiber, and Carpentry 2. A 2 by 2 building. Stand beside the coop, facing it, and press Space to open its panel, where you feed the hens (they are ordered from the catalog). The hens wander inside it, walking to a spot, pausing, and walking on.
- **Barn:** 10 wood, 6 fiber, and Carpentry 7. A 3 by 2 building of red boards. Stand beside it, facing it, and press Space to open its panel. It holds the goats, which are ordered from the catalog, and it is separate from the coop.
- **Hens:** 12 coins each from the catalog, up to four in the coop. Feed them once a day from your crops (1 crop per hen), by hand from the coop panel or from its feed hopper. Hens are grown after a week (7 nights), and only a grown hen that is fed lays an egg overnight, which goes into your pack as an egg, as far as there is room. A grown hen sells for **20 coins** from the coop panel. Two unfed days in a row and a hen wanders off.
- **Feed hoppers** (coop and barn panels; `COOP_HOPPER_COST` 4 wood, 4 copper bars, Carpentry 3; `BARN_HOPPER_COST` 6 wood, 6 copper bars, Carpentry 7): built once in each building, then **Fill** tips crops from the pack into it (turnips first) up to 30 (`HOPPER_CAP`): a week and more for four hens, five days for three goats. At night, before the chores are counted, a hopper feeds its animals if they weren't fed by hand and it holds a full day's feed, which counts as the feeding chore; the morning message says when it runs empty. The panel shows what it holds and about how many days that is.
- **Predators:** raids on the coop and barn at night (see Nights): a fox, crows or something at the barn door. They come more often at wear 4 or more, and a lamp post beside the building halves them and drives them off even while you sleep. (Until November 2026 a fox simply took a hen half the nights at wear 4.)
- **Post and the desk:** post comes through the mail slot in the front door and lands on the **desk** in the bedroom, which is there from the start. Each morning's new letters are announced in the morning message. Unread post turns on a **red light** at the desk, blinking, while you are in the house. Using the desk opens the Desk panel (post, property tax, pastimes, catalog), which marks the post read and lists it. Read letters go in the drawer with the Clear button.
- **Property tax:** a bill arrives on the 1st of January, April, July, and October (not on the first day of the game). Its amount is the **property value** at that moment, which scales with what you own: **50 coins** (`PROPERTY_TAX`), **multiplied by 1.8 with each house upgrade**, times (1 + **5% per building**: coop, barn, cellar, cooler, smokehouse, furnace, woodshed, + **15% per house extension**), times (1 + **25% per farm plot** past the first), plus **3 a hen, 8 a goat and 4 a lamp post or sprinkler** (`PROPERTY_PER_HEN`, `_GOAT`, `_FIXTURE`). Keeping the farm well doesn't raise the bill. A new farm pays about 60 a quarter, a restored one with its buildings, plots, animals and sprinklers about 750, and one with all three extensions about 950. (Until the October 2026 economy pass the base was 40 with no extensions, animals or fixtures: 1,350 a year at most.) The Desk panel shows the value and its breakdown. It is due 14 days after it arrives. Pay it from the Desk panel. Unpaid, a reminder comes the day after it is due, a final notice 7 days late, and at 14 days late the **land is lost**: the save is removed and the start screen says why. Once the **land deed** is bought (see Homestead projects), no bill comes again.
- **Third plot:** opens at Farming 9 once the house is Patched. It sits between the two paths, south of the first plot.

## Game feel

Everyday actions get a little weight (`scripts/game_feel.gd`).

- **Bursts:** each action's sound also throws a puff of particles at the tile being worked: dirt from the hoe and planting, droplets from watering and a catch, sparkles and leaves from a harvest, chips and leaves from the axe, stone from the pick, leaves from gathering, chips from splitting and repairs, and sparks from a hit. Leaves take the season's colours and see-saw as they fall. Particles are one or two art pixels, so they match the 3× pixel art.
- **Shake:** each tool strike already jolts the camera a little. Felling a tree and breaking a rock jolt it harder.
- **Pop-ups:** what you gain floats up over the farmer and fades: XP in gold (`+10 Farming XP`, after the Hale bonus), coins in bright gold, and items in cream (`+1 Turnip`). Gains are found by watching the totals each frame, so every source shows without being wired in. Several at once stack upward. They stay quiet while a menu or the bag is open, and they sit on their own canvas so the night doesn't dim them.

## Graphics and atmosphere

The farm reads as a finished picture rather than flat colour blocks. Four layers do this, all on the farm view.

- **Colour grade.** A full-screen pass (`shaders/grade.gdshader`) sits on a CanvasLayer under the HUD, for a grim, overcast mood: it pulls saturation well down (0.62), darkens the scene (0.84), adds a little contrast, faint warmth in the highlights and cold blue-grey in the shadows, a heavy vignette, and fine film grain. The grass is also tinted darker and mossier as it is drawn (`GRASS_TINT`). The HUD stays unfiltered so text remains sharp.
- **Ground detail.** Grass is tinted per tile (±2% so it does not checkerboard), with tufts and small pebbles on the path. Soil and path keep their own texture so they never blend into grass.
- **Shadows.** Trees cast a soft ground shadow, drawn in a separate pass beneath their canopy. Rocks and brush cast small shadows too.
- **Seasonal particles.** Each one follows the camera and only runs in its season. Autumn drops SpriteCook leaves (`weather_leaves`: maple, oak, elm and birch, one picked per particle) that spin as they fall. Spring drifts SpriteCook petals (`weather_petals`). Summer dusk brings blinking fireflies. Particles are CPU-driven and stay small in number, so they cost little.
- **Weather sprites.** The weather overlay (`scripts/weather.gd`) draws from SpriteCook art. Rain falls as crisp streaks one art pixel wide, each landing at its own spot on screen and playing the last three frames of `weather_splash` (a burst, a ring and a ripple). Snow uses the flake cells of `weather_drops`: mostly small clumps, some nearer and doubled, and a few full flakes. Fog rolls by in faint wisps (`weather_fog`, drawn 2.5 to 4 times its size). Clouds are shadows passing over the land: the SpriteCook `weather_cloud` (128×64), darkened to the shadow colour and drawn at 3× or 4×, some mirrored. Without the art, the old soft shapes are drawn.

Particles do not run indoors or in the cave. Nothing in the grade pass changes game logic, so the save and the rules are untouched.

## Code layout

`scripts/main.gd` (`class_name MainGame`) is the scene root. It owns the shared state, the drawing, the input and panel glue, the HUD, the map build, the lights, the crows, and the title and settings flow. The rules for each domain live in their own `RefCounted` script, which is built once in `_ready` and kept as a member on main:

- `panel_rows.gd` (`panels`): the row lists for every panel.
- `desk_system.gd` (`desk`): finding the diary, pastimes, the catalog and its deliveries, mail, the property tax and eviction. The diary itself (pages, the HUD icon) is in `main.gd` under "The diary", its rows in `panel_rows.gd`.
- `animal_system.gd` (`animals`): hens and goats, feeding, ageing and sales.
- `farm_system.gd` (`farm`): seeds, planting, watering, harvest and crop unlocks.
- `firewood_system.gd` (`firewood`): chopping, the fire, and warmth.
- `sanity_system.gd` (`sanity_sys`): the day's events, tidying, cleansing and the night relief.
- `night_system.gd` (`nights`): the night visitors and their encounters, the raids on the coop and barn, the field shadow and its blight, crow feathers and the crow charm.
- `madness_system.gd` (`madness`): what low sanity shows you: the crows watching, figures at the screen's edge, the tool swapped in your hand, the lying clock and the crop that isn't there.
- `homestead_rewards.gd` (`rewards`): what chores and needs give back: Hale, chore finds, the kept-well streak and pastimes.
- `daily_happenings.gd` (`happenings`): the day's surprise: what it is, where it is, and what taking it gives.
- `farm_projects.gd` (`projects`): the homestead progress ladder and placeable decor (lamps, flower beds, paths, fences, sprinklers, the bench, birdbath and weathervane, the crow bell).
- `estate_system.gd` (`estate`): the house extensions, furniture, paint and wallpaper, and the land deed, with their drawing.
- `folk_system.gd` (`folk`): the walkers as neighbours: friendship, gifts, farm visits, requests and scenes, and the Folk tab's rows. It owns the dialogue box (`dialogue_box.gd`, a `PanelContainer` on the HUD) and its portraits (`portraits.gd`, drawn in code).
- `trek_system.gd` (`trek`): treks into the Rookery Wood: the walker at the north edge, the clearings (laid into the cave's grid), the walker's nerve, lamp oil, and the trek events.
- `game_feel.gd` (`feel`): action bursts, the bigger shakes, and the pop-ups for XP, coins and items.
- `mystery.gd` (`mystery`): Agnes Rook's torn pages, when each turns up, and the diary's section for them.
- `stall_system.gd` (`stall`): the farm stand and its demand curve, cooking, food and the pack.
- `progression_system.gd` (`progression`): skill XP, levels, story, achievements and rewards.
- `save_system.gd` (`saver`): saving, loading and the saved position.
- `craft_system.gd` (`crafting`): recipes, gear, tools and bandages.
- `fishing_system.gd` (`fishing`): the pond's fish and when they bite, fish spots, casting and reeling, and the cooler.
- `forage_system.gd` (`forage`): the day's forage on the farm's edges and in the trek clearings, picking it, and its layer.
- `ambience_system.gd` (`ambience`): the looping beds and the occasional sounds of the farm, the house and the cave.
- `mining_system.gd` (`mining`): rocks, cave ore, smelting and brush gathering.
- `combat_system.gd` (`combat_sys`): foes and weapon damage.

Each class holds `var m: MainGame` and reads main's state through it. A member is named after its job, and never after a name main already uses as a local or variable (main has a local `combat`, which is why the combat member is `combat_sys`). Drawing (`_draw_*`), the engine callbacks, and anything connected to a signal stays on main, because it needs the node.

## Farm layout

The farm is a hand-read grid. `tools/farm_grid.txt` holds one character per inner tile (64×40). It was first read tile by tile from the layout diagram at 40×24, then spread out to 64×40 by the one-off `tools/grow_farm.py` when the farmer became a full-tile sprite. `tools/hand_layout.py` reads that grid, derives the anchors (plots, house, porch, well, stall, great tree, grove spots) and writes `scripts/farm_layout.gd`. Regenerate with `python3 tools/hand_layout.py`; edit the grid, not the generated file.

- Terrain codes are listed in the header of `scripts/farm_layout.gd`. The roof (`O`) is a separate tile from the house body (`H`), so the two can differ in colour. The roof is walkable: the player walks over it, the walls and door block. The roof art is drawn in its own layer, over the player while they are north of the walls and under them on the walls, the same rule as the great tree's canopy. The stall is 3×2, as wide as its art. The well is 2×2; `WELL_IX` is its top-left tile.
- The farmhouse footprint is 11 tiles wide: five rows of roof, then two of wall with the door in the middle of the bottom row, and the porch below the door, with a path tile on each side of it so the door sits centred on the path. Its sprite is 12 tiles wide and 10 tall, shifted half a tile so the steps sit on the door tile. The door is a little taller than the farmer, so the house reads at the farmer's scale. Each repair stage is a SpriteCook edit of the ruined house (`gemini-3-pro-image`, since the exact-size model stops at 128 pixels), placed on the same 192×160 canvas with the door and steps lined up. The Boarded stage came out about 11 pixels narrower; it is centred on the door.
- The plots are 15×7 (plot one), 15×6 (plot two) and 12×6 (plot three).
- Split-rail fences (`X`, blocking) run along the top of plot one and the bottom of plot two, one tile out from the soil; the plots stay open on their sides. A scarecrow (`Y`, blocking, drawn two tiles tall with the trees) stands just east of plot one.
- Ground clutter (pebbles, fallen leaves, mushrooms, dry grass tufts; `art/farm/clutter.png`) is scattered on about one open grass tile in eleven, chosen by a hash of the tile, and only where all eight neighbours are grass. It is drawn under everything and never blocks.
- Rocks and brush are SpriteCook sprites: breakable boulders (`boulder_*`), brush piles (`brush_*`) and a bramble thicket (`thicket_0`) on the thicket spots. The cave's outcrop (`K`) uses mossy cliff rocks (`rock_*`).
- The rocks around the cave are one 96×80 SpriteCook hillside (`hillside`): mossy stone ledges six tiles wide and five tall, its foot level with the entrance sill, so the cave reads as cut into a hill. The rock tiles under it are drawn as grass; the rocks in the row below keep their own boulder sprites at its base.
- The cave entrance is a 64×48 SpriteCook sprite (`cave_mouth`): a timber-framed doorway in a mossy rock face, four tiles wide and three tall, its doorway (about the farmer's height) centred on the cave-mouth tile. Inside, the exit is a 32×32 sprite (`cave_exit`) of stone steps up into daylight, over two exit tiles in the middle of the south wall, where you arrive; leaving puts you on the path just south of the cave mouth.
- Inside, the cave is drawn in SpriteCook art too: a packed-earth floor everywhere, the rock walls laid over it on the dual grid (darkened by `CAVE_WALL_TINT` so the tunnels read), copper and iron ore sprites on the ore tiles, and wooden steps up into daylight on the exit tile (`_draw_cave_sprites` in `main.gd`).
- Hens and goats are SpriteCook walk cycles (`hen_walk`, `goat_walk`, four frames facing right). Each faces the way it is walking, steps while it moves and stands on its first frame while it waits; the flock starts its cycles out of step. Bats, lizards and snakes are SpriteCook animations (`foe_<kind>.png`, four frames): the bat flaps all the time, the lizard and snake animate only while they move and face the way they last moved sideways, and all three turn pale when hit. The trek dogs keep their drawn shapes.
- The coop is a 3×2 footprint and the barn 5×3, sized so a hen fits the coop's door and a goat the barn's. Each is one SpriteCook sprite (`coop` 48×64, `barn` 80×80) as wide as its footprint, standing on its bottom edge with the roof rising above, and sorted with the trees so the farmer walks behind it from the north. The hens peck in the yard in front of the coop and the goats graze in front of the barn. A coop or barn from an older save that no longer fits where it stood is moved to the nearest clear grass.
- The great tree's base is a 3 by 3 block. Its middle and bottom rows (`B`) block movement; its top row (`b`) is walkable grass. Its art (a SpriteCook sprite, 128×128) is drawn larger than that base, 8 by 8 tiles, with the base at the bottom centre. The art above the base does not block. The player walks behind the canopy when north of the base, and in front of the base when south of it (`_update_big_tree_depth` in `main.gd`).
- Plot one and plot two are soil (brown in the diagram); plot three is fallow (olive).
- The grove keeps twelve trees. The thirteenth tree in the diagram, at the top-left of the field, is dropped.
- The workshop, furnace, smokehouse, woodshed, chopping log and cellar are not on the grid. The cellar's spot is open grass, listed as reserved, so a coop or barn is never placed on it. The workshop is placed on 7 by 6 open grass like the coop and barn (`workshop_tile`, saved since save version 7), and its pieces stand at fixed places inside it (`SMOKEHOUSE_AT` and the rest in `main.gd`). The layout still lists the workshop's first spot, south-east of the farm centre (`WORKSHOP_RECT`, among the reserved tiles); `main.gd` ignores that reservation and keeps the spot only for saves from before version 7, whose built workshop stays there until moved. Changing the generated layout would change its version and reset every save's crops, so it was left as it is. Once built, the cellar, smokehouse, furnace and woodstore are SpriteCook sprites (`cellar`, `smokehouse`, `furnace`, `woodstore`, 16×32), about the farmer's height: each stands on its one-tile footprint and rises over the tile above, sorted with the trees. The chopping log (`chopping_log`) is 16×16. The cellar stands on grass and the workshop pieces on its floor. The workshop is 7 by 6 tiles: a two-row back wall, about the farmer's height, low side and front walls, and a 5 by 3 floor with the door in the middle of the front wall. Its walls and floor are one SpriteCook sprite (`workshop`, 112×96) drawn under the player. The furnace, smokehouse and woodstore stand in a row against the back wall, and the chopping log in the front right corner.
- Rocks and brush spots are kept only where they still sit on open grass.

Farm art. `art/farm/` holds the farm's pixel art: 16-pixel tiles at native size, and props with transparent backgrounds. `FARM_SPRITES` in `main.gd` switches the farm from the flat view to this art, and `scripts/farm_sprites.gd` loads it. Tiles without art (coop, barn, workshop and other unlocked buildings, decorations) keep the flat colour until they get their own art.

The ground is five SpriteCook 15-piece dual-grid tilesets, `art/farm/ground_*.png`, each a 4 by 4 atlas of 16-pixel frames. Grass is drawn under every ground tile, using the filled frame of its set, mirrored by position. Water, fallow, soil and path (the porch counts as path) are laid over it in that order, each on the dual grid: a frame sits on every corner where four map tiles meet, half a tile up and left of a map tile, chosen by which of the four tiles are that material (`_draw_dual_ground` in `main.gd`). Edges, corners, inner corners and one-tile paths all come from the same 15 frames, and the path goes last so the dock and porch cross the shore and the plot edges.

The older `tools/farm_layout.py` converter sampled the diagram by colour. It produced too many misreads and is no longer the source of the layout.

A save records the layout's version. When the version changes, the save is migrated: crops, brush and felled trees reset, the player starts at the farm centre, and the coop and barn move to the nearest clear grass. Money, skills, tools and animals are kept, and the player is told what happened.

## Deferred

- More of the story beyond Agnes Rook's pages (see The farm's past): what the Hollow is, and whether Elias and Agnes can be found.
- **Wolves that threaten livestock.** Needs livestock first. With the cave and the trek dogs in, wolves would give a reason to guard the animals.

## Open decisions

- Whether the house interior should become a separate scene.
- Whether the tile map moves to a `TileMapLayer` with a real `TileSet` once art is in.
