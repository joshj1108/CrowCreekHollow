class_name FirstSeptember
extends RefCounted

## CCH-ORIGIN-004: "One Year on the Road", the first September's page in the player's diary (text in
## FirstSeptemberScript). It brings together the life before (OriginState, PastPost, PastSpring) and the year at the
## farm (house, field, people), from what the save proves, and ends with words the player chooses.
##
## From September 24 (day FROM, after the Harvest Moon and the meeting's fallback morning) the page can be read in
## the diary (its own section, "One year") and finished at the desk (the Diary tab), whenever the player likes: it
## never closes, never opens itself and takes no time. A morning note says once that the page is there. Until it is
## written, the page is put together each time it is read, so it is true on the day it is read. Writing it is done
## once: the page is then kept exactly as it was written ("paras", "words"), so a reload or a later change on the
## farm never alters it.
##
## It gives nothing: no coins, sanity, skills or items, and nothing in the story reads it. A legacy save (no origin)
## gets the farm's half only; a past is never made up.
##
## The record (saved under "first_september"; {} until something happens):
##   v           int     record version (V)
##   state       String  "" (not written) or "written"
##   noticed     int     the morning the note said the page was there (-1: not yet)
##   written     int     the day it was written (-1)
##   reflection  String  the closing chosen: finish, keep, unknown, unsettled or stay (FirstSeptemberScript)
##   words       String  the closing words as written on the page
##   paras       Array   the page as written: paragraphs, each an Array of sentences (the opening first)
##   facts       Dict    what the page was made from, for Year Two (ids and small values only; see _facts_for)
##   open        Array   the matters from before still open when it was written (ids; see _open)

const V := 1
const FROM := 359             # September 24 of the first year (Day 1 is October 1)
const DIARY_ID := "first_september"
const SECTION := "One year"
const LINE_CHARS := 31        # about this many characters to a handwritten line on a diary page
const FIRST_LINES := 7        # lines under the first page's large title (tools/first_september_test.gd checks the fit)
const PAGE_LINES := 8         # lines on a continued page

var m: MainGame
var data: Dictionary = {}


func _init(main: MainGame) -> void:
	m = main


func reset() -> void:
	data = {}


func to_save() -> Dictionary:
	return data.duplicate(true)


func from_save(d: Variant) -> void:
	data = sanitize(d)


# A saved record, checked: anything malformed is dropped, so a damaged save never shows a page nobody wrote.
static func sanitize(d: Variant) -> Dictionary:
	if typeof(d) != TYPE_DICTIONARY or (d as Dictionary).is_empty():
		return {}
	var src: Dictionary = d
	var noticed := int(src.get("noticed", -1)) if typeof(src.get("noticed", -1)) in [TYPE_INT, TYPE_FLOAT] else -1
	var out := {"v": V, "state": "", "noticed": noticed, "written": -1}
	if str(src.get("state", "")) != "written":
		return out if noticed >= 0 else {}
	var paras: Variant = src.get("paras", [])
	var words: Variant = src.get("words", "")
	var refl := str(src.get("reflection", ""))
	if typeof(paras) != TYPE_ARRAY or (paras as Array).is_empty() or typeof(words) != TYPE_STRING or str(words) == "" \
			or not refl in FirstSeptemberScript.REFLECTIONS:
		return out if noticed >= 0 else {}
	var kept: Array = []
	for p in paras:
		if typeof(p) != TYPE_ARRAY:
			return out if noticed >= 0 else {}
		var sentences: Array = []
		for s in p:
			if typeof(s) == TYPE_STRING and str(s).strip_edges() != "":
				sentences.append(str(s))
		if not sentences.is_empty():
			kept.append(sentences)
	if kept.is_empty():
		return out if noticed >= 0 else {}
	out["state"] = "written"
	out["written"] = maxi(FROM, int(src.get("written", FROM)))
	out["reflection"] = refl
	out["words"] = str(words)
	out["paras"] = kept
	out["facts"] = _whole((src.get("facts", {}) as Dictionary).duplicate(true)) if typeof(src.get("facts", {})) == TYPE_DICTIONARY else {}
	out["open"] = (src.get("open", []) as Array).duplicate(true) if typeof(src.get("open", [])) == TYPE_ARRAY else []
	return out


# JSON brings every number back as a float: whole numbers go back to ints, so a loaded record equals the written one.
static func _whole(v: Variant) -> Variant:
	match typeof(v):
		TYPE_FLOAT:
			return int(v) if is_equal_approx(float(v), roundf(float(v))) else v
		TYPE_DICTIONARY:
			var d := {}
			for k in v:
				d[k] = _whole(v[k])
			return d
		TYPE_ARRAY:
			return (v as Array).map(func(x: Variant) -> Variant: return _whole(x))
	return v


# --- Read-only queries (for Year Two: CCH-ORIGIN-005) ------------------------------------------------------------

func eligible() -> bool:
	return m.day >= FROM


func written() -> bool:
	return str(data.get("state", "")) == "written"


func reflection() -> String:
	return str(data.get("reflection", "")) if written() else ""


func facts() -> Dictionary:
	return data.get("facts", {}) if written() else {}


func open_matters() -> Array:
	return data.get("open", []) if written() else []


# --- The morning --------------------------------------------------------------------------------------------------

# Once, on the first morning the page can be read: one sentence in the morning report, and the diary's new-page dot.
# Not on the Harvest Moon's morning, which belongs to the town.
func _morning() -> String:
	if not eligible() or written() or int(data.get("noticed", -1)) >= 0 or m.day == StoryAct.HARVEST_MOON:
		return ""
	if data.is_empty():
		data = {"v": V, "state": "", "noticed": -1, "written": -1}
	data["noticed"] = m.day
	m._diary_page(DIARY_ID)
	return FirstSeptemberScript.NOTICE_SOON if m.day <= 365 else FirstSeptemberScript.NOTICE_LATE


# --- What is true ---------------------------------------------------------------------------------------------------

func _house_stage() -> int:
	var repairs: Dictionary = m.woodwork.repairs
	for i in range(3, 0, -1):
		if repairs.has("house_%d" % i) or m.house_stage >= i:
			return i
	return 0


func _gate_words(o: OriginState) -> String:
	var want := o.arrival_intention()
	if want == "":
		return ""
	for step in RoadScript.sequence(o.data.get("choices", {})):
		if str(step.get("key", "")) == "arrival_intention":
			for opt in step.get("options", []):
				if str(opt["id"]) == want:
					return str(opt["text"]).trim_prefix("\"").trim_suffix("\"")
	return ""


# The walker who has been brought the most of what they asked for: [who, first title, second title, how many more].
func _asked() -> Array:
	var by_who := {}
	for r in FolkSystem.REQUESTS:
		var id := str(r["id"])
		if m.folk.requests_done.has(id):
			var who := str(r["who"])
			if not by_who.has(who):
				by_who[who] = []
			(by_who[who] as Array).append([int(m.folk.requests_done[id]), str(r["title"])])
	var best := ""
	for who in by_who:
		if best == "" or (by_who[who] as Array).size() > (by_who[best] as Array).size():
			best = str(who)
	if best == "":
		return []
	var done: Array = by_who[best]
	done.sort_custom(func(a: Array, b: Array) -> bool: return a[0] < b[0])
	var title := func(t: String) -> String: return t.left(1).to_lower() + t.substr(1)
	var short := str(FolkSystem.FOLK[best]["short"])
	return [short.left(1).to_upper() + short.substr(1), title.call(str(done[0][1])),
		title.call(str(done[1][1])) if done.size() > 1 else "", done.size() - 1, best]


# The people-or-place line, by priority: Edith's repair, a walker's errands, the village, the woods, or nowhere.
# Returns [id, line]. `quiet` drops the village and the woods (origin A keeps to the house and its paper).
func _people(quiet := false) -> Array:
	var inn: Dictionary = m.town.inn_record()
	if not inn.is_empty():
		var date := m._calendar_date(maxi(1, int(inn.get("day", 1))))
		return ["inn", FirstSeptemberScript.inn(str(m.MONTH_NAMES[date["month"]]))]
	var a := _asked()
	if not a.is_empty():
		return ["asked:" + str(a[4]), FirstSeptemberScript.asked(str(a[0]), str(a[1]), str(a[2]), int(a[3]))]
	if quiet:
		return ["", ""]
	if m.town.visits > 0:
		return ["cove", FirstSeptemberScript.cove(m.town.visits)]
	var f: Dictionary = m.past_post._facts()
	if f.has("woods_id"):
		return ["woods:" + str(f["woods_id"]), str(FirstSeptemberScript.WOODS.get(str(f["woods_id"]), ""))]
	return ["none", FirstSeptemberScript.STAYED_CLOSE]


# The life before, from the records: [lines, kind]. Only what was received, written, sent or lapsed is told; a
# parcel that hasn't come or hasn't been opened is said to be so, whatever the September line says.
func _past() -> Array:
	var o: OriginState = m.origin
	var ps: PastSpring = m.past_spring
	var pp: PastPost = m.past_post
	var lines: Array = []
	var kind := "none"
	if ps.active():
		var r: Dictionary = ps.rec()
		var sept := ps.september()
		var outc: Dictionary = ps.outcome()
		var parcel_line := ""
		for pid in r.get("parcels", {}):
			var st := ps.parcel_state(str(pid))
			var words: Dictionary = FirstSeptemberScript.PARCELS.get(str(pid), {})
			if st in ["promised", "dispatched"] and words.has("coming"):
				parcel_line = str(words["coming"])
				kind = "parcel:%s:%s" % [pid, st]
			elif st == "received" and words.has("shut"):
				parcel_line = str(words["shut"])
				kind = "parcel:%s:%s" % [pid, st]
		if parcel_line != "":
			lines.append(parcel_line)
		elif sept != "":
			kind = "sept"
			var said := sept
			for key in FirstSeptemberScript.DATED:
				var kv: PackedStringArray = str(key).split("=")
				if str(outc.get(kv[0], "")) != kv[1] or not outc.has("until_day"):
					continue
				var dated: Dictionary = FirstSeptemberScript.DATED[key]
				kind = "dated:" + str(key)
				if m.day > int(outc["until_day"]):
					said = str(dated["after"]) if FirstSeptemberScript.DATED_SEPT.get(key, "") == sept else sept + " " + str(dated["after"])
				elif str(dated["before"]) != "":
					said = sept + " " + str(dated["before"])
			lines.append(said)
		elif o.origin() == "curiosity" and str(ps.script().get("medium", "mail")) == "desk" and not ps.awaiting_player():
			kind = "photo_untouched"
			lines.append("The photograph from the notice is still in the desk. I haven't written anything beside it.")
		var out: Dictionary = ps.outgoing()
		if ps.awaiting_player() and str(ps.script().get("medium", "mail")) == "mail":
			lines.append(FirstSeptemberScript.UNANSWERED)
			kind = kind if kind != "none" else "unanswered"
		elif not out.is_empty():
			lines.append(FirstSeptemberScript.IN_THE_POST if int(out.get("sent", -1)) < 0 else FirstSeptemberScript.AWAITING_REPLY)
			kind = kind if kind != "none" else "in_post"
	elif pp.state() == "delivered" and pp.letter_read("first"):
		lines.append(str(FirstSeptemberScript.WINTER_ONLY.get(o.origin(), "")))
		kind = "winter"
		if pp.awaiting_player():
			lines.append(FirstSeptemberScript.UNANSWERED)
		elif not pp.outgoing().is_empty():
			lines.append(FirstSeptemberScript.AWAITING_REPLY)
	return [lines, kind]


# What from before is still open today (ids, for the record and the "unsettled" wording).
func _open() -> Array:
	var out: Array = []
	if not m.origin.known():
		return out
	var ps: PastSpring = m.past_spring
	var pp: PastPost = m.past_post
	if ps.active():
		var r: Dictionary = ps.rec()
		var matter := str(r.get("matter", ""))
		if not matter in ["", "closed"]:
			out.append("matter:%s:%s" % [m.origin.thread(), matter])
		for pid in r.get("parcels", {}):
			var st := ps.parcel_state(str(pid))
			if st in ["promised", "dispatched", "received"]:
				out.append("parcel:%s:%s" % [pid, st])
		var outc: Dictionary = ps.outcome()
		if outc.has("until_day") and m.day <= int(outc["until_day"]):
			out.append("until:%d" % int(outc["until_day"]))
		if ps.awaiting_player():
			out.append("letter_unanswered")
		elif not ps.outgoing().is_empty():
			out.append("reply_pending")
	elif pp.state() == "delivered" and (pp.awaiting_player() or not pp.outgoing().is_empty()):
		out.append("winter_letter_open")
	return out


# The page as it stands today: paragraphs (Arrays of sentences), with the facts each line came from.
func compose() -> Dictionary:
	var o: OriginState = m.origin
	var day := m.day
	var stage := _house_stage()
	var mended := int(m.stats.get("mended", 0))
	var harvested := int(m.stats.get("harvested", 0))
	var crop_facts: Dictionary = m.past_post._facts()
	var crops := str(crop_facts.get("crops", ""))
	var house := FirstSeptemberScript.house(stage, mended)
	var land := FirstSeptemberScript.land(harvested, crops)
	var paras: Array = []
	var f := {"day": day, "origin": o.origin(), "origin_status": o.status(), "house_stage": stage, "mended": mended,
		"harvested": harvested, "crop": str(crop_facts.get("crop", ""))}
	var opening: Array = [FirstSeptemberScript.opening(day)]
	var known := o.known()
	if known:
		opening.append_array(FirstSeptemberScript.before(o).filter(func(s: String) -> bool: return s != ""))
	paras.append(opening)
	if known:
		var past := _past()
		var lines: Array = (past[0] as Array).filter(func(s: String) -> bool: return s != "")
		f["past"] = str(past[1])
		f["spring_variant"] = str(m.past_spring.rec().get("variant", ""))
		f["spring_state"] = m.past_spring.state()
		f["winter_state"] = m.past_post.state()
		f["spring_outcome"] = (m.past_spring.outcome() as Dictionary).duplicate(true)
		f["parcels"] = {}
		for pid in m.past_spring.rec().get("parcels", {}):
			f["parcels"][str(pid)] = m.past_spring.parcel_state(str(pid))
		f["keepsake"] = o.keepsake()
		f["contact"] = "private" if o.contact() == "private" else ("none" if not o.has_contact() else "named")
		f["contact_intent"] = o.contact_intent()
		f["intention"] = o.arrival_intention()
		if o.origin() == "household" and FirstSeptemberScript.KEEPSAKE.has(o.keepsake()):
			lines.append(str(FirstSeptemberScript.KEEPSAKE[o.keepsake()]))
		if not lines.is_empty():
			paras.append(lines)
	var gate := FirstSeptemberScript.gate(_gate_words(o)) if known and _gate_words(o) != "" else ""
	var b1: Array = []
	var b2: Array = []
	var people: Array
	match o.origin() if known else "":
		"security":
			var owned: bool = m.estate._deed_owned()
			f["deed"] = "owned" if owned else ("part" if m.estate.deed_paid > 0 else "town")
			people = _people(true)
			b1 = [gate, house, FirstSeptemberScript.deed(owned, m.estate.deed_paid, m.estate.DEED_PRICE)]
			b2 = [land, people[1]]
		"work":
			f["hewn"] = int(m.woodwork.hewn)
			people = _people(true)
			b1 = [gate, house, FirstSeptemberScript.planks(int(m.woodwork.hewn))]
			b2 = [people[1] if str(people[0]) == "inn" else "", land]
			if str(people[0]) != "inn":
				people = ["", ""]
		"household":
			people = _people()
			b1 = [gate, people[1]]
			b2 = [house, land]
		"curiosity":
			people = _people()
			b1 = [gate, FirstSeptemberScript.photograph(stage), house]
			b2 = [land, people[1]]
		"chance":
			people = _people()
			b1 = [gate, house, land]
			b2 = [people[1]]
		_:
			people = _people()
			b1 = [house, land]
			b2 = [people[1]]
	f["people"] = str(people[0])
	for b in [b1, b2]:
		var kept: Array = (b as Array).filter(func(s: String) -> bool: return s != "")
		if not kept.is_empty():
			paras.append(kept)
	var open := _open()
	return {"paras": paras, "facts": f, "open": open}


# The closing words on offer, adapted to the page: [{id, line}]. Without a known past, nothing about "before".
func options() -> Array:
	if not eligible() or written():
		return []
	var done := _house_stage() >= 3
	var open_before := not _open().is_empty()
	var out: Array = []
	for id in FirstSeptemberScript.REFLECTIONS:
		if id == "keep" and not m.origin.known():
			continue
		out.append({"id": id, "line": FirstSeptemberScript.reflection(id, done, open_before)})
	return out


# --- Writing it ---------------------------------------------------------------------------------------------------

# The player chooses the last words. Once only; nothing is given, nothing else changes, no time passes.
func write(id: String) -> bool:
	if not eligible() or written():
		return false
	var line := ""
	for o in options():
		if str(o["id"]) == id:
			line = str(o["line"])
	if line == "":
		return false
	var c := compose()
	data = {"v": V, "state": "written", "noticed": int(data.get("noticed", -1)), "written": m.day, "reflection": id,
		"words": line, "paras": c["paras"], "facts": c["facts"], "open": c["open"]}
	m._diary_page(DIARY_ID)
	m._show_message(FirstSeptemberScript.WRITTEN)
	m.play_sfx_at("panel", -8.0)
	return true


func _action(id: String) -> void:
	if id.begins_with("write|"):
		write(id.trim_prefix("write|"))


# --- The diary and the desk ---------------------------------------------------------------------------------------

func _date_line(day: int) -> String:
	var date := m._calendar_date(maxi(1, day))
	return "Day %d, %s %d." % [day, str(m.MONTH_NAMES[date["month"]]), int(date["day"])]


# Pages for the diary's "One year" section: whole sentences, an estimate of wrapped lines a page, a paragraph running on to the next
# page where it must. Before it is written, the last page says where the last lines are written.
func diary_pages() -> Array:
	if not eligible() and not written():
		return []
	var paras: Array
	var day: int
	if written():
		paras = (data["paras"] as Array).duplicate(true)
		paras.append([str(data["words"])])
		day = int(data["written"])
	else:
		paras = compose()["paras"]
		day = m.day
	paras[0] = [_date_line(day)] + paras[0]
	# Whole sentences, a paragraph running on to the next page where it must. A page is filled by an estimate of its
	# wrapped lines: each paragraph takes its lines plus one blank line before it.
	var pages: Array = []
	var page: Array = []      # paragraphs on this page, each an Array of sentences
	var used := 0             # lines used on this page
	for p in paras:
		var cur: Array = []
		for s in p:
			var budget := FIRST_LINES if pages.is_empty() else PAGE_LINES
			var gap := 1 if not page.is_empty() and cur.is_empty() else 0
			var trial: Array = cur + [str(s)]
			var lines := _lines(" ".join(trial)) - (_lines(" ".join(cur)) if not cur.is_empty() else 0)
			if used + gap + lines > budget and (not page.is_empty() or not cur.is_empty()):
				if not cur.is_empty():
					page.append(cur)
				pages.append(page)
				page = []
				cur = []
				used = 0
				gap = 0
				lines = _lines(str(s))
			cur.append(str(s))
			used += gap + lines
		if not cur.is_empty():
			page.append(cur)
	if not page.is_empty():
		pages.append(page)
	var out: Array = []
	for i in pages.size():
		var text := "\n\n".join((pages[i] as Array).map(func(p: Array) -> String: return " ".join(p)))
		out.append({"id": DIARY_ID, "title": FirstSeptemberScript.TITLE + (", continued" if i > 0 else ""), "text": text})
	if not written():
		out.append({"id": DIARY_ID, "title": "The last lines", "text": FirstSeptemberScript.UNFINISHED})
	return out


# Wrapped lines a paragraph takes on a page, by words, LINE_CHARS a line.
static func _lines(text: String) -> int:
	var n := 1
	var w := 0
	for word in text.split(" ", false):
		var len_w := word.length()
		if w > 0 and w + 1 + len_w > LINE_CHARS:
			n += 1
			w = len_w
		else:
			w += (1 if w > 0 else 0) + len_w
	return n


func page_text() -> String:
	var paras: Array = (data["paras"] as Array) if written() else compose()["paras"]
	return "\n\n".join(paras.map(func(p: Array) -> String: return " ".join(p)))


# The desk's Diary tab: the page to read, and the closing words to choose from; or, once written, a line saying so.
func desk_rows() -> Array:
	if not eligible():
		return []
	var t := FirstSeptemberScript.TITLE
	if written():
		var date := m._calendar_date(int(data["written"]))
		return [{"name": t, "status": "Written", "status_kind": "done",
			"value": "Written on %s %d. It is in your diary, under \"%s\"." % [str(m.MONTH_NAMES[date["month"]]), int(date["day"]), SECTION],
			"about": page_text() + "\n\n" + str(data["words"])}]
	var rows: Array = [{"name": t, "status": "To write", "status_kind": "short", "value": page_text()}]
	for o in options():
		rows.append({"name": str(FirstSeptemberScript.SHORT.get(str(o["id"]), o["line"])), "about": "End the page with these words:\n\n\"%s\"\n\nWriting takes no time. The page is finished once, and kept as written." % str(o["line"]),
			"button": "Write it", "action": "september:write|" + str(o["id"]), "enabled": true})
	rows.append({"note": "A year's page in your diary. Read it, then choose its last line. None is the right one."})
	return rows
