class_name PastPost
extends RefCounted

## CCH-ORIGIN-002: the first winter's post from the life before (one thread per origin, text in PastPostScript).
## It is a small correspondence record on top of the existing mailbox, not a second mailbox: letters arrive in
## MainGame.desk_mail like every other letter (with a "post" key naming them here), are read by opening the mailbox,
## and are answered there with the reply rows this file gives PanelRows._mailbox_rows.
##
## What is kept apart, so nothing intended is ever taken for done:
##   scheduled   the record exists and waits for LETTER_DAY            ("state": "waiting")
##   delivered   a letter came in the morning post                     (letters[i].day)
##   read        the mailbox was opened with it in                     (letters[i].read)
##   decided     the player chose an answer (or chose to wait)         (decisions[])
##   written     a reply is in the mailbox for the morning post        (outgoing, sent == -1; it can be taken back)
##   sent        the morning post took it                              (outgoing.sent; replies[])
##   received    the sender's answer came back                         (answered[stage] = day; the ack letter)
##   matter      pending, open, arranged, awaiting_sender, resolved or closed (and the outcome for later scenes)
## Coins enclosed with a reply are paid once when it is written and given back once if it is taken back before the
## post; a deposit the sender returns is credited once, the morning their answer comes ("credited"). Reading costs no
## time and nothing else (the mailbox panel holds the clock, as every panel does).
##
## Legacy and "none" records get nothing (no letter, no invented past). A save first seen after LAST_DELIVER without
## a letter is "missed": nothing comes, rather than a winter letter in spring. Saved under "past_post".

const V := 1
const LETTER_DAY := 104       # January 12 of the first winter (Day 1 is October 1): clear of the Longest Night
                              # (day 82), the New Year tax bill and feast (day 93) and Maren's minute book (day 150)
const LAST_DELIVER := 140     # February 17: a later first sight of the record sends nothing
const ANSWER_BY := 151        # February 28, the end of winter: the date every first letter states
const ANSWER_MORE := 14       # days to answer a follow-up letter that comes late in the winter
const ACK_DAYS := 6           # a reply goes out with the morning post; the answer comes this many days later
const DIARY_ID := "post_winter"
const PAGE_CHARS := 200       # text on one diary page before the record runs on to the next

var m: MainGame
var data: Dictionary = {}


func _init(main: MainGame) -> void:
	m = main


# --- The record ------------------------------------------------------------------------------------------------

static func fresh(o: OriginState) -> Dictionary:
	var v := PastPostScript.variant(o)
	if v.is_empty():
		return {"v": V, "state": "none"}
	return {"v": V, "state": "waiting", "thread": o.thread(), "variant": str(v["id"]), "scheduled": LETTER_DAY,
		"letters": [], "decisions": [], "replies": [], "outgoing": {}, "answered": {}, "stage": "first",
		"stage_day": LETTER_DAY, "lapsed": -1, "matter": "", "outcome": {}, "credited": 0, "facts": {}, "note_day": -1}


# The record for this farm, made from the origin the first time it's asked for (an old save has none saved).
func rec() -> Dictionary:
	if data.is_empty():
		data = fresh(m.origin)
	return data


func reset() -> void:
	data = {}


func to_save() -> Dictionary:
	return data.duplicate(true)


# A saved record, checked: anything malformed, or made for a different origin than the save's, starts again from
# the origin (a damaged record can't hold a letter the road never earned).
func from_save(d: Variant) -> void:
	data = {}
	if typeof(d) != TYPE_DICTIONARY or (d as Dictionary).is_empty():
		return
	var src: Dictionary = (d as Dictionary).duplicate(true)
	var want := fresh(m.origin)
	if str(src.get("state", "")) == "none" or str(want["state"]) == "none":
		data = want
		return
	if str(src.get("thread", "")) != str(want.get("thread", "")) or str(src.get("variant", "")) != str(want.get("variant", "")):
		return
	for key in want:
		if src.has(key) and typeof(src[key]) == typeof(want[key]):
			want[key] = src[key]
		elif src.has(key) and typeof(src[key]) == TYPE_FLOAT and typeof(want[key]) == TYPE_INT:
			want[key] = int(src[key])
	if not str(want["state"]) in ["waiting", "delivered", "missed"]:
		want["state"] = "waiting"
	data = want


func script() -> Dictionary:
	return PastPostScript.variant(m.origin)


func state() -> String:
	return str(rec().get("state", "none"))


func active() -> bool:
	return state() == "delivered"


func _stage() -> Dictionary:
	var stages: Dictionary = script().get("stages", {})
	return stages.get(str(rec()["stage"]), {})


# The last day a reply to the open stage can be written, or -1 once nothing is open.
func answer_by() -> int:
	if not awaiting_player():
		return -1
	if str(rec()["stage"]) == "first":
		return ANSWER_BY
	return maxi(ANSWER_BY, int(rec()["stage_day"]) + ANSWER_MORE)


# A letter waits on the player: delivered, nothing posted or waiting to be posted, and not lapsed.
func awaiting_player() -> bool:
	var r := rec()
	return active() and int(r["lapsed"]) < 0 and not (r["answered"] as Dictionary).has(str(r["stage"])) \
		and (r["outgoing"] as Dictionary).is_empty() and not _decided_final()


func _decided_final() -> bool:
	for d in rec()["decisions"]:
		if str(d.get("stage", "")) == str(rec()["stage"]) and str(d.get("kind", "")) in ["reply", "note"]:
			return true
	return false


func _last_decision() -> Dictionary:
	var ds: Array = rec()["decisions"]
	return {} if ds.is_empty() else ds[-1]


# --- The morning post (MainGame's new day, after the other post) -------------------------------------------------

func _morning() -> String:
	var r := rec()
	if str(r["state"]) == "none":
		return ""
	var note := ""
	if str(r["state"]) == "waiting":
		if m.day < int(r["scheduled"]):
			return ""
		if m.day > LAST_DELIVER:
			r["state"] = "missed"
			return ""
		r["state"] = "delivered"
		r["stage_day"] = m.day
		var s := script()
		_deliver("first", str(s["title"]), _letter_text(str(s["sender"]), str(s["body"])))
		note += " A personal letter has come in the mailbox."
	if str(r["state"]) != "delivered":
		return note
	# The post takes a reply left in the mailbox yesterday.
	var out: Dictionary = r["outgoing"]
	if not out.is_empty() and int(out.get("sent", -1)) < 0 and m.day > int(out["written"]):
		out["sent"] = m.day
		(r["replies"] as Array).append(out.duplicate(true))
		note += " The post took your letter."
	# The sender's answer (or their next letter) comes ACK_DAYS after the reply went.
	if not out.is_empty() and int(out.get("sent", -1)) >= 0 and m.day >= int(out["sent"]) + ACK_DAYS:
		note += _answer(out)
	# Nothing was sent by the date the letter gave: the sender acts on their own terms, once.
	if awaiting_player() and m.day > answer_by():
		note += _lapse()
	# The no-contact photograph: the morning after a note is written beside it, it is still on the desk.
	if int(r["note_day"]) >= 0 and m.day == int(r["note_day"]) + 1:
		note += " The photograph is still on the desk, with your note beside it."
	return note


func _answer(out: Dictionary) -> String:
	var r := rec()
	var c := _choice(str(out["stage"]), str(out["id"]))
	r["outgoing"] = {}
	r["answered"][str(out["stage"])] = m.day
	var s := script()
	var next := str(c.get("next", ""))
	if next != "":
		# A bounded follow-up: the sender's one answer opens the stage's decision; there is no further round.
		var st: Dictionary = s["stages"][next]
		r["stage"] = next
		r["stage_day"] = m.day
		r["matter"] = ""
		_deliver(next, str(st.get("title", s["title"])), _letter_text(str(s["sender"]), str(st["body"])))
		return " A second letter has come: \"%s\"." % str(st.get("title", s["title"]))
	var refund := int(c.get("refund", 0))
	var text := _fill(str(c["ack"]), out.get("facts", {}))
	if refund > 0 and int(r["credited"]) == 0:
		r["credited"] = refund
		m.money += refund
	_deliver("ack", "An answer: " + str(s["title"]), _letter_text(str(s["sender"]), text))
	return " An answer to your letter has come%s." % ((", with %d coins in it" % refund) if refund > 0 else "")


func _lapse() -> String:
	var r := rec()
	var lapse: Dictionary = script()["lapse"]
	r["lapsed"] = m.day
	r["outcome"] = (lapse["outcome"] as Dictionary).duplicate(true)
	r["matter"] = str(lapse["matter"])
	if str(lapse["text"]) == "":
		return ""
	var s := script()
	_deliver("lapse", "A last word: " + str(s["title"]), _letter_text(str(s["sender"]), str(lapse["text"])))
	return " Another letter has come: \"%s\"." % str(s["title"])


func _deliver(id: String, title: String, text: String) -> void:
	for l in rec()["letters"]:
		if str(l["id"]) == id:
			return   # never twice
	(rec()["letters"] as Array).append({"id": id, "day": m.day, "read": -1})
	m.desk_mail.append({"title": title, "text": text, "unread": true, "post": id})


static func _letter_text(sender: String, body: String) -> String:
	return "%s.\n\n%s" % [sender, body]


# The mailbox was opened with this letter in it (MailSystem._open_mailbox). Reading takes no time.
func read(id: String) -> void:
	for l in rec().get("letters", []):
		if str(l["id"]) == id and int(l["read"]) < 0:
			l["read"] = m.day
			m._diary_page(DIARY_ID)


func letter_read(id: String) -> bool:
	for l in rec().get("letters", []):
		if str(l["id"]) == id:
			return int(l["read"]) >= 0
	return false


# A letter still waiting on an answer stays in the mailbox when the read letters are taken out.
func keeps(id: String) -> bool:
	return active() and (awaiting_player() or not (rec()["outgoing"] as Dictionary).is_empty()) \
		and id == _open_letter_id()


func _open_letter_id() -> String:
	return str(rec().get("stage", ""))


# --- Answering (the mailbox's reply rows) ----------------------------------------------------------------------

func _choice(stage: String, id: String) -> Dictionary:
	var stages: Dictionary = script().get("stages", {})
	for c in (stages.get(stage, {}) as Dictionary).get("choices", []):
		if str(c["id"]) == id:
			return c
	return {}


# What the farm really shows, for a reply that describes it. Only things done are ever in here.
func _facts() -> Dictionary:
	var f := {}
	var best := ""
	var most := 0
	for kind in m.CROPS:
		var n := int(m.stats.get("crop_" + str(kind), 0))
		if n > most:
			most = n
			best = str(kind)
	if best != "":
		var plural := {"turnip": "turnips", "kale": "kale", "peas": "peas", "corn": "corn", "potato": "potatoes", "leek": "leeks",
			"pumpkin": "pumpkins", "parsnip": "parsnips", "strawberry": "strawberries", "garlic": "garlic",
			"blueberry": "blueberries", "apple": "apples"}
		var word := str(plural.get(best, str(m.CROPS[best]["label"]).to_lower()))
		f["crop"] = best
		f["crops"] = word
		f["Crops"] = word.capitalize()
	var repairs: Dictionary = m.woodwork.repairs
	var house := 0
	for i in range(3, 0, -1):
		if repairs.has("house_%d" % i) or m.house_stage >= i:
			house = i
			break
	var mended := int(m.stats.get("mended", 0))
	if house == 3:
		f["repair"] = "I've finished restoring the farmhouse: the walls, the roof and the windows."
		f["repair_short"] = "the farmhouse is restored, walls, roof and windows"
		f["repair_id"] = "house_3"
	elif house == 2:
		f["repair"] = "I've put new shingles on the farmhouse roof and glass back in the windows."
		f["repair_short"] = "the farmhouse roof has new shingles and the windows have glass again"
		f["repair_id"] = "house_2"
	elif house == 1:
		f["repair"] = "I've patched the holes in the farmhouse walls and boarded over the broken windows."
		f["repair_short"] = "the holes in the farmhouse walls are patched and the broken windows boarded"
		f["repair_id"] = "house_1"
	elif mended > 0:
		f["repair"] = "I've been mending boards in the farmhouse, one or two at a time."
		f["repair_short"] = "%d %s in the farmhouse %s mended" % [mended, "board" if mended == 1 else "boards", "is" if mended == 1 else "are"]
		f["repair_id"] = "boards"
	if f.has("repair_id"):
		f["house_repair"] = true
	elif repairs.has("inn_roof"):
		f["repair"] = "I mended a leak in the roof of the inn down in the village."
		f["repair_short"] = "a leak in the roof of the village inn is mended"
		f["repair_id"] = "inn_roof"
	if m.nearwood.trips > 0:
		f["woods"] = "There's a trail behind the house that goes up into the woods. I go up it for timber."
		f["woods_id"] = "nearwood"
	elif m.trek.treks_done > 0:
		f["woods"] = "The woods start behind the field and go on further than I can see. I've walked some way into them."
		f["woods_id"] = "trek"
	elif m.trek.edge_done:
		f["woods"] = "The woods start behind the field and go on further than I can see. I've walked out to where they begin."
		f["woods_id"] = "edge"
	return f


# Whether the farm backs a reply up: harvest, repair (for the photograph, a repair to the house itself), woods.
func _verified(c: Dictionary, f: Dictionary) -> bool:
	match str(c.get("needs", "")):
		"":
			return true
		"harvest":
			return f.has("crops")
		"repair":
			return f.has("repair") and (str(rec()["variant"]) != "notice" or f.has("house_repair"))
		"woods":
			return f.has("woods")
	return false


func _needs_text(c: Dictionary) -> String:
	match str(c.get("needs", "")):
		"harvest":
			return "A crop you have harvested"
		"repair":
			return "A repair to the farmhouse you have done" if str(rec()["variant"]) == "notice" else "A repair you have done"
		"woods":
			return "Having walked in the woods"
	return ""


static func _fill(text: String, f: Dictionary) -> String:
	for key in ["crops", "Crops", "repair_short", "repair", "woods"]:
		text = text.replace("{%s}" % key, str(f.get(key, "")))
	return text


# Every reply a stage offers, with whether it can be written now and why not.
func options() -> Array:
	if not awaiting_player():
		return []
	var f := _facts()
	var out: Array = []
	for c in _stage().get("choices", []):
		var cost := int(c.get("cost", 0))
		var true_now := _verified(c, f)
		var deferred := str(c.get("kind", "")) == "defer" and str(_last_decision().get("id", "")) == "defer" \
			and str(_last_decision().get("stage", "")) == str(rec()["stage"])
		out.append({"id": str(c["id"]), "label": str(c["label"]), "kind": str(c.get("kind", "reply")),
			"text": _fill(str(c.get("reply", c.get("about", ""))), f), "cost": cost,
			"true": true_now, "afford": m.money >= cost, "deferred": deferred,
			"needs": _needs_text(c), "about": str(c.get("about", ""))})
	return out


# The player answers. Everything is checked again here; a reply that isn't true now, or can't be paid for, or that
# has already been written, changes nothing. Returns whether anything was done.
func answer(id: String) -> bool:
	if not awaiting_player():
		return false
	var r := rec()
	var stage := str(r["stage"])
	var c := _choice(stage, id)
	if c.is_empty():
		return false
	var f := _facts()
	if not _verified(c, f):
		m._show_message("You can only write about what you have really done.")
		return false
	var kind := str(c.get("kind", "reply"))
	var cost := int(c.get("cost", 0))
	if kind == "reply" and cost > 0 and m.money < cost:
		m._show_message("That needs %d coins in the envelope." % cost)
		return false
	# What this answer tells, kept with it: a later answer or diary line says only this, even if the farm changes.
	var told := {}
	var keys: Array = {"harvest": ["crop", "crops", "Crops"], "repair": ["repair", "repair_short", "repair_id"],
		"woods": ["woods", "woods_id"]}.get(str(c.get("needs", "")), [])
	for key in keys:
		if f.has(key):
			told[key] = f[key]
	(r["decisions"] as Array).append({"stage": stage, "id": id, "kind": kind, "day": m.day})
	match kind:
		"defer":
			m._diary_page(DIARY_ID)
			m._show_message("You put the letter back in its envelope. There's no answer to post yet.")
		"note":
			r["outcome"] = (c["outcome"] as Dictionary).duplicate(true)
			r["outcome"]["day"] = m.day
			r["matter"] = str(c["matter"])
			r["facts"] = told
			r["note_day"] = m.day
			m._diary_page(DIARY_ID)
			m._show_message("You write a line in your diary beside the photograph." if str(c.get("reply", "")) != "" else "You put the correction with the photograph.")
		_:
			if cost > 0:
				m.money -= cost
			r["outgoing"] = {"stage": stage, "id": id, "written": m.day, "sent": -1, "coins": cost, "facts": told}
			r["outcome"] = (c["outcome"] as Dictionary).duplicate(true)
			r["matter"] = str(c["matter"])
			r["facts"] = told
			m._diary_page(DIARY_ID)
			m._show_message("You write your answer and leave it in the mailbox for the morning post%s." % ((", with %d coins" % cost) if cost > 0 else ""))
	m.play_sfx_at("panel", -8.0)
	return true


# A reply not yet taken by the post can be taken back: the coins come back out of the envelope, nothing is sent.
func take_back() -> bool:
	var r := rec()
	var out: Dictionary = r["outgoing"]
	if out.is_empty() or int(out.get("sent", -1)) >= 0:
		return false
	m.money += int(out.get("coins", 0))
	(r["decisions"] as Array).append({"stage": str(out["stage"]), "id": "take_back", "kind": "take_back", "day": m.day})
	# The decision made with that reply is undone, so the stage can be answered again.
	var kept: Array = []
	var dropped := false
	for i in range((r["decisions"] as Array).size() - 1, -1, -1):
		var d: Dictionary = r["decisions"][i]
		if not dropped and str(d["kind"]) == "reply" and str(d["stage"]) == str(out["stage"]) and str(d["id"]) == str(out["id"]):
			dropped = true
			continue
		kept.push_front(d)
	r["decisions"] = kept
	r["outgoing"] = {}
	r["outcome"] = {}
	r["matter"] = ""
	r["facts"] = {}
	m._show_message("You take your letter back out of the mailbox%s." % ((" and the %d coins with it" % int(out.get("coins", 0))) if int(out.get("coins", 0)) > 0 else ""))
	return true


func outgoing() -> Dictionary:
	return rec().get("outgoing", {})


# --- The mailbox rows (PanelRows._mailbox_rows, under the letter they answer) ----------------------------------

func rows_for(letter: Dictionary) -> Array:
	var id := str(letter.get("post", ""))
	if id == "" or not active() or id != _open_letter_id():
		return []
	var rows: Array = []
	var out := outgoing()
	if not out.is_empty() and int(out.get("sent", -1)) < 0:
		var c := _choice(str(out["stage"]), str(out["id"]))
		rows.append({"name": "Your answer: waiting for the post", "status": "Not sent yet", "status_kind": "short",
			"about": _fill(str(c.get("reply", "")), out.get("facts", {})) + ("\n\n%d coins in the envelope." % int(out["coins"]) if int(out["coins"]) > 0 else "")
				+ "\n\nThe post takes it in the morning. Until then you can take it back.",
			"button": "Take it back", "action": "post:take_back", "enabled": true})
		return rows
	if not out.is_empty():
		rows.append({"note": "Your answer went with the post on day %d. The answer usually takes about a week." % int(out["sent"])})
		return rows
	if not awaiting_player():
		return rows
	var by := answer_by()
	var date := m._calendar_date(by)
	rows.append({"note": "To answer, pick one of the replies above. Answer by %s %d, or they will go ahead without one." % [m.MONTH_NAMES[date["month"]], int(date["day"])]})
	var unavailable: Array = []
	for o in options():
		if not bool(o["true"]):
			unavailable.append(str(o["needs"]).to_lower())
			continue
		var row := {"name": str(o["label"]), "about": str(o["text"]) if str(o["text"]) != "" else str(o["about"]),
			"button": "Write it" if str(o["kind"]) == "reply" else ("Write it down" if str(o["kind"]) == "note" else "Wait"),
			"action": "post:answer|" + str(o["id"]), "enabled": true}
		if str(o["kind"]) == "note" and str(o["text"]) == "":
			row["button"] = "Leave it"
			row["about"] = "Nothing is written. The correction goes with the photograph."
		if str(o["kind"]) == "defer":
			if bool(o["deferred"]):
				rows.append({"note": "You decided not to answer yet. Any of these answers can still be written."})
				continue
			row["about"] = str(o["about"])
		if int(o["cost"]) > 0:
			row["needs"] = [{"text": "%d coins in the envelope" % int(o["cost"]), "have": m.money, "ok": bool(o["afford"])}]
			row["enabled"] = bool(o["afford"])
		rows.append(row)
	if not unavailable.is_empty():
		rows.append({"note": "You can only write about what you have really done. Not yet: %s." % ", ".join(unavailable)})
	return rows


func _action(id: String) -> void:
	if id == "take_back":
		take_back()
	elif id.begins_with("answer|"):
		answer(id.trim_prefix("answer|"))


# --- The diary (a Notes page, in your hand, from the record only) --------------------------------------------

func diary_pages() -> Array:
	if not active():
		return []
	var r := rec()
	var s := script()
	var first := _letter("first")
	if first.is_empty() or int(first["read"]) < 0:
		return []
	var paras: Array = [_dated(int(first["day"]), true) + str(s["received"])]
	var stages: Dictionary = s["stages"]
	for st in ["first"] + stages.keys().filter(func(k: String) -> bool: return k != "first"):
		if st != "first":
			var l := _letter(st)
			if l.is_empty() or int(l["read"]) < 0:
				continue
			paras.append(_dated(int(l["day"])) + str(stages[st].get("received", "")))
		for d in r["decisions"]:
			if str(d["stage"]) != st:
				continue
			var c := _choice(st, str(d["id"]))
			if c.is_empty():
				continue
			var facts: Dictionary = r["facts"]
			var line := _fill(str(c.get("diary", "")), facts)
			if str(d["kind"]) == "reply":
				var sent := -1
				for rep in r["replies"]:
					if str(rep["stage"]) == st and str(rep["id"]) == str(d["id"]):
						sent = int(rep["sent"])
				var out: Dictionary = r["outgoing"]
				if sent < 0 and not (not out.is_empty() and str(out["stage"]) == st and str(out["id"]) == str(d["id"])):
					continue
				line += " It went with the morning post." if sent >= 0 else " It is in the mailbox for the morning post."
			paras.append(_dated(int(d["day"])) + line)
		var ack := _letter("ack") if st == str(r["stage"]) else {}
		if not ack.is_empty() and int(ack["read"]) >= 0:
			var last := _choice(st, str(_reply_id(st)))
			if not last.is_empty():
				paras.append(_dated(int(ack["day"])) + _fill(str(last.get("ack_diary", "")), r["facts"]))
	var lapse := _letter("lapse")
	if int(r["lapsed"]) >= 0 and str((s["lapse"] as Dictionary).get("diary", "")) != "":
		if str((s["lapse"] as Dictionary).get("text", "")) == "" or (not lapse.is_empty() and int(lapse["read"]) >= 0):
			paras.append(_dated(int(r["lapsed"])) + str(s["lapse"]["diary"]))
	# One record, over as many pages as it needs: whole paragraphs, PAGE_CHARS of text a page, so a page doesn't
	# scroll at the game's size (tools/diary_fit.gd). Every page shares the id, so they are new together.
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


func _reply_id(stage: String) -> String:
	for rep in rec()["replies"]:
		if str(rep["stage"]) == stage:
			return str(rep["id"])
	return ""


func _letter(id: String) -> Dictionary:
	for l in rec().get("letters", []):
		if str(l["id"]) == id:
			return l
	return {}


# The first paragraph carries the day number, as the diary's other notes do; the rest just the date.
func _dated(day: int, first := false) -> String:
	var date := m._calendar_date(maxi(1, day))
	if first:
		return "Day %d, %s %d. " % [day, str(m.MONTH_NAMES[date["month"]]), int(date["day"])]
	return "%s %d. " % [str(m.MONTH_NAMES[date["month"]]), int(date["day"])]
