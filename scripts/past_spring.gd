class_name PastSpring
extends RefCounted

## CCH-ORIGIN-003: the first spring and summer's post from the life before. This is the second chapter of the same
## correspondence as PastPost (the winter), not a second system: its letters arrive in MainGame.desk_mail with a
## "post" key ("s_..." ids), are read by opening the mailbox, and are answered with reply rows under the letter, the
## same way. A scene with no letter (a photograph, or paid work done on papers that came by post) is done at the
## desk instead. Text is in PastSpringScript.
##
## The route is chosen once, from the winter record's settled outcome (PastPost.rec()), and the winter facts are
## copied in ("winter", "wfacts"), so nothing later in the winter record can change what spring promised. The
## winter record is only read, never written: no winter payment, deposit or letter is ever repeated.
##
## Kept apart, as in the winter: scheduled, delivered, read, decided, written, sent, received; and, new here:
##   parcels   pid -> {state, promised, dispatched, due, received, opened}
##             state: promised (paid for, not sent) -> dispatched (with the carrier) -> received (here, not opened)
##             -> inspected (opened); or returned / cancelled. A parcel is never made up: it exists only when the
##             winter paid for it (the route's "carrier") or a reply sends for it.
##   credits   "stage:choice" (or "lapse:stage") -> coins the sender sent: credited once, ever.
##   follows   a later letter (or desk page) a choice brings: [{id, stage, choice, day, done}]
##   september the factual line the September passage can use, set by the last thing that really happened.
## Reading costs no time. Paid work at the desk passes its stated hours, shown before it is done.
##
## Legacy and "none" pasts get nothing; a winter that was "missed" has no spring. Saved under "past_spring".

const V := 1
const SPRING_FROM := 152      # March 1: the first morning a settled winter can schedule its spring
const MIN_GAP := 5            # the spring's first scene comes at least this long after the winter settles
const LATE_START := 30        # first seen this long after the route's date (an old save): nothing comes
const ACK_DAYS := 6           # as in the winter: a reply goes with the morning post, the answer comes this much later
const MIN_STAGE := 7          # a stage always leaves at least a week to answer
const DIARY_ID := "post_spring"
const PAGE_CHARS := 200

var m: MainGame
var data: Dictionary = {}
var _cache: Dictionary = {}
var _cache_key := ""


func _init(main: MainGame) -> void:
	m = main


# --- The record ------------------------------------------------------------------------------------------------

func reset() -> void:
	data = {}
	_cache = {}
	_cache_key = ""


func to_save() -> Dictionary:
	return data.duplicate(true)


func _template() -> Dictionary:
	return {"v": V, "state": "waiting", "thread": "", "variant": "", "scheduled": 0, "created": 0, "winter": {}, "wfacts": {},
		"letters": [], "decisions": [], "replies": [], "outgoing": {}, "answered": {}, "stage": "first", "stage_day": 0,
		"stage_by": {}, "lapses": {}, "matter": "", "outcome": {}, "facts": {}, "credits": {}, "parcels": {}, "follows": [],
		"september": "", "noted": -1}


# A saved record, checked: anything malformed, or made for a route this origin and winter wouldn't give, is dropped
# and made again from the winter when it is settled (a damaged record can't hold a parcel nobody paid for).
func from_save(d: Variant) -> void:
	reset()
	if typeof(d) != TYPE_DICTIONARY or (d as Dictionary).is_empty():
		return
	var src: Dictionary = (d as Dictionary).duplicate(true)
	if not m.origin.known() or m.past_post.state() == "none":
		return
	if str(src.get("state", "")) == "missed":
		data = {"v": V, "state": "missed"}
		return
	if not str(src.get("state", "")) in ["waiting", "delivered"]:
		return
	var want := _template()
	for key in want:
		if src.has(key) and typeof(src[key]) == typeof(want[key]):
			want[key] = src[key]
		elif src.has(key) and typeof(src[key]) == TYPE_FLOAT and typeof(want[key]) == TYPE_INT:
			want[key] = int(src[key])
	want["state"] = str(src["state"])
	var v := PastSpringScript.variant(m.origin, {"outcome": want["winter"], "facts": want["wfacts"]})
	if v.is_empty() or str(want["thread"]) != m.origin.thread() or str(want["variant"]) != str(v["id"]):
		return
	if not (v["stages"] as Dictionary).has(str(want["stage"])):
		return
	data = want


# The record, or a stand-in that says why there is none yet ("none", "missed", "pending"). Nothing is stored until
# the winter has settled: until then the spring has no route.
func rec() -> Dictionary:
	if not data.is_empty():
		return data
	if not m.origin.known() or m.past_post.state() == "none":
		return {"state": "none"}
	if m.past_post.state() == "missed":
		return {"state": "missed"}
	return {"state": "pending"}


func state() -> String:
	return str(rec().get("state", "none"))


func active() -> bool:
	return state() == "delivered"


func script() -> Dictionary:
	if data.is_empty() or not data.has("winter"):
		return {}
	var key := "%s|%s|%s" % [str(data["variant"]), str(data["winter"]), str(data["wfacts"])]
	if key != _cache_key:
		_cache = PastSpringScript.variant(m.origin, {"outcome": data["winter"], "facts": data["wfacts"]})
		_cache_key = key
	return _cache


func _stages() -> Dictionary:
	return script().get("stages", {})


func _stage_def(stage: String) -> Dictionary:
	return _stages().get(stage, {})


func _where(stage: String) -> String:
	return str(_stage_def(stage).get("where", "desk" if str(script().get("medium", "mail")) == "desk" else "mail"))


func september() -> String:
	return str(rec().get("september", ""))


func outcome() -> Dictionary:
	return rec().get("outcome", {})


# The winter is settled: its letter was answered and the answer came, or it lapsed, or a note was written.
func _winter_settled() -> bool:
	var pp: PastPost = m.past_post
	if pp.state() != "delivered":
		return false
	return not pp.awaiting_player() and pp.outgoing().is_empty() and not str(pp.rec().get("matter", "")) in ["", "awaiting_sender"]


func _create() -> void:
	var pp: PastPost = m.past_post
	if not m.origin.known() or m.day < SPRING_FROM:
		return
	if pp.state() == "missed":
		data = {"v": V, "state": "missed"}
		return
	if not _winter_settled():
		return
	var w: Dictionary = pp.rec()
	var v := PastSpringScript.variant(m.origin, w)
	if v.is_empty():
		return
	if m.day > int(v["deliver"]) + LATE_START:
		data = {"v": V, "state": "missed"}
		return
	var r := _template()
	r["thread"] = m.origin.thread()
	r["variant"] = str(v["id"])
	r["winter"] = (w.get("outcome", {}) as Dictionary).duplicate(true)
	r["wfacts"] = (w.get("facts", {}) as Dictionary).duplicate(true)
	r["created"] = m.day
	r["scheduled"] = _clear_day(maxi(int(v["deliver"]), m.day + MIN_GAP))
	r["stage_day"] = int(r["scheduled"])
	data = r


# The town's letter (StoryAct, day 240) has its morning to itself: nothing of this arrives or lapses that day.
static func _busy(day: int) -> bool:
	return day == StoryAct.FROM


static func _clear_day(day: int) -> int:
	return day + 1 if _busy(day) else day


func _open_stage(stage: String) -> void:
	var r := data
	var st := _stage_def(stage)
	var by := int(st["by"]) if st.has("by") else m.day + int(st.get("within", 30))
	r["stage"] = stage
	r["stage_day"] = m.day
	r["stage_by"][stage] = maxi(by, m.day + MIN_STAGE)
	r["matter"] = "" if str(r["matter"]) == "awaiting_sender" else str(r["matter"])


# The last day the open stage can be answered, or -1 once nothing is open.
func answer_by() -> int:
	if not awaiting_player():
		return -1
	return int(data["stage_by"].get(str(data["stage"]), -1))


func awaiting_player() -> bool:
	if not active():
		return false
	var r := data
	var stage := str(r["stage"])
	if (r["lapses"] as Dictionary).has(stage) or (r["answered"] as Dictionary).has(stage) or not (r["outgoing"] as Dictionary).is_empty():
		return false
	for d in r["decisions"]:
		if str(d.get("stage", "")) == stage and str(d.get("kind", "")) in ["reply", "note", "work"]:
			return false
	return true


func outgoing() -> Dictionary:
	return rec().get("outgoing", {})


func _choice(stage: String, id: String) -> Dictionary:
	for c in _stage_def(stage).get("choices", []):
		if str(c["id"]) == id:
			return c
	return {}


func _parcel(pid: String) -> Dictionary:
	var ps: Dictionary = data["parcels"]
	if not ps.has(pid):
		ps[pid] = {"state": "", "promised": -1, "dispatched": -1, "due": -1, "received": -1, "opened": -1}
	return ps[pid]


func parcel_state(pid: String) -> String:
	return str((rec().get("parcels", {}) as Dictionary).get(pid, {}).get("state", ""))


func _parcel_letter(pid: String) -> String:
	return "s_first" if str(script().get("carrier", "")) == pid else "s_parcel_" + pid


# --- The morning post (MainGame's new day, after the winter's post) ---------------------------------------------

func _morning() -> String:
	if data.is_empty():
		_create()
	if data.is_empty() or not str(data.get("state", "")) in ["waiting", "delivered"]:
		return ""
	var r := data
	var s := script()
	if s.is_empty():
		return ""
	var note := ""
	if str(r["state"]) == "waiting":
		if m.day < int(r["scheduled"]) or _busy(m.day):
			return ""
		r["state"] = "delivered"
		_open_stage("first")
		var car := str(s.get("carrier", ""))
		if car != "":
			# Paid for in the winter: it comes now, with nothing more to pay.
			var p := _parcel(car)
			p["state"] = "received"
			p["promised"] = int(r["created"])
			p["dispatched"] = m.day
			p["received"] = m.day
		if str(s.get("medium", "mail")) == "mail":
			_deliver("s_first", str(s["title"]), _text(str(s["body"]), "first"))
		note += str(s.get("arrive_note", ""))
	var busy := _busy(m.day)
	# The post takes a reply (or the checked work) left in the mailbox yesterday.
	var out: Dictionary = r["outgoing"]
	if not out.is_empty() and int(out.get("sent", -1)) < 0 and m.day > int(out["written"]):
		out["sent"] = m.day
		(r["replies"] as Array).append(out.duplicate(true))
		note += " The post took the checked sheets." if bool(out.get("work", false)) else " The post took your letter."
	if not out.is_empty() and int(out.get("sent", -1)) >= 0 and m.day >= int(out["sent"]) + ACK_DAYS and not busy:
		note += _answer(out)
	# Parcels on their way arrive.
	var parcels: Dictionary = r["parcels"]
	for pid in parcels:
		var p: Dictionary = parcels[pid]
		if str(p["state"]) == "dispatched" and m.day >= int(p["due"]) and not busy:
			var def: Dictionary = s["parcels"].get(pid, {})
			p["state"] = "received"
			p["received"] = m.day
			_deliver("s_parcel_" + str(pid), str(def.get("title", "A parcel")), str(def.get("note", "")))
			note += " " + str(def.get("note", "A parcel has come."))
	# Later letters (or a later page at the desk) a choice brought.
	for f in r["follows"]:
		if int(f["done"]) >= 0 or m.day < int(f["day"]) or busy:
			continue
		f["done"] = m.day
		var fd: Dictionary = _choice(str(f["stage"]), str(f["choice"])).get("follow", {})
		if str(fd.get("next", "")) != "":
			_open_stage(str(fd["next"]))
			note += str(fd.get("note", ""))
		else:
			_deliver("s_follow_" + str(f["id"]), str(fd.get("title", s["title"])), _text(str(fd.get("text", "")), ""))
			note += " Another letter has come: \"%s\"." % str(fd.get("title", s["title"]))
		if str(fd.get("sept", "")) != "":
			r["september"] = str(fd["sept"])
	# Nothing done by the stage's date: the sender acts on the terms they gave, once.
	if awaiting_player() and m.day > answer_by() and not busy:
		note += _lapse()
	return note


func _answer(out: Dictionary) -> String:
	var r := data
	var s := script()
	var stage := str(out["stage"])
	var c := _choice(stage, str(out["id"]))
	r["outgoing"] = {}
	r["answered"][stage] = m.day
	var next := str(c.get("next", ""))
	if next != "":
		# A bounded next step: the sender's answer opens one more stage; no stage loops back.
		_open_stage(next)
		var st := _stage_def(next)
		_deliver("s_" + next, str(st.get("title", s["title"])), _text(str(st.get("body", "")), next))
		return " A letter has come: \"%s\"." % str(st.get("title", s["title"]))
	var pay := int(c.get("pay", 0))
	var key := "%s:%s" % [stage, str(out["id"])]
	if pay > 0 and not (r["credits"] as Dictionary).has(key):
		r["credits"][key] = pay
		m.money += pay
	_deliver("s_ack_" + stage, "An answer: " + str(s["title"]), _text(_fill(str(c.get("ack", "")), out.get("facts", {})), stage))
	if str(c.get("parcel", "")) != "":
		var p := _parcel(str(c["parcel"]))
		p["state"] = "dispatched"
		p["dispatched"] = m.day
		p["due"] = m.day + PastSpringScript.PARCEL_DAYS
	if str(c.get("parcel_state", "")) != "":
		for pid in r["parcels"]:
			if str(r["parcels"][pid]["state"]) in ["received", "inspected"]:
				r["parcels"][pid]["state"] = str(c["parcel_state"])
	_schedule_follow(stage, c)
	if str(c.get("sept", "")) != "":
		r["september"] = _fill(str(c["sept"]), out.get("facts", {}))
	return " An answer to your letter has come%s." % ((", with %d coins in it" % pay) if pay > 0 else "")


func _schedule_follow(stage: String, c: Dictionary) -> void:
	var fd: Dictionary = c.get("follow", {})
	if fd.is_empty():
		return
	(data["follows"] as Array).append({"id": str(c["id"]), "stage": stage, "choice": str(c["id"]),
		"day": _clear_day(m.day + int(fd.get("days", 30))), "done": -1})


func _lapse() -> String:
	var r := data
	var s := script()
	var stage := str(r["stage"])
	var lp: Dictionary = (s.get("lapse", {}) as Dictionary).get(stage, {})
	r["lapses"][stage] = m.day
	if not (lp.get("outcome", {}) as Dictionary).is_empty():
		r["outcome"] = (lp["outcome"] as Dictionary).duplicate(true)
	r["matter"] = str(lp.get("matter", "closed"))
	var pay := int(lp.get("pay", 0))
	if pay > 0 and not (r["credits"] as Dictionary).has("lapse:" + stage):
		r["credits"]["lapse:" + stage] = pay
		m.money += pay
	if str(lp.get("sept", "")) != "":
		r["september"] = str(lp["sept"])
	var next := str(lp.get("next", ""))
	if next != "":
		_open_stage(next)
		var st := _stage_def(next)
		_deliver("s_" + next, str(st.get("title", s["title"])), _text(str(lp.get("text", "")), next))
		return " Another letter has come: \"%s\"." % str(st.get("title", s["title"]))
	if str(lp.get("text", "")) == "":
		return ""
	_deliver("s_lapse_" + stage, "A last word: " + str(s["title"]), _text(str(lp["text"]), stage))
	return " Another letter has come: \"%s\"%s." % [str(s["title"]), (", with %d coins in it" % pay) if pay > 0 else ""]


func _deliver(id: String, title: String, text: String) -> void:
	for l in data["letters"]:
		if str(l["id"]) == id:
			return   # never twice
	(data["letters"] as Array).append({"id": id, "day": m.day, "read": -1})
	m.desk_mail.append({"title": title, "text": text, "unread": true, "post": id})


# The sender's name, then the body with the stage's date filled in.
func _text(body: String, stage: String) -> String:
	var sender := str(script().get("sender", ""))
	body = body.replace("{by}", _date(int(data["stage_by"].get(stage, -1)))) if stage != "" else body
	return body if sender == "" else "%s.\n\n%s" % [sender, body]


func _date(day: int) -> String:
	if day < 1:
		return ""
	var date := m._calendar_date(day)
	return "%s %d" % [str(m.MONTH_NAMES[date["month"]]), int(date["day"])]


static func _fill(text: String, f: Dictionary) -> String:
	for key in f:
		if typeof(f[key]) in [TYPE_STRING, TYPE_INT, TYPE_FLOAT]:
			text = text.replace("{%s}" % str(key), str(f[key]))
	return text


# The mailbox was opened with this letter in it (MailSystem._open_mailbox). Reading takes no time.
func read(id: String) -> void:
	if data.is_empty() or not data.has("letters"):
		return
	for l in data["letters"]:
		if str(l["id"]) == id and int(l["read"]) < 0:
			l["read"] = m.day
			m._diary_page(DIARY_ID)


func letter_read(id: String) -> bool:
	var l := _letter(id)
	return not l.is_empty() and int(l["read"]) >= 0


func _letter(id: String) -> Dictionary:
	for l in rec().get("letters", []):
		if str(l["id"]) == id:
			return l
	return {}


# A letter still waiting on an answer, or on its parcel being opened, stays when the read letters are taken out.
func keeps(id: String) -> bool:
	if not active() or not id.begins_with("s_"):
		return false
	if id == "s_" + str(data["stage"]) and (awaiting_player() or not outgoing().is_empty()):
		return true
	for pid in data["parcels"]:
		if str(data["parcels"][pid]["state"]) == "received" and id == _parcel_letter(str(pid)):
			return true
	return false


# --- What the farm shows (only things done) --------------------------------------------------------------------

func _facts() -> Dictionary:
	var f: Dictionary = m.past_post._facts()
	if m.town.visits > 0:
		f["place"] = "There's a fishing village at the bottom of the hill road, half an hour's walk down. It's called Wicker Cove. I've been down there."
		f["place_short"] = "the village down the hill road, Wicker Cove"
		f["place_ack"] = "A village half an hour down the road. So you're not as far from everything as I thought."
		f["place_id"] = "village"
	elif f.has("woods"):
		f["place"] = str(f["woods"])
		f["place_short"] = "the woods behind the house"
		f["place_ack"] = "Woods right behind the house. The picture showed the trees, but not how far they go."
		f["place_id"] = str(f["woods_id"])
	if f.has("repair"):
		f["repair_ack"] = "So the house is getting the work it needed. The picture made it look as if no one had touched it in years." if f.has("house_repair") else "A roof in the village. So there are neighbours, then. The picture didn't show any."
	var parts: Array = []
	if f.has("house_repair"):
		parts.append(str(f["repair_short"]))
	if f.has("crops"):
		parts.append("the open ground has grown %s" % str(f["crops"]))
	if not parts.is_empty():
		f["compare"] = "; ".join(parts)
	f["harvested"] = int(m.stats.get("harvested", 0))
	var noted := int(rec().get("noted", -1))
	f["more"] = maxi(0, int(f["harvested"]) - noted) if noted >= 0 else 0
	return f


func _verified(c: Dictionary, f: Dictionary) -> bool:
	var needs := str(c.get("needs", ""))
	if needs.begins_with("opened:"):
		return parcel_state(needs.trim_prefix("opened:")) == "inspected"
	match needs:
		"":
			return true
		"harvest":
			return f.has("crops")
		"repair":
			return f.has("repair")
		"place":
			return f.has("place")
		"any":
			return f.has("compare")
		"more":
			return int(f.get("more", 0)) > 0
	return false


func _needs_text(c: Dictionary) -> String:
	var needs := str(c.get("needs", ""))
	if needs.begins_with("opened:"):
		return "Opening what came first"
	return str({"harvest": "A crop you have harvested", "repair": "A repair you have done", "place": "A place you have been",
		"any": "A repair to the house, or a harvest", "more": "Something harvested since your last note"}.get(needs, ""))


const _TOLD := {"harvest": ["crop", "crops", "Crops"], "repair": ["repair", "repair_short", "repair_id", "repair_ack"],
	"place": ["place", "place_short", "place_ack", "place_id"], "any": ["compare"], "more": ["more"]}


# --- Answering ---------------------------------------------------------------------------------------------------

func options() -> Array:
	if not awaiting_player():
		return []
	var f := _facts()
	var out: Array = []
	for c in _stage_def(str(data["stage"])).get("choices", []):
		var cost := int(c.get("cost", 0))
		out.append({"id": str(c["id"]), "label": str(c["label"]), "kind": str(c.get("kind", "reply")),
			"text": _fill(str(c.get("reply", "")), f), "about": str(c.get("about", "")), "cost": cost,
			"hours": float(c.get("hours", 0.0)), "pay": int(c.get("pay", 0)), "true": _verified(c, f),
			"afford": m.money >= cost, "needs": _needs_text(c)})
	return out


# The player answers. Everything is checked again here; nothing happens for a reply that isn't true now, can't be
# paid for, has no time left tonight, or has been written already. Returns whether anything was done.
func answer(id: String) -> bool:
	if not awaiting_player():
		return false
	var r := data
	var stage := str(r["stage"])
	var c := _choice(stage, id)
	if c.is_empty():
		return false
	var f := _facts()
	if not _verified(c, f):
		m._show_message("Not yet: %s." % _needs_text(c).to_lower() if _needs_text(c) != "" else "Not yet.")
		return false
	var kind := str(c.get("kind", "reply"))
	var cost := int(c.get("cost", 0))
	if kind in ["reply", "work"] and cost > 0 and m.money < cost:
		m._show_message("That needs %d coins in the envelope." % cost)
		return false
	var hours := float(c.get("hours", 0.0))
	if kind == "work" and m.current_hour + hours > m.PASTIME_LAST_HOUR:
		m._show_message("It is too late to start that tonight.")
		return false
	var told := {}
	for key in _TOLD.get(str(c.get("needs", "")), []):
		if f.has(key):
			told[key] = f[key]
	(r["decisions"] as Array).append({"stage": stage, "id": id, "kind": kind, "day": m.day, "facts": told})
	var prior: Dictionary = (r["outcome"] as Dictionary).duplicate(true)
	if not (c.get("outcome", {}) as Dictionary).is_empty():
		r["outcome"] = (c["outcome"] as Dictionary).duplicate(true)
	r["matter"] = str(c.get("matter", r["matter"]))
	r["facts"] = told
	if kind == "note":
		if int(r["noted"]) < 0:
			r["noted"] = int(f["harvested"])
		_schedule_follow(stage, c)
		if str(c.get("sept", "")) != "":
			r["september"] = _fill(str(c["sept"]), told)
		m._show_message(str(c.get("done", "Done.")))
	else:
		if kind == "work":
			# The work takes its time, as the row said: needs drop and the fire burns down, as at a pastime.
			m.clock += hours * m.DAY_LENGTH / (m.DAY_END_HOUR - m.START_HOUR)
			m.current_hour += hours
			m._update_needs(hours)
		if cost > 0:
			m.money -= cost
		r["outgoing"] = {"stage": stage, "id": id, "written": m.day, "sent": -1, "coins": cost, "facts": told, "work": kind == "work",
			"prior": prior}
		if kind == "work":
			m._show_message("You spend %s on the work, then leave it in the mailbox for the morning post." % m.desk._hours_text(hours))
		else:
			m._show_message("You write your answer and leave it in the mailbox for the morning post%s." % ((", with %d coins" % cost) if cost > 0 else ""))
	m._diary_page(DIARY_ID)
	m.play_sfx_at("panel", -8.0)
	return true


# A reply the post hasn't taken can be taken back: coins come back out of the envelope and the stage opens again.
# Checked work can't be unchecked, so it isn't taken back.
func take_back() -> bool:
	var r := rec()
	var out: Dictionary = r.get("outgoing", {})
	if out.is_empty() or int(out.get("sent", -1)) >= 0 or bool(out.get("work", false)):
		return false
	m.money += int(out.get("coins", 0))
	var kept: Array = []
	var dropped := false
	for i in range((r["decisions"] as Array).size() - 1, -1, -1):
		var d: Dictionary = r["decisions"][i]
		if not dropped and str(d["kind"]) == "reply" and str(d["stage"]) == str(out["stage"]) and str(d["id"]) == str(out["id"]):
			dropped = true
			continue
		kept.push_front(d)
	kept.append({"stage": str(out["stage"]), "id": "take_back", "kind": "take_back", "day": m.day, "facts": {}})
	r["decisions"] = kept
	r["outgoing"] = {}
	r["outcome"] = (out.get("prior", {}) as Dictionary).duplicate(true)
	r["matter"] = ""
	m._show_message("You take your letter back out of the mailbox%s." % ((" and the %d coins with it" % int(out.get("coins", 0))) if int(out.get("coins", 0)) > 0 else ""))
	return true


# Opening what came: the record notes it, and the diary says what was in it. Nothing goes in the pack.
func open_parcel(pid: String) -> bool:
	if not active() or parcel_state(pid) != "received":
		return false
	var p := _parcel(pid)
	var def: Dictionary = script()["parcels"].get(pid, {})
	p["state"] = "inspected"
	p["opened"] = m.day
	if str(def.get("sept", "")) != "":
		data["september"] = str(def["sept"])
	m._diary_page(DIARY_ID)
	m._show_message(str(def.get("open_text", "")))
	m.play_sfx_at("panel", -8.0)
	return true


func _action(id: String) -> void:
	if id == "take_back":
		take_back()
	elif id.begins_with("answer|"):
		answer(id.trim_prefix("answer|"))
	elif id.begins_with("open|"):
		open_parcel(id.trim_prefix("open|"))


# --- Rows: under a letter in the mailbox, and at the desk ---------------------------------------------------------

func rows_for(letter: Dictionary) -> Array:
	var id := str(letter.get("post", ""))
	if not id.begins_with("s_") or not active():
		return []
	var rows: Array = []
	var s := script()
	for pid in data["parcels"]:
		if parcel_state(str(pid)) == "received" and id == _parcel_letter(str(pid)):
			var def: Dictionary = s["parcels"].get(pid, {})
			rows.append({"name": str(def.get("open_label", "Open it")), "status": "Not opened", "status_kind": "short",
				"about": "Open it to see what came. Opening it takes no time.", "button": "Open", "action": "spring:open|" + str(pid), "enabled": true})
	if id != "s_" + str(data["stage"]):
		return rows
	if _where(str(data["stage"])) == "desk":
		if awaiting_player():
			rows.append({"note": "This is done at the desk in the house, by %s. %s" % [_date(answer_by()), str(_stage_def(str(data["stage"])).get("late", ""))]})
		elif not outgoing().is_empty():
			rows.append_array(_reply_rows())
		return rows
	rows.append_array(_reply_rows())
	return rows


# The answer rows for the open stage: the reply waiting for the post, the reply sent, or the replies to choose from.
func _reply_rows() -> Array:
	var rows: Array = []
	var out := outgoing()
	if not out.is_empty() and int(out.get("sent", -1)) < 0:
		var c := _choice(str(out["stage"]), str(out["id"]))
		var row := {"name": "Your answer: waiting for the post", "status": "Not sent yet", "status_kind": "short",
			"about": _fill(str(c.get("reply", "")), out.get("facts", {})) + ("\n\n%d coins in the envelope." % int(out["coins"]) if int(out["coins"]) > 0 else "")
				+ "\n\nThe post takes it in the morning."}
		if not bool(out.get("work", false)):
			row["about"] += " Until then you can take it back."
			row["button"] = "Take it back"
			row["action"] = "spring:take_back"
			row["enabled"] = true
		rows.append(row)
		return rows
	if not out.is_empty():
		rows.append({"note": "Your answer went with the post on %s. The answer usually takes about a week." % _date(int(out["sent"]))})
		return rows
	if not awaiting_player():
		return rows
	var st := _stage_def(str(data["stage"]))
	var unavailable: Array = []
	for o in options():
		if not bool(o["true"]):
			unavailable.append(str(o["needs"]).to_lower())
			continue
		rows.append(_option_row(o))
	var by := answer_by()
	rows.append({"note": "To answer, pick one of the replies above. Answer by %s. %s" % [_date(by), str(st.get("late", ""))]})
	if not unavailable.is_empty():
		rows.append({"note": "You can only write about what is really so. Not yet: %s." % ", ".join(unavailable)})
	return rows


func _option_row(o: Dictionary) -> Dictionary:
	var kind := str(o["kind"])
	var row := {"name": str(o["label"]), "about": str(o["text"]) if str(o["text"]) != "" else str(o["about"]),
		"button": {"reply": "Write it", "note": "Write it down", "work": "Do the work"}.get(kind, "Choose"),
		"action": "spring:answer|" + str(o["id"]), "enabled": true}
	if kind == "note" and str(o["text"]) == "":
		row["button"] = "Choose"
	if kind == "work":
		var hours := float(o["hours"])
		var start := m.current_hour
		row["name"] = "%s (%s)" % [str(o["label"]), m.desk._hours_text(hours)]
		row["about"] = "%s\n\nIt takes %s of your time, now: from %s to %s. They pay %d coins when they have the sheets back." % [
			str(o["text"]), m.desk._hours_text(hours), _clock(start), _clock(start + hours), int(o["pay"])]
		row["needs"] = [{"text": "Finished before 02:00", "ok": start + hours <= m.PASTIME_LAST_HOUR}]
		row["enabled"] = start + hours <= m.PASTIME_LAST_HOUR
	if int(o["cost"]) > 0:
		var needs: Array = row.get("needs", [])
		needs.append({"text": "%d coins in the envelope" % int(o["cost"]), "have": m.money, "ok": bool(o["afford"])})
		row["needs"] = needs
		row["enabled"] = bool(row["enabled"]) and bool(o["afford"])
	return row


static func _clock(hour: float) -> String:
	var h := int(floorf(hour)) % 24
	var mins := int(roundf((hour - floorf(hour)) * 60.0)) % 60
	return "%02d:%02d" % [h, mins]


# The desk's rows (the Diary tab): a scene with no letter, or work on papers that came by post.
func desk_rows() -> Array:
	if not active():
		return []
	var stage := str(data["stage"])
	if _where(stage) != "desk" or not (awaiting_player() or (not outgoing().is_empty() and int(outgoing().get("sent", -1)) < 0)):
		return []
	var s := script()
	var st := _stage_def(stage)
	var rows: Array = []
	var body := str(st.get("body", "")) if stage != "first" or str(s.get("medium", "mail")) == "mail" else str(s["body"])
	if str(s.get("medium", "mail")) == "mail":
		body = "The letter is in the mailbox:\n\n" + body.replace("{by}", _date(int(data["stage_by"].get(stage, -1))))
	rows.append({"name": str(st.get("title", s["title"])), "status": "To do", "status_kind": "short", "value": body})
	if not outgoing().is_empty():
		rows.append_array(_reply_rows())
		return rows
	var unavailable: Array = []
	for o in options():
		if not bool(o["true"]):
			unavailable.append(str(o["needs"]).to_lower())
			continue
		rows.append(_option_row(o))
	if str(s.get("medium", "mail")) == "mail":
		rows.append({"note": "Due back by %s. %s" % [_date(answer_by()), str(st.get("late", ""))]})
	if not unavailable.is_empty():
		rows.append({"note": "Not yet: %s." % ", ".join(unavailable)})
	return rows


# --- The diary (a Notes page in your hand, from the record only) ---------------------------------------------

func diary_pages() -> Array:
	if not active():
		return []
	var r := data
	var s := script()
	var stages := _stages()
	var events: Array = []   # [day, seq, text]
	var add := func(day: int, text: String) -> void:
		if text.strip_edges() != "":
			events.append([day, events.size(), text])
	var mail := str(s.get("medium", "mail")) == "mail"
	if mail:
		var first := _letter("s_first")
		if first.is_empty() or int(first["read"]) < 0:
			return []
		add.call(int(first["day"]), str(s["received"]))
	for pid in r["parcels"]:
		var p: Dictionary = r["parcels"][pid]
		var def: Dictionary = s["parcels"].get(pid, {})
		if int(p["received"]) >= 0 and letter_read(_parcel_letter(str(pid))):
			add.call(int(p["received"]), str(def.get("diary_came", "")))
		if int(p["opened"]) >= 0:
			add.call(int(p["opened"]), str(def.get("diary_opened", "")))
	for l in r["letters"]:
		var lid := str(l["id"])
		if lid != "s_first" and lid.begins_with("s_") and stages.has(lid.trim_prefix("s_")) and int(l["read"]) >= 0:
			add.call(int(l["day"]), str(stages[lid.trim_prefix("s_")].get("received", "")))
	for d in r["decisions"]:
		if str(d["kind"]) == "take_back":
			continue
		var c := _choice(str(d["stage"]), str(d["id"]))
		var line := _fill(str(c.get("diary", "")), d.get("facts", {}))
		if str(d["kind"]) in ["reply", "work"]:
			var sent := -1
			for rep in r["replies"]:
				if str(rep["stage"]) == str(d["stage"]) and str(rep["id"]) == str(d["id"]):
					sent = int(rep["sent"])
			var out: Dictionary = r["outgoing"]
			var pending: bool = not out.is_empty() and str(out["stage"]) == str(d["stage"]) and str(out["id"]) == str(d["id"])
			if sent < 0 and not pending:
				continue
			line += " It went with the morning post." if sent >= 0 else " It is in the mailbox for the morning post."
		add.call(int(d["day"]), line)
	for l in r["letters"]:
		var lid := str(l["id"])
		if lid.begins_with("s_ack_") and int(l["read"]) >= 0:
			var st := lid.trim_prefix("s_ack_")
			for rep in r["replies"]:
				if str(rep["stage"]) == st:
					add.call(int(l["day"]), _fill(str(_choice(st, str(rep["id"])).get("ack_diary", "")), rep.get("facts", {})))
	for f in r["follows"]:
		if int(f["done"]) < 0:
			continue
		var fd: Dictionary = _choice(str(f["stage"]), str(f["choice"])).get("follow", {})
		if str(fd.get("next", "")) == "" and letter_read("s_follow_" + str(f["id"])):
			add.call(int(f["done"]), str(fd.get("diary", "")))
	for st in r["lapses"]:
		var lp: Dictionary = (s.get("lapse", {}) as Dictionary).get(st, {})
		var lid := ("s_" + str(lp["next"])) if str(lp.get("next", "")) != "" else "s_lapse_" + str(st)
		if str(lp.get("text", "")) == "" or letter_read(lid):
			add.call(int(r["lapses"][st]), str(lp.get("diary", "")))
	if events.is_empty():
		return []
	events.sort_custom(func(a: Array, b: Array) -> bool: return a[0] < b[0] or (a[0] == b[0] and a[1] < b[1]))
	var paras: Array = []
	for i in events.size():
		paras.append(_dated(int(events[i][0]), i == 0) + str(events[i][2]))
	var pages: Array = []
	var chunk: Array = []
	var size := 0
	for p in paras:
		if not chunk.is_empty() and size + str(p).length() > PAGE_CHARS:
			pages.append(chunk)
			chunk = []
			size = 0
		chunk.append(p)
		size += str(p).length()
	pages.append(chunk)
	var out: Array = []
	for i in pages.size():
		out.append({"id": DIARY_ID, "title": str(s["title"]) + (", continued" if i > 0 else ""), "text": "\n\n".join(pages[i])})
	return out


func _dated(day: int, first := false) -> String:
	var date := m._calendar_date(maxi(1, day))
	if first:
		return "Day %d, %s %d. " % [day, str(m.MONTH_NAMES[date["month"]]), int(date["day"])]
	return "%s %d. " % [str(m.MONTH_NAMES[date["month"]]), int(date["day"])]
