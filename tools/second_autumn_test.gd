extends SceneTree

# CCH-ORIGIN-005: checks "The Second Year Remembers" (SecondAutumn, SecondAutumnScript). Run headless:
#   godot --path . --headless -s tools/second_autumn_test.gd
# Optional:  -- dump=AI_COLLAB/CCH_ORIGIN_005_SCENES.md   also writes every scene played here, its choices and outcomes.
# It plays in save slot 9 and deletes that save when done (slots 1-3 are never touched). Each case plays the winter and
# the spring through PastPost's and PastSpring's real mornings and answers, the first September where asked, then the
# second autumn's mornings (with the post), and answers the scene:
#   - the date: the practical morning from day 367, the scene from day 372, never on 370-371 or 395-397, never on the
#     September note's morning, once each; it waits while the spring is still open;
#   - every route for the five origins, from their winter and spring outcomes; private relations kept private; the
#     no-contact photograph; parcels never claimed before they come; every choice, its answer, its diary line;
#   - every September closing, unwritten, written late; deadlines and their lapse; coins only as the letters say, once;
#   - save and load before, during and after; v21 and legacy saves; damaged records;
#   - the real day through Davy's night and All Hallows: no note, nothing opened, Davy found or lost still possible,
#     the story's state identical with and without a past; StoryAct and the mystery untouched;
#   - input: the desk by keyboard, Xbox A and B, a mouse click; the mailbox's rows; the diary's Notes.
# Prints PASS or FAIL per case and a total; the exit code is the number of failures.

const SLOT := 9

var m: MainGame
var failures := 0
var dump_path := ""
var dump: Array = []


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if str(a).begins_with("dump="):
			dump_path = str(a).trim_prefix("dump=")
	create_timer(1500.0).timeout.connect(func() -> void:
		print("FAIL: the test stopped part way (a script error above?) and timed out")
		quit(99))
	m = load("res://scenes/main.tscn").instantiate()
	root.add_child.call_deferred(m)
	_run.call_deferred()


func _run() -> void:
	await _frames(3)
	SaveSystem.delete_save(TitleMenu.slot_path(SLOT))
	m._on_title_start("new", SLOT)
	await _frames(5)
	m.diary_found = true
	_dates()
	_security()
	_work()
	_household()
	_curiosity()
	_chance()
	_reflections()
	_deadlines()
	_world()
	_saving()
	_legacy()
	_real_day()
	await _input()
	if dump_path != "":
		_write_dump()
	SaveSystem.delete_save(TitleMenu.slot_path(SLOT))
	print("%s: %d failure(s)" % ["PASS" if failures == 0 else "FAIL", failures])
	quit(failures)


# --- Helpers ----------------------------------------------------------------------------------------------------

func _road(wants: Dictionary) -> Dictionary:
	var choices := {}
	var order := []
	for i in 40:
		var next := RoadScript.next_choice(choices)
		if next.is_empty():
			break
		var key := str(next["key"])
		var ids: Array = RoadScript.option_ids(next)
		var pick := str(wants.get(key, ids[0]))
		if not ids.has(pick):
			print("   (road: %s has no option %s; using %s)" % [key, pick, ids[0]])
			pick = ids[0]
		choices[key] = pick
		order.append(key)
	return {"v": 1, "status": "complete", "choices": choices, "order": order, "day": 1}


func _setup(wants: Dictionary, day := 103) -> void:
	m.origin = OriginState.new(_road(wants) if not wants.has("status") else wants)
	m.past_post.reset()
	m.past_spring.reset()
	m.first_september.reset()
	m.second_autumn.reset()
	m.desk_mail = []
	m.diary_new = []
	m.day = day
	m.money = 500
	m.tax_owed = 0
	m.current_hour = 10.0
	_bare_farm()


func _bare_farm() -> void:
	for kind in m.CROPS:
		m.stats.erase("crop_" + str(kind))
	m.stats["mended"] = 0
	m.stats["harvested"] = 0
	m.woodwork.repairs.clear()
	m.woodwork.hewn = 0
	m.house_stage = 0
	m.nearwood.trips = 0
	m.trek.treks_done = 0
	m.trek.edge_done = false
	m.town.visits = 0
	m.folk.requests_done.clear()
	m.estate.deed_paid = 0


func _worked_farm() -> void:
	m.house_stage = 2
	m.woodwork.repairs["house_1"] = {"day": 60, "cost": {}}
	m.woodwork.repairs["house_2"] = {"day": 200, "cost": {}}
	m.stats["harvested"] = 46
	m.stats["crop_turnip"] = 30
	m.stats["crop_potato"] = 16
	m.folk.requests_done["maren_eggs"] = 80
	m.nearwood.trips = 9
	m.woodwork.hewn = 24


func _go(d: int) -> String:
	var note := ""
	while m.day < d:
		m.day += 1
		note += m.past_post._morning() + m.past_spring._morning() + m.first_september._morning() + m.second_autumn._morning()
	return note


# Day by day: day -> the notes from this system that morning.
func _go_log(d: int) -> Dictionary:
	var log := {}
	while m.day < d:
		m.day += 1
		var a := m.past_post._morning() + m.past_spring._morning()
		var b := m.first_september._morning()
		log[m.day] = [a, b, m.second_autumn._morning()]
	return log


func _read_all() -> void:
	for l in m.desk_mail:
		if l.has("post") and bool(l["unread"]):
			m.past_post.read(str(l["post"]))
			m.past_spring.read(str(l["post"]))
			m.second_autumn.read(str(l["post"]))
		l["unread"] = false


func _winter(wants: Dictionary, id := "") -> void:
	_setup(wants)
	_go(PastPost.LETTER_DAY)
	_read_all()
	if id == "":
		_go(PastPost.ANSWER_BY + 1)
		return
	m.past_post.answer(id)
	_go(m.day + 1 + PastPost.ACK_DAYS)
	_read_all()


func _spring() -> void:
	for i in 400:
		if m.past_spring.active() or m.day > 420:
			break
		_go(m.day + 1)
	_read_all()


func _through(id: String) -> void:
	if not m.past_spring.answer(id):
		print("   (spring: %s not answered)" % id)
		return
	var out: Dictionary = m.past_spring.outgoing()
	if out.is_empty():
		return
	_go(int(out["written"]) + 1 + PastSpring.ACK_DAYS)
	_read_all()


# A whole past: the road, the winter's answer, the spring's steps ("open:<pid>" opens a parcel, "" lets it lapse).
func _past(wants: Dictionary, winter := "", steps: Array = [], farm := false) -> void:
	_winter(wants, winter)
	_spring()
	if farm:
		_worked_farm()
	for s in steps:
		var st := str(s)
		if st.begins_with("open:"):
			m.past_spring.open_parcel(st.trim_prefix("open:"))
		elif st != "":
			_through(st)
	_read_all()


func _to(day := SecondAutumn.FROM) -> String:
	var note := _go(day)
	_read_all()
	return note


# Answers the scene and lets its answer come (the post, then ACK_DAYS), everything read.
func _answer(id: String) -> bool:
	if not m.second_autumn.answer(id):
		return false
	var a: Dictionary = m.second_autumn.data.get("ack", {})
	if not a.is_empty():
		_go(int(a["due"]))
		_read_all()
	return true


func _sa() -> SecondAutumn:
	return m.second_autumn


func _body() -> String:
	var r := _sa().route()
	return str(r.get("body", ""))


func _labels() -> Array:
	return (_sa().route().get("choices", []) as Array).map(func(c: Dictionary) -> String: return str(c["id"]))


func _diary() -> String:
	return "\n\n".join(_sa().diary_pages().map(func(p: Dictionary) -> String: return str(p["text"])))


func _mail(post: String) -> Dictionary:
	for l in m.desk_mail:
		if str(l.get("post", "")) == post:
			return l
	return {}


func _count_mail(post: String) -> int:
	return m.desk_mail.filter(func(l: Dictionary) -> bool: return str(l.get("post", "")) == post).size()


func _round_trip() -> bool:
	m.saver._save_game()
	return m.saver._load_game()


func _check(name: String, ok: bool, detail := "") -> void:
	if not ok:
		failures += 1
	print("%s  %s%s" % ["PASS" if ok else "FAIL", name, "" if ok or detail == "" else "  (" + detail + ")"])


func _frames(n: int) -> void:
	for i in n:
		await process_frame


# Plays a route once per choice (from the same past) and records each outcome for the scenes document.
func _every_choice(name: String, setup: Callable, expect: String) -> void:
	setup.call()
	_to()
	_check("%s: the route is %s" % [name, expect], _sa().route_id() == expect, _sa().route_id())
	var r := _sa().route()
	if r.is_empty():
		return
	var entry := {"name": name, "route": expect, "title": str(r["title"]), "medium": str(r["medium"]), "sender": str(r["sender"]),
		"body": _sa()._body(r), "choices": []}
	var ids := _labels()
	for id in ids:
		setup.call()
		_to()
		var money := m.money
		var c := _sa()._choice(_sa().route(), id)
		var ok := _answer(id)
		var a: Dictionary = _sa().data.get("ack", {})
		var pay := int(_sa().data.get("credits", {}).get("ack", 0))
		var cost := int(c.get("cost", 0))
		if str(c.get("kind", "")) == "open":
			cost = 0
		var money_ok := m.money == money - cost + pay
		var diary := _diary()
		var said_ok := diary.contains(str(c.get("diary", "~")))
		var ack_ok := str(c.get("ack", "")) == "" or (int(a.get("delivered", -1)) >= 0 and diary.contains(str(c.get("ack_diary", "~"))) and _count_mail(SecondAutumn.ACK_POST) == 1)
		_check("%s: '%s' answers, its diary line, its answer, coins only as written" % [name, id], ok and said_ok and ack_ok and money_ok,
			"ok %s said %s ack %s money %d->%d cost %d pay %d" % [ok, said_ok, ack_ok, money, m.money, cost, pay])
		var p: Dictionary = _sa().data.get("parcel", {})
		if not p.is_empty():
			_check("%s: '%s' brings its parcel only with the answer, shut until opened" % [name, id], str(p["state"]) == "received" and not diary.contains(str(p["diary_opened"])))
			_sa().open_parcel()
			_check("%s: '%s' parcel opened once, in the diary" % [name, id], str(_sa().data["parcel"]["state"]) == "inspected" and _diary().contains(str(p["diary_opened"])) and not _sa().open_parcel())
		(entry["choices"] as Array).append({"id": id, "label": str(c.get("label", "")), "kind": str(c.get("kind", "")), "text": str(c.get("text", "")),
			"about": str(c.get("about", "")), "ack": str(c.get("ack", "")), "diary": _diary(), "cost": cost, "pay": pay})
	if dump_path != "":
		dump.append(entry)


# --- 1. The date --------------------------------------------------------------------------------------------------

func _dates() -> void:
	_past({"origin": "security", "security_exit": "forward"}, "renew", ["leave"])
	var log := _go_log(SecondAutumn.FROM + 2)
	var said := func(d: int) -> String: return str((log.get(d, ["", "", ""]) as Array)[2])
	var before := true
	for d in range(330, 367):
		if said.call(d) != "":
			before = false
	_check("date: nothing before October 2 (day 367)", before)
	_check("date: the practical morning on October 2, once", said.call(367) != "" and _sa().world_moment().get("day", -1) == 367
		and said.call(368) == "" and said.call(369) == "")
	_check("date: nothing on Davy's day or the morning after (370, 371)", said.call(370) == "" and said.call(371) == "")
	_check("date: the scene on October 7 (day 372), once", said.call(372).contains("letter") and _sa().route_id() == "a_deposit"
		and int(_sa().data["delivered"]) == 372 and said.call(373) == "" and _count_mail(SecondAutumn.POST) == 1)
	_check("date: the September note's morning keeps to itself (day 359)", str((log[359] as Array)[1]) != "" and said.call(359) == "")
	# Nothing on All Hallows and the days either side, even when a scene first could come then (a late save).
	_past({"origin": "security", "security_exit": "forward"}, "renew", ["leave"])
	m.day = 393
	var late := _go_log(400)
	var quiet := true
	for d in [395, 396, 397]:
		if str((late[d] as Array)[2]) != "":
			quiet = false
	_check("date: a late save: nothing on days 395-397; the scene and the morning come after", quiet and _sa().route_id() != "" and _sa().world_moment().size() > 0
		and int(_sa().data["delivered"]) not in [395, 396, 397] and int(_sa().world_moment()["day"]) not in [395, 396, 397] and int(_sa().data["delivered"]) != int(_sa().world_moment()["day"]))
	# A spring still open (a letter unanswered past day 372) is waited for.
	_past({"origin": "household"}, "ask")
	_go(m.day)
	m.past_spring.data["stage_by"]["first"] = 380
	_to(375)
	_check("date: a spring letter still waiting on an answer is waited for", _sa().route_id() == "" and m.past_spring.awaiting_player())
	_through("close")
	_to(390)
	_check("date: and the scene comes once it is settled", _sa().route_id() == "c_keepsake")
	# Ignored: it stays, with no reminders.
	_past({"origin": "work"}, "explain", ["method"])
	var notes := _to(520)
	_check("date: ignored for months it stays, with no reminder", _sa().state() == "delivered" and notes.count("old job") <= 1 and _count_mail(SecondAutumn.POST) == 1)


# --- 2. Origin A: The Cost of a Room ------------------------------------------------------------------------------

func _security() -> void:
	_every_choice("A deposit on account", func() -> void: _past({"origin": "security", "security_exit": "forward"}, "renew", ["leave"]), "a_deposit")
	_past({"origin": "security", "security_exit": "extension"}, "end", ["leave"])
	_to()
	_check("A: the letting office writes when the player asked for more time", str(_sa().route()["sender"]) == "From the letting office")
	_past({"origin": "security", "security_exit": "forward"}, "renew", ["sign"])
	_to()
	_check("A: a settled deposit gets no new debt: the desk, the account closed", _sa().route_id() == "a_desk" and _body().contains("The old account is closed")
		and not _body().contains("owed by you") and _count_mail(SecondAutumn.POST) == 0)
	_every_choice("A boxes opened, sent on", func() -> void: _past({"origin": "security", "security_exit": "stored", "contact": "friend"}, "ship", ["send_on", "open:boxes"]), "a_send_on")
	_past({"origin": "security", "security_exit": "stored", "contact": "friend"}, "ship", ["send_on"])
	_to()
	_check("A: the keeper's letter names the seed catalogue only because it came", _body().contains("seed catalogue") and str(_sa().route()["sender"]).contains("your friend"))
	_every_choice("A boxes shut", func() -> void: _past({"origin": "security", "security_exit": "stored"}, "ship", ["thanks"]), "a_desk")
	_past({"origin": "security", "security_exit": "stored"}, "ship", ["thanks"])
	_to()
	_check("A: boxes that came and were never opened are 'still shut', with a way to open them", _body().contains("still shut") and _labels().has("open_boxes")
		and not _body().contains("the kettle"))
	_answer("open_boxes")
	_check("A: opening them goes through the spring's own parcel (once)", m.past_spring.parcel_state("boxes") == "inspected" and _diary().contains("opened the two boxes"))
	_past({"origin": "security", "security_exit": "stored"}, "ship", ["thanks", "open:boxes"])
	_to()
	_check("A: boxes opened: the scene revisits what was in them", _body().contains("the winter coat, the plates") and not _labels().has("open_boxes"))
	_every_choice("A papers kept in a drawer", func() -> void: _past({"origin": "security", "security_exit": "stored"}, "release", [""]), "a_papers")
	_past({"origin": "security", "security_exit": "stored"}, "release", ["burn"])
	_to()
	_check("A: boxes given away: no boxes in the house", _body().contains("went to the charity shop") and not _body().contains("still shut") and not _body().contains("coat"))
	_past({"origin": "security", "security_exit": "forward"}, "renew", ["sign"])
	m.estate.deed_paid = 3000
	_to()
	_check("A: the deed as it stands, never 'owned' unless paid", _body().contains("You've paid 3000") and not _body().contains("is paid."))


# --- 3. Origin B: Work That Belonged to Everyone -----------------------------------------------------------------

func _work() -> void:
	_every_choice("B paid work", func() -> void: _past({"origin": "work"}, "explain", ["take", "do"]), "b_paid")
	_past({"origin": "work"}, "explain", ["take", "do"])
	_to()
	_check("B paid: a final accounting, and a question, not a job", _body().contains("20 coins paid in May") and _body().contains("might say no") and not _body().contains("I could pay you"))
	_every_choice("B paid, boundary", func() -> void: _past({"origin": "work", "work_exit": "boundary"}, "explain", ["take", "do"]), "b_paid")
	_past({"origin": "work", "work_exit": "boundary"}, "explain", ["take", "do"])
	_to()
	_check("B boundary: no new request at all", _body().contains("not asking") and not _body().contains("write to you again") and not _labels().has("ask_first"))
	_every_choice("B method sent", func() -> void: _past({"origin": "work"}, "explain", ["method"]), "b_method")
	_every_choice("B declined", func() -> void: _past({"origin": "work", "work_exit": "instructions"}, "explain", ["decline"]), "b_closed")
	_past({"origin": "work", "work_exit": "instructions"}, "explain", ["decline"])
	_to()
	_check("B declined: a closing note, no demand; their sheet only because it was left", _body().contains("No need to answer") and _body().contains("instruction sheet")
		and not _body().contains("coins"))
	_every_choice("B never answered", func() -> void: _past({"origin": "work"}, "explain", [""]), "b_desk")
	_past({"origin": "work"}, "explain", [""])
	m.woodwork.hewn = 12
	_to()
	_check("B unanswered: private, the planks from the bench's own count", _body().contains("12 planks") and _sa().data["medium"] == "desk")


# --- 4. Origin C: A House With One Less Person -------------------------------------------------------------------

func _household() -> void:
	var told := {"origin": "household", "household_relation": "partner", "household_change": "separate", "keepsake": "notebook"}
	_every_choice("C held to September", func() -> void: _past(told, "ask", ["time"]), "c_held")
	_every_choice("C writing now and then", func() -> void: _past(told, "ask", ["write"]), "c_letter")
	_every_choice("C never answered", func() -> void: _past(told, "ask", [""]), "c_unanswered")
	_every_choice("C closed, notebook", func() -> void: _past(told, "ask", ["close"]), "c_keepsake")
	_past(told, "ask", ["close"])
	_to()
	_check("C closed: no letter reopens it; a keepsake at the desk", _sa().data["medium"] == "desk" and _count_mail(SecondAutumn.POST) == 0 and _body().contains("notebook"))
	var private := {"origin": "household", "household_relation": "private", "household_change": "private", "keepsake": "postcard"}
	_every_choice("C private, held", func() -> void: _past(private, "ask", ["time"]), "c_held")
	_past(private, "ask", ["time"])
	_to()
	var r := _sa().route()
	_check("C private: never who, never why", str(r["sender"]) == "From someone at the house you left" and not _body().contains("partner") and not _body().contains("separate"))
	_every_choice("C boxes sent, shut", func() -> void: _past(private, "ask", ["send_mine"]), "c_keepsake")
	_past(private, "ask", ["send_mine"])
	_to()
	_check("C sent but shut: 'still shut', a way to open them, the postcard", _body().contains("still shut") and _labels().has("open_house_boxes") and _labels().has("finish"))
	_past({"origin": "household", "keepsake": "none"}, "no_need", ["close"])
	_to()
	_check("C nothing kept: told as nothing, no keepsake invented", _body().contains("didn't bring anything") and not _body().contains("photograph"))


# --- 5. Origin D: The Place in the Photograph --------------------------------------------------------------------

func _curiosity() -> void:
	_every_choice("D no contact", func() -> void: _past({"origin": "curiosity", "contact": "none"}, "keep", ["keep"]), "d_photo")
	_past({"origin": "curiosity", "contact": "none"}, "keep", ["keep"])
	_to()
	_check("D no contact: complete, private, nobody made up", _sa().data["medium"] == "desk" and not _labels().has("write") and _body().contains("still open ground")
		and _body().contains("haven't been far"))
	_worked_farm()
	m.town.visits = 3
	_check("D: the photograph against today's facts (house, field, woods)", _body().contains("new shingles") and _body().contains("46 crops") and _body().contains("trail there for timber"))
	_past({"origin": "curiosity", "contact": "none"}, "keep", [""])
	_to()
	_check("D: an untouched photograph is said to be untouched", _body().contains("haven't written anything beside it"))
	var who := {"origin": "curiosity", "contact": "friend"}
	_every_choice("D wrote about a place", func() -> void:
		_winter(who, "unsaid")
		_spring()
		m.town.visits = 2
		_through("place")
		_read_all(), "d_photo")
	_winter(who, "unsaid")
	_spring()
	m.town.visits = 2
	_through("place")
	_to()
	_check("D contact: the letter can go to the person who saw them off", _labels().has("write") and _body().contains("wrote to your friend"))
	_answer("write")
	_check("D contact: their answer refers to exactly what they were told", _sa().data["ack"]["text"].contains("Wicker Cove") and _diary().contains("They wrote back"))
	_past(who, "unsaid", [""])
	_to()
	_check("D contact unanswered in spring: said so", _body().contains("didn't answer the spring letter"))


# --- 6. Origin E: A Chance Before It Closed ----------------------------------------------------------------------

func _chance() -> void:
	_every_choice("E order kept for collection", func() -> void: _past({"origin": "chance", "chance_loose_end": "order"}, "hold", ["collect"]), "e_collect")
	_every_choice("E meeting in the autumn", func() -> void: _past({"origin": "chance", "chance_loose_end": "meeting"}, "spring", ["autumn"]), "e_meeting")
	_past({"origin": "chance", "chance_loose_end": "meeting"}, "spring", ["autumn"])
	_to()
	_check("E meeting: their availability, and no trip is asked of the player", _body().contains("Saturday in November") and not _labels().has("go"))
	_every_choice("E on next year's list", func() -> void: _past({"origin": "chance", "chance_loose_end": "work_offer"}, "list", ["not_this_year"]), "e_desk")
	_past({"origin": "chance", "chance_loose_end": "work_offer"}, "list", ["not_this_year"])
	_to()
	_check("E list: no letter that contradicts 'we write in August'; the list told truly", _count_mail(SecondAutumn.POST) == 0 and _body().contains("they write in August"))
	_past({"origin": "chance", "chance_loose_end": "work_offer"}, "close", [""])
	_to()
	_check("E closed offer: the fact stands", _body().contains("was filled") and not _labels().has("off"))
	_every_choice("E storage shut", func() -> void: _past({"origin": "chance", "chance_loose_end": "storage"}, "send", []), "e_desk")
	_past({"origin": "chance", "chance_loose_end": "storage"}, "send", [])
	_to()
	_check("E storage here, unopened: 'still shut', and openable", _body().contains("still shut") and _labels().has("open_unit"))
	_every_choice("E address kept", func() -> void: _past({"origin": "chance", "chance_loose_end": "meeting"}, "close", ["keep"]), "e_desk")
	_past({"origin": "chance", "chance_loose_end": "order"}, "refund", ["no"])
	_to()
	_check("E order cancelled: no parcel, nothing said to have come", _body().contains("cancelled") and not _body().contains("unwrapped"))


# --- 7. The September page -----------------------------------------------------------------------------------------

func _refl_case(id: String, farm: Callable) -> String:
	_past({"origin": "security", "security_exit": "forward"}, "renew", ["leave"])
	_go(FirstSeptember.FROM)
	if id != "":
		m.first_september.write(id)
	farm.call()
	_to()
	_answer("sign")
	return _diary()


func _reflections() -> void:
	var none := func() -> void: pass
	var d := _refl_case("", none)
	_check("September unwritten: the scene still comes and answers, with no quote", _sa().answered() and not d.contains("I wrote, \"") and not d.contains("year's page"))
	d = _refl_case("finish", func() -> void: m.house_stage = 3)
	_check("finish, house finished since: said so", d.contains("At the end of September I wrote, \"There is still work on this house") and d.contains("Since then the house has been finished"))
	d = _refl_case("finish", none)
	_check("finish, nothing done since: the work is still there", d.contains("The house is as it was then"))
	d = _refl_case("keep", none)
	_check("keep, the account closed by signing: 'This one I closed.'", d.contains("I want to keep some part of my old life.") and d.contains("This one I closed."))
	d = _refl_case("unknown", none)
	_check("unknown: no fear, a plain fact", d.contains("I don't know what next year will bring.") and d.contains("This letter is part of what it has brought.") and not d.to_lower().contains("afraid"))
	d = _refl_case("unsettled", none)
	_check("unsettled, the deposit was open and is settled now", d.contains("There are things from before that I haven't settled yet.") and d.contains("This was one of them. It is settled now."))
	d = _refl_case("stay", none)
	_check("stay: still here, no promise claimed", d.contains("I want to see what happens if I stay.") and d.contains("I'm still here, 37") and not d.contains("forever"))
	# The same kind of moment, two closings: the same scene's diary differs only by the September line.
	var a := _refl_case("keep", none)
	var b := _refl_case("unsettled", none)
	_check("two closings change the same moment's diary", a != b and a.contains("I signed the slip") and b.contains("I signed the slip"))
	if dump_path != "":
		dump.append({"name": "Two September closings, one scene (A deposit, signed)", "route": "a_deposit", "title": "", "medium": "", "sender": "", "body": "",
			"choices": [{"id": "keep", "label": "(closing: keep)", "kind": "", "text": "", "about": "", "ack": "", "diary": a, "cost": 0, "pay": 0},
				{"id": "unsettled", "label": "(closing: unsettled)", "kind": "", "text": "", "about": "", "ack": "", "diary": b, "cost": 0, "pay": 0}]})
	# Written late: after the scene came but before the answer, told with its real date; after the answer, not at all.
	_past({"origin": "security", "security_exit": "forward"}, "renew", ["leave"])
	_to(380)
	m.first_september.write("stay")
	_answer("sign")
	_check("September written late (Oct 15): told as written then, never 'at the end of September'", _diary().contains("On October 15 I finished the year's page with")
		and not _diary().contains("At the end of September") and _sa().data["reflection"].is_empty())
	_past({"origin": "security", "security_exit": "forward"}, "renew", ["leave"])
	_to()
	_answer("sign")
	m.first_september.write("stay")
	_check("September written after the answer: the answer's entry doesn't claim it", not _diary().contains("finished the year's page") and not _diary().contains("I wrote, \""))
	_check("the September page is never rewritten", m.first_september.reflection() == "stay" and str(m.first_september.data["words"]) == "I want to see what happens if I stay.")


# --- 8. Deadlines, coins, duplicates --------------------------------------------------------------------------------

func _deadlines() -> void:
	_past({"origin": "household", "household_relation": "friend"}, "ask", ["time"])
	_to()
	var by := int(_sa().data["by"])
	_check("deadline: a sender's date, 21 days, clear of the busy days", by == SecondAutumn.FROM + 21 and not SecondAutumn.busy(by) and _sa()._body(_sa().route()).contains("October 28"))
	var money := m.money
	_to(by - 1)
	_check("deadline: still open the day before", _sa().state() == "delivered")
	_to(by)
	_read_all()
	_check("deadline: on the day it lapses, by their terms", _sa().state() == "lapsed" and _diary().contains("took my boxes to the charity shop") and m.money == money
		and _count_mail(SecondAutumn.LAPSE_POST) == 1)
	_check("deadline: nothing to answer afterwards", not _sa().answer("send") and _sa().desk_rows().size() == 1)
	_past({"origin": "chance", "chance_loose_end": "order"}, "hold", ["collect"])
	_to()
	money = m.money
	_to(int(_sa().data["by"]) + 2)
	_check("deadline: the shop cancels and returns the deposit, 12 coins, once", _sa().state() == "lapsed" and m.money == money + 12)
	_check("deadline: reloading never pays it twice", _round_trip() and m.money == money + 12 and _count_mail(SecondAutumn.LAPSE_POST) == 1)
	_go(m.day + 30)
	_check("deadline: later mornings pay nothing more", m.money == money + 12)
	# Not enough coins: the row says so; nothing happens.
	_past({"origin": "household"}, "ask", ["time"])
	_to()
	m.money = 5
	var rows := _sa().desk_rows().filter(func(r: Dictionary) -> bool: return str(r.get("action", "")) == "autumn:answer|send")
	_check("coins: a reply that needs coins is shown as needing them, and refused", rows.size() == 1 and not bool(rows[0]["enabled"]) and not _sa().answer("send") and m.money == 5)
	m.money = 500
	# Duplicates: the answer, its coins, its letter and its parcel once, across reloads at each point.
	_past({"origin": "security", "security_exit": "forward"}, "renew", ["leave"])
	_to()
	_check("dupes: before answering, a reload keeps one letter, waiting", _round_trip() and _count_mail(SecondAutumn.POST) == 1 and _sa().state() == "delivered")
	money = m.money
	_sa().answer("sign")
	_check("dupes: during (answer in the post), a reload keeps it", _round_trip() and _sa().answered() and int(_sa().data["ack"]["delivered"]) < 0)
	_check("dupes: answering again is refused", not _sa().answer("sign") and not _sa().answer("close"))
	_go(int(_sa().data["ack"]["due"]))
	_check("dupes: after, the 24 coins once", m.money == money + 24 and _round_trip() and m.money == money + 24 and _count_mail(SecondAutumn.ACK_POST) == 1)
	_go(m.day + 40)
	_check("dupes: no second letter or payment later", m.money == money + 24 and _count_mail(SecondAutumn.ACK_POST) == 1 and _count_mail(SecondAutumn.POST) == 1)
	# Reading takes no time; answering takes no time.
	_past({"origin": "work"}, "explain", ["method"])
	_to()
	var clock := m.clock
	var hour := m.current_hour
	_sa().answer("keep")
	_check("time: answering takes no time", m.clock == clock and m.current_hour == hour)
	# No skills, sanity, items or friendship from any of it.
	_past({"origin": "household"}, "ask", ["write"])
	_to()
	var sanity: float = m.sanity
	var bag := JSON.stringify(m.inventory)
	var hearts := JSON.stringify(m.folk.bonus)
	_answer("farm")
	_check("nothing given: sanity, pack and friendship unchanged", m.sanity == sanity and JSON.stringify(m.inventory) == bag and JSON.stringify(m.folk.bonus) == hearts)


# --- 9. The practical morning ---------------------------------------------------------------------------------------

func _world_case(farm: Callable) -> Array:
	_setup({"status": "legacy"}, 360)
	farm.call()
	_go(368)
	var w := _sa().world_moment()
	return [str(w.get("id", "")), str(w.get("line", "")), _diary()]


func _world() -> void:
	var w := _world_case(func() -> void: m.woodwork.repairs[str(TownData.INN_REPAIR["id"])] = {"day": 250, "cost": {}})
	_check("world: Edith's repair, only with its record", w[0] == "inn" and str(w[1]).contains("inn in Wicker Cove") and str(w[2]).contains("In June"))
	w = _world_case(func() -> void: m.house_stage = 3)
	_check("world: the house as repaired", w[0] == "house:3" and str(w[1]).contains("restored"))
	w = _world_case(func() -> void: m.woodwork.hewn = 7)
	_check("world: the planks from the bench's count", w[0] == "hewn" and str(w[1]).contains("made 7"))
	w = _world_case(func() -> void: m.folk.requests_done["maren_eggs"] = 80)
	_check("world: a walker's errands, never 'friend'", str(w[0]).begins_with("asked:") and not str(w[1]).to_lower().contains("friend"))
	w = _world_case(func() -> void: m.town.visits = 4)
	_check("world: Wicker Cove visits", w[0] == "cove" and str(w[1]).contains("4 times"))
	w = _world_case(func() -> void: pass)
	_check("world: a farmer who stayed close is not criticised", w[0] == "farm" and str(w[1]).contains("still unfamiliar") and not str(w[1]).contains("should"))
	_check("world: a legacy save gets the morning but no past", _sa().route_id() == "" and not str(w[2]).contains("old room"))
	_go(380)
	_check("world: once only", _sa().world_moment()["day"] == 367)
	if dump_path != "":
		dump.append({"name": "The practical morning (six farms)", "route": "world", "title": SecondAutumnScript.WORLD_TITLE, "medium": "morning", "sender": "", "body": "",
			"choices": []})
		for f in [["inn", func() -> void: m.woodwork.repairs[str(TownData.INN_REPAIR["id"])] = {"day": 250, "cost": {}}], ["house", func() -> void: m.house_stage = 2],
				["hewn", func() -> void: m.woodwork.hewn = 7], ["asked", func() -> void: m.folk.requests_done["maren_eggs"] = 80],
				["cove", func() -> void: m.town.visits = 4], ["farm", func() -> void: pass]]:
			var x := _world_case(f[1])
			(dump[-1]["choices"] as Array).append({"id": f[0], "label": "morning", "kind": "", "text": str(x[1]).strip_edges(), "about": "", "ack": "", "diary": str(x[2]), "cost": 0, "pay": 0})


# --- 10. Saving ---------------------------------------------------------------------------------------------------

func _saving() -> void:
	_past({"origin": "household", "household_relation": "family"}, "ask", ["time"])
	_to()
	var rec := JSON.stringify(_sa().to_save())
	_check("save: waiting, the record loads exactly", _round_trip() and JSON.stringify(_sa().to_save()) == rec)
	_sa().answer("send")
	rec = JSON.stringify(_sa().to_save())
	_check("save: answered, the record loads exactly", _round_trip() and JSON.stringify(_sa().to_save()) == rec)
	_go(int(_sa().data["ack"]["due"]))
	_read_all()
	var pages := _diary()
	_check("save: after the answer and the parcel, the diary loads the same", _round_trip() and _diary() == pages and str(_sa().data["parcel"]["state"]) == "received")
	m.house_stage = 3
	m.day += 30
	_check("save: later changes on the farm never alter what was written", _diary().contains(str(_sa().data["said"])) and _diary() == pages)
	# A v21 save (no second_autumn): loads, nothing made for the player yet; the scene comes on its own morning.
	_past({"origin": "work"}, "explain", ["method"])
	_go(SecondAutumn.FROM - 1)
	m.saver._save_game()
	var path := TitleMenu.slot_path(SLOT)
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	data.erase("second_autumn")
	data["save_version"] = 21
	var fa := FileAccess.open(path, FileAccess.WRITE)
	fa.store_string(JSON.stringify(data))
	fa.close()
	_check("save: a v21 save loads with nothing made", m.saver._load_game() and _sa().to_save().is_empty())
	_go(SecondAutumn.FROM)
	_check("save: and the scene comes from its own records", _sa().route_id() == "b_method")
	_sa().from_save("garbage")
	_check("save: garbage is dropped", _sa().to_save().is_empty())
	_sa().from_save({"route": "a_deposit", "origin": "security", "state": "delivered", "delivered": 372})
	_check("save: a scene for another origin is dropped", _sa().route_id() == "")
	_sa().from_save({"route": "x_unknown", "origin": "work", "state": "delivered", "delivered": 372})
	_check("save: an unknown scene is dropped", _sa().route_id() == "")
	_sa().from_save({"route": "b_method", "origin": "work", "state": "answered", "delivered": 372, "world": {"day": 367, "line": " x", "diary": "y"}})
	_check("save: an answer with no choice in it goes back to waiting; the morning kept", _sa().state() == "delivered" and _sa().world_moment()["day"] == 367)


func _legacy() -> void:
	_setup({"status": "legacy"}, 300)
	_go(400)
	_check("legacy: no past is ever made up", _sa().route_id() == "" and _count_mail(SecondAutumn.POST) == 0 and not _diary().contains("before"))
	_setup({"status": "none"}, 300)
	_go(400)
	_check("legacy: a world with no interlude gets no scene", _sa().route_id() == "")
	# A complete origin whose winter was missed: a private scene from the road alone.
	_setup({"origin": "chance", "chance_loose_end": "storage"}.merged({}), 200)
	m.past_post.from_save({"v": 1, "state": "missed"})
	_go(SecondAutumn.FROM)
	_check("origin with no winter or spring: still a scene, from the road only", _sa().route_id() == "e_desk" and not _body().contains("cartons") and _body().contains("Wednesday"))


# --- 11. The real day, Davy and the Hollow -------------------------------------------------------------------------

func _next_day() -> void:
	m.tax_owed = 0
	m.tax_stage = 0
	m._end_day("Test.", false)


func _story() -> String:
	return JSON.stringify({"beats": m.act.beats, "meeting": m.act.meeting, "davy": m.act.davy, "davy_day": m.act.davy_day, "endings": m.act.endings})


# One story, played twice from the same saved morning: once with the save's past, once with the past taken away
# (a legacy farm). Everything else is identical, so any difference in the story would be this system's.
func _story_start() -> void:
	_past({"origin": "household", "household_relation": "friend"}, "ask", ["time"])
	m.act.beats.clear()
	m.act.beats["letter"] = 240
	m.act.beats["shown"] = 250
	m.act.beats["orchard"] = 270
	m.act.meeting = ""
	m.act.meeting_there = false
	m.act.davy = ""
	m.act.davy_day = -1
	m.act.hollow_left = 0
	m.act.knock_from = -1
	m.act.pending = ""
	m.act.endings.clear()
	m.sanity = m.SANITY_MAX
	m.money = 500
	m.day = 362
	m.saver._save_game()


func _story_run(past: bool) -> Array:
	m.saver._load_game()
	if not past:
		m.origin = OriginState.new({"v": 1, "status": "legacy"})
		m.past_post.reset()
		m.past_spring.reset()
		m.first_september.reset()
		m.second_autumn.reset()
		m.desk_mail = []
	seed(20261117)
	var notes := {}
	while m.day < 399:
		_next_day()
		notes[m.day] = m.morning_report
		if m.day == StoryAct.DAVY_FROM:
			m.current_hour = 20.5
			notes["davy"] = [m.act._davy_waiting(), m.open_tab, m.act.davy_day]
			m.current_hour = 10.0
	return [notes, _story()]


func _real_day() -> void:
	_story_start()
	var with := _story_run(true)
	var notes: Dictionary = with[0]
	var ours := func(d: int) -> bool:
		var t := str(notes.get(d, ""))
		return t.contains("hall cupboard") or t.contains("A year ago") or t.contains("personal letter") or t.contains("papers from before")
	_check("real day: the practical morning on October 2 (367)", str(notes.get(367, "")).contains("A year ago") or str(notes.get(367, "")).contains("a year since"))
	_check("real day: the scene's letter on October 7 (372)", str(notes.get(372, "")).contains("personal letter") and _sa().route_id() == "c_held")
	_check("real day: nothing of this on Davy's day or the morning after", not ours.call(370) and not ours.call(371))
	_check("real day: nothing of this on the three days around All Hallows", not ours.call(395) and not ours.call(396) and not ours.call(397))
	var davy: Array = notes.get("davy", [false, "?", -1])
	_check("real day: at 20:00 on Davy's day nothing is open; he can be found", int(davy[2]) == StoryAct.DAVY_FROM and bool(davy[0]) and str(davy[1]) == "",
		str(davy))
	print("   (the original story on this save, as it ran: %s)" % with[1])
	var without := _story_run(false)
	_check("real day: the story's state is identical with and without a past", str(with[1]) == str(without[1]), "%s vs %s" % [with[1], without[1]])
	_check("real day: Davy found or lost stays the story's own (his night passed by its own rules)", m.act.davy in ["stopped", "lost", ""])
	_check("real day: the story's dates are untouched", StoryAct.FROM == 240 and StoryAct.HARVEST_MOON == 357 and StoryAct.DAVY_FROM == 370 and StoryAct.MEETING_FROM == 300
		and StoryAct.DAVY_FROM_HOUR == 20.0 and StoryAct.DAVY_UNTIL == 25.0)
	var story := FileAccess.get_file_as_string("res://scripts/story_act.gd") + FileAccess.get_file_as_string("res://scripts/mystery.gd") \
		+ FileAccess.get_file_as_string("res://scripts/night_system.gd") + FileAccess.get_file_as_string("res://scripts/ending_screen.gd")
	_check("real day: nothing in the story, nights or endings reads this (bell, grove, endings unchanged)", not story.contains("second_autumn") and not story.contains("SecondAutumn")
		and not story.contains("first_september"))
	var mine := FileAccess.get_file_as_string("res://scripts/second_autumn.gd") + FileAccess.get_file_as_string("res://scripts/second_autumn_script.gd")
	_check("real day: this never writes the story, Davy, skills, sanity, the pack or friendship", not mine.contains("m.act.") and not mine.contains("davy =")
		and not mine.contains("m.sanity") and not mine.contains("m.folk.") and not mine.contains("m.skills") and not mine.contains("m.inventory") and not mine.contains("_add_item"))
	if m.act.screen != null:
		m.act.screen.active = false
		m.act.screen.visible = false
	m.act.beats.clear()
	m.act.meeting = ""
	m.act.davy = ""
	m.act.davy_day = -1
	m.act.pending = ""
	m.act.endings.clear()


# --- 12. Input ----------------------------------------------------------------------------------------------------

func _input() -> void:
	_past({"origin": "curiosity", "contact": "none"}, "keep", ["keep"])
	_to()
	m._toggle_tab("Desk")
	await _frames(3)
	_check("input: the desk opens with focus", m.open_tab == "Desk" and _focus() != null)
	var ok := await _focus_action("autumn:answer|note")
	await _key(KEY_SPACE)
	_check("input: Space on a choice answers it", ok and _sa().choice() == "note")
	_check("input: nothing disabled takes focus", _no_disabled_focus(m.action_bar.panel))
	await _key(KEY_ESCAPE)
	_check("input: Esc closes the desk", m.open_tab == "")
	_past({"origin": "curiosity", "contact": "none"}, "keep", ["keep"])
	_to()
	m._toggle_tab("Desk")
	await _frames(3)
	ok = await _focus_action("autumn:answer|file")
	await _pad(JOY_BUTTON_A)
	_check("input: Xbox A answers", ok and _sa().choice() == "file")
	for i in 3:
		if m.open_tab != "":
			await _pad(JOY_BUTTON_B)
	_check("input: B closes the desk (back one level at a time)", m.open_tab == "")
	_past({"origin": "curiosity", "contact": "none"}, "keep", ["keep"])
	_to()
	m._toggle_tab("Desk")
	await _frames(3)
	var entry: Button = null
	for e in _entries():
		if str(e.get_meta("action", "")) == "autumn:answer|leave":
			entry = e
	if entry != null:
		entry.grab_focus()
		await _frames(4)
		await _click(entry)
		var button := _button_named(m.action_bar.panel, "Choose")
		if button != null:
			await _click(button)
	_check("input: a mouse click on the choice, then its button", _sa().choice() == "leave", "entry %s, tab %s" % [entry != null, m.open_tab])
	for i in 3:
		if m.open_tab != "":
			await _key(KEY_ESCAPE)
	# The mailbox: a letter's answers are under it.
	_past({"origin": "security", "security_exit": "forward"}, "renew", ["leave"])
	_to()
	m.mail._open_mailbox()
	await _frames(3)
	ok = await _focus_action("autumn:answer|sign")
	await _key(KEY_SPACE)
	_check("input: the mailbox shows the letter's answers; one is written", m.open_tab == "Mailbox" and ok and _sa().choice() == "sign")
	for i in 3:
		if m.open_tab != "":
			await _key(KEY_ESCAPE)
	m.mail._clear_read_mail()
	_check("input: the answered letter can be cleared; nothing else waits", _count_mail(SecondAutumn.POST) == 0)
	# The diary book: the entry is in Notes, and no page scrolls.
	_go(int(_sa().data["ack"]["due"]))
	var ab: ActionBar = m.action_bar
	await _key(KEY_J)
	await _frames(3)
	var found := false
	for s in ab.book_sections.size():
		if str(ab.book_sections[s]["name"]) == "Notes":
			for p in ab.book_sections[s]["pages"].size():
				if str(ab.book_sections[s]["pages"][p]["title"]).begins_with(SecondAutumnScript.TITLE):
					found = true
					ab.open_book_at(s, p)
					await _frames(3)
	_check("input: J opens the diary; the entry is under Notes", ab.book.visible and found)
	_check("input: its page doesn't scroll", _book_scrolls() == "")
	await _key(KEY_ESCAPE)


func _book_scrolls() -> String:
	var ab: ActionBar = m.action_bar
	var sc := _find_scroll(ab.book)
	if sc == null:
		return ""
	var bar := sc.get_v_scroll_bar()
	return "scrolls" if bar != null and bar.visible and bar.max_value > bar.page + 1.0 else ""


func _find_scroll(n: Node) -> ScrollContainer:
	if n is ScrollContainer and (n as Control).is_visible_in_tree():
		return n
	for c in n.get_children():
		var f := _find_scroll(c)
		if f != null:
			return f
	return null


func _focus() -> Control:
	return root.gui_get_focus_owner()


func _entries() -> Array:
	return m.action_bar.list_box.get_children().filter(func(c: Node) -> bool: return c is Button)


func _focus_action(action: String) -> bool:
	for i in 80:
		if _focus() != null and str(_focus().get_meta("action", "")) == action:
			return true
		await _key(KEY_DOWN if i < 40 else KEY_UP)
	return false


func _no_disabled_focus(box: Node) -> bool:
	for child in box.get_children():
		var c := child as Control
		if c != null and c.focus_mode != Control.FOCUS_NONE and c.is_visible_in_tree() and c is BaseButton and (c as BaseButton).disabled:
			return false
		if not _no_disabled_focus(child):
			return false
	return true


func _button_named(box: Node, text: String) -> Button:
	for child in box.get_children():
		if child is Button and (child as Button).text == text and (child as Button).is_visible_in_tree():
			return child
		var found := _button_named(child, text)
		if found != null:
			return found
	return null


func _key(code: int) -> void:
	for pressed in [true, false]:
		var ev := InputEventKey.new()
		ev.physical_keycode = code
		ev.keycode = code
		ev.pressed = pressed
		Input.parse_input_event(ev)
		await _frames(1 if pressed else 2)


func _pad(button: int) -> void:
	for pressed in [true, false]:
		var ev := InputEventJoypadButton.new()
		ev.button_index = button
		ev.pressed = pressed
		ev.pressure = 1.0 if pressed else 0.0
		Input.parse_input_event(ev)
		await _frames(1 if pressed else 2)


func _screen(at: Vector2) -> Vector2:
	return root.get_final_transform() * at


func _click(c: Control) -> void:
	var at := c.get_global_rect().get_center()
	var mv := InputEventMouseMotion.new()
	mv.position = _screen(at)
	mv.global_position = mv.position
	Input.parse_input_event(mv)
	await _frames(2)
	for pressed in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = pressed
		ev.position = _screen(at)
		ev.global_position = ev.position
		Input.parse_input_event(ev)
		await _frames(2)


# --- The scenes document ----------------------------------------------------------------------------------------

func _write_dump() -> void:
	var out := PackedStringArray()
	out.append("# CCH-ORIGIN-005 — The Second Year Remembers: every scene, choice and outcome")
	out.append("")
	out.append("Generated from the game's own code by `tools/second_autumn_test.gd -- dump=AI_COLLAB/CCH_ORIGIN_005_SCENES.md`.")
	out.append("Each scene is shown as it came for the test's farm (bare unless noted), then each choice: what is written or done, the")
	out.append("sender's answer if any, and the diary as it stands after (the date first; no September page was written unless noted).")
	out.append("")
	for e in dump:
		out.append("## %s" % str(e["name"]))
		out.append("")
		if str(e["title"]) != "":
			out.append("**Route** `%s` · **%s** · %s%s" % [str(e["route"]), str(e["title"]), "a letter" if str(e["medium"]) == "mail" else str(e["medium"]),
				(" · " + str(e["sender"])) if str(e["sender"]) != "" else ""])
			out.append("")
		if str(e["body"]) != "":
			for line in str(e["body"]).split("\n"):
				out.append("> " + line)
			out.append("")
		for c in e["choices"]:
			out.append("- **%s** (`%s`%s)" % [str(c["label"]), str(c["id"]), (", %s" % str(c["kind"])) if str(c["kind"]) != "" else ""])
			if str(c["text"]) != "":
				out.append("  - Written: \"%s\"" % str(c["text"]))
			elif str(c["about"]) != "":
				out.append("  - %s" % str(c["about"]).replace("\n", " "))
			if int(c["cost"]) > 0 or int(c["pay"]) > 0:
				out.append("  - Coins: %d enclosed, %d back with the answer" % [int(c["cost"]), int(c["pay"])])
			if str(c["ack"]) != "":
				out.append("  - Their answer: \"%s\"" % str(c["ack"]))
			out.append("  - Diary: %s" % str(c["diary"]).replace("\n\n", " / "))
		out.append("")
	var f := FileAccess.open("res://" + dump_path, FileAccess.WRITE)
	if f != null:
		f.store_string("\n".join(out) + "\n")
		f.close()
		print("   (wrote %s: %d scenes)" % [dump_path, dump.size()])
