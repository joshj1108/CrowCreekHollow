class_name Mystery
extends RefCounted

# The farm's past, told in torn pages from Agnes Rook's journal. She and her husband Elias farmed here before
# you. Elias walked into the hollow under the great tree; Agnes kept it under by ringing an iron bell each
# night, until the town made her take it down, and then she was gone too. Each page turns up through
# something the player already does, so the story comes out of playing: the knocking, the figure in the
# field, the crows, the house's walls, the cave, the Hollow. Pages are numbered, so the diary reads them in
# order whatever order they were found in. Five more, from after she left, are in the hollow trees on treks.
# Hanging the crow bell adds a last page in your own hand.

var m: MainGame

# Each page: its number, title, text, and where it turns up (shown when found).
const PAGES := [
	{"id": "p1", "title": "The first spring", "found": "A torn page came through the mail slot, with no envelope.",
		"text": "We bought the farm from the town for almost nothing. Elias says the crows are a good sign. I counted forty in the great tree tonight, and every one of them was looking at the house."},
	{"id": "p2", "title": "On the knocking", "found": "After the knocking, a torn page is lying on the doormat.",
		"text": "Three knocks again. Elias opened the door and there was nobody, only wet prints going back to the field. He laughed. I did not."},
	{"id": "p3", "title": "The thing in the field", "found": "Where the figure stood, a torn page is caught in the grass.",
		"text": "It stands at the field's edge on the dark nights. When I walk out to it, it goes, and leaves a feather. When I don't, it is closer the next night. I have started walking out."},
	{"id": "p4", "title": "Feathers", "found": "Tucked among the feathers, a torn page.",
		"text": "The feathers are warm. I bound three with flax and slept with them under my pillow, and nothing knocked. The crows give them for a reason."},
	{"id": "p5", "title": "Four families", "found": "A torn page was folded into the farm stand's cash tin.",
		"text": "Mr. Pell at the stall says the farm has had four families in sixty years. He would not say what happened to them. He said only, 'They stopped going out at night.'"},
	{"id": "p6", "title": "Elias", "found": "Behind the board you just patched, a torn page.",
		"text": "Elias went out to the field after the knocking and did not come back until dawn. He will not say what he saw. He sits by the fire all day now and does not answer to his name."},
	{"id": "p7", "title": "What the crows bring", "found": "The crows have left a torn page among their gifts.",
		"text": "There is a hollow under the great tree. The crows bring it things: buttons, spoons, keys. Elias says it is hungry. I said it is only a hole in the ground. He said, then why do they feed it?"},
	{"id": "p8", "title": "The bell", "found": "Pinned under a stone at the cave mouth, a torn page.",
		"text": "The old women in Lowmere say a bell will keep it under. Iron, and hardwood, and the crows' own feathers. I have ordered the iron. It will take everything we have left."},
	{"id": "p9", "title": "Winter", "found": "When the Hollow has gone, a torn page is on the step.",
		"text": "Elias walked into the hollow tonight. I watched him go. The crows went quiet all at once. I have hung the bell. I ring it every night, and the shadow does not cross the yard."},
	{"id": "p10", "title": "The last page", "found": "Behind the mantel, folded small, a torn page.",
		"text": "The town wants the bell down. They say it keeps them awake. If they take it, I will go after Elias, and whoever has this farm next must hang it again. Face what comes. Keep the fire lit. Agnes Rook."},
]
# What she wrote after the bell came down, following Elias through the Rookery Wood, and left in the hollow
# trees for whoever came after. Found in order on treks (TrekSystem._search_hollow), each from its route on:
# "from" is the first route (in TREK_ROUTES order) whose hollow trees can hold it.
const TREK_ROUTES := ["mill", "orchard", "chapel", "grove"]
const TREK_PAGES := [
	{"id": "t1", "title": "Into the wood", "from": "mill",
		"text": "The bell is down. I have taken the lantern and what oil I could carry. I'll leave these in the hollow trees as I go, the way Elias cut his marks, so that someone can follow."},
	{"id": "t2", "title": "Past the mill", "from": "mill",
		"text": "I passed the mill at dusk. Maren's lamp was lit, and I did not knock. They voted in that room with the shutters closed, as if the crows could not hear through wood."},
	{"id": "t3", "title": "The drowned rows", "from": "orchard",
		"text": "Elias's orchard is under water. The trees stand in it to the waist, still bearing. Something walks the rows at night. The prints are his size, and they go round and round."},
	{"id": "t4", "title": "The vicar", "from": "chapel",
		"text": "The vicar would not give me the clapper. He said it was the one thing he could keep safe. I said it was not the bell that needed keeping safe. He shut the vestry door, and I heard him weeping behind it."},
	{"id": "t5", "title": "The ring of trees", "from": "chapel",
		"text": "The crows brought me here. There is a path worn in a ring, and Elias is on it, just ahead of me, always just ahead. If you are reading this, go home. Keep the fire lit. Ring the bell every night, and I will hear it. A."},
]
const EPILOGUE := {"id": "bell", "title": "The bell rings again",
	"text": "You hang the bell where you think she hung hers, and ring it once at dusk. Under the great tree, something answers, low, and then is still. The crows settle. For the first time, the field is only a field."}

var found := {}                 # saved: page id -> true
var _events := {}               # this session: things seen that a page waits on (knock, field, crows, hollow)


func _init(main: MainGame) -> void:
	m = main


# A night visitor answered or left: the knocking, the field figure, the crows and the Hollow each leave a page.
func _on_visitor(id: String, faced: bool) -> void:
	if id == "knock" or id == "crows" or id == "hollow" or (id == "field" and faced):
		_events[id] = true


# The crows' gifts under the great tree also carry their page.
func _on_crow_gifts() -> void:
	_events["crows"] = true


# Checked every half second: any page whose moment has come is found. quiet, used when a game starts, files
# pages an older save has already earned without announcing each one.
func _check(quiet := false) -> void:
	var due := {
		"p1": m.day >= 3,
		"p2": _events.has("knock"),
		"p3": _events.has("field"),
		"p4": int(m.materials["feathers"]) >= 3 or int(m.inventory["crow_charm"]) > 0,
		"p5": int(m.stats["sold"]) >= 1,
		"p6": m.house_stage >= 2,
		"p7": _events.has("crows"),
		"p8": m.in_cave and not m.trek.active,
		"p9": _events.has("hollow"),
		"p10": m.house_stage >= 3,
		"bell": m.projects._has_bell(),
	}
	for id in due:
		if due[id] and not found.has(id):
			if quiet:
				found[id] = true
				continue
			_find(id)
			return      # one at a time, so each gets its moment


func _page(id: String) -> Dictionary:
	if id == "bell":
		return EPILOGUE
	for p in PAGES + TREK_PAGES:
		if p["id"] == id:
			return p
	return {}


func _find(id: String) -> void:
	found[id] = true
	var p := _page(id)
	m._diary_page("rook_" + id)
	m.play_sfx("chime", 0.0)
	if id == "bell":
		m._show_message("The bell rings out over the field, and something under the great tree answers. A last page is in your diary.")
		return
	m._show_message("%s It's in your diary: \"%s\" (%d of %d)." % [p["found"], p["title"], _count(), PAGES.size()])


func _count(pages := PAGES) -> int:
	var n := 0
	for p in pages:
		if found.has(p["id"]):
			n += 1
	return n


# The next trek page a hollow tree on this route can hold, or "" when the next one waits for a later route
# (or all are found). Pages come in order, so none is skipped.
func _next_trek_page(route_id: String) -> String:
	for p in TREK_PAGES:
		if not found.has(p["id"]):
			return p["id"] if TREK_ROUTES.find(route_id) >= TREK_ROUTES.find(p["from"]) else ""
	return ""


func _find_trek_page(id: String) -> void:
	found[id] = true
	var p := _page(id)
	m._diary_page("rook_" + id)
	m.play_sfx("chime", 0.0)
	m._show_message("Inside, folded small and dry, a page in Agnes Rook's hand. It's in your diary: \"%s\" (%d of %d from the wood)." % [
		p["title"], _count(TREK_PAGES), TREK_PAGES.size()])


# The diary's section: the pages found, in page order, with the epilogue last.
func _rows(new_mark: Callable) -> Array:
	if found.is_empty():
		return []
	var rows: Array = [{"section": "Agnes Rook's pages (%d of %d)" % [_count(), PAGES.size()]}]
	for i in PAGES.size():
		var p: Dictionary = PAGES[i]
		if found.has(p["id"]):
			rows.append({"note": "%d. %s%s\n%s" % [i + 1, p["title"], new_mark.call("rook_" + str(p["id"])), p["text"]]})
		else:
			rows.append({"name": "%d. Missing" % (i + 1), "value": "not found yet"})
	if _count(TREK_PAGES) > 0:
		rows.append({"section": "Pages from the wood (%d of %d)" % [_count(TREK_PAGES), TREK_PAGES.size()]})
		for i in TREK_PAGES.size():
			var p: Dictionary = TREK_PAGES[i]
			if found.has(p["id"]):
				rows.append({"note": "%d. %s%s\n%s" % [i + 1, p["title"], new_mark.call("rook_" + str(p["id"])), p["text"]]})
			else:
				rows.append({"name": "%d. Missing" % (i + 1), "value": "in a hollow tree somewhere"})
	if found.has("bell"):
		rows.append({"note": "%s%s\n%s" % [EPILOGUE["title"], new_mark.call("rook_bell"), EPILOGUE["text"]]})
	return rows
