class_name RoadScript
extends RefCounted

## CCH-ORIGIN-001: the text of "The Road to Crow Creek Hollow", the opening interlude every new game plays
## before October 1. The words are the screenplay's (AI_COLLAB/ROAD_TO_CROW_CREEK_HOLLOW_BRANCHING_SCREENPLAY_DRAFT.md,
## Acts 0-4); AI_COLLAB/CCH_ORIGIN_001_REPORT.md lists the few places its stage directions were turned into prose.
##
## sequence(choices) lays out the road for the choices made so far: a list of steps, ending at the first choice
## not yet made (or, once every choice is made, at the door). The same choices always give the same steps, so
## a step's index is a safe place to resume, and going back and choosing differently simply lays out a new road.
##
## A step is a Dictionary:
##   kind    "page" (text, then Continue), "choice" (a prompt and options) or "arrive" (the last confirmation)
##   id      a stable name, e.g. "s1a" or "c20"
##   act     the act's title, shown above the page
##   scene   the backdrop to draw (RoadInterlude._draw_scene)
##   lines   paragraphs; one starting with "!" is printed as the notice or sign it quotes
##   key, prompt, options [{id, text}]   for a choice: the OriginState key it sets and what can be said

const ACTS := ["A Place on Paper", "The Reason for Leaving", "Someone Who Knows You", "What Comes Along", "The Road"]


static func _page(id: String, act: int, scene: String, lines: Array) -> Dictionary:
	return {"kind": "page", "id": id, "act": ACTS[act], "scene": scene, "lines": lines}


static func _choice(id: String, act: int, scene: String, key: String, prompt: String, options: Array, lines: Array = []) -> Dictionary:
	var opts := []
	for pair in options:
		opts.append({"id": pair[0], "text": pair[1]})
	return {"kind": "choice", "id": id, "act": ACTS[act], "scene": scene, "key": key, "prompt": prompt, "options": opts, "lines": lines}


# Whether the choice in this step has been made with one of its own options.
static func _made(step: Dictionary, choices: Dictionary) -> bool:
	return choices.has(step["key"]) and option_ids(step).has(str(choices[step["key"]]))


static func option_ids(step: Dictionary) -> Array:
	var ids := []
	for o in step.get("options", []):
		ids.append(str(o["id"]))
	return ids


# The first choice on this road not yet made, or {} when the road reaches the door.
static func next_choice(choices: Dictionary) -> Dictionary:
	var steps := sequence(choices)
	var last: Dictionary = steps[steps.size() - 1]
	return last if last["kind"] == "choice" else {}


static func sequence(c: Dictionary) -> Array:
	var s := []
	# ACT 0 - A Place on Paper (SCENE 00)
	s.append(_page("s00", 0, "notice", [
		"The notice had arrived with the usual post.",
		"It was folded between an advertisement and a bill that had nothing to do with you.",
		"!Old farmhouse. Fields and outbuildings. Available for occupation and work. Terms through the town office.",
		"The picture showed a roof above a fence and a stand of dark trees.",
		"You left it on the table.",
		"Three days later, it was still there."]))
	var c00 := _choice("c00", 0, "notice", "origin", "Why have you kept it?", [
		["security", "\"I need a place I can afford to live.\""],
		["work", "\"I want my work to belong to me.\""],
		["household", "\"The life I had has changed.\""],
		["curiosity", "\"I want to see that place for myself.\""],
		["chance", "\"The chance is here, and it may not be again.\""]])
	s.append(c00)
	if not _made(c00, c):
		return s
	var origin := str(c["origin"])

	# ACT 1 - The Reason for Leaving: one of five scenes.
	match origin:
		"security":
			s.append(_page("s1a", 1, "rent", [
				"The new terms were printed on one sheet.",
				"You laid it beside the old one. Most of the words were the same.",
				"The amount at the bottom had changed.",
				"You counted what you had saved. Then you counted it again.",
				"There were other rooms to look at. The farm was the first place you had seen with land you might work."]))
			var c1a := _choice("c1a", 1, "rent", "security_exit", "What do you do before leaving?", [
				["extension", "\"Ask for more time to arrange the move.\""],
				["forward", "\"Arrange a forwarding address and go.\""],
				["stored", "\"Ask someone to keep two boxes until I'm settled.\""]])
			s.append(c1a)
			if not _made(c1a, c):
				return s
			var after: Array = {
				"extension": ["You wrote a short note asking for more time to arrange the move.",
					"The answer arrived days later.", "\"Until the end of the month. No longer.\""],
				"forward": ["You wrote the farm's address on a card and placed it with the bills."],
				"stored": ["You asked someone you knew to keep two boxes until you were settled.", "They said they would."],
			}[c["security_exit"]]
			s.append(_page("s1a_end", 1, "rent", after + [
				"You put the two notices into the same envelope.",
				"One was no longer useful. You kept it anyway."]))
		"work":
			s.append(_page("s1b", 1, "workroom", [
				"There was a list of things to do tomorrow.",
				"There had been one yesterday, too.",
				"You finished the last task on today's page and put the pencil down.",
				"Someone had written a note asking if you could come in early.",
				"In your coat pocket was a folded copy of the farm notice."]))
			var c1b := _choice("c1b", 1, "workroom", "work_exit", "How do you leave the work?", [
				["finish", "\"Finish the job I promised to finish.\""],
				["instructions", "\"Give notice and leave clear instructions.\""],
				["boundary", "\"Tell them I can't keep doing this.\""]])
			s.append(c1b)
			if not _made(c1b, c):
				return s
			var after: Array = {
				"finish": ["It took several more days to finish the order you had promised and hand it over.",
					"You signed the last page."],
				"instructions": ["You gave your notice.",
					"Then you wrote the next steps on a clean sheet and left it by the work list."],
				"boundary": ["\"I can't keep doing this,\" you said.",
					"Your supervisor accepted your notice, then asked who would take over.",
					"\"I don't know yet,\" you said.",
					"They would have to choose someone themselves."],
			}[c["work_exit"]]
			s.append(_page("s1b_end", 1, "workroom", after + [
				"You turned the light off when you left.",
				"Someone else would turn it on in the morning."]))
		"household":
			s.append(_page("s1c", 1, "shelf", [
				"The shelf was still marked where the other things had been.",
				"You tried the empty space with your hand, as if something might fit there.",
				"It didn't need filling.",
				"On the table lay a photograph of a farmhouse in the hills.",
				"You had already begun packing when you found the notice."]))
			var c1c := _choice("c1c_1", 1, "shelf", "household_relation", "Who had shared this place?", [
				["partner", "\"Someone I loved.\""],
				["friend", "\"A friend.\""],
				["family", "\"Someone in my family.\""],
				["private", "\"I'd rather keep that private.\""]])
			s.append(c1c)
			if not _made(c1c, c):
				return s
			var c1c2 := _choice("c1c_2", 1, "shelf", "household_change", "What changed?", [
				["separate", "\"We agreed it was time to live separately.\""],
				["moved", "\"They had somewhere else they needed to be.\""],
				["ended", "\"The arrangement couldn't continue.\""],
				["private", "\"I don't want to explain it.\""]])
			s.append(c1c2)
			if not _made(c1c2, c):
				return s
			var told: bool = c["household_relation"] != "private" and c["household_change"] != "private"
			var variant: Array
			if told:
				variant = ["There was a knock at the door.",
					"\"You don't have to get rid of everything,\" they said.",
					"\"I know.\"",
					"They stood beside the empty shelf for a moment."]
			else:
				variant = ["You closed the box, wrote the address on it, and put it beside the door."]
			s.append(_page("s1c_end", 1, "shelf", variant + [
				"You made a list of what needed moving.",
				"There was less on it than there had been in the spring."]))
		"curiosity":
			s.append(_page("s1d", 1, "photograph", [
				"The photograph wasn't a good one.",
				"Half the farmhouse was hidden by the trees. The fence looked as though it hadn't been fixed in years.",
				"There was a patch of open ground beside the house.",
				"You kept returning to that part of the picture.",
				"The listing told you almost nothing about the place."]))
			var c1d := _choice("c1d", 1, "photograph", "curiosity_interest", "What did you hope to find there?", [
				["growing", "\"Land where I could grow something.\""],
				["quiet", "\"Time away from noise and traffic.\""],
				["making", "\"A place where I could learn to work with my hands.\""],
				["exploring", "\"A road I hadn't taken before.\""]])
			s.append(c1d)
			if not _made(c1d, c):
				return s
			s.append(_page("s1d_end", 1, "photograph", [
				"You wrote to ask whether the place was still available.",
				"The answer was short.",
				"It was."]))
		"chance":
			s.append(_page("s1e", 1, "closing_date", [
				"You had not made plans to move that year.",
				"There was work where you lived, for the moment. Your days had a useful order.",
				"The farm notice said the opportunity would close at the end of the week.",
				"You put it under a pile of papers on Wednesday.",
				"On Thursday, you took it out again."]))
			var c1e := _choice("c1e", 1, "closing_date", "chance_loose_end", "What will you leave unfinished?", [
				["work_offer", "\"An offer of seasonal work.\""],
				["storage", "\"A small storage arrangement.\""],
				["order", "\"An order or deposit for something I'd intended to buy.\""],
				["meeting", "\"A meeting I had agreed to.\""]])
			s.append(c1e)
			if not _made(c1e, c):
				return s
			s.append(_page("s1e_end", 1, "closing_date", [
				"You wrote to the town office before the post went out.",
				"There was no answer that day.",
				"When the reply came, you read it standing beside the door."]))

	# ACT 2 - Someone Who Knows You (SCENE 20). Who came is asked first, so "no one" can be its own scene.
	var contacts := [["friend", "A friend."], ["family", "A relative."],
		["colleague_or_neighbor", "Someone I've worked or lived beside."]]
	if origin == "household":
		contacts.append(["former_household", "Someone from the house I'm leaving."])
	contacts.append(["private", "Someone whose name I'd rather keep to myself."])
	contacts.append(["none", "No one came by."])
	var c20 := _choice("c20", 2, "boxes", "contact", "Before you left, did anyone come by?", contacts,
		["By the last afternoon, only a few boxes were still open."])
	s.append(c20)
	if not _made(c20, c):
		return s
	if c["contact"] == "none":
		s.append(_page("s20_alone", 2, "boxes", [
			"You set a final box beside the door.",
			"There was nobody to say goodbye to that afternoon.",
			"You checked the address and shut the room behind you."]))
		var c21n := _choice("c21", 2, "boxes", "contact_intent", "Before you go", [
			["none", "\"I'll make the arrangements myself.\""]])
		s.append(c21n)
		if not _made(c21n, c):
			return s
	else:
		s.append(_page("s20", 2, "boxes", [
			"Someone came by while the last boxes were open.",
			"They looked at the room, then at the folded farm notice.",
			"\"That's a long way,\" they said.",
			"\"It is.\"",
			"They picked up a book from the table and put it back."]))
		var echo := []
		match origin:
			"security":
				if c.get("security_exit", "") == "extension":
					echo = ["\"You could have stayed here another month,\" they said.", "\"Another month,\" you answered."]
			"work":
				echo = ["\"They'll find someone,\" they said.", "\"They'll have to,\" you answered."]
			"household":
				echo = ["\"You can send word when you're ready,\" they said.", "\"I know.\""]
			"curiosity":
				echo = ["\"You don't know what the place is like.\"", "\"No. I don't.\""]
			"chance":
				echo = ["\"You always said you might do something different.\"", "\"I didn't say when.\""]
		var c21 := _choice("c21", 2, "boxes", "contact_intent", "Your reply", [
			["promise", "\"I will.\""],
			["uncertain", "\"I don't know how often.\""],
			["invite", "\"Come up sometime, if you'd like.\""],
			["boundaries", "\"I'd rather start without making plans.\""]],
			echo + ["\"Write when you get there,\" they said.", "They did not make it a question."])
		s.append(c21)
		if not _made(c21, c):
			return s
		s.append(_page("s20_end", 2, "boxes", [
			"You shut the last box.",
			"The room was ready for whoever came after you."]))

	# ACT 3 - What Comes Along (SCENE 30). The keepsake is a fact in the record, not an item in the pack.
	var c30 := _choice("c30", 3, "case", "keepsake", "What do you take?", [
		["photo", "A photograph."],
		["tool", "An old work tool."],
		["postcard", "A postcard, or a note never sent."],
		["notebook", "A small notebook."],
		["none", "Nothing."]],
		["The large things had gone already.",
		"There was room for one more small thing in your case.",
		"You looked through what was left."])
	s.append(c30)
	if not _made(c30, c):
		return s
	var kept: Array = {
		"photo": ["You put the photograph in the case. The faded corner had been folded twice."],
		"tool": ["You put the tool in the case. The handle was smooth near the thumb."],
		"postcard": ["You put the postcard in the case. One line on it was unfinished."],
		"notebook": ["You put the notebook in the case. It held names, measurements and a few things worth remembering."],
		"none": ["You left the rest where it was."],
	}[c["keepsake"]]
	s.append(_page("s30_end", 3, "case", kept + ["You closed the case and lifted it from the floor."]))

	# ACT 4 - The Road (SCENES 40-42)
	var echo40: String = {
		"security": "You had copied the terms of the farm onto the back of the notice.",
		"work": "The last page of instructions was still in your coat pocket." if c.get("work_exit", "") == "instructions"
			else "The folded farm notice was still in your coat pocket.",
		"household": "You checked that the box was closed.",
		"curiosity": "You took the photograph out to check whether the road looked familiar. It didn't.",
		"chance": "The acceptance note had been folded and unfolded enough to soften its corners.",
	}[origin]
	s.append(_page("s40", 4, "fuel", [
		"By the time you stopped for fuel, the town behind you was too far away to go back for anything forgotten.",
		"You bought a drink and asked how much farther the road went.",
		"\"To the farms,\" the attendant said. \"After that, mostly trees.\"",
		"You checked the directions again.",
		echo40]))
	var c41 := _choice("c41", 4, "ridge", "road_pause", "How do you approach the turn?", [
		["look", "\"Stop and look at the sign.\""],
		["drive", "\"Keep driving.\""]],
		["The road crossed a ridge before turning between tall trees.",
		"You passed a junction where another road led downhill. You couldn't see where it went.",
		"Ahead, an old sign stood beside the ditch.",
		"!CROW CREEK HOLLOW"])
	s.append(c41)
	if not _made(c41, c):
		return s
	var turn: Array = {
		"look": ["The paint was flaking around the letters.", "Someone had cleared the brush from the lower half."],
		"drive": ["You checked the sign through the side window and took the turn."],
	}[c["road_pause"]]
	s.append(_page("s41_end", 4, "ridge", turn))
	var intentions: Array = {
		"security": [["fit_to_live", "\"First I'll make it fit to live in.\""], ["land_provide", "\"I'll see what the land can provide.\""],
			["one_day", "\"I'll take one day at a time.\""]],
		"work": [["own_terms", "\"I'll do what needs doing, on my terms.\""], ["one_repair", "\"I'll start with one repair.\""],
			["not_today", "\"I don't have to decide everything today.\""]],
		"household": [["new_routine", "\"There is room for a new routine.\""], ["keep_some", "\"I can keep some things from before.\""],
			["see_how", "\"I'll see how it goes.\""]],
		"curiosity": [["find_out", "\"Now I can find out what the photograph left out.\""], ["learn_land", "\"First I'll learn the land.\""],
			["no_idea", "\"I have no idea what to expect.\""]],
		"chance": [["work_next", "\"The choice is made. The work comes next.\""], ["worth_doing", "\"I can find out whether this was worth doing.\""],
			["what_i_have", "\"I'll start with what I have.\""]],
	}[origin]
	var c42 := _choice("c42", 4, "gate", "arrival_intention", "At the gate", intentions, [
		"The farmhouse appeared slowly between the trees.",
		"The roof was worse than in the photograph.",
		"Weeds stood along the path. The fence ran past the fields and disappeared into the brush.",
		"There was no one waiting at the gate.",
		"You found the latch and opened it."])
	s.append(c42)
	if not _made(c42, c):
		return s
	s.append({"kind": "arrive", "id": "arrive", "act": ACTS[4], "scene": "door", "lines": [
		"The farmhouse door was not locked.",
		"Inside was a bed, a desk, and work you would have to begin for yourself."]})
	return s


# Every choice key and its possible option ids, gathered from every road (for tests and the report).
static func all_options() -> Dictionary:
	var out := {}
	var frontier := [{}]
	while not frontier.is_empty():
		var c: Dictionary = frontier.pop_back()
		var next := next_choice(c)
		if next.is_empty():
			continue
		var key := str(next["key"])
		if not out.has(key):
			out[key] = []
		for id in option_ids(next):
			if not (out[key] as Array).has(id):
				out[key].append(id)
			var more := c.duplicate()
			more[key] = id
			frontier.append(more)
	return out
