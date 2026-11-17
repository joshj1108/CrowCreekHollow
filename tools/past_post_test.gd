extends SceneTree

# CCH-ORIGIN-002: checks the first winter's post from the life before (PastPost, PastPostScript). Run headless:
#   godot --path . --headless -s tools/past_post_test.gd
# It plays in save slot 9 and deletes that save when done (slots 1-3 are never touched). Cases:
#   - timing: nothing before January 12 (day 104), one letter that morning and never twice; legacy and "none" pasts
#     get nothing all year; a record first seen after February 17 gets nothing ("missed"); an old save mid-winter
#     gets its letter the next morning;
#   - each origin and variant gets its own letter and no other's: A boxes / forwarding (forward, extension), B the
#     order book (finish, instructions, boundary), C the second key, D the friend's question / the notice correction,
#     E the seasonal place, storage, order and meeting;
#   - truth: no boxes on the forwarding roads; the household's private sender; the boundaries line only for the one
#     it was said to; the curiosity replies only for a harvest, repair or walk in the woods that happened (and the
#     photograph's repair only for the house itself); what was told is kept even when the farm changes later; no
#     death, romance, fog, crows, bell or Rook family in any letter;
#   - answers: defer, reply, note, take back (coins back), close; the bounded order-book follow-up; lapses at the end
#     of winter with the sender's own terms; coins paid and deposits returned exactly once;
#   - save and load at every step (written, sent, answered), an old v18 save, a damaged record;
#   - the real day: tax bill on January 1 and the parish letter on day 240 still come, the mailbox reads without
#     time passing, a pending letter stays when the read letters are cleared, and the diary says only what happened;
#   - input: the reply rows driven by keyboard, Xbox buttons and a mouse click, the ledger's focus rules.
# Prints PASS or FAIL per case and a total; the exit code is the number of failures.

const SLOT := 9

var m: MainGame
var failures := 0


func _initialize() -> void:
	create_timer(600.0).timeout.connect(func() -> void:
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
	_timing()
	_titles()
	_security()
	_work()
	_household()
	_curiosity()
	_chance()
	_honesty()
	_saving()
	_real_day()
	await _input()
	SaveSystem.delete_save(TitleMenu.slot_path(SLOT))
	print("%s: %d failure(s)" % ["PASS" if failures == 0 else "FAIL", failures])
	quit(failures)


# --- Helpers ----------------------------------------------------------------------------------------------------

# A finished road with these choices, the first option everywhere else (as the interlude would record it).
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


func _farm_blank() -> void:
	for kind in m.CROPS:
		m.stats.erase("crop_" + str(kind))
	m.stats["mended"] = 0
	m.woodwork.repairs.clear()
	m.house_stage = 0
	m.nearwood.trips = 0
	m.trek.treks_done = 0
	m.trek.edge_done = false


func _setup(wants: Dictionary, day := 103) -> void:
	m.origin = OriginState.new(_road(wants) if not wants.has("status") else wants)
	m.past_post.reset()
	m.desk_mail = []
	m.diary_new = []
	m.day = day
	m.money = 500
	m.tax_owed = 0
	_farm_blank()


func _morning_at(d: int) -> String:
	m.day = d
	return m.past_post._morning()


func _post_letters() -> Array:
	return m.desk_mail.filter(func(l: Dictionary) -> bool: return l.has("post"))


func _post_ids() -> Array:
	return _post_letters().map(func(l: Dictionary) -> String: return str(l["post"]))


func _ids(opts: Array) -> Array:
	return opts.map(func(o: Dictionary) -> String: return str(o["id"]))


func _true_ids() -> Array:
	return m.past_post.options().filter(func(o: Dictionary) -> bool: return bool(o["true"])).map(func(o: Dictionary) -> String: return str(o["id"]))


func _read_all() -> void:
	for l in m.desk_mail:
		if l.has("post") and bool(l["unread"]):
			m.past_post.read(str(l["post"]))
		l["unread"] = false


func _diary() -> String:
	var pages: Array = m.past_post.diary_pages()
	return "\n\n".join(pages.map(func(p: Dictionary) -> String: return str(p["text"])))


func _letter_text(id: String) -> String:
	for l in m.desk_mail:
		if str(l.get("post", "")) == id:
			return str(l["text"])
	return ""


# Every word a variant can show: letters, replies, answers, lapses, diary lines.
func _all_text() -> String:
	return JSON.stringify(m.past_post.script()).to_lower()


# Delivers, reads, answers and walks the post through to the sender's answer. Returns the ack letter's text.
func _answer_through(id: String) -> String:
	if m.day < PastPost.LETTER_DAY:
		_morning_at(PastPost.LETTER_DAY)
	_read_all()
	# Already written (by the caller) counts; otherwise write it now.
	if str(m.past_post.outgoing().get("id", "")) != id and not m.past_post.answer(id):
		return "(not answered)"
	var written := int(m.past_post.outgoing()["written"])
	_morning_at(written + 1)
	_morning_at(written + 1 + PastPost.ACK_DAYS)
	_read_all()
	return _letter_text("ack")


func _check(name: String, ok: bool, detail := "") -> void:
	if not ok:
		failures += 1
	print("%s  %s%s" % ["PASS" if ok else "FAIL", name, "" if ok or detail == "" else "  (" + detail + ")"])


func _frames(n: int) -> void:
	for i in n:
		await process_frame


# --- Timing -----------------------------------------------------------------------------------------------------

func _timing() -> void:
	_setup({"origin": "security", "security_exit": "stored"}, 1)
	var early := ""
	for d in range(1, PastPost.LETTER_DAY):
		early += _morning_at(d)
	_check("timing: nothing comes before January 12", _post_letters().is_empty() and early == "" and m.past_post.state() == "waiting")
	var note := _morning_at(PastPost.LETTER_DAY)
	var date := m._calendar_date(PastPost.LETTER_DAY)
	_check("timing: day 104 is January 12, in winter", int(date["month"]) == 0 and int(date["day"]) == 12 and m._season_of(0) == "Winter")
	_check("timing: the letter comes that morning, with a note", _post_ids() == ["first"] and note.contains("letter"))
	_morning_at(PastPost.LETTER_DAY)
	_morning_at(PastPost.LETTER_DAY + 1)
	_check("timing: never twice", _post_ids() == ["first"])
	_check("timing: clear of the Longest Night, the New Year post and the minute book", not [82, 93, 150].has(PastPost.LETTER_DAY))
	for status in ["legacy", "none"]:
		_setup({"v": 1, "status": status}, 60)
		for d in range(60, 366):
			_morning_at(d)
		_check("timing: a %s past gets no letter all year" % status, _post_letters().is_empty() and m.past_post.state() == "none" and m.past_post.diary_pages().is_empty())
		m.mail._add_letter("Receipt", "An ordinary letter.")
		var rows: Array = m.panels._mailbox_rows()
		m.mail._clear_read_mail()
		_check("timing: a %s past's mailbox lists ordinary post with no reply rows" % status, rows.size() == 3 and m.panels._diary_sections().size() > 0)
	_setup({"origin": "work"}, 141)
	for d in range(141, 200):
		_morning_at(d)
	_check("timing: first seen after February 17, nothing comes (no winter letter in spring)", _post_letters().is_empty() and m.past_post.state() == "missed")
	_setup({"origin": "work"}, 120)
	_morning_at(120)
	_check("timing: an old save mid-winter gets its letter the next morning", _post_ids() == ["first"])


# --- Each origin its own letter --------------------------------------------------------------------------------

const EXPECT := [
	[{"origin": "security", "security_exit": "stored"}, "About the two boxes"],
	[{"origin": "security", "security_exit": "forward"}, "Forwarded post"],
	[{"origin": "security", "security_exit": "extension"}, "Forwarded post"],
	[{"origin": "work", "work_exit": "finish"}, "The order book"],
	[{"origin": "work", "work_exit": "instructions"}, "The order book"],
	[{"origin": "work", "work_exit": "boundary"}, "The order book"],
	[{"origin": "household", "household_relation": "partner"}, "The second key"],
	[{"origin": "household", "household_relation": "private"}, "The second key"],
	[{"origin": "curiosity", "contact": "friend"}, "Did it look like the picture?"],
	[{"origin": "curiosity", "contact": "none"}, "A correction to the notice"],
	[{"origin": "chance", "chance_loose_end": "work_offer"}, "The seasonal place"],
	[{"origin": "chance", "chance_loose_end": "storage"}, "The storage unit"],
	[{"origin": "chance", "chance_loose_end": "order"}, "Your order"],
	[{"origin": "chance", "chance_loose_end": "meeting"}, "The meeting"],
]


func _titles() -> void:
	var all_titles := EXPECT.map(func(e: Array) -> String: return str(e[1]))
	for e in EXPECT:
		var wants: Dictionary = e[0]
		_setup(wants)
		_morning_at(PastPost.LETTER_DAY)
		var titles := m.desk_mail.map(func(l: Dictionary) -> String: return str(l["title"]))
		var others := all_titles.filter(func(t: String) -> bool: return t != str(e[1]) and titles.has(t))
		_check("letter: %s gets \"%s\" and no other" % [JSON.stringify(wants), e[1]], titles == [e[1]] and others.is_empty(),
			"got %s" % str(titles))
		_check("letter: %s keeps to its thread %s" % [wants["origin"], m.origin.thread()], str(m.past_post.rec()["thread"]) == m.origin.thread())


# --- A: the boxes, or the forwarding -----------------------------------------------------------------------------

func _security() -> void:
	_setup({"origin": "security", "security_exit": "stored"})
	_morning_at(PastPost.LETTER_DAY)
	_check("A stored: the screenplay's letter", _letter_text("first").contains("There are two boxes here under your name. I can keep them through the end of winter."))
	_check("A stored: ship, more time, release", _ids(m.past_post.options()) == ["ship", "more_time", "release"])
	_read_all()
	m.money = 10
	_check("A stored: shipping can't be written without the 30 coins", not m.past_post.answer("ship") and m.money == 10 and m.past_post.outgoing().is_empty())
	m.money = 100
	_check("A stored: shipping takes the 30 coins once", m.past_post.answer("ship") and m.money == 70)
	_check("A stored: a second answer can't be written over it", not m.past_post.answer("release") and m.money == 70)
	_check("A stored: the diary says the reply waits for the post, not that it went", _diary().contains("in the mailbox for the morning post") and not _diary().contains("went with the post"))
	_check("A stored: taking it back returns the coins", m.past_post.take_back() and m.money == 100 and m.past_post.outgoing().is_empty())
	_check("A stored: taking it back twice gives nothing more", not m.past_post.take_back() and m.money == 100)
	_check("A stored: after taking it back the diary claims no reply", not _diary().contains("send the boxes"))
	m.past_post.answer("more_time")
	var ack := _answer_through("more_time")
	_check("A stored, more time: the answer gives the end of April", ack.contains("The end of April is all right"))
	_check("A stored, more time: outcome held until day 212, pending", str(m.past_post.rec()["outcome"].get("boxes", "")) == "held" and int(m.past_post.rec()["outcome"]["until_day"]) == 212 and str(m.past_post.rec()["matter"]) == "pending")
	var d := _diary()
	_check("A stored, more time: the diary is the factual record", d.contains("I had a letter about the two boxes I left behind.") and d.contains("I asked for more time.") and d.contains("It went with the morning post.") and d.contains("until the end of April"), d)
	_check("A stored, more time: the diary assigns no feeling", not (d.to_lower().contains("felt") or d.to_lower().contains("belong") or d.to_lower().contains("realized")))
	_check("A stored, more time: no money moved", m.money == 100)
	_check("A stored: no options once answered", m.past_post.options().is_empty())

	_setup({"origin": "security", "security_exit": "stored"})
	m.money = 100
	_morning_at(PastPost.LETTER_DAY)
	_read_all()
	m.past_post.answer("ship")
	var ack2 := _answer_through("ship")
	for dd in range(PastPost.LETTER_DAY + 8, 200):
		_morning_at(dd)
	_check("A stored, ship: 30 coins paid exactly once over the winter", m.money == 70)
	_check("A stored, ship: the boxes are on their way, not arrived", ack2.contains("the boxes will go in the spring") and str(m.past_post.rec()["outcome"]["boxes"]) == "to_ship" and str(m.past_post.rec()["matter"]) == "arranged")
	_check("A stored, ship: one answer letter only", _post_ids().count("ack") == 1)

	_setup({"origin": "security", "security_exit": "stored"})
	_morning_at(PastPost.LETTER_DAY)
	_read_all()
	_morning_at(PastPost.ANSWER_BY)
	_check("A stored: still answerable on February 28", not m.past_post.options().is_empty())
	_morning_at(PastPost.ANSWER_BY + 1)
	_read_all()
	_check("A stored, no answer: one last word on March 1 with the sender's terms", _letter_text("lapse").contains("the boxes are still here") and str(m.past_post.rec()["outcome"]["boxes"]) == "held_unanswered")
	_check("A stored, no answer: nothing left to answer", m.past_post.options().is_empty() and not m.past_post.answer("ship"))
	_check("A stored, no answer: the diary says so plainly", _diary().contains("I didn't answer by the end of February."))

	for exit in ["forward", "extension"]:
		_setup({"origin": "security", "security_exit": exit})
		_morning_at(PastPost.LETTER_DAY)
		_check("A %s: no boxes anywhere in the thread" % exit, not _all_text().contains("box"))
		_check("A %s: renew or let it end" % exit, _ids(m.past_post.options()) == ["renew", "end"])
		_read_all()
		var a := _answer_through("renew")
		_check("A %s, renew: 12 coins, forwarding to August" % exit, m.money == 488 and a.contains("until the end of August") and str(m.past_post.rec()["outcome"]["forwarding"]) == "renewed")
	_check("A extension: says the extra month was kept", PastPostScript.variant(m.origin)["body"].contains("You stayed to the end of the month, as agreed"))
	_setup({"origin": "security", "security_exit": "forward"})
	var b := _answer_through("end")
	_check("A forward, let it end: closed", b.contains("The account is closed") and str(m.past_post.rec()["matter"]) == "closed" and m.money == 500)


# --- B: the order book -------------------------------------------------------------------------------------------

func _work() -> void:
	var openings := {"finish": "You left the order book in good shape.", "instructions": "I've been going by the sheet you left",
		"boundary": "They gave me the order book after you left."}
	for exit in openings:
		_setup({"origin": "work", "work_exit": exit})
		_morning_at(PastPost.LETTER_DAY)
		_check("B %s: the opening fits how they left" % exit, _letter_text("first").contains(openings[exit]) and _letter_text("first").contains("Thursday totals"))
		for other in openings:
			if other != exit:
				_check("B %s: not the %s opening" % [exit, other], not _letter_text("first").contains(openings[other]))
	_setup({"origin": "work", "work_exit": "finish"})
	_morning_at(PastPost.LETTER_DAY)
	_check("B: explain, ask, decline", _ids(m.past_post.options()) == ["explain", "ask", "decline"])
	_read_all()
	m.past_post.answer("ask")
	_morning_at(PastPost.LETTER_DAY + 1)
	_check("B ask: no answer yet while the question travels", _post_ids() == ["first"] and m.past_post.options().is_empty())
	_morning_at(PastPost.LETTER_DAY + 1 + PastPost.ACK_DAYS)
	_read_all()
	_check("B ask: the page comes back, bounded", _letter_text("page").contains("page 41") and _ids(m.past_post.options()) == ["explain", "decline"])
	var ack := _answer_through("explain")
	_check("B ask then explain: the figures are sorted", ack.contains("One delivery went in twice") and str(m.past_post.rec()["outcome"]["order_book"]) == "explained")
	var d := _diary()
	_check("B ask then explain: the diary keeps both steps in order", d.find("I asked which page they meant.") < d.find("They sent the page") and d.find("They sent the page") < d.find("short explanation"), d)
	_setup({"origin": "work", "work_exit": "boundary"})
	var dec := _answer_through("decline")
	_check("B decline: the old job carries on without you", dec.contains("I'll go through the slips with the manager") and str(m.past_post.rec()["matter"]) == "closed")
	_setup({"origin": "work"})
	_morning_at(PastPost.LETTER_DAY)
	_read_all()
	_morning_at(PastPost.ANSWER_BY + 1)
	_read_all()
	_check("B no answer: they sort it themselves", _letter_text("lapse").contains("found it: one delivery was entered twice") and str(m.past_post.rec()["matter"]) == "resolved")
	# A question late in the winter gives the page its own two weeks.
	_setup({"origin": "work"})
	_morning_at(PastPost.LETTER_DAY)
	_read_all()
	m.day = 140
	m.past_post.answer("ask")
	_morning_at(141)
	_morning_at(147)
	_check("B late ask: the page can be answered two weeks on", m.past_post.answer_by() == 161)
	_morning_at(152)
	_check("B late ask: no lapse on March 1 while the page is fresh", int(m.past_post.rec()["lapsed"]) < 0 and not m.past_post.options().is_empty())
	_morning_at(162)
	_check("B late ask: lapses after its own date", int(m.past_post.rec()["lapsed"]) == 162)


# --- C: the second key -------------------------------------------------------------------------------------------

func _household() -> void:
	_setup({"origin": "household", "household_relation": "private", "household_change": "private", "contact": "private"})
	_morning_at(PastPost.LETTER_DAY)
	var t := _letter_text("first").to_lower()
	_check("C private: the sender is not named", t.begins_with("from someone at the house you left"))
	for word in ["partner", "friend", "family", "loved", "wife", "husband", "brother", "sister", "mother", "father"]:
		if t.contains(word):
			_check("C private: no \"%s\"" % word, false)
	_check("C: the screenplay's letter", t.contains("i found another key while clearing the drawer"))
	_check("C: ask, keep, no need, don't reply yet", _ids(m.past_post.options()) == ["ask", "keep", "no_need", "defer"])
	_setup({"origin": "household", "household_relation": "partner"})
	_morning_at(PastPost.LETTER_DAY)
	_check("C partner: named only as the person you shared the house with", _letter_text("first").begins_with("From the person you shared the house with") and not _all_text().contains("partner") and not _all_text().contains("love"))
	_setup({"origin": "household", "household_relation": "family"})
	_morning_at(PastPost.LETTER_DAY)
	_check("C family: from family at the old house", _letter_text("first").begins_with("From your family at the old house"))
	_setup({"origin": "household", "contact": "former_household", "contact_intent": "boundaries"})
	_morning_at(PastPost.LETTER_DAY)
	_check("C: told this person no plans, the letter keeps to a line", _letter_text("first").contains("A line will do."))
	_setup({"origin": "household", "contact": "friend", "contact_intent": "boundaries"})
	_morning_at(PastPost.LETTER_DAY)
	_check("C: told someone else no plans, no such line", not _letter_text("first").contains("A line will do."))
	_setup({"origin": "household"})
	_morning_at(PastPost.LETTER_DAY)
	_read_all()
	_check("C defer: recorded, nothing written", m.past_post.answer("defer") and m.past_post.outgoing().is_empty())
	_check("C defer: the other answers stay open, defer once", _ids(m.past_post.options()) == ["ask", "keep", "no_need", "defer"] and m.past_post.awaiting_player())
	_check("C defer: the diary says so", _diary().contains("I decided not to answer yet."))
	_morning_at(PastPost.LETTER_DAY + 2)
	_check("C defer: nothing went with the post", (m.past_post.rec()["replies"] as Array).is_empty())
	var keep := _answer_through("keep")
	_check("C defer then keep: kept in the tin", keep.contains("in the tin with the spare buttons") and str(m.past_post.rec()["outcome"]["key"]) == "kept_by_them")
	_check("C defer then keep: the diary has both, in order", _diary().find("not to answer yet") < _diary().find("asked them to keep the key"))
	_setup({"origin": "household"})
	var ask := _answer_through("ask")
	_check("C ask: the key will come with the rest (no key appears now)", ask.contains("I'll send it with the other things") and str(m.past_post.rec()["outcome"]["key"]) == "to_send")
	_setup({"origin": "household"})
	_morning_at(PastPost.LETTER_DAY)
	_read_all()
	m.past_post.answer("defer")
	_morning_at(PastPost.ANSWER_BY + 1)
	_read_all()
	_check("C defer, no answer: they put the key away", _letter_text("lapse").contains("I've put the key away for now") and str(m.past_post.rec()["outcome"]["key"]) == "put_away_unanswered")


# --- D: the place in the photograph ------------------------------------------------------------------------------

func _curiosity() -> void:
	_setup({"origin": "curiosity", "contact": "friend", "contact_intent": "uncertain"})
	_morning_at(PastPost.LETTER_DAY)
	_read_all()
	_check("D friend: the screenplay's letter", _letter_text("first").contains("Did it look like the picture?") and _letter_text("first").begins_with("From your friend"))
	_check("D friend: nothing done yet, only \"hard to put into words\" can be written", _true_ids() == ["unsaid"])
	_check("D friend: a crop can't be claimed unharvested", not m.past_post.answer("crops") and m.past_post.outgoing().is_empty())
	_check("D friend: the woods can't be claimed unvisited", not m.past_post.answer("woods"))
	m.stats["crop_pumpkin"] = 3
	m.stats["crop_turnip"] = 1
	var opt: Dictionary = m.past_post.options().filter(func(o: Dictionary) -> bool: return o["id"] == "crops")[0]
	_check("D friend: a harvest makes the crops reply true, naming the crop", bool(opt["true"]) and str(opt["text"]).contains("pumpkins"))
	m.past_post.answer("crops")
	m.stats["crop_turnip"] = 50   # the farm changes after the letter went
	_morning_at(m.day + 1)
	_morning_at(m.day + PastPost.ACK_DAYS)
	_read_all()
	_check("D friend, crops: the answer speaks only of what was told", _letter_text("ack").begins_with("From your friend") and _letter_text("ack").contains("Pumpkins.") and not _letter_text("ack").contains("urnip"))
	_check("D friend, crops: the diary too", _diary().contains("the pumpkins I've grown"))
	# Repairs: the house, or the inn's roof for the friend; the photograph only takes the house.
	_setup({"origin": "curiosity", "contact": "family"})
	_morning_at(PastPost.LETTER_DAY)
	m.woodwork.repairs["inn_roof"] = {"day": 90, "cost": {}}
	var rep: Dictionary = m.past_post.options().filter(func(o: Dictionary) -> bool: return o["id"] == "repair")[0]
	_check("D friend: the inn's roof counts as a repair", bool(rep["true"]) and str(rep["text"]).contains("inn"))
	m.woodwork.repairs["house_1"] = {"day": 80, "cost": {}}
	m.house_stage = 1
	rep = m.past_post.options().filter(func(o: Dictionary) -> bool: return o["id"] == "repair")[0]
	_check("D friend: the farmhouse's own repair is told first", str(rep["text"]).contains("boarded over the broken windows"))
	m.nearwood.trips = 2
	var wood: Dictionary = m.past_post.options().filter(func(o: Dictionary) -> bool: return o["id"] == "woods")[0]
	_check("D friend: the Nearwood counts as the woods", bool(wood["true"]) and str(wood["text"]).contains("for timber"))
	_setup({"origin": "curiosity", "contact": "friend"})
	_morning_at(PastPost.LETTER_DAY)
	m.trek.edge_done = true
	wood = m.past_post.options().filter(func(o: Dictionary) -> bool: return o["id"] == "woods")[0]
	_check("D friend: the wood's edge alone says only that much", bool(wood["true"]) and str(wood["text"]).contains("where they begin"))
	for intent in {"promise": "You said you'd write. I thought I'd go first.", "invite": "Not in this weather, I think.",
			"boundaries": "You don't have to write back at all."}:
		_setup({"origin": "curiosity", "contact": "friend", "contact_intent": intent})
		_morning_at(PastPost.LETTER_DAY)
		_check("D friend, %s: the letter remembers the parting words" % intent, _letter_text("first").contains({"promise": "You said you'd write. I thought I'd go first.", "invite": "Not in this weather, I think.", "boundaries": "You don't have to write back at all."}[intent]))
	_setup({"origin": "curiosity", "contact": "private"})
	_morning_at(PastPost.LETTER_DAY)
	_check("D private contact: not named", _letter_text("first").begins_with("From the person who saw you off"))
	# No one saw them off: the notice, and the photograph.
	_setup({"origin": "curiosity", "contact": "none"})
	_morning_at(PastPost.LETTER_DAY)
	_read_all()
	_check("D no contact: no friend's letter, the town's correction", _letter_text("first").begins_with("From the town office") and not _all_text().contains("saw you off"))
	_check("D no contact: only the office or leaving it, until something is done", _true_ids() == ["road", "keep"])
	m.woodwork.repairs["inn_roof"] = {"day": 90, "cost": {}}
	_check("D no contact: the inn's roof isn't the house in the photograph", not _true_ids().has("repair"))
	m.stats["mended"] = 3
	_check("D no contact: mended boards are", _true_ids().has("repair"))
	_check("D no contact: a note goes in the diary, nothing is posted", m.past_post.answer("repair") and m.past_post.outgoing().is_empty() and (m.past_post.rec()["replies"] as Array).is_empty())
	_check("D no contact, note: the diary has it", _diary().contains("3 boards in the farmhouse are mended"))
	var nxt := _morning_at(m.day + 1)
	_check("D no contact, note: the next morning, the photograph is still on the desk", nxt.contains("The photograph is still on the desk"))
	_setup({"origin": "curiosity", "contact": "none"})
	var road := _answer_through("road")
	_check("D no contact, road: the office files the note", road.contains("filed with the notice"))
	_setup({"origin": "curiosity", "contact": "none"})
	_morning_at(PastPost.LETTER_DAY)
	_read_all()
	m.past_post.answer("keep")
	_check("D no contact, leave it: the diary says only that", _diary().contains("I put the town's correction with the photograph and didn't write anything."))


# --- E: the old offer ----------------------------------------------------------------------------------------------

func _chance() -> void:
	var opts := {"work_offer": ["close", "list"], "storage": ["renew", "send", "clear"], "order": ["send", "refund", "hold"], "meeting": ["close", "spring"]}
	var lines := {"work_offer": "we filled the position in December", "storage": "Your unit is paid to the end of February",
		"order": "The item you ordered has come in", "meeting": "I couldn't hold the time"}
	for end in opts:
		_setup({"origin": "chance", "chance_loose_end": end})
		_morning_at(PastPost.LETTER_DAY)
		_check("E %s: its own letter" % end, _letter_text("first").contains(lines[end]))
		_check("E %s: its own answers" % end, _ids(m.past_post.options()) == opts[end])
		for other in lines:
			if other != end:
				_check("E %s: not the %s letter" % [end, other], not _letter_text("first").contains(lines[other]))
	_setup({"origin": "chance", "chance_loose_end": "order"})
	var ack := _answer_through("refund")
	_check("E order, refund: the deposit comes back with the answer", ack.contains("Your deposit of 12 coins is enclosed") and m.money == 512 and int(m.past_post.rec()["credited"]) == 12)
	for d in range(m.day + 1, m.day + 60):
		_morning_at(d)
	_check("E order, refund: once only", m.money == 512)
	_setup({"origin": "chance", "chance_loose_end": "order"})
	_answer_through("send")
	_check("E order, send: 24 coins, coming in spring, no deposit back", m.money == 476 and str(m.past_post.rec()["outcome"]["order"]) == "to_ship")
	_setup({"origin": "chance", "chance_loose_end": "storage"})
	_answer_through("send")
	_check("E storage, send: 30 coins once", m.money == 470)
	_setup({"origin": "chance", "chance_loose_end": "storage"})
	_morning_at(PastPost.LETTER_DAY)
	_read_all()
	_morning_at(PastPost.ANSWER_BY + 1)
	_read_all()
	_check("E storage, no answer: held to March 30, then cleared", _letter_text("lapse").contains("held until March 30") and int(m.past_post.rec()["outcome"]["until_day"]) == 181)
	_setup({"origin": "chance", "chance_loose_end": "work_offer"})
	_morning_at(PastPost.LETTER_DAY)
	_read_all()
	_morning_at(PastPost.ANSWER_BY + 1)
	_check("E work offer, no answer: nothing more comes, it is closed", _post_ids() == ["first"] and str(m.past_post.rec()["matter"]) == "closed")
	_setup({"origin": "chance", "chance_loose_end": "meeting"})
	var sp := _answer_through("spring")
	_check("E meeting, spring: a day in April, no promise", sp.contains("April, then.") and str(m.past_post.rec()["matter"]) == "open")
	_setup({"origin": "chance", "chance_loose_end": "work_offer"})
	var ls := _answer_through("list")
	_check("E work offer, list: written to in August", ls.contains("We'll write in August") and int(m.past_post.rec()["outcome"]["until_day"]) == 305)


# --- Honesty across every variant ---------------------------------------------------------------------------------

func _honesty() -> void:
	var banned := ["died", "death", "dead", "funeral", "grave", "divorce", "romance", "fog", "crow", "bell", "rook", "agnes",
		"maren", "davy", "vicar", "hollow", "ghost", "curse", "you belong", "realized", "the right choice"]
	var walked := {}
	for o in ["security", "work", "household", "curiosity", "chance"]:
		for e in EXPECT:
			if e[0]["origin"] != o:
				continue
			_setup(e[0])
			var text := _all_text()
			for w in banned:
				if text.contains(w):
					_check("honesty: %s has no \"%s\"" % [JSON.stringify(e[0]), w], false)
			walked[JSON.stringify(e[0])] = true
	_check("honesty: every variant checked for death, romance, the mystery and assigned feelings (%d)" % walked.size(), walked.size() == EXPECT.size())
	# Nothing gives sanity, friendship, skills or tools.
	_setup({"origin": "work"})
	var before := [m.sanity, JSON.stringify(m.skill_xp), JSON.stringify(m.folk._to_save()), JSON.stringify(m.inventory)]
	_answer_through("explain")
	_check("honesty: a letter changes no sanity, skill, friendship or pack", before == [m.sanity, JSON.stringify(m.skill_xp), JSON.stringify(m.folk._to_save()), JSON.stringify(m.inventory)])


# --- Saving ----------------------------------------------------------------------------------------------------

func _round_trip() -> bool:
	m.saver._save_game()
	return m.saver._load_game()


func _saving() -> void:
	_setup({"origin": "security", "security_exit": "stored"})
	_morning_at(PastPost.LETTER_DAY)
	_read_all()
	m.past_post.answer("ship")
	var money := m.money
	_check("save: a written reply loads as written, coins paid once", _round_trip() and str(m.past_post.outgoing().get("id", "")) == "ship" and int(m.past_post.outgoing()["sent"]) == -1 and m.money == money)
	_morning_at(m.day + 1)
	_check("save: sent reply loads as sent", _round_trip() and int(m.past_post.outgoing()["sent"]) >= 0 and m.money == money)
	var sent := int(m.past_post.outgoing()["sent"])
	_morning_at(sent + PastPost.ACK_DAYS)
	_check("save: the answer once, after load", _round_trip() and _post_ids() == ["first", "ack"])
	_morning_at(sent + PastPost.ACK_DAYS + 1)
	_round_trip()
	_morning_at(sent + PastPost.ACK_DAYS + 2)
	_check("save: no letter, payment or answer repeats across loads", _post_ids() == ["first", "ack"] and m.money == money and (m.past_post.rec()["replies"] as Array).size() == 1)
	_check("save: the letter keeps its id through the mailbox's migration", _post_letters().size() == 2)
	# A refund loaded before it is credited, then after.
	_setup({"origin": "chance", "chance_loose_end": "order"})
	_morning_at(PastPost.LETTER_DAY)
	_read_all()
	m.past_post.answer("refund")
	_morning_at(m.day + 1)
	_round_trip()
	_morning_at(m.day + PastPost.ACK_DAYS)
	_round_trip()
	_morning_at(m.day + 1)
	_check("save: the deposit is credited once across loads", m.money == 512)
	# A v18 save with a finished road and no past_post, mid-winter.
	_setup({"origin": "household"}, 110)
	m.saver._save_game()
	var path := TitleMenu.slot_path(SLOT)
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	data.erase("past_post")
	data["save_version"] = 18
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(data))
	f.close()
	m.past_post.data = {"junk": true}
	_check("save: a v18 save loads", m.saver._load_game() and m.origin.origin() == "household")
	_morning_at(111)
	_check("save: a v18 save mid-winter gets its letter", _post_ids() == ["first"])
	# A v17 save (legacy origin) gets nothing.
	data["origin"] = {"v": 1, "status": "legacy"}
	data["save_version"] = 17
	f = FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(data))
	f.close()
	m.desk_mail = []
	_check("save: a legacy save loads", m.saver._load_game() and m.origin.status() == "legacy")
	for d in range(111, 200):
		_morning_at(d)
	_check("save: a legacy save never gets a letter", _post_letters().is_empty())
	# A record for another origin (a damaged or hand-edited save) is dropped, not trusted.
	_setup({"origin": "work"})
	m.past_post.from_save({"v": 1, "state": "delivered", "thread": "forwarded_belongings", "variant": "boxes", "letters": [{"id": "first", "day": 104, "read": 104}]})
	_check("save: a record for another origin starts again from the origin", str(m.past_post.rec()["thread"]) == "old_workplace" and m.past_post.state() == "waiting")
	m.past_post.from_save("garbage")
	_check("save: a garbage record starts again", m.past_post.state() == "waiting")


# --- The real day ---------------------------------------------------------------------------------------------------

func _next_day() -> void:
	m.tax_owed = 0
	m.tax_stage = 0
	m._end_day("Test.", false)


func _real_day() -> void:
	_setup({"origin": "security", "security_exit": "stored"}, 91)
	for i in 3:
		_next_day()
	var titles := m.desk_mail.map(func(l: Dictionary) -> String: return str(l["title"]))
	_check("real day: the New Year tax bill still comes (day %d)" % m.day, titles.has("Property tax bill"))
	while m.day < PastPost.LETTER_DAY:
		_next_day()
	titles = m.desk_mail.map(func(l: Dictionary) -> String: return str(l["title"]))
	_check("real day: the letter comes with the morning on day 104, beside the other post", titles.has("About the two boxes") and titles.has("Property tax bill"))
	_check("real day: the morning report says so", m.morning_report.contains("A personal letter has come in the mailbox."))
	_check("real day: the flag is up", m.mail._flag_up())
	var clock := m.clock
	var hour := m.current_hour
	var food := m.food
	m.mail._open_mailbox()
	_check("real day: opening the mailbox reads it", m.past_post.letter_read("first") and m.diary_new.has(PastPost.DIARY_ID))
	_check("real day: reading takes no time or food", m.clock == clock and m.current_hour == hour and m.food == food)
	m._close_panel()
	m.mail._clear_read_mail()
	titles = m.desk_mail.map(func(l: Dictionary) -> String: return str(l["title"]))
	_check("real day: clearing read letters keeps the one waiting for an answer", titles == ["About the two boxes"])
	_check("real day: the diary page is in Notes, in your hand", m.panels._diary_sections().any(func(s: Dictionary) -> bool:
		return str(s["name"]) == "Notes" and (s["pages"] as Array).any(func(p: Dictionary) -> bool: return str(p["title"]) == "About the two boxes" and not p.has("hand"))))
	m.past_post.answer("release")
	_next_day()
	_check("real day: the post takes the reply in the morning", m.morning_report.contains("The post took your letter.") and int(m.past_post.outgoing()["sent"]) == m.day)
	for i in PastPost.ACK_DAYS:
		_next_day()
	_check("real day: the answer comes in the morning post", _post_ids().has("ack") and m.morning_report.contains("An answer to your letter has come."))
	# The parish letter on day 240 and its diary page are untouched.
	m.day = 239
	_next_day()
	_check("real day: the parish letter still comes on day 240", m.act._has("letter") and m.diary_new.has("act_letter"))
	_check("real day: the parish chapters are not touched", StoryAct.FROM == 240 and StoryAct.HARVEST_MOON == 357 and StoryAct.DAVY_FROM == 370)


# --- Input: the mailbox driven by keys, pad and mouse ----------------------------------------------------------------

func _input() -> void:
	_setup({"origin": "chance", "chance_loose_end": "order"})
	_morning_at(PastPost.LETTER_DAY)
	m.mail._open_mailbox()
	await _frames(3)
	_check("input: the mailbox opens with focus", m.open_tab == "Mailbox" and _focus() != null)
	_check("input: the clock is held while reading", await _clock_stopped())
	_check("input: nothing disabled takes focus", _no_disabled_focus(m.action_bar.panel))
	var ok := await _focus_action("post:answer|hold")
	await _key(KEY_SPACE)
	_check("input: Space on \"Ask them to hold it\" writes the reply", ok and str(m.past_post.outgoing().get("id", "")) == "hold")
	ok = await _focus_action("post:take_back")
	await _pad(JOY_BUTTON_A)
	_check("input: A on \"Take it back\" takes it back", ok and m.past_post.outgoing().is_empty())
	ok = await _focus_action("post:answer|send")
	await _key(KEY_ENTER)
	_check("input: Enter writes the paid reply, 24 coins", ok and str(m.past_post.outgoing().get("id", "")) == "send" and m.money == 476)
	ok = await _focus_action("post:take_back")
	await _key(KEY_SPACE)
	_check("input: and the coins come back", ok and m.money == 500)
	# The mouse: a click picks the entry, the detail's button writes it.
	var entry: Button = null
	for e in _entries():
		if str(e.get_meta("action", "")) == "post:answer|refund":
			entry = e
	if entry != null:
		await _click(entry)
		var button := _button_named(m.action_bar.panel, "Write it")
		if button != null:
			await _click(button)
	_check("input: a click on the entry and then \"Write it\"", str(m.past_post.outgoing().get("id", "")) == "refund")
	await _pad(JOY_BUTTON_B)
	_check("input: B closes the mailbox", m.open_tab == "")
	m.money = 5
	m.past_post.take_back()
	m.mail._open_mailbox()
	await _frames(3)
	_check("input: an unaffordable reply is not in the focus path", _no_disabled_focus(m.action_bar.panel))
	await _key(KEY_ESCAPE)
	_check("input: Esc closes it", m.open_tab == "")


func _clock_stopped() -> bool:
	var before := m.clock
	await _frames(5)
	return m.clock == before and m.player.paused


func _focus() -> Control:
	return root.gui_get_focus_owner()


func _entries() -> Array:
	return m.action_bar.list_box.get_children().filter(func(c: Node) -> bool: return c is Button)


func _focus_action(action: String) -> bool:
	for i in 60:
		if _focus() != null and str(_focus().get_meta("action", "")) == action:
			return true
		await _key(KEY_DOWN if i < 30 else KEY_UP)
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
		await _frames(1)
	await _frames(1)
