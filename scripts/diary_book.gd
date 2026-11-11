class_name DiaryBook
extends RefCounted

# UI-OVERHAUL-001 Phase 5: the diary as a physical book. ActionBar still builds the pages and keeps the place
# (book_section, book_spread); this file only draws the book around them and the page turn over them.
#   DiaryBook.Cover     the leather cover, its drop shadow and the stacked page edges, drawn behind the spread
#   DiaryBook.PageTurn  the turning sheet: a presentation layer over the spread while a page turns
# The art is hand-drawn pixel art from tools/make_diary_art.py (art/ui/diary/, saved at 2x). Every piece falls
# back to the old code-drawn look if its file is missing.

const DIR := "res://art/ui/diary/"
const PAPER := Color("c4ae84")
const EDGE := Color("8f7a54")
const EDGE_DARK := Color("5a4632")
const LEATHER := Color("3b2417")

static var _tex := {}


static func tex(name: String) -> Texture2D:
	if not _tex.has(name):
		var path := DIR + name + ".png"
		_tex[name] = load(path) if ResourceLoader.exists(path) else null
	return _tex[name]


static func _tiled(t: Texture2D, left: float, top: float, right: float, bottom: float) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = t
	sb.texture_margin_left = left
	sb.texture_margin_top = top
	sb.texture_margin_right = right
	sb.texture_margin_bottom = bottom
	sb.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
	sb.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
	sb.set_content_margin_all(0)
	return sb


# A page's parchment: side 0 is the left page (its spine edge on the right). Margins are the art's at 2x:
# outer 10, top 10, bottom 10 and the gutter 14 native pixels.
static func page_style(side: int) -> StyleBox:
	var t := tex("page_l" if side == 0 else "page_r")
	if t == null:
		return null
	return _tiled(t, 20.0 if side == 0 else 28.0, 20.0, 28.0 if side == 0 else 20.0, 20.0)


static func cover_style() -> StyleBox:
	var t := tex("cover")
	return null if t == null else _tiled(t, 28.0, 28.0, 28.0, 28.0)


# A ribbon marker's fabric, tinted with the section's colour. Its left end tucks under the cover.
static func ribbon_style(tint: Color) -> StyleBox:
	var t := tex("ribbon")
	if t == null:
		return null
	var sb := _tiled(t, 8.0, 6.0, 16.0, 6.0)
	sb.modulate_color = tint
	sb.content_margin_left = 16
	sb.content_margin_right = 24
	return sb


# --- The cover -------------------------------------------------------------------

# Draws the book around the spread: a soft stepped shadow on the table, the leather cover with its brass caps
# and stitching, a dark seat where the page block rests, and three page edges stacked under each page, so the
# book has thickness. The spread itself (ActionBar.book_spread_box) and the PageTurn sit in its content rect.
class Cover extends PanelContainer:
	const MARGIN_SIDE := 26    # leather to the page block, left and right (with the stacked edges)
	const MARGIN_TOP := 14
	const MARGIN_BOTTOM := 20
	const STACK := 3           # page edges showing under the open pages, 2 px each
	var _cover_sb: StyleBox

	func _init() -> void:
		var room := StyleBoxEmpty.new()
		room.content_margin_left = MARGIN_SIDE
		room.content_margin_right = MARGIN_SIDE
		room.content_margin_top = MARGIN_TOP
		room.content_margin_bottom = MARGIN_BOTTOM
		add_theme_stylebox_override("panel", room)
		_cover_sb = DiaryBook.cover_style()

	func page_block() -> Rect2:
		return Rect2(Vector2(MARGIN_SIDE, MARGIN_TOP), size - Vector2(MARGIN_SIDE * 2, MARGIN_TOP + MARGIN_BOTTOM))

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		# The book's shadow on the table under it, in two hard steps (no soft gradient).
		draw_rect(Rect2(r.position + Vector2(8, 10), r.size), Color(0, 0, 0, 0.22))
		draw_rect(Rect2(r.position + Vector2(4, 5), r.size), Color(0, 0, 0, 0.26))
		if _cover_sb != null:
			draw_style_box(_cover_sb, r)
		else:
			draw_rect(r, LEATHER)
		var p := page_block()
		# The seat: the leather darkened where the page block presses into it.
		var seat := p.grow_individual(STACK * 2 + 4, 2, STACK * 2 + 4, STACK * 2 + 4)
		draw_rect(seat, Color(0.05, 0.03, 0.02, 0.55))
		# The stacked page edges, deepest first: each one 2 px further out at the sides and the foot.
		for i in range(STACK, 0, -1):
			var g := p.grow_individual(i * 2, 0, i * 2, i * 2)
			draw_rect(g, EDGE_DARK if i == STACK else (EDGE if i % 2 == 0 else Color("a08a62")))
			# the hairline between the leaves
			draw_rect(Rect2(g.position.x, g.end.y - 1, g.size.x, 1), Color(EDGE_DARK, 0.8))
		# The dip at the spine: the block bows down into the binding, so its foot is shaded there.
		var mid := p.get_center().x
		draw_rect(Rect2(mid - 6, p.end.y, 12, STACK * 2), Color(0.08, 0.05, 0.03, 0.6))


# --- The page turn ---------------------------------------------------------------

# The turning page, drawn over the spread for the length of one turn. The diary's place has already moved on
# when a turn starts; this only shows it happening.
#
# How: two SubViewports hold copies of the spread before and after the turn (built by ActionBar into
# old_root and new_root). They render for two frames, then stop, so their textures are snapshots made once per
# turn and kept in the same two render targets every time (no new textures per turn). The sheet is a strip mesh:
# the page is cut into STRIPS across its width, each strip at its own angle about the spine, so the outer
# edge lifts first, the paper bends toward the binding, and, past the spine, trails as it settles. Each strip
# is placed in 3D (x across, z up off the book) and drawn with a gentle perspective, so a lifted sheet looks
# nearer. A strip facing the camera shows the page it was (the front); one turned away shows the page behind it
# (the back), mapped so its writing reads the right way round once it lies down. Strips are shaded by their
# angle to the light, and the sheet casts a stepped shadow across the pages under it.
#
# Riffling (a section jump) sends a few blank leaves over before the last one, quickly, instead of a full turn
# per page. A new turn while one is playing finishes the old one at once, so turns never overlap or get lost.
class PageTurn extends Control:
	signal cue(sound: String)   # page_lift, page_rustle, page_settle, book_section: ActionBar plays them

	const STRIPS := 40
	const CAMERA := 6.0          # the camera's height over the book, in sheet widths: the perspective's strength
	const RIFFLE_GAP := 0.085    # seconds between riffled leaves
	const WARM_FRAMES := 2       # frames the snapshots take to lay out and render before the sheet shows

	var active := false
	var hold := -1.0             # tools only: with 0 to 1, the turn stops at that point (tools/capture.gd dprog=)
	var forward := true
	var leaves := 1
	var duration := 0.6
	var t := 0.0
	var warm := 0
	var old_root: Control
	var new_root: Control
	var reveal: Callable         # rebuilds the live spread underneath once the sheet covers it
	var _vp_old: SubViewport
	var _vp_new: SubViewport
	var _logical := Vector2.ONE  # the spread's size in UI units; the snapshots may be rendered at a larger scale
	var _left := Rect2()         # the left page, the spine and the right page, in this control's space
	var _spine := Rect2()
	var _right := Rect2()
	var _cues: Array = []        # [time, sound] still to play this turn
	var _paper_l: StyleBox
	var _paper_r: StyleBox

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		visible = false
		_vp_old = _make_viewport()
		_vp_new = _make_viewport()
		old_root = _vp_old.get_child(0)
		new_root = _vp_new.get_child(0)
		_paper_l = DiaryBook.page_style(0)
		_paper_r = DiaryBook.page_style(1)

	func _make_viewport() -> SubViewport:
		var vp := SubViewport.new()
		vp.transparent_bg = true
		vp.disable_3d = true
		vp.gui_disable_input = true
		vp.size_2d_override_stretch = true
		vp.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
		vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
		var box := HBoxContainer.new()
		box.add_theme_constant_override("separation", 0)
		vp.add_child(box)
		add_child(vp)
		return vp

	# Empties both snapshots and sizes them like the live spread, whose pages are at left, spine and right.
	# scale is the window's stretch, so the snapshot's text is as sharp as the live text.
	func prepare(spread_size: Vector2, left: Rect2, spine: Rect2, right: Rect2, scale: float) -> void:
		_logical = spread_size.max(Vector2.ONE)
		_left = left
		_spine = spine
		_right = right
		var px := Vector2i((_logical * scale).ceil())
		for vp in [_vp_old, _vp_new]:
			var root: Control = vp.get_child(0)
			for child in root.get_children():
				root.remove_child(child)
				child.queue_free()
			if vp.size != px:
				vp.size = px
			vp.size_2d_override = Vector2i(_logical)
			root.position = Vector2.ZERO
			root.size = _logical

	# Starts the turn once the snapshots are filled. forward turns the right page over to the left.
	func start(go_forward: bool, leaf_count: int, seconds: float) -> void:
		forward = go_forward
		leaves = maxi(1, leaf_count)
		duration = maxf(0.05, seconds)
		t = 0.0
		warm = WARM_FRAMES
		active = true
		visible = false
		for vp in [_vp_old, _vp_new]:
			vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		# The sound follows the paper: a lift as it leaves the page, the rustle as it crosses, a settle as it lands.
		var land := duration - 0.07
		if leaves > 1:
			_cues = [[0.0, "book_section"], [land, "page_settle"]]
		else:
			_cues = [[0.0, "page_lift"], [duration * 0.3, "page_rustle"], [land, "page_settle"]]

	# Ends the turn now: the live spread is already the new one, so all that's left is to clear the snapshots.
	func finish() -> void:
		if not active:
			return
		var pending := warm > 0
		active = false
		visible = false
		warm = 0
		_cues.clear()
		for vp in [_vp_old, _vp_new]:
			vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
			var root: Control = vp.get_child(0)
			for child in root.get_children():
				root.remove_child(child)
				child.queue_free()
		if pending and reveal.is_valid():
			reveal.call()

	func progress() -> float:
		return clampf(t / duration, 0.0, 1.0)

	func _process(delta: float) -> void:
		if not active:
			return
		# Closing the diary (or its panel) mid-turn ends the turn cleanly.
		var host := get_parent() as Control
		if host == null or not host.is_visible_in_tree():
			finish()
			return
		if warm > 0:
			warm -= 1
			if warm == 0:
				for vp in [_vp_old, _vp_new]:
					vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
				visible = true
				if reveal.is_valid():
					reveal.call()
				_play_cues()
				queue_redraw()
			return
		t = hold * duration if hold >= 0.0 else t + delta
		_play_cues()
		if t >= duration and hold < 0.0:
			finish()
			return
		queue_redraw()

	func _play_cues() -> void:
		while not _cues.is_empty() and t >= float(_cues[0][0]):
			cue.emit(str(_cues.pop_front()[1]))

	# --- Drawing ---

	func _blit(texture: Texture2D, r: Rect2) -> void:
		var k := Vector2(texture.get_size()) / _logical
		draw_texture_rect_region(texture, r, Rect2(r.position * k, r.size * k))

	# The leaf's own clock: each riffled leaf starts RIFFLE_GAP after the one before.
	func _leaf_q(i: int) -> float:
		if leaves == 1:
			return progress()
		var each := duration - RIFFLE_GAP * (leaves - 1)
		return clampf((t - RIFFLE_GAP * i) / each, 0.0, 1.0)

	func _draw() -> void:
		if not active or warm > 0:
			return
		var old_tex := _vp_old.get_texture()
		var new_tex := _vp_new.get_texture()
		var from_rect := _right if forward else _left    # the page the turn starts from
		var to_rect := _left if forward else _right      # the page it lands on
		var qs: Array = []
		for i in leaves:
			qs.append(_leaf_q(i))
		# Under everything: the page being revealed (the new spread's), with any leaves still waiting on it.
		_blit(new_tex, from_rect)
		if leaves > 1 and float(qs[leaves - 1]) <= 0.0:
			_draw_blank(from_rect, 0 if not forward else 1)
		# The page being covered: the old one until a leaf lands on it, then that leaf's back.
		_blit(old_tex, _spine)
		var landed := -1
		for i in leaves:
			if float(qs[i]) >= 1.0:
				landed = i
		if landed < 0:
			_blit(old_tex, to_rect)
		elif landed == leaves - 1:
			_blit(new_tex, to_rect)
		else:
			_draw_blank(to_rect, 0 if forward else 1)
		# The leaves in the air, the one furthest from upright first, so the nearer one covers it.
		var flying: Array = []
		for i in leaves:
			# The first leaf is drawn from its very first frame (lying flat at 0), so the page under it never
			# shows before it lifts.
			if float(qs[i]) < 1.0 and (float(qs[i]) > 0.0 or i == 0):
				flying.append(i)
		flying.sort_custom(func(a: int, b: int) -> bool:
			return absf(_theta(float(qs[a])) - PI / 2.0) > absf(_theta(float(qs[b])) - PI / 2.0))
		for i in flying:
			var shape := _shape(float(qs[i]))
			_draw_shadow(shape, float(qs[i]))
		for i in flying:
			var shape := _shape(float(qs[i]))
			var front: Texture2D = old_tex if i == 0 else null
			var back: Texture2D = new_tex if i == leaves - 1 else null
			_draw_leaf(shape, front, back)

	func _draw_blank(r: Rect2, side: int) -> void:
		var sb: StyleBox = _paper_l if side == 0 else _paper_r
		if sb != null:
			draw_style_box(sb, r)
		else:
			draw_rect(r, PAPER)

	# The leaf's angle at the spine, in key poses (progress, degrees): it lifts quickly, slows a little as it
	# stands up over the spine, falls, and settles. BENDS is how far the outer edge leads (+, lifting) or
	# trails (-, settling), in radians. Both are eased between the keys by a smooth cubic (no stops at keys).
	const ANGLES := [[0.0, 0.0], [0.15, 22.0], [0.3, 56.0], [0.5, 90.0], [0.7, 126.0], [0.85, 160.0], [1.0, 180.0]]
	const BENDS := [[0.0, 0.0], [0.1, 0.7], [0.25, 0.9], [0.45, 0.35], [0.55, -0.15], [0.75, -0.55], [0.9, -0.3], [1.0, 0.0]]

	static func _curve(keys: Array, q: float, settle: bool) -> float:
		q = clampf(q, 0.0, 1.0)
		var i := 0
		while i < keys.size() - 2 and q > float(keys[i + 1][0]):
			i += 1
		var p0: float = keys[i][0]
		var p1: float = keys[i + 1][0]
		var v0: float = keys[i][1]
		var v1: float = keys[i + 1][1]
		var m0 := _slope(keys, i)
		var m1 := 0.0 if settle and i + 1 == keys.size() - 1 else _slope(keys, i + 1)
		var h := p1 - p0
		var u := (q - p0) / h
		var u2 := u * u
		var u3 := u2 * u
		return (2 * u3 - 3 * u2 + 1) * v0 + (u3 - 2 * u2 + u) * h * m0 + (-2 * u3 + 3 * u2) * v1 + (u3 - u2) * h * m1

	static func _slope(keys: Array, i: int) -> float:
		var a: int = maxi(i - 1, 0)
		var b: int = mini(i + 1, keys.size() - 1)
		return (float(keys[b][1]) - float(keys[a][1])) / (float(keys[b][0]) - float(keys[a][0]))

	func _theta(q: float) -> float:
		return deg_to_rad(clampf(_curve(ANGLES, q, true), 0.0, 180.0))

	# The leaf as a row of strip edges from the spine to its outer edge. Each point is [screen x, top y,
	# bottom y, angle, height]. The outer edge leads while the leaf lifts and trails while it settles.
	func _shape(q: float) -> Array:
		var theta := _theta(q)
		var bend := _curve(BENDS, q, true)
		var spine_x := _spine.get_center().x
		var half := _spine.size.x * 0.5
		var length := _right.size.x + half if forward else _left.size.x + half
		var dir := 1.0 if forward else -1.0
		var top := _right.position.y
		var bottom := _right.end.y
		var cy := (top + bottom) * 0.5
		var cam := CAMERA * length
		var pts: Array = []
		var x := 0.0
		var z := 0.0
		for j in STRIPS + 1:
			var u := float(j) / STRIPS
			var k := cam / maxf(cam - z, 1.0)
			# Lifted strips sit nearer the camera, so they draw larger about the book's centre.
			var a := clampf(theta + bend * pow(u, 1.6), 0.0, PI)
			pts.append([spine_x + dir * x * k, cy + (top - cy) * k, cy + (bottom - cy) * k, a, z, u * length - half])
			var mid_u := (float(j) + 0.5) / STRIPS
			var am := clampf(theta + bend * pow(mid_u, 1.6), 0.0, PI)
			x += cos(am) * length / STRIPS
			z += sin(am) * length / STRIPS
		return pts

	# A stepped shadow on the pages beyond the leaf's outer edge (wider and darker the higher it rides), and a
	# darkening either side of the spine while the leaf stands up there.
	func _draw_shadow(pts: Array, q: float) -> void:
		var outer: Array = pts[pts.size() - 1]
		var height := 0.0
		for p in pts:
			height = maxf(height, float(p[4]))
		var spine_x := _spine.get_center().x
		var top := _right.position.y
		var h := _right.size.y
		var lift := clampf(height / (_right.size.x * 0.5), 0.0, 1.0)
		var side := signf(float(outer[0]) - spine_x)
		if side == 0.0:
			side = 1.0
		var width := 6.0 + 30.0 * lift
		var steps := [0.34, 0.24, 0.15, 0.07]
		var limit := _right.end.x if side > 0.0 else _left.position.x
		for i in steps.size():
			var x0 := float(outer[0]) + side * width * i / steps.size()
			var x1 := float(outer[0]) + side * width * (i + 1) / steps.size()
			x0 = minf(x0, limit) if side > 0.0 else maxf(x0, limit)
			x1 = minf(x1, limit) if side > 0.0 else maxf(x1, limit)
			var r := Rect2(minf(x0, x1), top, absf(x1 - x0), h)
			if r.size.x > 0.0:
				draw_rect(r, Color(0.08, 0.05, 0.02, steps[i] * lift))
		# The leaf upright at the spine shades the gutter on both pages.
		var upright := sin(_theta(q))
		var gutter := 0.16 * _right.size.x * upright
		for i in 3:
			var w := gutter * (3 - i) / 3.0
			var a := 0.1 * upright
			draw_rect(Rect2(spine_x - w, top, w * 2.0, h), Color(0.08, 0.05, 0.02, a))

	# The leaf's strips: textured from the snapshot of whichever face is toward the camera, shaded by angle.
	# A riffled leaf with no page of its own (front or back null) is plain parchment.
	func _draw_leaf(pts: Array, front: Texture2D, back: Texture2D) -> void:
		var dir := 1.0 if forward else -1.0
		var src_inner := _right.position.x if forward else _left.end.x   # the front page's spine edge
		var dst_inner := _left.end.x if forward else _right.position.x   # the back page's spine edge
		var v0 := _right.position.y / _logical.y
		var v1 := _right.end.y / _logical.y
		var top_line := PackedVector2Array()
		var bottom_line := PackedVector2Array()
		for j in STRIPS:
			var a: Array = pts[j]
			var b: Array = pts[j + 1]
			# The part over the spine itself is the binding, not paper.
			if float(b[5]) <= 0.0:
				continue
			var da := maxf(float(a[5]), 0.0)
			var db := float(b[5])
			var ax := float(a[0]) if float(a[5]) >= 0.0 else lerpf(float(a[0]), float(b[0]), -float(a[5]) / (db - float(a[5])))
			var at := float(a[1]) if float(a[5]) >= 0.0 else lerpf(float(a[1]), float(b[1]), -float(a[5]) / (db - float(a[5])))
			var ab := float(a[2]) if float(a[5]) >= 0.0 else lerpf(float(a[2]), float(b[2]), -float(a[5]) / (db - float(a[5])))
			var quad := PackedVector2Array([Vector2(ax, at), Vector2(float(b[0]), float(b[1])),
				Vector2(float(b[0]), float(b[2])), Vector2(ax, ab)])
			if top_line.is_empty():
				top_line.append(quad[0])
				bottom_line.append(quad[3])
			top_line.append(quad[1])
			bottom_line.append(quad[2])
			var angle := (float(a[3]) + float(b[3])) * 0.5
			var facing := (float(b[0]) - ax) * dir > 0.0
			var shade := 0.0
			var texture: Texture2D
			var u0 := 0.0
			var u1 := 0.0
			if facing:
				shade = 0.7 + 0.3 * pow(maxf(cos(angle), 0.0), 0.6)
				texture = front
				u0 = (src_inner + dir * da) / _logical.x
				u1 = (src_inner + dir * db) / _logical.x
			else:
				shade = 0.6 + 0.4 * pow(maxf(-cos(angle), 0.0), 0.6)
				texture = back
				u0 = (dst_inner - dir * da) / _logical.x
				u1 = (dst_inner - dir * db) / _logical.x
			shade = snappedf(shade, 0.04)   # in steps, as the art's shading is
			var tint := Color(shade, shade * 0.985, shade * 0.95)
			if texture != null:
				var uvs := PackedVector2Array([Vector2(u0, v0), Vector2(u1, v0), Vector2(u1, v1), Vector2(u0, v1)])
				draw_polygon(quad, PackedColorArray([tint, tint, tint, tint]), uvs, texture)
			else:
				draw_colored_polygon(quad, PAPER * tint)
		if top_line.size() < 2:
			return
		# The leaf's edges: a dark pixel line round the paper, as the art outlines everything.
		draw_polyline(top_line, EDGE_DARK, 2.0)
		draw_polyline(bottom_line, EDGE_DARK, 2.0)
		draw_line(top_line[top_line.size() - 1], bottom_line[bottom_line.size() - 1], EDGE_DARK, 2.0)
