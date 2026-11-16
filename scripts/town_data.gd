class_name TownData
extends RefCounted

# Wicker Cove's people, shops and the one order (CCH-WICKER-COVE-ALPHA-001). All of it is data, so a name, a price
# or a line can change here without touching TownSystem. Thomas and Edith are the alpha's working names from the
# design bible (WICKER_COVE_LIVED_IN_DISTRICT_BIBLE.md), not a final cast: rename them here and in Portraits.NAMES.
#
# Nothing here says why the fog is there or when it came. People disagree about it; that is all.

const TRAVEL_HOURS := 0.5      # the walk down the hill road (and back up): half an hour of the day each way
const OPEN_FROM := 2           # the road is open from the second day, after the first day's house and first night
const ROAD_CLOSES := 20.0      # the gate won't take you down after this hour: home is up a steep road
const LATE_HOUR := 19.0        # in the village after this, people mention the walk home

# The residents. who is the dialogue box's speaker id (Portraits draws them).
const PEOPLE := {
	"thomas": {"name": "Thomas Bellweather", "short": "Thomas", "where": "the general store"},
	"edith": {"name": "Edith Vale", "short": "Edith", "where": "the inn"},
}

# Shops. Each sells a few things a day (stock comes back each morning) and buys some kinds of food, up to a
# number a day, at the farm stand's own full price (StallSystem._food_price). Selling here is a second outlet for
# a day's surplus, not a better one: the walk costs an hour of the day there and back.
#   item: an inventory key, or a materials key when "mat" is true.
const SHOPS := {
	"store": {
		"tab": "Store", "who": "thomas",
		"sells": [
			{"item": "lamp_oil", "mat": true, "name": "Lamp oil", "price": 9, "stock": 3, "about": "A flask for the lantern on a trek. The catalog's is a coin cheaper, but comes tomorrow."},
			{"item": "seeds", "name": "Turnip seeds", "price": 3, "stock": 6, "about": "One packet, one turnip's worth. They grow in any season."},
			{"item": "flour", "mat": true, "name": "Flour", "price": 6, "stock": 3, "about": "A bag of flour for bread, when the cart has been."},
			{"item": "rope", "mat": true, "name": "Rope", "price": 7, "stock": 2, "about": "A good length of hemp rope. It takes a walker over a flooded hollow."},
			{"item": "bandage", "name": "Bandage", "price": 12, "stock": 2, "about": "Clean linen and a little salve."},
			{"item": "trail_ration", "name": "Trail ration", "price": 14, "stock": 2, "about": "Hard bread, cheese and dried fruit, wrapped for walking."},
		],
		"buys": ["crop", "animal"], "buys_name": "produce", "buys_max": 12,
	},
	"market": {
		"tab": "Fish market", "who": "",
		"sells": [
			{"item": "fish", "name": "Yellow Perch", "price": 8, "stock": 3, "about": "This morning's. It won't keep past tonight; cook it or eat it."},
			{"item": "smoked_fish", "name": "Smoked Fish", "price": 15, "stock": 2, "about": "Split, salted and smoked over alder. It keeps."},
		],
		"buys": ["fish"], "buys_name": "fish", "buys_max": 8,
	},
	"inn": {
		"tab": "The inn", "who": "edith",
		"sells": [
			{"item": "fish_stew", "name": "Fish Stew", "price": 17, "stock": 2, "about": "Edith's stew, in a lidded pot to carry home. Hot and filling."},
			{"item": "bread", "name": "Farmhouse Bread", "price": 18, "stock": 2, "about": "A loaf, when the flour has come."},
			{"item": "rosehip_tea", "name": "Rose Hip Tea", "price": 11, "stock": 2, "about": "A stoppered jar of it, sharp and warming."},
		],
		"buys": [], "buys_name": "", "buys_max": 0,
	},
}

# The one order for the alpha: posted on the store's notice board, handed in at Thomas's counter, all at once.
# It pays a little over the stand's price for the trouble of the walk. Done once; not repeated in the alpha.
const ORDERS := [
	{"id": "thomas_turnips", "who": "thomas", "title": "Turnips for the store",
		"want": {"crops": 6}, "reward": {"coins": 70},
		"board": "WANTED: six good turnips, for the store. 70 coins on delivery, all six at once. Ask at the counter. T. Bellweather",
		"thanks": "\"Six. Good ones, too.\" He weighs them anyway, out of habit, and counts the coins out twice."},
]

# The first time you meet each of them: a short scene. Pages are {who, expr, text}; who "" is narration.
const MEET := {
	"thomas": [
		{"who": "", "text": "A man in a canvas apron is writing in a ledger behind the half-door. He finishes the line before he looks up."},
		{"who": "thomas", "expr": "neutral", "text": "\"You'll be from up the Hollow road. Nobody else comes down it with that much mud on their boots.\""},
		{"who": "thomas", "expr": "smile", "text": "\"Thomas Bellweather. The store, the accounts, and whatever else wants writing down.\""},
		{"who": "thomas", "expr": "neutral", "text": "\"Most days I can tell you what's coming in. It's what's going out that's harder to keep track of.\""},
		{"who": "thomas", "expr": "neutral", "text": "\"I'll buy produce, if you've some to spare. And there's a note on the board about turnips, if you grow them.\""},
	],
	"edith": [
		{"who": "", "text": "The room smells of woodsmoke and fish stock. The woman behind the counter is drying a mug that is already dry."},
		{"who": "edith", "expr": "smile", "text": "\"Come in, shut the door, the fog gets in otherwise. I'm Edith. This is mine, more or less.\""},
		{"who": "edith", "expr": "neutral", "text": "\"The upstairs rooms aren't ready. But the fire works, and there's a table if you need one.\""},
		{"who": "edith", "expr": "neutral", "text": "\"I do a stew most days, and bread when the flour comes. Nothing fancy. It's hot, and it's fair.\""},
	],
}

# Everyday words, one picked by the day. Seasonal and late lines come first when they apply.
const LINES := {
	"thomas": [
		"\"The boats went out at five. Two came back with something worth weighing. That's a good morning, lately.\"",
		"\"Flour's late again. It comes when the cart comes, and the cart comes when it likes.\"",
		"\"I keep two ledgers. One for what's sold, one for what folk say they'll pay for. The second one's thicker.\"",
		"\"Mind the step going out. I've been meaning to fix it since spring. Which spring, I couldn't tell you.\"",
	],
	"edith": [
		"\"The roof over the back room lets in more than it keeps out. I've a bucket under it. The bucket's doing well.\"",
		"\"Sit by the fire if you like. Nobody's going to rush you. There's nobody here to do it.\"",
		"\"Two of the crews were arguing about the fog again. One says it used to lift in high summer. The other says it never has. They're brothers. They argue about everything.\"",
		"\"Someone left a pair of boots drying by my stove three days ago. I've not seen who. They're good boots.\"",
	],
}
const SEASON_LINES := {
	"thomas": {
		"Autumn": "\"Everyone wants lamp oil this time of year. The evenings come in early, and nobody likes the fog in the dark.\"",
		"Winter": "\"Winter's quiet. Fewer boats, fewer callers, more people standing by my stove pretending to choose.\"",
		"Spring": "\"Spring, and someone's painting a boat. Every year somebody does. It doesn't change the fog, but it's nice to look at.\"",
		"Summer": "\"Summer brings the fish in and keeps everyone indoors gutting them. Fog's the same, only warmer.\"",
	},
	"edith": {
		"Autumn": "\"Autumn, I start putting things by. Jars on every shelf. It feels like getting ready, though for what I couldn't say.\"",
		"Winter": "\"Winter nights, half the village ends up in here. Not for my cooking. For my fire.\"",
		"Spring": "\"Spring cleaning. I found a chair upstairs I didn't know I had. It doesn't mean I'll find the money for the roof.\"",
		"Summer": "\"Summer's when the crews eat here. Loud, hungry, and they pay in coin, mostly.\"",
	},
}
const LATE_LINES := {
	"thomas": "\"Getting on. I'd start up that hill before the light goes, if I were you. It's steep in the dark.\"",
	"edith": "\"It's late for the hill road. I'd not walk it in the dark, but you're not me.\"",
}
# After you've traded with them (the first time it applies on a later day), and after the order is done.
const CALLBACK_LINES := {
	"thomas": "\"Back again. I've put you in the book under 'reliable'. Don't let it go to your head.\"",
	"edith": "\"You came back. People mostly do, once they've had the stew. I take it as a compliment.\"",
}
const ORDER_DONE_LINE := "\"Those turnips went into Edith's pot by suppertime. She says thank you, in her way, which is complaining about my prices.\""

# What the things in the village say when you face them and press the hand button.
const LOOK := {
	"S": "WICKER COVE, in white paint. The paint is newer than the board.",
	"N": "",   # the notice board opens its own panel
	"x": "Crates and barrels, stencilled with the names of boats. Some of the names have been painted over.",
	"n": "Nets hung to dry. They've been mended so many times the mending is most of the net.",
	"b": "A dory, tied fore and aft. Somebody has patched the hull with a plank that doesn't match.",
	"o": "An iron bollard, worn smooth where the ropes go round.",
	"L": "A lamp post. Someone fills and trims these every evening; you never see who.",
	"B": "You sit a moment. The water slaps the pilings. Out in the fog a rope creaks against a post, and keeps creaking.",
	"pier": "The end of the pier. The fog starts a boat's length out. You can hear the sea well past where you can see it.",
	"house_a": "Smoke from the chimney, and a smell of frying. Someone is home.",
	"house_b": "Washing hung under the eaves, out of the wet. It will not dry, but it's out of the wet.",
	"house_c": "Boards over the windows, nailed from the outside. The step has been swept anyway.",
	"house_d": "A lamp in the window, though it's day. A cat watches you from the sill.",
	"market": "",   # the fish market opens its panel
	"store": "",
	"inn": "The inn. Warm light in the windows, and the door on the latch.",
	"T": "Firs, dripping with the fog.",
	"~": "Grey water, flat and cold. The fog sits on it like a lid.",
	"hearth": "The inn's fire, banked high. Somebody has put a kettle at the edge of it.",
	"table": "A scrubbed table, ring-marked by a hundred mugs.",
	"p": "Barrels of something. Edith's handwriting on the lids: ONIONS, SALT, DO NOT.",
}
const ARRIVE_FIRST := "You smelled the sea before you saw the water."
const MARKET_SLATE := "Nobody at the stall. A slate reads: PRICES AS MARKED. COINS IN THE TIN. BACK WHEN THE TIDE TURNS."
