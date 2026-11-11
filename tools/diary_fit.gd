extends SceneTree

# Lists the diary pages whose words don't fit their page and scroll (DIARY-HAND-002), so a font change can be
# checked for new overflow. Run headless, from the project folder:
#   godot --path . --headless -s tools/diary_fit.gd
# Writes every note, finds all of Agnes Rook's pages (the farm's and the wood's), lives every second-year beat and
# reaches every ending, opens the diary and visits each spread. Prints one line per page that scrolls (section,
# page, title, how many px over) and a total. Also checks that no title runs past its page. Plays in save slot 9.

const SLOT := 9

var m: MainGame
var ab: ActionBar


func _initialize() -> void:
	create_timer(300.0).timeout.connect(func() -> void:
		print("FAIL: timed out")
		quit(99))
	m = load("res://scenes/main.tscn").instantiate()
	root.add_child.call_deferred(m)
	_run.call_deferred()


func _run() -> void:
	await _frames(3)
	m._on_title_start("new", SLOT)
	await _frames(5)
	m._dev_unlock_all()
	m.diary_found = true
	for tip in m.TIPS:
		m.tips_seen[tip["id"]] = true
	for p in m.mystery.PAGES:
		m.mystery.found[p["id"]] = true
	for p in m.mystery.TREK_PAGES:
		m.mystery.found[p["id"]] = true
	m.mystery.found["bell"] = true
	m.mystery.found["grove"] = true
	for beat in ["letter", "shown", "orchard", "knock", "meeting"]:
		m.act.beats[beat] = 400
	m.act.meeting = "won"
	m.act.davy = "stopped"
	m.act.davy_day = 420
	for id in m.act.ENDINGS:
		m.act.endings[id] = 500
	GameSettings.page_turns = 2
	ab = m.action_bar
	await _frames(3)
	if not ab.book.visible:
		var ev := InputEventKey.new()
		ev.keycode = KEY_J
		ev.physical_keycode = KEY_J
		ev.pressed = true
		Input.parse_input_event(ev)
		await _frames(2)
		ev = ev.duplicate()
		ev.pressed = false
		Input.parse_input_event(ev)
		await _frames(3)
	var over := 0
	var pages := 0
	for s in ab.book_sections.size():
		var n: int = ab.book_sections[s]["pages"].size()
		for p in range(0, n, 2):
			ab.open_book_at(s, p)
			await _frames(3)
			var side := 0
			for page_root in ab.book_spread_box.get_children():
				var scroll := _find_scroll(page_root)
				if scroll == null:
					continue
				var idx := p + side
				side += 1
				if idx >= n:
					continue
				pages += 1
				var body := scroll.get_child(0) as Control
				var bar := scroll.get_v_scroll_bar()
				var extra := bar.max_value - bar.page if bar.visible else 0.0
				if OS.get_environment("FIT_DEBUG") != "":
					var lb := body as Label
					print("  %s %d lines=%d body=%s scroll=%s font=%s" % [ab.book_sections[s]["name"], idx, lb.get_line_count(), lb.size, scroll.size, lb.get_theme_font("font").resource_path])
				if extra > 0.5:
					over += 1
					print("SCROLLS  %s %d  \"%s\"  +%d px" % [ab.book_sections[s]["name"], idx, ab.book_sections[s]["pages"][idx]["title"], int(extra)])
	print("pages %d, scrolling %d" % [pages, over])
	SaveSystem.delete_save(TitleMenu.slot_path(SLOT))
	quit(0)


func _find_scroll(n: Node) -> ScrollContainer:
	if n is ScrollContainer:
		return n
	for c in n.get_children():
		var f := _find_scroll(c)
		if f != null:
			return f
	return null


func _frames(k: int) -> void:
	for i in k:
		await process_frame
