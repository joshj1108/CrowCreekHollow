class_name PastPostScript
extends RefCounted

## CCH-ORIGIN-002: the words of the first winter's post from the life before, one thread for each origin. The letters
## are the screenplay's (AI_COLLAB/ROAD_TO_CROW_CREEK_HOLLOW_BRANCHING_SCREENPLAY_DRAFT.md, Act 5, W-A to W-E);
## AI_COLLAB/CCH_ORIGIN_002_REPORT.md lists where its stage directions were turned into letters and replies.
## PastPost (scripts/past_post.gd) keeps the state and does the work; this file is only text and its shape.
##
## variant(origin) picks the thread's variant from the choices the road actually recorded. A variant is:
##   title, sender      the letter's name in the mailbox, and who it is from (never more than the player told)
##   body               the first letter
##   stages             stage id -> {"choices": [...]}; "first" answers the first letter. A choice:
##     id, label        the button's line
##     kind             "reply" (a letter written and left for the morning post), "defer" (decided, nothing written,
##                      the other answers stay open) or "note" (written in the diary only: nothing is posted)
##     reply            what the player writes (for "note", the diary line)
##     cost             coins enclosed with the reply (paid when written, given back if it is taken back unposted)
##     needs            a check the farm must pass for the reply to be true (PastPost._verified): harvest, repair, woods
##     ack              the sender's answer, when the reply has reached them
##     next             instead of an answer: a stage the sender's next letter opens ("page" in the order book)
##     refund           coins the sender's answer encloses (the deposit, legitimately the player's)
##     outcome, matter  what is settled, for later scenes (CCH-ORIGIN-003) and the diary
##     diary            what the player's diary says they did (first person, facts only)
##     told             what the sender's answer and the diary say the player told them
##   lapse              {text, outcome, matter, diary}: what happens if nothing is sent by the answer-by date
##                      (text "" means nothing more comes: the matter closes on the sender's own terms)
##   received           the diary's first line: what the letter was about
## Placeholders: {crops} {Crops} {repair} {repair_short} {woods}, filled from what the farm really shows when the
## reply is written (PastPost._facts), and kept with the reply so a later answer says only what was told.

const DEADLINE_TEXT := "February 28"


static func _reply(id: String, label: String, reply: String, ack: String, outcome: Dictionary, matter: String,
		diary: String, extra: Dictionary = {}) -> Dictionary:
	var c := {"id": id, "label": label, "kind": "reply", "reply": reply, "ack": ack, "outcome": outcome, "matter": matter,
		"diary": diary, "cost": 0}
	c.merge(extra, true)
	return c


# --- A: The Cost of a Room ----------------------------------------------------------------------------------

static func _security(o: OriginState) -> Dictionary:
	var exit := o.choice("security_exit")
	if exit == "stored":
		var who := {"friend": "From your friend, who kept the boxes", "family": "From your family, who kept the boxes"}
		return {"id": "boxes", "title": "About the two boxes",
			"sender": str(who.get(o.contact(), "From the person keeping your boxes")),
			"body": "The last notice was settled. There are two boxes here under your name. I can keep them through the end of winter. After that you'll need to tell me what to do.\n\nNo hurry until then. I thought you'd want to know.",
			"received": "I had a letter about the two boxes I left behind. They can be kept until the end of winter.",
			"stages": {"first": {"choices": [
				_reply("ship", "Ask them to send the boxes on (30 coins)",
					"Please send the boxes up to the farm. I've put in 30 coins for the carriage.",
					"Your coins came, thank you. The carrier only comes up your way once the road is clear, so the boxes will go in the spring. I've written your address on both lids.",
					{"boxes": "to_ship", "paid": 30}, "arranged",
					"I wrote asking them to send the boxes up, and put in 30 coins for the carriage.",
					{"cost": 30, "ack_diary": "They wrote back. The boxes will come up with the carrier in the spring."}),
				_reply("more_time", "Ask them to keep the boxes longer",
					"Could you keep them until the end of April? I'll know by then what to do with them.",
					"The end of April is all right. Not much past it, though. I'll need the cupboard back by May.",
					{"boxes": "held", "until_day": 212}, "pending",
					"I asked for more time.",
					{"ack_diary": "They wrote back. They can keep the boxes until the end of April."}),
				_reply("release", "Tell them the boxes can go",
					"You needn't keep them. Give the things to whoever can use them.",
					"I took them down to the charity shop on Saturday. They were glad of them. That's the last of it, I think.",
					{"boxes": "released"}, "closed",
					"I told them the boxes could go.",
					{"ack_diary": "They wrote back. The boxes went to the charity shop."}),
			]}},
			"lapse": {"text": "I didn't hear from you, so the boxes are still here. I can keep them until the end of April, but I'll need to know by then.",
				"outcome": {"boxes": "held_unanswered", "until_day": 212}, "matter": "pending",
				"diary": "I didn't answer by the end of February. They wrote that they'll keep the boxes until the end of April."}}
	# No boxes were left: the forwarding of post from the old address, and nothing else.
	var from := "From the letting office" if exit == "extension" else "From the post office at your old address"
	var body := "You stayed to the end of the month, as agreed, and the room has been let again since. Your account with us is settled.\n\nWe have the farm's address for any post that comes here, and we'll send it on until the end of February. To keep that going another six months is 12 coins. Otherwise, after February, post for you goes back to the sender." \
		if exit == "extension" else \
		"Your forwarding card has been on file since October. Forwarding runs to the end of February. After that, anything addressed to your old room goes back to the sender.\n\nTo keep it going another six months is 12 coins. Nothing else is owed."
	return {"id": exit, "title": "Forwarded post", "sender": from, "body": body,
		"received": "I had a letter about forwarding the post from my old address. It runs out at the end of February.",
		"stages": {"first": {"choices": [
			_reply("renew", "Keep the forwarding going (12 coins)",
				"Please keep forwarding my post to the farm for another six months. I've put in the 12 coins.",
				"Received, with thanks. Post for you will come on to the farm until the end of August.",
				{"forwarding": "renewed", "until_day": 335, "paid": 12}, "resolved",
				"I paid 12 coins to keep my post coming on to the farm.",
				{"cost": 12, "ack_diary": "They wrote back. The post will come on until the end of August."}),
			_reply("end", "Let the forwarding end",
				"Please let the forwarding end in February. I'll give people the farm's address myself.",
				"Noted. The forwarding ends on February 28, and nothing more is owed. The account is closed.",
				{"forwarding": "ended"}, "closed",
				"I wrote to let the forwarding end. I'll give people the farm's address myself.",
				{"ack_diary": "They wrote back. The account is closed."}),
		]}},
		"lapse": {"text": "The forwarding of your post ended on February 28. Nothing is owed. The account is now closed.",
			"outcome": {"forwarding": "lapsed"}, "matter": "closed",
			"diary": "I didn't answer. The forwarding ended with February, and they wrote that the account is closed."}}


# --- B: Work That Belonged to Everyone ----------------------------------------------------------------------

const _ORDER_EXPLAIN := "Thursday is when the late deliveries go in. Check that none was entered twice, once on Wednesday's sheet and again on Thursday's."
const _ORDER_DECLINE := "I'm sorry, I can't take this on from here. Someone there will be able to go through it with you."
const _ORDER_RIGHT := "You were right. One delivery went in twice, on Wednesday's sheet and again on Thursday's. The totals match now. Thank you for taking the time."


static func _work(o: OriginState) -> Dictionary:
	var opening := {
		"finish": "You left the order book in good shape. One thing doesn't add up.",
		"instructions": "I've been going by the sheet you left, and it's been a help. One thing doesn't add up, though.",
		"boundary": "They gave me the order book after you left. Most of it makes sense. One thing doesn't add up.",
	}
	var exit := o.choice("work_exit")
	var explain := _reply("explain", "Send a short explanation", _ORDER_EXPLAIN, _ORDER_RIGHT,
		{"order_book": "explained"}, "resolved", "I wrote back with a short explanation of the Thursday figures.",
		{"ack_diary": "They wrote back. A delivery had been entered twice, and the totals match now."})
	var decline := _reply("decline", "Say you can't take it on", _ORDER_DECLINE,
		"That's fair enough. I'll go through the slips with the manager on Monday. Good luck with the farm.",
		{"order_book": "declined"}, "closed", "I wrote that I couldn't take it on.",
		{"ack_diary": "They wrote back. They'll go through it with the manager."})
	var ask := _reply("ask", "Ask which page they mean", "Which week do you mean? Send me the page and I'll look.", "",
		{"order_book": "asked"}, "awaiting_sender", "I asked which page they meant.", {"next": "page"})
	return {"id": exit, "title": "The order book", "sender": "From someone at the old job",
		"body": "%s I found your notes but I still can't see why the Thursday totals were different.\n\nI thought I'd ask before I start changing the figures." % str(opening.get(exit, opening["finish"])),
		"received": "Someone from the old job wrote about the order book. The Thursday totals don't add up.",
		"stages": {
			"first": {"choices": [explain, ask, decline]},
			# The bounded follow-up (W-B): one answer, then a real decision; no third round of questions.
			"page": {"title": "The order book, page 41",
				"body": "It's the second week of September, page 41. Thursday comes out eleven short of the delivery slips. I've copied the column out below so you don't have to remember it.\n\nIf it's too much, say so. I'll manage.",
				"received": "They sent the page: the second week of September, Thursday eleven short.",
				"choices": [explain, decline]},
		},
		"lapse": {"text": "I didn't hear back, which is fine. I went through the slips myself and found it: one delivery was entered twice. It's all sorted.",
			"outcome": {"order_book": "sorted_without_me"}, "matter": "resolved",
			"diary": "I didn't answer by the end of February. They found it themselves: one delivery entered twice."}}


# --- C: A House With One Less Person ------------------------------------------------------------------------

static func _household(o: OriginState) -> Dictionary:
	# The sender is named only as far as the player named them; "private" names nobody (W-C).
	var senders := {"partner": "From the person you shared the house with", "friend": "From your friend at the old house",
		"family": "From your family at the old house"}
	var body := "I found another key while clearing the drawer. I don't think it opens anything here anymore.\n\nDid you want it, or shall I put it away?"
	# The one who saw you off was this person, and you told them you'd rather not make plans: keep it to a line.
	if o.contact() == "former_household" and o.contact_intent() == "boundaries":
		body += " A line will do. I'm not asking for more than that."
	return {"id": "key", "title": "The second key", "sender": str(senders.get(o.household_sender(), "From someone at the house you left")),
		"body": body,
		"received": "I had a letter from the house I left. They found a second key and asked what to do with it.",
		"stages": {"first": {"choices": [
			_reply("ask", "Ask for the key", "Yes, I'd like it. Send it whenever you're next at the post office.",
				"I'll send it with the other things once I've sorted them. It won't be long. I've wrapped it so it doesn't get lost.",
				{"key": "to_send"}, "pending", "I asked them to send the key.",
				{"ack_diary": "They wrote back. The key will come with the other things, once they're sorted."}),
			_reply("keep", "Ask them to keep it", "Would you keep it for now? I don't need it here.",
				"I'll keep it, then. It's in the tin with the spare buttons, if you ever want it.",
				{"key": "kept_by_them"}, "open", "I asked them to keep the key.",
				{"ack_diary": "They wrote back. The key is in their tin with the spare buttons."}),
			_reply("no_need", "Say there's no need", "There's no need to keep it. I don't need it anymore.",
				"All right. I won't keep it for you, then.",
				{"key": "let_go"}, "closed", "I wrote that there was no need to keep it.",
				{"ack_diary": "They wrote back. They won't keep it."}),
			{"id": "defer", "label": "Don't reply yet", "kind": "defer", "diary": "I decided not to answer yet.",
				"about": "Nothing is written or sent. You can still answer until February 28."},
		]}},
		"lapse": {"text": "I haven't heard, and that's all right. I've put the key away for now. It will keep.",
			"outcome": {"key": "put_away_unanswered"}, "matter": "open",
			"diary": "I didn't answer by the end of February. They wrote that they've put the key away for now."}}


# --- D: The Place in the Photograph -------------------------------------------------------------------------

static func _curiosity(o: OriginState) -> Dictionary:
	if o.has_contact():
		var senders := {"friend": "From your friend, who saw you off", "family": "From your family, who saw you off"}
		var body := "Did it look like the picture? You told me there were trees and a field, but I can't picture how far the house is from everything.\n\nTell me one thing about it when you get a chance."
		match o.contact_intent():
			"promise":
				body = "You said you'd write. I thought I'd go first.\n\n" + body
			"invite":
				body += " You said to come up sometime. Not in this weather, I think."
			"boundaries":
				body += " One thing is plenty. You don't have to write back at all."
		return {"id": "friend", "title": "Did it look like the picture?",
			"sender": str(senders.get(o.contact(), "From the person who saw you off")), "body": body,
			"received": "The person who saw me off wrote to ask what the place is really like.",
			"stages": {"first": {"choices": [
				_reply("crops", "Write about what you've grown", "There's a field beside the house. I've grown {crops} in it and brought them in.",
					"{Crops}. I tried to picture you bringing them in, and I nearly could. The picture didn't show the field at all.",
					{"told": "crops"}, "resolved", "I wrote back about the field, and the {crops} I've grown in it.",
					{"needs": "harvest", "ack_diary": "They wrote back about the {crops}."}),
				_reply("repair", "Write about a repair you've done", "{repair}",
					"So there was work to do. The picture didn't show that part. It sounds as if you've been busy.",
					{"told": "repair"}, "resolved", "I wrote back about the work: {repair_short}.",
					{"needs": "repair", "ack_diary": "They wrote back. The picture didn't show the work."}),
				_reply("woods", "Write about the woods", "{woods}",
					"Woods right behind the house. Mind you don't get lost in them.",
					{"told": "woods"}, "resolved", "I wrote back about the woods behind the house.",
					{"needs": "woods", "ack_diary": "They wrote back about the woods."}),
				_reply("unsaid", "Say it's hard to put into words", "It's hard to put into words. I'll tell you more when I can.",
					"That's all right. When you can, then.",
					{"told": "unsaid"}, "open", "I wrote that it's hard to put into words.",
					{"ack_diary": "They wrote back: when I can, then."}),
			]}},
			"lapse": {"text": "", "outcome": {"told": "unanswered"}, "matter": "open",
				"diary": "I didn't answer it this winter."}}
	# No one saw them off: the notice itself is corrected, and the photograph is set beside what is really here.
	return {"id": "notice", "title": "A correction to the notice", "sender": "From the town office",
		"body": "A correction to the notice for the farm, as printed in the autumn. The photograph with it was an old one, taken in summer some years ago, and gave a wrong idea of the distance from the road.\n\nThe notice has been taken down, now that the farm is lived in. No reply is needed.",
		"received": "The town office wrote: the photograph on the notice was an old one, taken in summer years ago.",
		"stages": {"first": {"choices": [
			{"id": "crops", "label": "Note beside the photograph: what has grown", "kind": "note", "needs": "harvest",
				"reply": "The photograph shows open ground beside the house. I have grown {crops} there since.",
				"outcome": {"noted": "crops"}, "matter": "closed", "diary": "I wrote beside the photograph: the open ground has grown {crops} since."},
			{"id": "repair", "label": "Note beside the photograph: what is mended", "kind": "note", "needs": "repair",
				"reply": "In the photograph the house looks as if no one has touched it in years. Since I came, {repair_short}.",
				"outcome": {"noted": "repair"}, "matter": "closed", "diary": "I wrote beside the photograph: {repair_short}."},
			{"id": "woods", "label": "Note beside the photograph: the woods", "kind": "note", "needs": "woods",
				"reply": "The photograph shows the trees. I have walked in them now.",
				"outcome": {"noted": "woods"}, "matter": "closed", "diary": "I wrote beside the photograph that I have walked in the woods now."},
			_reply("road", "Write to the office about the road",
				"Thank you for the correction. The road is longer than the photograph made it look.",
				"Thank you for your note about the road. It has been filed with the notice.",
				{"noted": "wrote_office"}, "closed", "I wrote to the town office that the road is longer than the photograph made it look.",
				{"ack_diary": "They wrote back. My note is filed with the notice."}),
			{"id": "keep", "label": "Put it with the photograph and leave it", "kind": "note",
				"reply": "", "outcome": {"noted": "kept"}, "matter": "closed",
				"diary": "I put the town's correction with the photograph and didn't write anything."},
		]}},
		"lapse": {"text": "", "outcome": {"noted": "unread_or_left"}, "matter": "closed", "diary": ""}}


# --- E: A Chance Before It Closed ---------------------------------------------------------------------------

static func _chance(o: OriginState) -> Dictionary:
	match o.choice("chance_loose_end"):
		"work_offer":
			return {"id": "work_offer", "title": "The seasonal place", "sender": "From the people who offered you seasonal work",
				"body": "We held the seasonal place for you as long as we could, but we filled the position in December. We heard you had moved away.\n\nIf you're looking for work another year, the list for next season opens in August.",
				"received": "The people who offered me seasonal work wrote. They filled the place in December.",
				"stages": {"first": {"choices": [
					_reply("close", "Thank them and close it", "Thank you for holding it. I won't need the place. Please close it.",
						"Noted, and good luck with the farm.", {"offer": "closed"}, "closed", "I wrote to thank them and close it.",
						{"ack_diary": "They wrote back and wished me luck with the farm."}),
					_reply("list", "Ask to be on next season's list", "Please keep my name for next season's list. I can't promise I'll be free.",
						"Your name is on the list for next season. We'll write in August. You needn't answer then if it doesn't suit.",
						{"offer": "on_list", "until_day": 305}, "open", "I asked them to keep my name for next season's list.",
						{"ack_diary": "They wrote back. My name is on next season's list; they'll write in August."}),
				]}},
				"lapse": {"text": "", "outcome": {"offer": "filled"}, "matter": "closed",
					"diary": "I didn't answer. The place was filled, and that was the end of it."}}
		"storage":
			return {"id": "storage", "title": "The storage unit", "sender": "From the storage yard",
				"body": "Your unit is paid to the end of February. It needs to be cleared or renewed by then.\n\nRenewal is 15 coins for another three months. We can also send the contents on by carrier, for 30 coins. If we hear nothing, the contents are kept for thirty days and then cleared.",
				"received": "The storage yard wrote. The unit is paid to the end of February.",
				"stages": {"first": {"choices": [
					_reply("renew", "Renew it for three months (15 coins)", "Please renew the unit for another three months. 15 coins enclosed.",
						"Received. Your unit is paid to the end of May.", {"storage": "renewed", "until_day": 243, "paid": 15}, "pending",
						"I paid 15 coins to keep the unit another three months.",
						{"cost": 15, "ack_diary": "They wrote back. The unit is paid to the end of May."}),
					_reply("send", "Have the contents sent on (30 coins)", "Please send the contents on to the farm. 30 coins enclosed for the carrier.",
						"Received. The carrier will bring the contents up to the farm once the road is clear in spring. Your unit is closed.",
						{"storage": "to_ship", "paid": 30}, "arranged", "I paid 30 coins to have the unit's contents sent up.",
						{"cost": 30, "ack_diary": "They wrote back. The carrier will bring everything up in the spring."}),
					_reply("clear", "Ask them to clear it", "Please clear the unit and close the account. I won't need what's in it.",
						"The unit is cleared and the account closed. Nothing more is owed.", {"storage": "cleared"}, "closed",
						"I asked them to clear the unit and close the account.",
						{"ack_diary": "They wrote back. The unit is cleared and nothing is owed."}),
				]}},
				"lapse": {"text": "Your unit was not renewed. The contents are held until March 30 and then cleared. Write before then if you want them.",
					"outcome": {"storage": "held_unanswered", "until_day": 181}, "matter": "pending",
					"diary": "I didn't answer by the end of February. They'll hold the contents until March 30."}}
		"order":
			return {"id": "order", "title": "Your order", "sender": "From the shop where you left an order",
				"body": "The item you ordered has come in. Your deposit of 12 coins is held against it.\n\nWe can send it on by carrier: the balance, with carriage, is 24 coins. Or we can cancel the order and return your deposit. Please let us know by the end of February.",
				"received": "The shop wrote: my order has come in. They hold my deposit of 12 coins against it.",
				"stages": {"first": {"choices": [
					_reply("send", "Have it sent (24 coins)", "Please send it on to the farm. The balance and carriage, 24 coins, are enclosed.",
						"Received with thanks. Your order will go up with the carrier in the spring, when the road is clear.",
						{"order": "to_ship", "paid": 24}, "arranged", "I paid the 24 coins to have the order sent up.",
						{"cost": 24, "ack_diary": "They wrote back. It will come up with the carrier in the spring."}),
					_reply("refund", "Cancel it; ask for the deposit back", "Please cancel the order and return my deposit.",
						"Your order is cancelled. Your deposit of 12 coins is enclosed.", {"order": "refunded", "returned": 12}, "closed",
						"I cancelled the order and asked for my deposit back.",
						{"refund": 12, "ack_diary": "They wrote back with my deposit, 12 coins."}),
					_reply("hold", "Ask them to hold it until spring", "Could you hold it until the spring? I'll write again by the end of April.",
						"We can hold it until the end of April. After that the order will be cancelled and the deposit returned.",
						{"order": "held", "until_day": 212}, "pending", "I asked them to hold the order until the spring.",
						{"ack_diary": "They wrote back. They'll hold it until the end of April."}),
				]}},
				"lapse": {"text": "We have not heard from you. We'll hold your order until the end of April. After that it will be cancelled and your deposit returned.",
					"outcome": {"order": "held_unanswered", "until_day": 212}, "matter": "pending",
					"diary": "I didn't answer by the end of February. They'll hold the order until the end of April."}}
		"meeting":
			return {"id": "meeting", "title": "The meeting", "sender": "From the person you'd agreed to meet",
				"body": "We'd said we would meet in the autumn. By the time the day came you had moved away, and I couldn't hold the time after that.\n\nIf you want to talk another time, write with a day that suits you. I can't promise I'll be free.",
				"received": "The person I'd agreed to meet wrote. They couldn't hold the time.",
				"stages": {"first": {"choices": [
					_reply("close", "Write that you can't, and close it", "I've moved a long way off and can't come. Let's leave it there.",
						"That's all right. Thank you for writing.", {"meeting": "closed"}, "closed",
						"I wrote that I couldn't come, and left it there.",
						{"ack_diary": "They wrote back. That's all right."}),
					_reply("spring", "Ask to try again in the spring", "Could we try again in the spring? Write and suggest a day in April.",
						"April, then. I'll write nearer the time with a day. I can't promise it will suit.",
						{"meeting": "spring"}, "open", "I asked if we could try again in the spring.",
						{"ack_diary": "They wrote back. They'll suggest a day in April."}),
				]}},
				"lapse": {"text": "", "outcome": {"meeting": "lapsed"}, "matter": "closed",
					"diary": "I didn't answer it."}}
	return {}


# The thread's variant for this origin record, or {} when the past is unknown (legacy, none, unfinished).
static func variant(o: OriginState) -> Dictionary:
	match o.origin():
		"security":
			return _security(o)
		"work":
			return _work(o)
		"household":
			return _household(o)
		"curiosity":
			return _curiosity(o)
		"chance":
			return _chance(o)
	return {}
