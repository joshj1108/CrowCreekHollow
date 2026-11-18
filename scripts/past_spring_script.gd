class_name PastSpringScript
extends RefCounted

## CCH-ORIGIN-003: the words of the first spring and summer's post from the life before. The scenes are the spring
## screenplay's (AI_COLLAB/ROAD_TO_CROW_CREEK_HOLLOW_SPRING_RETURN_SCREENPLAY.md, S-A to S-E), adapted to what the
## winter actually settled (PastPost's record): AI_COLLAB/CCH_ORIGIN_003_REPORT.md lists every adaptation.
## PastSpring (scripts/past_spring.gd) keeps the state and does the work; this file is only text and its shape.
##
## variant(origin, winter) picks one route from the winter record's outcome. A route is the winter's shape
## (PastPostScript) with these additions:
##   medium        "mail" (the scene is a letter in the mailbox) or "desk" (no letter: the scene is at the desk)
##   deliver       the day the scene arrives (moved later if the winter isn't settled yet; never on day 240)
##   arrive_note   the morning report's line when it arrives
##   carrier       a parcel the winter already paid for, arriving with the first letter (received, not yet opened)
##   stages        stage id -> {title, body, received, by (a day) or within (days from when it opens), where
##                 ("mail" or "desk"), late (what happens if nothing is done, for the deadline note), choices}
##   lapse         stage id -> {text, outcome, matter, diary, sept, pay, next}: nothing done by the stage's date
##                 (text "" = nothing more comes; next = the sender's letter opens one more, final stage)
##   parcels       parcel id -> {title, note (the carrier's line), open_label, open_text, diary_came, diary_opened,
##                 sept}: a real delivery, kept in the record from promised to opened
## A choice adds to the winter's: kind "work" (paid work done at the desk: hours pass, the result is posted),
## pay (coins the sender's answer encloses, credited once), parcel (a parcel the answer sends), parcel_state (what
## the answer does to a parcel already here, e.g. "returned"), follow ({days, title, text, diary, sept, next, note}:
## a later letter, or for a desk scene a later page), sept (the factual line kept for the September passage),
## done (the line shown when a desk note is written), needs (harvest, repair, place, any, opened:<parcel>, more).
## Placeholders: {by} (the stage's date), the facts at the time of writing ({crops} {repair} {place} ...), and the
## winter's facts as they were told ({w_crops}).

const PARCEL_DAYS := 5          # a parcel the sender's answer sends arrives this many days after it


static func _r(id: String, label: String, reply: String, ack: String, outcome: Dictionary, matter: String,
		diary: String, extra: Dictionary = {}) -> Dictionary:
	var c := {"id": id, "label": label, "kind": "reply", "reply": reply, "ack": ack, "outcome": outcome,
		"matter": matter, "diary": diary, "cost": 0}
	c.merge(extra, true)
	return c


static func _note(id: String, label: String, reply: String, outcome: Dictionary, diary: String, done: String,
		extra: Dictionary = {}) -> Dictionary:
	var c := {"id": id, "label": label, "kind": "note", "reply": reply, "outcome": outcome, "matter": "closed",
		"diary": diary, "done": done}
	c.merge(extra, true)
	return c


# --- A: The Cost of a Room ----------------------------------------------------------------------------------

static func _keeper(o: OriginState) -> String:
	return str({"friend": "From your friend, who kept the boxes", "family": "From your family, who kept the boxes"}.get(
		o.contact(), "From the person who kept your boxes"))


const _BOXES := {"title": "Two boxes", "note": "The carrier brought the two boxes up the lane.",
	"open_label": "Open the two boxes",
	"open_text": "A winter coat, plates wrapped in newspaper, a few books and the kettle from the old room. Everything you packed is there.",
	"diary_came": "The two boxes came up with the carrier.",
	"diary_opened": "I opened the two boxes: the winter coat, the plates, a few books and the kettle from the old room."}


static func _a_ship(sept: String) -> Dictionary:
	return _r("ship", "Ask them to send the boxes up (30 coins)", "Please send the boxes up. I've put in 30 coins for the carrier.",
		"Your coins came. The carrier took both boxes this morning.", {"boxes": "to_ship", "paid": 30}, "arranged",
		"I wrote asking them to send the boxes up, with 30 coins for the carrier.",
		{"cost": 30, "parcel": "boxes", "ack_diary": "They wrote back. The carrier has the boxes.", "sept": sept})


static func _a_release() -> Dictionary:
	return _r("release", "Tell them to give the things away", "Please give the things to whoever can use them. You've kept them long enough.",
		"I took them to the charity shop on Saturday. The cupboard's mine again. Thank you.", {"boxes": "released"}, "closed",
		"I told them to give the things away.",
		{"ack_diary": "They wrote back. The boxes went to the charity shop.",
		"sept": "I told them they could give the boxes away. The cupboard is theirs again."})


static func _a_lapse(date: String) -> Dictionary:
	return {"text": "I didn't hear from you, and I needed the cupboard. I've taken the things to the charity shop, as I said I would. It isn't a complaint. I just couldn't keep them any longer.",
		"outcome": {"boxes": "given_away_unanswered"}, "matter": "closed",
		"diary": "I didn't answer by %s. They gave the boxes to the charity shop, as they said they would." % date,
		"sept": "I didn't answer about the boxes. They went to the charity shop in the spring."}


static func _security(o: OriginState, wo: Dictionary) -> Dictionary:
	var boxes := str(wo.get("boxes", ""))
	var shipped_sept := "I paid to bring the boxes up. I unpacked them when they came."
	match boxes:
		"to_ship":
			# The winter paid for the carriage: the boxes come, with nothing more to pay.
			return {"id": "boxes_arrived", "title": "The two boxes", "sender": _keeper(o), "deliver": 166, "carrier": "boxes",
				"arrive_note": " The carrier brought two boxes up the lane, with a letter.",
				"body": "The carrier took both boxes on Monday. He said he'd be up your way by the end of the week.\n\nThat's the cupboard empty. If anything comes to your old room, I can send it on. I'm round that way most weeks. Or we can leave it there. Either is fine.",
				"received": "The two boxes came with the carrier, and a letter from the person who kept them.",
				"parcels": {"boxes": _BOXES},
				"stages": {"first": {"within": 30, "late": "If you don't write, nothing more comes.", "choices": [
					_r("thanks", "Write that both boxes came", "Both boxes came. Thank you for keeping them all winter. There's no need to send anything on.",
						"I'm glad they got there. That's that, then.", {"boxes": "received", "keeper": "closed"}, "closed",
						"I wrote that both boxes came, and thanked them. I said there was no need to send anything on.",
						{"ack_diary": "They wrote back. That's the end of it.",
						"sept": "I paid to bring the boxes up in the winter. They came in March, and I wrote to say so."}),
					_r("send_on", "Ask them to send on anything that comes", "Both boxes came. Thank you for keeping them all winter. If anything comes for me at the old room, I'd be glad if you sent it on.",
						"I'll ask at the door until the end of summer, then. After that I'll stop.", {"boxes": "received", "keeper": "send_on", "until_day": 335}, "open",
						"I wrote that both boxes came, and asked them to send on anything that comes to the old room.",
						{"ack_diary": "They wrote back. They'll ask at the old door until the end of summer.",
						"sept": "The boxes came in March. They said they'd send on anything that came to the old room.",
						"follow": {"days": 50, "title": "Something that came for you",
							"text": "Only one thing came for you: a seed catalogue, addressed to the old room. I thought you might want it, up there.\n\nThat's all there's been.",
							"diary": "They sent on the one thing that came to the old room: a seed catalogue.",
							"sept": "The boxes came in March. Later they sent on a seed catalogue that came to the old room."}}),
				]}},
				"lapse": {"first": {"text": "", "outcome": {"boxes": "received", "keeper": "unanswered"}, "matter": "closed",
					"diary": "I didn't write back about the boxes.", "sept": "The boxes came in March. I didn't write back."}}}
		"held", "held_unanswered":
			var asked := boxes == "held"
			var choices: Array = [_a_ship(shipped_sept), _a_release()]
			var body := "It's nearly the end of April. The boxes are still in the cupboard, and I'll need it back by May, as I said.\n\nShould I send them up? The carrier is 30 coins now the road is open. Or I can give them away. Either way, I need to know by {by}."
			if not asked:
				# They gave the date themselves when no answer came; one more, bounded, month is still theirs to give.
				body = "I said I'd keep the boxes until the end of April, and it's nearly that. I haven't heard from you since the winter.\n\nI can send them up: the carrier is 30 coins now the road is open. Or I can give them away. If you need a little longer, I can manage until May 20, but no later. Let me know by {by}."
				choices.append(_r("more", "Ask them to keep the boxes until May 20", "Could you keep them until May 20? I'll know by then.", "",
					{"boxes": "held", "until_day": 232}, "awaiting_sender", "I asked them to keep the boxes until May 20.", {"next": "last"}))
			return {"id": "boxes_deadline" if asked else "boxes_deadline_unanswered", "title": "The boxes, before May",
				"sender": _keeper(o), "deliver": 190, "arrive_note": " A personal letter has come in the mailbox.",
				"body": body, "received": "The person keeping my boxes wrote. They need the cupboard back by May.",
				"parcels": {"boxes": _BOXES},
				"stages": {
					"first": {"by": 212, "late": "After that, they'll give the things away, as they said.", "choices": choices},
					"last": {"title": "The boxes, by May 20", "by": 232, "late": "After that, they'll give the things away.",
						"body": "May 20, then. That's the last I can do. Send for them or let them go, and I'll do whichever you say.",
						"received": "They wrote back: May 20, and no later.",
						"choices": [_a_ship(shipped_sept), _a_release()]},
				},
				"lapse": {"first": _a_lapse("the end of April"), "last": _a_lapse("May 20")}}
		"released":
			# The winter closed the boxes; the one thing a charity shop won't take is papers with a name on them.
			return {"id": "boxes_papers", "title": "Your papers", "sender": _keeper(o), "deliver": 190,
				"arrive_note": " A personal letter has come in the mailbox.",
				"body": "I said that was the last of it. Not quite. The charity shop took everything except your papers: the rent book and a bundle of letters. They won't take anything with a name on it.\n\nI can post them to you. It's only a stamp. Or I can put them in the stove. I don't mind which. I just don't want to keep them.",
				"received": "The person who kept my boxes wrote. The charity shop wouldn't take my papers.",
				"parcels": {"papers": {"title": "A packet of papers", "note": "A packet came in the post, addressed in the same hand as the letters.",
					"open_label": "Open the packet", "open_text": "The rent book from the old room, and the letters you kept in the drawer, tied with string.",
					"diary_came": "The packet of papers came.", "diary_opened": "I opened the packet: the old rent book and my letters, tied with string.",
					"sept": "The boxes went to the charity shop in the winter. My papers came back by post in the spring."}},
				"stages": {"first": {"within": 30, "late": "If you don't write, they'll keep the papers in a drawer.", "choices": [
					_r("post", "Ask them to post the papers", "Please post them. Thank you for doing all this.",
						"I posted them on Tuesday. That really is the last of it.", {"papers": "to_post"}, "arranged",
						"I asked them to post the papers.", {"parcel": "papers", "ack_diary": "They wrote back. The papers are in the post."}),
					_r("burn", "Tell them to burn the papers", "You can put them in the stove. I don't need them.",
						"Done. That really is the last of it.", {"papers": "burned"}, "closed", "I told them to burn the papers.",
						{"ack_diary": "They wrote back. The papers are burned.",
						"sept": "I told them the boxes could go, and the papers too. That is all closed."}),
				]}},
				"lapse": {"first": {"text": "I didn't hear, and I won't burn someone's papers without being told. They're in a drawer. Write if you want them.",
					"outcome": {"papers": "kept_by_them"}, "matter": "open",
					"diary": "I didn't answer about the papers. They're keeping them in a drawer.",
					"sept": "The boxes went to the charity shop. They kept my papers in a drawer; I never answered about them."}}}
	# No boxes were stored: the deposit on the old room (the screenplay's final account), whatever happened to the post.
	var exit := o.choice("security_exit")
	var fwd := str(wo.get("forwarding", ""))
	var opening := "You gave notice with the farm's address, so this comes to you there."
	if exit == "extension":
		opening = "When we wrote in the winter, your rent was settled. The deposit is a separate matter: the room was checked when the new tenant moved in."
	elif fwd == "renewed":
		opening = "Your post is being sent on, so this should reach you."
	var sign_sept := "The old account took another two letters. It is settled now."
	return {"id": "deposit", "title": "The deposit on your room",
		"sender": "From the letting office" if exit == "extension" else "From the landlord of your old room", "deliver": 185,
		"arrive_note": " A letter about your old room has come in the mailbox.",
		"body": "%s\n\nYour deposit was 30 coins. We have kept 6 for a new catch on the window, which was broken. That leaves 24 to return to you.\n\nSign the statement and send it back by {by}, and the 24 coins will be sent. If you think the deduction is wrong, say so and we will look again. If we hear nothing, the money stays on the account for you." % opening,
		"received": "The final statement for my old room came: 24 coins of the deposit to come back, 6 kept for a window catch.",
		"stages": {"first": {"by": 227, "late": "After that, the money stays on the account.", "choices": [
			_r("sign", "Sign the statement and send it back", "Statement signed and returned.",
				"Thank you. Your deposit of 24 coins is enclosed. The account is closed.", {"deposit": "returned", "returned": 24}, "closed",
				"I signed the statement for my old room and sent it back.",
				{"pay": 24, "ack_diary": "They wrote back with 24 coins: the deposit, less 6 for the window catch.", "sept": sign_sept}),
			_r("query", "Write that the catch was loose when you moved in", "The window catch was loose when I moved in. Please look at the check that was made then.",
				"We looked at the check from when you moved in. It says the catch was stiff, not broken. We'll share the cost: 27 coins are enclosed, and the account is closed.",
				{"deposit": "returned", "returned": 27, "queried": true}, "closed",
				"I wrote that the window catch was loose when I moved in, and asked them to look at the check made then.",
				{"pay": 27, "ack_diary": "They wrote back. The old check said the catch was stiff. They shared the cost and sent 27 coins.",
				"sept": "I questioned the deduction on the old room. They looked again and shared it. It is settled now."}),
			_note("leave", "Put the statement away unsigned", "", {"deposit": "held_on_account"},
				"I put the statement away unsigned. The 24 coins stay on the account.",
				"You put the statement away unsigned. Nothing is sent.",
				{"matter": "open", "about": "Nothing is sent. The 24 coins stay on their account, in your name.",
				"sept": "I didn't sign for the old deposit. The money is still on the account."}),
		]}},
		"lapse": {"first": {"text": "", "outcome": {"deposit": "held_on_account"}, "matter": "open",
			"diary": "I didn't answer the letter about the deposit. The money stays on the account.",
			"sept": "I didn't sign for the old deposit. The money is still on the account."}}}


# --- B: Work That Belonged to Everyone ----------------------------------------------------------------------

static func _b_take() -> Dictionary:
	return _r("take", "Take the job (3 hours' work, 20 coins)", "I'll do it. Send the March sheets up and I'll check them against the slips.", "",
		{"work": "accepted"}, "awaiting_sender", "I wrote that I'd check the March sheets for 20 coins.", {"next": "work"})


static func _b_method() -> Dictionary:
	return _r("method", "Send the method instead", "I'd rather not take the work on, but here's how I'd do it. Lay each day's slips out in order and tick each one off against the sheet. A day that comes out short usually has a slip entered twice, or not at all. Start with the Thursdays.",
		"Thank you. I'll try it on the March sheets myself.", {"work": "method"}, "resolved",
		"I wrote back with the way I'd check the sheets, rather than doing it myself.",
		{"ack_diary": "They wrote back. They'll try it on the March sheets.",
		"sept": "I sent the method back. They said they'd try it.",
		"follow": {"days": 40, "title": "The March sheets", "text": "I did the March sheets your way. It took me an afternoon, but they balance. I thought you'd want to know.",
			"diary": "They wrote later that the method worked: the March sheets balance.", "sept": "I sent the method back. They wrote later that it worked."}})


static func _b_decline() -> Dictionary:
	return _r("decline", "Decline and wish them well", "I can't take this on. I hope the quarter goes well.",
		"Understood. The manager's taking someone on for the summer. Good luck with the farm.", {"work": "declined"}, "closed",
		"I wrote that I couldn't take it on.",
		{"ack_diary": "They wrote back. Someone else will do it.", "sept": "I told them I couldn't take the job. Someone else did."})


static func _work(o: OriginState, wo: Dictionary) -> Dictionary:
	var opening := {
		"explained": "Your note about Thursday sorted it. It was a number copied twice, as you said.",
		"declined": "The manager and I went through the slips, and it was a number copied twice. I know you said you couldn't take things on, and that's fine. This is a different thing, and the manager asked me to write.",
		"sorted_without_me": "I found the Thursday problem myself in the end. It was a number copied twice.",
	}
	var book := str(wo.get("order_book", "sorted_without_me"))
	return {"id": "offer", "title": "More of the order book", "sender": "From someone at the old job", "deliver": 190,
		"arrive_note": " A personal letter has come in the mailbox.",
		"body": "%s\n\nIt's the end of the quarter now, and there's more of this. The March sheets need checking against the slips, and nobody here has the time. I could pay you 20 coins to check them. It's about three hours' work. I'd post the sheets up and you'd post them back.\n\nNo trouble if not. Let me know by {by}." % str(opening.get(book, opening["sorted_without_me"])),
		"received": "Someone from the old job wrote. They offered 20 coins to check the March sheets, about three hours' work.",
		"stages": {
			"first": {"within": 30, "late": "After that, they'll find someone else.", "choices": [
				_b_take(), _b_method(), _b_decline(),
				_r("ask", "Ask what checking them involves", "What would checking them involve, exactly?", "",
					{"work": "asked"}, "awaiting_sender", "I asked what checking the sheets would involve.", {"next": "page"}),
			]},
			# The bounded clarification: one answer, then the same three choices; no further round.
			"page": {"title": "What the checking is", "within": 21, "late": "After that, they'll find someone else.",
				"body": "It's adding up each day's slips and comparing them with the sheet, and marking any day that doesn't match. You wouldn't need to put anything right. Three hours, twenty coins, as I said.",
				"received": "They wrote back about what checking the sheets involves.",
				"choices": [_b_take(), _b_method(), _b_decline()]},
			# Paid work, once: the sheets come by post and are checked at the desk. Hours pass; the coins come back with the answer.
			"work": {"title": "The March sheets", "within": 21, "where": "desk", "late": "After that, they'll do them from their copies.",
				"body": "Here are the March sheets and the slips. Twenty coins when they come back checked. I need them back by {by}.",
				"received": "The March sheets came, with the slips.",
				"choices": [
					{"id": "do", "label": "Check the March sheets", "kind": "work", "hours": 3.0,
						"reply": "The March sheets, checked against the slips. Two days don't match; I've marked them in pencil.",
						"ack": "The sheets came back. You were right about both days. Twenty coins are enclosed, as agreed. Thank you.",
						"outcome": {"work": "paid", "paid": 20}, "matter": "resolved", "pay": 20,
						"diary": "I spent three hours checking the March sheets and posted them back.",
						"ack_diary": "They wrote back with 20 coins, as agreed.",
						"sept": "I checked the March sheets for them. They paid for my time."},
					_r("send_back", "Send them back unchecked", "I'm sorry, I can't get to these after all. The sheets are back with this letter, unchecked.",
						"That's all right. I'll do them myself.", {"work": "returned"}, "closed", "I sent the March sheets back unchecked.",
						{"ack_diary": "They wrote back. They'll do them themselves.",
						"sept": "I said I'd check the March sheets, then sent them back unchecked. They did them themselves."}),
				]},
		},
		"lapse": {
			"first": {"text": "I didn't hear back, which is fine. The manager's taking someone on for the summer.", "outcome": {"work": "unanswered"},
				"matter": "closed", "diary": "I didn't answer about the March sheets. They've taken someone on.",
				"sept": "They asked if I'd check the March sheets. I didn't answer, and someone else did."},
			"page": {"text": "I didn't hear back, which is fine. The manager's taking someone on for the summer.", "outcome": {"work": "unanswered"},
				"matter": "closed", "diary": "I didn't answer their second letter. They've taken someone on.",
				"sept": "They asked if I'd check the March sheets. I didn't answer, and someone else did."},
			"work": {"text": "I needed the sheets for the quarter, so I've done them from the carbon copies. Don't worry about it. You can put the ones I sent in the stove.",
				"outcome": {"work": "lapsed"}, "matter": "closed", "diary": "I didn't check the March sheets in time. They did them from the carbon copies.",
				"sept": "I said I'd check the March sheets, but didn't get to them. They managed."},
		}}


# --- C: A House With One Less Person ------------------------------------------------------------------------

const _HOUSE_SENDERS := {"partner": "From the person you shared the house with", "friend": "From your friend at the old house",
	"family": "From your family at the old house"}


static func _household(o: OriginState, wo: Dictionary) -> Dictionary:
	var key := str(wo.get("key", "put_away_unanswered"))
	var things := "Your things are in two boxes: your boots, a box of papers and the books that were yours. Then there are the things we had together: the clock, and the books on the long shelf."
	var ask := "I can send your boxes if you'd like them. The carrier is 20 coins. And the rest? Let me know by {by}. I'd like it settled by the summer."
	var opening := {
		"to_send": "Here is the key, wrapped so it doesn't get lost. I found it with the things we never sorted out.",
		"kept_by_them": "I put the key away as you asked. I found the other things too. Should I keep them together?",
		"let_go": "I didn't keep the key, as you said. But clearing the rest of the house, I found the things we never sorted out.",
		"put_away_unanswered": "The key is still in the tin, with the other things I found. I'm clearing the house this summer, so I need to know what you want.",
	}
	var body := "%s\n\n%s\n\n%s" % [str(opening.get(key, opening["put_away_unanswered"])), things, ask]
	if o.contact() == "former_household" and o.contact_intent() == "boundaries":
		body += " A line will do."
	var v := {"id": "things", "title": "The things we never sorted out",
		"sender": str(_HOUSE_SENDERS.get(o.household_sender(), "From someone at the house you left")),
		"deliver": 175 if key == "to_send" else 190,
		"arrive_note": " A small parcel has come with a letter." if key == "to_send" else " A personal letter has come in the mailbox.",
		"body": body, "received": "A letter came from the house I left, about the things we never sorted out.",
		"parcels": {
			"key": {"title": "The key", "note": "", "open_label": "Unwrap the key",
				"open_text": "A small brass key, wrapped in a piece of cloth. It doesn't open anything here.",
				"diary_came": "The key came with the letter, in a small parcel.", "diary_opened": "I unwrapped the key. It was wrapped in a piece of cloth."},
			"house_boxes": {"title": "Two boxes from the old house", "note": "The carrier brought two boxes up the lane, from the old house.",
				"open_label": "Open the boxes", "open_text": "Your boots, a box of papers, and the books that were yours. Nothing else.",
				"diary_came": "The carrier brought my two boxes from the old house.",
				"diary_opened": "I opened the boxes from the old house: my boots, my papers and my books.",
				"sept": "We decided who would keep what. My boxes came in the spring; they kept the clock and the shelf books."},
		},
		"stages": {"first": {"within": 35, "late": "If you don't write, they'll keep your boxes where they are.", "choices": [
			_r("send_mine", "Ask for your boxes (20 coins)",
				"Please send my two boxes. I've put in 20 coins for the carrier. Keep the clock and the books from the long shelf.",
				"They went with the carrier this morning. I'll keep the clock and the shelf books, then.",
				{"belongings": "sent", "shared": "theirs"}, "arranged",
				"I asked them to send my two boxes, with 20 coins for the carrier, and to keep the clock and the shelf books.",
				{"cost": 20, "parcel": "house_boxes", "ack_diary": "They wrote back. My boxes went with the carrier.",
				"sept": "We decided who would keep what. They kept the clock and the shelf books, and sent my boxes."}),
			_r("write", "Keep in touch; they keep it all for now",
				"Keep the clock and the books, and my boxes too, for now. There's no room for them here yet. I'd like to write now and then, if you would.",
				"All right. Now and then suits me.", {"belongings": "kept_by_them", "correspondence": "now_and_then"}, "open",
				"I asked them to keep everything for now, and said I'd like to write now and then.",
				{"ack_diary": "They wrote back. Now and then suits them.", "sept": "We agreed to write now and then.",
				"follow": {"days": 100, "title": "A letter from the old house",
					"text": "Nothing much to tell. The plum tree over the back fence is heavy this year, more than last. Your boxes are in the hall cupboard. Write when you like.",
					"diary": "They wrote again, about ordinary things. My boxes are in their hall cupboard.",
					"sept": "We still exchange letters now and then, about ordinary things."}}),
			_r("close", "Settle it and close the matter",
				"Keep the clock and the books. Give my boxes away, or keep anything you want from them. I think that's everything between us now.",
				"All right. I'll take the boxes to the charity shop and keep the clock. That's everything.",
				{"belongings": "given_up", "shared": "theirs", "correspondence": "closed"}, "closed",
				"I wrote that they could keep the clock and the books, and give my boxes away. I said that was everything.",
				{"ack_diary": "They wrote back. That's everything.",
				"sept": "We decided who would keep the clock and the books. That was the last thing left."}),
			_r("time", "Ask for more time", "Could you keep everything until the autumn? I'll know by then.",
				"Until the end of September, then. I'll keep it together until then. After that I'd like it gone.",
				{"belongings": "held", "until_day": 365}, "pending", "I asked them to keep everything until the autumn.",
				{"ack_diary": "They wrote back. They'll keep it all until the end of September.",
				"sept": "I asked for more time. They agreed until autumn."}),
		]}},
		"lapse": {"first": {"text": "I haven't heard, and that's all right. I'll keep your boxes in the hall cupboard. The clock I'll keep.",
			"outcome": {"belongings": "kept_unanswered"}, "matter": "open",
			"diary": "I didn't answer about the things. They're keeping my boxes in their hall cupboard.",
			"sept": "I didn't answer about the things at the old house. They're keeping my boxes."}}}
	if key == "to_send":
		v["carrier"] = "key"   # the winter's promise: the key comes with this letter, in a small parcel
	return v


# --- D: The Place in the Photograph -------------------------------------------------------------------------

static func _curiosity(o: OriginState, wo: Dictionary, wf: Dictionary) -> Dictionary:
	if o.has_contact():
		var told := str(wo.get("told", "unanswered"))
		var opening := {
			"crops": "I keep thinking about the %s you wrote about." % str(wf.get("crops", "crops")),
			"repair": "You wrote that there was work to do on the house. I hope the roof held through the winter.",
			"woods": "You wrote about the woods. I hope you haven't got lost in them.",
			"unsaid": "You said you'd tell me more when you could. It's spring now, so I'm asking again.",
			"unanswered": "I didn't hear back in the winter, and that's all right. I'll ask once more, and then I'll leave it.",
		}
		var body := "%s\n\nWhat's it like, now the winter's over? Tell me one thing you've found there. Something the picture left out." % str(opening.get(told, opening["unanswered"]))
		if o.contact_intent() == "boundaries":
			body += " You don't have to answer."
		var senders := {"friend": "From your friend, who saw you off", "family": "From your family, who saw you off"}
		return {"id": "friend", "title": "What the picture left out", "sender": str(senders.get(o.contact(), "From the person who saw you off")),
			"deliver": 195, "arrive_note": " A personal letter has come in the mailbox.", "body": body,
			"received": "The person who saw me off wrote again, asking for one thing the picture left out.",
			"stages": {"first": {"within": 30, "late": "If you don't write, nothing more comes.", "choices": [
				_r("crops", "Write about what you've grown", "I've been bringing in {crops} from the field beside the house.",
					"So the field grows {crops}. The picture made it look as if nothing would grow there at all.", {"told": "crops"}, "resolved",
					"I wrote about the {crops} I've grown.", {"needs": "harvest", "ack_diary": "They wrote back about the {crops}.",
					"sept": "I wrote to them about the {crops} I'd grown."}),
				_r("repair", "Write about a repair you've done", "{repair}", "{repair_ack}", {"told": "repair"}, "resolved",
					"I wrote about the work: {repair_short}.", {"needs": "repair", "ack_diary": "They wrote back about the work.",
					"sept": "I wrote to them about the work: {repair_short}."}),
				_r("place", "Write about a place you've been", "{place}", "{place_ack}", {"told": "place"}, "resolved",
					"I wrote about {place_short}.", {"needs": "place", "ack_diary": "They wrote back about {place_short}.",
					"sept": "I wrote to them about {place_short}."}),
				_r("unsaid", "Say you'd rather not describe it yet", "I'd rather not describe it yet. I'm still getting to know it.",
					"That's fair. I'll stop asking. Write when you want to.", {"told": "not_yet"}, "open",
					"I wrote that I'd rather not describe it yet.", {"ack_diary": "They wrote back. They'll stop asking.",
					"sept": "I wrote that I'd rather not describe the place yet."}),
				_r("wrong", "Say it isn't what you expected", "It isn't what I thought it would be. I'm still working out what it is.",
					"Most things aren't. Tell me when you've worked it out.", {"told": "not_expected"}, "open",
					"I wrote that it isn't what I thought it would be.", {"ack_diary": "They wrote back: tell them when I've worked it out.",
					"sept": "I wrote that the place isn't what I expected."}),
			]}},
			"lapse": {"first": {"text": "", "outcome": {"told": "unanswered_spring"}, "matter": "open",
				"diary": "I didn't answer their spring letter.", "sept": "They wrote in the winter and the spring. I didn't answer the spring letter."}}}
	# No one saw them off: no letter. The photograph and the diary, at the desk, are the scene.
	var noted := str(wo.get("noted", "unread_or_left"))
	var before := {
		"crops": "Your winter note is still beside it.", "repair": "Your winter note is still beside it.",
		"woods": "Your winter note is still beside it.", "wrote_office": "The town office's correction is folded in with it.",
		"kept": "The town office's correction is folded in with it.",
	}
	var body := "The photograph from the notice was folded along the roofline. You set it beside a newer page in the diary. %s\n\nThe roof was still there. In the picture, the fence hadn't been fixed in years, and the open ground beside the house was empty." % str(before.get(noted, ""))
	var summer := {"title": "The photograph, again", "within": 60, "where": "desk",
		"body": "The photograph is still in the diary, with your earlier note beside it.",
		"choices": [
			_note("more", "Add what has been brought in since", "Since I last wrote here, I've brought in {more} more crops.",
				{"photo": "annotated_twice"}, "I added a line beside the photograph: {more} more crops brought in since my last note.",
				"You add a line beside the photograph.", {"needs": "more", "sept": "I wrote beside the photograph twice: once in the spring, and again later."}),
			_note("leave", "Leave it as it is", "", {"photo": "left_in_summer"}, "I looked at the photograph again and left it as it was.",
				"You close the diary on the photograph.", {"about": "Nothing is written."}),
		]}
	var later := {"days": 90, "next": "summer", "note": " The photograph is still in the diary, with your note beside it."}
	return {"id": "photograph", "title": "The photograph", "sender": "", "medium": "desk", "deliver": 190,
		"arrive_note": " The photograph from the notice has slipped out of the diary in the desk.", "body": body,
		"received": "", "stages": {
			"first": {"by": 335, "where": "desk", "choices": [
				_note("compare", "Compare it with the farm now", "Beside the photograph I wrote what is different now: {compare}.",
					{"photo": "compared"}, "I wrote beside the photograph what is different now: {compare}.",
					"You write beside the photograph what is different now.",
					{"needs": "any", "follow": later, "sept": "I kept the advertisement. Beside it I wrote what had changed since I came."}),
				_note("left_out", "Write what the picture left out", "Beside the photograph I wrote what it left out: the sound of the wind at the back fence.",
					{"photo": "left_out"}, "I wrote beside the photograph what it left out: the sound of the wind at the back fence.",
					"You write beside the photograph what it left out.",
					{"follow": later, "sept": "I kept the photograph. I wrote down what it left out."}),
				_note("keep", "Fold it back into the diary without writing", "", {"photo": "kept"},
					"I folded the photograph back into the diary and wrote nothing beside it.", "You fold the photograph back into the diary.",
					{"about": "Nothing is written. The photograph goes back between the pages.",
					"sept": "I kept the advertisement. It showed the house before I arrived."}),
			]},
			"summer": summer,
		},
		"lapse": {"first": {"text": "", "outcome": {"photo": "untouched"}, "matter": "closed", "diary": "", "sept": ""},
			"summer": {"text": "", "outcome": {}, "matter": "closed", "diary": "", "sept": ""}}}


# --- E: A Chance Before It Closed ---------------------------------------------------------------------------

const _UNIT := {"title": "The unit's contents", "note": "The carrier brought the contents of the storage unit up the lane.",
	"open_label": "Open the cartons", "open_text": "It's what you left in the unit, packed the way you packed it.",
	"diary_came": "The carrier brought the contents of the storage unit.", "diary_opened": "I opened the cartons from the storage unit.",
	"sept": "The storage unit came through. I had it sent to the farm."}
const _ORDER := {"title": "Your order", "note": "The carrier brought the parcel from the shop.",
	"open_label": "Unwrap the order", "open_text": "It's the thing you ordered before you left, wrapped in the shop's paper.",
	"diary_came": "The carrier brought my order from the shop.", "diary_opened": "I unwrapped the order.",
	"sept": "The old order came through. I had it sent to the farm."}


static func _e_send(cost: int, sept: String) -> Dictionary:
	return _r("send", "Have the contents sent on (%d coins)" % cost, "Please send the contents on to the farm. %d coins enclosed for the carrier." % cost,
		"Received. The contents have gone with the carrier, and your unit is closed.", {"storage": "to_ship", "paid": cost}, "arranged",
		"I paid %d coins to have the unit's contents sent up." % cost,
		{"cost": cost, "parcel": "unit", "ack_diary": "They wrote back. The contents are with the carrier.", "sept": sept})


static func _e_clear() -> Dictionary:
	return _r("clear", "Ask them to clear it", "Please clear the unit and close the account. I won't need what's in it.",
		"The unit is cleared and the account closed. Nothing more is owed.", {"storage": "cleared"}, "closed",
		"I asked them to clear the unit and close the account.",
		{"ack_diary": "They wrote back. The unit is cleared and nothing is owed.", "sept": "I let the storage unit go. They cleared it."})


static func _e_cleared_lapse(date: String) -> Dictionary:
	return {"text": "The contents of your unit were cleared on %s, as we wrote. Nothing is owed. The account is closed." % date,
		"outcome": {"storage": "cleared_unanswered"}, "matter": "closed",
		"diary": "I didn't answer the storage yard. They cleared the unit on %s." % date,
		"sept": "I didn't answer the storage yard. They cleared the unit."}


static func _chance(o: OriginState, wo: Dictionary) -> Dictionary:
	match o.choice("chance_loose_end"):
		"work_offer":
			if str(wo.get("offer", "")) == "on_list":
				return {"id": "work_list", "title": "Next season's list", "sender": "From the people who offered you seasonal work", "deliver": 306,
					"arrive_note": " A letter about seasonal work has come in the mailbox.",
					"body": "As we said we would, we're writing because the list for next season is open. Your name is on it.\n\nThe places run from October, for six weeks, and they're being filled now. If you'd like one, write by {by} and say when you could start. If not, there's no need to answer. Your name can stay on the list for another year, or come off.",
					"received": "The people who offered me seasonal work wrote. Next season's list is open.",
					"stages": {"first": {"by": 324, "late": "If you don't write, the places are filled without you.", "choices": [
						_r("not_this_year", "Say not this year, and stay on the list", "I can't come this season. Please keep my name on the list.",
							"Your name stays on for next year. We'll write again in August.", {"offer": "on_list", "until_day": 670}, "open",
							"I wrote that I can't come this season, and asked them to keep my name on the list.",
							{"ack_diary": "They wrote back. My name stays on the list for next year.",
							"sept": "I stayed on their list for seasonal work. I didn't take a place this year."}),
						_r("off", "Take your name off the list", "Please take my name off the list. Thank you for holding it.",
							"Done. Good luck with the farm.", {"offer": "off_list"}, "closed", "I asked them to take my name off the list.",
							{"ack_diary": "They wrote back. My name is off the list.", "sept": "I took my name off the list for seasonal work."}),
					]}},
					"lapse": {"first": {"text": "", "outcome": {"offer": "list_lapsed"}, "matter": "closed",
						"diary": "I didn't answer the letter about the list. The places were filled.",
						"sept": "My name was on the seasonal list. I didn't answer, and the places were filled."}}}
			var filled := str(wo.get("offer", "")) != "closed"
			return {"id": "work_closed", "title": "The seasonal place, filled", "sender": "From the people who offered you seasonal work",
				"deliver": 195, "arrive_note": " A letter about seasonal work has come in the mailbox.",
				"body": "We wrote in the winter and didn't hear back, which is fine. The place was filled, and the person has stayed on.\n\nIf you're ever looking for seasonal work, you're welcome to write." if filled else
					"We hired someone in February. The work is going well. Thank you for your reply in the winter.\n\nThe offer can't be held, but you're welcome to write in future.",
				"received": "The people who offered me seasonal work wrote. The place is filled, and the person is staying on.",
				"stages": {"first": {"within": 30, "late": "There's no need to answer.", "choices": [
					_r("thank", "Thank them, and leave it there", "Thank you for letting me know. I won't be needing the place.",
						"Noted. All the best.", {"offer": "closed"}, "closed", "I wrote to thank them, and left it there.",
						{"ack_diary": "They wrote back: all the best.", "sept": "They filled the job. I wrote back and closed the matter."}),
					_r("keep_in_touch", "Ask them to write if a place comes up", "If a place comes up another year, I'd be glad to hear. I can't promise I'll take it.",
						"We'll put your name on the list for next year. We write in August.", {"offer": "on_list", "until_day": 670}, "open",
						"I asked them to write if a place comes up another year.",
						{"ack_diary": "They wrote back. My name is on next year's list.", "sept": "They filled the job. I asked them to write if another place comes up."}),
					_r("no_more", "Ask them not to write again", "Please take my name off your lists. I won't be looking for seasonal work.",
						"Done. Good luck.", {"offer": "off_list"}, "closed", "I asked them not to write again.",
						{"ack_diary": "They wrote back. My name is off their lists.", "sept": "They filled the job. I asked them not to write again."}),
				]}},
				"lapse": {"first": {"text": "", "outcome": {"offer": "let_go"}, "matter": "closed", "diary": "I didn't answer their note.",
					"sept": "They filled the job. I let it go."}}}
		"storage":
			var storage := str(wo.get("storage", ""))
			match storage:
				"to_ship":
					return {"id": "storage_arrived", "title": "The unit's contents", "sender": "From the storage yard", "deliver": 166, "carrier": "unit",
						"arrive_note": " The carrier brought the storage unit's contents up the lane, with a note.",
						"body": "The carrier has brought the contents of your unit up to you. Your account was closed in the winter, and nothing more is owed.\n\nThe carrier says he comes back up this way at the end of the month. If there's anything you'd like taken down to the charity shop, he'll take it for nothing.",
						"received": "The contents of my storage unit came up with the carrier.",
						"parcels": {"unit": _UNIT},
						"stages": {"first": {"within": 21, "late": "If you do nothing, you keep it all.", "choices": [
							_note("keep", "Keep everything", "", {"unit": "kept"}, "I kept everything from the unit.", "You keep everything from the unit.",
								{"needs": "opened:unit", "about": "Everything stays with you.", "sept": "The storage unit came through. I kept everything."}),
							_r("give_some", "Send some of it to the charity shop", "For the charity shop, with thanks. I've kept the rest.",
								"Received with thanks: one carton of household goods. From the charity shop.", {"unit": "gave_some"}, "closed",
								"I left one carton by the gate for the carrier to take down to the charity shop.",
								{"needs": "opened:unit", "ack_diary": "The charity shop sent a receipt for the carton.",
								"sept": "The storage unit came through. I kept some of it and gave the rest to the charity shop."}),
							_r("give_all", "Send all of it to the charity shop", "For the charity shop, with thanks.",
								"Received with thanks: three cartons of household goods. From the charity shop.", {"unit": "gave_all"}, "closed",
								"I left all the cartons by the gate for the carrier to take down to the charity shop.",
								{"needs": "opened:unit", "ack_diary": "The charity shop sent a receipt for the cartons.",
								"sept": "The storage unit came through, and I gave all of it to the charity shop."}),
						]}},
						"lapse": {"first": {"text": "", "outcome": {"unit": "kept"}, "matter": "closed", "diary": "",
							"sept": "The storage unit came through. I had it sent to the farm and kept it."}}}
				"renewed":
					return {"id": "storage_renewed", "title": "Your unit, end of May", "sender": "From the storage yard", "deliver": 222,
						"arrive_note": " A letter from the storage yard has come in the mailbox.",
						"body": "Your unit is paid to the end of the month. Let me know whether to forward the remaining contents or close it.\n\nCarriage is 30 coins. Clearing it costs nothing. If you need a little longer, we can let it run one more month, to the end of June, for 5 coins, but we can't go past that.",
						"received": "The storage yard wrote. The unit is paid to the end of May.",
						"parcels": {"unit": _UNIT},
						"stages": {
							"first": {"by": 243, "late": "After that, the contents are held for thirty days and then cleared, as their terms say.", "choices": [
								_e_send(30, _UNIT["sept"]), _e_clear(),
								_r("month", "Let it run one more month (5 coins)", "Please let the unit run to the end of June. 5 coins enclosed.", "",
									{"storage": "renewed", "until_day": 273, "paid": 5}, "awaiting_sender", "I paid 5 coins to keep the unit to the end of June.",
									{"cost": 5, "next": "last"}),
							]},
							"last": {"title": "Your unit, end of June", "by": 273, "late": "After that, the contents are cleared.",
								"body": "Received. Your unit is paid to the end of June. That is as far as we can go: please tell us by then whether to send the contents or clear them.",
								"received": "They wrote back. The unit is paid to the end of June, and no further.",
								"choices": [_e_send(30, _UNIT["sept"]), _e_clear()]},
							"held": {"title": "Your unit, not renewed", "by": 273, "late": "After that, the contents are cleared.",
								"received": "The storage yard wrote. The unit wasn't renewed; the contents are held until the end of June.",
								"choices": [_e_send(30, _UNIT["sept"]), _e_clear()]},
						},
						"lapse": {
							"first": {"text": "Your unit was not renewed. As our terms say, the contents are held for thirty days, until {by}, and then cleared. Write before then if you want them sent.",
								"outcome": {"storage": "held_unanswered", "until_day": 273}, "matter": "pending", "next": "held",
								"diary": "I didn't answer by the end of May. They'll hold the contents until the end of June."},
							"last": _e_cleared_lapse("June 30"), "held": _e_cleared_lapse("June 30"),
						}}
				"held_unanswered":
					return {"id": "storage_held", "title": "Your unit's contents", "sender": "From the storage yard", "deliver": 160,
						"arrive_note": " A letter from the storage yard has come in the mailbox.",
						"body": "As we wrote, your unit was not renewed, and the contents are held until {by}. After that they will be cleared.\n\nWe can still send them on, for 30 coins. Or we can clear them now. If you need a little longer, we can hold them to the end of April for 5 coins, but no later.",
						"received": "The storage yard wrote again. The contents are held until March 30.",
						"parcels": {"unit": _UNIT},
						"stages": {
							"first": {"by": 181, "late": "After that, the contents are cleared.", "choices": [
								_e_send(30, _UNIT["sept"]), _e_clear(),
								_r("hold", "Ask them to hold it to the end of April (5 coins)", "Please hold the contents to the end of April. 5 coins enclosed.", "",
									{"storage": "held", "until_day": 212, "paid": 5}, "awaiting_sender", "I paid 5 coins to have the contents held to the end of April.",
									{"cost": 5, "next": "last"}),
							]},
							"last": {"title": "Your unit, end of April", "by": 212, "late": "After that, the contents are cleared.",
								"body": "Received. The contents are held to the end of April, and no later. Please tell us by then whether to send them or clear them.",
								"received": "They wrote back. The contents are held to the end of April, and no later.",
								"choices": [_e_send(30, _UNIT["sept"]), _e_clear()]},
						},
						"lapse": {"first": _e_cleared_lapse("March 30"), "last": _e_cleared_lapse("April 30")}}
			# Cleared in the winter: the yard won't dispose of personal papers without the owner's word.
			return {"id": "storage_cleared", "title": "Papers from your unit", "sender": "From the storage yard", "deliver": 190,
				"arrive_note": " A letter from the storage yard has come in the mailbox.",
				"body": "When we cleared your unit we found a folder of papers with your name on them. We don't dispose of personal papers without the owner's word.\n\nWe can post them to you, free of charge, or shred them. Please let us know by {by}. If we don't hear, we'll shred them then.",
				"received": "The storage yard wrote. They found a folder of my papers when they cleared the unit.",
				"parcels": {"folder": {"title": "A folder of papers", "note": "A folder of papers came in the post, from the storage yard.",
					"open_label": "Open the folder", "open_text": "Your papers from the unit, in the order you left them.",
					"diary_came": "The folder of papers came from the storage yard.", "diary_opened": "I opened the folder of papers from the unit.",
					"sept": "I let the storage unit go in the winter. They posted my papers back in the spring."}},
				"stages": {"first": {"within": 30, "late": "After that, they'll shred them.", "choices": [
					_r("post", "Ask them to post the papers", "Please post them to the farm. Thank you.",
						"The folder is in the post.", {"papers": "to_post"}, "arranged", "I asked the storage yard to post the papers.",
						{"parcel": "folder", "ack_diary": "They wrote back. The folder is in the post."}),
					_r("shred", "Ask them to shred the papers", "Please shred them. I don't need them.",
						"The papers are shredded. The account is closed.", {"papers": "shredded"}, "closed", "I asked them to shred the papers.",
						{"ack_diary": "They wrote back. The papers are shredded.", "sept": "I let the storage unit go, and the last of the papers too."}),
				]}},
				"lapse": {"first": {"text": "We didn't hear from you, so the papers were shredded, as we said. The account is closed.",
					"outcome": {"papers": "shredded_unanswered"}, "matter": "closed",
					"diary": "I didn't answer the storage yard about the papers. They shredded them.",
					"sept": "I let the storage unit go. The last papers were shredded when I didn't answer."}}}
		"order":
			var order := str(wo.get("order", ""))
			match order:
				"to_ship":
					return {"id": "order_arrived", "title": "Your order", "sender": "From the shop where you left an order", "deliver": 166, "carrier": "order",
						"arrive_note": " The carrier brought the parcel from the shop, with a note.",
						"body": "Your order has gone up with the carrier, paid in full. Thank you.\n\nIf it isn't what you wanted, you can send it back by {by} for a refund of its price, 30 coins. The carriage back is yours to pay: 6 coins.",
						"received": "My order came up with the carrier, paid in full.",
						"parcels": {"order": _ORDER},
						"stages": {"first": {"within": 30, "late": "After that, the order is yours to keep.", "choices": [
							_note("keep", "Keep it", "", {"order": "kept"}, "I kept the order.", "You keep the order.",
								{"about": "Nothing is sent. The order is yours.", "sept": _ORDER["sept"]}),
							_r("return", "Send it back for a refund (6 coins carriage, 30 back)", "I'm returning the order. 6 coins are enclosed for the carriage.",
								"The order came back to us. Your refund of 30 coins is enclosed.", {"order": "returned"}, "closed",
								"I sent the order back, with 6 coins for the carriage.",
								{"cost": 6, "pay": 30, "parcel_state": "returned", "ack_diary": "They wrote back with the refund of its price, 30 coins.",
								"sept": "The old order came, and I sent it back. They refunded its price."}),
						]}},
						"lapse": {"first": {"text": "", "outcome": {"order": "kept"}, "matter": "closed", "diary": "", "sept": _ORDER["sept"]}}}
				"refunded":
					return {"id": "order_resale", "title": "The item you cancelled", "sender": "From the shop where you left an order", "deliver": 195,
						"arrive_note": " A letter from the shop has come in the mailbox.",
						"body": "You cancelled your order in the winter, and your deposit went back to you. The item is still with us, unsold.\n\nIf you'd still like it, we can send it for 20 coins, carriage included, which is less than it was. If not, there's no need to reply. The offer stands until {by}.",
						"received": "The shop wrote. The item I cancelled is still unsold; they offered it for 20 coins.",
						"parcels": {"order": _ORDER},
						"stages": {"first": {"within": 30, "late": "There's no need to answer.", "choices": [
							_r("buy", "Buy it after all (20 coins)", "I'd like it after all. 20 coins enclosed.",
								"Received with thanks. It has gone with the carrier.", {"order": "bought_later", "paid": 20}, "arranged",
								"I paid 20 coins for the item I'd cancelled.",
								{"cost": 20, "parcel": "order", "ack_diary": "They wrote back. It's with the carrier.",
								"sept": "I cancelled the old order in the winter, then bought it in the spring for less."}),
							_r("no", "Say no, thank you", "No, thank you. I won't need it.", "Thank you for letting us know.", {"order": "declined_offer"}, "closed",
								"I wrote that I didn't want it.", {"ack_diary": "They wrote back. That's the end of it.",
								"sept": "I cancelled the old order and got my deposit back. That was the end of it."}),
						]}},
						"lapse": {"first": {"text": "", "outcome": {"order": "closed"}, "matter": "closed", "diary": "I didn't answer the shop's offer.",
							"sept": "I cancelled the old order and got my deposit back. That was the end of it."}}}
			# Held to the end of April (asked for, or the shop's own terms): delivery, refund or collection.
			var opening := "We wrote in March that we'd hold your order until the end of April. " if order == "held_unanswered" else ""
			return {"id": "order_held", "title": "Your order, by April 30", "sender": "From the shop where you left an order", "deliver": 190,
				"arrive_note": " A letter from the shop has come in the mailbox.",
				"body": "%sThe item has arrived and is still held for you. Please confirm delivery or request the refund by {by}.\n\nThe balance and carriage come to 24 coins. Or we can cancel it and return your deposit of 12 coins. If you'd rather collect it yourself one day, we can keep it in the back until the end of September for 4 coins." % opening,
				"received": "The shop wrote. My order is held for me until April 30.",
				"parcels": {"order": _ORDER},
				"stages": {"first": {"by": 212, "late": "After that, the order is cancelled and the deposit returned, as they said.", "choices": [
					_r("send", "Have it sent (24 coins)", "Please send it on to the farm. The balance and carriage, 24 coins, are enclosed.",
						"Received with thanks. Your order has gone with the carrier.", {"order": "to_ship", "paid": 24}, "arranged",
						"I paid the 24 coins to have the order sent up.",
						{"cost": 24, "parcel": "order", "ack_diary": "They wrote back. The order is with the carrier.", "sept": _ORDER["sept"]}),
					_r("refund", "Cancel it; ask for the deposit back", "Please cancel the order and return my deposit.",
						"Your order is cancelled. Your deposit of 12 coins is enclosed.", {"order": "refunded", "returned": 12}, "closed",
						"I cancelled the order and asked for my deposit back.",
						{"pay": 12, "ack_diary": "They wrote back with my deposit, 12 coins.", "sept": "I cancelled the old order in the spring. They sent my deposit back."}),
					_r("collect", "Ask them to keep it for collection (4 coins)", "Please keep it for me to collect. 4 coins enclosed.",
						"It's in the back with your name on it, until the end of September.", {"order": "for_collection", "until_day": 365, "paid": 4}, "pending",
						"I paid 4 coins to have the order kept for me to collect, until the end of September.",
						{"cost": 4, "ack_diary": "They wrote back. It's kept for me until the end of September.",
						"sept": "My old order is kept at the shop for me to collect, until the end of September."}),
				]}},
				"lapse": {"first": {"text": "As we wrote, your order has been cancelled. Your deposit of 12 coins is enclosed.", "pay": 12,
					"outcome": {"order": "cancelled_unanswered", "returned": 12}, "matter": "closed",
					"diary": "I didn't answer the shop by the end of April. They cancelled the order and sent my deposit back, 12 coins.",
					"sept": "I didn't answer the shop. They cancelled the order and sent my deposit back."}}}
		"meeting":
			var meeting := str(wo.get("meeting", ""))
			var sender := "From the person you'd agreed to meet"
			var purpose := _r("purpose", "Say you'd meant to tell them you might move away",
				"I'd wanted to tell you in person that I might move away. I did, sooner than I said. I'm sorry it came by letter.",
				"I wondered if it was that. Thank you for telling me. I hope it's going well.", {"meeting": "purpose_told"}, "closed",
				"I wrote what the meeting had been for: I'd meant to tell them in person that I might move away.",
				{"ack_diary": "They wrote back. They'd wondered if it was that.",
				"sept": "I wrote what the meeting had been for. They wrote back that they'd wondered."})
			if meeting == "spring":
				return {"id": "meeting_spring", "title": "About April", "sender": sender, "deliver": 185,
					"arrive_note": " A personal letter has come in the mailbox.",
					"body": "I said I'd write with a day in April. The trouble is, I'm away from the start of May until the autumn, so it would have to be a Saturday this month, here. I know that's a long way for you.\n\nIf it can't be April, tell me what you wanted to talk about, and I'll write back. Or we can leave it. Let me know by {by}.",
					"received": "The person I'd agreed to meet wrote. It would have to be a Saturday in April, and they're away after that.",
					"stages": {"first": {"within": 14, "late": "After that, they're away until the autumn.", "choices": [
						_r("autumn", "Say April is too far; ask about the autumn", "April is too far for me to come. Could we try when you're back in the autumn?",
							"The autumn, then. I'll write when I'm back. I can't promise the day will suit.", {"meeting": "autumn"}, "open",
							"I wrote that April was too far, and asked about the autumn.",
							{"ack_diary": "They wrote back. They'll write when they're back in the autumn.",
							"sept": "We agreed to speak again. We haven't chosen a day."}),
						purpose,
						_r("leave", "Leave it there", "April won't work, and I don't know when I'll be back that way. Let's leave it.",
							"All right. Thank you for writing.", {"meeting": "closed"}, "closed", "I wrote that April wouldn't work, and left it there.",
							{"ack_diary": "They wrote back: thank you for writing.", "sept": "We didn't find a day to meet. I wrote and left it there."}),
					]}},
					"lapse": {"first": {"text": "I didn't hear back, so I'll take it April doesn't suit. I'm away now until the autumn.",
						"outcome": {"meeting": "lapsed_spring"}, "matter": "closed", "diary": "I didn't answer about April. They're away until the autumn.",
						"sept": "They offered a day in April. I didn't answer."}}}
			if meeting == "lapsed":
				return {"id": "meeting_lapsed", "title": "Once more", "sender": sender, "deliver": 195,
					"arrive_note": " A personal letter has come in the mailbox.",
					"body": "I wrote in the winter and didn't hear back. I'll write once more, and then I'll leave it.\n\nIf you want to talk, write with a day that suits you. I can't promise I'll be free.",
					"received": "The person I'd agreed to meet wrote once more.",
					"stages": {"first": {"within": 30, "late": "If you don't write, they'll leave it.", "choices": [
						_r("autumn", "Suggest trying in the autumn", "I'm a long way off now. Could we try in the autumn?",
							"The autumn might work. I'll write then. I can't promise.", {"meeting": "autumn"}, "open",
							"I wrote asking if we could try in the autumn.",
							{"ack_diary": "They wrote back. They'll write in the autumn.", "sept": "We agreed to speak again. We haven't chosen a day."}),
						purpose,
						_r("leave", "Leave it there", "I'm a long way off now, and I can't come. Let's leave it there.",
							"All right. Thank you for writing.", {"meeting": "closed"}, "closed", "I wrote that I couldn't come, and left it there.",
							{"ack_diary": "They wrote back: thank you for writing.", "sept": "We didn't meet. I wrote once and left it there."}),
					]}},
					"lapse": {"first": {"text": "", "outcome": {"meeting": "lapsed_twice"}, "matter": "closed", "diary": "I didn't answer their second letter.",
						"sept": "They wrote twice about the meeting. I didn't answer."}}}
			# Closed in the winter: they don't reopen it. Their own life moves on, and they say so once.
			return {"id": "meeting_closed", "title": "A new address", "sender": sender, "deliver": 195,
				"arrive_note": " A personal letter has come in the mailbox.",
				"body": "You wrote in the winter that you'd leave it there, and that's fine. I'm only writing because I'm moving in June, and I didn't want a letter of yours to go astray. This is my new address.\n\nNo need to answer.",
				"received": "The person I'd agreed to meet wrote. They're moving in June, and sent their new address.",
				"stages": {"first": {"within": 30, "late": "There's no need to answer.", "choices": [
					_r("wish", "Write back with good wishes for the move", "Thank you for the address. I hope the move goes well.",
						"Thank you. The same to you, up there.", {"address": "kept", "wrote": true}, "closed",
						"I wrote back with good wishes for their move, and kept the address.",
						{"ack_diary": "They wrote back: the same to me.", "sept": "We never met. They moved in June; I wished them well, and kept the address."}),
					_note("keep", "Keep the address", "", {"address": "kept"}, "I kept their new address.", "You keep the address.",
						{"about": "Nothing is sent. The address goes in the back of the diary.", "sept": "We never met. They moved in June. I kept their address."}),
					_note("discard", "Don't keep it", "", {"address": "not_kept"}, "I didn't keep their new address.", "You put the letter on the fire.",
						{"about": "Nothing is sent. The letter goes on the fire.", "sept": "We never met. They moved in June, and I didn't keep the address."}),
				]}},
				"lapse": {"first": {"text": "", "outcome": {"address": "unanswered"}, "matter": "closed", "diary": "", "sept": "We never met. They moved in June."}}}
	return {}


# The spring route for this origin and the winter's record, or {} when there is none (legacy, none, missed).
static func variant(o: OriginState, winter: Dictionary) -> Dictionary:
	var wo: Dictionary = winter.get("outcome", {})
	var wf: Dictionary = winter.get("facts", {})
	var v := {}
	match o.origin():
		"security":
			v = _security(o, wo)
		"work":
			v = _work(o, wo)
		"household":
			v = _household(o, wo)
		"curiosity":
			v = _curiosity(o, wo, wf)
		"chance":
			v = _chance(o, wo)
	if not v.is_empty():
		for key in ["medium", "parcels", "lapse"]:
			if not v.has(key):
				v[key] = "mail" if key == "medium" else {}
	return v
