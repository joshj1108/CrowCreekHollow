class_name UiTheme
extends RefCounted

# UI-OVERHAUL-001 Phase 1: the one Godot Theme every menu will share. It builds on UiSkin's SpriteCook kit
# (art/ui/: the wood-and-iron panel, buttons and parchment card as 9-slices) and draws the pieces the kit has
# no art for in code (tabs' shading, focus ring, tooltip, scrollbar, badge, divider, list entries, key glyphs),
# all in the spec's palette. build() makes it; tools/build_ui_theme.gd saves it to THEME_PATH so it can be
# opened in the editor, and get() loads that file (or builds it when the file is missing).
#
# Components are Godot types or type variations, so a control only sets theme_type_variation:
#   Button              primary button (the kit's wood): normal, hover, pressed, focus ring, disabled
#   SecondaryButton     plain charred-wood button for lesser actions (No, Back)
#   TabActive           the open tab: the kit's gold-edged board, lantern-gold text
#   TabInactive         the other tabs: the board darkened, muted text; hover lifts it
#   ListEntry           one line of a list: charred wood, brass edge on hover, gold ring on focus
#   MenuFrame           a menu's outer frame (the kit's panel)
#   DialogPanel         a confirmation dialog's frame
#   DescriptionPanel    the parchment page for details; its text uses the Ink* label variations
#   TooltipPanel / TooltipLabel   Godot's own tooltip types
#   Badge, BadgeAlert   a small count on a tab or icon: gold for news, rust for warnings
#   KeyGlyph            a boxed key or pad button name in the footer prompts
#   HSeparator          the divider: a brass rule with a dark lip
#   VScrollBar          a thin dark track with a walnut grabber, brass when held
#   ProgressBar, InkProgress   a meter on dark wood, and on parchment
#   DisplayTitle, Subtitle, SectionHeading, NumberLabel, Ink*   the typography roles (see FONTS below)
# Phase 2 (readability, hierarchy, Inventory):
#   ScrollContainer     every list and grid sits in a recessed dark well, so it reads apart from the frame's wood
#   PlainScroll         a scroll with no well (the detail column, whose card is its own panel)
#   FooterBar           the footer's dark band under a brass rule: prompts and Close
#   Card                one row of values (Coins, Pack space): dark wood, a dim iron edge; CardValue its value
#   Slot, SlotSelected, SlotLocked   an inventory slot: occupied, the picked one, unavailable; hover and the
#                       focus ring are the slot's own states. SlotEmpty (a PanelContainer) is a free slot
#   SlotCount           the quantity in a slot's corner; SlotCaption the line naming the slot in focus
#   GroupHeading        a slot group's name, with its count in a NumberLabel beside it
#   mark_active_tab()   the open tab's gold bar along its foot, the clearest sign of which tab is open
#
# Focus is never the same as hover: hover lightens a control and edges it in brass; focus draws a lantern-gold
# ring around it, over whatever state it is in, so the keyboard or pad's place is always visible.

const THEME_PATH := "res://art/ui/theme/crow_creek_ui.tres"

# The spec's palette (UI_OVERHAUL_001_SPEC.md section 2), which matches action_bar.gd's colours.
const SHADOW := Color("151009")
const CHARRED := Color("231a12")
const LEATHER := Color("3b2417")
const WALNUT := Color("6b5340")
const BRASS := Color("8a6a3a")
const PARCHMENT := Color("c4ae84")
const LINEN := Color("8f7a54")
const IVORY := Color("e8dcc0")
const BEIGE := Color("9a8a6a")
# Phase 2: muted text on dark wood, lifted from BEIGE so small text reads (about 7:1 on CHARRED; BEIGE is 5:1).
const MUTED := Color("b8a682")
const MOSS := Color("8fb069")
const RUST := Color("d0705a")
const GOLD := Color("d8b050")
# Ink on parchment: the same meanings, dark enough to read on the aged cream (contrast 6:1 or better).
const INK := Color("2a1d12")
const INK_HEADING := Color("4a2c12")
const INK_MUTED := Color("46331f")   # Phase 2: darker, so notes on parchment read (was 5a4630)
const INK_GOOD := Color("3d5a1e")
const INK_WARN := Color("8a2e1c")
# In-between shades the components need.
const WOOD_DARK := Color("1b140d")
const WOOD_HOVER := Color("2e2218")
const WOOD_PRESSED := Color("3a2a18")
const EDGE_DIM := Color("3d3024")
const WELL := Color(0.043, 0.031, 0.02, 0.82)   # the recessed list well, over the frame's planks
const IRON := Color("4f4234")

# Typography roles. There are no licensed font files in the project yet, so all three are variations of
# Godot's default font for now; a chosen font replaces the base in one place (_font) without touching menus.
#   display: headings and titles, emboldened and spaced, with a dark outline so it holds over any background
#   body:    descriptions, list lines and the diary, plain and readable
#   numbers: coins, time, counts and stats, with tabular figures so columns of digits line up
# Sizes: display 30 (menu title), 20 (detail heading); body 16 (14 for notes and hints); numbers 14-16.
# Phase 2 raised body 15 -> 16 and small 13 -> 14, and adds 2 px between wrapped lines, for 1280 x 720.
const SIZE_DISPLAY := 30
const SIZE_HEADING := 20
const SIZE_BODY := 16
const SIZE_SMALL := 14
const LINE_SPACING := 2

static var _theme: Theme


# The shared theme: the saved file when it is there, otherwise built now. Cached for the session.
static func get_theme() -> Theme:
	if _theme == null:
		if ResourceLoader.exists(THEME_PATH):
			_theme = load(THEME_PATH) as Theme
		if _theme == null:
			_theme = build()
	return _theme


static func _font(role: String) -> FontVariation:
	var f := FontVariation.new()
	# No base_font: the variation then uses the project's default font.
	match role:
		"display":
			f.variation_embolden = 0.5
			f.spacing_glyph = 1
		"numbers":
			f.opentype_features = {TextServerManager.get_primary_interface().name_to_tag("tnum"): 1}
	return f


static func _flat(bg: Color, border: Color, width: int, margin_x: int, margin_y: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(width)
	# Square corners and no anti-aliasing, so the code-drawn pieces stay pixel-crisp beside the kit art.
	sb.anti_aliasing = false
	sb.content_margin_left = margin_x
	sb.content_margin_right = margin_x
	sb.content_margin_top = margin_y
	sb.content_margin_bottom = margin_y
	return sb


# The focus ring: a lantern-gold outline with a dark line inside it, drawn just outside the control.
static func focus_ring(outset := 3) -> StyleBoxFlat:
	var sb := _flat(Color(0, 0, 0, 0), GOLD, 2, 0, 0)
	sb.draw_center = false
	sb.expand_margin_left = outset
	sb.expand_margin_right = outset
	sb.expand_margin_top = outset
	sb.expand_margin_bottom = outset
	sb.shadow_color = Color(SHADOW, 0.9)
	sb.shadow_size = 1
	return sb


static func _kit_button(state: String, tint := Color.WHITE) -> StyleBox:
	var sb := UiSkin.button(state)
	if sb == null:
		return null
	sb.modulate_color = tint
	return sb


# The parchment card, 9-sliced at its nailed corners.
static func parchment(content_x := 30, content_y := 26) -> StyleBox:
	var tex: Texture2D = UiSkin._tex("card_parchment")
	if tex == null:
		var flat := _flat(PARCHMENT, LEATHER, 3, content_x, content_y)
		return flat
	var sb := StyleBoxTexture.new()
	sb.texture = tex
	sb.set_texture_margin_all(28)
	sb.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	sb.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	sb.content_margin_left = content_x
	sb.content_margin_right = content_x
	sb.content_margin_top = content_y
	sb.content_margin_bottom = content_y
	return sb


static func _set_button(t: Theme, type: String, boxes: Dictionary, colors: Dictionary) -> void:
	for state in boxes:
		if boxes[state] != null:
			t.set_stylebox(state, type, boxes[state])
	for key in colors:
		t.set_color(key, type, colors[key])


static func build() -> Theme:
	var t := Theme.new()
	var body := _font("body")
	var display := _font("display")
	var numbers := _font("numbers")
	t.default_font = body
	t.default_font_size = SIZE_BODY
	t.set_color("font_color", "Label", IVORY)
	t.set_constant("line_spacing", "Label", LINE_SPACING)

	# --- Buttons ---------------------------------------------------------------------------------------
	var flat_normal := _flat(WOOD_HOVER, BRASS, 2, 14, 8)
	_set_button(t, "Button", {
		"normal": _kit_button("normal") if UiSkin.button("normal") != null else flat_normal,
		"hover": _kit_button("hover") if UiSkin.button("hover") != null else _flat(Color("43321f"), GOLD, 2, 14, 8),
		"pressed": _kit_button("pressed") if UiSkin.button("pressed") != null else _flat(Color("65472a"), GOLD, 2, 14, 8),
		"disabled": _kit_button("disabled", Color(0.8, 0.8, 0.8)) if UiSkin.button("disabled") != null else _flat(CHARRED, EDGE_DIM, 2, 14, 8),
		"focus": focus_ring(),
	}, {"font_color": IVORY, "font_hover_color": Color("f4ead2"), "font_pressed_color": GOLD,
		"font_focus_color": IVORY, "font_hover_pressed_color": GOLD, "font_disabled_color": Color(BEIGE, 0.7)})

	t.set_type_variation("SecondaryButton", "Button")
	_set_button(t, "SecondaryButton", {
		"normal": _flat(CHARRED, WALNUT, 2, 14, 8),
		"hover": _flat(WOOD_HOVER, BRASS, 2, 14, 8),
		"pressed": _flat(WOOD_PRESSED, GOLD, 2, 14, 8),
		"disabled": _flat(WOOD_DARK, Color("2e2218"), 2, 14, 8),
		"focus": focus_ring(),
	}, {"font_color": MUTED, "font_hover_color": IVORY, "font_pressed_color": GOLD, "font_focus_color": IVORY,
		"font_disabled_color": Color(BEIGE, 0.5)})

	# --- Tabs: the open one is the gold-edged board with lantern-gold display text (and mark_active_tab's bar);
	# the rest are the board well into shadow, with muted text that a hover lifts to ivory ------------------------
	t.set_type_variation("TabActive", "Button")
	_set_button(t, "TabActive", {
		"normal": _kit_button("hover"), "hover": _kit_button("hover"), "pressed": _kit_button("hover"),
		"disabled": _kit_button("hover", Color(0.7, 0.7, 0.7)), "focus": focus_ring(),
	}, {"font_color": GOLD, "font_hover_color": GOLD, "font_pressed_color": GOLD, "font_focus_color": GOLD,
		"font_outline_color": SHADOW})
	t.set_constant("outline_size", "TabActive", 3)
	t.set_font("font", "TabActive", display)
	t.set_type_variation("TabInactive", "Button")
	var shade := Color(0.5, 0.47, 0.44)
	_set_button(t, "TabInactive", {
		"normal": _kit_button("normal", shade), "hover": _kit_button("normal", Color(0.85, 0.82, 0.78)),
		"pressed": _kit_button("pressed"), "disabled": _kit_button("disabled", Color(0.4, 0.4, 0.4)), "focus": focus_ring(),
	}, {"font_color": MUTED, "font_hover_color": IVORY, "font_pressed_color": GOLD, "font_focus_color": IVORY,
		"font_disabled_color": Color(BEIGE, 0.45)})

	# --- List entries: the focused (picked) line is lit, ringed in gold and marked by a gold bar on its left -----
	t.set_type_variation("ListEntry", "Button")
	var entry_focus := _flat(Color(GOLD, 0.10), GOLD, 2, 14, 0)
	entry_focus.border_width_left = 5
	_set_button(t, "ListEntry", {
		"normal": _flat(CHARRED, EDGE_DIM, 1, 14, 0),
		"hover": _flat(WOOD_HOVER, BRASS, 1, 14, 0),
		"pressed": _flat(WOOD_PRESSED, GOLD, 1, 14, 0),
		"disabled": _flat(WOOD_DARK, Color("2a2018"), 1, 14, 0),
		"focus": entry_focus,
	}, {"font_color": IVORY, "font_disabled_color": Color(BEIGE, 0.6)})

	# --- Wells, cards and the footer band ---------------------------------------------------------------------
	var well := _flat(WELL, Color(SHADOW, 0.9), 1, 8, 8)
	well.border_width_top = 2
	t.set_stylebox("panel", "ScrollContainer", well)
	t.set_type_variation("PlainScroll", "ScrollContainer")
	t.set_stylebox("panel", "PlainScroll", StyleBoxEmpty.new())
	t.set_type_variation("FooterBar", "PanelContainer")
	var foot := _flat(Color(SHADOW, 0.55), Color(BRASS, 0.7), 0, 10, 8)
	foot.border_width_top = 1
	t.set_stylebox("panel", "FooterBar", foot)
	t.set_type_variation("Card", "PanelContainer")
	t.set_stylebox("panel", "Card", _flat(Color("1e1610"), EDGE_DIM, 1, 14, 9))

	# --- Inventory slots: drawn frames (tools/make_ui_slots.py), with the focus ring over them -------------------
	t.set_type_variation("Slot", "Button")
	_set_button(t, "Slot", {"normal": slot("occupied"), "hover": slot("hover"), "pressed": slot("picked"),
		"disabled": slot("locked"), "focus": focus_ring()}, {})
	t.set_type_variation("SlotSelected", "Button")
	_set_button(t, "SlotSelected", {"normal": slot("picked"), "hover": slot("picked"), "pressed": slot("picked"),
		"disabled": slot("locked"), "focus": focus_ring()}, {})
	t.set_type_variation("SlotLocked", "Button")
	_set_button(t, "SlotLocked", {"normal": slot("locked"), "hover": slot("hover"), "pressed": slot("picked"),
		"disabled": slot("locked"), "focus": focus_ring()}, {})
	t.set_type_variation("SlotEmpty", "PanelContainer")
	t.set_stylebox("panel", "SlotEmpty", slot("empty"))

	# --- Frames and panels -------------------------------------------------------------------------------
	t.set_type_variation("MenuFrame", "PanelContainer")
	var frame: StyleBox = UiSkin.panel(14)
	t.set_stylebox("panel", "MenuFrame", frame if frame != null else _flat(SHADOW, BRASS, 2, 14, 14))
	t.set_type_variation("DialogPanel", "PanelContainer")
	var dialog: StyleBox = UiSkin.panel(26)
	t.set_stylebox("panel", "DialogPanel", dialog if dialog != null else _flat(SHADOW, BRASS, 2, 26, 26))
	t.set_type_variation("DescriptionPanel", "PanelContainer")
	t.set_stylebox("panel", "DescriptionPanel", parchment())

	# --- Tooltip -------------------------------------------------------------------------------------------
	var tip := _flat(CHARRED, BRASS, 2, 10, 6)
	tip.shadow_color = Color(0, 0, 0, 0.55)
	tip.shadow_size = 3
	tip.shadow_offset = Vector2(2, 2)
	t.set_stylebox("panel", "TooltipPanel", tip)
	t.set_color("font_color", "TooltipLabel", IVORY)
	t.set_font_size("font_size", "TooltipLabel", SIZE_SMALL + 1)
	t.set_font("font", "TooltipLabel", body)

	# --- Scrollbar: a thin dark track and a walnut grabber, lit in brass on hover and gold while held -------
	var track := _flat(Color("120d09"), EDGE_DIM, 1, 5, 5)
	t.set_stylebox("scroll", "VScrollBar", track)
	t.set_stylebox("scroll_focus", "VScrollBar", track)
	t.set_stylebox("grabber", "VScrollBar", _flat(WALNUT, SHADOW, 1, 4, 4))
	t.set_stylebox("grabber_highlight", "VScrollBar", _flat(BRASS, SHADOW, 1, 4, 4))
	t.set_stylebox("grabber_pressed", "VScrollBar", _flat(GOLD, SHADOW, 1, 4, 4))

	# --- Divider: a brass rule with a dark lip under it -------------------------------------------------------
	var rule := StyleBoxFlat.new()
	rule.bg_color = BRASS
	rule.border_color = SHADOW
	rule.border_width_bottom = 1
	rule.content_margin_top = 1
	rule.content_margin_bottom = 1
	rule.anti_aliasing = false
	t.set_stylebox("separator", "HSeparator", rule)
	t.set_constant("separation", "HSeparator", 8)

	# --- Badges: a small count, gold for something new, rust for something wrong ---------------------------
	for pair in [["Badge", GOLD], ["BadgeAlert", RUST]]:
		t.set_type_variation(pair[0], "Label")
		var badge := _flat(pair[1], SHADOW, 1, 5, 0)
		t.set_stylebox("normal", pair[0], badge)
		t.set_color("font_color", pair[0], SHADOW)
		t.set_font_size("font_size", pair[0], 12)
		t.set_font("font", pair[0], numbers)

	# --- Key glyphs: a key cap with a deeper lip at the bottom ------------------------------------------------
	t.set_type_variation("KeyGlyph", "Label")
	var cap := _flat(WOOD_HOVER, BRASS, 1, 5, 1)
	cap.border_width_bottom = 3
	t.set_stylebox("normal", "KeyGlyph", cap)
	t.set_color("font_color", "KeyGlyph", IVORY)
	t.set_font_size("font_size", "KeyGlyph", 13)

	# --- Meters --------------------------------------------------------------------------------------------
	t.set_stylebox("background", "ProgressBar", _flat(Color("120d09"), LEATHER, 1, 0, 0))
	t.set_stylebox("fill", "ProgressBar", _flat(GOLD, Color("a07c30"), 1, 0, 0))
	t.set_type_variation("InkProgress", "ProgressBar")
	t.set_stylebox("background", "InkProgress", _flat(Color("a8916a"), LEATHER, 1, 0, 0))
	t.set_stylebox("fill", "InkProgress", _flat(Color("5e7a32"), INK_GOOD, 1, 0, 0))

	# --- Typography roles ------------------------------------------------------------------------------------
	_label(t, "DisplayTitle", display, SIZE_DISPLAY, GOLD, 4)
	_label(t, "DisplayHeading", display, SIZE_HEADING, GOLD, 3)
	_label(t, "Subtitle", body, 15, MUTED)
	_label(t, "SectionHeading", display, SIZE_SMALL, GOLD, 2)
	_label(t, "GroupHeading", display, SIZE_SMALL, GOLD, 2)
	_label(t, "NumberLabel", numbers, SIZE_SMALL, GOLD)
	_label(t, "Hint", body, SIZE_SMALL, MUTED)
	_label(t, "CardValue", numbers, 15, Color("d8c9a6"))
	_label(t, "SlotCount", numbers, SIZE_SMALL, IVORY, 3)
	_label(t, "SlotCaption", body, 15, IVORY)
	_label(t, "InkHeading", display, SIZE_HEADING, INK_HEADING)
	_label(t, "InkBody", body, SIZE_BODY, INK)
	_label(t, "InkMuted", body, SIZE_SMALL, INK_MUTED)
	_label(t, "InkGood", body, SIZE_BODY, INK_GOOD)
	_label(t, "InkWarn", body, SIZE_BODY, INK_WARN)
	_label(t, "InkNumber", numbers, SIZE_SMALL + 1, INK_HEADING)
	return t


static func _label(t: Theme, type: String, font: Font, size: int, color: Color, outline := 0) -> void:
	t.set_type_variation(type, "Label")
	t.set_font("font", type, font)
	t.set_font_size("font_size", type, size)
	t.set_color("font_color", type, color)
	if outline > 0:
		t.set_constant("outline_size", type, outline)
		t.set_color("font_outline_color", type, SHADOW)


# An inventory slot frame (art/ui/slot_<state>.png, drawn by tools/make_ui_slots.py), 9-sliced at its 8 px
# corner; a flat box in the same colours when the art is missing.
static func slot(state: String) -> StyleBox:
	var tex: Texture2D = UiSkin._tex("slot_" + state)
	if tex == null:
		var colors := {"empty": [Color("110d09"), Color("2a2119")], "occupied": [Color("1e1610"), IRON],
			"hover": [WOOD_HOVER, BRASS], "picked": [WOOD_PRESSED, GOLD], "locked": [Color("17110c"), Color("332a20")]}
		var pair: Array = colors.get(state, colors["occupied"])
		return _flat(pair[0], pair[1], 2, 6, 6)
	var sb := StyleBoxTexture.new()
	sb.texture = tex
	sb.set_texture_margin_all(8)
	sb.set_content_margin_all(6)
	return sb


# The open tab's mark: a gold bar with a dark lip, laid along the tab's foot just under its frame, so the open
# tab reads at a glance without more glow. It ignores the mouse.
static func mark_active_tab(tab: Control) -> void:
	var bar := ColorRect.new()
	bar.color = GOLD
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bar.offset_left = 16
	bar.offset_right = -16
	bar.offset_top = 2
	bar.offset_bottom = 5
	var lip := ColorRect.new()
	lip.color = SHADOW
	lip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lip.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	lip.offset_top = 0
	lip.offset_bottom = 1
	bar.add_child(lip)
	tab.add_child(bar)


# The ink colour for a dark-panel text colour, for text moved onto parchment.
static func ink(color: Color) -> Color:
	if color.is_equal_approx(GOLD):
		return INK_HEADING
	if color.is_equal_approx(MOSS):
		return INK_GOOD
	if color.is_equal_approx(RUST):
		return INK_WARN
	if color.is_equal_approx(BEIGE) or color.is_equal_approx(MUTED):
		return INK_MUTED
	return INK


# A small count badge laid in a control's top-right corner. It ignores the mouse, so clicks reach the control.
static func add_badge(owner: Control, count: int, alert := false) -> Label:
	var badge := Label.new()
	badge.theme_type_variation = "BadgeAlert" if alert else "Badge"
	badge.text = str(count)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	badge.offset_left = -12
	badge.offset_top = -7
	badge.offset_right = 4
	badge.offset_bottom = 9
	badge.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	owner.add_child(badge)
	return badge


# A confirmation dialog: a framed question with No and Yes. No is on the left and takes focus first, so a
# stray press never confirms; left and right move between them. The caller connects the buttons' pressed
# signals (found as the dialog's "no" and "yes" metadata) and frees the dialog.
static func confirm_dialog(title: String, text: String, yes_text := "Yes", no_text := "No") -> PanelContainer:
	var dialog := PanelContainer.new()
	dialog.theme_type_variation = "DialogPanel"
	dialog.custom_minimum_size = Vector2(420, 0)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	dialog.add_child(box)
	var heading := Label.new()
	heading.theme_type_variation = "DisplayHeading"
	heading.text = title
	box.add_child(heading)
	box.add_child(HSeparator.new())
	var body := Label.new()
	body.text = text
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(body)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_END
	row.add_theme_constant_override("separation", 12)
	box.add_child(row)
	var no := Button.new()
	no.theme_type_variation = "SecondaryButton"
	no.text = no_text
	no.custom_minimum_size = Vector2(120, 38)
	row.add_child(no)
	var yes := Button.new()
	yes.text = yes_text
	yes.custom_minimum_size = Vector2(140, 38)
	row.add_child(yes)
	no.focus_neighbor_right = no.get_path_to(yes)
	yes.focus_neighbor_left = yes.get_path_to(no)
	dialog.set_meta("no", no)
	dialog.set_meta("yes", yes)
	return dialog
