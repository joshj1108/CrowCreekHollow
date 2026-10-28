class_name EstateSystem
extends RefCounted

# What the farm's coins go to once the homestead stands: the big goals you can see.
# - House extensions (Buildings section, House tab): a cellar room, a covered porch and a second storey, each with
#   an effect of its own, and each raising the property value.
# - The house's looks: an outside paint colour, wallpaper, and furniture, which make the house a comfort (each
#   piece gives a little sanity every morning) and are drawn in the house.
# - The land deed (Desk, Tax tab): the town took Agnes Rook's bell for the tax she owed, and it can take the farm
#   the same way. Once the house is patched the clerk will sell the deed outright, paid off in instalments over
#   the next year or so; with it the tax ends for good.

var m: MainGame

const EXTENSIONS := {
	"cellar_room": {"name": "Cellar room", "stage": 2, "cost": {"coins": 700, "stone": 60, "hardwood": 20, "copper_bar": 20, "level": 5},
		"about": "A stone room dug under the house. The root cellar holds %d crops instead of %d, and keeps every crop, not only the ones that store.",
		"built": "The root cellar holds %d and keeps every crop."},
	"porch": {"name": "Covered porch", "stage": 2, "cost": {"coins": 1200, "wood": 60, "hardwood": 40, "copper_bar": 40, "level": 6},
		"about": "A deep porch on the lane side with a copper roof. Passers-by stop to talk: the farm stand takes a quarter more at full price each day, and the mornings on it give +%d sanity.",
		"built": "The stand takes a quarter more each day; +%d sanity each morning."},
	"second_storey": {"name": "Second storey", "stage": 3, "after": "porch", "cost": {"coins": 3000, "wood": 100, "hardwood": 80, "stone": 60, "copper_bar": 60, "iron_bar": 20, "feathers": 60, "level": 8},
		"about": "Bedrooms under a new roof, with feather beds. Each night's sleep gives +%d more sanity, and the night takes a tenth less, high above the field.",
		"built": "+%d sanity from each sleep; the night takes a tenth less."},
}
const CELLAR_ROOM_CAP := 80
const PORCH_SANITY := 2.0
const PORCH_DEMAND := 1.25
const STOREY_SLEEP := 6.0
const STOREY_NIGHT_MULT := 0.9
const EXTENSION_VALUE := 0.15     # each extension adds this much to the property value

# Furniture, each bought once and drawn in its room. Each piece gives +1 sanity every morning (comfort).
# room: the house stage that opens the room it stands in. spot: interior tile.
const FURNITURE := {
	"dresser": {"name": "Oak dresser", "stage": 0, "spot": Vector2i(6, 3), "cost": {"coins": 150, "hardwood": 12, "copper_bar": 2}, "about": "Drawers for the bedroom, with copper handles."},
	"feather_bed": {"name": "Feather bed", "stage": 1, "spot": Vector2i(1, 5), "cost": {"coins": 250, "hardwood": 6, "feathers": 40}, "about": "A deep mattress of crow down on the old bed. They are only feathers."},
	"armchair": {"name": "Armchair", "stage": 1, "spot": Vector2i(19, 14), "cost": {"coins": 200, "hardwood": 8, "feathers": 20}, "about": "A wing chair by the hearth."},
	"clock": {"name": "Long-case clock", "stage": 1, "spot": Vector2i(8, 13), "cost": {"coins": 350, "hardwood": 10, "copper_bar": 8, "iron_bar": 2}, "about": "A tall clock in the hall, with a copper face. It ticks through the night."},
	"painting": {"name": "A painting of the farm", "stage": 2, "spot": Vector2i(14, 12), "cost": {"coins": 400}, "about": "The farm as it was in Agnes's day, bought from a carter. Someone stands in the field."},
	"bookshelf": {"name": "Bookshelf", "stage": 3, "spot": Vector2i(12, 3), "cost": {"coins": 300, "hardwood": 16}, "about": "Shelves for the study, for almanacs and the diary."},
}
const COMFORT_SANITY := 1.0

# The outside paint, once the house is restored, and the wallpaper, once it is patched. Each change is paid for.
const PAINTS := {
	"plain": {"name": "Weathered", "color": Color(1, 1, 1)},
	"whitewash": {"name": "Whitewash", "color": Color(1.12, 1.1, 1.06)},
	"barn_red": {"name": "Barn red", "color": Color(1.15, 0.82, 0.78)},
	"sage": {"name": "Sage green", "color": Color(0.9, 1.06, 0.9)},
	"slate": {"name": "Slate blue", "color": Color(0.86, 0.94, 1.1)},
	"ochre": {"name": "Ochre", "color": Color(1.12, 1.0, 0.76)},
}
const PAINT_COST := {"coins": 200, "copper_bar": 2}   # the copper is for the pigment
const PAPERS := {
	"plain": {"name": "Bare boards", "color": Color(0, 0, 0, 0)},
	"rose": {"name": "Rose sprig", "color": Color("b07a7a")},
	"damask": {"name": "Green damask", "color": Color("5a7a5a")},
	"stripe": {"name": "Ochre stripe", "color": Color("b8964a")},
	"toile": {"name": "Blue toile", "color": Color("5a6a8a")},
}
const PAPER_COST := {"coins": 150, "fiber": 2}

# The land deed: bought from the town in instalments, from the day the house is patched.
const DEED_PRICE := 12000
const DEED_STEP := 500

var built := {}              # saved: extension id -> true
var furniture := {}          # saved: furniture id -> true
var paint := "plain"         # saved
var paper := "plain"         # saved
var deed_paid := 0           # saved: coins paid toward the deed
var deed_offered := false    # saved: the clerk's letter has come


func _init(main: MainGame) -> void:
	m = main


func _to_save() -> Dictionary:
	return {"built": built.keys(), "furniture": furniture.keys(), "paint": paint, "paper": paper, "deed_paid": deed_paid, "deed_offered": deed_offered}


func _from_save(data: Variant) -> void:
	built.clear()
	furniture.clear()
	paint = "plain"
	paper = "plain"
	deed_paid = 0
	deed_offered = false
	if typeof(data) != TYPE_DICTIONARY:
		return
	for id in data.get("built", []):
		if EXTENSIONS.has(str(id)):
			built[str(id)] = true
	for id in data.get("furniture", []):
		if FURNITURE.has(str(id)):
			furniture[str(id)] = true
	paint = str(data.get("paint", "plain")) if PAINTS.has(str(data.get("paint", ""))) else "plain"
	paper = str(data.get("paper", "plain")) if PAPERS.has(str(data.get("paper", ""))) else "plain"
	deed_paid = clampi(int(data.get("deed_paid", 0)), 0, DEED_PRICE)
	deed_offered = bool(data.get("deed_offered", false))
	m.house_roof_drawn_stage = -1   # the house is drawn again, with its extensions and paint


func _has(id: String) -> bool:
	return built.has(id)


# --- Extensions -----------------------------------------------------------------------------------

func _about(id: String) -> String:
	var e: Dictionary = EXTENSIONS[id]
	match id:
		"cellar_room":
			return str(e["about"]) % [CELLAR_ROOM_CAP, m.CELLAR_CAP]
		"porch":
			return str(e["about"]) % int(PORCH_SANITY)
	return str(e["about"]) % int(STOREY_SLEEP)


func _built_text(id: String) -> String:
	var e: Dictionary = EXTENSIONS[id]
	match id:
		"cellar_room":
			return str(e["built"]) % CELLAR_ROOM_CAP
		"porch":
			return str(e["built"]) % int(PORCH_SANITY)
	return str(e["built"]) % int(STOREY_SLEEP)


# Why an extension can't be built now ("built" once it is), or "" when it can.
func _why(id: String) -> String:
	if _has(id):
		return "built"
	var e: Dictionary = EXTENSIONS[id]
	if id == "cellar_room" and not m.cellar_built:
		return "the root cellar first"
	if m.house_stage < int(e["stage"]):
		return "the house must be %s first" % str(m.STAGE_NAMES[int(e["stage"])]).to_lower()
	if e.has("after") and not _has(str(e["after"])):
		return "the %s first" % str(EXTENSIONS[e["after"]]["name"]).to_lower()
	if not m._can_afford(e["cost"]):
		return "needs %s" % m.stall._price_text(e["cost"])
	return ""


func _build(id: String) -> void:
	var why := _why(id)
	var e: Dictionary = EXTENSIONS[id]
	if why != "":
		m._show_message("%s: %s." % [e["name"], why])
		return
	m._pay(e["cost"])
	built[id] = true
	m.progression._grant_xp("Carpentry", m.XP_REPAIR * 2)
	m.play_sfx("repair", 0.05)
	m.queue_redraw()
	m.house_roof_drawn_stage = -1
	m._show_message("The %s is built. %s" % [str(e["name"]).to_lower(), _built_text(id)])


func _cellar_cap() -> int:
	return CELLAR_ROOM_CAP if _has("cellar_room") else m.CELLAR_CAP


func _stand_demand_mult() -> float:
	return PORCH_DEMAND if _has("porch") else 1.0


func _sleep_bonus() -> float:
	return STOREY_SLEEP if _has("second_storey") else 0.0


func _night_mult() -> float:
	return STOREY_NIGHT_MULT if _has("second_storey") else 1.0


# --- Furniture, paint and wallpaper -------------------------------------------------------------

func _furniture_why(id: String) -> String:
	if furniture.has(id):
		return "bought"
	var f: Dictionary = FURNITURE[id]
	if m.house_stage < int(f["stage"]):
		return "its room opens when the house is %s" % str(m.STAGE_NAMES[int(f["stage"])]).to_lower()
	if not _held_all(f["cost"]):
		return "needs %s" % m.projects._cost_list(f["cost"])
	return ""


func _buy_furniture(id: String) -> void:
	var why := _furniture_why(id)
	var f: Dictionary = FURNITURE[id]
	if why != "":
		m._show_message("%s: %s." % [f["name"], why])
		return
	_spend(f["cost"])
	furniture[id] = true
	m.play_sfx("repair", 0.05)
	m.queue_redraw()
	m._show_message("The %s is in the house. +%d sanity each morning while it stands." % [str(f["name"]).to_lower(), int(COMFORT_SANITY)])


func _paint_why(id: String) -> String:
	if paint == id:
		return "current"
	if m.house_stage < 3:
		return "the house must be restored first"
	if not _held_all(PAINT_COST):
		return "needs %s" % m.projects._cost_list(PAINT_COST)
	return ""


func _repaint(id: String) -> void:
	var why := _paint_why(id)
	if why != "":
		m._show_message("%s: %s." % [PAINTS[id]["name"], why])
		return
	_spend(PAINT_COST)
	paint = id
	m.play_sfx("repair", 0.05)
	m.house_roof_drawn_stage = -1
	m._show_message("The house is painted %s." % str(PAINTS[id]["name"]).to_lower())


func _paper_why(id: String) -> String:
	if paper == id:
		return "current"
	if m.house_stage < 2:
		return "the house must be patched first"
	if not _held_all(PAPER_COST):
		return "needs %s" % m.projects._cost_list(PAPER_COST)
	return ""


func _repaper(id: String) -> void:
	var why := _paper_why(id)
	if why != "":
		m._show_message("%s: %s." % [PAPERS[id]["name"], why])
		return
	_spend(PAPER_COST)
	paper = id
	m.play_sfx("repair", 0.05)
	m.queue_redraw()
	m._show_message("The rooms are papered in %s." % str(PAPERS[id]["name"]).to_lower())


func _paint_tint() -> Color:
	return PAINTS[paint]["color"]


func _paper_color() -> Color:
	return PAPERS[paper]["color"]


func _held_all(cost: Dictionary) -> bool:
	for key in cost:
		if m._held(str(key)) < int(cost[key]):
			return false
	return true


func _spend(cost: Dictionary) -> void:
	for key in cost:
		if key == "coins":
			m.money -= int(cost[key])
		else:
			m.materials[key] -= int(cost[key])


# Each morning: the comfort of the furniture and the porch. Returns a note for the morning message.
func _morning() -> String:
	var lift := COMFORT_SANITY * furniture.size() + (PORCH_SANITY if _has("porch") else 0.0)
	if lift <= 0.0:
		return ""
	m.sanity_sys._change_sanity(lift)
	return " The house is a comfort. +%d sanity." % int(lift)


# --- The land deed ---------------------------------------------------------------------------------

func _deed_owned() -> bool:
	return deed_paid >= DEED_PRICE


func _deed_open() -> bool:
	return m.house_stage >= 2


# The clerk's letter comes the morning after the house is patched. Returns a note for the morning message.
func _mail_day() -> String:
	if deed_offered or not _deed_open():
		return ""
	deed_offered = true
	m.desk._add_letter("From the town clerk", "Madam or sir. We hear the Rook house is lived in again. The farm is held from the town on the quarter's tax, as it was in Mrs Rook's day. "
		+ "When she fell behind, in her last year, the town took her bell in lieu, and would have taken the land after. "
		+ "The council will sell the deed outright, for %d coins, paid at your desk as you can (%d at a time). Once paid, no tax is owed on the farm again." % [DEED_PRICE, DEED_STEP])
	return " A letter from the town clerk is on the desk."


func _deed_step() -> int:
	return mini(DEED_STEP, DEED_PRICE - deed_paid)


func _deed_why() -> String:
	if _deed_owned():
		return "owned"
	if not _deed_open():
		return "the town sells the deed once the house is patched"
	if m.tax_owed > 0:
		return "pay the tax owed first"
	if m.money < _deed_step():
		return "needs %d coins" % _deed_step()
	return ""


func _pay_deed() -> void:
	var why := _deed_why()
	if why != "":
		m._show_message("The land deed: %s." % why)
		return
	var n := _deed_step()
	m.money -= n
	deed_paid += n
	m.play_sfx("coin")
	if not _deed_owned():
		m._show_message("You pay %d coins toward the land deed. %d of %d paid." % [n, deed_paid, DEED_PRICE])
		return
	m.desk._add_letter("The deed to the Rook farm", "Received in full. The land, the house and all that stands on it are yours, and no tax is owed on them again. "
		+ "The clerk adds, in his own hand: the bell we took from Mrs Rook was sold for its iron. I am sorry for it. She asked us to keep it hung.")
	m._show_message("The land deed is yours. No more property tax, ever.")
	m.progression._check_story()


func _deed_text() -> String:
	if _deed_owned():
		return "yours: no tax is owed on the farm"
	if not _deed_open():
		return "%d coins, sold once the house is patched" % DEED_PRICE
	return "%d of %d coins paid" % [deed_paid, DEED_PRICE]


# --- Drawing --------------------------------------------------------------------------------------

# The extensions, drawn over the house sprite in its rect (see main's _draw_house_roof_layer).
func _draw_outside(ci: CanvasItem, rect: Rect2, porch_y: float) -> void:
	var px := float(m.PX)
	var ink := Color("1d1611")
	if _has("second_storey"):
		# A dormer row on the roof: a gable with two lit windows.
		var w := rect.size.x * 0.5
		var base := Vector2(rect.position.x + rect.size.x * 0.25, rect.position.y + rect.size.y * 0.3)
		var gable := PackedVector2Array([base, base + Vector2(w, 0), base + Vector2(w * 0.5, -px * 1.1)])
		var wall := Rect2(base, Vector2(w, px * 0.9))
		ci.draw_rect(wall.grow(2.0), ink)
		ci.draw_rect(wall, Color("8a6a4c") * _paint_tint())
		ci.draw_colored_polygon(gable, Color("6b4b33"))
		ci.draw_polyline(gable + PackedVector2Array([gable[0]]), ink, 2.0)
		for k in 2:
			var win := Rect2(base + Vector2(w * (0.2 + 0.45 * k), px * 0.2), Vector2(px * 0.5, px * 0.45))
			ci.draw_rect(win.grow(2.0), ink)
			ci.draw_rect(win, Color("e8c878"))
	if _has("porch"):
		# A plank deck along the porch row under a copper roof on posts.
		var deck := Rect2(rect.position.x + px * 0.5, porch_y + px * 0.55, rect.size.x - px, px * 0.4)
		ci.draw_rect(deck.grow(2.0), ink)
		ci.draw_rect(deck, Color("7a5a3c"))
		for k in int(deck.size.x / (px * 0.5)):
			var x := deck.position.x + px * 0.5 * k
			ci.draw_line(Vector2(x, deck.position.y), Vector2(x, deck.end.y), Color(0, 0, 0, 0.25), 1.0)
		var roof := Rect2(deck.position.x - px * 0.2, porch_y - px * 0.35, deck.size.x + px * 0.4, px * 0.22)
		ci.draw_rect(roof.grow(2.0), ink)
		ci.draw_rect(roof, Color("b8733a"))
		ci.draw_rect(Rect2(roof.position, Vector2(roof.size.x, 3)), Color("d8a060"))
		for x in [deck.position.x + 3, deck.end.x - 7]:
			ci.draw_rect(Rect2(x, roof.end.y, 4, deck.position.y - roof.end.y), ink)
	if _has("cellar_room"):
		# Slanted cellar doors against the west wall.
		var at := Vector2(rect.position.x - px * 0.1, porch_y + px * 0.1)
		var doors := PackedVector2Array([at, at + Vector2(px * 0.9, 0), at + Vector2(px * 0.9, px * 0.8), at + Vector2(0, px * 0.8)])
		ci.draw_colored_polygon(doors, Color("5a3f2c"))
		ci.draw_polyline(doors + PackedVector2Array([doors[0]]), ink, 2.0)
		ci.draw_line(at + Vector2(px * 0.45, 0), at + Vector2(px * 0.45, px * 0.8), ink, 2.0)
		ci.draw_rect(Rect2(at + Vector2(px * 0.38, px * 0.35), Vector2(px * 0.14, px * 0.08)), Color("8a8f99"))


# The wallpaper over a wall tile's face, and the furniture in the rooms (see main's _draw_interior).
func _draw_paper(ci: CanvasItem, cell: Rect2, pos: Vector2i) -> void:
	var c := _paper_color()
	if c.a <= 0.0:
		return
	ci.draw_rect(cell, Color(c, 0.6))
	var dot := Color(c.lightened(0.45), 0.8)
	for k in 2:
		ci.draw_circle(cell.position + Vector2(cell.size.x * (0.25 + 0.5 * k), cell.size.y * (0.3 + 0.4 * ((k + pos.x + pos.y) % 2))), 2.5, dot)


func _draw_furniture(ci: CanvasItem, cell: Rect2, pos: Vector2i) -> void:
	for id in furniture:
		var f: Dictionary = FURNITURE[id]
		if f["spot"] != pos or m.house_stage < int(f["stage"]):
			continue
		var px := cell.size.x
		var ink := Color("1d1611")
		var r := cell.grow(-px * 0.1)
		match str(id):
			"dresser":
				ci.draw_rect(r.grow(2.0), ink)
				ci.draw_rect(r, Color("6b4a30"))
				for k in 3:
					var drawer := Rect2(r.position + Vector2(3, 3 + r.size.y * 0.3 * k), Vector2(r.size.x - 6, r.size.y * 0.26))
					ci.draw_rect(drawer, Color("7f5a3a"))
					ci.draw_circle(drawer.get_center(), 2.0, Color("c8844a"))
			"feather_bed":
				# Drawn from the bed's bottom tile, over the bed: a plump white quilt below the pillow.
				var quilt := Rect2(cell.position + Vector2(px * 0.15, -px * 1.1), Vector2(px * 1.7, px * 1.75))
				ci.draw_rect(quilt.grow(1.0), ink)
				ci.draw_rect(quilt, Color("d8d0c0"))
				for k in 3:
					ci.draw_line(quilt.position + Vector2(0, quilt.size.y * 0.25 * (k + 1)), quilt.position + Vector2(quilt.size.x, quilt.size.y * 0.25 * (k + 1)), Color("2a2a30"), 1.0)
			"armchair":
				var seat := Rect2(r.position + Vector2(0, r.size.y * 0.35), Vector2(r.size.x, r.size.y * 0.65))
				var back := Rect2(r.position + Vector2(r.size.x * 0.1, 0), Vector2(r.size.x * 0.8, r.size.y * 0.5))
				ci.draw_rect(back.grow(2.0), ink)
				ci.draw_rect(back, Color("6a2e34"))
				ci.draw_rect(seat.grow(2.0), ink)
				ci.draw_rect(seat, Color("7a3a40"))
			"clock":
				var body := Rect2(cell.position + Vector2(px * 0.25, -px * 0.6), Vector2(px * 0.5, px * 1.5))
				ci.draw_rect(body.grow(2.0), ink)
				ci.draw_rect(body, Color("5a3a26"))
				ci.draw_circle(body.position + Vector2(body.size.x * 0.5, px * 0.3), px * 0.18, ink)
				ci.draw_circle(body.position + Vector2(body.size.x * 0.5, px * 0.3), px * 0.15, Color("d8a060"))
				ci.draw_line(body.position + Vector2(body.size.x * 0.5, px * 0.6), body.position + Vector2(body.size.x * 0.5, px * 1.2), Color("c8a040"), 2.0)
			"painting":
				var frame := Rect2(cell.position + Vector2(px * 0.1, px * 0.2), Vector2(px * 1.6, px * 0.9))
				ci.draw_rect(frame.grow(2.0), ink)
				ci.draw_rect(frame, Color("a0783a"))
				var canvas := frame.grow(-4.0)
				ci.draw_rect(canvas, Color("7a8a9a"))
				ci.draw_rect(Rect2(canvas.position + Vector2(0, canvas.size.y * 0.6), Vector2(canvas.size.x, canvas.size.y * 0.4)), Color("5a6a3a"))
				ci.draw_rect(Rect2(canvas.position + Vector2(canvas.size.x * 0.6, canvas.size.y * 0.4), Vector2(2, canvas.size.y * 0.3)), Color("1d1611"))
			"bookshelf":
				var shelf := Rect2(cell.position + Vector2(px * 0.05, 0), Vector2(px * 1.9, px * 0.95))
				ci.draw_rect(shelf.grow(2.0), ink)
				ci.draw_rect(shelf, Color("5a3a26"))
				var spines := [Color("8a2e3a"), Color("3e5a80"), Color("3f6b4a"), Color("b8964a"), Color("6a5a4a")]
				for row in 2:
					for k in 9:
						var b := Rect2(shelf.position + Vector2(4 + k * (shelf.size.x - 8) / 9.0, 3 + row * shelf.size.y * 0.5), Vector2((shelf.size.x - 8) / 9.0 - 1, shelf.size.y * 0.42))
						ci.draw_rect(b, spines[(k + row * 2) % spines.size()])
