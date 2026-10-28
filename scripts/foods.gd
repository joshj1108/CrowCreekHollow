class_name Foods
extends RefCounted

## Every food the farm grows, gathers, or makes. The pack counts each one under its held key.
## A food's difficulty (1 to 5) and the level needed to obtain it set what it restores, so harder and
## later food fills you more:
##   food    = 10 + 12 x difficulty + 3 x level
##   sanity  = 1 + difficulty + level / 2
##   HP      = difficulty
## Cooked foods are named for what made them and have a picture of their own.

const LIST := [
	{"id": "turnip", "held": "crops", "name": "Turnip", "icon": "turnip", "tint": "8fd16b", "skill": "Farming", "level": 0, "difficulty": 1, "price": 0,
		"desc": "Harvested from the field. Eat it raw, or cook it into a meal."},
	{"id": "corn", "held": "corn", "name": "Corn", "icon": "corn", "tint": "e8c440", "skill": "Farming", "level": 2, "difficulty": 1, "price": 0,
		"desc": "An ear of corn in its husk. Eat it raw, or feed it to the animals. Corn does not keep in the cellar."},
	{"id": "pumpkin", "held": "pumpkins", "name": "Pumpkin", "icon": "pumpkin", "tint": "e0822a", "skill": "Farming", "level": 3, "difficulty": 2, "price": 0,
		"desc": "A large pumpkin. Eat it raw, or cook it. Pumpkins do not keep in the cellar."},
	{"id": "egg", "held": "eggs", "name": "Egg", "icon": "egg", "tint": "f2ead2", "skill": "Farming", "level": 0, "difficulty": 1, "price": 0,
		"desc": "Laid by the hens."},
	{"id": "milk", "held": "milk", "name": "Milk", "icon": "milk", "tint": "b8d4e8", "skill": "Farming", "level": 0, "difficulty": 1, "price": 0, "verb": "Drink",
		"desc": "Milked from the goats."},
	{"id": "trail_ration", "held": "trail_ration", "name": "Trail Ration", "icon": "hash", "tint": "c8a060", "skill": "Cooking", "level": 2, "difficulty": 2, "price": 10,
		"desc": "An egg and a turnip baked hard in a crust. It keeps, and a frightened walker in the Rookery Wood steadies when they eat one."},
	{"id": "apple", "held": "apples", "name": "Apple", "icon": "turnip", "tint": "b8442e", "skill": "Farming", "level": 4, "difficulty": 2, "price": 0,
		"desc": "From an apple tree grown from the drowned orchard's stock. Sharp and sweet, and it keeps."},
	{"id": "bread", "held": "bread", "name": "Farmhouse Bread", "icon": "hash", "tint": "c89a58", "skill": "Cooking", "level": 3, "difficulty": 3, "price": 14,
		"desc": "A loaf of the mill's flour and an egg, baked at the fire. It keeps, and on a trek a walker who has run out of rations takes heart from it."},
	{"id": "fish_meal", "held": "fish_meal", "name": "Grilled Fish", "icon": "grilled", "tint": "c8864a", "skill": "Cooking", "level": 0, "difficulty": 1, "price": 8,
		"desc": "A fish grilled over a small fire."},
	{"id": "turnip_hash", "held": "turnip_hash", "name": "Turnip Hash", "icon": "hash", "tint": "b98a5a", "skill": "Cooking", "level": 0, "difficulty": 1, "price": 8,
		"desc": "Turnips fried in a pan over the fire."},
	{"id": "smoked_fish", "held": "smoked_fish", "name": "Smoked Fish", "icon": "smoked", "tint": "9a5a2e", "skill": "Cooking", "level": 2, "difficulty": 2, "price": 11,
		"desc": "Fish smoked in the smokehouse. It keeps in the pack."},
	{"id": "dried_turnip", "held": "dried_turnip", "name": "Dried Turnip", "icon": "dried", "tint": "d8c48a", "skill": "Farming", "level": 2, "difficulty": 2, "price": 9,
		"desc": "Turnip slices dried in the smokehouse. They keep in the pack."},
	{"id": "pumpkin_soup", "held": "pumpkin_soup", "name": "Pumpkin Soup", "icon": "soup", "tint": "e0822a", "skill": "Cooking", "level": 3, "difficulty": 3, "price": 12,
		"desc": "Pumpkin simmered until soft."},
	{"id": "canned_turnip", "held": "canned_turnip", "name": "Canned Turnip", "icon": "canned", "tint": "9fb7c9", "skill": "Cooking", "level": 3, "difficulty": 3, "price": 10,
		"desc": "Turnips sealed in a tin in the smokehouse. They keep in the pack."},
	{"id": "fish_stew", "held": "fish_stew", "name": "Fish Stew", "icon": "fish_stew", "tint": "9a5a3a", "skill": "Cooking", "level": 3, "difficulty": 3, "price": 13,
		"desc": "A thick stew of fish and turnips."},
	{"id": "fermented_turnip", "held": "fermented_turnip", "name": "Fermented Turnip", "icon": "fermented", "tint": "a6c26a", "skill": "Cooking", "level": 4, "difficulty": 3, "price": 11,
		"desc": "Turnips fermented in a jar in the smokehouse. They keep in the pack."},
	{"id": "hearty_stew", "held": "hearty_stew", "name": "Hearty Stew", "icon": "hearty", "tint": "b5602a", "skill": "Cooking", "level": 5, "difficulty": 4, "price": 20,
		"desc": "Smoked fish and turnips, simmered for hours."},
]

## How each cooked food is made. station is "fire" (Craft, Cooking) or "smokehouse" (the smokehouse panel).
## needs are pack keys: turnips, pumpkins, fish, smoked_fish, or materials such as wood and fiber.
## The food's own skill and level decide when it can be made, and the skill gets xp for each one.
const RECIPES := [
	{"food": "fish_meal", "station": "fire", "needs": {"fish": 1, "wood": 1}, "xp": 15},
	{"food": "trail_ration", "station": "fire", "needs": {"eggs": 1, "turnips": 1, "wood": 1}, "xp": 12},
	{"food": "bread", "station": "fire", "needs": {"flour": 2, "eggs": 1, "wood": 1}, "xp": 20},
	{"food": "turnip_hash", "station": "fire", "needs": {"turnips": 2, "wood": 1}, "xp": 10},
	{"food": "pumpkin_soup", "station": "fire", "needs": {"pumpkins": 2, "wood": 1}, "xp": 18},
	{"food": "fish_stew", "station": "fire", "needs": {"fish": 1, "turnips": 2, "wood": 1}, "xp": 18},
	{"food": "hearty_stew", "station": "fire", "needs": {"smoked_fish": 1, "turnips": 2, "wood": 1}, "xp": 26},
	{"food": "smoked_fish", "station": "smokehouse", "needs": {"fish": 1, "wood": 1}, "xp": 12},
	{"food": "dried_turnip", "station": "smokehouse", "needs": {"turnips": 2}, "xp": 10},
	{"food": "canned_turnip", "station": "smokehouse", "needs": {"turnips": 2, "fiber": 1}, "xp": 14},
	{"food": "fermented_turnip", "station": "smokehouse", "needs": {"turnips": 2, "wood": 1}, "xp": 16},
]


static func find(id: String) -> Dictionary:
	for f in LIST:
		if f["id"] == id:
			return f
	return {}


static func recipe(id: String) -> Dictionary:
	for r in RECIPES:
		if r["food"] == id:
			return r
	return {}


static func food_restore(f: Dictionary) -> float:
	return 10.0 + 12.0 * float(f["difficulty"]) + 3.0 * float(f["level"])


static func sanity_restore(f: Dictionary) -> float:
	return 1.0 + float(f["difficulty"]) + 0.5 * float(f["level"])


static func hp_restore(f: Dictionary) -> int:
	return int(f["difficulty"])
