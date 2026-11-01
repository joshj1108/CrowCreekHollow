class_name Foods
extends RefCounted

## Every food the farm grows, catches, gathers, or makes. The pack counts each one under its held key.
## A food's difficulty (1 to 5) and the level needed to obtain it set what it restores, so harder and
## later food fills you more:
##   food    = 10 + 12 x difficulty + 3 x level
##   sanity  = 1 + difficulty + level / 2
##   HP      = difficulty
## kind is crop, animal, fish, forage or cooked. Crops sell for CROP_VALUE in main.gd; the rest for price.
## tags put a food in a recipe group ("berries", "mushrooms"); see group().
## effect is what some foods do besides fill you: warm (warmth), water, calm (sanity on top of the usual),
## and nerve (steadies the walker, when eaten on a trek). A calm below zero unsettles you.
## inedible foods are only ingredients. Cooked foods are named for what made them and have a picture of their own.

const LIST := [
	# Crops, in the order of CROPS in main.gd.
	{"id": "turnip", "held": "crops", "kind": "crop", "name": "Turnip", "icon": "turnip", "tint": "8fd16b", "skill": "Farming", "level": 0, "difficulty": 1, "price": 0,
		"desc": "Harvested from the field. Eat it raw, or cook it into a meal. Turnips grow in every season and keep in the cellar."},
	{"id": "kale", "held": "kale", "kind": "crop", "name": "Kale", "icon": "leafy", "tint": "3f6a4a", "skill": "Farming", "level": 1, "difficulty": 1, "price": 0,
		"desc": "Dark, crinkled leaves that sweeten after a frost. Picked again every few days until winter's end."},
	{"id": "peas", "held": "peas", "kind": "crop", "name": "Peas", "icon": "pod", "tint": "8fc860", "skill": "Farming", "level": 1, "difficulty": 1, "price": 0,
		"desc": "Sweet spring peas, picked again every couple of days while spring lasts."},
	{"id": "corn", "held": "corn", "kind": "crop", "name": "Corn", "icon": "corn", "tint": "e8c440", "skill": "Farming", "level": 2, "difficulty": 1, "price": 0,
		"desc": "An ear of corn in its husk. Eat it raw, cook it, or feed it to the animals. Corn does not keep in the cellar."},
	{"id": "potato", "held": "potatoes", "kind": "crop", "name": "Potato", "icon": "potato", "tint": "c8a06a", "skill": "Farming", "level": 2, "difficulty": 1, "price": 0,
		"desc": "Dug from under the haulms, three to a plant. They keep in the cellar."},
	{"id": "leek", "held": "leeks", "kind": "crop", "name": "Leek", "icon": "leek", "tint": "a8c878", "skill": "Farming", "level": 2, "difficulty": 2, "price": 0,
		"desc": "A long white leek that stands through the winter rain. It keeps in the cellar."},
	{"id": "pumpkin", "held": "pumpkins", "kind": "crop", "name": "Pumpkin", "icon": "pumpkin", "tint": "e0822a", "skill": "Farming", "level": 3, "difficulty": 2, "price": 0,
		"desc": "A large pumpkin. Eat it raw, or cook it. Pumpkins do not keep in the cellar."},
	{"id": "parsnip", "held": "parsnips", "kind": "crop", "name": "Parsnip", "icon": "root", "tint": "e8dcb0", "skill": "Farming", "level": 3, "difficulty": 2, "price": 0,
		"desc": "A pale root, sweeter for the cold. It keeps in the cellar."},
	{"id": "strawberry", "held": "strawberries", "kind": "crop", "name": "Strawberry", "icon": "berry", "tint": "d83a3a", "skill": "Farming", "level": 4, "difficulty": 2, "price": 0, "tags": ["berries"],
		"desc": "Small and sharp, the old kind. The plants fruit again every few days through spring and summer."},
	{"id": "garlic", "held": "garlic", "kind": "crop", "name": "Garlic", "icon": "bulb", "tint": "efe6d8", "skill": "Farming", "level": 4, "difficulty": 2, "price": 0,
		"desc": "A fat head of garlic, planted in autumn and lifted in the cold. It keeps in the cellar. Some say the things at the fence mind it."},
	{"id": "blueberry", "held": "blueberries", "kind": "crop", "name": "Blueberry", "icon": "berry", "tint": "4a5aa8", "skill": "Farming", "level": 5, "difficulty": 2, "price": 0, "tags": ["berries"],
		"desc": "From a low bush that fruits again every few days through the summer."},
	{"id": "apple", "held": "apples", "kind": "crop", "name": "Apple", "icon": "turnip", "tint": "b8442e", "skill": "Farming", "level": 4, "difficulty": 2, "price": 0,
		"desc": "From an apple tree grown from the drowned orchard's stock. Sharp and sweet, and it keeps."},
	# From the animals.
	{"id": "egg", "held": "eggs", "kind": "animal", "name": "Egg", "icon": "egg", "tint": "f2ead2", "skill": "Farming", "level": 0, "difficulty": 1, "price": 0,
		"desc": "Laid by the hens."},
	{"id": "milk", "held": "milk", "kind": "animal", "name": "Milk", "icon": "milk", "tint": "b8d4e8", "skill": "Farming", "level": 0, "difficulty": 1, "price": 0, "verb": "Drink",
		"desc": "Milked from the goats."},
	# Fish from the pond (see FishingSystem.FISH for when each bites). Raw fish spoil in the pack overnight.
	{"id": "perch", "held": "fish", "kind": "fish", "name": "Yellow Perch", "icon": "fish_t", "tint": "b8b04a", "skill": "Fishing", "level": 1, "difficulty": 1, "price": 6, "verb": "Eat raw",
		"desc": "The pond's everyday fish, striped and bony. It bites in any season."},
	{"id": "bluegill", "held": "bluegill", "kind": "fish", "name": "Bluegill", "icon": "fish_t", "tint": "5a7ab0", "skill": "Fishing", "level": 1, "difficulty": 1, "price": 5, "verb": "Eat raw",
		"desc": "A small, flat summer fish that takes anything by day."},
	{"id": "trout", "held": "trout", "kind": "fish", "name": "Cutthroat Trout", "icon": "fish_t", "tint": "b87a6a", "skill": "Fishing", "level": 2, "difficulty": 2, "price": 10, "verb": "Eat raw",
		"desc": "Red-slashed under the jaw. It comes up the creek into the pond in spring and autumn, by day."},
	{"id": "crappie", "held": "crappie", "kind": "fish", "name": "Black Crappie", "icon": "fish_t", "tint": "7a7a6a", "skill": "Fishing", "level": 2, "difficulty": 1, "price": 8, "verb": "Eat raw",
		"desc": "Speckled and slow. It bites in the cold months, when little else will."},
	{"id": "bullhead", "held": "bullhead", "kind": "fish", "name": "Brown Bullhead", "icon": "fish_t", "tint": "6a5a3a", "skill": "Fishing", "level": 3, "difficulty": 2, "price": 9, "verb": "Eat raw",
		"desc": "A whiskered mud fish that only feeds after dark, in summer and autumn."},
	{"id": "lamprey", "held": "lamprey", "kind": "fish", "name": "Lamprey", "icon": "fish_t", "tint": "4a4a5a", "skill": "Fishing", "level": 4, "difficulty": 2, "price": 12, "verb": "Eat raw", "effect": {"calm": -2},
		"desc": "No jaw, only a round mouth of teeth. It comes up at night in winter and spring. Smoked, it fetches a good price."},
	{"id": "pale_carp", "held": "pale_carp", "kind": "fish", "name": "Pale Carp", "icon": "fish_t", "tint": "e8e4d8", "skill": "Fishing", "level": 5, "difficulty": 3, "price": 26, "verb": "Eat raw", "effect": {"calm": -8},
		"desc": "White as candle wax, and its eyes have no colour at all. It only rises late at night. Nobody stocked the pond with these."},
	{"id": "sturgeon", "held": "sturgeon", "kind": "fish", "name": "White Sturgeon", "icon": "fish_t", "tint": "8a9098", "skill": "Fishing", "level": 6, "difficulty": 3, "price": 45, "verb": "Eat raw",
		"desc": "Older than the farm, armoured in bony plates. It is rare, and only takes a line by day."},
	# Forage from the farm's edges and the trek trails (see ForageSystem.FORAGE for the seasons).
	{"id": "hare", "held": "hare", "kind": "game", "name": "Hare", "icon": "smoked", "tint": "8a7058", "skill": "Bushcrafting", "level": 2, "difficulty": 2, "price": 12,
		"desc": "Caught in a snare at the wood's edge. Lean, dark meat that keeps a body going through the cold."},
	{"id": "nettles", "held": "nettles", "kind": "forage", "name": "Stinging Nettles", "icon": "leafy", "tint": "5a8a3a", "skill": "Bushcrafting", "level": 1, "difficulty": 1, "price": 2,
		"desc": "Young spring nettle tops, picked with a sleeve over your hand. Better in a soup than raw."},
	{"id": "fiddleheads", "held": "fiddleheads", "kind": "forage", "name": "Fiddleheads", "icon": "fern", "tint": "7aa04a", "skill": "Bushcrafting", "level": 1, "difficulty": 1, "price": 3,
		"desc": "Curled fern shoots from the wet spring ground."},
	{"id": "salmonberries", "held": "salmonberries", "kind": "forage", "name": "Salmonberries", "icon": "berry", "tint": "e8803a", "skill": "Bushcrafting", "level": 1, "difficulty": 1, "price": 3, "tags": ["berries"],
		"desc": "Soft orange berries from the canes along the wood, in late spring and summer."},
	{"id": "blackberries", "held": "blackberries", "kind": "forage", "name": "Blackberries", "icon": "berry", "tint": "3a2a4a", "skill": "Bushcrafting", "level": 1, "difficulty": 1, "price": 3, "tags": ["berries"],
		"desc": "From the brambles that take every fence they can, late summer into autumn."},
	{"id": "rosehips", "held": "rosehips", "kind": "forage", "name": "Rose Hips", "icon": "hip", "tint": "c83a2a", "skill": "Bushcrafting", "level": 1, "difficulty": 1, "price": 2,
		"desc": "Red hips from the wild roses, left on the canes through autumn and winter. They make a warming tea."},
	{"id": "chanterelles", "held": "chanterelles", "kind": "forage", "name": "Chanterelles", "icon": "mushroom", "tint": "e8a83a", "skill": "Bushcrafting", "level": 2, "difficulty": 2, "price": 7, "tags": ["mushrooms"],
		"desc": "Golden, smelling faintly of apricots, under the firs after the autumn rain."},
	{"id": "yellowfoot", "held": "yellowfoot", "kind": "forage", "name": "Yellowfoot", "icon": "mushroom", "tint": "b89a50", "skill": "Bushcrafting", "level": 2, "difficulty": 1, "price": 5, "tags": ["mushrooms"],
		"desc": "The winter chanterelle: thin brown caps on yellow stems, in the moss when the rest have gone."},
	{"id": "huckleberries", "held": "huckleberries", "kind": "forage", "name": "Huckleberries", "icon": "berry", "tint": "8a2a4a", "skill": "Bushcrafting", "level": 3, "difficulty": 1, "price": 4, "tags": ["berries"],
		"desc": "Tart red huckleberries from the old stumps in summer."},
	{"id": "oyster_mushrooms", "held": "oyster_mushrooms", "kind": "forage", "name": "Oyster Mushrooms", "icon": "mushroom", "tint": "d8d0c0", "skill": "Bushcrafting", "level": 3, "difficulty": 2, "price": 6, "tags": ["mushrooms"],
		"desc": "Grey shelves on the dead alders, in the wet of winter and spring."},
	{"id": "morels", "held": "morels", "kind": "forage", "name": "Morels", "icon": "mushroom", "tint": "8a6a4a", "skill": "Bushcrafting", "level": 4, "difficulty": 2, "price": 10, "tags": ["mushrooms"],
		"desc": "Honeycombed caps, there one spring morning and gone the next."},
	{"id": "ghost_pipe", "held": "ghost_pipe", "kind": "forage", "name": "Ghost Pipe", "icon": "pipe", "tint": "eeeef0", "skill": "Bushcrafting", "level": 5, "difficulty": 1, "price": 14, "inedible": true,
		"desc": "A waxy white plant with no green in it, nodding in the deep shade. Steeped, it is an old remedy for the nerves."},
	# Cooked at the fire or preserved in the smokehouse.
	{"id": "trail_ration", "held": "trail_ration", "kind": "cooked", "name": "Trail Ration", "icon": "hash", "tint": "c8a060", "skill": "Cooking", "level": 2, "difficulty": 2, "price": 10,
		"desc": "An egg and a turnip baked hard in a crust. It keeps, and a frightened walker in the Rookery Wood steadies when they eat one."},
	{"id": "bread", "held": "bread", "kind": "cooked", "name": "Farmhouse Bread", "icon": "hash", "tint": "c89a58", "skill": "Cooking", "level": 3, "difficulty": 3, "price": 14,
		"desc": "A loaf of the mill's flour and an egg, baked at the fire. It keeps, and on a trek a walker who has run out of rations takes heart from it."},
	{"id": "fish_meal", "held": "fish_meal", "kind": "cooked", "name": "Grilled Fish", "icon": "grilled", "tint": "c8864a", "skill": "Cooking", "level": 0, "difficulty": 1, "price": 8,
		"desc": "A fish grilled over a small fire."},
	{"id": "turnip_hash", "held": "turnip_hash", "kind": "cooked", "name": "Turnip Hash", "icon": "hash", "tint": "b98a5a", "skill": "Cooking", "level": 0, "difficulty": 1, "price": 8,
		"desc": "Turnips fried in a pan over the fire."},
	{"id": "baked_potato", "held": "baked_potato", "kind": "cooked", "name": "Baked Potato", "icon": "potato", "tint": "a8783a", "skill": "Cooking", "level": 1, "difficulty": 1, "price": 9, "effect": {"warm": 10},
		"desc": "A potato baked in the embers. It warms your hands before it warms the rest of you."},
	{"id": "rosehip_tea", "held": "rosehip_tea", "kind": "cooked", "name": "Rose Hip Tea", "icon": "tea", "tint": "c84a3a", "skill": "Cooking", "level": 1, "difficulty": 1, "price": 8, "verb": "Drink", "effect": {"warm": 15, "water": 20, "calm": 4},
		"desc": "Hips steeped in boiling water. Sour, red, and warming on a winter night."},
	{"id": "nettle_soup", "held": "nettle_soup", "kind": "cooked", "name": "Nettle Soup", "icon": "dish", "tint": "5a8a3a", "skill": "Cooking", "level": 1, "difficulty": 2, "price": 10, "effect": {"warm": 10, "water": 15},
		"desc": "Nettle tops wilted in broth. The sting goes in the pot."},
	{"id": "smoked_fish", "held": "smoked_fish", "kind": "cooked", "name": "Smoked Fish", "icon": "smoked", "tint": "9a5a2e", "skill": "Cooking", "level": 2, "difficulty": 2, "price": 11,
		"desc": "Fish smoked in the smokehouse. It keeps in the pack."},
	{"id": "dried_turnip", "held": "dried_turnip", "kind": "cooked", "name": "Dried Turnip", "icon": "dried", "tint": "d8c48a", "skill": "Farming", "level": 2, "difficulty": 2, "price": 9,
		"desc": "Turnip slices dried in the smokehouse. They keep in the pack."},
	{"id": "pea_soup", "held": "pea_soup", "kind": "cooked", "name": "Pea Soup", "icon": "dish", "tint": "9ab850", "skill": "Cooking", "level": 2, "difficulty": 2, "price": 12, "effect": {"warm": 15},
		"desc": "Peas simmered down thick enough to stand a spoon in."},
	{"id": "fiddlehead_fry", "held": "fiddlehead_fry", "kind": "cooked", "name": "Fiddlehead Fry", "icon": "fern", "tint": "6a8a3a", "skill": "Cooking", "level": 2, "difficulty": 2, "price": 14,
		"desc": "Fiddleheads fried with an egg. A taste of the first warm week."},
	{"id": "bramble_jam", "held": "bramble_jam", "kind": "cooked", "name": "Bramble Jam", "icon": "jar", "tint": "6a2a4a", "skill": "Cooking", "level": 2, "difficulty": 2, "price": 10, "effect": {"calm": 6},
		"desc": "Berries boiled down and sealed in the smokehouse. A spoonful tastes of a better summer. It keeps."},
	{"id": "pumpkin_soup", "held": "pumpkin_soup", "kind": "cooked", "name": "Pumpkin Soup", "icon": "soup", "tint": "e0822a", "skill": "Cooking", "level": 3, "difficulty": 3, "price": 12, "effect": {"warm": 10},
		"desc": "Pumpkin simmered until soft."},
	{"id": "canned_turnip", "held": "canned_turnip", "kind": "cooked", "name": "Canned Turnip", "icon": "canned", "tint": "9fb7c9", "skill": "Cooking", "level": 3, "difficulty": 3, "price": 10,
		"desc": "Turnips sealed in a tin in the smokehouse. They keep in the pack."},
	{"id": "fish_stew", "held": "fish_stew", "kind": "cooked", "name": "Fish Stew", "icon": "fish_stew", "tint": "9a5a3a", "skill": "Cooking", "level": 3, "difficulty": 3, "price": 13, "effect": {"warm": 10},
		"desc": "A thick stew of fish and turnips."},
	{"id": "colcannon", "held": "colcannon", "kind": "cooked", "name": "Colcannon", "icon": "dish", "tint": "d8d0a0", "skill": "Cooking", "level": 3, "difficulty": 3, "price": 18, "effect": {"warm": 10},
		"desc": "Potatoes mashed with kale and goat's milk."},
	{"id": "leek_soup", "held": "leek_soup", "kind": "cooked", "name": "Leek and Potato Soup", "icon": "dish", "tint": "c8d0a0", "skill": "Cooking", "level": 3, "difficulty": 3, "price": 20, "effect": {"warm": 25, "water": 10},
		"desc": "The winter soup: leeks and potatoes, simmered until the windows fog."},
	{"id": "roast_roots", "held": "roast_roots", "kind": "cooked", "name": "Roast Roots", "icon": "root", "tint": "c8904a", "skill": "Cooking", "level": 3, "difficulty": 3, "price": 22, "effect": {"warm": 15},
		"desc": "Parsnips and a turnip roasted in the coals until they catch at the edges."},
	{"id": "bullhead_fry", "held": "bullhead_fry", "kind": "cooked", "name": "Bullhead Fry", "icon": "grilled", "tint": "a8783a", "skill": "Cooking", "level": 3, "difficulty": 2, "price": 16, "effect": {"warm": 10},
		"desc": "A night fish rolled in cornmeal and fried. Best eaten with the lamp lit."},
	{"id": "dried_mushrooms", "held": "dried_mushrooms", "kind": "cooked", "name": "Dried Mushrooms", "icon": "mushroom", "tint": "8a6a3a", "skill": "Cooking", "level": 3, "difficulty": 2, "price": 12, "effect": {"nerve": 10},
		"desc": "Mushrooms strung up in the smokehouse until they rattle. They keep, and a walker chews them for courage."},
	{"id": "fermented_turnip", "held": "fermented_turnip", "kind": "cooked", "name": "Fermented Turnip", "icon": "fermented", "tint": "a6c26a", "skill": "Cooking", "level": 4, "difficulty": 3, "price": 11,
		"desc": "Turnips fermented in a jar in the smokehouse. They keep in the pack."},
	{"id": "corn_chowder", "held": "corn_chowder", "kind": "cooked", "name": "Corn Chowder", "icon": "dish", "tint": "e8c870", "skill": "Cooking", "level": 4, "difficulty": 3, "price": 24, "effect": {"warm": 20},
		"desc": "Corn, potato and milk, thick and sweet."},
	{"id": "forager_stew", "held": "forager_stew", "kind": "cooked", "name": "Forager's Stew", "icon": "dish", "tint": "8a6a4a", "skill": "Cooking", "level": 4, "difficulty": 3, "price": 22, "effect": {"nerve": 25, "warm": 10},
		"desc": "Wild mushrooms and a leek. Eaten on a trek, it steadies the walker as well as you."},
	{"id": "garlic_trout", "held": "garlic_trout", "kind": "cooked", "name": "Garlic Trout", "icon": "grilled", "tint": "d89a6a", "skill": "Cooking", "level": 4, "difficulty": 3, "price": 26, "effect": {"calm": 6},
		"desc": "A trout baked with a whole head of garlic. The house smells of it all night, and nothing comes close to the window."},
	{"id": "smoked_lamprey", "held": "smoked_lamprey", "kind": "cooked", "name": "Smoked Lamprey", "icon": "smoked", "tint": "4a3a3a", "skill": "Cooking", "level": 4, "difficulty": 3, "price": 34, "effect": {"warm": 10},
		"desc": "An old delicacy, black and oily. Better not to look at the mouth. It keeps."},
	{"id": "apple_crumble", "held": "apple_crumble", "kind": "cooked", "name": "Apple Crumble", "icon": "pie", "tint": "c89a58", "skill": "Cooking", "level": 4, "difficulty": 3, "price": 22, "effect": {"calm": 8},
		"desc": "Orchard apples under a crumble of the mill's flour."},
	{"id": "hearty_stew", "held": "hearty_stew", "kind": "cooked", "name": "Hearty Stew", "icon": "hearty", "tint": "b5602a", "skill": "Cooking", "level": 5, "difficulty": 4, "price": 20, "effect": {"warm": 15},
		"desc": "Smoked fish and turnips, simmered for hours."},
	{"id": "pumpkin_pie", "held": "pumpkin_pie", "kind": "cooked", "name": "Pumpkin Pie", "icon": "pie", "tint": "e0822a", "skill": "Cooking", "level": 5, "difficulty": 4, "price": 30, "effect": {"calm": 10},
		"desc": "Spiced pumpkin in a crust. It tastes like a holiday nobody here keeps any more."},
	{"id": "berry_cobbler", "held": "berry_cobbler", "kind": "cooked", "name": "Berry Cobbler", "icon": "pie", "tint": "8a3a5a", "skill": "Cooking", "level": 5, "difficulty": 4, "price": 30, "effect": {"calm": 10, "nerve": 15},
		"desc": "Berries baked under a sweet crust. Shared on a trek, it brings a smile out of anyone."},
	{"id": "ghost_tincture", "held": "ghost_tincture", "kind": "cooked", "name": "Ghost Pipe Tincture", "icon": "tea", "tint": "d8d8e8", "skill": "Bushcrafting", "level": 5, "difficulty": 3, "price": 40, "verb": "Drink", "effect": {"calm": 20, "nerve": 40},
		"desc": "Ghost pipe steeped with rose hips until the water turns violet. It settles the nerves, yours or a walker's, like nothing else."},
	{"id": "sturgeon_steak", "held": "sturgeon_steak", "kind": "cooked", "name": "Sturgeon Steak", "icon": "grilled", "tint": "b8987a", "skill": "Cooking", "level": 6, "difficulty": 5, "price": 80, "effect": {"warm": 20, "calm": 10},
		"desc": "A thick steak of the old fish, seared with garlic. A meal to remember."},
]

## How each cooked food is made. station is "fire" (Craft, Cooking) or "smokehouse" (the smokehouse panel).
## needs are pack keys (turnips means the turnips themselves), materials such as wood and fiber, or a group
## from group(): any_fish, berries, mushrooms. A group is spent cheapest first.
## The food's own skill and level decide when it can be made, and the skill gets xp for each one.
const RECIPES := [
	{"food": "fish_meal", "station": "fire", "needs": {"any_fish": 1, "wood": 1}, "xp": 15},
	{"food": "trail_ration", "station": "fire", "needs": {"eggs": 1, "turnips": 1, "wood": 1}, "xp": 12},
	{"food": "bread", "station": "fire", "needs": {"flour": 2, "eggs": 1, "wood": 1}, "xp": 20},
	{"food": "turnip_hash", "station": "fire", "needs": {"turnips": 2, "wood": 1}, "xp": 10},
	{"food": "baked_potato", "station": "fire", "needs": {"potatoes": 1, "wood": 1}, "xp": 10},
	{"food": "rosehip_tea", "station": "fire", "needs": {"rosehips": 3, "wood": 1}, "xp": 10},
	{"food": "nettle_soup", "station": "fire", "needs": {"nettles": 2, "wood": 1}, "xp": 12},
	{"food": "pea_soup", "station": "fire", "needs": {"peas": 3, "wood": 1}, "xp": 14},
	{"food": "fiddlehead_fry", "station": "fire", "needs": {"fiddleheads": 2, "eggs": 1, "wood": 1}, "xp": 14},
	{"food": "pumpkin_soup", "station": "fire", "needs": {"pumpkins": 2, "wood": 1}, "xp": 18},
	{"food": "fish_stew", "station": "fire", "needs": {"any_fish": 1, "turnips": 2, "wood": 1}, "xp": 18},
	{"food": "colcannon", "station": "fire", "needs": {"potatoes": 2, "kale": 1, "milk": 1, "wood": 1}, "xp": 20},
	{"food": "leek_soup", "station": "fire", "needs": {"leeks": 1, "potatoes": 2, "wood": 1}, "xp": 20},
	{"food": "roast_roots", "station": "fire", "needs": {"parsnips": 2, "turnips": 1, "wood": 1}, "xp": 20},
	{"food": "bullhead_fry", "station": "fire", "needs": {"bullhead": 1, "corn": 1, "wood": 1}, "xp": 18},
	{"food": "corn_chowder", "station": "fire", "needs": {"corn": 2, "potatoes": 1, "milk": 1, "wood": 1}, "xp": 22},
	{"food": "forager_stew", "station": "fire", "needs": {"mushrooms": 2, "leeks": 1, "wood": 1}, "xp": 22},
	{"food": "garlic_trout", "station": "fire", "needs": {"trout": 1, "garlic": 1, "wood": 1}, "xp": 24},
	{"food": "apple_crumble", "station": "fire", "needs": {"apples": 2, "flour": 1, "wood": 1}, "xp": 22},
	{"food": "hearty_stew", "station": "fire", "needs": {"smoked_fish": 1, "turnips": 2, "wood": 1}, "xp": 26},
	{"food": "pumpkin_pie", "station": "fire", "needs": {"pumpkins": 1, "flour": 1, "eggs": 1, "wood": 1}, "xp": 26},
	{"food": "berry_cobbler", "station": "fire", "needs": {"berries": 3, "flour": 1, "eggs": 1, "wood": 1}, "xp": 26},
	{"food": "ghost_tincture", "station": "fire", "needs": {"ghost_pipe": 1, "rosehips": 2, "wood": 1}, "xp": 30},
	{"food": "sturgeon_steak", "station": "fire", "needs": {"sturgeon": 1, "garlic": 1, "wood": 1}, "xp": 40},
	{"food": "smoked_fish", "station": "smokehouse", "needs": {"any_fish": 1, "wood": 1}, "xp": 12},
	{"food": "dried_turnip", "station": "smokehouse", "needs": {"turnips": 2}, "xp": 10},
	{"food": "canned_turnip", "station": "smokehouse", "needs": {"turnips": 2, "fiber": 1}, "xp": 14},
	{"food": "fermented_turnip", "station": "smokehouse", "needs": {"turnips": 2, "wood": 1}, "xp": 16},
	{"food": "bramble_jam", "station": "smokehouse", "needs": {"berries": 3, "fiber": 1}, "xp": 14},
	{"food": "dried_mushrooms", "station": "smokehouse", "needs": {"mushrooms": 2}, "xp": 14},
	{"food": "smoked_lamprey", "station": "smokehouse", "needs": {"lamprey": 1, "wood": 1}, "xp": 20},
]

## Recipe groups and the words the panels use for them.
const GROUP_LABELS := {"any_fish": "fish (any)", "berries": "berries (any)", "mushrooms": "mushrooms (any)", "crops": "crops (any)", "forage": "forage (any)"}


static func find(id: String) -> Dictionary:
	for f in LIST:
		if f["id"] == id:
			return f
	return {}


## The food held under a pack key, or an empty dictionary.
static func by_held(key: String) -> Dictionary:
	for f in LIST:
		if f["held"] == key:
			return f
	return {}


static func recipe(id: String) -> Dictionary:
	for r in RECIPES:
		if r["food"] == id:
			return r
	return {}


static func is_group(key: String) -> bool:
	return GROUP_LABELS.has(key)


## The pack keys in a group: any_fish (every fish), crops (every crop but apples), forage, or a tag.
static func group(key: String) -> Array:
	var out: Array = []
	for f in LIST:
		var hit := false
		match key:
			"any_fish":
				hit = f["kind"] == "fish"
			"forage":
				hit = f["kind"] == "forage"
			"crops":
				hit = f["kind"] == "crop" and f["id"] != "apple"
			_:
				hit = (f.get("tags", []) as Array).has(key)
		if hit:
			out.append(str(f["held"]))
	return out


static func of_kind(kind: String) -> Array:
	var out: Array = []
	for f in LIST:
		if f["kind"] == kind:
			out.append(f)
	return out


static func food_restore(f: Dictionary) -> float:
	return 10.0 + 12.0 * float(f["difficulty"]) + 3.0 * float(f["level"])


static func sanity_restore(f: Dictionary) -> float:
	return 1.0 + float(f["difficulty"]) + 0.5 * float(f["level"]) + float(f.get("effect", {}).get("calm", 0))


static func hp_restore(f: Dictionary) -> int:
	return int(f["difficulty"])
