extends SceneTree

# CCH-ORIGIN-003: checks the first spring and summer's post from the life before (PastSpring, PastSpringScript).
# Run headless:  godot --path . --headless -s tools/past_spring_test.gd
# It plays in save slot 9 and deletes that save when done (slots 1-3 are never touched). Each case plays the winter
# through PastPost's real mornings and answers, then the spring through PastSpring's, one morning at a time:
#   - routes: every winter outcome that changes spring gets its own route and no other's (A boxes to_ship / held /
#     held_unanswered / released, the deposit on the forward and extension roads; B each winter outcome; C each key
#     outcome; D contact told / unanswered and no contact; E all four loose ends and their winter outcomes);
#   - promises: parcels only where the winter paid or a reply sends for them, never twice, never charged again;
#     opened, returned; refunds and pay credited once (also across loads); the 12-coin deposit never twice;
#   - time: paid work shows its hours and pay, passes exactly those hours, and is refused too late at night;
#     reading and choosing take no time;
#   - deadlines and lapses on the sender's stated terms; bounded extensions (once); nothing on day 240;
#   - truth: D's replies only for what happened, kept as told; the no-contact route at the desk with no letters;
#     sender names as the road allowed; no death, romance or mystery words; no skills, sanity or pack change;
#   - the diary page from the record only, and a September line for every settled route;
#   - save and load at every step, a v19 save, a damaged record, legacy and missed pasts;
#   - the real day (`_end_day`): the spring letter and the parish letter on day 240;
#   - input: Space, Enter, Xbox A and B, a mouse click; the letter page scrolls with PgDn, the button row stays in view.
# Prints PASS or FAIL per case and a total; the exit code is the number of failures.

const SLOT := 9

var m: MainGame
var failures := 0


func _initialize() -> void:
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
	_gating()
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
	m.desk_mail = []
	m.diary_new = []
	m.day = day
	m.money = 500
	m.tax_owed = 0
	m.current_hour = 10.0
	for kind in m.CROPS:
		m.stats.erase("crop_" + str(kind))
	m.stats["mended"] = 0
	m.stats["harvested"] = 0
	m.woodwork.repairs.clear()
	m.house_stage = 0
	m.nearwood.trips = 0
	m.trek.treks_done = 0
	m.trek.edge_done = false
	m.town.visits = 0


# Every morning from tomorrow to day d: the winter's post, then the spring's. Returns the notes.
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


# The winter, settled: answered with `id` (and `id2` for a follow-up) and the answer come, or left to lapse ("").
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


# Spring from here: to its first scene (read).
func _spring() -> String:
	var note := ""
	for i in 400:
		if m.past_spring.active() or m.day > 420:
			break
		note += _go(m.day + 1)
	_read_all()
	return note


# Answer the open spring stage and go through to the sender's answer (read). Returns the ack's text.
func _through(id: String) -> String:
	if not m.past_spring.answer(id):
		return "(not answered)"
	var out: Dictionary = m.past_spring.outgoing()
	if out.is_empty():
		return "(note)"
	_go(int(out["written"]) + 1 + PastSpring.ACK_DAYS)
	_read_all()
	return _text("s_ack_" + str(out["stage"]))


func _ids() -> Array:
	return m.past_spring.options().map(func(o: Dictionary) -> String: return str(o["id"]))


func _true_ids() -> Array:
	return m.past_spring.options().filter(func(o: Dictionary) -> bool: return bool(o["true"])).map(func(o: Dictionary) -> String: return str(o["id"]))


func _spring_ids() -> Array:
	return m.desk_mail.filter(func(l: Dictionary) -> bool: return str(l.get("post", "")).begins_with("s_")).map(
		func(l: Dictionary) -> String: return str(l["post"]))


func _text(id: String) -> String:
	for l in m.desk_mail:
		if str(l.get("post", "")) == id:
			return str(l["text"])
	return ""


func _diary() -> String:
	return "\n\n".join(m.past_spring.diary_pages().map(func(p: Dictionary) -> String: return str(p["text"])))


func _variant() -> String:
	return str(m.past_spring.rec().get("variant", ""))


func _out(key: String) -> String:
	return str(m.past_spring.outcome().get(key, ""))


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


# --- Gating -------------------------------------------------------------------------------------------------------

func _gating() -> void:
	_setup({"status": "legacy"})
	_go(340)
	_check("gating: a legacy past gets no spring letter all year", _spring_ids().is_empty() and m.past_spring.state() == "none")
	m.origin = OriginState.new({"status": "none"})
	m.past_post.reset()
	m.past_spring.reset()
	_go(345)
	_check("gating: a 'none' past gets nothing", _spring_ids().is_empty() and m.past_spring.to_save().is_empty())
	# A winter first seen too late is missed; its spring is missed too.
	_setup({"origin": "security", "security_exit": "stored"}, 141)
	_go(300)
	_check("gating: a missed winter has no spring", m.past_post.state() == "missed" and m.past_spring.state() == "missed" and _spring_ids().is_empty())
	# Not before March, and not before the winter is settled.
	_setup({"origin": "work"})
	_go(PastPost.LETTER_DAY)
	_read_all()
	_go(145)
	m.past_post.answer("ask")
	_go(160)
	_read_all()
	_check("gating: an unsettled winter (the order book's page still open) holds the spring back", m.past_spring.state() == "pending" and m.past_spring.to_save().is_empty())
	m.past_post.answer("explain")
	_go(m.day + 1 + PastPost.ACK_DAYS)
	_spring()
	_check("gating: once it settles, the spring comes on its date (day %d)" % m.day, m.past_spring.active() and m.day >= 190)
	# Nothing before its date.
	_winter({"origin": "security", "security_exit": "stored"}, "ship")
	_go(165)
	_check("gating: nothing arrives before its date (boxes on day 166)", _spring_ids().is_empty() and m.past_spring.state() == "waiting")


# --- A ----------------------------------------------------------------------------------------------------------

func _security() -> void:
	# Paid in the winter: the boxes come, no new charge.
	_winter({"origin": "security", "security_exit": "stored", "contact": "friend"}, "ship")
	var money := m.money
	var note := _spring()
	_check("A paid: the boxes come on day 166 with a letter", m.day == 166 and _variant() == "boxes_arrived" and m.past_spring.parcel_state("boxes") == "received" and note.contains("two boxes"))
	_check("A paid: nothing is charged again", m.money == money and m.money == 470)
	_check("A paid: the sender is the friend who kept them", _text("s_first").begins_with("From your friend, who kept the boxes."))
	var rows: Array = m.panels._mailbox_rows()
	_check("A paid: the mailbox has an Open row for the boxes", rows.any(func(r: Dictionary) -> bool: return str(r.get("action", "")) == "spring:open|boxes"))
	m.mail._clear_read_mail()
	_check("A paid: clearing keeps the letter while the boxes are unopened", _spring_ids() == ["s_first"])
	m.past_spring.open_parcel("boxes")
	_check("A paid: opening them is recorded; nothing goes in the pack", m.past_spring.parcel_state("boxes") == "inspected" and not m.past_spring.open_parcel("boxes"))
	var ack := _through("send_on")
	_check("A paid: asking to send things on is answered with its terms", ack.contains("end of summer") and _out("keeper") == "send_on")
	_go(m.day + 50)
	_read_all()
	_check("A paid: one thing is sent on later: a seed catalogue", _spring_ids().has("s_follow_send_on") and _text("s_follow_send_on").contains("seed catalogue"))
	_check("A paid: the diary says what came and what was in it", _diary().contains("The two boxes came up with the carrier.") and _diary().contains("the kettle from the old room") and _diary().contains("seed catalogue"))
	_check("A paid: a September line", m.past_spring.september().contains("seed catalogue"))
	# Held, asked for: ship now, once, and the boxes come.
	_winter({"origin": "security", "security_exit": "stored"}, "more_time")
	_spring()
	_check("A held: the April letter on day 190, deadline April 30", _variant() == "boxes_deadline" and m.day == 190 and _text("s_first").contains("April 30"))
	_check("A held: no second extension for someone who already asked", not _ids().has("more") and _ids() == ["ship", "release"])
	money = m.money
	m.past_spring.answer("ship")
	_check("A held: shipping costs 30 when written", m.money == money - 30)
	m.past_spring.take_back()
	_check("A held: taking it back returns the 30", m.money == money and m.past_spring.awaiting_player())
	_through("ship")
	_check("A held: the carrier has them (dispatched)", m.past_spring.parcel_state("boxes") == "dispatched")
	_go(m.day + PastSpringScript.PARCEL_DAYS)
	_read_all()
	_check("A held: the boxes arrive five days later, paid once", m.past_spring.parcel_state("boxes") == "received" and _spring_ids().has("s_parcel_boxes") and m.money == money - 30)
	# Held, no answer: the sender gives them away on their stated date.
	_winter({"origin": "security", "security_exit": "stored"}, "more_time")
	_spring()
	_go(212)
	_check("A held: nothing happens until April 30 has passed", m.past_spring.awaiting_player())
	_go(213)
	_read_all()
	_check("A held lapse: May 1, the things go to the charity shop, no parcel", _out("boxes") == "given_away_unanswered" and m.past_spring.parcel_state("boxes") == "" and _spring_ids().has("s_lapse_first"))
	# Held because the winter went unanswered: one bounded extension, then a final stage.
	_winter({"origin": "security", "security_exit": "stored"})
	_spring()
	_check("A unanswered: the extension to May 20 is offered", _variant() == "boxes_deadline_unanswered" and _ids().has("more"))
	_through("more")
	_check("A unanswered: May 20 is the last date; no further extension", _spring_ids().has("s_last") and str(m.past_spring.rec()["stage"]) == "last" and not _ids().has("more") and m.past_spring.answer_by() == 232)
	_go(233)
	_check("A unanswered: after May 20 they give the things away", _out("boxes") == "given_away_unanswered")
	# Released: no boxes, only the papers a shop won't take.
	_winter({"origin": "security", "security_exit": "stored"}, "release")
	_spring()
	_check("A released: no parcel, no charge; the papers letter", _variant() == "boxes_papers" and (m.past_spring.rec()["parcels"] as Dictionary).is_empty() and not _ids().any(func(i: String) -> bool: return i == "ship"))
	_through("post")
	_go(m.day + PastSpringScript.PARCEL_DAYS)
	_read_all()
	m.past_spring.open_parcel("papers")
	_check("A released: the papers come by post; the diary says what they are", _diary().contains("the old rent book and my letters") and m.past_spring.september().contains("papers came back"))
	# The forwarding and extension roads: no boxes anywhere; the deposit.
	for exit in ["forward", "extension"]:
		for wid in ["renew", "end", ""]:
			_winter({"origin": "security", "security_exit": exit}, wid)
			_spring()
			var t := JSON.stringify(m.past_spring.script()).to_lower()
			_check("A %s/%s: the deposit letter, and no boxes anywhere" % [exit, wid if wid != "" else "lapsed"], _variant() == "deposit" and not t.contains("boxes") and (m.past_spring.rec()["parcels"] as Dictionary).is_empty())
	_check("A extension: the letting office writes, and says the rent was settled", _text("s_first").begins_with("From the letting office.") and _text("s_first").contains("rent was settled"))
	money = m.money
	_through("sign")
	_check("A deposit: signing brings 24 coins once", m.money == money + 24 and _out("deposit") == "returned")
	_round_trip()
	_go(m.day + 20)
	_check("A deposit: and never again after a load", m.money == money + 24)
	_winter({"origin": "security", "security_exit": "forward"}, "end")
	_spring()
	money = m.money
	_through("query")
	_check("A deposit: questioning it: they look again and share the cost, 27", m.money == money + 27 and m.past_spring.september().contains("shared"))
	_winter({"origin": "security", "security_exit": "forward"}, "end")
	_spring()
	money = m.money
	m.past_spring.answer("leave")
	_go(m.day + 40)
	_check("A deposit: put away unsigned, the money stays on the account; nothing comes", m.money == money and _out("deposit") == "held_on_account" and _spring_ids() == ["s_first"])


# --- B ----------------------------------------------------------------------------------------------------------

func _work() -> void:
	var openings := {"explained": ["explain", "Your note about Thursday"], "declined": ["decline", "I know you said you couldn't"],
		"sorted_without_me": ["", "I found the Thursday problem myself"]}
	for k in openings:
		_winter({"origin": "work"}, str(openings[k][0]))
		_spring()
		_check("B %s: the letter respects the winter's outcome" % k, _variant() == "offer" and _text("s_first").contains(str(openings[k][1])))
	_check("B: the offer states the time and the pay", _text("s_first").contains("20 coins") and _text("s_first").contains("three hours"))
	_check("B: four choices: take, method, decline, ask", _ids() == ["take", "method", "decline", "ask"])
	# Paid work, once.
	_through("take")
	_check("B take: the sheets come by post; the work is at the desk", _spring_ids().has("s_work") and m.past_spring.rows_for({"post": "s_work"}).any(func(r: Dictionary) -> bool: return str(r.get("note", "")).contains("desk")))
	var rows: Array = m.past_spring.desk_rows()
	var work: Dictionary = {}
	for r in rows:
		if str(r.get("action", "")) == "spring:answer|do":
			work = r
	_check("B take: the desk row shows the hours, the clock times and the pay", not work.is_empty() and str(work["name"]).contains("3 hours") and str(work["about"]).contains("10:00 to 13:00") and str(work["about"]).contains("20 coins"))
	m.current_hour = 24.0
	_check("B take: too late at night it is refused", not m.past_spring.answer("do") and m.past_spring.awaiting_player())
	m.current_hour = 10.0
	var clock := m.clock
	var money := m.money
	m.past_spring.answer("do")
	_check("B take: doing it passes exactly 3 hours", is_equal_approx(m.current_hour, 13.0) and m.clock > clock)
	_check("B take: checked work can't be taken back", not m.past_spring.take_back())
	_go(m.day + 1 + PastSpring.ACK_DAYS)
	_read_all()
	_check("B take: 20 coins with their answer", m.money == money + 20 and _out("work") == "paid")
	_round_trip()
	_go(m.day + 30)
	_check("B take: paid once, also across a load", m.money == money + 20 and m.past_spring.september() == "I checked the March sheets for them. They paid for my time.")
	# The method: a later letter that it worked.
	_winter({"origin": "work"}, "explain")
	_spring()
	_through("method")
	_go(m.day + 40)
	_read_all()
	_check("B method: they write later that it worked", _text("s_follow_method").contains("they balance") and m.past_spring.september().contains("worked"))
	# Ask: one bounded answer, then the same three choices.
	_winter({"origin": "work"}, "explain")
	_spring()
	_through("ask")
	_check("B ask: one answer, then take / method / decline only", _spring_ids().has("s_page") and _ids() == ["take", "method", "decline"])
	_through("decline")
	_check("B decline: the work goes on without you", _out("work") == "declined" and m.past_spring.september().contains("Someone else did"))
	# Work accepted but never done: they manage.
	_winter({"origin": "work"}, "explain")
	_spring()
	_through("take")
	_go(m.day + 30)
	_check("B lapse: sheets not checked in time; they do them from their copies, no pay", _out("work") == "lapsed")


# --- C ----------------------------------------------------------------------------------------------------------

func _household() -> void:
	_winter({"origin": "household", "household_relation": "partner"}, "ask")
	_spring()
	_check("C promised: the key comes in a small parcel with the letter (day 175)", m.day == 175 and m.past_spring.parcel_state("key") == "received")
	_check("C partner: the sender as the player named them", _text("s_first").begins_with("From the person you shared the house with."))
	m.past_spring.open_parcel("key")
	_check("C promised: unwrapping the key", _diary().contains("I unwrapped the key."))
	var money := m.money
	_through("send_mine")
	_go(m.day + PastSpringScript.PARCEL_DAYS)
	_read_all()
	_check("C send: 20 coins, and the two boxes come", m.money == money - 20 and m.past_spring.parcel_state("house_boxes") == "received")
	for key in ["keep", "no_need", ""]:
		_winter({"origin": "household", "household_relation": "private"}, key)
		_spring()
		_check("C %s: no key arrives" % (key if key != "" else "unanswered"), m.past_spring.parcel_state("key") == "" and m.day == 190)
	_check("C private: the sender names nobody", _text("s_first").begins_with("From someone at the house you left."))
	_winter({"origin": "household", "household_relation": "friend"}, "keep")
	_spring()
	_check("C kept: the screenplay's line", _text("s_first").contains("I put the key away as you asked."))
	_through("write")
	_go(m.day + 100)
	_read_all()
	_check("C write: they agree, and write in summer about ordinary things", _out("correspondence") == "now_and_then" and _text("s_follow_write").contains("plum tree"))
	_winter({"origin": "household"}, "keep")
	_spring()
	_through("time")
	_check("C time: more time until the end of September, and no further", _out("belongings") == "held" and int(m.past_spring.outcome()["until_day"]) == 365 and not m.past_spring.awaiting_player())
	_winter({"origin": "household"}, "keep")
	_spring()
	_through("close")
	_check("C close: settled and closed; nothing more comes", _out("correspondence") == "closed" and m.past_spring.september() == "We decided who would keep the clock and the books. That was the last thing left.")
	_winter({"origin": "household", "contact": "former_household", "contact_intent": "boundaries"}, "keep")
	_spring()
	_check("C boundaries: a line will do", _text("s_first").ends_with("A line will do."))


# --- D ----------------------------------------------------------------------------------------------------------

func _curiosity() -> void:
	_setup({"origin": "curiosity", "contact": "friend"})
	m.stats["crop_pumpkin"] = 4
	_go(PastPost.LETTER_DAY)
	_read_all()
	m.past_post.answer("crops")
	_go(m.day + 1 + PastPost.ACK_DAYS)
	m.stats.erase("crop_pumpkin")
	_spring()
	_check("D contact: the spring letter remembers what was told (pumpkins)", _variant() == "friend" and _text("s_first").contains("pumpkins"))
	_check("D contact: nothing claimable before it happens", _true_ids() == ["unsaid", "wrong"])
	m.stats["crop_kale"] = 6
	m.town.visits = 2
	_check("D contact: a harvest and a visit to the village make those true", _true_ids() == ["crops", "place", "unsaid", "wrong"])
	var ack := _through("place")
	_check("D contact: the answer speaks to what was told", ack.contains("village half an hour down the road"))
	m.town.visits = 0
	_check("D contact: and the diary keeps it as told", _diary().contains("Wicker Cove"))
	# The inn roof is not the house.
	_winter({"origin": "curiosity", "contact": "family"})
	m.woodwork.repairs["inn_roof"] = {"day": 160, "cost": {}}
	_spring()
	_check("D unanswered winter: asks once more", _text("s_first").contains("I'll ask once more"))
	ack = _through("repair")
	_check("D repair: the inn roof gets an answer about the village, not the house", ack.contains("A roof in the village") and not ack.contains("house"))
	# No contact: the photograph, at the desk, no letters.
	_winter({"origin": "curiosity", "contact": "none"}, "keep")
	var note := _spring()
	_check("D no contact: no letter; the photograph is at the desk", _spring_ids().is_empty() and note.contains("photograph") and not m.past_spring.desk_rows().is_empty())
	_check("D no contact: comparing needs a real change", not _true_ids().has("compare") and _true_ids() == ["left_out", "keep"])
	m.house_stage = 1
	m.woodwork.repairs["house_1"] = {"day": 170, "cost": {}}
	m.stats["harvested"] = 10
	m.past_spring.answer("compare")
	_check("D no contact: the note says what's different, from the farm", _diary().contains("the holes in the farmhouse walls are patched"))
	_go(m.day + 90)
	_check("D no contact: later, the photograph again, at the desk", str(m.past_spring.rec()["stage"]) == "summer" and m.past_spring.awaiting_player())
	_check("D no contact: adding needs something harvested since", not _true_ids().has("more"))
	m.stats["harvested"] = 14
	m.past_spring.answer("more")
	_check("D no contact: the added line counts what really came in", _diary().contains("4 more crops") and m.past_spring.september().contains("twice"))
	_winter({"origin": "curiosity", "contact": "none"}, "keep")
	_spring()
	m.past_spring.answer("keep")
	_go(m.day + 120)
	_check("D no contact: kept without writing, nothing follows", not m.past_spring.awaiting_player() and m.past_spring.september() == "I kept the advertisement. It showed the house before I arrived.")


# --- E ----------------------------------------------------------------------------------------------------------

func _chance() -> void:
	_winter({"origin": "chance", "chance_loose_end": "work_offer"}, "close")
	_spring()
	_check("E work closed: the screenplay's note, the place filled in February", _variant() == "work_closed" and _text("s_first").contains("We hired someone in February."))
	_winter({"origin": "chance", "chance_loose_end": "work_offer"})
	_spring()
	_check("E work unanswered: the place was filled; no job is held", _text("s_first").contains("The place was filled") and not JSON.stringify(m.past_spring.script()).contains("still held"))
	_winter({"origin": "chance", "chance_loose_end": "work_offer"}, "list")
	_spring()
	_check("E work on the list: the August letter on day 306", _variant() == "work_list" and m.day == 306 and _ids() == ["not_this_year", "off"])
	# Storage paid in the winter.
	_winter({"origin": "chance", "chance_loose_end": "storage"}, "send")
	var money := m.money
	_spring()
	_check("E storage paid: the contents come on day 166, no new charge", m.day == 166 and m.past_spring.parcel_state("unit") == "received" and m.money == money)
	_check("E storage paid: deciding about the contents needs them opened first", not _true_ids().has("keep"))
	m.past_spring.open_parcel("unit")
	_check("E storage paid: no imaginary contents", _diary().contains("I opened the cartons from the storage unit.") and not _diary().contains("tool"))
	_through("give_some")
	_check("E storage paid: the charity shop's receipt", _text("s_ack_first").contains("one carton"))
	# Storage renewed to May: the month extension once, then a lapse that lands after day 240.
	_winter({"origin": "chance", "chance_loose_end": "storage"}, "renew")
	_spring()
	_check("E storage renewed: the May letter on day 222", _variant() == "storage_renewed" and m.day == 222 and _ids() == ["send", "clear", "month"])
	_go(244)
	_read_all()
	_check("E storage renewed lapse: held to June 30 (the letter comes after the parish day)", _spring_ids().has("s_held") and _text("s_held").contains("June 30") and _ids() == ["send", "clear"])
	_go(274)
	_check("E storage renewed: cleared after June 30", _out("storage") == "cleared_unanswered")
	_winter({"origin": "chance", "chance_loose_end": "storage"}, "renew")
	_spring()
	money = m.money
	_through("month")
	_check("E storage renewed: one more month for 5 coins, no more", m.money == money - 5 and str(m.past_spring.rec()["stage"]) == "last" and not _ids().has("month"))
	# Storage unanswered in the winter: the March 30 deadline.
	_winter({"origin": "chance", "chance_loose_end": "storage"})
	_spring()
	_check("E storage unanswered: a reminder on day 160, by March 30", _variant() == "storage_held" and m.day == 160 and m.past_spring.answer_by() == 181)
	_go(182)
	_check("E storage unanswered: cleared after March 30", _out("storage") == "cleared_unanswered")
	_winter({"origin": "chance", "chance_loose_end": "storage"}, "clear")
	_spring()
	_check("E storage cleared: only the papers they won't throw away", _variant() == "storage_cleared")
	# The order.
	_winter({"origin": "chance", "chance_loose_end": "order"}, "send")
	money = m.money
	_spring()
	_check("E order paid: it comes on day 166, no new charge", m.past_spring.parcel_state("order") == "received" and m.money == money)
	_through("return")
	_check("E order return: 6 coins out, 30 back, once; the parcel is returned", m.money == money - 6 + 30 and m.past_spring.parcel_state("order") == "returned")
	_go(m.day + 30)
	_check("E order return: no second refund", m.money == money - 6 + 30)
	_winter({"origin": "chance", "chance_loose_end": "order"}, "refund")
	money = m.money
	_check("E order refunded in winter: the deposit came once (512)", money == 512)
	_spring()
	_check("E order refunded: an offer to buy, no refund again", _variant() == "order_resale" and not JSON.stringify(m.past_spring.script()).contains("\"pay\""))
	_go(m.day + 40)
	_check("E order refunded: nothing more is credited", m.money == money)
	_winter({"origin": "chance", "chance_loose_end": "order"}, "hold")
	_spring()
	money = m.money
	_through("refund")
	_check("E order held: refund the 12 once", m.money == money + 12)
	_round_trip()
	_go(m.day + 40)
	_check("E order held: and not again after a load or the deadline", m.money == money + 12)
	_winter({"origin": "chance", "chance_loose_end": "order"})
	_spring()
	money = m.money
	_go(213)
	_go(230)
	_check("E order unanswered: cancelled after April 30, deposit 12 once", m.money == money + 12 and _out("order") == "cancelled_unanswered")
	# The meeting.
	_winter({"origin": "chance", "chance_loose_end": "meeting"}, "spring")
	_spring()
	_check("E meeting spring: their availability: a Saturday in April, then away", _variant() == "meeting_spring" and _text("s_first").contains("away from the start of May"))
	_through("autumn")
	_check("E meeting autumn: agreed to speak again, no day", m.past_spring.september() == "We agreed to speak again. We haven't chosen a day.")
	_winter({"origin": "chance", "chance_loose_end": "meeting"})
	_spring()
	_check("E meeting lapsed: once more, then they leave it", _variant() == "meeting_lapsed")
	_winter({"origin": "chance", "chance_loose_end": "meeting"}, "close")
	_spring()
	_check("E meeting closed: not reopened; their own move, and a new address", _variant() == "meeting_closed" and not _text("s_first").contains("meet again"))


# --- Honesty -----------------------------------------------------------------------------------------------------

const ROUTES := [
	[{"origin": "security", "security_exit": "stored"}, "ship"], [{"origin": "security", "security_exit": "stored"}, "more_time"],
	[{"origin": "security", "security_exit": "stored"}, ""], [{"origin": "security", "security_exit": "stored"}, "release"],
	[{"origin": "security", "security_exit": "forward"}, "renew"], [{"origin": "security", "security_exit": "extension"}, ""],
	[{"origin": "work"}, "explain"], [{"origin": "household"}, "ask"], [{"origin": "household"}, "keep"],
	[{"origin": "curiosity", "contact": "friend"}, ""], [{"origin": "curiosity", "contact": "none"}, "keep"],
	[{"origin": "chance", "chance_loose_end": "work_offer"}, "close"], [{"origin": "chance", "chance_loose_end": "work_offer"}, "list"],
	[{"origin": "chance", "chance_loose_end": "storage"}, "send"], [{"origin": "chance", "chance_loose_end": "storage"}, "renew"],
	[{"origin": "chance", "chance_loose_end": "storage"}, ""], [{"origin": "chance", "chance_loose_end": "storage"}, "clear"],
	[{"origin": "chance", "chance_loose_end": "order"}, "send"], [{"origin": "chance", "chance_loose_end": "order"}, "refund"],
	[{"origin": "chance", "chance_loose_end": "order"}, "hold"], [{"origin": "chance", "chance_loose_end": "meeting"}, "spring"],
	[{"origin": "chance", "chance_loose_end": "meeting"}, ""], [{"origin": "chance", "chance_loose_end": "meeting"}, "close"],
]


func _honesty() -> void:
	var banned := ["died", "death", "dead", "funeral", "grave", "divorce", "romance", "fog", "crow", "bell", "rook", "agnes",
		"maren", "davy", "vicar", "hollow", "ghost", "curse", "you belong", "realized", "the right choice", "you feel", "relief", "regret"]
	var seen := {}
	for e in ROUTES:
		_winter(e[0], str(e[1]))
		_spring()
		var t := JSON.stringify(m.past_spring.script()).to_lower().replace("deadline", "")
		for w in banned:
			if t.contains(w):
				_check("honesty: %s has no \"%s\"" % [_variant(), w], false)
		seen[_variant()] = true
		# Every route can end with a September line.
		var any_sept := t.contains("\"sept\"")
		if not any_sept:
			_check("honesty: %s has September lines" % _variant(), false)
	_check("honesty: every route checked (%d distinct routes)" % seen.size(), seen.size() == 21, str(seen.keys()))
	# Nothing gives sanity, friendship, skills or tools.
	_winter({"origin": "work"}, "explain")
	var before := [m.sanity, JSON.stringify(m.skill_xp), JSON.stringify(m.folk._to_save()), JSON.stringify(m.inventory)]
	_spring()
	_through("method")
	_go(m.day + 45)
	_check("honesty: spring post changes no sanity, skill, friendship or pack", before == [m.sanity, JSON.stringify(m.skill_xp), JSON.stringify(m.folk._to_save()), JSON.stringify(m.inventory)])
	# Nothing new arrives or lapses on the parish letter's day.
	var on_240 := false
	for e in ROUTES:
		_winter(e[0], str(e[1]))
		_go(239)
		var n := m.desk_mail.size()
		m.day = 240
		var note := m.past_post._morning() + m.past_spring._morning()
		if note != "" or m.desk_mail.size() != n:
			on_240 = true
	_check("honesty: nothing of the old life arrives or lapses on day 240", not on_240)


# --- Saving ----------------------------------------------------------------------------------------------------

func _saving() -> void:
	_winter({"origin": "security", "security_exit": "stored"}, "more_time")
	_spring()
	var money := m.money
	m.past_spring.answer("ship")
	_check("save: a written spring reply loads as written, coins paid once", _round_trip() and str(m.past_spring.outgoing().get("id", "")) == "ship" and m.money == money - 30)
	_go(m.day + 1)
	_check("save: sent loads as sent", _round_trip() and int(m.past_spring.outgoing()["sent"]) >= 0)
	_go(m.day + PastSpring.ACK_DAYS)
	_check("save: dispatched loads as dispatched", _round_trip() and m.past_spring.parcel_state("boxes") == "dispatched")
	_go(m.day + PastSpringScript.PARCEL_DAYS)
	_round_trip()
	_go(m.day + 10)
	var parcels := _spring_ids().filter(func(i: String) -> bool: return i == "s_parcel_boxes")
	_check("save: the parcel arrives once across loads, charged once", parcels.size() == 1 and m.money == money - 30)
	_check("save: the winter record is untouched by spring", str(m.past_post.rec()["outcome"]["boxes"]) == "held" and (m.past_post.rec()["replies"] as Array).size() == 1)
	# A v19 save (no past_spring): the spring is made from its winter, and the winter isn't paid again.
	_winter({"origin": "security", "security_exit": "stored"}, "ship")
	money = m.money
	m.saver._save_game()
	var path := TitleMenu.slot_path(SLOT)
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	data.erase("past_spring")
	data["save_version"] = 19
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(data))
	f.close()
	m.past_spring.data = {"junk": true}
	_check("save: a v19 save loads", m.saver._load_game() and m.past_spring.to_save().is_empty())
	_spring()
	_check("save: a v19 save gets its spring from its winter, nothing paid again", _variant() == "boxes_arrived" and m.money == money)
	# A damaged or mismatched record is dropped and made again from the winter.
	m.past_spring.from_save({"v": 1, "state": "delivered", "thread": "old_workplace", "variant": "offer", "winter": {}, "wfacts": {}})
	_check("save: a record for another route is dropped", m.past_spring.to_save().is_empty())
	m.past_spring.from_save("garbage")
	_check("save: garbage is dropped", m.past_spring.to_save().is_empty())
	# Legacy save: never a spring.
	data["origin"] = {"v": 1, "status": "legacy"}
	data["save_version"] = 17
	data.erase("past_post")
	f = FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(data))
	f.close()
	m.desk_mail = []
	_check("save: a legacy save loads", m.saver._load_game() and m.origin.status() == "legacy")
	_go(320)
	_check("save: a legacy save never gets spring post", _spring_ids().is_empty())


# --- The real day ---------------------------------------------------------------------------------------------------

func _next_day() -> void:
	m.tax_owed = 0
	m.tax_stage = 0
	m._end_day("Test.", false)


func _real_day() -> void:
	_winter({"origin": "chance", "chance_loose_end": "order"}, "hold")
	_go(188)
	while m.day < 190:
		_next_day()
	var titles := m.desk_mail.map(func(l: Dictionary) -> String: return str(l["title"]))
	_check("real day: the spring letter comes with the morning on day 190", titles.has("Your order, by April 30") and m.morning_report.contains("A letter from the shop"))
	var clock := m.clock
	var hour := m.current_hour
	m.mail._open_mailbox()
	_check("real day: reading takes no time", m.past_spring.letter_read("s_first") and m.clock == clock and m.current_hour == hour)
	m._close_panel()
	_check("real day: the diary page is in Notes", m.panels._diary_sections().any(func(s: Dictionary) -> bool:
		return str(s["name"]) == "Notes" and (s["pages"] as Array).any(func(p: Dictionary) -> bool: return str(p["title"]) == "Your order, by April 30")))
	m.past_spring.answer("send")
	_next_day()
	_check("real day: the post takes it", m.morning_report.contains("The post took your letter."))
	m.day = 239
	_next_day()
	_check("real day: the parish letter still comes on day 240", m.act._has("letter") and m.diary_new.has("act_letter"))
	_check("real day: the parish chapters are not touched", StoryAct.FROM == 240 and StoryAct.HARVEST_MOON == 357 and StoryAct.DAVY_FROM == 370)


# --- Input ------------------------------------------------------------------------------------------------------------

func _input() -> void:
	_winter({"origin": "chance", "chance_loose_end": "order"}, "send")
	_spring()
	m.mail._open_mailbox()
	await _frames(3)
	_check("input: the mailbox opens with focus", m.open_tab == "Mailbox" and _focus() != null)
	var ok := await _focus_action("spring:open|order")
	await _key(KEY_SPACE)
	_check("input: Space on \"Unwrap the order\" opens it", ok and m.past_spring.parcel_state("order") == "inspected")
	ok = await _focus_action("spring:answer|return")
	await _pad(JOY_BUTTON_A)
	_check("input: A on \"Send it back\" writes the reply", ok and str(m.past_spring.outgoing().get("id", "")) == "return")
	ok = await _focus_action("spring:take_back")
	await _key(KEY_ENTER)
	_check("input: Enter takes it back", ok and m.past_spring.outgoing().is_empty())
	var entry: Button = null
	for e in _entries():
		if str(e.get_meta("action", "")) == "spring:answer|keep":
			entry = e
	if entry != null:
		await _click(entry)
		var button := _button_named(m.action_bar.panel, "Choose")
		if button != null:
			await _click(button)
	_check("input: a click on the entry and then its button", _out("order") == "kept")
	_check("input: nothing disabled takes focus", _no_disabled_focus(m.action_bar.panel))
	await _pad(JOY_BUTTON_B)
	_check("input: B closes the mailbox", m.open_tab == "")
	# A long letter: the page scrolls, the button row stays in view, PgDn scrolls without pressing anything.
	_winter({"origin": "household", "household_relation": "partner"}, "ask")
	_spring()
	m.desk_mail[0]["text"] += "\n\n" + "A long line to fill the page, so the page must scroll to show all of it. ".repeat(12)
	m.mail._open_mailbox()
	await _frames(4)
	var ab: ActionBar = m.action_bar
	await _focus_action("")
	for i in 3:
		await _key(KEY_UP)
	var first: Button = _entries()[0]
	first.grab_focus()
	await _frames(4)
	_check("input: a long letter overflows its page and says so", ab._detail_overflows() and ab._detail_more)
	_check("input: the long letter doesn't grow its page past the list beside it (%d vs %d)" % [int(ab.detail_page.size.y), int(ab.list_scroll.size.y)],
		ab.detail_page.size.y <= ab.list_scroll.size.y + 2.0)
	var on_letter := ab.detail_scroll.scroll_vertical
	await _focus_action("spring:open|key")
	await _frames(3)
	var row_btn := _button_named(ab.detail_box, "Open")
	_check("input: the page's button stays inside the page", row_btn != null and ab.detail_page.get_global_rect().encloses(row_btn.get_global_rect()))
	first.grab_focus()
	await _frames(4)
	var before := ab.detail_scroll.scroll_vertical
	var mail_before := JSON.stringify(m.past_spring.rec())
	await _key(KEY_PAGEDOWN)
	_check("input: PgDn scrolls the letter and presses nothing", ab.detail_scroll.scroll_vertical > before and JSON.stringify(m.past_spring.rec()) == mail_before)
	# The last entry brings the list's notes into view.
	var entries := _entries()
	(entries[-1] as Button).grab_focus()
	await _frames(5)
	_check("input: the last entry scrolls the list to its notes", ab.list_scroll.scroll_vertical >= int(ab.list_scroll.get_v_scroll_bar().max_value - ab.list_scroll.size.y) - 2)
	await _key(KEY_ESCAPE)
	_check("input: Esc closes it", m.open_tab == "")
	# The desk: paid work driven by the keyboard.
	_winter({"origin": "work"}, "explain")
	_spring()
	_through("take")
	m._toggle_tab("Desk")
	await _frames(3)
	ok = await _focus_action("spring:answer|do")
	m.current_hour = 9.0
	m._refresh_panel()
	await _frames(2)
	ok = await _focus_action("spring:answer|do")
	await _key(KEY_SPACE)
	_check("input: Space at the desk does the work (3 hours)", ok and is_equal_approx(m.current_hour, 12.0) and bool(m.past_spring.outgoing().get("work", false)))
	await _key(KEY_ESCAPE)


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
