class_name SecondAutumn
extends RefCounted

## CCH-ORIGIN-005: "The Second Year Remembers". In the second calendar autumn (Day 366 is October 1 of year two), one
## scene from the life before comes back, chosen once from what the winter (PastPost) and the spring (PastSpring)
## really settled (SecondAutumnScript.pick), and one morning remembers a practical fact of the year at the farm.
## Text is in SecondAutumnScript.
##
## When: the scene comes on the first quiet morning from October 7 (day FROM), after Davy's night (day 370) and the
## morning after it, and never on the three days around All Hallows (395-397). It waits while anything from the spring
## is still open (an unanswered letter, an answer in the post, a parcel on its way, a later letter still to come), so it
## never talks over the spring. It never closes: unless a sender has real terms (a date), it can be answered whenever
## the player likes. The practical morning comes from October 2 (WORLD_FROM). Neither comes on the morning the first
## September's page note is given. Nothing opens by itself; nothing takes time.
##
## A letter is answered under it in the mailbox, or at the desk (the Diary tab); a scene with no letter is at the desk.
## A reply goes with the morning post; the sender's answer comes ACK_DAYS later, with any coins legitimately the
## player's (credited once) or a parcel (here only once that answer has come; opened from the row under it).
## The September page (FirstSeptember) is read, never written: if it was written before the answer, the answer's diary
## entry quotes its last line, with when it was written, and one plain fact of how things stand now.
##
## The record (saved under "second_autumn"; {} until something happens):
##   v          record version (V)
##   world      {} or {day, id, line (the morning's sentence), diary}: the practical morning, once
##   route      the scene's id (SecondAutumnScript), chosen once; "" before it comes
##   origin     the origin it was chosen for (a record for another origin is dropped)
##   medium     "mail" or "desk"
##   state      "delivered" (waiting on the player), "answered", or "lapsed" (a sender's date passed)
##   delivered  the morning it came; read: the day its letter was read (-1); by: the date to answer by (-1: none)
##   prior      what it was chosen from (small ids only): winter, spring (outcome dicts), parcels, contact
##   reflection the September page's closing as it stood when the scene came: {} (not written) or {id, written}
##   choice, kind, answered, keeps, settles, said (the diary line), text (what was written), refl ([quote, now]), paid
##   ack        {} or {due, delivered, title, text, diary, note, pay, parcel}: the sender's answer
##   parcel     {} or {title, open_label, open_text, diary_came, diary_opened, state (received/inspected), received, opened}
##   credits    key -> coins credited (once ever per key: "ack", "lapse")
##   lapse      {} or {day, text, diary}

const V := 1
const FROM := 372            # October 7 of year two: after Davy's night (StoryAct.DAVY_FROM) and the morning after
const WORLD_FROM := 367      # October 2 of year two: the practical morning
const ACK_DAYS := 6          # as in the winter and spring: the answer comes this long after the post takes a reply
const WAIT_CAP := 60         # a spring that hasn't even arrived by FROM + this is no longer waited for
const ALL_HALLOWS := 396     # October 31 of year two: the bell's night
const DIARY_ID := "second_autumn"
const WORLD_DIARY := "second_autumn_world"
const POST := "y2_letter"
const ACK_POST := "y2_answer"
const LAPSE_POST := "y2_lapse"
const ROUTES := ["a_deposit", "a_send_on", "a_papers", "a_desk", "b_paid", "b_method", "b_closed", "b_desk",
	"c_held", "c_letter", "c_unanswered", "c_keepsake", "d_photo", "e_collect", "e_meeting", "e_desk"]

var m: MainGame
var data: Dictionary = {}


func _init(main: MainGame) -> void:
	m = main


func reset() -> void:
	data = {}


func to_save() -> Dictionary:
	return data.duplicate(true)


func from_save(d: Variant) -> void:
	data = sanitize(d, m.origin.origin() if m.origin.known() else "")


# A saved record, checked. A scene for another origin (or for a past that isn't known) is dropped, so a legacy save
# never gets one; the practical morning is kept on its own. Numbers come back from JSON as floats: ints again here.
static func sanitize(d: Variant, origin: String) -> Dictionary:
	if typeof(d) != TYPE_DICTIONARY or (d as Dictionary).is_empty():
		return {}
	var src: Dictionary = FirstSeptember._whole((d as Dictionary).duplicate(true))
	var out := {"v": V}
	var w: Variant = src.get("world", {})
	if typeof(w) == TYPE_DICTIONARY and int((w as Dictionary).get("day", -1)) >= WORLD_FROM and str((w as Dictionary).get("line", "")) != "":
		out["world"] = {"day": int(w["day"]), "id": str(w.get("id", "")), "line": str(w["line"]), "diary": str(w.get("diary", ""))}
	var route := str(src.get("route", ""))
	if route == "" or not route in ROUTES or origin == "" or str(src.get("origin", "")) != origin \
			or not str(src.get("state", "")) in ["delivered", "answered", "lapsed"] or int(src.get("delivered", -1)) < FROM:
		return out if out.has("world") else {}
	out["route"] = route
	out["origin"] = origin
	out["medium"] = "mail" if str(src.get("medium", "")) == "mail" else "desk"
	out["state"] = str(src["state"])
	out["delivered"] = int(src["delivered"])
	out["read"] = int(src.get("read", -1))
	out["by"] = int(src.get("by", -1))
	for key in ["prior", "reflection", "ack", "parcel", "credits", "lapse"]:
		out[key] = src[key] if typeof(src.get(key, null)) == TYPE_DICTIONARY else {}
	if out["state"] != "delivered":
		if str(src.get("choice", "")) == "" and out["state"] == "answered":
			out["state"] = "delivered"   # an answer with no choice in it: the scene is still waiting
		else:
			for key in ["choice", "kind", "said", "text"]:
				out[key] = str(src.get(key, ""))
			out["answered"] = int(src.get("answered", -1))
			out["keeps"] = bool(src.get("keeps", false))
			out["settles"] = bool(src.get("settles", false))
			out["paid"] = int(src.get("paid", 0))
			out["refl"] = (src["refl"] as Array).map(func(x: Variant) -> String: return str(x)) if typeof(src.get("refl", null)) == TYPE_ARRAY else []
	if out["state"] == "delivered":
		out["ack"] = {}
	return out


# --- Read-only queries (for later work: CCH-ORIGIN-006) -----------------------------------------------------------

func route_id() -> String:
	return str(data.get("route", ""))


func state() -> String:
	return str(data.get("state", "")) if route_id() != "" else ""


func answered() -> bool:
	return state() == "answered"


func choice() -> String:
	return str(data.get("choice", "")) if answered() else ""


func world_moment() -> Dictionary:
	return data.get("world", {})


# --- When ---------------------------------------------------------------------------------------------------------

# Davy's night and its morning after, and the three days around All Hallows: nothing of this comes, lapses or answers.
static func busy(day: int) -> bool:
	return day == StoryAct.DAVY_FROM or day == StoryAct.DAVY_FROM + 1 or absi(day - ALL_HALLOWS) <= 1


static func clear_day(day: int) -> int:
	while busy(day):
		day += 1
	return day


# Nothing from the winter or spring is still open: no letter waiting on the player, no answer in the post, no parcel
# on its way, no later letter still to come. A spring not yet arrived is waited for (a little while).
func _past_settled() -> bool:
	var pp: PastPost = m.past_post
	var ps: PastSpring = m.past_spring
	if pp.state() == "delivered" and (pp.awaiting_player() or not pp.outgoing().is_empty()):
		return false
	if ps.state() in ["waiting", "pending"] and not pp.state() in ["none", "missed"] and m.day < FROM + WAIT_CAP:
		return false
	if ps.active():
		if ps.awaiting_player() or not ps.outgoing().is_empty():
			return false
		var r: Dictionary = ps.rec()
		for f in r.get("follows", []):
			if int((f as Dictionary).get("done", -1)) < 0:
				return false
		for pid in r.get("parcels", {}):
			if ps.parcel_state(str(pid)) in ["promised", "dispatched"]:
				return false
	return true


# The morning (MainGame's new day, after the first September's page). One line at most: an answer or a lapse, else
# the scene, else the practical morning. Not on a busy day, nor on the morning the September note is given.
func _morning() -> String:
	if busy(m.day) or int(m.first_september.data.get("noticed", -1)) == m.day:
		return ""
	var note := _settle()
	if note == "":
		note = _deliver()
	if note == "":
		note = _world()
	return note


func _deliver() -> String:
	if route_id() != "" or m.day < FROM or not m.origin.known() or not _past_settled():
		return ""
	var ctx := _ctx()
	var id := SecondAutumnScript.pick(ctx)
	var r := SecondAutumnScript.route(id, ctx)
	if r.is_empty():
		return ""
	var fs: FirstSeptember = m.first_september
	data["v"] = V
	data["route"] = id
	data["origin"] = m.origin.origin()
	data["medium"] = str(r["medium"])
	data["state"] = "delivered"
	data["delivered"] = m.day
	data["read"] = -1
	data["by"] = clear_day(m.day + int(r["by_days"])) if int(r["by_days"]) > 0 else -1
	data["prior"] = {"winter": (ctx["w"] as Dictionary).duplicate(true), "spring": (ctx["s"] as Dictionary).duplicate(true),
		"parcels": (ctx["parcels"] as Dictionary).duplicate(true), "contact": str(ctx["contact_form"]), "keepsake": str(ctx["keepsake"])}
	data["reflection"] = {"id": fs.reflection(), "written": int(fs.data.get("written", -1))} if fs.written() else {}
	data["ack"] = {}
	data["parcel"] = {}
	data["credits"] = {}
	data["lapse"] = {}
	if str(r["medium"]) == "mail":
		_post(POST, str(r["title"]), _letter_text(str(r["sender"]), str(r["body"])))
	m._diary_page(DIARY_ID)
	return str(r["arrive_note"])


func _world() -> String:
	if data.has("world") or m.day < WORLD_FROM:
		return ""
	var w := SecondAutumnScript.world(_ctx())
	data["v"] = V
	data["world"] = {"day": m.day, "id": str(w[0]), "line": str(w[1]), "diary": str(w[2])}
	m._diary_page(WORLD_DIARY)
	return str(w[1])


# The sender's answer, or the sender's date passing with no answer.
func _settle() -> String:
	var st := state()
	if st == "answered":
		var a: Dictionary = data.get("ack", {})
		if a.is_empty() or int(a.get("delivered", -1)) >= 0 or m.day < int(a.get("due", 0)):
			return ""
		a["delivered"] = m.day
		var r := route()
		_post(ACK_POST, str(a.get("title", "An answer")), _letter_text(str(r.get("sender", "")), str(a.get("text", ""))))
		_credit("ack", int(a.get("pay", 0)))
		var p: Dictionary = a.get("parcel", {})
		if not p.is_empty():
			var kept := p.duplicate(true)
			kept["state"] = "received"
			kept["received"] = m.day
			kept["opened"] = -1
			data["parcel"] = kept
		m._diary_page(DIARY_ID)
		var note := str(a.get("note", ""))
		return note if note != "" else " A letter has come in the mailbox, in answer to yours."
	if st == "delivered" and int(data.get("by", -1)) > 0 and m.day >= int(data["by"]):
		var r := route()
		var l: Dictionary = r.get("lapse", {})
		var by := _date(int(data["by"]))
		data["state"] = "lapsed"
		data["lapse"] = {"day": m.day, "text": str(l.get("text", "")), "diary": str(l.get("diary", "")).replace("{by}", by)}
		if str(l.get("text", "")) != "":
			_post(LAPSE_POST, str(r["title"]), _letter_text(str(r.get("sender", "")), str(l["text"])))
		_credit("lapse", int(l.get("pay", 0)))
		m._diary_page(DIARY_ID)
		return " A personal letter has come in the mailbox." if str(l.get("text", "")) != "" else ""
	return ""


func _credit(key: String, coins: int) -> void:
	if coins <= 0:
		return
	var c: Dictionary = data["credits"]
	if c.has(key):
		return
	c[key] = coins
	m.money += coins


func _post(id: String, title: String, text: String) -> void:
	for l in m.desk_mail:
		if str(l.get("post", "")) == id:
			return   # never twice
	m.desk_mail.append({"title": title, "text": text, "unread": true, "post": id})


static func _letter_text(sender: String, body: String) -> String:
	return body if sender == "" else "%s.\n\n%s" % [sender, body]


func _date(day: int) -> String:
	if day < 1:
		return ""
	var date := m._calendar_date(day)
	return "%s %d" % [str(m.MONTH_NAMES[date["month"]]), int(date["day"])]


# --- What is true now -----------------------------------------------------------------------------------------------

func _ctx() -> Dictionary:
	var o: OriginState = m.origin
	var pp: PastPost = m.past_post
	var ps: PastSpring = m.past_spring
	var fs: FirstSeptember = m.first_september
	var pr: Dictionary = ps.rec()
	var parcels := {}
	for pid in pr.get("parcels", {}):
		parcels[str(pid)] = ps.parcel_state(str(pid))
	var follows_done: Array = []
	for f in pr.get("follows", []):
		if int((f as Dictionary).get("done", -1)) >= 0:
			follows_done.append(str((f as Dictionary).get("choice", "")))
	var pf: Dictionary = pp._facts()
	var inn: Dictionary = m.town.inn_record()
	var inn_month := ""
	if not inn.is_empty():
		inn_month = str(m.MONTH_NAMES[m._calendar_date(maxi(1, int(inn.get("day", 1))))["month"]])
	var owned: bool = m.estate._deed_owned()
	var w: Variant = pp.rec().get("outcome", {}) if pp.state() == "delivered" else {}
	return {"day": m.day, "origin": o.origin(), "contact": o.contact(),
		"contact_form": "private" if o.contact() == "private" else ("named" if o.has_contact() else "none"),
		"contact_intent": o.contact_intent(), "keepsake": o.keepsake(), "exit": o.choice("security_exit"),
		"work_exit": o.choice("work_exit"), "loose_end": o.choice("chance_loose_end"), "relation": o.household_sender(),
		"who": str({"friend": "your friend", "family": "your family"}.get(o.contact(), "the person who saw you off")),
		"w": w if typeof(w) == TYPE_DICTIONARY else {}, "w_state": pp.state(),
		"s": (ps.outcome() as Dictionary) if ps.active() else {}, "s_state": ps.state(),
		"s_facts": pr.get("facts", {}) if typeof(pr.get("facts", {})) == TYPE_DICTIONARY else {},
		"parcels": parcels, "follows_done": follows_done,
		"stage": fs._house_stage(), "mended": int(m.stats.get("mended", 0)), "harvested": int(m.stats.get("harvested", 0)),
		"crops": str(pf.get("crops", "")), "woods_id": str(pf.get("woods_id", "")), "visits": int(m.town.visits),
		"inn_month": inn_month, "hewn": int(m.woodwork.hewn), "asked": fs._asked(),
		"deed": "owned" if owned else ("part" if m.estate.deed_paid > 0 else "town"), "deed_paid": int(m.estate.deed_paid),
		"deed_price": int(m.estate.DEED_PRICE),
		"refl_facts": fs.facts(), "open_then": not fs.open_matters().is_empty()}


func route() -> Dictionary:
	if route_id() == "":
		return {}
	return SecondAutumnScript.route(route_id(), _ctx())


func _choice(r: Dictionary, id: String) -> Dictionary:
	for c in r.get("choices", []):
		if str(c["id"]) == id:
			return c
	return {}


func _body(r: Dictionary) -> String:
	return str(r.get("body", "")).replace("{by}", _date(int(data.get("by", -1))))


# --- Answering ----------------------------------------------------------------------------------------------------

# The player's one response. Once only; it costs no time. A reply's coins go in the envelope now.
func answer(id: String) -> bool:
	if state() != "delivered":
		return false
	var r := route()
	var c := _choice(r, id)
	if c.is_empty():
		return false
	var kind := str(c["kind"])
	var cost := int(c.get("cost", 0))
	if cost > 0 and m.money < cost:
		m._show_message("That needs %d coins in the envelope." % cost)
		return false
	if kind == "open":
		if m.past_spring.parcel_state(str(c["pid"])) != "received" or not m.past_spring.open_parcel(str(c["pid"])):
			return false
	var ctx := _ctx()
	data["choice"] = id
	data["kind"] = kind
	data["answered"] = m.day
	data["keeps"] = bool(c.get("keeps", false))
	data["settles"] = bool(c.get("settles", false))
	data["said"] = str(c.get("diary", ""))
	data["text"] = str(c.get("text", ""))
	data["refl"] = _reflection(r, c, ctx)
	data["paid"] = cost
	data["state"] = "answered"
	if cost > 0:
		m.money -= cost
	if kind == "reply" and str(c.get("ack", "")) != "":
		data["ack"] = {"due": clear_day(m.day + 1 + ACK_DAYS), "delivered": -1, "title": str(c.get("ack_title", r["title"])),
			"text": str(c["ack"]), "diary": str(c.get("ack_diary", "")), "note": str(c.get("ack_note", "")), "pay": int(c.get("pay", 0)),
			"parcel": (c.get("parcel", {}) as Dictionary).duplicate(true)}
	if kind == "reply":
		m._show_message("You write it and leave it in the mailbox for the morning post%s." % ((", with %d coins" % cost) if cost > 0 else ""))
	elif kind == "note":
		m._show_message(str(c.get("done", "Done.")))
	m._diary_page(DIARY_ID)
	m.play_sfx_at("panel", -8.0)
	return true


# The September page's last line, if it was written before this answer, and how things stand now.
func _reflection(r: Dictionary, c: Dictionary, ctx: Dictionary) -> Array:
	var fs: FirstSeptember = m.first_september
	if not fs.written() or int(fs.data.get("written", 9999)) > m.day:
		return []
	var written := int(fs.data["written"])
	return SecondAutumnScript.reflection_lines(fs.reflection(), str(fs.data.get("words", "")), written, _date(written), ctx, r, c)


func open_parcel() -> bool:
	var p: Dictionary = data.get("parcel", {})
	if p.is_empty() or str(p.get("state", "")) != "received":
		return false
	p["state"] = "inspected"
	p["opened"] = m.day
	m._diary_page(DIARY_ID)
	m._show_message(str(p.get("open_text", "")))
	m.play_sfx_at("panel", -8.0)
	return true


func _action(id: String) -> void:
	if id.begins_with("answer|"):
		answer(id.trim_prefix("answer|"))
	elif id == "open":
		open_parcel()


# --- The mailbox ----------------------------------------------------------------------------------------------------

func read(id: String) -> void:
	if id == POST and route_id() != "" and int(data.get("read", -1)) < 0:
		data["read"] = m.day
		m._diary_page(DIARY_ID)


# A letter still waiting on an answer, or an answer whose parcel is still shut, stays when the read letters go.
func keeps(id: String) -> bool:
	if id == POST:
		return state() == "delivered"
	if id == ACK_POST:
		return str((data.get("parcel", {}) as Dictionary).get("state", "")) == "received"
	return false


func rows_for(letter: Dictionary) -> Array:
	var id := str(letter.get("post", ""))
	if id == POST and state() == "delivered":
		return _choice_rows(route())
	if id == ACK_POST:
		return _parcel_rows()
	return []


func _parcel_rows() -> Array:
	var p: Dictionary = data.get("parcel", {})
	if str(p.get("state", "")) != "received":
		return []
	return [{"name": str(p.get("open_label", "Open it")), "status": "Not opened", "status_kind": "short",
		"about": "Open it to see what came. Opening it takes no time.", "button": "Open", "action": "autumn:open", "enabled": true}]


func _choice_rows(r: Dictionary) -> Array:
	var rows: Array = []
	for c in r.get("choices", []):
		var kind := str(c["kind"])
		var cost := int(c.get("cost", 0))
		var about := str(c.get("about", ""))
		if kind == "reply":
			about = "You write:\n\n\"%s\"%s\n\nThe post takes it in the morning. What you write is final." % [str(c["text"]),
				("\n\n%d coins go in the envelope." % cost) if cost > 0 else ""]
		var row := {"name": str(c["label"]), "about": about, "button": {"reply": "Write it", "open": "Open"}.get(kind, "Choose"),
			"action": "autumn:answer|" + str(c["id"]), "enabled": true}
		if cost > 0:
			row["needs"] = [{"text": "%d coins in the envelope" % cost, "have": m.money, "ok": m.money >= cost}]
			row["enabled"] = m.money >= cost
		rows.append(row)
	if int(data.get("by", -1)) > 0:
		rows.append({"note": "Answer by %s. %s" % [_date(int(data["by"])), str(r.get("late", ""))]})
	else:
		rows.append({"note": "Nothing is due. It can wait as long as you like. None of these is the right one."})
	return rows


# The desk's Diary tab: the scene and its choices while it waits; a parcel to open; then one line saying it is done.
func desk_rows() -> Array:
	var st := state()
	if st == "":
		return []
	var r := route()
	if r.is_empty():
		return []
	var rows: Array = []
	if st == "delivered":
		var value := _body(r)
		if str(r["medium"]) == "mail":
			value = "The letter is in the mailbox:\n\n" + _letter_text(str(r["sender"]), value)
		rows.append({"name": str(r["title"]), "status": "To do", "status_kind": "short", "value": value})
		var fs: FirstSeptember = m.first_september
		if fs.written():
			rows.append({"note": "Your page for September ends: \"%s\"" % str(fs.data.get("words", ""))})
		rows.append_array(_choice_rows(r))
		return rows
	rows.append_array(_parcel_rows())
	var summary := str(data.get("said", "")) if st == "answered" else str((data.get("lapse", {}) as Dictionary).get("diary", ""))
	var a: Dictionary = data.get("ack", {})
	if not a.is_empty() and int(a.get("delivered", -1)) < 0:
		summary += " The answer usually takes about a week."
	rows.append({"name": str(r["title"]), "status": "Done", "status_kind": "done", "value": summary.strip_edges(),
		"about": summary.strip_edges() + "\n\nIt is in your diary, under Notes."})
	return rows


# --- The diary (Notes pages in the player's hand, from the record only) ----------------------------------------------

func diary_pages() -> Array:
	var out: Array = []
	var w: Dictionary = world_moment()
	if not w.is_empty() and str(w.get("diary", "")) != "":
		out.append_array(_pages(WORLD_DIARY, SecondAutumnScript.WORLD_TITLE, [["%s. %s" % [_date(int(w["day"])), str(w["diary"])]]]))
	var st := state()
	if st == "":
		return out
	var r := route()
	if r.is_empty():
		return out
	var events: Array = []   # [day, seq, sentences]
	var mail := str(r["medium"]) == "mail"
	if mail and int(data.get("read", -1)) >= 0:
		events.append([int(data["read"]), 0, [str(r.get("received", ""))]])
	if st == "answered":
		var said: Array = [str(data.get("said", ""))]
		said.append_array(data.get("refl", []))
		events.append([int(data.get("answered", m.day)), 1, said])
		var a: Dictionary = data.get("ack", {})
		if not a.is_empty() and int(a.get("delivered", -1)) >= 0 and str(a.get("diary", "")) != "":
			events.append([int(a["delivered"]), 2, [str(a["diary"])]])
	elif st == "lapsed":
		var l: Dictionary = data.get("lapse", {})
		events.append([int(l.get("day", m.day)), 1, [str(l.get("diary", ""))]])
	var p: Dictionary = data.get("parcel", {})
	if int(p.get("opened", -1)) >= 0:
		events.append([int(p["opened"]), 3, [str(p.get("diary_opened", ""))]])
	events.sort_custom(func(a: Array, b: Array) -> bool: return a[0] < b[0] or (a[0] == b[0] and a[1] < b[1]))
	# One paragraph a day, the date joined to its first sentence so it never stands alone at the foot of a page.
	var paras: Array = []
	var last_day := -1
	for e in events:
		var sentences: Array = (e[2] as Array).filter(func(s: Variant) -> bool: return str(s).strip_edges() != "")
		if sentences.is_empty():
			continue
		if int(e[0]) == last_day:
			(paras[-1] as Array).append_array(sentences)
			continue
		last_day = int(e[0])
		sentences[0] = "%s. %s" % [_date(last_day), str(sentences[0])]
		paras.append(sentences)
	if st == "delivered":
		if mail and int(data.get("read", -1)) < 0:
			paras.append(["A letter has come from before: \"%s\"." % str(r["title"]), str(r["waiting"])])
		elif mail:
			paras.append([str(r["waiting"])])
		else:
			paras.append(["The papers from before are in the desk: \"%s\"." % str(r["title"]), str(r["waiting"])])
	if paras.is_empty():
		return out
	out.append_array(_pages(DIARY_ID, SecondAutumnScript.TITLE, paras))
	return out


# Whole sentences, a paragraph running on to the next page where it must (FirstSeptember's estimate of a page).
func _pages(id: String, title: String, paras: Array) -> Array:
	var pages: Array = []
	var page: Array = []
	var used := 0
	for p in paras:
		var cur: Array = []
		for s in p:
			var budget := FirstSeptember.FIRST_LINES if pages.is_empty() else FirstSeptember.PAGE_LINES
			var gap := 1 if not page.is_empty() and cur.is_empty() else 0
			var lines := FirstSeptember._lines(" ".join(cur + [str(s)])) - (FirstSeptember._lines(" ".join(cur)) if not cur.is_empty() else 0)
			if used + gap + lines > budget and (not page.is_empty() or not cur.is_empty()):
				if not cur.is_empty():
					page.append(cur)
				pages.append(page)
				page = []
				cur = []
				used = 0
				gap = 0
				lines = FirstSeptember._lines(str(s))
			cur.append(str(s))
			used += gap + lines
		if not cur.is_empty():
			page.append(cur)
	if not page.is_empty():
		pages.append(page)
	var out: Array = []
	for i in pages.size():
		out.append({"id": id, "title": title + (", continued" if i > 0 else ""),
			"text": "\n\n".join((pages[i] as Array).map(func(q: Array) -> String: return " ".join(q)))})
	return out
