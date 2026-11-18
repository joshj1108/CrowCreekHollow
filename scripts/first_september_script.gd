class_name FirstSeptemberScript
extends RefCounted

## CCH-ORIGIN-004: the words of "One Year on the Road", the first September's page in the player's diary.
## FirstSeptember (scripts/first_september.gd) decides which lines are true and keeps the record; this file is only
## text. Every line here is used only when the save proves it (the conditions are in FirstSeptember).
##
## Sources: FIRST_SEPTEMBER_BRANCHING_DETAIL.md (P3 "A Year at the Farm", the four sample voices),
## TWO_LIVES_INTERWOVEN_ORIGIN_ARCS.md (each origin's September note), the spring screenplay's September factual
## lines (already in PastSpringScript as each route's "sept"), and the interlude's own words (RoadScript). The
## adaptations are listed in AI_COLLAB/CCH_ORIGIN_004_REPORT.md.

const TITLE := "One Year on the Road"

# How long ago the lane was, by the day the page is read (and, once written, the day it was written).
static func opening(day: int) -> String:
	if day <= 365:
		return "It's almost a year since I first came up the lane."
	if day <= 372:
		return "It's a year now since I first came up the lane."
	return "It's more than a year since I first came up the lane. I meant to write this in September."


# --- A. The life before (only for a known origin) ------------------------------------------------------------

# The first lines, from the interlude's own scenes and the choices made on that road.
static func before(o: OriginState) -> Array:
	match o.origin():
		"security":
			var exit_line: String = {
				"extension": "Before I left the old room, I asked for more time to arrange the move. They gave me until the end of the month.",
				"forward": "I left the old room with the farm's address written on a card, for anything that came after me.",
				"stored": "When I left the old room, I asked someone to keep two boxes until I was settled. They said they would.",
			}.get(o.choice("security_exit"), "")
			return [exit_line, "I kept the old rent notice and the new one in the same envelope, though only one of them still mattered."]
		"work":
			var exit_line: String = {
				"finish": "Before I left the old job, I finished the order I'd promised and signed the last page.",
				"instructions": "When I left the old job, I gave notice and wrote the next steps on a clean sheet by the work list.",
				"boundary": "When I left the old job, I told them I couldn't keep doing it. They had to choose someone to take over.",
			}.get(o.choice("work_exit"), "")
			return [exit_line, "I turned the light off when I left. Someone else would turn it on in the morning."]
		"household":
			var rel := o.choice("household_relation")
			var change := o.choice("household_change")
			var shared: String = {"partner": "someone I loved", "friend": "a friend", "family": "someone in my family"}.get(rel, "someone")
			var lines: Array = ["A year ago I was packing up a house I had shared with %s." % shared]
			if rel != "private":
				var why: String = {"separate": "We had agreed it was time to live separately.",
					"moved": "They had somewhere else they needed to be.", "ended": "The arrangement couldn't continue."}.get(change, "")
				if why != "":
					lines.append(why)
			lines.append("There was less on the list of things to move than there would have been the spring before.")
			return lines
		"curiosity":
			var hope: String = {"growing": "I wanted land where I could grow something.",
				"quiet": "I wanted time away from noise and traffic.",
				"making": "I wanted somewhere I could learn to work with my hands.",
				"exploring": "I wanted a road I hadn't taken before."}.get(o.choice("curiosity_interest"), "")
			return ["A year ago all I knew of this place was a photograph in a notice: half the house behind trees, a fence nobody had mended, and a patch of open ground.", hope]
		"chance":
			var left: String = {"work_offer": "an offer of seasonal work",
				"storage": "a small storage arrangement",
				"order": "an order, with a deposit on something I'd meant to buy",
				"meeting": "a meeting I had agreed to"}.get(o.choice("chance_loose_end"), "something")
			return ["I hadn't meant to move that year. The notice said the chance would close at the end of the week. I put it under a pile of papers on the Wednesday and took it out again on the Thursday.",
				"When I took it, I left something unfinished: %s." % left]
	return []


# The keepsake, as the interlude described it. A fact of what was packed, not a claim about where it is now.
const KEEPSAKE := {
	"photo": "I brought one photograph with me, its corner folded twice.",
	"tool": "I brought an old work tool with me. The handle is smooth near the thumb.",
	"postcard": "I brought a postcard with me. One line on it is still unfinished.",
	"notebook": "I brought a small notebook with me: names, measurements, a few things worth remembering.",
}

# When the spring left no line of its own: what the winter really brought (its first letter, read).
const WINTER_ONLY := {
	"security": "A letter about the old room came in the winter.",
	"work": "A letter came from the old job in the winter.",
	"household": "A letter came from the old house in the winter.",
	"curiosity": "In the winter, someone wrote to ask what the place was really like.",
	"chance": "In the winter, a letter came about what I had left unfinished.",
}

# A letter still on the desk, or an answer still in the post, when the page is written.
const UNANSWERED := "There is a letter from before that I haven't answered yet."
const IN_THE_POST := "My last answer is still in the post."
const AWAITING_REPLY := "I've written back. Their answer hasn't come yet."

# A parcel's state, so a box that hasn't come, or came and is still shut, is never called unpacked.
#   coming: paid for and with the carrier; shut: here, not opened.
const PARCELS := {
	"boxes": {"coming": "I paid to have the two boxes sent up. The carrier has them; they haven't come yet.",
		"shut": "The two boxes came up with the carrier. I haven't opened them yet."},
	"papers": {"coming": "My papers are in the post. They haven't come yet.",
		"shut": "The packet with my papers came. I haven't opened it yet."},
	"house_boxes": {"coming": "My two boxes from the old house are with the carrier. They haven't come yet.",
		"shut": "My two boxes from the old house came. I haven't opened them yet."},
	"unit": {"coming": "The contents of the storage unit are with the carrier. They haven't come yet.",
		"shut": "The cartons from the storage unit came up with the carrier. I haven't opened them yet."},
	"folder": {"coming": "The storage yard is posting my papers back. They haven't come yet.",
		"shut": "The folder of papers from the storage yard came. I haven't opened it yet."},
	"order": {"coming": "The old order is with the carrier. It hasn't come yet.",
		"shut": "The old order came with the carrier. I haven't unwrapped it yet."},
}

# An arrangement with a date in it, told as what was said, before and after that date (never assumed kept).
#   key: "outcome key=value"; each {"until": the outcome's until_day key, "before", "after"}
const DATED := {
	"keeper=send_on": {"before": "They said they'd ask at the old door until the end of summer.",
		"after": "They said they'd ask at the old door until the end of summer. The summer is over now."},
	"belongings=held": {"before": "They said they'd keep everything together until the end of September.",
		"after": "They said they'd keep everything together until the end of September. September has gone, and I haven't written since."},
	"order=for_collection": {"before": "",
		"after": "The shop said it would keep the order until the end of September. I didn't go for it."},
}
# The September line the screenplay gave a dated arrangement, which is only true before its date.
const DATED_SEPT := {
	"order=for_collection": "My old order is kept at the shop for me to collect, until the end of September.",
}


# --- B. The life here -------------------------------------------------------------------------------------------

# The player's own words at the gate (RoadScript), quoted back without comment.
static func gate(said: String) -> String:
	return "At the gate I said, \"%s\"" % said


static func house(stage: int, mended: int) -> String:
	match stage:
		3:
			return "The farmhouse is restored now: the walls, the roof and the windows."
		2:
			return "The roof has new shingles, and there is glass in the windows again. One more round of work and the house would be restored."
		1:
			return "I patched the holes in the walls and boarded the broken windows. The roof still wants new shingles."
	if mended > 0:
		return "I've mended %s in the house, one at a time. Otherwise it is much as I found it: the roof has its hole, and the wind comes through the walls." % (
			"one board" if mended == 1 else "%d boards" % mended)
	return "The house is much as I found it. The roof has its hole, and the wind comes through the walls."


# Origin A: the paper side of a home. Never says the farm is owned unless the deed is paid.
static func deed(owned: bool, paid: int, price: int) -> String:
	if owned:
		return "The deed is paid. The farm is mine on paper as well."
	if paid > 0:
		return "I've paid %d of the town's %d coins toward the deed. The rest is still owed." % [paid, price]
	return "The town still holds the deed."


static func land(harvested: int, crops: String) -> String:
	if harvested <= 0:
		return "Nothing has come out of the field yet."
	if harvested == 1:
		return "The field has given me one crop so far."
	return "I've harvested %d crops from the field since I came, more %s than anything else." % [harvested, crops]


# Origin B: the work of the hands, counted only from the workbench's record.
static func planks(hewn: int) -> String:
	if hewn <= 0:
		return ""
	return "I hewed %s at the workbench myself." % ("one plank" if hewn == 1 else "%d planks" % hewn)


static func inn(month: String) -> String:
	return "In %s I mended the leak over the back room at the inn in Wicker Cove, for Edith Vale. She paid me for the work." % month


# A walker who asked for something and was brought it. Never called a friend.
static func asked(who: String, first: String, second: String, more: int) -> String:
	if more <= 0:
		return "%s asked me for %s, and I brought them." % [who, first]
	if more == 1:
		return "%s asked me for %s, and later for %s. I brought both." % [who, first, second]
	return "%s asked me for %s, and for other things after. I brought what was asked." % [who, first]


static func cove(visits: int) -> String:
	if visits == 1:
		return "I've been down the hill road to Wicker Cove once."
	return "I've been down the hill road to Wicker Cove %d times." % visits


const WOODS := {
	"nearwood": "I go up the trail behind the house for timber. I know some of the way now.",
	"trek": "I've walked some way into the woods behind the field. There are places there I still don't understand.",
	"edge": "I've walked out to where the woods begin, and no further.",
}
const STAYED_CLOSE := "I haven't gone far from the farm. The road down the hill is still there."

# Origin D: the photograph laid against what is there now. Says what changed, never that it is better.
static func photograph(stage: int) -> String:
	if stage >= 1:
		return "The roof was worse than in the photograph when I came. It isn't the house in the picture any more."
	return "The roof was worse than in the photograph when I came."

# Origin E: the chance taken, read against what was left.
const CHANCE_BOTH := "I don't know if the other way would have been better. I know what this one has been."


# --- C. What the player chooses to say ----------------------------------------------------------------------

# The closing words. Each is something the player says about the year ahead, kept as said, not as a measure of
# them. {label} is what the row shows; {line} is what goes on the page. FirstSeptember adapts the wording.
const REFLECTIONS := ["finish", "keep", "unknown", "unsettled", "stay"]
# Short names for the desk's list, where a whole line would be cut off; the whole line shows beside it.
const SHORT := {"finish": "Work I want to finish", "keep": "Part of my old life", "unknown": "What next year will bring",
	"unsettled": "Things not settled yet", "stay": "What happens if I stay"}

static func reflection(id: String, house_done: bool, open_before: bool) -> String:
	match id:
		"finish":
			return "There is still work here I want to finish." if house_done else "There is still work on this house I want to finish."
		"keep":
			return "I want to keep some part of my old life."
		"unknown":
			return "I don't know what next year will bring."
		"unsettled":
			return "There are things from before that I haven't settled yet." if open_before else "There are things I haven't settled yet."
		"stay":
			return "I want to see what happens if I stay."
	return ""

const WRITTEN := "You write it at the foot of the page, and blot the ink."
const UNFINISHED := "The foot of the page is still blank.\n\nThe last lines are written at the desk in the bedroom, in its Diary tab. Writing takes no time."
const NOTICE_SOON := " It is almost a year since you first came up the lane. There is a blank page at the back of your diary."
const NOTICE_LATE := " It is more than a year since you first came up the lane. There is a blank page at the back of your diary."
