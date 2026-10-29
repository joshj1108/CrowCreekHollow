class_name StoryAct
extends RefCounted

# The second year's story (the mid-game act) and the endings. From early summer (day 240) to the second All
# Hallows (day 396), five beats give the bell a cost and the year a shape: the town writes to say the bell
# must not be hung; Elias's orchard rises; the Hollow learns his knock; the town meets at the mill; and Davy
# goes to take his turn. The walkers' last scenes (FolkSystem's ending hooks) decide how the meeting goes,
# and with the pages from the wood and a night at the grove, which ending the grove gives.
#
# Endings (saved in endings, id -> the day reached, for achievements):
#   bell   the crow bell hung and the woman in grey walked to the grove: the Hollow sleeps.
#   elias  the same, with the town's keeping won at the mill, Davy's and the postman's last scenes, all five
#          pages from the wood, and the grove walked by night: you take a turn on the ring, and Elias comes home.
#   hollow the Hollow left at the door HOLLOW_TAKES times from day 240, before the bell: the farm is its.
#          Play goes on, and the bell can still be hung; the bell's ending after it is the way back.
# Each plays a short ending sequence over the farm (EndingScreen), writes the diary's Afterword and rolls the
# credits, then the game goes on.

var m: MainGame

const FROM := 240                  # the town's letter, early summer of the second year
const ORCHARD_FROM := 265          # Elias's orchard rises: the next walk to it
const KNOCK_FROM := 285            # the Hollow comes to the door with his knock
const KNOCK_AFTER := 4             # nights at least after the orchard
const KNOCK_AGAIN := 5             # nights before it tries again, left at the door
const MEETING_FROM := 300          # the meeting can be put at the mill
const HARVEST_MOON := 357          # the town meets that night whether you come or not (September 22)
const DAVY_FROM := 370             # Davy goes, in the second autumn (October 5)
const DAVY_FROM_HOUR := 20.0
const DAVY_UNTIL := 25.0           # 01:00: after that he has gone into the wood
const HOLLOW_TAKES := 3            # the Hollow left at the door this often from FROM, before the bell
const STAND_HEARTS := 6            # a walker this fond of you stands up at the meeting

# The Hollow on the night it learns Elias's knock (NightSystem._pick); played like HOLLOW, at the door.
const KNOCK := {"id": "hollow", "where": "door", "sound": "heartbeat", "act": "knock",
	"appear": "Three knocks, slow, the way a man knocks at his own door when his hands are full. The Hollow has come to the door, and it knocks like Elias.",
	"face": "You open the door with the lantern high. It is the Hollow, and for a moment it is the shape of a tall man in it. Then it shrieks and comes apart into a hundred crows. On the step is a seed catalogue thirty years old, addressed to Mr E. Rook.",
	"face_sanity": 20, "feathers": 5,
	"ignore": "It knocked until morning, patiently, the way you knock for someone you know is in. Something in your mind gave way.",
	"ignore_sanity": 30, "limit": 5}

# The town's letter (FROM): it comes through the mail slot, in the clerk's hand.
const LETTER := {"title": "From the parish meeting",
	"text": "To the tenant at Rook's farm. It has come to the meeting's notice that you have been asking after Agnes Rook's bell. The meeting voted that bell down thirty-one hands to four, and the vote stands. No bell is to be hung on that farm. We have kept the peace thirty years by letting it be. Let it be. For the meeting, E. Pell, clerk."}

# What each walker says when you show them the letter (the first visit after it comes).
const SHOWN := {
	"mill": [
		{"text": "You hold out the letter. Maren reads it at arm's length, then closer."},
		{"who": "mill", "expr": "grim", "text": "\"Edwin Pell. He was a boy at that meeting. He held his father's coat.\""},
		{"who": "mill", "text": "\"Thirty-one to four. I'd forgotten there were four. I'd like to know who they were.\""},
		{"who": "mill", "expr": "worry", "text": "\"They're frightened. Frightened people write very polite letters. Don't hang anything yet. Let me think.\""}],
	"orchard": [
		{"text": "Davy reads the letter with his finger under each line, lips moving."},
		{"who": "orchard", "expr": "worry", "text": "\"Mr Pell's the one who shouts at the dogs. He says there's no such thing as a bell that keeps anything.\""},
		{"who": "orchard", "text": "\"Then why's he so cross about it?\""},
		{"text": "He gives it back folded smaller than it was, as if that helped."}],
	"chapel": [
		{"text": "The vicar reads the letter twice, and his mouth tightens at the signature."},
		{"who": "chapel", "expr": "grim", "text": "\"Thirty years of peace. That's one word for it. The farm stood empty most of them, and the whole lane bolted its doors at dusk.\""},
		{"who": "chapel", "expr": "worry", "text": "\"They'll call a meeting. They always do. It will be at the mill, because that is where it was done.\""},
		{"who": "chapel", "expr": "far", "text": "\"Don't go to it with only a bell. Go with something they can't vote away.\""}],
	"post": [
		{"text": "The postman doesn't need to read it. He knows the envelope."},
		{"who": "post", "expr": "grim", "text": "\"I carried that one up the lane myself. Pell watched me to your gate from his window.\""},
		{"who": "post", "text": "\"Every keeper this farm has had got one of those, near enough word for word. My father carried the others.\""},
		{"who": "post", "expr": "far", "text": "\"Agnes burned hers in the stove. I watched her do it. Then she ordered the iron.\""}],
}
const SHOWN_HINT := "Show it to a neighbour when one comes by."

# Davy at the great tree on the night he goes (DAVY_FROM), found before 01:00.
const DAVY_FOUND := [
	{"text": "Davy is sitting in the roots of the great tree with an unlit lantern in his lap, looking down into the dark under it."},
	{"who": "orchard", "expr": "far", "text": "\"I can hear him walking. Can you? Round and round. And Pip's feet, little ones, behind.\""},
	{"who": "orchard", "expr": "worry", "text": "\"Someone has to take a turn. I said I could. I'm not scared. I'm only cold.\""},
	{"text": "You put your coat round him and say it isn't his turn. It isn't anybody's yet. Not while there's a bell to hang."},
	{"who": "orchard", "expr": "worry", "text": "\"You'll tell Ma.\" You say you will. He nods, as if that's fair, and lets you walk him home."}]
const DAVY_FOUND_YOURS := "You put your coat round him and say it isn't his turn. You have seen a letter in your own hand. If anyone takes a turn, it will be you."

# The ending sequences: the title, then the lines shown one at a time over the farm.
const ENDINGS := {
	"bell": {"title": "The Hollow Sleeps"},
	"elias": {"title": "Two Came Home"},
	"hollow": {"title": "The Line Under the Rooks"},
}
const CREDITS := ["Crow Creek Hollow", "",
	"Old Maren, who stood", "Davy Tull, and Pip", "The vicar, who kept the clapper", "The postman, who kept the letters", "",
	"Agnes Rook", "Elias Rook", "",
	"The Askews, the Lindqvists, the Harrows and the Moores", "",
	"Made with Godot Engine", "Sprites with SpriteCook", "",
	"And the crows", "", "", "Thank you for keeping the farm."]

var beats := {}          # saved: beat id (letter, shown, orchard, knock, meeting, davy) -> the day it happened
var meeting := ""        # saved: "won" or "lost" once the meeting is held
var meeting_there := false   # saved: you walked Maren to it
var davy := ""           # saved: "stopped" or "lost" once his night has passed
var davy_day := -1       # saved: the day Davy goes
var knock_from := -1     # saved: the first night the knock can come
var hollow_left := 0     # saved: the Hollow left at the door from FROM, before the bell
var endings := {}        # saved: ending id -> the day reached
var pending := ""        # saved: an ending reached but not yet shown
var screen: EndingScreen


func _init(main: MainGame) -> void:
	m = main


func _build() -> void:
	screen = EndingScreen.new()
	m.add_child(screen)


func _has(id: String) -> bool:
	return beats.has(id)


# The beat happened in play (not closed quietly).
func _lived(id: String) -> bool:
	return int(beats.get(id, -1)) >= 0


func _done(id: String) -> void:
	if not beats.has(id):
		beats[id] = m.day


# The bell is hung or the act is otherwise over (old saves): what's left of it is closed quietly.
func _closed() -> bool:
	return m.projects._has_bell() or m.trek.grove_done


# Beats closed this way hold -1, so the diary has no page for them.
func _close() -> void:
	for id in ["letter", "shown", "orchard", "knock", "meeting"]:
		if not beats.has(id):
			beats[id] = -1
	if meeting == "":
		meeting = "lost"


# --- The morning --------------------------------------------------------------------------------

# A new day (main._end_day): the beats that come by morning, as a note for the morning message.
func _morning() -> String:
	if _closed():
		_close()
		return ""
	var note := ""
	# Davy wasn't found before the day ended.
	if davy_day >= 0 and davy == "" and m.day > davy_day:
		_lose_davy()
		note += " Mrs Tull came up the lane at first light. Davy didn't come home. There are small boot prints in the roots of the great tree, and they don't come out."
	if m.day >= FROM and not _has("letter"):
		_done("letter")
		m._diary_page("act_letter")
		m.play_sfx("chime", 0.0)
		note += " A letter has come through the mail slot, from the parish meeting. It's in your diary. %s" % SHOWN_HINT
	# The town meets on the night of the Harvest Moon whether you come or not.
	if _has("letter") and not _has("meeting") and m.day > maxi(HARVEST_MOON, int(beats["letter"]) + 10):
		_hold_meeting(false)
		note += " " + _meeting_morning()
	if davy_day < 0 and _has("orchard") and m.day >= DAVY_FROM:
		davy_day = m.day
		note += " Mrs Tull is at the gate, white to the lips: Davy has gone, with a lantern and a heel of bread. His grandad says to look at the great tree after dark, where the hollow is."
	return note


# --- The letter, shown to a neighbour (FolkSystem._talk) -----------------------------------------------

# An act scene for a walker you speak to, or {} for their own talk: the letter once, Davy on his night.
func _folk_scene(id: String) -> Dictionary:
	if _davy_waiting() and id == "orchard":
		var pages: Array = DAVY_FOUND.duplicate(true)
		if m.folk.seen.has("post_hand"):
			pages[3] = {"text": DAVY_FOUND_YOURS}
		return {"id": "act_davy", "title": "Davy at the great tree", "act": "davy", "pages": pages}
	if _has("letter") and not _has("shown") and SHOWN.has(id):
		return {"id": "act_shown", "title": "The town's letter", "act": "shown", "pages": SHOWN[id]}
	return {}


func _on_scene(sc: Dictionary) -> void:
	match str(sc.get("act", "")):
		"shown":
			_done("shown")
			m._show_message("Next: %s." % _next_title())
		"davy":
			davy = "stopped"
			_done("davy")
			m.folk._add("orchard", 20)
			m.folk.visitor = ""
			m._diary_page("act_davy")
			m.play_sfx("chime", 0.0)
			m._show_message("You walk Davy home down the lane. Mrs Tull doesn't say anything. She holds on to him. It's in your diary.")


func _next_title() -> String:
	var q := m._current_chapter()
	return str(q.get("title", "the next chapter"))


# --- The orchard and the meeting (TrekSystem._arrive) ---------------------------------------------------

# Arriving at a route's end: what the act adds to the arrival, or "".
func _on_trek_arrived(route: String) -> String:
	if _closed():
		return ""
	if route == "orchard" and _has("shown") and not _has("orchard") and m.day >= ORCHARD_FROM:
		_done("orchard")
		knock_from = maxi(KNOCK_FROM, m.day + KNOCK_AFTER)
		m._diary_page("act_orchard")
		return " The water has come up to the eleventh row, Elias's last. Nothing walks the rows tonight. On a low branch hangs a lantern, cold and dry, as if someone set it down to have both hands free. Davy won't go near it. \"He's stopped,\" he says. \"He's looking at your farm.\" (Your diary has a page.)"
	if route == "mill" and _has("letter") and not _has("meeting") and m.day >= MEETING_FROM:
		if _ready_for_meeting():
			meeting_there = true
			_hold_meeting(true)
			m._diary_page("act_meeting")
			return " " + _meeting_text(true)
		return " " + _meeting_wait()
	return ""


# Maren's minute book and the vicar's register: without both, the town won't hear it.
func _ready_for_meeting() -> bool:
	return m.folk.seen.has("maren_book") and m.folk.seen.has("vicar_register")


func _meeting_wait() -> String:
	var want: Array = []
	if not m.folk.seen.has("maren_book"):
		want.append("Ruth's minute book, which Maren hasn't shown you yet")
	if not m.folk.seen.has("vicar_register"):
		want.append("the vicar's register, which he hasn't shown you yet")
	return "At the mill door Maren stops you. \"Not tonight. They won't hear it without %s. They meet on the Harvest Moon whether we're ready or not.\"" % " or ".join(want)


func _hold_meeting(there: bool) -> void:
	meeting = "won" if _ready_for_meeting() else "lost"
	_done("meeting")
	if not there:
		m._diary_page("act_meeting")


# The walkers who stand with you at the meeting.
func _standing() -> Array:
	var out: Array = []
	for id in FolkSystem.IDS:
		if m.folk._hearts(id) >= STAND_HEARTS:
			out.append(m.folk._name(id))
	return out


func _meeting_text(there: bool) -> String:
	if meeting == "won":
		return "%sMaren stands up with Ruth's minute book and reads every name and every hand, her own third. The vicar opens the register and reads the witness's line: his father's name, and his. Nobody says anything for a long time. Then Edwin Pell puts the vote again, and the hands go up the other way. The town will hang the bell with you, and ring it in turns, the way it should have from the start." % \
			("The mill is full, the shutters closed. " if there else "")
	var who := _standing()
	var stood := (" %s stood with you, and it wasn't enough." % " and ".join(who)) if not who.is_empty() else " Nobody stood up."
	return "The meeting was held at the mill on the night of the Harvest Moon.%s The vote stands: no bell on Rook's farm. If it is hung, it is hung by you alone, against the lane." % stood


func _meeting_morning() -> String:
	return _meeting_text(false) + " (Your diary has a page.)"


# --- Davy's night ------------------------------------------------------------------------------------

func _davy_waiting() -> bool:
	return davy_day == m.day and davy == "" and m.current_hour >= DAVY_FROM_HOUR and m.current_hour < DAVY_UNTIL \
		and not m.trek.active and not _closed()


# The Tull boy is gone from the lane until the grove (FolkSystem._can_visit, TrekSystem._route_open).
func _davy_gone() -> bool:
	return (davy == "lost" and not m.trek.grove_done) or (davy_day == m.day and davy == "")


func _lose_davy() -> void:
	davy = "lost"
	_done("davy")
	m._diary_page("act_davy")


# Each frame: Davy waits at the great tree after dark, and an ending reached plays when nothing covers it.
func _update() -> void:
	if davy_day == m.day and davy == "":
		if _davy_waiting() and m.folk.visitor != "orchard":
			m.folk.visit_day = m.day
			m.folk.visitor = "orchard"
			m.folk.spot = m.folk._spot_at("tree")
		elif m.current_hour >= DAVY_UNTIL:
			_lose_davy()
			m.folk.visitor = ""
			m._show_message("Under the great tree the roots shift, once, like something settling. Davy has gone in.")
	if pending != "" and not playing() and not m.trek.active and not m.folk._in_scene() and m.open_tab == "" and not m.transitioning:
		_play_ending(pending)


# --- The nights (NightSystem) ----------------------------------------------------------------------

func _knock_tonight() -> bool:
	return knock_from >= 0 and not _has("knock") and m.day >= knock_from and not _closed()


# The Hollow came to the door, faced or not. Left there from FROM, before the bell, it counts toward taking
# the farm.
func _on_hollow(faced: bool, v: Dictionary) -> void:
	if str(v.get("act", "")) == "knock":
		if faced:
			_done("knock")
			m._diary_page("act_knock")
		else:
			knock_from = m.day + KNOCK_AGAIN
	if faced or m.day < FROM or m.projects._has_bell() or m.trek.grove_done or endings.has("hollow"):
		return
	hollow_left += 1
	if hollow_left >= HOLLOW_TAKES:
		_reach("hollow")


# --- The grove (TrekSystem._on_arrived) ------------------------------------------------------------

# Everything Elias's homecoming needs; by_night is the walk itself.
func _elias_ready(by_night: bool) -> bool:
	return by_night and meeting == "won" and m.folk.seen.has("davy_turn") and m.folk.seen.has("post_hand") \
		and m.mystery._count(m.mystery.TREK_PAGES) == m.mystery.TREK_PAGES.size()


func _on_grove(by_night: bool) -> void:
	_close()
	_reach("elias" if _elias_ready(by_night) else "bell")
	if davy == "lost":
		davy = "home"


func _grove_arrive(text: String) -> String:
	if not endings.has("elias"):
		return text
	return "The Hollow's grove: a ring of great black trees, the ground inside worn into a path, round and round. The woman lets the grey shawl fall; it is Agnes Rook. On the path, always a step ahead of her, walks a tall man with an unlit lantern. You take out the letter in your own hand and read it aloud, and step onto the ring behind him. He stops. For the first time in thirty years, he stops. Far off, at the farm, the town is ringing the bell in turns, two notes, and the ring has no need of you: by first light you are walking back down the path, and two people are walking behind you, holding hands."


# --- Endings -------------------------------------------------------------------------------------

func _reach(id: String) -> void:
	if endings.has(id):
		return
	endings[id] = m.day
	pending = id
	m._diary_page("end_" + id)
	m.progression._bump("endings")
	match id:
		"hollow":
			# The Hollow has what it came for, for now: the shadow goes back to the field's edge, and the mind it
			# wore down is let go.
			m.sanity_penalty = 0
			m.nights.shadow_steps = 0
			hollow_left = 0
		"elias":
			m.materials["apple_sapling"] += 3


func playing() -> bool:
	return screen != null and screen.active


func _play_ending(id: String) -> void:
	pending = ""
	m.play_sfx("chime", 0.0)
	screen.play(str(ENDINGS[id]["title"]), _lines(id), CREDITS, func() -> void:
		m._show_message("Your diary has an Afterword. The farm goes on."))


func _keys() -> void:
	if Input.is_action_just_pressed("use") or Input.is_action_just_pressed("tool_use") or Input.is_action_just_pressed("ui_accept"):
		screen.advance()


# The ending's lines over the farm.
func _lines(id: String) -> Array:
	match id:
		"hollow":
			return ["The Hollow came to the door, and nobody answered it.",
				"One night you went out to the field, the way the Askews did, and the Lindqvists, and the Harrows, and the Moores.",
				"The postman found you at dawn at the field's edge, sitting in the frost, looking at the great tree.",
				"The vicar wrote your name in the register, on the line he left under the Rooks.",
				"The farm is the Hollow's now. You still live on it."]
		"elias":
			return ["You took a turn on the ring, and Elias Rook stopped walking.",
				"The town rang the bell all night, in turns, Maren first.",
				"At first light two old people walked out of the Rookery Wood behind you, holding hands." + (" A boy and a dog came after them." if davy == "home" else ""),
				"The Hollow sleeps. Nobody has to keep it alone any more.",
				"This autumn there was no letter in the postman's sack. You wrote one anyway."]
	var lines: Array = ["The bell rings at dusk over Rook's farm.",
		"In the Hollow's grove Agnes Rook took up the path behind her husband, and the Hollow sleeps."]
	if meeting == "won":
		lines.append("The town rings it with you now, in turns. Thirty-one hands went up the other way.")
	else:
		lines.append("The town never voted it back. You ring it alone, every night, and you are the one who stays.")
	if davy == "home":
		lines.append("Davy Tull came home from the grove thin and quiet, with a dog at his heel. He doesn't whistle now.")
	lines.append("Somewhere far off in the Rookery Wood, something rings back. Two notes. Lower, and late.")
	return lines


# --- The diary -------------------------------------------------------------------------------------

# The second year's pages (a diary section of their own), in your hand but for the letter.
func _year_pages(is_new: Callable) -> Array:
	var out: Array = []
	if _lived("letter"):
		out.append({"title": LETTER["title"], "text": LETTER["text"], "new": is_new.call("act_letter")})
	if _lived("orchard"):
		out.append({"title": "The eleventh row", "hand": "yours", "new": is_new.call("act_orchard"),
			"text": "I walked Davy to the orchard. The water has risen to Elias's last row, and nothing walks there now. His lantern was hanging on a branch, cold, and dry as if it had never been near water. Davy says the man has stopped walking and is looking at the farm. I believe him."})
	if _lived("knock"):
		out.append({"title": "His knock", "hand": "yours", "new": is_new.call("act_knock"),
			"text": "It came to the door tonight and knocked the way a man knocks at his own house, with his hands full. I opened it. On the step was a seed catalogue for Mr E. Rook, thirty years old and bone dry. It has learned him, or he is in it. I don't know which is worse."})
	if _lived("meeting"):
		out.append({"title": "At the mill", "hand": "yours", "new": is_new.call("act_meeting"), "text": _meeting_page()})
	if davy != "" and davy_day >= 0:
		out.append({"title": "Davy", "hand": "yours", "new": is_new.call("act_davy"), "text": _davy_page()})
	return out


func _meeting_page() -> String:
	if meeting == "won":
		return "Maren stood with Ruth's book and read the names. The vicar read the register. Pell put the vote again, and the hands went up the other way. I counted. Thirty-one. They will ring it with me, in turns. Maren asked to be first."
	var who := _standing()
	return "They met at the mill on the Harvest Moon. %s The vote stands. I'll hang it anyway. Agnes did." % \
		(("%s stood with me. It wasn't enough." % " and ".join(who)) if not who.is_empty() else "Nobody stood.")


func _davy_page() -> String:
	if davy == "stopped":
		return "I found Davy in the roots of the great tree with an unlit lantern, listening to someone walking underneath. He said someone has to take a turn. I said not him. I walked him home. His mother held on to him and didn't say anything to me at all, which was right."
	if davy == "home":
		return "Davy went under the great tree on the night he meant to, and I didn't find him in time. He came home from the grove, thin and quiet, with a dog at his heel. He doesn't whistle now."
	return "Davy went under the great tree on the night he meant to, and I didn't find him in time. His mother comes up the lane every morning now and stands at my gate, and doesn't ask."


# The Afterword's ending pages, in the order reached.
func _afterword(is_new: Callable) -> Array:
	var out: Array = []
	var ids := endings.keys()
	ids.sort_custom(func(a, b) -> bool: return int(endings[a]) < int(endings[b]))
	for id in ids:
		out.append({"title": str(ENDINGS[id]["title"]), "hand": "yours", "new": is_new.call("end_" + str(id)), "text": _ending_page(str(id))})
	return out


func _ending_page(id: String) -> String:
	match id:
		"hollow":
			return "The register has my name in it now, on the line under the Rooks. The vicar showed me. He didn't cross it out, because I'm still here, but he said a line can be crossed out later. I still have the farm. It has me. The bell's parts are in the barn. All Hallows comes round every year."
		"elias":
			return "Mrs Agnes Rook, care of the chapel.\n\nYou'll want to know the bell is ringing. The town takes it in turns; Maren goes first and rings it too hard. Elias's orchard has gone down a row a week since you came out, and there are apples on the eleventh. The postman says there was no letter in his sack this autumn, and he doesn't know what to do with his hands. I'm writing this one so he has something to carry. Come up for your hens. They are terrible, and they are yours."
	var page := "The bell rings at dusk. Agnes went into the grove after him, and now there are two of them on the path, and the Hollow sleeps. "
	page += "The town rings it with me now, in turns." if meeting == "won" else "The town never voted it back. I ring it alone."
	if davy == "home":
		page += " Davy came home from the grove the morning after. He doesn't whistle any more."
	return page


# The grove page (Mystery) is Elias's homecoming instead, when he came home.
func _grove_page() -> Dictionary:
	if not endings.has("elias"):
		return {}
	return {"title": "The ring", "text": "I walked her to the grove by night, and he was on the path, a step ahead, as her page said. I read the letter in my own hand and took a turn behind him, and he stopped. The town was ringing at the farm; I could hear it the whole night through the trees. At first light I walked out, and Agnes and Elias Rook walked out behind me. That night there was no shadow in the field."}


# --- Saving -----------------------------------------------------------------------------------------

func _to_save() -> Dictionary:
	return {"beats": beats, "meeting": meeting, "meeting_there": meeting_there, "davy": davy, "davy_day": davy_day,
		"knock_from": knock_from, "hollow_left": hollow_left, "endings": endings, "pending": pending}


func _from_save(d: Variant) -> void:
	if typeof(d) != TYPE_DICTIONARY:
		return
	beats = {}
	var b: Variant = d.get("beats", {})
	if typeof(b) == TYPE_DICTIONARY:
		for k in b:
			beats[str(k)] = int(b[k])
	meeting = str(d.get("meeting", ""))
	meeting_there = bool(d.get("meeting_there", false))
	davy = str(d.get("davy", ""))
	davy_day = int(d.get("davy_day", -1))
	knock_from = int(d.get("knock_from", -1))
	hollow_left = int(d.get("hollow_left", 0))
	endings = {}
	var e: Variant = d.get("endings", {})
	if typeof(e) == TYPE_DICTIONARY:
		for k in e:
			endings[str(k)] = int(e[k])
	pending = str(d.get("pending", ""))
