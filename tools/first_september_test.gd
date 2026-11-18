extends SceneTree

# CCH-ORIGIN-004: checks "One Year on the Road", the first September's diary page (FirstSeptember,
# FirstSeptemberScript). Run headless:  godot --path . --headless -s tools/first_september_test.gd
# Optional:  -- dump=AI_COLLAB/CCH_ORIGIN_004_SEPTEMBER.md   also writes every page variant played here to that file.
# It plays in save slot 9 and deletes that save when done (slots 1-3 are never touched). Each origin case plays the
# winter and the spring through PastPost's and PastSpring's real mornings and answers, then sets the farm, then reads
# the page on September 24 (day 359):
#   - the date: nothing on day 358, the page and one morning note from day 359, still there if ignored (into Year Two);
#   - five origins, each with its own words; the winter and spring as they really went; pending things still pending,
#     dated arrangements told as said, before and after their dates; parcels coming, shut or opened told as such;
#   - the farm: house stages (restored and not), harvests, the deed, planks, Edith's repair only when done, Wicker
#     Cove only when visited, walkers' errands, the woods; private relations kept private; the no-contact photograph;
#   - every closing line; written once, kept as written across loads and later changes; nothing given;
#   - legacy and v20 saves, damaged records; the real day (`_end_day`) through the Harvest Moon, the meeting and the
#     rollover into the second autumn; StoryAct untouched;
#   - input: the desk's Diary tab by keyboard, Xbox A and B, a mouse click; the diary book shows the section.
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
	create_timer(900.0).timeout.connect(func() -> void:
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
	_origins()
	_security()
	_work()
	_household()
	_curiosity()
	_chance()
	_farm()
	_closing()
	_saving()
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


# A worked farm: the house patched, a harvest, a walker's errand, the woods.
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
		note += m.past_post._morning() + m.past_spring._morning()
	return note


func _read_all() -> void:
	for l in m.desk_mail:
		if l.has("post") and bool(l["unread"]):
			m.past_post.read(str(l["post"]))
			m.past_spring.read(str(l["post"]))
		l["unread"] = false


func _winter(wants: Dictionary, id := "", id2 := "") -> void:
	_setup(wants)
	_go(PastPost.LETTER_DAY)
	_read_all()
	if id == "":
		_go(PastPost.ANSWER_BY + 1)
		return
	m.past_post.answer(id)
	_go(m.day + 1 + PastPost.ACK_DAYS)
	_read_all()
	if id2 != "":
		m.past_post.answer(id2)
		_go(m.day + 1 + PastPost.ACK_DAYS)
		_read_all()


func _spring() -> String:
	var note := ""
	for i in 400:
		if m.past_spring.active() or m.day > 420:
			break
		note += _go(m.day + 1)
	_read_all()
	return note


func _through(id: String) -> String:
	if not m.past_spring.answer(id):
		return "(not answered)"
	var out: Dictionary = m.past_spring.outgoing()
	if out.is_empty():
		return "(note)"
	_go(int(out["written"]) + 1 + PastSpring.ACK_DAYS)
	_read_all()
	return "(answered)"


# On to September 24 with the post's mornings, everything read.
func _to_sept(day := FirstSeptember.FROM) -> void:
	_go(day)
	_read_all()


func _page() -> String:
	return "\n\n".join(m.first_september.diary_pages().map(func(p: Dictionary) -> String: return str(p["text"])))


func _body() -> String:
	return m.first_september.page_text()


func _first_para() -> String:
	return " ".join(m.first_september.compose()["paras"][0])


# Records the page as it stands, for the variants document.
func _keep(name: String, note := "") -> void:
	if dump_path == "":
		return
	var text := _body() + ("

" + str(m.first_september.data["words"]) if m.first_september.written() else "")
	dump.append({"name": name, "note": note, "text": text, "options": m.first_september.options().map(
		func(o: Dictionary) -> String: return str(o["line"])), "pages": m.first_september.diary_pages().size() - 1})


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


# --- 1, 2. The date, and a page left unwritten -----------------------------------------------------------------

func _dates() -> void:
	_winter({"origin": "work"}, "explain")
	_spring()
	_through("method")
	_go(FirstSeptember.FROM - 1)
	m.first_september.reset()
	_check("date: nothing before September 24 (day 358): no page, no desk row, no note",
		m.first_september.diary_pages().is_empty() and m.first_september.desk_rows().is_empty() and m.first_september._morning() == "")
	m.day = FirstSeptember.FROM
	var note := m.first_september._morning()
	_check("date: September 24 (day 359): one morning note and the new-page dot", note.contains("almost a year") and m.diary_new.has(FirstSeptember.DIARY_ID))
	_check("date: the page is in the diary's own section", m.panels._diary_sections().any(func(s: Dictionary) -> bool:
		return str(s["name"]) == FirstSeptember.SECTION and str(s["heading"]) == "One Year on the Road"))
	_check("date: and at the desk's Diary tab, with closing lines to choose", m.first_september.desk_rows().size() >= 6)
	m.day = 360
	_check("date: the note is said once", m.first_september._morning() == "")
	m.day = 380
	_check("date: ignored into the second autumn, it is still there to write", not m.first_september.options().is_empty() and _page().contains("a year now") == false and _page().contains("more than a year"))
	m.day = 368
	_check("date: just after the year turns, it says so", _page().contains("a year now since"))
	m.day = 500
	_check("date: far into Year Two, still writable, and says it was meant for September", m.first_september.write("unknown") and _body().contains("I meant to write this in September"))
	# The Harvest Moon's morning never carries the note (an old save loaded that day).
	m.first_september.reset()
	m.day = StoryAct.HARVEST_MOON
	_check("date: nothing on the Harvest Moon's morning", m.first_september._morning() == "" and m.first_september.diary_pages().is_empty())


# --- 3. Five origins, five pages -------------------------------------------------------------------------------

func _origins() -> void:
	var firsts := {}
	var routes := [[{"origin": "security", "security_exit": "stored"}, "ship"], [{"origin": "work"}, "explain"],
		[{"origin": "household", "household_relation": "friend"}, "keep"], [{"origin": "curiosity", "contact": "friend"}, ""],
		[{"origin": "chance", "chance_loose_end": "meeting"}, "close"]]
	for r in routes:
		_winter(r[0], str(r[1]))
		_spring()
		_to_sept()
		_worked_farm()
		firsts[str(r[0]["origin"])] = _first_para()
	var distinct := {}
	for k in firsts:
		distinct[firsts[k]] = true
	_check("origins: five origins open with five different passages", distinct.size() == 5)
	var shared := false
	var keys: Array = firsts.keys()
	for i in keys.size():
		for j in range(i + 1, keys.size()):
			for s in str(firsts[keys[i]]).split(". "):
				if s.length() > 30 and not s.contains("almost a year") and str(firsts[keys[j]]).contains(s):
					shared = true
	_check("origins: no origin's sentence is another's with a word swapped in", not shared)


# --- 4-6. Each origin's past, as it really went ------------------------------------------------------------------

func _security() -> void:
	# Paid in the winter, came in March, opened, thanked.
	_winter({"origin": "security", "security_exit": "stored", "contact": "friend"}, "ship")
	_spring()
	m.past_spring.open_parcel("boxes")
	_through("thanks")
	_to_sept()
	_worked_farm()
	_check("A: the spring's line, as it happened", _body().contains("They came in March, and I wrote to say so."))
	_check("A: the rent notices, from the road", _body().contains("the old rent notice and the new one"))
	_check("A: the deed is never claimed when unpaid", _body().contains("The town still holds the deed.") and not _body().contains("mine on paper"))
	_check("A: the house as it is (patched, not restored)", _body().contains("new shingles") and not _body().contains("is restored"))
	_keep("A — boxes paid in winter, opened, thanked; house patched (stage 2), 46 crops")
	# The same boxes came but were never opened, nothing answered; the house untouched.
	_winter({"origin": "security", "security_exit": "stored"}, "ship")
	_spring()
	_to_sept()
	_check("A shut: boxes that came and were never opened are not called unpacked",
		_body().contains("I haven't opened them yet") and not _body().contains("unpack") and not _body().contains("I opened"))
	_check("A shut: an untouched house is said to be untouched", _body().contains("much as I found it") and not _body().contains("restored"))
	_check("A shut: nothing out of the field", _body().contains("Nothing has come out of the field yet."))
	_keep("A — boxes came, never opened, letter unanswered; house untouched, no harvest", "Promised vs delivered: the parcel is 'shut'.")
	# Held boxes, sent for in the spring, still with the carrier when the page is read.
	_winter({"origin": "security", "security_exit": "stored"}, "more_time")
	_spring()
	m.past_spring.answer("ship")
	_go(m.day + 1 + PastSpring.ACK_DAYS)
	_read_all()
	m.day = FirstSeptember.FROM
	_check("A coming: boxes paid for but not here are 'with the carrier', never unpacked",
		m.past_spring.parcel_state("boxes") == "dispatched" and _body().contains("haven't come yet") and not _body().contains("unpacked"))
	_check("A coming: the shipment is an open matter", m.first_september._open().has("parcel:boxes:dispatched"))
	# Arrived, opened: the same route's own line.
	_go(m.day + PastSpringScript.PARCEL_DAYS + 1)
	_read_all()
	m.past_spring.open_parcel("boxes")
	_check("A arrived: once opened, the route's own line", _body().contains("I unpacked them when they came") and not _body().contains("haven't come"))
	# Send on: a dated arrangement, told as said.
	_winter({"origin": "security", "security_exit": "stored"}, "ship")
	_spring()
	m.past_spring.open_parcel("boxes")
	_through("send_on")
	_to_sept()
	_check("A send on: the summer's arrangement is told as said, and as over", _body().contains("until the end of summer. The summer is over now."))
	_keep("A — boxes opened; asked them to send on post until summer's end")
	# The deposit, left unsigned: still on the account, and open.
	_winter({"origin": "security", "security_exit": "forward"}, "end")
	_spring()
	m.past_spring.answer("leave")
	_to_sept()
	_worked_farm()
	m.estate.deed_paid = 3000
	_check("A deposit unsigned: the money is still on the account, not settled", _body().contains("still on the account") and not _body().contains("settled now"))
	_check("A deposit unsigned: the deed paid in part is said as such", _body().contains("3000 of the town's 12000 coins"))
	_check("A forward road: its own opening", _first_para().contains("forwarding") or _first_para().contains("address written on a card"))
	_keep("A — forwarding road, deposit left unsigned; 3000 paid toward the deed")
	# Signed.
	_winter({"origin": "security", "security_exit": "forward"}, "end")
	_spring()
	_through("sign")
	_to_sept()
	_check("A deposit signed: settled", _body().contains("It is settled now."))


func _work() -> void:
	_winter({"origin": "work", "work_exit": "boundary"}, "explain")
	_spring()
	_through("take")
	m.current_hour = 9.0
	m.past_spring.answer("do")
	_go(m.day + 1 + PastSpring.ACK_DAYS)
	_read_all()
	_to_sept()
	_worked_farm()
	m.woodwork.repairs["inn_roof"] = {"day": 230, "cost": {}, "paid": 40}
	_check("B paid: the work they paid for", _body().contains("They paid for my time."))
	_check("B: the boundary they set, from the road", _first_para().contains("I couldn't keep doing it"))
	_check("B: planks from the workbench's own count", _body().contains("24 planks"))
	_check("B: Edith's paid repair, because it was done", _body().contains("Edith Vale") and _body().contains("May"))
	_keep("B — told them 'I can't keep doing this'; checked the March sheets for pay; Edith's repair done, 24 planks")
	_winter({"origin": "work", "work_exit": "instructions"}, "explain")
	_spring()
	_through("ask")
	_through("decline")
	_to_sept()
	_check("B declined: someone else took it", _body().contains("Someone else did."))
	_check("B: no Edith without the repair", not _body().contains("Edith"))
	_keep("B — left instructions; asked once, then declined; untouched farm")
	_winter({"origin": "work"}, "explain")
	_spring()
	_through("method")
	_to_sept()
	_check("B method: sent back, and the later letter that it worked", _body().contains("They wrote later that it worked."))


func _household() -> void:
	_winter({"origin": "household", "household_relation": "partner", "household_change": "separate", "keepsake": "notebook"}, "ask")
	_spring()
	m.past_spring.open_parcel("key")
	_through("time")
	_to_sept()
	_worked_farm()
	_check("C more time: pending until the end of September, as said", _body().contains("I asked for more time. They agreed until autumn.")
		and _body().contains("until the end of September") and not _body().contains("September has gone"))
	_check("C: the relation and change, told because the player told them", _first_para().contains("someone I loved") and _first_para().contains("live separately"))
	_check("C: the keepsake as the road described it", _body().contains("a small notebook"))
	_check("C: a walker's errand, without calling them a friend", _body().contains("Maren asked me for eggs for the mill") and not _body().to_lower().contains("friend"))
	_check("C more time: an open matter", m.first_september._open().any(func(s: String) -> bool: return s.begins_with("until:")))
	_keep("C — partner, separated; the key came; asked for more time (until Sept 30); a notebook; Maren's eggs")
	m.day = 370
	_check("C more time: after September, told as what they said, not as kept", _body().contains("September has gone, and I haven't written since."))
	# Private: nothing of who.
	_winter({"origin": "household", "household_relation": "private", "contact": "private"}, "keep")
	_spring()
	_through("close")
	_to_sept()
	var t := _body().to_lower()
	_check("C private: the relation stays private", t.contains("shared with someone.") and not t.contains("loved") and not t.contains("partner")
		and not t.contains("family") and not t.contains("a friend"))
	_check("C private: no reason given when none was told", not t.contains("separately") and not t.contains("somewhere else"))
	_check("C closed: the clock and the books decided", _body().contains("That was the last thing left."))
	_keep("C — relation kept private, contact private; settled who keeps what")
	# Boxes sent for, and opened.
	_winter({"origin": "household", "household_relation": "family"}, "keep")
	_spring()
	_through("send_mine")
	_go(m.day + PastSpringScript.PARCEL_DAYS + 1)
	_read_all()
	_to_sept()
	_check("C boxes came but shut: said so", m.past_spring.parcel_state("house_boxes") == "received" and _body().contains("I haven't opened them yet"))
	m.past_spring.open_parcel("house_boxes")
	_check("C boxes opened: the route's line", _body().contains("My boxes came in the spring"))


func _curiosity() -> void:
	_setup({"origin": "curiosity", "contact": "friend", "curiosity_interest": "growing"})
	m.stats["crop_pumpkin"] = 4
	_go(PastPost.LETTER_DAY)
	_read_all()
	m.past_post.answer("crops")
	_go(m.day + 1 + PastPost.ACK_DAYS)
	_spring()
	m.town.visits = 3
	_through("place")
	_to_sept()
	_worked_farm()
	m.town.visits = 3
	_check("D contact: what was written about, as told", _body().contains("I wrote to them about the village down the hill road, Wicker Cove."))
	_check("D: the photograph and the hope, from the road", _first_para().contains("photograph in a notice") and _first_para().contains("grow something"))
	_check("D: the photograph against the house now, not called better", _body().contains("It isn't the house in the picture any more.") and not _body().contains("better"))
	_check("D: the walker's errand outranks the village in the farm's half", _body().contains("Maren asked me for eggs"))
	_keep("D — a friend wrote; told them about Wicker Cove; house patched; 3 visits to the Cove")
	# No contact, the photograph at the desk, compared.
	_winter({"origin": "curiosity", "contact": "none", "curiosity_interest": "quiet"}, "keep")
	_spring()
	m.house_stage = 1
	m.woodwork.repairs["house_1"] = {"day": 170, "cost": {}}
	m.stats["harvested"] = 10
	m.stats["crop_kale"] = 10
	m.past_spring.answer("compare")
	_to_sept()
	_check("D no contact: complete without letters", _body().contains("Beside it I wrote what had changed since I came.") and not _body().to_lower().contains("letter"))
	_check("D no contact: no Wicker Cove when never visited", not _body().contains("Wicker Cove"))
	_keep("D — no one saw them off; compared the photograph with the farm; house boarded (stage 1), 10 kale", "No-contact variation.")
	_winter({"origin": "curiosity", "contact": "none", "curiosity_interest": "exploring"}, "keep")
	_spring()
	_go(m.day + 40)
	_to_sept()
	m.trek.edge_done = true
	_check("D no contact, untouched: the photograph is still in the desk", _body().contains("still in the desk. I haven't written anything beside it."))
	_check("D: the woods' edge, and no further", _body().contains("where the woods begin, and no further"))
	_keep("D — no contact; the photograph left untouched; walked to the wood's edge only", "No-contact, nothing written.")


func _chance() -> void:
	_winter({"origin": "chance", "chance_loose_end": "order"}, "hold")
	_spring()
	_through("collect")
	_to_sept()
	_check("E for collection: kept at the shop until the end of September (before the date)",
		_body().contains("kept at the shop for me to collect, until the end of September"))
	_keep("E — the order kept at the shop for collection, read on Sept 24")
	m.day = 370
	_check("E for collection: after the date, never 'is kept'", _body().contains("I didn't go for it.") and not _body().contains("is kept at the shop"))
	_winter({"origin": "chance", "chance_loose_end": "storage"}, "send")
	_spring()
	m.past_spring.open_parcel("unit")
	_through("give_some")
	_to_sept()
	_check("E storage: came, opened, some given away", _body().contains("I kept some of it and gave the rest to the charity shop."))
	_check("E: the Wednesday and the Thursday, from the road", _first_para().contains("on the Wednesday") and _first_para().contains("a small storage arrangement"))
	_keep("E — the storage unit sent up, opened, some given away")
	_winter({"origin": "chance", "chance_loose_end": "storage"}, "send")
	_spring()
	_to_sept()
	_check("E storage shut: came, never opened, not called kept-and-sorted", _body().contains("I haven't opened them yet") and not _body().contains("I kept everything"))
	_winter({"origin": "chance", "chance_loose_end": "meeting"}, "close")
	_spring()
	_go(m.day + 40)
	_to_sept()
	_worked_farm()
	_check("E meeting closed: never met, they moved", _body().contains("We never met. They moved in June.") or _body().contains("address"))
	_keep("E — the meeting closed in winter; they moved; worked farm")
	_winter({"origin": "chance", "chance_loose_end": "work_offer"}, "list")
	_go(305)
	_spring()
	_read_all()
	_to_sept()
	_check("E list: the August letter left unanswered, said so", _body().contains("I didn't answer, and the places were filled.") or _body().contains("haven't answered"))


# --- 7-12. The farm --------------------------------------------------------------------------------------------

func _farm() -> void:
	_winter({"origin": "chance", "chance_loose_end": "work_offer"}, "close")
	_spring()
	_to_sept()
	m.house_stage = 3
	m.woodwork.repairs["house_3"] = {"day": 300, "cost": {}}
	_check("farm: a restored house is said to be restored", _body().contains("The farmhouse is restored now"))
	m.house_stage = 0
	m.woodwork.repairs.clear()
	m.stats["mended"] = 4
	_check("farm: boards mended, and the rest as found", _body().contains("mended 4 boards") and _body().contains("much as I found it"))
	m.stats["mended"] = 0
	m.stats["harvested"] = 1
	m.stats["crop_leek"] = 1
	_check("farm: one crop is one crop", _body().contains("one crop so far"))
	m.stats["harvested"] = 0
	m.stats.erase("crop_leek")
	_check("farm: no Edith, no Cove, no woods: stayed close", _body().contains("haven't gone far from the farm") and not _body().contains("Edith") and not _body().contains("Wicker Cove"))
	m.town.visits = 1
	_check("farm: the Cove once is once", _body().contains("Wicker Cove once"))
	m.woodwork.repairs["inn_roof"] = {"day": 200, "cost": {}, "paid": 40}
	_check("farm: Edith's repair, only with its record", _body().contains("for Edith Vale"))
	m.woodwork.repairs.erase("inn_roof")
	m.folk.requests_done["davy_fish"] = 50
	m.folk.requests_done["davy_rope"] = 90
	_check("farm: a walker's errands, as errands", _body().contains("Davy asked me for perch for Ma, and later for rope for the boat. I brought both."))
	_keep("E — job filled, closed; house untouched; Davy's two errands; the Cove once")
	# Legacy: the farm's half, nothing from before, no 'old life' closing.
	_setup({"status": "legacy"}, FirstSeptember.FROM)
	_worked_farm()
	var t := _body()
	_check("legacy: a page from the farm only", t.contains("new shingles") and not t.contains("old room") and not t.contains("old job") and not t.contains("At the gate"))
	_check("legacy: no 'keep my old life' closing", not m.first_september.options().any(func(o: Dictionary) -> bool: return str(o["id"]) == "keep"))
	_keep("Legacy save (no origin) — worked farm", "The farm's half only.")
	_setup({"status": "legacy"}, FirstSeptember.FROM)
	_keep("Legacy save (no origin) — nothing done all year", "The quiet farmer: a truthful, modest page.")


# --- 13-17. Writing it -----------------------------------------------------------------------------------------

func _closing() -> void:
	for id in FirstSeptemberScript.REFLECTIONS:
		_winter({"origin": "household", "household_relation": "friend"}, "keep")
		_spring()
		_through("write")
		_to_sept()
		var line := ""
		for o in m.first_september.options():
			if str(o["id"]) == id:
				line = str(o["line"])
		var money := m.money
		var sanity := m.sanity
		var inv := JSON.stringify(m.inventory)
		var skills := JSON.stringify(m.skills.to_save()) if m.get("skills") != null and m.skills.has_method("to_save") else ""
		var hour := m.current_hour
		var ok := m.first_september.write(id)
		_check("closing %s: written as chosen (\"%s\")" % [id, line], ok and m.first_september.reflection() == id and _page().ends_with(line))
		_check("closing %s: nothing given, no time passed" % id, m.money == money and m.sanity == sanity and JSON.stringify(m.inventory) == inv
			and m.current_hour == hour and (skills == "" or JSON.stringify(m.skills.to_save()) == skills))
	_check("closing: written once only", not m.first_september.write("stay") and m.first_september.reflection() == "unsettled" or m.first_september.reflection() == FirstSeptemberScript.REFLECTIONS[-1])
	_check("closing: no options once written; the desk says it is written", m.first_september.options().is_empty()
		and str(m.first_september.desk_rows()[0]["status"]) == "Written")
	var pages := m.first_september.diary_pages().size()
	for i in 5:
		m.panels._diary_sections()
		m.panels._desk_rows()
	_check("closing: reading again adds nothing", m.first_september.diary_pages().size() == pages and m.first_september.to_save()["paras"].size() > 0)
	_check("closing: the 'unsettled' wording follows what is open", FirstSeptemberScript.reflection("unsettled", false, true).contains("from before")
		and not FirstSeptemberScript.reflection("unsettled", false, false).contains("from before"))
	_check("closing: 'finish' follows the house", FirstSeptemberScript.reflection("finish", false, false).contains("this house")
		and not FirstSeptemberScript.reflection("finish", true, false).contains("this house"))


func _saving() -> void:
	_winter({"origin": "security", "security_exit": "stored"}, "ship")
	_spring()
	_to_sept()
	_worked_farm()
	m.first_september._morning()
	var before := m.first_september.diary_pages().map(func(p: Dictionary) -> String: return str(p["text"]))
	_check("save: unwritten, the page loads the same", _round_trip() and m.first_september.diary_pages().map(func(p: Dictionary) -> String: return str(p["text"])) == before
		and int(m.first_september.to_save()["noticed"]) == FirstSeptember.FROM)
	m.first_september.write("finish")
	var rec := JSON.stringify(m.first_september.to_save())
	var pages := m.first_september.diary_pages().map(func(p: Dictionary) -> String: return str(p["text"]))
	_check("save: written, the record and the page load exactly", _round_trip() and JSON.stringify(m.first_september.to_save()) == rec
		and m.first_september.diary_pages().map(func(p: Dictionary) -> String: return str(p["text"])) == pages)
	m.house_stage = 3
	m.stats["harvested"] = 200
	m.past_spring.open_parcel("boxes")
	m.day = 420
	_check("save: later changes on the farm never alter the written page", m.first_september.diary_pages().map(func(p: Dictionary) -> String: return str(p["text"])) == pages)
	var f: Dictionary = m.first_september.facts()
	_check("save: the record keeps what Year Two needs", str(f.get("origin", "")) == "security" and f.has("spring_outcome") and f.has("parcels")
		and str(f.get("keepsake", "")) != "" and m.first_september.open_matters().has("parcel:boxes:received") and m.first_september.reflection() == "finish")
	# A v20 save (no first_september): loads, nothing written for the player, the page made from its records.
	m.saver._save_game()
	var path := TitleMenu.slot_path(SLOT)
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	data.erase("first_september")
	data["save_version"] = 20
	var fa := FileAccess.open(path, FileAccess.WRITE)
	fa.store_string(JSON.stringify(data))
	fa.close()
	_check("save: a v20 save loads with no page written", m.saver._load_game() and m.first_september.to_save().is_empty() and not m.first_september.written())
	_check("save: and can write it", not m.first_september.options().is_empty() and m.first_september._morning() != "")
	m.first_september.from_save("garbage")
	_check("save: garbage is dropped", m.first_september.to_save().is_empty())
	m.first_september.from_save({"state": "written", "reflection": "triumph", "words": "I found myself.", "paras": [["x"]]})
	_check("save: an unknown closing is dropped", not m.first_september.written())
	m.first_september.from_save({"state": "written", "reflection": "stay", "words": "", "paras": [["x"]], "noticed": 360})
	_check("save: a written record with no words is dropped (the note kept)", not m.first_september.written() and int(m.first_september.to_save()["noticed"]) == 360)
	# Legacy save loads, never an invented past.
	data["origin"] = {"v": 1, "status": "legacy"}
	data["save_version"] = 17
	data.erase("past_post")
	data.erase("past_spring")
	fa = FileAccess.open(path, FileAccess.WRITE)
	fa.store_string(JSON.stringify(data))
	fa.close()
	_check("save: a legacy save loads; its page has no past", m.saver._load_game() and m.origin.status() == "legacy" and not _body().contains("old room"))


# --- 18-19. The real day, and the story around it ---------------------------------------------------------------

func _next_day() -> void:
	m.tax_owed = 0
	m.tax_stage = 0
	m._end_day("Test.", false)


func _real_day() -> void:
	_winter({"origin": "curiosity", "contact": "none"}, "keep")
	_spring()
	m.past_spring.answer("keep")
	m.act.beats["letter"] = 240
	m.act.meeting = ""
	m.day = StoryAct.HARVEST_MOON - 2
	m.first_september.reset()
	var notes := {}
	while m.day < FirstSeptember.FROM + 1:
		_next_day()
		notes[m.day] = m.morning_report
	_check("real day: no note on the Harvest Moon or the meeting's morning", not str(notes.get(357, "")).contains("blank page") and not str(notes.get(358, "")).contains("blank page"))
	_check("real day: the note comes with the morning on September 24", str(notes.get(359, "")).contains("blank page at the back of your diary"))
	_check("real day: once", not str(notes.get(360, "")).contains("blank page"))
	_check("real day: the meeting still falls on its own (day 358)", m.act.meeting != "" and m.act._has("meeting"))
	var clock := m.clock
	var hour := m.current_hour
	m.first_september.write("stay")
	_check("real day: writing takes no time", m.clock == clock and m.current_hour == hour)
	while m.day < StoryAct.DAVY_FROM:
		_next_day()
	_check("real day: the year turns into the second autumn", m.day == StoryAct.DAVY_FROM and m.first_september.written())
	_check("real day: the story's dates are untouched", StoryAct.FROM == 240 and StoryAct.HARVEST_MOON == 357 and StoryAct.DAVY_FROM == 370 and StoryAct.MEETING_FROM == 300)
	var story := FileAccess.get_file_as_string("res://scripts/story_act.gd") + FileAccess.get_file_as_string("res://scripts/mystery.gd")
	_check("real day: nothing in the story reads the page (the endings' conditions unchanged)", not story.contains("first_september") and not story.contains("FirstSeptember"))
	print("   (the original story on this save, as it ran: meeting %s, davy_day %d, endings %s, playing %s)" % [m.act.meeting, m.act.davy_day, str(m.act.endings.keys()), m.act.playing()])
	# Leave the story as it was found, so the input cases below start on a quiet farm.
	if m.act.screen != null:
		m.act.screen.active = false
		m.act.screen.visible = false
	m.act.beats.clear()
	m.act.meeting = ""
	m.act.davy = ""
	m.act.davy_day = -1
	m.act.pending = ""
	m.act.endings.clear()


# --- 20. Input ----------------------------------------------------------------------------------------------------

func _input() -> void:
	_winter({"origin": "work"}, "explain")
	_spring()
	_through("method")
	_to_sept()
	m._toggle_tab("Desk")
	await _frames(3)
	_check("input: the desk opens with focus", m.open_tab == "Desk" and _focus() != null)
	var ok := await _focus_action("september:write|unknown")
	await _key(KEY_SPACE)
	_check("input: Space on a closing line writes it", ok and m.first_september.reflection() == "unknown")
	_check("input: nothing disabled takes focus", _no_disabled_focus(m.action_bar.panel))
	await _key(KEY_ESCAPE)
	_check("input: Esc closes the desk", m.open_tab == "")
	_winter({"origin": "work"}, "explain")
	_spring()
	_through("method")
	_to_sept()
	m._toggle_tab("Desk")
	await _frames(3)
	ok = await _focus_action("september:write|finish")
	await _pad(JOY_BUTTON_A)
	_check("input: Xbox A writes it", ok and m.first_september.reflection() == "finish")
	for i in 3:
		if m.open_tab != "":
			await _pad(JOY_BUTTON_B)
	_check("input: B closes the desk (back one level at a time)", m.open_tab == "")
	_winter({"origin": "work"}, "explain")
	_spring()
	_through("method")
	_to_sept()
	m._toggle_tab("Desk")
	await _frames(3)
	var entry: Button = null
	for e in _entries():
		if str(e.get_meta("action", "")) == "september:write|stay":
			entry = e
	if entry != null:
		entry.grab_focus()
		await _frames(4)
		await _click(entry)
		var button := _button_named(m.action_bar.panel, "Write it")
		if button != null:
			await _click(button)
	_check("input: a mouse click on the line, then its button", m.first_september.reflection() == "stay", "entry %s, tab %s" % [entry != null, m.open_tab])
	for i in 3:
		if m.open_tab != "":
			await _key(KEY_ESCAPE)
	# The diary book shows the section, written.
	var ab: ActionBar = m.action_bar
	await _key(KEY_J)
	await _frames(3)
	var found := -1
	for s in ab.book_sections.size():
		if str(ab.book_sections[s]["name"]) == FirstSeptember.SECTION:
			found = s
	_check("input: J opens the diary and its 'One year' section is there", ab.book.visible and found >= 0)
	if found >= 0:
		ab.open_book_at(found, 0)
		await _frames(3)
		_check("input: the section's pages end with the chosen words", str(ab.book_sections[found]["pages"][-1]["text"]).ends_with("I want to see what happens if I stay."))
	await _key(KEY_ESCAPE)
	await _fit()


# The longest page this test can make, written, in the book at the game's size: no page scrolls, no blank page
# inside the entry, the paragraphs run on in order.
func _fit() -> void:
	_winter({"origin": "household", "household_relation": "partner", "household_change": "separate", "keepsake": "postcard"}, "ask")
	_spring()
	m.past_spring.open_parcel("key")
	_through("time")
	_to_sept()
	_worked_farm()
	m.woodwork.repairs["inn_roof"] = {"day": 230, "cost": {}, "paid": 40}
	m.first_september.write("unsettled")
	_keep("Longest page in this test (C, written, 'unsettled')", "Used for the pagination check.")
	var ab: ActionBar = m.action_bar
	GameSettings.page_turns = 2
	await _key(KEY_J)
	await _frames(3)
	var sec := -1
	for s in ab.book_sections.size():
		if str(ab.book_sections[s]["name"]) == FirstSeptember.SECTION:
			sec = s
	var pages: Array = ab.book_sections[sec]["pages"] if sec >= 0 else []
	var over := 0
	var blank := 0
	for p in range(0, pages.size(), 2):
		ab.open_book_at(sec, p)
		await _frames(3)
		var side := 0
		for page_root in ab.book_spread_box.get_children():
			var scroll := _find_scroll(page_root)
			if scroll == null:
				continue
			var idx := p + side
			side += 1
			if idx >= pages.size():
				continue
			var bar := scroll.get_v_scroll_bar()
			if bar.visible and bar.max_value - bar.page > 0.5:
				over += 1
				print("   (page %d scrolls by %d px)" % [idx, int(bar.max_value - bar.page)])
			if str(pages[idx]["text"]).strip_edges() == "":
				blank += 1
	var joined := " ".join(pages.map(func(pg: Dictionary) -> String: return str(pg["text"]).replace("

", " ")))
	_check("fit: the longest entry (%d pages) fits every page, none scrolls" % pages.size(), sec >= 0 and pages.size() >= 2 and over == 0)
	_check("fit: no blank page inside the entry", blank == 0)
	_check("fit: every sentence appears once, in order", joined.find("almost a year") < joined.find("At the gate") and joined.ends_with("I haven't settled yet.")
		and joined.count("At the gate") == 1)
	await _key(KEY_ESCAPE)
	# Every origin's page, on a worked farm with Edith's repair (the fullest farm half), written: none scrolls.
	var routes := [[{"origin": "security", "security_exit": "stored"}, "ship", ["open:boxes", "thanks"]],
		[{"origin": "security", "security_exit": "forward"}, "end", ["leave"]],
		[{"origin": "work", "work_exit": "boundary"}, "explain", ["method"]],
		[{"origin": "work", "work_exit": "instructions"}, "explain", ["ask", "decline"]],
		[{"origin": "household", "household_relation": "private", "contact": "private"}, "keep", ["close"]],
		[{"origin": "curiosity", "contact": "none", "curiosity_interest": "making"}, "keep", ["left_out"]],
		[{"origin": "curiosity", "contact": "friend"}, "", []],
		[{"origin": "chance", "chance_loose_end": "order"}, "hold", ["collect"]],
		[{"origin": "chance", "chance_loose_end": "storage"}, "send", ["open:unit", "give_some"]],
		[{"origin": "chance", "chance_loose_end": "meeting"}, "spring", ["autumn"]]]
	var bad: Array = []
	for r in routes:
		for farm in ["worked", "bare"]:
			_winter(r[0], str(r[1]))
			_spring()
			for step in r[2]:
				if str(step).begins_with("open:"):
					m.past_spring.open_parcel(str(step).trim_prefix("open:"))
				else:
					_through(str(step))
			_to_sept()
			if farm == "worked":
				_worked_farm()
				m.woodwork.repairs["inn_roof"] = {"day": 230, "cost": {}, "paid": 40}
			m.first_september.write("unsettled")
			var scrolled := await _book_scrolls()
			if scrolled != "":
				bad.append("%s/%s %s" % [str(r[0]["origin"]), farm, scrolled])
	_check("fit: every origin's written page (20 cases, worked and bare farms) fits, none scrolls", bad.is_empty(), ", ".join(bad))


# Opens the diary at the section and returns the pages that scroll ("" when none).
func _book_scrolls() -> String:
	var ab: ActionBar = m.action_bar
	await _key(KEY_J)
	await _frames(3)
	var sec := -1
	for s in ab.book_sections.size():
		if str(ab.book_sections[s]["name"]) == FirstSeptember.SECTION:
			sec = s
	var out: Array = []
	if sec >= 0:
		var n: int = ab.book_sections[sec]["pages"].size()
		for p in range(0, n, 2):
			ab.open_book_at(sec, p)
			await _frames(3)
			var side := 0
			for page_root in ab.book_spread_box.get_children():
				var scroll := _find_scroll(page_root)
				if scroll == null:
					continue
				var idx := p + side
				side += 1
				var bar := scroll.get_v_scroll_bar()
				if idx < n and bar.visible and bar.max_value - bar.page > 0.5:
					out.append("p%d+%d" % [idx, int(bar.max_value - bar.page)])
	await _key(KEY_ESCAPE)
	return " ".join(out) if sec >= 0 else "no section"


func _find_scroll(n: Node) -> ScrollContainer:
	if n is ScrollContainer:
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


# --- The variants document ------------------------------------------------------------------------------------------

func _write_dump() -> void:
	var out: Array = ["# CCH-ORIGIN-004 — One Year on the Road: every page played by the test",
		"", "Generated by `tools/first_september_test.gd -- dump=...` from the game's own code: each page is exactly what the",
		"diary shows on September 24 (day 359) for that save, before the closing line is chosen. The closing lines offered",
		"for that page follow it. Text: `scripts/first_september_script.gd`; rules: `scripts/first_september.gd`.", ""]
	for d in dump:
		out.append("## " + str(d["name"]))
		out.append("")
		if str(d["note"]) != "":
			out.append("*" + str(d["note"]) + "*")
			out.append("")
		for para in str(d["text"]).split("\n\n"):
			out.append("> " + para)
			out.append(">")
		out.pop_back()
		out.append("")
		if (d["options"] as Array).is_empty():
			out.append("Written: the last paragraph is the closing line the player chose. Diary pages: %d." % (int(d["pages"]) + 1))
			out.append("")
			continue
		out.append("Diary pages: %d (plus \"The last lines\" until it is written). Closing lines offered:" % int(d["pages"]))
		out.append("")
		for o in d["options"]:
			out.append("- " + str(o))
		out.append("")
	var f := FileAccess.open("res://" + dump_path, FileAccess.WRITE)
	f.store_string("\n".join(out) + "\n")
	f.close()
	print("wrote %s (%d pages)" % [dump_path, dump.size()])
