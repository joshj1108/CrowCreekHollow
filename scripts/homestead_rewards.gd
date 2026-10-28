class_name HomesteadRewards
extends RefCounted

# What the daily chores and needs give back, so looking after the farm and yourself pays rather than
# only staving off a loss:
# - Hale: with food, water and warmth all high, skills train faster.
# - Finds: the day's tidy and first mended board each turn up something small.
# - Kept well: each night with every chore done brings odd-job coins, and every seventh a crow charm.
# - Pastimes: a finished desk game lifts sanity and wins back some of the lost sanity limit.

var m: MainGame

const HALE_NEED := 70.0         # food, water and warmth all at least this
const HALE_XP := 1.2            # skill XP while hale
const KEPT_COINS_PER_NIGHT := 1 # odd-job coins per night of the streak
const KEPT_COINS_MAX := 8
const KEPT_CHARM_EVERY := 7     # a crow charm on the step every this many clean nights in a row
const PASTIME_SANITY := 3.0
const PASTIME_RELIEF := 2.0     # sanity limit won back per finished desk game

# Each find: its weight, what it gives, and how it reads. "amount" is a range for coins.
const TIDY_FINDS := [
	{"weight": 4, "coins": [3, 8], "text": "Under the rug you find %d coins."},
	{"weight": 2, "firewood": 2, "text": "Behind the stove you find two good split logs. +2 firewood."},
	{"weight": 2, "seeds": 2, "text": "A paper twist of turnip seed was tucked in a drawer. +2 turnip seeds."},
	{"weight": 1, "feathers": 1, "text": "A black feather on the windowsill, though the window was shut. +1 crow feather."},
	{"weight": 1, "sanity": 5.0, "text": "A pressed flower falls out of an old book. It makes you smile. +5 sanity."},
]
const MEND_FINDS := [
	{"weight": 3, "coins": [2, 6], "text": "Behind the old board, someone hid %d coins."},
	{"weight": 3, "sticks": 2, "text": "The offcuts make good kindling. +2 sticks."},
	{"weight": 2, "resin": 1, "text": "A bead of resin wells from the new board. +1 resin."},
	{"weight": 1, "feathers": 1, "text": "A crow feather was wedged in the gap. +1 crow feather."},
]

var _rng := RandomNumberGenerator.new()


func _init(main: MainGame) -> void:
	m = main


func _is_hale() -> bool:
	return m.food >= HALE_NEED and m.water >= HALE_NEED and m.warmth >= HALE_NEED


# XP after the hale bonus.
func _xp(amount: int) -> int:
	return roundi(amount * HALE_XP) if _is_hale() else amount


# A small find for a chore. Returns the sentence to add to the chore's message.
func _find(table: Array, salt: String) -> String:
	_rng.seed = hash([m.day, salt, m.stats["tidied"], m.stats["mended"]])
	var weights := PackedFloat32Array()
	for f in table:
		weights.append(float(f["weight"]))
	var f: Dictionary = table[_rng.rand_weighted(weights)]
	if f.has("coins"):
		var coins := _rng.randi_range(int(f["coins"][0]), int(f["coins"][1]))
		m.money += coins
		return str(f["text"]) % coins
	for mat in ["feathers", "sticks", "resin"]:
		if f.has(mat):
			m.materials[mat] += int(f[mat])
	if f.has("firewood"):
		m.inventory["firewood"] += int(f["firewood"])
	if f.has("seeds"):
		m.inventory["seeds"] += int(f["seeds"])
	if f.has("sanity"):
		m.sanity_sys._change_sanity(float(f["sanity"]))
	return str(f["text"])


func _tidy_find() -> String:
	return _find(TIDY_FINDS, "tidy")


func _mend_find() -> String:
	return _find(MEND_FINDS, "mend")


# The morning after a night with every chore done. Returns the note for the morning message.
func _kept_well() -> String:
	var coins := mini(KEPT_COINS_PER_NIGHT * m.clean_nights, KEPT_COINS_MAX)
	m.money += coins
	var note := " Word of a well-kept farm gets round: %d coins for odd jobs (%d night%s in a row)." % [coins, m.clean_nights, "" if m.clean_nights == 1 else "s"]
	if m.clean_nights % KEPT_CHARM_EVERY == 0:
		m.inventory["crow_charm"] += 1
		note += " Someone left a crow charm on the step."
	return note


# A finished desk game: sanity now, and some of the lost limit back, boredom's first.
func _pastime_done() -> String:
	var relief := PASTIME_RELIEF
	var from_boredom := minf(relief, m.boredom_loss)
	m.boredom_loss -= from_boredom
	relief -= from_boredom
	var from_penalty := mini(int(relief), m.sanity_penalty)
	m.sanity_penalty -= from_penalty
	var won := from_boredom + from_penalty
	m.sanity_sys._change_sanity(PASTIME_SANITY)
	if won > 0.0:
		return " +%d sanity, and your limit recovers by %d." % [int(PASTIME_SANITY), int(won)]
	return " +%d sanity." % int(PASTIME_SANITY)
