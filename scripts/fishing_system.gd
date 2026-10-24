class_name FishingSystem
extends RefCounted

var m: MainGame


func _init(main: MainGame) -> void:
	m = main


# Fishing level 3 and up adds spots: one more at 3, another at 5.
func _fish_spot_count() -> int:
	return m.FISH_SPOT_COUNT + (m.progression._level("Fishing") - 1) / 2


func _update_fish_spots(delta: float) -> void:
	# Each spot runs down its life. When it goes quiet, it moves to a new place.
	for tile in m.fish_spots.keys():
		m.fish_spots[tile] -= delta
		if m.fish_spots[tile] <= 0.0:
			m.fish_spots.erase(tile)
			if tile == m.fishing_tile:
				_stop_fishing("The fish have moved on from your spot.")
	# Refill up to the count for the current Fishing level.
	while m.fish_spots.size() < _fish_spot_count() and _spawn_fish_spot():
		pass
	# The sparkle pulses and fades, so the layer redraws every frame.
	if m.fish_layer != null:
		m.fish_layer.queue_redraw()


func _spawn_fish_spot() -> bool:
	var options: Array = []
	for edge in m.pond_edges:
		if not m.fish_spots.has(edge):
			options.append(edge)
	if options.is_empty():
		return false
	var pick: Vector2i = options.pick_random()
	m.fish_spots[pick] = randf_range(m.FISH_SPOT_MIN_LIFE, m.FISH_SPOT_MAX_LIFE)
	return true


func _is_fishing() -> bool:
	return m.fishing_tile != m.NO_SPOT


func _start_fishing(tile: Vector2i) -> void:
	if not m.stall._pack_room(int(m.inventory["fish"]), 1):
		m._show_message("Your pack is full. Store fish in the cooler, or sell or cook them first.")
		return
	m.fishing_tile = tile
	m.fish_timer = m.FISH_TICK_SECONDS
	m._show_message("You cast your line. Stay put and keep fishing.")


func _stop_fishing(reason: String) -> void:
	m.fishing_tile = m.NO_SPOT
	if reason != "":
		m._show_message(reason)


# While fishing, roll for a catch every tick. Moving, going inside, or
# opening a panel reels the line in.
func _update_fishing(delta: float) -> void:
	if not _is_fishing():
		return
	var moved := Input.get_vector("move_left", "move_right", "move_up", "move_down") != Vector2.ZERO
	if moved or m.inside or m.open_tab != "" or m._tile_in_front() != m.fishing_tile:
		_stop_fishing("You reel in your line.")
		return
	m.fish_timer -= delta
	if m.fish_timer > 0.0:
		return
	m.fish_timer = m.FISH_TICK_SECONDS
	if not m.stall._pack_room(int(m.inventory["fish"]), 1):
		_stop_fishing("Your pack is full. Store fish in the cooler, or sell or cook them.")
		return
	_fish_roll()


func _fish_roll() -> void:
	m.stats["fished"] += 1
	var chance := clampf(m.FISH_BASE_CHANCE + m.FISH_CHANCE_PER_LEVEL * float(m.progression._level("Fishing") - 1) + m._rod_bonus(), 0.0, m.FISH_CHANCE_CAP)
	if randf() < chance:
		m.stats["caught"] += 1
		m.inventory["fish"] += 1
		m.progression._grant_xp("Fishing", m.XP_FISH)
		m._show_message("You hook a fish! +%d Fishing XP" % m.XP_FISH)
	else:
		m._show_message("Nothing yet. Keep still.")


func _store_fish() -> void:
	var amount := mini(int(m.inventory["fish"]), m.COOLER_CAP - m.cooler_stock)
	if amount <= 0:
		m._show_message("Nothing to store, or the cooler is full.")
		return
	m.inventory["fish"] -= amount
	m.cooler_stock += amount
	m._show_message("You store %d fish in the cooler." % amount)


func _take_fish() -> void:
	var amount := mini(m.cooler_stock, m.stall._pack_free())
	if amount <= 0:
		m._show_message("Your pack is full, or the cooler is empty.")
		return
	m.cooler_stock -= amount
	m.inventory["fish"] += amount
	m._show_message("You take %d fish from the cooler." % amount)
