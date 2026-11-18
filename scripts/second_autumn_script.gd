class_name SecondAutumnScript
extends RefCounted

## CCH-ORIGIN-005: the words of "The Second Year Remembers", the second calendar autumn's one scene from the life
## before (one per save) and its one practical-life morning. SecondAutumn (scripts/second_autumn.gd) keeps the state,
## decides when things come and builds the context (ctx) from the records; this file is only text and its shape.
##
## pick(ctx) chooses one route, once, from what the winter (PastPost) and the spring (PastSpring) really settled.
## route(id, ctx) gives that route's words. A route is:
##   medium        "mail" (a letter in the mailbox, answered under it or at the desk) or "desk" (no letter: papers or a
##                 keepsake already in the house, at the desk's Diary tab)
##   title, sender the scene's name, and for a letter who it is from (never more than the player told)
##   arrive_note   the morning report's line on the day it comes
##   body          the letter, or the desk scene (second person, from facts only)
##   received      the diary's line once the letter is read (mail only)
##   waiting       the diary's line while nothing has been done (where it is, and that nothing is due unless `by`)
##   open          the scene concerns a matter from before that was open when it came (for the "unsettled" line)
##   by_days       0, or days to answer by (a sender's real terms); lapse {text, diary, pay} what happens then
##   choices       [{id, label, kind, text, about, diary, done, ack, ack_title, ack_note, ack_diary, cost, pay,
##                 parcel, pid, keeps, settles}]
##     kind        "reply" (a letter, left for the morning post; an answer comes ACK_DAYS later if `ack`), "note"
##                 (done at once, nothing is sent) or "open" (opens a spring parcel that came and is still shut)
##     cost / pay  coins enclosed by the player / coins legitimately theirs that come back with the answer (once)
##     parcel      a delivery the answer brings: {title, open_label, open_text, diary_came, diary_opened}
##     keeps       the choice keeps up a connection with the life before; settles: it closes an open matter
## Nothing here gives skills, sanity, items, friendship or story progress. No line names a feeling for the player.

const TITLE := "A Year On"
const WORLD_TITLE := "A year's work"
const NOTICE_DESK := " It's a year this week since you came up the lane. Some papers from before are still in the desk."
const WAITING_DESK := "This is done at the desk in the bedroom, in its Diary tab. Nothing is due. It can wait as long as you like."
const WAITING_MAIL := "The letter is in the mailbox by the east gate. It can be answered there, or at the desk in the bedroom."

const _HOUSE_SENDERS := {"partner": "From the person you shared the house with", "friend": "From your friend at the old house",
	"family": "From your family at the old house"}


static func _c(id: String, label: String, kind: String, text: String, diary: String, keeps: bool, settles: bool,
		extra: Dictionary = {}) -> Dictionary:
	var c := {"id": id, "label": label, "kind": kind, "text": text, "about": "", "diary": diary, "done": "", "ack": "",
		"ack_title": "", "ack_note": "", "ack_diary": "", "cost": 0, "pay": 0, "parcel": {}, "pid": "", "keeps": keeps, "settles": settles}
	c.merge(extra, true)
	return c


# --- The present, said plainly (second person for a scene, first person for the diary) -----------------------

static func house_now(stage: int, mended: int) -> String:
	match stage:
		3:
			return "The house around you is restored: walls, roof and windows."
		2:
			return "The roof has new shingles and the windows have glass. The walls still want work."
		1:
			return "The holes in the walls are patched and the broken windows boarded. The roof still wants shingles."
	if mended > 0:
		return "%s in the house %s mended. The roof still has its hole." % ["One board" if mended == 1 else "%d boards" % mended, "is" if mended == 1 else "are"]
	return "The roof still has its hole, and the wind still comes through the walls."


static func house_short(stage: int, mended: int) -> String:
	match stage:
		3:
			return "the house restored, walls, roof and windows"
		2:
			return "new shingles on the roof and glass in the windows"
		1:
			return "the holes in the walls patched and the broken windows boarded"
	if mended > 0:
		return "%s in the house mended" % ("one board" if mended == 1 else "%d boards" % mended)
	return "the house much as it was, the roof with its hole"


static func field_now(harvested: int, crops: String) -> String:
	if harvested <= 0:
		return "The open ground beside the house is still open ground."
	if harvested == 1:
		return "The open ground beside the house has given one crop."
	return "The open ground beside the house has given %d crops, more %s than anything else." % [harvested, crops]


static func field_short(harvested: int, crops: String) -> String:
	if harvested <= 0:
		return "nothing yet from the open ground"
	if harvested == 1:
		return "one crop from the open ground"
	return "%d crops from the open ground, mostly %s" % [harvested, crops]


# A place beyond the house, as far as it has been walked: the woods, the village, or nowhere far.
static func place_now(ctx: Dictionary) -> String:
	match str(ctx["woods_id"]):
		"nearwood":
			return "Behind the house the trees go further than the picture showed. You go up the trail there for timber."
		"trek":
			return "Behind the field the woods go on further than the picture showed. You've walked some way into them."
		"edge":
			return "Behind the field the woods begin. You've walked out to where they start."
	if int(ctx["visits"]) > 0:
		return "Half an hour down the hill road is Wicker Cove, which the picture didn't show. You've been down %s." % _times(int(ctx["visits"]))
	return "You haven't been far from the house. The road down the hill is still there."


static func place_short(ctx: Dictionary) -> String:
	match str(ctx["woods_id"]):
		"nearwood":
			return "a trail behind the house that goes up into the woods"
		"trek":
			return "woods behind the field that go on further than I can see"
		"edge":
			return "woods that begin behind the field"
	if int(ctx["visits"]) > 0:
		return "a village down the hill road, Wicker Cove"
	return ""


static func _times(n: int) -> String:
	return "once" if n == 1 else ("twice" if n == 2 else "%d times" % n)


# --- Which route ------------------------------------------------------------------------------------------------

static func pick(ctx: Dictionary) -> String:
	var w: Dictionary = ctx["w"]
	var s: Dictionary = ctx["s"]
	var spring := str(ctx["s_state"]) == "delivered"
	var parcels: Dictionary = ctx["parcels"]
	match str(ctx["origin"]):
		"security":
			if spring:
				if str(s.get("deposit", "")) == "held_on_account":
					return "a_deposit"
				if str(s.get("keeper", "")) == "send_on":
					return "a_send_on"
				if str(s.get("papers", "")) == "kept_by_them":
					return "a_papers"
			return "a_desk"
		"work":
			if spring:
				match str(s.get("work", "")):
					"paid":
						return "b_paid"
					"method":
						return "b_method"
					"declined", "returned":
						return "b_closed"
			return "b_desk"
		"household":
			if spring:
				match str(s.get("belongings", "")):
					"held":
						return "c_held"
					"kept_by_them":
						return "c_letter"
					"kept_unanswered":
						return "c_unanswered"
			return "c_keepsake"
		"curiosity":
			return "d_photo"
		"chance":
			if spring:
				if str(s.get("order", "")) == "for_collection" and str(parcels.get("order", "")) == "":
					return "e_collect"
				if str(s.get("meeting", "")) == "autumn":
					return "e_meeting"
			return "e_desk"
	return ""


static func route(id: String, ctx: Dictionary) -> Dictionary:
	var r: Dictionary = {}
	match id:
		"a_deposit": r = _a_deposit(ctx)
		"a_send_on": r = _a_send_on(ctx)
		"a_papers": r = _a_papers(ctx)
		"a_desk": r = _a_desk(ctx)
		"b_paid": r = _b_paid(ctx)
		"b_method": r = _b_method(ctx)
		"b_closed": r = _b_closed(ctx)
		"b_desk": r = _b_desk(ctx)
		"c_held": r = _c_held(ctx)
		"c_letter": r = _c_letter(ctx)
		"c_unanswered": r = _c_unanswered(ctx)
		"c_keepsake": r = _c_keepsake(ctx)
		"d_photo": r = _d_photo(ctx)
		"e_collect": r = _e_collect(ctx)
		"e_meeting": r = _e_meeting(ctx)
		"e_desk": r = _e_desk(ctx)
	if r.is_empty():
		return r
	for key in ["sender", "received", "lapse"]:
		if not r.has(key):
			r[key] = "" if key != "lapse" else {}
	if not r.has("by_days"):
		r["by_days"] = 0
	if not r.has("open"):
		r["open"] = false
	if not r.has("waiting"):
		r["waiting"] = WAITING_MAIL if str(r["medium"]) == "mail" else WAITING_DESK
	if not r.has("arrive_note"):
		r["arrive_note"] = " A personal letter has come in the mailbox." if str(r["medium"]) == "mail" else NOTICE_DESK
	return r


# A spring parcel that came and is still shut can be opened from the scene (through PastSpring, as at the mailbox).
static func _open_choice(ctx: Dictionary, pid: String, label: String, diary: String) -> Array:
	if str((ctx["parcels"] as Dictionary).get(pid, "")) != "received":
		return []
	return [_c("open_" + pid, label, "open", "", diary, true, false, {"pid": pid,
		"about": "Open it now. It takes no time."})]


# --- A: The Cost of a Room ----------------------------------------------------------------------------------

static func _keeper(ctx: Dictionary) -> String:
	return str({"friend": "From your friend, who kept the boxes", "family": "From your family, who kept the boxes"}.get(
		str(ctx["contact"]), "From the person who kept your boxes"))


static func _a_deposit(ctx: Dictionary) -> Dictionary:
	var office := str(ctx["exit"]) == "extension"
	return {"medium": "mail", "title": "The balance on your old account", "open": true,
		"sender": "From the letting office" if office else "From the landlord of your old room",
		"arrive_note": " A letter about your old room has come in the mailbox.",
		"body": "This is the yearly statement we send on any balance left with us. 24 coins of your deposit are still on the account in your name, from the statement sent to you in the spring.\n\nIf you would like them, sign the slip below and send it back, and the money will be sent. Or write and tell us to close the account and keep the balance. If we hear nothing, the money stays where it is. Nothing is owed by you.",
		"received": "The yearly statement for my old room came. The 24 coins of the deposit are still on the account.",
		"choices": [
			_c("sign", "Sign the slip and send it back", "reply", "Slip signed and returned.",
				"I signed the slip for the old deposit and sent it back.", false, true,
				{"ack": "Thank you. The balance of 24 coins is enclosed. The account is closed.", "pay": 24,
				"ack_title": "Your old account, closed", "ack_diary": "They wrote back with the 24 coins. The account is closed."}),
			_c("close", "Tell them to close it and keep the balance", "reply", "Please close the account and keep the balance. I won't be writing for it.",
				"I wrote that they could close the account and keep the 24 coins.", false, true,
				{"ack": "As you ask, the account is closed and the balance kept. Nothing more will be sent.",
				"ack_title": "Your old account, closed", "ack_diary": "They wrote back. The account is closed, and they kept the balance."}),
			_c("file", "File it with the farm's papers, unsigned", "note", "",
				"I put the yearly statement in with the farm's papers, unsigned. The 24 coins stay on the account.", true, false,
				{"done": "You put the statement in with the farm's papers.",
				"about": "Nothing is sent. The money stays on their account, in your name. They don't need an answer."}),
		]}


static func _a_send_on(ctx: Dictionary) -> Dictionary:
	var caught := "Apart from the seed catalogue, nothing came." if (ctx["follows_done"] as Array).has("send_on") else "Nothing came."
	return {"medium": "mail", "title": "The old door", "sender": _keeper(ctx),
		"body": "I stopped asking at your old door at the end of August, as I said I would. %s\n\nThe new tenant seems decent. If you like, I can give them the farm's address, and they can send anything straight up to you. Or we can leave it, and anything that comes goes back where it came from. A line either way will do." % caught,
		"received": "The person who kept my boxes wrote. They stopped asking at the old door at the end of August.",
		"choices": [
			_c("tenant", "Ask them to give the tenant the farm's address", "reply",
				"Please give the new tenant the farm's address. Thank you for asking at the door all summer.",
				"I asked them to give the new tenant at the old room the farm's address.", true, true,
				{"ack": "Done. I gave them the address on a card, and they've put it by the door. That's the last I'll need to do.",
				"ack_title": "The address, by the door", "ack_diary": "They wrote back. The new tenant has the farm's address."}),
			_c("leave", "Say there's no need", "reply",
				"There's no need. Anything that comes can go back. Thank you for asking at the door all summer.",
				"I wrote that there was no need: anything that comes to the old room can go back.", false, true,
				{"ack": "All right. I'll leave it, then. Look after yourself up there.",
				"ack_title": "The old door", "ack_diary": "They wrote back. They'll leave it."}),
			_c("keep", "Keep the letter without answering", "note", "",
				"I kept their letter and didn't answer it.", true, false,
				{"done": "You fold the letter and keep it.", "about": "Nothing is sent. Nothing comes on from the old door unless you write."}),
		]}


static func _a_papers(ctx: Dictionary) -> Dictionary:
	return {"medium": "mail", "title": "Your papers, still in the drawer", "sender": _keeper(ctx), "open": true,
		"body": "Your papers are still in my drawer: the rent book and the letters. I'm turning out the drawers before the winter, and I'd rather not keep someone else's papers another year.\n\nI can post them, or put them in the stove. Or, if you'd rather, I'll keep them a while yet. Tell me which. I won't do anything until you do.",
		"received": "The person who kept my boxes wrote. My papers are still in their drawer.",
		"choices": [
			_c("post", "Ask them to post the papers", "reply", "Please post them. Thank you for keeping them this long.",
				"I asked them to post my papers.", true, true,
				{"ack": "Here they are: the rent book, and the letters, tied the way you left them. That's the drawer clear.",
				"ack_title": "Your papers", "ack_note": " A packet of papers has come with a letter.",
				"ack_diary": "Their letter came with my papers: the old rent book and my letters, tied with string."}),
			_c("burn", "Tell them to put them in the stove", "reply", "You can put them in the stove. Thank you for keeping them this long.",
				"I told them to put my papers in the stove.", false, true,
				{"ack": "Done. That's the last of it, really this time.", "ack_title": "Your papers",
				"ack_diary": "They wrote back. The papers are burned."}),
			_c("keep", "Ask them to keep them a while yet", "reply", "Could you keep them a while longer? I'll write when I know.",
				"I asked them to keep my papers a while longer.", true, false,
				{"ack": "All right. They'll stay in the drawer.", "ack_title": "Your papers",
				"ack_diary": "They wrote back. The papers stay in their drawer."}),
		]}


# The papers from the old room in the desk: what became of the room's things, the house, and the deed, as they stand.
static func _a_desk(ctx: Dictionary) -> Dictionary:
	var s: Dictionary = ctx["s"]
	var w: Dictionary = ctx["w"]
	var parcels: Dictionary = ctx["parcels"]
	var old := ""
	if str(s.get("deposit", "")) == "returned":
		old = "The old account is closed. The deposit came back in the spring, less half the cost of the window catch." if bool(s.get("queried", false)) \
			else "The old account is closed. The deposit came back in the spring, less the window catch."
	elif str(parcels.get("boxes", "")) == "inspected":
		old = "The two boxes came up in March: the winter coat, the plates, a few books and the kettle."
	elif str(parcels.get("boxes", "")) == "received":
		old = "The two boxes that came up in March are still shut."
	elif str(parcels.get("papers", "")) == "inspected":
		old = "The boxes went to the charity shop. The rent book came back by post, with the letters you kept."
	elif str(parcels.get("papers", "")) == "received":
		old = "The boxes went to the charity shop. The packet with the rent book came back by post, still shut."
	elif str(s.get("papers", "")) == "burned" or str(s.get("boxes", "")) in ["released", "given_away_unanswered"] or str(w.get("boxes", "")) == "released":
		old = "The boxes went to the charity shop. Nothing else from the old room came up the lane."
	elif str(w.get("forwarding", "")) == "renewed":
		old = "Post from the old room came on to the farm until the end of August."
	elif str(w.get("forwarding", "")) in ["ended", "lapsed"]:
		old = "The forwarding of post from the old room ended in February."
	var deed := "The deed in the same drawer is paid."
	if str(ctx["deed"]) == "part":
		deed = "The deed is still the town's. You've paid %d of its %d coins." % [int(ctx["deed_paid"]), int(ctx["deed_price"])]
	elif str(ctx["deed"]) == "town":
		deed = "The deed is still the town's."
	var body := "The envelope from the old room is in the desk, with the two notices in it: the rent notice and the farm's. One was no longer useful when you left. You kept it anyway."
	if old != "":
		body += "\n\n" + old
	body += "\n\n%s %s" % [house_now(int(ctx["stage"]), int(ctx["mended"])), deed]
	var choices: Array = _open_choice(ctx, "boxes", "Open the two boxes", "A year on, I opened the two boxes from the old room.") \
		+ _open_choice(ctx, "papers", "Open the packet of papers", "A year on, I opened the packet with my old papers.")
	choices.append_array([
		_c("file", "File the old room's papers with the farm's", "note", "",
			"I put the papers from the old room in with the farm's papers, under the deed.", true, false,
			{"done": "You put the old room's papers in with the farm's.", "about": "Both notices go in the drawer with the deed."}),
		_c("discard", "Put the old rent notice on the fire", "note", "",
			"I put the old rent notice on the fire. I kept the farm's.", false, false,
			{"done": "You put the old rent notice on the fire.", "about": "The farm's notice stays. The rent notice goes."}),
		_c("leave", "Leave the envelope as it is", "note", "",
			"I looked through the envelope from the old room and left it as it was.", true, false,
			{"done": "You put the envelope back in the desk.", "about": "Nothing changes."}),
	])
	return {"medium": "desk", "title": "The two notices", "body": body, "choices": choices}


# --- B: Work That Belonged to Everyone ----------------------------------------------------------------------

const _OLD_JOB := "From someone at the old job"


static func _b_paid(ctx: Dictionary) -> Dictionary:
	var boundary := str(ctx["work_exit"]) == "boundary" or str(ctx["contact_intent"]) == "boundaries"
	var body := "The year's accounts are done. Your March check is in the file with your pencil marks, and the two days you marked were right. The office asked me to send you the slip below for your records: 20 coins paid in May, for three hours."
	var choices: Array
	if boundary:
		body += "\n\nThat's all. I know you'd rather not be asked for more, so I'm not asking."
		choices = [
			_c("thank", "Thank them for the slip", "reply", "Thank you for the slip, and for not asking.",
				"I wrote to thank them for the slip.", true, true,
				{"ack": "You're welcome. Good luck with the farm.", "ack_title": "The slip", "ack_diary": "They wrote back: good luck with the farm."}),
			_c("file", "File the slip; don't answer", "note", "", "I filed the slip with the farm's papers and didn't answer.", false, true,
				{"done": "You file the slip with the farm's papers.", "about": "Nothing is sent. There is nothing to answer."}),
		]
	else:
		body += "\n\nThe manager asked whether we could write to you again if something like it comes up. I said I'd ask, and that you might say no."
		choices = [
			_c("ask_first", "Say they can ask, case by case", "reply", "You can write if something comes up. I'll say yes or no each time.",
				"I wrote that they can ask if something comes up, and I'll say yes or no each time.", true, true,
				{"ack": "Understood. Each time, then, and no is a fine answer.", "ack_title": "Case by case",
				"ack_diary": "They wrote back. They'll ask each time, and no is an answer."}),
			_c("last", "Say the March sheets were the last", "reply", "The March sheets were the last I'll do from here. Thank you for the slip.",
				"I wrote that the March sheets were the last work I'd do for them.", false, true,
				{"ack": "Understood. I'll tell the manager. Good luck up there.", "ack_title": "The last of it",
				"ack_diary": "They wrote back. They'll tell the manager."}),
			_c("file", "File the slip; don't answer", "note", "", "I filed the slip with the farm's papers and didn't answer.", false, false,
				{"done": "You file the slip with the farm's papers.", "about": "Nothing is sent. Nobody writes about more work unless you answer."}),
		]
	return {"medium": "mail", "title": "The year's accounts", "sender": _OLD_JOB, "body": body, "open": not boundary,
		"received": "Someone from the old job wrote. They sent the slip for the March sheets, for my records.", "choices": choices}


static func _b_method(ctx: Dictionary) -> Dictionary:
	var again := "again " if (ctx["follows_done"] as Array).has("method") else ""
	return {"medium": "mail", "title": "Your way, still", "sender": _OLD_JOB,
		"body": "We used your way %son the September sheets. The person who started in the summer learned it from your letter; it's pinned up by the slip trays now.\n\nI don't need anything. I thought you'd want to know it's still in use." % again,
		"received": "Someone from the old job wrote. They still check the sheets my way.",
		"choices": [
			_c("theirs", "Say it's theirs now", "reply", "It's yours now. Change it however suits you.",
				"I wrote that the method is theirs now, to change however suits them.", false, true,
				{"ack": "We will. Thank you for it.", "ack_title": "Yours now", "ack_diary": "They wrote back: thank you for it."}),
			_c("write_if", "Say they can write if it stops working", "reply", "If it stops working, write and I'll look.",
				"I wrote that they can write if the method stops working.", true, false,
				{"ack": "I will, if it does. I hope it won't come to that.", "ack_title": "If it stops working",
				"ack_diary": "They wrote back. They'll write if it stops working."}),
			_c("keep", "Keep the letter", "note", "", "I kept their letter about the method.", true, false,
				{"done": "You keep the letter.", "about": "Nothing is sent. They didn't ask for anything."}),
		]}


static func _b_closed(ctx: Dictionary) -> Dictionary:
	var sheet := " Your instruction sheet is still in the drawer there. We still go by it." if str(ctx["work_exit"]) == "instructions" else ""
	return {"medium": "mail", "title": "Your old desk", "sender": _OLD_JOB,
		"body": "The person they took on for the summer has stayed. They have your old desk now.%s\n\nI only wanted to say the order book is in good hands, so you needn't think about it. No need to answer." % sheet,
		"received": "Someone from the old job wrote. The person taken on for the summer has stayed, at my old desk.",
		"choices": [
			_c("wish", "Write back with good wishes", "reply", "Thank you for letting me know. I hope the new person settles in.",
				"I wrote back with good wishes for the new person.", true, false,
				{"ack": "They have. Good luck with the farm.", "ack_title": "Settled in", "ack_diary": "They wrote back: the new person has settled in."}),
			_c("keep", "Keep the note", "note", "", "I kept their note.", true, false,
				{"done": "You keep the note.", "about": "Nothing is sent."}),
			_c("discard", "Don't keep it", "note", "", "I read their note and didn't keep it.", false, false,
				{"done": "You put the note on the fire.", "about": "Nothing is sent. The note goes on the fire."}),
		]}


static func _b_desk(ctx: Dictionary) -> Dictionary:
	var left: String = {"finish": "You finished the order you had promised and signed the last page.",
		"instructions": "You gave your notice and left the next steps on a clean sheet by the work list.",
		"boundary": "You told them you couldn't keep doing it, and left them to choose who would take over."}.get(str(ctx["work_exit"]), "")
	var since := ""
	match str(ctx["s"].get("work", "")):
		"unanswered":
			since = "They wrote again in the spring, about the March sheets. You didn't answer, and someone else did them."
		"lapsed":
			since = "In the spring you said you'd check the March sheets, and didn't get to them. They managed."
	if since == "" and str(ctx["w_state"]) == "delivered":
		since = "Their letter about the order book is still in the desk."
	var body := "The last letter from the old job is in the desk. %s" % left
	if since != "" and not body.ends_with(since):
		body += "\n\n" + since
	var hewn := int(ctx["hewn"])
	var here := house_now(int(ctx["stage"]), int(ctx["mended"]))
	if hewn > 0:
		here = "You've hewn %s at the workbench here. %s" % ["one plank" if hewn == 1 else "%d planks" % hewn, here]
	body += "\n\n" + here
	var choices: Array = []
	if str(ctx["w_state"]) == "delivered":
		choices.append(_c("close", "Write a short line to close it", "reply", "I won't be taking on work from here. Thank you for asking, all the same.",
			"I wrote to the old job that I won't be taking on work from the farm.", false, true,
			{"ack": "Understood. All the best up there.", "ack_title": "All the best", "ack_diary": "They wrote back: all the best."}))
	choices.append_array([
		_c("file", "File their letters with the farm's papers", "note", "", "I filed the letters from the old job with the farm's papers.", true, false,
			{"done": "You file the letters with the farm's papers.", "about": "Nothing is sent."}),
		_c("leave", "Leave them where they are", "note", "", "I read the old job's letters again and left them where they were.", true, false,
			{"done": "You leave the letters where they are.", "about": "Nothing changes."}),
	])
	return {"medium": "desk", "title": "The old job's letters", "body": body, "choices": choices}


# --- C: A House With One Less Person ------------------------------------------------------------------------

static func _house_sender(ctx: Dictionary) -> String:
	return str(_HOUSE_SENDERS.get(str(ctx["relation"]), "From someone at the house you left"))


static func _line(ctx: Dictionary) -> String:
	return " A line will do." if str(ctx["contact"]) == "former_household" and str(ctx["contact_intent"]) == "boundaries" else ""


const _HOUSE_BOXES := {"title": "Two boxes from the old house", "open_label": "Open the boxes",
	"open_text": "Your boots, a box of papers, and the books that were yours. Nothing else.",
	"diary_came": "The carrier brought my two boxes from the old house.",
	"diary_opened": "I opened the boxes from the old house: my boots, my papers and my books."}


static func _send_boxes(text: String, diary: String) -> Dictionary:
	return _c("send", "Ask for your two boxes (20 coins)", "reply", text, diary, true, true,
		{"cost": 20, "parcel": _HOUSE_BOXES, "ack_title": "Your boxes", "ack_note": " The carrier brought two boxes up the lane, with a letter.",
		"ack": "The carrier took your boxes on Monday. That's the cupboard clear. I'll keep the clock and the shelf books, as before.",
		"ack_diary": "Their letter came with the carrier, and my two boxes from the old house."})


static func _give_boxes(text: String, diary: String) -> Dictionary:
	return _c("give", "Say they can give the boxes away", "reply", text, diary, false, true,
		{"ack": "I took them to the charity shop on Saturday. That's everything, I think.", "ack_title": "Your boxes",
		"ack_diary": "They wrote back. My boxes went to the charity shop."})


static func _c_held(ctx: Dictionary) -> Dictionary:
	return {"medium": "mail", "title": "The things, after September", "sender": _house_sender(ctx), "open": true, "by_days": 21,
		"body": "It's October. You asked me to keep everything until the end of September, and I have. I need the hall cupboard now.\n\nI can send your two boxes, your boots and papers and the books that were yours. The carrier is 20 coins. Or I can take them to the charity shop. The clock and the shelf books I'll keep, if that's all right.\n\nLet me know by {by}. If I don't hear by then, they'll go to the charity shop.%s" % _line(ctx),
		"received": "A letter came from the house I left. They kept everything until the end of September, as agreed, and need the cupboard now.",
		"late": "After that, they'll take the boxes to the charity shop, as they said.",
		"lapse": {"text": "I didn't hear, so I've taken your boxes to the charity shop, as I said. I've kept the clock. That's everything.",
			"diary": "I didn't answer by {by}. They took my boxes to the charity shop, as they said they would."},
		"choices": [
			_send_boxes("Please send my boxes. 20 coins for the carrier are in with this. Keep the clock and the shelf books.",
				"I asked them to send my two boxes, with 20 coins for the carrier."),
			_give_boxes("Please take them to the charity shop, and keep the clock and the shelf books. Thank you for keeping it all this long.",
				"I wrote that they could take my boxes to the charity shop, and keep the clock and the shelf books."),
		]}


static func _c_letter(ctx: Dictionary) -> Dictionary:
	var farm := "%s, and %s" % [house_short(int(ctx["stage"]), int(ctx["mended"])), field_short(int(ctx["harvested"]), str(ctx["crops"]))]
	return {"medium": "mail", "title": "A year, near enough", "sender": _house_sender(ctx), "open": true,
		"body": "Nothing much to tell. It's a year since you went, near enough. The plum tree came good again, and I've been giving the plums away. Your boxes are still in the hall cupboard. I don't mind them there.\n\nWrite when you like.",
		"received": "A letter came from the old house, about ordinary things. My boxes are still in their hall cupboard.",
		"choices": [
			_c("farm", "Write back about the farm", "reply", "It's a year here too. At the farm: %s." % farm,
				"I wrote back about the farm: %s." % farm, true, false,
				{"ack": "Thank you for the news of the farm. Write again when you like.", "ack_title": "The farm",
				"ack_diary": "They wrote back. Write again when I like."}),
			_send_boxes("It's a year here too. Could you send my boxes now? 20 coins for the carrier are in with this.",
				"I wrote asking them to send my two boxes now, with 20 coins for the carrier."),
			_c("pause", "Say you'll stop writing for a while", "reply", "I'll stop writing for a while. Keep the boxes or give them away, whichever suits you.",
				"I wrote that I'll stop writing for a while, and that they can keep my boxes or give them away.", false, false,
				{"ack": "All right. They'll stay in the cupboard unless I need the room.", "ack_title": "For a while",
				"ack_diary": "They wrote back. My boxes stay in their cupboard unless they need the room."}),
		]}


static func _c_unanswered(ctx: Dictionary) -> Dictionary:
	var body := "The letter from the old house is in the desk. In the spring they wrote that they'd keep your boxes in the hall cupboard, and the clock. You haven't written since."
	var k := str(FirstSeptemberScript.KEEPSAKE.get(str(ctx["keepsake"]), ""))
	if k != "":
		body += "\n\n" + _keepsake_now(str(ctx["keepsake"]))
	return {"medium": "desk", "title": "The letter from the old house", "body": body, "open": true,
		"choices": [
			_send_boxes("It's a year now. Could you send my boxes? 20 coins for the carrier are in with this. Keep the clock.",
				"I wrote asking for my two boxes, with 20 coins for the carrier."),
			_give_boxes("It's a year now. You can give my boxes away, and keep the clock. Thank you for keeping them.",
				"I wrote that they can give my boxes away and keep the clock."),
			_c("leave", "Leave it as it is", "note", "", "I read their letter again and left it as it was.", true, false,
				{"done": "You put the letter back in the desk.", "about": "Nothing is sent. Your boxes stay in their cupboard."}),
		]}


static func _keepsake_now(k: String) -> String:
	return str({"photo": "The photograph you brought is in your case, its corner folded twice.",
		"tool": "The old work tool you brought is in your case. The handle is smooth near the thumb.",
		"postcard": "The postcard you brought is in your case. One line on it is still unfinished.",
		"notebook": "The small notebook you brought is in your case: names, measurements, a few things worth remembering.",
	}.get(k, ""))


# Contact closed, or the things settled: no letter. What the spring settled, and the keepsake from the case.
static func _c_keepsake(ctx: Dictionary) -> Dictionary:
	var s: Dictionary = ctx["s"]
	var parcels: Dictionary = ctx["parcels"]
	var settled := ""
	match str(s.get("belongings", "")):
		"given_up":
			settled = "In the spring you settled who would keep what. The clock and the shelf books are theirs, and your boxes went to the charity shop. That was the last thing between you."
		"sent":
			match str(parcels.get("house_boxes", "")):
				"inspected":
					settled = "In the spring you settled who would keep what. Your boots, papers and books came up from the old house."
				"received":
					settled = "In the spring you settled who would keep what. The two boxes from the old house came, and are still shut."
				_:
					settled = "In the spring you settled who would keep what. They kept the clock and the shelf books."
	if str(parcels.get("key", "")) == "inspected":
		settled += (" " if settled != "" else "") + "The brass key they sent is still wrapped in its cloth. It doesn't open anything here."
	elif str(parcels.get("key", "")) == "received":
		settled += (" " if settled != "" else "") + "The small parcel with the key is still wrapped."
	var k := str(ctx["keepsake"])
	var body := settled
	var keep := _keepsake_now(k)
	body += ("\n\n" if body != "" else "") + (keep if keep != "" else "You didn't bring anything from the old house to keep. The list of things to move was short.")
	body += "\n\n" + house_now(int(ctx["stage"]), int(ctx["mended"]))
	var choices: Array = _open_choice(ctx, "house_boxes", "Open the boxes from the old house", "A year on, I opened the boxes from the old house.") \
		+ _open_choice(ctx, "key", "Unwrap the key", "A year on, I unwrapped the key from the old house.")
	match k:
		"photo":
			choices.append_array([
				_c("out", "Put the photograph out", "note", "", "I took the photograph out of my case and stood it on the shelf.", true, false,
					{"done": "You stand the photograph on the shelf.", "about": "It goes on the shelf, where it can be seen."}),
				_c("case", "Put it back in the case", "note", "", "I looked at the photograph and put it back in my case.", true, false,
					{"done": "You put the photograph back in the case.", "about": "It goes back where it was."})])
		"tool":
			choices.append_array([
				_c("out", "Hang the tool by the door", "note", "", "I hung the old work tool on a nail by the door.", true, false,
					{"done": "You hang the tool on a nail by the door.", "about": "It goes on a nail by the door."}),
				_c("case", "Put it back in the case", "note", "", "I looked at the old tool and put it back in my case.", true, false,
					{"done": "You put the tool back in the case.", "about": "It goes back where it was."})])
		"postcard":
			choices.append_array([
				_c("finish", "Finish the unfinished line", "note", "", "I finished the line on the postcard, in pencil. I didn't send it.", true, false,
					{"done": "You finish the line in pencil. You don't send it.", "about": "Nothing is sent. The line is finished on the card."}),
				_c("case", "Leave the line unfinished", "note", "", "I read the postcard again and left the line unfinished.", true, false,
					{"done": "You put the postcard back in the case.", "about": "The line stays as it is."})])
		"notebook":
			choices.append_array([
				_c("add", "Add a line to the notebook", "note", "", "I added a line to the notebook: %s." % house_short(int(ctx["stage"]), int(ctx["mended"])), true, false,
					{"done": "You add a line to the notebook.", "about": "One line, about the house as it is."}),
				_c("case", "Put it back in the case", "note", "", "I looked through the notebook and put it back in my case.", true, false,
					{"done": "You put the notebook back in the case.", "about": "It goes back where it was."})])
		_:
			choices.append(_c("write", "Write a line about the house as it is", "note", "",
				"I wrote a line in the diary about the house a year on: %s." % house_short(int(ctx["stage"]), int(ctx["mended"])), false, false,
				{"done": "You write a line in the diary.", "about": "One line, about the house as it is."}))
	choices.append(_c("leave", "Leave it all where it is", "note", "", "I looked at what I brought from the old house and left it where it was.", true, false,
		{"done": "You leave it where it is.", "about": "Nothing changes."}))
	return {"medium": "desk", "title": "From the old house", "body": body, "choices": choices}


# --- D: The Place in the Photograph -------------------------------------------------------------------------

# What the person who saw them off was really told in the spring (PastSpring's kept facts), for their answer.
static func _told_before(ctx: Dictionary) -> String:
	var f: Dictionary = ctx["s_facts"]
	match str((ctx["s"] as Dictionary).get("told", "")):
		"crops":
			return "In the spring you wrote to me about the %s. Now I know about the rest." % str(f.get("crops", "crops"))
		"repair":
			return "In the spring you wrote that %s. It sounds as if the work has gone on." % str(f.get("repair_short", "there was work on the house"))
		"place":
			return "In the spring you wrote about %s. The picture has more in it now." % str(f.get("place_short", "a place there"))
		"not_yet":
			return "In the spring you said you'd rather not describe it yet. Thank you for describing it now."
		"not_expected":
			return "In the spring you wrote that it wasn't what you expected. I think I see a little more of it now."
		"unanswered_spring":
			return "I'd stopped expecting a letter. Thank you for this one."
	return "It's good to hear from you."


static func _d_photo(ctx: Dictionary) -> Dictionary:
	var s: Dictionary = ctx["s"]
	var beside := ""
	match str(s.get("photo", "")):
		"compared":
			beside = "Your note from the spring is beside it: what had changed since you came."
		"left_out":
			beside = "Your note from the spring is beside it: the sound of the wind at the back fence."
		"annotated_twice":
			beside = "Your two notes are beside it, from the spring and the summer."
		"left_in_summer", "kept":
			beside = "In the spring you folded it back without writing anything beside it."
		"untouched":
			beside = "You haven't written anything beside it."
	match str(s.get("told", "")):
		"crops", "repair", "place":
			beside = "In the spring you wrote to %s about it." % str(ctx["who"])
		"not_yet", "not_expected":
			beside = "In the spring you wrote to %s, but not what it's like." % str(ctx["who"])
		"unanswered_spring":
			beside = "%s wrote twice to ask what it's like. You didn't answer the spring letter." % (str(ctx["who"]).left(1).to_upper() + str(ctx["who"]).substr(1))
	var now: Array = [house_now(int(ctx["stage"]), int(ctx["mended"])), field_now(int(ctx["harvested"]), str(ctx["crops"])), place_now(ctx)]
	if str(ctx["inn_month"]) != "":
		now.append("In %s you mended the leak at the inn in Wicker Cove." % str(ctx["inn_month"]))
	var body := "The photograph from the notice is in the desk, folded along the roofline. %s\n\nIn the picture: half the house behind trees, a fence nobody had mended, a patch of open ground.\n\nA year on:\n%s" % [beside, " ".join(now)]
	var parts: Array = [house_short(int(ctx["stage"]), int(ctx["mended"])), field_short(int(ctx["harvested"]), str(ctx["crops"]))]
	if place_short(ctx) != "":
		parts.append(place_short(ctx))
	var note := "; ".join(parts)
	var choices: Array = [
		_c("note", "Add a note beside the photograph", "note", "",
			"Beside the photograph I added a note, a year on: %s." % note, true, false,
			{"done": "You write the note beside the photograph.", "about": "Beside the photograph you write:\n\nA year on: %s." % note}),
		_c("file", "File it with the farm notice", "note", "", "I put the photograph back with the farm notice it came in.", true, false,
			{"done": "You put the photograph back with the notice.", "about": "The photograph goes back with the notice it came in."}),
		_c("leave", "Leave it as it was", "note", "", "I looked at the photograph again and left it as it was.", true, false,
			{"done": "You put the photograph back in the desk.", "about": "Nothing is written."}),
	]
	if str(ctx["contact_form"]) != "none":
		choices.insert(1, _c("write", "Copy the note into a letter to %s" % str(ctx["who"]), "reply",
			"A year on, here is what the picture left out: %s." % note,
			"I copied my note into a letter to %s: %s." % [str(ctx["who"]), note], true, false,
			{"ack": _told_before(ctx),
			"ack_title": "The picture, a year on", "ack_diary": "They wrote back about my letter."}))
	return {"medium": "desk", "title": "The photograph, a year on", "body": body, "choices": choices}


# --- E: A Chance Before It Closed ---------------------------------------------------------------------------

const _ORDER := {"title": "Your order", "open_label": "Unwrap the order",
	"open_text": "It's the thing you ordered before you left, wrapped in the shop's paper.",
	"diary_came": "The carrier brought my order from the shop.", "diary_opened": "I unwrapped the order."}


static func _e_collect(ctx: Dictionary) -> Dictionary:
	return {"medium": "mail", "title": "Your order, after September", "sender": "From the shop where you left an order", "open": true, "by_days": 21,
		"arrive_note": " A letter from the shop has come in the mailbox.",
		"body": "The end of September has passed, and your order is still in the back with your name on it. We kept it as agreed.\n\nWe can still send it up: the balance and carriage come to 24 coins. Or we can cancel it and return your deposit of 12 coins. Please let us know by {by}. If we don't hear by then, we'll cancel it and send the deposit.",
		"received": "The shop wrote. The order wasn't collected by the end of September; it's still in their back room.",
		"late": "After that, they'll cancel it and send the deposit back.",
		"lapse": {"text": "As we wrote, your order has been cancelled. Your deposit of 12 coins is enclosed.", "pay": 12,
			"diary": "I didn't answer the shop by {by}. They cancelled the order and sent my deposit back, 12 coins."},
		"choices": [
			_c("send", "Have it sent (24 coins)", "reply", "Please send it on to the farm. The balance and carriage, 24 coins, are enclosed.",
				"I paid the 24 coins to have the order sent up.", true, true,
				{"cost": 24, "parcel": _ORDER, "ack_title": "Your order", "ack_note": " The carrier brought the parcel from the shop, with a note.",
				"ack": "Received with thanks. Your order has gone with the carrier.", "ack_diary": "The carrier brought the order from the shop, with their note."}),
			_c("refund", "Cancel it; ask for the deposit back", "reply", "Please cancel the order and send my deposit back.",
				"I cancelled the order and asked for my deposit back.", false, true,
				{"pay": 12, "ack": "Your order is cancelled. Your deposit of 12 coins is enclosed.", "ack_title": "Your order, cancelled",
				"ack_diary": "They wrote back with my deposit, 12 coins."}),
		]}


static func _e_meeting(_ctx: Dictionary) -> Dictionary:
	return {"medium": "mail", "title": "Back for the autumn", "sender": "From the person you'd agreed to meet", "open": true,
		"body": "I'm back, as I said I'd be. I could do a Saturday in November, here, in the afternoon. I know it's a long way for you, and I can't do anything later in the year.\n\nIf you can't come, you could write instead. Or we can leave it. Either is all right.",
		"received": "The person I'd agreed to meet wrote. They're back, and could meet on a Saturday in November, where they live.",
		"choices": [
			_c("tell", "Say you can't come; write what it was for", "reply",
				"I can't come that far. What I wanted to tell you in person was that I might move away. I did, sooner than I said.",
				"I wrote that I can't come, and what the meeting had been for: I'd meant to tell them I might move away.", true, true,
				{"ack": "I wondered if it was that. Thank you for telling me, even this way.", "ack_title": "What it was for",
				"ack_diary": "They wrote back. They'd wondered if it was that."}),
			_c("letters", "Ask to write instead, now and then", "reply", "I can't come in November. Could we write instead, now and then?",
				"I wrote that I can't come in November, and asked if we could write instead.", true, true,
				{"ack": "Now and then, then. I'm not much of a letter writer, but I'll try.", "ack_title": "Now and then",
				"ack_diary": "They wrote back. We'll write now and then."}),
			_c("leave", "Leave it there", "reply", "November won't work, and I don't know when I'll be back that way. Let's leave it there.",
				"I wrote that November won't work, and left it there.", false, true,
				{"ack": "All right. Thank you for writing.", "ack_title": "Leave it there", "ack_diary": "They wrote back: thank you for writing."}),
		]}


# The rest of E: what became of the thing left unfinished, told by its outcome, with the farm beside it.
static func _e_desk(ctx: Dictionary) -> Dictionary:
	var s: Dictionary = ctx["s"]
	var w: Dictionary = ctx["w"]
	var parcels: Dictionary = ctx["parcels"]
	var fact := ""      # second person, for the scene
	var mine := ""      # first person, for the diary
	var choices: Array = []
	match str(ctx["loose_end"]):
		"work_offer":
			var offer := str(s.get("offer", w.get("offer", "")))
			if offer == "on_list":
				fact = "The seasonal work starts about now: six weeks, from October. You aren't down for a place this year. Your name is on their list for next year, and they write in August."
				mine = "The seasonal work started this month. I wasn't down for a place; my name is on next year's list."
				choices.append(_c("keep", "Keep their letter for August", "note", "", "I put their letter where I'll find it in August.", true, false,
					{"done": "You put the letter where you'll find it in August.", "about": "Nothing is sent. Your name stays on the list."}))
				choices.append(_c("off", "Write to take your name off the list", "reply", "Please take my name off the list for next year. Thank you for holding it.",
					"I wrote asking them to take my name off next year's list.", false, true,
					{"ack": "Done. Good luck with the farm.", "ack_title": "Off the list", "ack_diary": "They wrote back. My name is off the list."}))
			elif offer == "off_list":
				fact = "The seasonal work starts about now: six weeks, from October. Your name is off their list."
				mine = "The seasonal work started this month. My name is off their list."
			else:
				fact = "The seasonal work starts about now: six weeks, from October. The place you were offered was filled."
				mine = "The seasonal work started this month. The place I was offered was filled."
		"storage":
			var unit := str(parcels.get("unit", ""))
			if unit == "inspected" or unit == "returned":
				fact = {"gave_some": "The cartons from the unit came in the spring. You kept some of it and gave a carton to the charity shop.",
					"gave_all": "The cartons from the unit came in the spring. You gave them all to the charity shop."}.get(str(s.get("unit", "")),
					"The cartons from the unit came in the spring. You kept what was in them.")
				mine = "The storage unit came through in the spring."
			elif unit == "received":
				fact = "The cartons from the unit came in the spring, and are still shut."
				mine = "The cartons from the storage unit came in the spring. I haven't opened them."
			elif str(parcels.get("folder", "")) in ["received", "inspected"]:
				fact = "The unit was cleared. The folder of papers came back from the yard%s." % (", still shut" if str(parcels.get("folder", "")) == "received" else "")
				mine = "The storage unit was cleared. My papers came back from the yard."
			elif str(s.get("papers", "")) in ["shredded", "shredded_unanswered"]:
				fact = "The unit was cleared, and the last papers in it were shredded."
				mine = "The storage unit was cleared, and the last papers shredded."
			elif str(s.get("storage", w.get("storage", ""))) in ["cleared", "cleared_unanswered"]:
				fact = "The unit was cleared, and nothing was owed."
				mine = "The storage unit was cleared. Nothing was owed."
		"order":
			var order := str(parcels.get("order", ""))
			if order == "inspected":
				fact = "The order came up with the carrier in the spring, and you unwrapped it."
				mine = "The old order came through."
			elif order == "received":
				fact = "The order came up with the carrier, and is still in the shop's paper."
				mine = "The old order came. I haven't unwrapped it."
			elif order == "returned":
				fact = "The order came, and you sent it back. They refunded its price."
				mine = "The old order came, and I sent it back."
			elif str(s.get("order", "")) == "for_collection":
				fact = "The shop kept the order until the end of September. You didn't go for it."
				mine = "The shop kept my order until the end of September. I didn't go for it."
			elif str(s.get("order", w.get("order", ""))) in ["refunded", "declined_offer", "closed", "cancelled_unanswered"]:
				fact = "The order was cancelled, and the deposit came back."
				mine = "The old order was cancelled, and the deposit came back."
		"meeting":
			var meet := str(s.get("meeting", w.get("meeting", "")))
			if meet == "purpose_told":
				fact = "You never met. In the spring you wrote what the meeting had been for. They wrote back that they'd wondered."
				mine = "We never met. I wrote what the meeting had been for."
			elif str(s.get("address", "")) != "":
				fact = "You never met. They moved in June%s." % (", and you kept their new address" if str(s.get("address", "")) == "kept" else "")
				mine = "We never met. They moved in June."
				if str(s.get("address", "")) == "kept":
					choices.append(_c("write", "Write a short line to the new address", "reply", "A year on, a short line from the farm. I hope the move went well.",
						"I wrote a short line to their new address.", true, false,
						{"ack": "Thank you. It did, mostly. The same to you, up there.", "ack_title": "The new address",
						"ack_diary": "They wrote back: the move went well, mostly."}))
			else:
				fact = "You never met."
				mine = "We never met."
	if fact == "" and str(ctx["w_state"]) == "delivered":
		fact = "The letters about what you left unfinished are in the desk with it."
		mine = "I read the letters about what I left unfinished again."
	var body := "The notice for the farm is in the desk. You put it under a pile of papers on a Wednesday, and took it out again on the Thursday."
	if fact != "":
		body += "\n\n" + fact
	body += "\n\n%s %s" % [house_now(int(ctx["stage"]), int(ctx["mended"])), field_now(int(ctx["harvested"]), str(ctx["crops"]))]
	choices = _open_choice(ctx, "unit", "Open the cartons", "A year on, I opened the cartons from the storage unit.") \
		+ _open_choice(ctx, "order", "Unwrap the order", "A year on, I unwrapped the old order.") \
		+ _open_choice(ctx, "folder", "Open the folder of papers", "A year on, I opened the folder of papers from the unit.") + choices
	if mine != "":
		choices.append(_c("write_down", "Write down where it stands", "note", "", mine, false, false,
			{"done": "You write it down in the diary.", "about": "In the diary:\n\n%s" % mine}))
	choices.append(_c("put_away", "Put the notice away with the farm's papers", "note", "", "I put the farm notice away with the farm's papers.", false, false,
		{"done": "You put the notice away with the farm's papers.", "about": "Nothing is sent."}))
	choices.append(_c("leave", "Leave it where it is", "note", "", "I read the farm notice again and left it where it was.", true, false,
		{"done": "You leave the notice where it is.", "about": "Nothing changes."}))
	return {"medium": "desk", "title": "The closing date", "body": body, "choices": choices}


# --- The September page, read against now --------------------------------------------------------------------

# Two sentences for the diary entry the answer makes, when the September page was written before the answer:
# the closing line as written (with when it was written), then one plain fact of how things stand now.
# ctx keys used: day, stage, harvested (now); refl (the record's facts: house_stage, harvested); open_then.
static func reflection_lines(id: String, words: String, written: int, written_date: String, ctx: Dictionary, r: Dictionary,
		c: Dictionary) -> Array:
	if id == "" or words == "":
		return []
	var quote := "At the end of September I wrote, \"%s\"" % words if written <= 365 else "On %s I finished the year's page with, \"%s\"" % [written_date, words]
	var then: Dictionary = ctx["refl_facts"]
	var now := ""
	match id:
		"finish":
			var was := int(then.get("house_stage", 0))
			var is_now := int(ctx["stage"])
			if was >= 3:
				var more := int(ctx["harvested"]) - int(then.get("harvested", 0))
				now = "The house was already restored then. Since then I've brought in %d more crops." % more if more > 0 else "The house was already restored then."
			elif is_now >= 3:
				now = "Since then the house has been finished: the walls, the roof and the windows."
			elif is_now > was:
				now = "Since then I've done another round of work on the house. It isn't finished."
			else:
				now = "The house is as it was then. That work is still there to do."
		"keep":
			now = "This is one of the things I kept." if bool(c.get("keeps", false)) else "This one I closed."
		"unknown":
			now = "It is the next year now. This letter is part of what it has brought." if str(r["medium"]) == "mail" \
				else "It is the next year now. The farm still needs its work."
		"unsettled":
			if bool(r.get("open", false)):
				now = "This was one of them. It is settled now." if bool(c.get("settles", false)) else "This is still one of them."
			elif bool(ctx["open_then"]):
				now = "This wasn't one of the things still open then."
			else:
				now = "Nothing from before was still open when I wrote it."
		"stay":
			now = "I'm still here, %d days after I first came up the lane." % (int(ctx["day"]) - 1)
	return [quote, now]


# --- The practical life: one morning in the second autumn -----------------------------------------------------

# [id, the morning report's sentence, the diary's lines]: one fact, by priority, from what the save proves.
static func world(ctx: Dictionary) -> Array:
	var then := "A year ago" if int(ctx["day"]) <= 372 else "When you first came up the lane"
	var then_me := "A year ago" if int(ctx["day"]) <= 372 else "When I first came up the lane"
	if str(ctx["inn_month"]) != "":
		return ["inn", " %s you hadn't been down the hill road. Since then you've mended the leak over the back room at the inn in Wicker Cove." % then,
			"%s I hadn't been down the hill road. In %s I mended the leak over the back room at the inn in Wicker Cove, for Edith Vale." % [then_me, str(ctx["inn_month"])]]
	var stage := int(ctx["stage"])
	if stage >= 1 or int(ctx["mended"]) > 0:
		var done: String = {3: "the house is restored: walls, roof and windows", 2: "the roof has new shingles and the windows have glass",
			1: "the holes in the walls are patched and the broken windows boarded"}.get(stage,
			"%s mended" % ("one board is" if int(ctx["mended"]) == 1 else "%d boards are" % int(ctx["mended"])))
		return ["house:%d" % stage, " %s the wind came through the walls of this house. Now %s." % [then, done],
			"%s the wind came through the walls of the house. Now %s." % [then_me, done]]
	if int(ctx["hewn"]) > 0:
		var n := int(ctx["hewn"])
		return ["hewn", " %s you had never hewn a plank. The workbench has made %s since." % [then, "one" if n == 1 else str(n)],
			"%s I had never hewn a plank. I've hewn %s at the workbench since." % [then_me, "one" if n == 1 else "%d" % n]]
	var a: Array = ctx["asked"]
	if not a.is_empty():
		return ["asked:" + str(a[4]), " %s you didn't know anyone on the road past the farm. %s has asked you for things since, and you brought them." % [then, str(a[0])],
			"%s I didn't know anyone on the road past the farm. %s has asked me for things since, and I brought them." % [then_me, str(a[0])]]
	if int(ctx["visits"]) > 0:
		return ["cove", " %s you hadn't been down the hill road. You've been to Wicker Cove %s since." % [then, _times(int(ctx["visits"]))],
			"%s I hadn't been down the hill road. I've been to Wicker Cove %s since." % [then_me, _times(int(ctx["visits"]))]]
	return ["farm", " It is a year since you came up the lane. Most of the valley past the gate is still unfamiliar.",
		"It is a year since I came up the lane. I've kept to the farm. Most of the valley past the gate I still don't know."]
