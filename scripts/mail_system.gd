class_name MailSystem
extends RefCounted

# CCH-CONSOLIDATED-003 Phase B: the post comes to the mailbox by the east gate, beside the farm stand, not to the
# desk in the house. Everything that arrives by post lands here: catalog deliveries, the tax bills and notices, the
# receipts, the town clerk's letters. Opening the mailbox reads them all; read letters can be put away.
# A raised flag shows that something unread waits (no light). The letters are still saved as "desk_mail", so old
# saves keep their letters with their read and unread state.

var m: MainGame

const MAILBOX_IX := Vector2i(53, 32)    # inner farm tile, where the concept farm put the mailbox (west of the stand)
const FLAG_TIME := 0.32                  # seconds for the flag to swing up or down
const LID_TIME := 0.9                    # seconds the lid stays open after the mailbox is checked
const PROMPT_TEXT := "{hand}  Check the mail"

var flag := 0.0          # 0 down, 1 up: drawn by FarmScenery from the mailbox frames
var lid_left := 0.0      # seconds until the door shuts again
var prompt: Label        # shown over the mailbox while the farmer faces it
var prompt_layer: CanvasLayer   # on screen, so the night's tint doesn't darken the prompt


func _init(main: MainGame) -> void:
	m = main


# The mailbox's tile in world tiles.
func _tile() -> Vector2i:
	return MAILBOX_IX + Vector2i(m.BORDER_X, m.BORDER_Y)


func _stamp() -> void:
	var t := _tile()
	m.map[t.y][t.x] = MainGame.Tile.MAILBOX


# --- Letters ---

func _add_letter(title: String, text: String) -> void:
	m.desk_mail.append({"title": title, "text": text, "unread": true})


func _unread_count() -> int:
	var n := 0
	for letter in m.desk_mail:
		if bool(letter["unread"]):
			n += 1
	return n


func _has_read_mail() -> bool:
	for letter in m.desk_mail:
		if not bool(letter["unread"]):
			return true
	return false


func _clear_read_mail() -> void:
	var kept: Array = []
	for letter in m.desk_mail:
		if bool(letter["unread"]):
			kept.append(letter)
	m.desk_mail = kept
	m._show_message("You take the read letters out of the mailbox and keep them.")


# The flag is up while anything waits unread.
func _flag_up() -> bool:
	return _unread_count() > 0


# Old saves: letters from before the move keep their state. A letter missing a field gets a safe default
# (unread, so nothing in it is missed); anything that is not a letter is dropped.
static func migrate(letters: Variant) -> Array:
	var out: Array = []
	if not (letters is Array):
		return out
	for letter in letters:
		if not (letter is Dictionary):
			continue
		out.append({"title": str(letter.get("title", "Letter")), "text": str(letter.get("text", "")),
			"unread": bool(letter.get("unread", true))})
	return out


# --- The mailbox ---

func _open_mailbox() -> void:
	lid_left = LID_TIME
	m.play_sfx_at("door", -8.0)
	for letter in m.desk_mail:
		letter["unread"] = false
	m._toggle_tab("Mailbox")


func _action(action_id: String) -> void:
	if action_id == "mail_clear":
		_clear_read_mail()
	m._refresh_panel()


func _lid_open() -> bool:
	return lid_left > 0.0


# Each frame (main._process, paused or not): swing the flag toward its state, count down the open door, and show
# the prompt while the farmer faces the mailbox with nothing else on screen.
func _update(delta: float) -> void:
	if m.open_tab == "":
		lid_left = maxf(0.0, lid_left - delta)   # the door stays open while the letters are read
	var target := 1.0 if _flag_up() else 0.0
	flag = move_toward(flag, target, delta / FLAG_TIME)
	if prompt == null:
		return
	var show: bool = not m.inside and not m.in_cave and m.open_tab == "" and not m.player.paused and m.placing == "" and m._tile_in_front() == _tile()
	prompt.visible = show
	if show:
		prompt.text = m._fill_controls(PROMPT_TEXT)
		prompt.reset_size()
		var top := m._tile_center(_tile().x, _tile().y) + Vector2(0, -m.PX * 1.9)
		var xf := m.get_viewport().get_canvas_transform()
		var at := xf * top
		prompt.position = (at - Vector2(prompt.size.x * 0.5, prompt.size.y)).round()


func _build_prompt() -> void:
	prompt_layer = CanvasLayer.new()
	prompt_layer.layer = 5
	m.add_child(prompt_layer)
	prompt = Label.new()
	prompt.visible = false
	prompt.add_theme_font_size_override("font_size", 14)
	prompt.add_theme_color_override("font_color", Color("e8dcc0"))
	prompt.add_theme_color_override("font_outline_color", Color("151009"))
	prompt.add_theme_constant_override("outline_size", 4)
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.08, 0.06, 0.04, 0.78)
	box.border_color = Color("8a6a3a")
	box.set_border_width_all(1)
	box.set_content_margin_all(4)
	box.content_margin_left = 7
	box.content_margin_right = 7
	prompt.add_theme_stylebox_override("normal", box)
	prompt_layer.add_child(prompt)
