class_name OriginState
extends RefCounted

## CCH-ORIGIN-001: the record of the player's life before Crow Creek Hollow, made by the opening interlude
## (RoadInterlude, text in RoadScript) and kept in the save under "origin".
##
## It holds facts only: which reason the player gave, the choices they actually made on that road, and
## whether the interlude is finished. It gives nothing: no coins, tools, skills, land or friendship. Future
## mail and diary pages read it through the query functions at the bottom (read-only); nothing else should
## write to it. Residents of the Hollow never read it: none of them has a way to know the player's past
## unless a later scene gives them one.
##
## The record (dictionary, version V):
##   v         int     record version (1)
##   status    String  "in_progress" (the interlude isn't finished; pos is where to resume), "complete",
##                     "legacy" (a save from before the interlude existed: the past is unknown, never made up),
##                     or "none" (a world started without the interlude, by a test tool)
##   choices   Dict    choice key -> option id, only for choices on the path actually taken
##   order     Array   the choice keys in the order they were made (going back and choosing again drops the
##                     later ones, so the record never holds a choice from a road not taken)
##   pos       int     while in_progress: the step of the interlude to resume on
##   day       int     the game day the interlude was finished before (always 1)
##
## Choice keys and their option ids are the screenplay's state ids
## (AI_COLLAB/ROAD_TO_CROW_CREEK_HOLLOW_BRANCHING_SCREENPLAY_DRAFT.md). RoadScript.OPTIONS lists every one.

const V := 1
const ORIGINS := ["security", "work", "household", "curiosity", "chance"]
# The design documents' origin letters and titles for each screenplay id.
const ORIGIN_TITLES := {
	"security": "A - The Cost of a Room",
	"work": "B - Work That Belonged to Everyone",
	"household": "C - A House With One Less Person",
	"curiosity": "D - The Place in the Photograph",
	"chance": "E - A Chance Before It Closed",
}

var data: Dictionary = {}


func _init(d: Variant = null) -> void:
	data = sanitize(d)


static func fresh() -> Dictionary:
	return {"v": V, "status": "in_progress", "choices": {}, "order": [], "pos": 0}


# A record checked against the authored options: unknown keys, options off the path and anything malformed are
# dropped, so a damaged or hand-edited save can never make a contradictory past. A missing record is "none".
static func sanitize(d: Variant) -> Dictionary:
	if typeof(d) != TYPE_DICTIONARY:
		return {"v": V, "status": "none", "choices": {}, "order": []}
	var src: Dictionary = d
	var status := str(src.get("status", "none"))
	if not status in ["in_progress", "complete", "legacy", "none"]:
		status = "none"
	var out := {"v": V, "status": status, "choices": {}, "order": []}
	if status in ["legacy", "none"]:
		return out
	var raw: Variant = src.get("choices", {})
	var order: Variant = src.get("order", [])
	if typeof(raw) != TYPE_DICTIONARY or typeof(order) != TYPE_ARRAY:
		raw = {}
		order = []
	# Replay the choices in order through the script: each must be the next choice the road asks for.
	var kept := {}
	var kept_order := []
	for key in order:
		var k := str(key)
		if not (raw as Dictionary).has(k) or kept.has(k):
			break
		var next := RoadScript.next_choice(kept)
		if next.is_empty() or str(next["key"]) != k or not RoadScript.option_ids(next).has(str(raw[k])):
			break
		kept[k] = str(raw[k])
		kept_order.append(k)
	out["choices"] = kept
	out["order"] = kept_order
	if status == "complete":
		# A finished road must be whole; one that isn't goes back to being read from where it stops.
		if not RoadScript.next_choice(kept).is_empty():
			out["status"] = "in_progress"
		else:
			out["day"] = int(src.get("day", 1))
			return out
	out["pos"] = maxi(0, int(src.get("pos", 0)))
	return out


func to_save() -> Dictionary:
	return data.duplicate(true)


# --- Read-only queries for mail, the diary and later scenes -------------------------------------------------
# Every one answers "" or false when the past is unknown (a legacy save) or unfinished, so a caller never has
# to tell those apart from a choice it doesn't care about.

# Whether the player came through the interlude and the record is complete.
func known() -> bool:
	return str(data.get("status", "")) == "complete"


# "legacy" for a save from before the interlude: show nothing about the player's past.
func status() -> String:
	return str(data.get("status", "none"))


# security, work, household, curiosity or chance; "" when unknown.
func origin() -> String:
	return choice("origin")


# The option id the player chose for a screenplay choice key, or "" if it was never made on their road.
func choice(key: String) -> String:
	if not known():
		return ""
	return str((data.get("choices", {}) as Dictionary).get(key, ""))


# Who saw the player off: friend, family, colleague_or_neighbor, former_household, private, or none.
func contact() -> String:
	return choice("contact")


# Someone saw them off (even if the player keeps who it was private).
func has_contact() -> bool:
	return contact() != "" and contact() != "none"


# promise, uncertain, invite, boundaries, or none. A letter from the old life should honour "boundaries".
func contact_intent() -> String:
	return choice("contact_intent")


# photo, tool, postcard, notebook, or none. A fact only: there is no item in the pack.
func keepsake() -> String:
	return choice("keepsake")


# The present-tense statement chosen at the gate (RoadScript.OPTIONS["arrival_intention"]). Not a personality.
func arrival_intention() -> String:
	return choice("arrival_intention")


# The later-life thread each origin opens, for the winter post (screenplay Act 5). "" when unknown.
#   forwarded_belongings  security: stored boxes or a forwarding address (security_exit)
#   old_workplace         work: someone at the old job may write (work_exit)
#   former_household      household: someone from the house left behind (household_relation, _change)
#   the_place             curiosity: someone asks what the place is really like (needs has_contact())
#   open_arrangement      chance: the arrangement left unfinished (chance_loose_end)
func thread() -> String:
	return {"security": "forwarded_belongings", "work": "old_workplace", "household": "former_household",
		"curiosity": "the_place", "chance": "open_arrangement"}.get(origin(), "")


# How a letter from the former household may name its sender: the relationship the player gave, or "" if
# they kept it private (then write "someone from the house you left").
func household_sender() -> String:
	var r := choice("household_relation")
	return "" if r == "private" else r
