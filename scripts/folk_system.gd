class_name FolkSystem
extends RefCounted

# The walkers as neighbours. Old Maren, Davy Tull, the vicar and the postman each have a friendship of 0 to 10
# hearts (20 points a heart), raised by walking them through the wood, a word each day, gifts and their
# requests. The walks were the old standing (TrekSystem.walked), and still count from it: the first three walks
# give a heart each, later ones a fifth of one, so a save from before friendship keeps every walker's standing.
# On days nobody waits at the gate, one of them sometimes comes by the farm (Maren by the stand, Davy at the
# pond, the vicar under the great tree, the postman at the door) with a line for the season and how well they
# know you, now and then a small request, and, at 2, 4, 6 and 8 hearts, a scene: something they have never told
# anyone about Agnes, Elias, the bell or the town's vote. The last scene of each is a hook for the endings (see
# DESIGN.md, Folk). Their talk, scenes and trek words show in the dialogue box with their portraits.

var m: MainGame

const IDS := ["mill", "orchard", "chapel", "post"]
const HEART := 20
const MAX_POINTS := 200
const FULL_WALKS := 3                 # walks that give a whole heart each (the old standing); later ones give half
const WALK_POINTS := 20
const WALK_POINTS_AFTER := 4
const NIGHT_WALK_POINTS := 8          # more for walking them by night
const EDGE_POINTS := 8                # Maren, for the walk to the wood's edge
const TALK_POINTS := 1                # the first word of the day
const GIFT_POINTS := {"loved": 10, "liked": 5, "neutral": 2, "disliked": -8}
const GIFT_DAYS := 7                  # a gift to each walker once a week
const REQUEST_POINTS := 20
const SCENE_HEARTS := [2, 4, 6, 8]
const SCENE_GAP := 10                 # days at least between one walker's scenes
const VISIT_FROM := 9.0
const VISIT_UNTIL := 16.0
const VISIT_EVERY := 2                # about one day in this many without walkers at the gate has a visitor
const SCENE_PICK := 0.7               # the chance the day's visitor is one with a scene waiting
const REQUEST_CHANCE := 0.5           # the chance a visitor with nothing asked yet asks for something

# Who they are. "from" is the first day they come by the farm ("edge": once Maren has been walked to the wood's
# edge). Tastes are pack keys (Foods "held"); anything else edible is neutral. "react" is said on a gift.
const FOLK := {
	"mill": {"name": "Old Maren", "short": "Maren", "from": 5, "edge": true, "spot": "stand", "where": "sitting on the edge of the farm stand",
		"about": "From the last cottage down the lane. Her sister Ruth keeps the mill. She was at the meeting the night the town voted Agnes Rook's bell down.",
		"loved": ["rosehip_tea", "bramble_jam", "apple_crumble"],
		"liked": ["leek_soup", "blackberries", "apples", "garlic", "baked_potato", "bread"],
		"disliked": ["pale_carp", "lamprey", "ghost_pipe", "ghost_tincture"],
		"react": {"loved": "\"Oh. Oh, you shouldn't have. Agnes made this every autumn.\" She holds it in both hands.",
			"liked": "\"That's kind. I'll have it with my tea.\"",
			"neutral": "\"Well. Thank you.\" She tucks it in her basket.",
			"disliked": "She looks at it a long while. \"Not that. Never that, in my house.\""}},
	"orchard": {"name": "Davy Tull", "short": "Davy", "from": 20, "spot": "pond", "where": "skimming stones at the pond",
		"about": "The Tull boy, from the farm below the drowned orchard. His dog Pip ran off with the wild dogs at harvest. His grandad worked the orchard for Elias Rook.",
		"loved": ["strawberries", "salmonberries", "pumpkin_pie", "berry_cobbler"],
		"liked": ["apples", "corn", "huckleberries", "blueberries", "fish_meal", "bluegill", "apple_crumble"],
		"disliked": ["kale", "nettle_soup", "parsnips", "ghost_tincture", "fermented_turnip"],
		"react": {"loved": "\"For me? The whole thing?\" It's gone before you can say yes.",
			"liked": "\"Thanks.\" He eats it walking in a small circle, pleased.",
			"neutral": "\"Ma will want it.\" He puts it inside his jacket.",
			"disliked": "\"Ugh.\" He takes it, because his ma would want him to, and holds it away from himself."}},
	"chapel": {"name": "The vicar", "short": "the vicar", "from": 40, "spot": "tree", "where": "standing under the great tree with his hat off",
		"about": "He climbed the ladder and cut Agnes Rook's bell down. He kept the clapper. He holds a service at the chapel on the hill once a month, for no one.",
		"loved": ["pumpkin_soup", "sturgeon_steak", "chanterelles", "fish_stew"],
		"liked": ["leeks", "parsnips", "trout", "crappie", "pea_soup", "bread", "smoked_fish"],
		"disliked": ["pale_carp", "lamprey", "smoked_lamprey", "fermented_turnip", "ghost_pipe"],
		"react": {"loved": "\"That's generous. That will feed six at the vicarage door.\" He means it as the highest praise he has.",
			"liked": "\"Thank you. Truly.\"",
			"neutral": "\"Kind of you.\" He finds a pocket for it.",
			"disliked": "\"I won't have it in the house, I'm afraid.\" He gives it back to you, gently."}},
	"post": {"name": "The postman", "short": "the postman", "from": 6, "spot": "door", "where": "waiting by your door with his satchel",
		"about": "Thirty years on the lane's round. It was he who brought the torn page through your mail slot on your third morning. Every autumn he carries a letter for Agnes Rook.",
		"loved": ["corn_chowder", "smoked_lamprey", "hearty_stew"],
		"liked": ["potatoes", "garlic_trout", "yellowfoot", "morels", "roast_roots", "eggs", "colcannon"],
		"disliked": ["bramble_jam", "rosehip_tea", "strawberries", "ghost_pipe"],
		"react": {"loved": "\"Now that's a dinner.\" He stows it in the satchel, carefully, on top of the letters.",
			"liked": "\"Much obliged.\"",
			"neutral": "\"Thank you kindly.\"",
			"disliked": "\"Sticks to everything in the sack, that does.\" He takes it to be polite."}},
}

# A visitor's lines: "t" the text, "e" the face, "s" a season, "h"/"x" the fewest and most hearts, "if" walked,
# bell (the crow bell is hung), grove (Agnes is walked to the grove) or nogrove.
const LINES := {
	"mill": [
		{"t": "\"I came up for the walk. My knees say otherwise.\" She watches your field. \"Agnes grew pole beans along that fence. Taller than Elias.\"", "x": 3},
		{"t": "\"You keep the stand tidy. Mr Pell will notice. He notices everything, and says nothing.\"", "x": 5},
		{"t": "\"The salmonberries are out along the lane. Agnes said the first ones belong to the crows.\" She doesn't pick any.", "s": "Spring"},
		{"t": "\"Hot, for here. The creek's low. When the creek's low you can hear the wood better. I don't like it.\"", "s": "Summer", "e": "worry"},
		{"t": "\"First rain, and the moss comes back like it never left. Keep your fire in.\"", "s": "Autumn"},
		{"t": "\"Dark at four now. You'll be in by then.\" It isn't a question.", "s": "Winter", "e": "grim"},
		{"t": "\"Ruth sends her love. She doesn't send it often. Take it.\"", "h": 3, "e": "smile"},
		{"t": "\"I've stopped locking my door. Isn't that strange? Since you came, I sleep.\"", "h": 5, "e": "smile"},
		{"t": "\"I keep thinking of the mill that night. Thirty-one of us, and the shutters shut. You could hear the crows walking on the roof the whole time.\"", "h": 7, "e": "far"},
		{"t": "\"You walk the wood like you mean to come back out of it. That's most of it.\"", "if": "walked"},
		{"t": "\"I heard it ring last night. I stood at my door in my nightgown like a girl.\"", "if": "bell", "e": "smile"},
		{"t": "\"She's gone in, then. I knew her walk, under that shawl. I should have said.\"", "if": "grove", "e": "far"},
	],
	"orchard": [
		{"t": "Davy skims a stone. \"Four. Pip used to go in after them.\"", "x": 3},
		{"t": "\"Ma says I'm not to come up here. I come up here.\""},
		{"t": "\"Ned Pell says there's fish in your pond with no eyes. Is there?\"", "x": 5, "e": "worry"},
		{"t": "\"Fiddleheads are up on the creek bank. You fry them in butter. I don't like them. Ma does.\"", "s": "Spring"},
		{"t": "\"Bluegill take bread, if you've got bread. Pip used to eat the bread.\"", "s": "Summer", "e": "smile"},
		{"t": "He whistles two notes at the far bank, waits, and pretends he didn't.", "s": "Autumn", "e": "far"},
		{"t": "\"The pond freezes at the edges. Grandad says don't stand on it, not even at the edges. It isn't the ice he means.\"", "s": "Winter", "e": "worry"},
		{"t": "\"You can have my best stone. No. Not that one.\"", "h": 3, "e": "smile"},
		{"t": "\"I told Ma you're all right. She said, 'For up there.' I think that's good.\"", "h": 5, "e": "smile"},
		{"t": "\"When I can't sleep I count the orchard rows. There's eleven. Grandad says there was nearly twelve.\"", "h": 7, "e": "far"},
		{"t": "\"Next time we go, I'll whistle louder. He's maybe just far.\"", "if": "walked"},
		{"t": "\"Did you hear it? Pip would've howled. He howled at the church bell, before.\"", "if": "bell"},
		{"t": "\"Grandad says the water's going down in the orchard. He won't say why he's crying about it.\"", "if": "grove", "e": "worry"},
	],
	"chapel": [
		{"t": "\"I don't come for the crows. I come because nobody else does.\"", "x": 3},
		{"t": "He looks up into the crown a long time. \"There's a great deal up there that isn't nests.\"", "x": 5, "e": "grim"},
		{"t": "\"Easter soon. I'll set out the hymn books at the chapel for no one, and sing all the verses.\"", "s": "Spring"},
		{"t": "\"The tree's in full leaf. You can't see what's in the crown in summer. I find I prefer winter.\"", "s": "Summer"},
		{"t": "\"All Hallows soon. The town sleeps badly in this season. They used to blame her bell.\"", "s": "Autumn", "e": "far"},
		{"t": "\"The winters she rang it, nobody froze up here. Not one. I've checked the register.\"", "s": "Winter", "e": "grim"},
		{"t": "\"You keep the place in order. Agnes liked a swept step.\"", "h": 3, "e": "smile"},
		{"t": "\"I pray for this farm by name, every Sunday. It feels like the least I owe.\"", "h": 5, "e": "far"},
		{"t": "\"My hands still ache in the rain. The bell rope. Years, and they remember.\"", "h": 7, "e": "grim"},
		{"t": "\"You walked me there and back, and I didn't stay past dark. Thank you for that.\"", "if": "walked", "e": "smile"},
		{"t": "\"You've hung one. Good. God forgive us, good.\"", "if": "bell", "e": "grim"},
		{"t": "\"The vestry door was unlocked this morning. I've had the only key for years.\"", "if": "grove", "e": "worry"},
	],
	"post": [
		{"t": "\"Nothing for you today. There rarely is. I come by anyway.\"", "x": 3},
		{"t": "\"The crows sat on your gatepost the whole time I came up. Watching the sack, not me.\"", "e": "worry"},
		{"t": "\"Seed catalogues, this time of year. Elias Rook still gets one. Every spring.\"", "s": "Spring", "e": "far"},
		{"t": "\"Dry roads. I can do the whole lane by noon in summer. Then I sit on the chapel steps and wait for the shade.\"", "s": "Summer", "e": "smile"},
		{"t": "\"It's in the sack again. The letter. I can feel it, like a stone.\"", "s": "Autumn", "if": "nogrove", "e": "grim"},
		{"t": "\"Tax letters from the county. I'm sorry. I don't write them.\"", "s": "Winter"},
		{"t": "\"Mrs Pell asks after you. That means the whole lane does.\"", "h": 3, "e": "smile"},
		{"t": "\"You've a good hand. On your tax slips. Clear.\" He looks at you oddly.", "h": 5, "e": "far"},
		{"t": "\"Thirty years and I've never lost a letter. People think that's pride. It's fear.\"", "h": 7, "e": "grim"},
		{"t": "\"I've told the sorting office I'm walked through the wood now, by the Rook farm. They wrote it down like it was weather.\"", "if": "walked"},
		{"t": "\"The sack's light this autumn. I keep reaching in for it.\"", "if": "grove", "e": "far"},
	],
}

# Small deliveries. A visitor asks for one when nothing of theirs is waiting and they know you well enough
# ("hearts"); "season" limits when it is asked. Bring it when they are on the farm (a visit or the gate).
const REQUESTS := [
	{"id": "maren_eggs", "who": "mill", "hearts": 1, "title": "Eggs for the mill", "want": {"eggs": 6}, "reward": {"coins": 30, "flour": 2},
		"ask": "\"Ruth's hens have gone off laying, and the mill kitchen runs on eggs. Could you spare six? Bring them when I'm by.\"",
		"thanks": "\"Six. Ruth will make a cake and pretend it was her idea.\" She leaves coins on the stand and a twist of flour."},
	{"id": "maren_garlic", "who": "mill", "hearts": 3, "season": "Autumn", "title": "Garlic for the sill", "want": {"garlic": 3}, "reward": {"coins": 25, "feathers": 2},
		"ask": "\"I'd like three heads of garlic, for the window sill. Agnes kept it on hers. I never asked her why. I'm asking you to bring it.\"",
		"thanks": "\"On the sill tonight.\" She gives you two black feathers from her basket. \"They come to my step. I don't know what else to do with them.\""},
	{"id": "maren_tea", "who": "mill", "hearts": 5, "title": "Tea for the cold", "want": {"rosehip_tea": 2}, "reward": {"coins": 40, "bread": 2},
		"ask": "\"My chest is bad in the cold. Two jars of rose hip tea would see me to spring.\"",
		"thanks": "\"You're a good neighbour. Better than I was.\" She gives you two loaves of Ruth's bread and a few coins."},
	{"id": "davy_fish", "who": "orchard", "hearts": 1, "title": "Perch for Ma", "want": {"fish": 3}, "reward": {"coins": 25},
		"ask": "\"Ma wants fish, and I can't catch any. Three perch? Don't say I asked.\"",
		"thanks": "\"Ma'll think I caught them.\" He grins and pays you in coins warm from his pocket."},
	{"id": "davy_berries", "who": "orchard", "hearts": 3, "season": "Summer", "title": "Salmonberries", "want": {"salmonberries": 4}, "reward": {"coins": 15, "apple_sapling": 1},
		"ask": "\"Pip liked salmonberries. Daft dog. If I left some at the orchard he might smell them. Four?\"",
		"thanks": "\"I'll leave them on the gatepost.\" He gives you a sapling wrapped in sacking. \"From the drowned rows. Grandad grafted it.\""},
	{"id": "davy_rope", "who": "orchard", "hearts": 5, "title": "Rope for the boat", "want": {"rope": 2}, "reward": {"hardwood": 3, "coins": 20},
		"ask": "\"There's a boat at the orchard, sunk to the gunwales. With two ropes I could drag it out. Then I could go out over the rows and look.\"",
		"thanks": "\"Don't tell Ma what it's for.\" He gives you applewood his grandad split, and coins, and runs."},
	{"id": "vicar_pumpkins", "who": "chapel", "hearts": 1, "season": "Autumn", "title": "Pumpkins for the soup", "want": {"pumpkins": 4}, "reward": {"coins": 45},
		"ask": "\"I give out soup at the vicarage door in the autumn. Four pumpkins would make a great deal of it. Would you bring them?\"",
		"thanks": "\"Thank you. Somebody will be warm because of these.\" He pays you more than they would fetch at the stand."},
	{"id": "vicar_oil", "who": "chapel", "hearts": 3, "title": "Oil for the chapel lamp", "want": {"lamp_oil": 2}, "reward": {"sanity": 10, "coins": 10},
		"ask": "\"The lamp in the chapel window has gone out. I'd like it lit again. Two flasks of oil?\"",
		"thanks": "\"It will be lit tonight.\" He puts his hand on your head for a moment, like a blessing, and you feel steadier for it."},
	{"id": "vicar_sturgeon", "who": "chapel", "hearts": 5, "title": "A harvest supper", "want": {"sturgeon": 1}, "reward": {"coins": 80},
		"ask": "\"I hold a harvest supper every year. Nobody comes, but I set the table. This year I'd like a white sturgeon on it. Indulge me.\"",
		"thanks": "\"Older than the farm, they say, these fish. I'll set a place for her.\" He pays you well."},
	{"id": "post_potatoes", "who": "post", "hearts": 1, "title": "Potatoes for the stove", "want": {"potatoes": 5}, "reward": {"coins": 25},
		"ask": "\"The sorting office stove bakes a fine potato. Five of yours, and I'd be the envy of the county.\"",
		"thanks": "\"Grand.\" He counts out coins, the old way, one at a time."},
	{"id": "post_firewood", "who": "post", "hearts": 3, "season": "Winter", "title": "Firewood for the office", "want": {"firewood": 6}, "reward": {"coins": 35},
		"ask": "\"The county's not sent coal. Six bundles of split wood would keep the office open till spring.\"",
		"thanks": "\"You've kept the post going this winter. That's no small thing.\" Coins, and a nod."},
	{"id": "post_lamprey", "who": "post", "hearts": 5, "title": "Smoked lamprey", "want": {"smoked_lamprey": 1}, "reward": {"coins": 60, "crow_charm": 1},
		"ask": "\"My father liked smoked lamprey. Nobody makes it now. If you ever did, I'd pay.\"",
		"thanks": "He eats a piece right there and closes his eyes. Then he gives you coins and a crow charm. \"For the round. Mine's never failed me.\""},
]

# The scenes, four a walker, at SCENE_HEARTS. "day" is the first day the last can come. "gift" is given at the
# end. "hook" marks what the endings build on (see DESIGN.md, Folk). Each page: {who, expr, text}; no who is
# the narration.
const SCENES := {
	"mill": [
		{"id": "maren_lamp", "title": "Ruth's lamp", "pages": [
			{"text": "Maren sits on the edge of the farm stand, her stick across her knees."},
			{"who": "mill", "text": "\"The night after they took the bell down, I sat up at Ruth's, at the mill. I left the lamp in the window.\""},
			{"who": "mill", "expr": "far", "text": "\"I thought she might come by on her way. I thought she'd want her tea, and a scolding, and to be told not to be so daft.\""},
			{"text": "She turns the stick in her hands."},
			{"who": "mill", "expr": "grim", "text": "\"Somebody went by at dusk. I heard the gravel. They didn't knock.\""},
			{"who": "mill", "text": "\"I've kept a lamp in my window every night since. Ruth thinks it's for burglars.\""}]},
		{"id": "maren_hens", "title": "Agnes's hens", "gift": {"eggs": 4}, "pages": [
			{"text": "Maren has brought a basket. Under a cloth are four brown eggs."},
			{"who": "mill", "expr": "smile", "text": "\"These are hers, you know. Agnes's hens. Well, their great-grandchildren. I took them in when the farm stood empty.\""},
			{"who": "mill", "expr": "smile", "text": "\"She sang to them. Hymns, very loud and not very well. Elias said the hens laid out of fear.\""},
			{"who": "mill", "expr": "far", "text": "\"He was a quiet man. He cut marks in the trees so the wood wouldn't forget the way. As if the wood were the one forgetting.\""},
			{"text": "She sets the eggs down by the stand and doesn't take the basket back."}]},
		{"id": "maren_hands", "title": "Thirty-one hands", "pages": [
			{"text": "Maren doesn't sit today. She stands looking north, at the wood."},
			{"who": "mill", "expr": "grim", "text": "\"You'll hear it was the noise. That she rang all night and nobody slept. That's what we told each other.\""},
			{"who": "mill", "expr": "grim", "text": "\"It wasn't loud. You slept through it, once you were used to it. It was what came after.\""},
			{"who": "mill", "expr": "worry", "text": "\"When she rang it, something rang back. Out in the wood. Lower, and a beat late. Every night.\""},
			{"who": "mill", "expr": "far", "text": "\"Thirty-one hands went up at the mill. Not for quiet. Because we couldn't bear to hear it answer.\""},
			{"text": "She goes before you can say anything, quicker than her knees should let her."}]},
		{"id": "maren_book", "title": "The minute book", "day": 150, "hook": "maren_stands", "pages": [
			{"text": "Maren has a book under her arm, its cloth cover gone soft with damp."},
			{"who": "mill", "text": "\"Ruth's minute book. The mill keeps one, for meetings. Ruth wrote it all down that night. She writes everything down.\""},
			{"who": "mill", "expr": "grim", "text": "\"Every name. Every hand. Mine is third from the top. I've read it so often the page has gone thin.\""},
			{"who": "mill", "expr": "far", "text": "\"A vote can be put again. That's what Ruth says. It only wants someone to stand up at the mill and ask.\""},
			{"who": "mill", "expr": "worry", "text": "\"I was afraid then and I'm afraid now. But if it comes to it, I'll stand. You tell me when.\""},
			{"text": "She won't let you take the book. \"It stays at the mill. Where it was done.\""}]},
	],
	"orchard": [
		{"id": "davy_notes", "title": "Two notes", "pages": [
			{"text": "Davy is crouched at the water's edge, whistling: two notes, the second lower."},
			{"who": "orchard", "text": "\"That's Pip's whistle. Grandad taught it me. He says it's older than Pip. Older than him.\""},
			{"who": "orchard", "text": "\"He says it's what her bell sounded like. Agnes Rook's. It had a crack in it, so it rang two notes instead of one.\""},
			{"who": "orchard", "expr": "worry", "text": "\"He says that's why it worked. One note for here, and one for... he wouldn't say for what.\""},
			{"text": "He whistles again. Across the pond the trees go quiet, in a way they weren't before."}]},
		{"id": "davy_rows", "title": "Eleven rows", "pages": [
			{"text": "Davy has an apple core and is deciding whether to throw it."},
			{"who": "orchard", "expr": "smile", "text": "\"Grandad worked the orchard for Elias, when he was young. He says Elias was the best grafter in the valley.\""},
			{"who": "orchard", "text": "\"He planted a row every year he and Agnes were married. Eleven rows. Then he went into the hollow, and there wasn't a twelfth.\""},
			{"who": "orchard", "expr": "far", "text": "\"The year Agnes went, the creek came up over the whole orchard in one night, with no rain. Grandad says like it was filling a hole.\""},
			{"text": "He throws the core into the pond. It doesn't splash so much as go under."}]},
		{"id": "davy_man", "title": "The man in the rows", "pages": [
			{"text": "Davy won't look at you. His boots are wet to the knee, and it hasn't rained."},
			{"who": "orchard", "expr": "worry", "text": "\"Don't tell Ma. I went to the orchard on my own, at night. I thought Pip would come if it was dark. The dogs do.\""},
			{"who": "orchard", "expr": "worry", "text": "\"There's a man in the water, walking the rows. Round the end of one and up the next, round and round. He's got a lantern, but it gives no light.\""},
			{"who": "orchard", "expr": "grim", "text": "\"I whistled the two notes. He stopped, and he turned his head. Just his head.\""},
			{"who": "orchard", "expr": "far", "text": "\"He's tall. Grandad says Elias was tall.\""},
			{"text": "He looks at you then. \"You won't tell Ma.\""}]},
		{"id": "davy_turn", "title": "Keeping company", "day": 200, "hook": "davy_turn", "pages": [
			{"text": "Davy sits very still by the pond, and he is smiling, which is worse."},
			{"who": "orchard", "expr": "smile", "text": "\"Pip's not lost. I saw him. He's at the orchard, walking behind the man in the rows, right at his heel, like a good dog.\""},
			{"who": "orchard", "text": "\"He's keeping him company. You'd want company, going round and round like that.\""},
			{"who": "orchard", "expr": "worry", "text": "\"Grandad says the man can't stop walking, wherever he is, or something gets out. Unless somebody takes a turn for him. Then he could come home. Then Pip could.\""},
			{"who": "orchard", "expr": "far", "text": "\"I'm small, but I can walk all day. I could take a turn.\""},
			{"text": "He says it the way children say they could fly. He doesn't laugh after."}]},
	],
	"chapel": [
		{"id": "vicar_names", "title": "The names", "pages": [
			{"text": "The vicar is reading from a small black book under the great tree, his lips moving."},
			{"who": "chapel", "text": "\"Forgive me. The names. I read them once a month at the chapel, and once here. It seemed the place.\""},
			{"who": "chapel", "expr": "far", "text": "\"Before the Rooks, four families kept this farm. The Askews. The Lindqvists. The Harrows. The Moores.\""},
			{"who": "chapel", "expr": "grim", "text": "\"Every one of them stopped going out at night, in the end. And then one of each went out, and didn't come in.\""},
			{"who": "chapel", "text": "\"I've left a line under the Rooks. I hope I'm a long time filling it.\""}]},
		{"id": "vicar_ladder", "title": "The ladder", "pages": [
			{"text": "The vicar holds out his hands, palms up. The skin across them is shiny with old scar."},
			{"who": "chapel", "expr": "grim", "text": "\"Rope burn. The bell rope, when it came down. It ran through my hands, and I didn't let go, or it would have gone through the cote roof.\""},
			{"who": "chapel", "text": "\"Agnes held the ladder. Did you know that? She stood at the foot of it the whole time and held it steady, so I wouldn't fall.\""},
			{"who": "chapel", "expr": "far", "text": "\"She didn't want it down. She held the ladder anyway. I've never understood it, and I've had a long time to try.\""},
			{"who": "chapel", "text": "\"Perhaps she wanted it done kindly, if it had to be done.\""}]},
		{"id": "vicar_struck", "title": "What I struck", "pages": [
			{"text": "The vicar is quiet a long time before he speaks."},
			{"who": "chapel", "expr": "grim", "text": "\"The night she went into the wood, she came to the chapel first, for the clapper. I said no. I shut the vestry door and wept behind it like a boy.\""},
			{"who": "chapel", "expr": "worry", "text": "\"When she'd gone, I took it out of its cloth and struck it once on the font. To hear it, I think.\""},
			{"who": "chapel", "expr": "grim", "text": "\"Iron on stone shouldn't ring like that. And out in the wood, something rang back. Two notes. Lower, and late.\""},
			{"who": "chapel", "expr": "far", "text": "\"I have never struck it again. I have never slept well since.\""}]},
		{"id": "vicar_register", "title": "The register", "day": 250, "hook": "vicar_register", "pages": [
			{"text": "The vicar has brought the parish register, wrapped in oilcloth against the rain."},
			{"who": "chapel", "text": "\"The deeds of sale for this farm. The town has sold it six times. Always for almost nothing. Always to someone from away.\""},
			{"who": "chapel", "expr": "grim", "text": "\"Look at the witness's line. My father's name, three times. Mine, twice. The Rooks. And you.\""},
			{"who": "chapel", "expr": "worry", "text": "\"The town doesn't sell this farm. It hands it on, to someone who will ring, or walk, or go in, so that the rest of us needn't.\""},
			{"who": "chapel", "expr": "far", "text": "\"I've known it all my life and said it to no one. I'm saying it to you. I'll stand by whatever you do with it, at the mill or the altar.\""},
			{"text": "He wraps the register again and holds it against his chest, as if it were cold."}]},
	],
	"post": [
		{"id": "post_round", "title": "The round", "pages": [
			{"text": "The postman sets his satchel down on your step, which he never does."},
			{"who": "post", "text": "\"The Rooks had more post than the rest of the lane together. Seed catalogues for him, from all over. Letters for her, from Lowmere.\""},
			{"who": "post", "text": "\"Lowmere's over the hills. Old place. Old women. Agnes wrote to them every week the last winter, and they wrote back in a hand like spiders.\""},
			{"who": "post", "expr": "far", "text": "\"I didn't read them. I'll say that first. But you carry a thing long enough, you know its weight.\""}]},
		{"id": "post_crate", "title": "The crate", "pages": [
			{"who": "post", "text": "\"The iron for her bell came on my round. A crate from Lowmere, so heavy the cart axle cracked at the bottom of your lane.\""},
			{"who": "post", "expr": "grim", "text": "\"There was a card nailed to the lid. That I did read. It said: It wants ringing by someone who stays.\""},
			{"who": "post", "expr": "far", "text": "\"She stayed. Every night, she stayed. Then they took it down and she couldn't, so she went to where she could.\""},
			{"text": "He picks up his satchel. On the gatepost, the crows lift and settle."}]},
		{"id": "post_dead", "title": "Dead letters", "pages": [
			{"who": "post", "text": "\"There's no such thing as an undeliverable letter. Only one that hasn't found where it's going yet.\""},
			{"who": "post", "text": "\"The Rooks' post still comes. Elias's catalogues. A bill from Lowmere. I keep it in the sack. Sending it back would be saying there's nobody.\""},
			{"who": "post", "expr": "worry", "text": "\"Some mornings there's one in the sack I didn't put there. For the farm. For whoever's there. No stamp.\""},
			{"who": "post", "expr": "far", "text": "\"That torn page your third morning was one of those. I'm sorry. I should have said then.\""},
			{"text": "He doesn't say how many there have been."}]},
		{"id": "post_hand", "title": "The hand", "day": 280, "hook": "post_hand", "pages": [
			{"text": "The postman doesn't say good morning. He holds out a yellowed envelope, and doesn't let go of it."},
			{"who": "post", "expr": "grim", "text": "\"Mrs Agnes Rook, care of the chapel. Every autumn. I told you I didn't know the hand.\""},
			{"who": "post", "expr": "worry", "text": "\"I know it now. I've carried your tax slips and your catalogue orders all year. Look at the capitals. Look at the R.\""},
			{"text": "It is your handwriting. You have never written to anyone called Agnes Rook."},
			{"who": "post", "expr": "far", "text": "\"I won't open it. It isn't mine to open. But I thought you should know whose it is, before you decide anything.\""}]},
	],
}

var bonus := {}             # saved: friendship points beyond the walks, by walker
var met := {}               # saved: walkers you have spoken to
var seen := {}              # saved: scene id -> the day it was seen
var tastes := {}            # saved: "who:key" -> loved, liked, neutral or disliked, learned by giving it
var requests := {}          # saved: request id -> the day it was asked
var requests_done := {}     # saved: request id -> the day it was brought
var talk_day := {}          # saved: walker -> the last day you had a word
var gift_day := {}          # saved: walker -> the last day you gave them something
var gifts_given := 0        # saved
var visit_day := 0          # saved: the day the visitor below was picked
var visitor := ""           # saved: today's visitor on the farm, or none
var spot := Vector2i(-1, -1)  # where they stand (worked out each morning and on loading)
var present := ""           # the walker you last spoke to today: gifts go to them
var dialogue: DialogueBox


func _init(main: MainGame) -> void:
	m = main


func _build() -> void:
	dialogue = DialogueBox.new()
	dialogue.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	dialogue.grow_horizontal = Control.GROW_DIRECTION_BOTH
	dialogue.grow_vertical = Control.GROW_DIRECTION_BEGIN
	dialogue.custom_minimum_size = Vector2(640, 0)
	dialogue.offset_left = -320
	dialogue.offset_right = 320
	dialogue.offset_bottom = -104
	m.message_label.get_parent().add_child(dialogue)   # the HUD root, beside the messages


# --- Friendship ---------------------------------------------------------------------------------

func _walk_points(id: String) -> int:
	var walks := int(m.trek.walked.get(id, 0))
	return mini(walks, FULL_WALKS) * WALK_POINTS + maxi(0, walks - FULL_WALKS) * WALK_POINTS_AFTER


# Friendship points, 0 to MAX_POINTS. extra_walks counts walks not yet added (the one arriving now).
func _points(id: String, extra_walks := 0) -> int:
	var walks := int(m.trek.walked.get(id, 0)) + extra_walks
	var wp := mini(walks, FULL_WALKS) * WALK_POINTS + maxi(0, walks - FULL_WALKS) * WALK_POINTS_AFTER
	return clampi(wp + int(bonus.get(id, 0)), 0, MAX_POINTS)


func _hearts(id: String, extra_walks := 0) -> int:
	return _points(id, extra_walks) / HEART


# Adds points beyond the walks, never taking the total under nothing or past the most.
func _add(id: String, n: int) -> void:
	var wp := _walk_points(id)
	bonus[id] = clampi(int(bonus.get(id, 0)) + n, -wp, MAX_POINTS - wp)
	met[id] = true


# A trek arrived (TrekSystem._on_arrived calls this, before the walk is counted): the walk to the wood's edge
# is Maren's first, and a walk by night counts for more.
func _on_walked(id: String, by_night: bool) -> void:
	if id == "edge":
		_add("mill", EDGE_POINTS)
		return
	if not FOLK.has(id):
		return
	met[id] = true
	if by_night:
		_add(id, NIGHT_WALK_POINTS)


func _name(id: String) -> String:
	return str(FOLK[id]["name"])


func _short(id: String) -> String:
	return m.trek._cap(str(FOLK[id]["short"]))


# --- The day's visitor --------------------------------------------------------------------------

# Walkers wait at the gate today, so nobody comes by the farm.
func _gate_day(d: int) -> bool:
	return m.trek._walker_day(d) and m.trek._route_open("mill")


func _can_visit(id: String) -> bool:
	var f: Dictionary = FOLK[id]
	if m.day < int(f["from"]) or (bool(f.get("edge", false)) and not m.trek.edge_done):
		return false
	if id == "orchard" and m.act._davy_gone():   # Davy's night, and after it if he went in (StoryAct)
		return false
	return true


# Picks today's visitor (morning true when a new day has begun, so it is announced), and where they stand.
func _start_day(morning: bool) -> String:
	present = ""
	if visit_day != m.day:
		visit_day = m.day
		visitor = _pick(m.day)
	spot = _spot(visitor) if visitor != "" else Vector2i(-1, -1)
	if spot.x < 0:
		visitor = ""
	if not morning or visitor == "":
		return ""
	return " %s has come up the lane and is %s, until four." % [_name(visitor), str(FOLK[visitor]["where"])]


func _pick(d: int) -> String:
	if d < 5 or _gate_day(d):
		return ""
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([d, "visit"])
	if rng.randi() % VISIT_EVERY != 0:
		return ""
	var open: Array = IDS.filter(func(id: String) -> bool: return _can_visit(id))
	if open.is_empty():
		return ""
	var waiting: Array = open.filter(func(id: String) -> bool: return not _next_scene(id).is_empty())
	if not waiting.is_empty() and rng.randf() < SCENE_PICK:
		return str(waiting[rng.randi() % waiting.size()])
	return str(open[rng.randi() % open.size()])


func _visiting() -> bool:
	if visitor == "orchard" and m.act._davy_waiting():   # Davy at the great tree on his night (StoryAct)
		return true
	return visitor != "" and visit_day == m.day and spot.x >= 0 and not m.trek.active \
		and m.current_hour >= VISIT_FROM and m.current_hour < VISIT_UNTIL


# On the farm now: visiting, or waiting at the gate.
func _here(id: String) -> bool:
	return (_visiting() and visitor == id) or m.trek._waiting(id)


# Where a visitor stands: the open tile nearest their place on the farm.
func _spot(id: String) -> Vector2i:
	return _spot_at(str(FOLK[id]["spot"]))


# The open tile nearest a place on the farm: stand, pond, tree or door.
func _spot_at(place: String) -> Vector2i:
	var anchor := Vector2i(-1, -1)
	match place:
		"stand":
			anchor = m._world_tile(m.STALL_IX + 1, m.STALL_IY + m.STALL_TILES.y + 1)
		"pond":
			anchor = _pond_middle()
		"tree":
			anchor = m._big_tree_origin() + Vector2i(-1, 3)
		"door":
			anchor = m._world_tile(m.HOUSE_DOOR_IX + 2, m.HOUSE_DOOR_IY + 1)
	if anchor.x < 0:
		return anchor
	# Nearest open tile, by a widening search.
	for r in range(0, 8):
		var best := Vector2i(-1, -1)
		for y in range(anchor.y - r, anchor.y + r + 1):
			for x in range(anchor.x - r, anchor.x + r + 1):
				if maxi(absi(x - anchor.x), absi(y - anchor.y)) != r:
					continue
				var t := Vector2i(x, y)
				if _open(t) and (best.x < 0 or (t - anchor).length_squared() < (best - anchor).length_squared()):
					best = t
		if best.x >= 0:
			return best
	return Vector2i(-1, -1)


func _pond_middle() -> Vector2i:
	var sum := Vector2.ZERO
	var n := 0
	for y in range(m.BORDER_Y, m.BORDER_Y + m.INNER_H):
		for x in range(m.BORDER_X, m.BORDER_X + m.INNER_W):
			if m.map[y][x] == MainGame.Tile.WATER:
				sum += Vector2(x, y)
				n += 1
	return Vector2i(sum / n) if n > 0 else Vector2i(-1, -1)


func _open(t: Vector2i) -> bool:
	if not m._in_bounds(t) or not m.map[t.y][t.x] in [MainGame.Tile.GRASS, MainGame.Tile.PATH]:
		return false
	if m.crops.has(t) or m.brush.has(t) or m.rocks.has(t) or m.projects.decor.has(t) or t == m.happenings.tile:
		return false
	# Not in the doorway, nor on the pedlar's spot.
	return t != m._world_tile(m.HOUSE_DOOR_IX, m.HOUSE_DOOR_IY + 1) \
		and t != m._world_tile(DailyHappenings.PEDLAR_SPOT.x, DailyHappenings.PEDLAR_SPOT.y)


# Space on the farm. Returns true when the press was used.
func _try_visit(tile: Vector2i) -> bool:
	if not _visiting() or m.inside or m.in_cave:
		return false
	if tile != spot and m.player.position.distance_to(m._tile_center(spot.x, spot.y)) > m.PX * 1.4:
		return false
	_talk_ui(visitor)
	return true


# A word at the gate (TrekSystem._try_walker): it counts for the day, and a request in hand is delivered.
func _on_gate(id: String) -> void:
	if not FOLK.has(id):
		return
	present = id
	met[id] = true
	var req := _active_request(id)
	if not req.is_empty() and _has_wants(req):
		_say(id, "smile", _deliver(req))
	if int(talk_day.get(id, -1)) != m.day:
		talk_day[id] = m.day
		_add(id, TALK_POINTS)


# --- Talking ------------------------------------------------------------------------------------

# What happens when you speak to a visitor (the balance sim calls this too): {kind: scene, scene}, {kind: line,
# text, expr}, or {kind: again} once you've had today's word.
func _talk(id: String) -> Dictionary:
	present = id
	met[id] = true
	var first := int(talk_day.get(id, -1)) != m.day
	if first:
		talk_day[id] = m.day
		_add(id, TALK_POINTS)
	# The second year's beats come before a walker's own talk (StoryAct): the town's letter, Davy's night.
	var sc := m.act._folk_scene(id)
	if sc.is_empty():
		sc = _next_scene(id)
	if not sc.is_empty():
		return {"kind": "scene", "scene": sc}
	var req := _active_request(id)
	if not req.is_empty() and _has_wants(req):
		return {"kind": "line", "text": _deliver(req), "expr": "smile"}
	if not first:
		return {"kind": "again"}
	var line := _line(id)
	var text := str(line["t"])
	var offer := _offer_request(id)
	if not offer.is_empty():
		text += " " + str(offer["ask"])
	elif not req.is_empty():
		text += " (%s: %s.)" % [str(req["title"]), _want_text(req)]
	return {"kind": "line", "text": text, "expr": str(line.get("e", "neutral"))}


func _talk_ui(id: String) -> void:
	var r := _talk(id)
	match str(r["kind"]):
		"scene":
			var sc: Dictionary = r["scene"]
			m.play_sfx("panel", 0.03)
			dialogue.play(sc["pages"], func() -> void: _scene_done(id, sc), "Space: next")
		"line":
			_say(id, str(r["expr"]), str(r["text"]))
			if gifts_given == 0:
				m._show_message("Press Space again to give %s something from your pack." % FOLK[id]["short"])
		"again":
			_open_folk()


func _say(id: String, expr: String, text: String) -> void:
	if dialogue != null:
		dialogue.say(id, expr, text, (m.MESSAGE_SECONDS + text.length() / 30.0) * GameSettings.message_scale())


# Words on a trek: the walker's line in the dialogue box, with a face for their nerve.
func _say_trek(route: String, text: String, nerve: float) -> void:
	_say(route, "worry" if nerve < 40.0 else ("far" if route == "grove" else "neutral"), text)


func _open_folk() -> void:
	m.action_bar.ledger_tabs["Quests"] = 1
	if m.open_tab != "Quests":
		m._toggle_tab("Quests")


func _in_scene() -> bool:
	return dialogue != null and dialogue.in_scene()


# While a scene is open: Space, Enter, A or a click turns the page.
func _scene_keys() -> void:
	if Input.is_action_just_pressed("use") or Input.is_action_just_pressed("tool_use") or Input.is_action_just_pressed("ui_accept"):
		dialogue.advance()


# A scene has been seen to its end (the balance sim calls this too): its gift, and the Folk tab notes it.
func _scene_done(id: String, sc: Dictionary) -> void:
	if sc.has("act"):
		m.act._on_scene(sc)
		return
	seen[str(sc["id"])] = m.day
	var gift: Dictionary = sc.get("gift", {})
	var got := _give_reward(gift)
	m._show_message("%s: \"%s\" is written in Quests, Folk.%s" % [_name(id), str(sc["title"]), (" " + got) if got != "" else ""])


# The next scene that is due: the first not seen, once the hearts (and for the last, the day) allow it, and
# SCENE_GAP days after the one before.
func _next_scene(id: String) -> Dictionary:
	var list: Array = SCENES.get(id, [])
	var last := -SCENE_GAP
	for i in list.size():
		var sc: Dictionary = list[i]
		if seen.has(str(sc["id"])):
			last = int(seen[str(sc["id"])])
			continue
		if m.day - last < SCENE_GAP:
			return {}
		if _hearts(id) >= int(SCENE_HEARTS[i]) and m.day >= int(sc.get("day", 0)):
			return sc
		return {}
	return {}


func _scenes_seen(id: String) -> int:
	var n := 0
	for sc in SCENES.get(id, []):
		if seen.has(str(sc["id"])):
			n += 1
	return n


# Today's line: from those that fit the season, the hearts and the story, picked by the day. Lines tied to a
# season or the story come up twice as often as the everyday ones.
func _line(id: String) -> Dictionary:
	var season := m._season_of(m._calendar_date(m.day)["month"])
	var h := _hearts(id)
	var pool: Array = []
	for line in LINES[id]:
		if line.has("s") and str(line["s"]) != season:
			continue
		if h < int(line.get("h", 0)) or h > int(line.get("x", 10)):
			continue
		if line.has("if") and not _cond(id, str(line["if"])):
			continue
		pool.append(line)
		if line.has("s") or line.has("if"):
			pool.append(line)
	if pool.is_empty():
		return {"t": "\"Morning.\""}
	return pool[hash([m.day, id, "line"]) % pool.size()]


func _cond(id: String, c: String) -> bool:
	match c:
		"walked":
			return int(m.trek.walked.get(id, 0)) > 0
		"bell":
			return m.projects._has_bell()
		"grove":
			return m.trek.grove_done
		"nogrove":
			return not m.trek.grove_done
	return false


# --- Gifts ------------------------------------------------------------------------------------

func _taste(id: String, key: String) -> String:
	for t in ["loved", "liked", "disliked"]:
		if key in FOLK[id][t]:
			return t
	return "neutral"


func _can_give(id: String) -> bool:
	return FOLK.has(id) and _here(id) and m.day - int(gift_day.get(id, -GIFT_DAYS)) >= GIFT_DAYS


# Gives one of a pack food to the walker you last spoke to (the Folk tab's Give). Returns what they said.
func _give(key: String, id := "") -> String:
	if id == "":
		id = present
	if not _can_give(id) or m._held(key) <= 0:
		return ""
	_take(key, 1)
	var t := _taste(id, key)
	_add(id, int(GIFT_POINTS[t]))
	tastes["%s:%s" % [id, key]] = t
	gift_day[id] = m.day
	gifts_given += 1
	m.progression._bump("gifts")
	var text := str(FOLK[id]["react"][t])
	_say(id, {"loved": "smile", "liked": "smile", "neutral": "neutral", "disliked": "grim"}[t], text)
	m.play_sfx("coin" if t in ["loved", "liked"] else "panel", 0.03)
	return text


# The food a walker would like best of what you hold, loved before liked (the balance sim gives it), or "".
func _best_gift(id: String, keep := 0) -> String:
	for t in ["loved", "liked"]:
		for key in FOLK[id][t]:
			if m._held(str(key)) > keep:
				return str(key)
	return ""


func _take(key: String, n: int) -> void:
	if key == "coins":
		m.money -= n
	elif m.materials.has(key):
		m.materials[key] = int(m.materials[key]) - n
	else:
		m.inventory[key] = int(m.inventory.get(key, 0)) - n


# --- Requests ---------------------------------------------------------------------------------

func _request(rid: String) -> Dictionary:
	for r in REQUESTS:
		if str(r["id"]) == rid:
			return r
	return {}


func _active_request(id: String) -> Dictionary:
	for rid in requests:
		var r := _request(str(rid))
		if not r.is_empty() and str(r["who"]) == id:
			return r
	return {}


func _has_wants(r: Dictionary) -> bool:
	for key in r["want"]:
		if m._held(str(key)) < int(r["want"][key]):
			return false
	return true


# On the first word of a visit, a walker with nothing asked may ask for the next request they have.
func _offer_request(id: String) -> Dictionary:
	if not _visiting() or visitor != id or not _active_request(id).is_empty():
		return {}
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([m.day, id, "request"])
	if rng.randf() >= REQUEST_CHANCE:
		return {}
	var season := m._season_of(m._calendar_date(m.day)["month"])
	for r in REQUESTS:
		if str(r["who"]) != id or requests_done.has(r["id"]) or _hearts(id) < int(r["hearts"]):
			continue
		if r.has("season") and str(r["season"]) != season:
			continue
		requests[str(r["id"])] = m.day
		return r
	return {}


# Hands over what a request wants. Returns their thanks and what they gave.
func _deliver(r: Dictionary) -> String:
	for key in r["want"]:
		_take(str(key), int(r["want"][key]))
	requests.erase(str(r["id"]))
	requests_done[str(r["id"])] = m.day
	_add(str(r["who"]), REQUEST_POINTS)
	m.progression._bump("requests")
	var got := _give_reward(r["reward"])
	m.play_sfx("coin", 0.03)
	m._show_message("%s: %s done. %s" % [_name(str(r["who"])), str(r["title"]), got])
	return str(r["thanks"])


func _give_reward(reward: Dictionary) -> String:
	var parts: Array = []
	for key in reward:
		var n := int(reward[key])
		match str(key):
			"coins":
				m.money += n
				parts.append("+%d coins" % n)
			"sanity":
				m.sanity_sys._change_sanity(float(n))
				parts.append("+%d sanity" % n)
			_:
				if m.materials.has(key):
					m.materials[key] = int(m.materials[key]) + n
				else:
					m.inventory[key] = int(m.inventory.get(key, 0)) + n
				parts.append("+%d %s" % [n, _label(str(key))])
	return ", ".join(parts) + ("." if not parts.is_empty() else "")


func _label(key: String) -> String:
	var f := Foods.by_held(key)
	if not f.is_empty():
		return str(f["name"]).to_lower()
	return m.panels._need_label(key)


func _want_text(r: Dictionary) -> String:
	var parts: Array = []
	for key in r["want"]:
		parts.append("%d %s" % [int(r["want"][key]), _label(str(key))])
	return ", ".join(parts)


# --- The Folk tab (Quests) ---------------------------------------------------------------------

func _rows() -> Array:
	var rows: Array = [{"tab": "Folk"}]
	if present != "" and _here(present):
		var id := present
		rows.append({"section": "Give %s something" % FOLK[id]["short"]})
		if not _can_give(id):
			rows.append({"note": "You've given %s something this week. One gift a week." % FOLK[id]["short"]})
		else:
			var any := false
			for f in Foods.LIST:
				var key := str(f["held"])
				if m._held(key) <= 0 or f.get("inedible", false):
					continue
				any = true
				var known := str(tastes.get("%s:%s" % [id, key], ""))
				rows.append({"name": str(f["name"]), "status": known.capitalize() if known != "" else "Give",
					"status_kind": "short" if known == "disliked" else ("ok" if known != "neutral" else "info"),
					"value": "%d held" % m._held(key),
					"about": "You know what %s thinks of it." % FOLK[id]["short"] if known != "" else "You don't know yet what %s thinks of it." % FOLK[id]["short"],
					"button": "Give", "action": "folk_gift:" + key, "enabled": true})
			if not any:
				rows.append({"note": "You have nothing in your pack to give."})
	var shown := false
	for id in IDS:
		if not met.has(id) and _points(id) <= 0:
			continue
		if not shown:
			rows.append({"section": "Walkers"})
			shown = true
		rows.append(_walker_row(id))
	if not shown:
		rows.append({"note": "Nobody from the lane knows you yet."})
	var asked: Array = []
	for r in REQUESTS:
		if requests.has(r["id"]) or requests_done.has(r["id"]):
			asked.append(r)
	if not asked.is_empty():
		rows.append({"section": "Requests"})
		for r in asked:
			var done := requests_done.has(r["id"])
			var ready := not done and _has_wants(r)
			var row := {"name": str(r["title"]), "value": "For %s" % (_name(str(r["who"])) if str(r["who"]) in ["mill", "orchard"] else str(FOLK[r["who"]]["short"])),
				"status": "Done" if done else ("Ready" if ready else "Not yet"),
				"status_kind": "done" if done else ("ok" if ready else "short"),
				"about": str(r["ask"]), "note": "Reward: " + _give_reward_text(r["reward"])}
			if not done:
				row["needs"] = m.panels._needs(r["want"], "")
				if ready and _here(str(r["who"])):
					row["button"] = "Hand over"
					row["action"] = "folk_req:" + str(r["id"])
					row["enabled"] = true
			rows.append(row)
	rows.append({"note": "Walks, a word each day, gifts and help raise friendship. Talk to someone on the farm, then press Space again to give them something. Neighbours come by on days nobody waits at the gate."})
	return rows


func _walker_row(id: String) -> Dictionary:
	var h := _hearts(id)
	var known: Array = []
	for t in ["loved", "liked"]:
		for key in FOLK[id][t]:
			if str(tastes.get("%s:%s" % [id, key], "")) == t:
				known.append("%s (%s)" % [_label(str(key)), t])
	var notes: Array = []
	if TrekSystem.STANDING.has(id):
		var at := int(TrekSystem.STANDING[id]["at"])
		notes.append(("Knows you: " if h >= at else "At %d heart%s: " % [at, "" if at == 1 else "s"]) + m.trek._cap(str(TrekSystem.STANDING[id]["about"]).trim_prefix("Once %s knows you, " % FOLK[id]["short"])))
	var seen_titles: Array = []
	for sc in SCENES[id]:
		if seen.has(str(sc["id"])):
			seen_titles.append(str(sc["title"]))
	var next_at := -1
	var n := _scenes_seen(id)
	if n < SCENE_HEARTS.size():
		next_at = int(SCENE_HEARTS[n])
	var scenes := "Heard: %s." % ", ".join(seen_titles) if not seen_titles.is_empty() else "They haven't told you much yet."
	if next_at > 0:
		scenes += " More at %d hearts." % next_at
	return {"name": _name(id), "status": "%d / 10 hearts" % h, "status_kind": "info",
		"value": str(FOLK[id]["about"]), "progress": float(_points(id)) / MAX_POINTS,
		"about": ("Likes: %s." % ", ".join(known)) if not known.is_empty() else "Give gifts to learn what they like.",
		"note": " ".join(notes + [scenes])}


func _give_reward_text(reward: Dictionary) -> String:
	var parts: Array = []
	for key in reward:
		parts.append("%d %s" % [int(reward[key]), "coins" if key == "coins" else ("sanity" if key == "sanity" else _label(str(key)))])
	return ", ".join(parts)


# --- Saving -----------------------------------------------------------------------------------

func _to_save() -> Dictionary:
	return {"bonus": bonus, "met": met.keys(), "seen": seen, "tastes": tastes, "requests": requests,
		"requests_done": requests_done, "talk_day": talk_day, "gift_day": gift_day, "gifts_given": gifts_given,
		"visit_day": visit_day, "visitor": visitor}


func _from_save(d: Variant) -> void:
	bonus = {}
	met = {}
	seen = {}
	tastes = {}
	requests = {}
	requests_done = {}
	talk_day = {}
	gift_day = {}
	gifts_given = 0
	visit_day = 0
	visitor = ""
	if typeof(d) != TYPE_DICTIONARY:
		return
	for key in ["bonus", "seen", "requests", "requests_done", "talk_day", "gift_day"]:
		var src: Variant = d.get(key, {})
		if typeof(src) == TYPE_DICTIONARY:
			var dst: Dictionary = get(key)
			for k in src:
				dst[str(k)] = int(src[k])
	var t: Variant = d.get("tastes", {})
	if typeof(t) == TYPE_DICTIONARY:
		for k in t:
			tastes[str(k)] = str(t[k])
	for id in d.get("met", []):
		met[str(id)] = true
	gifts_given = int(d.get("gifts_given", 0))
	visit_day = int(d.get("visit_day", 0))
	visitor = str(d.get("visitor", ""))
	if visitor != "" and not FOLK.has(visitor):
		visitor = ""
