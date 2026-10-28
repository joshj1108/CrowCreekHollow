class_name CombatSystem
extends RefCounted

var m: MainGame


func _init(main: MainGame) -> void:
	m = main


func _new_foe(kind: String, tile: Vector2i) -> Dictionary:
	var center := m._tile_center(tile.x, tile.y)
	return {
		"kind": kind, "pos": center, "home": center,
		"hp": int(m.FOES[kind]["hp"]), "cool": 0.0, "dir": Vector2.ZERO,
		"wander_t": 0.0, "flash": 0.0,
	}


func _spawn_foes() -> void:
	m.foes = []
	if m.in_cave:
		for spawn in m.cave_spawns:
			m.foes.append(_new_foe(str(spawn["kind"]), spawn["tile"]))
	m.queue_redraw()


func _update_foes(delta: float) -> void:
	m.swing_cool = maxf(0.0, m.swing_cool - delta)
	m.invuln = maxf(0.0, m.invuln - delta)
	if not m.in_cave:
		m.player.modulate = Color.WHITE
		return
	m.player.modulate = Color(1.0, 0.55, 0.55) if m.invuln > 0.0 else Color.WHITE
	for foe in m.foes:
		var st: Dictionary = m.FOES[foe["kind"]]
		foe["cool"] = maxf(0.0, float(foe["cool"]) - delta)
		foe["flash"] = maxf(0.0, float(foe["flash"]) - delta)
		var pos: Vector2 = foe["pos"]
		var to_player: Vector2 = m.player.position - pos
		var dist := to_player.length()
		if dist < float(st["aggro"]) * m.PX:
			# A foe calls out once when it notices you, and again if you lose it and it finds you again.
			if not foe.get("noticed", false):
				foe["noticed"] = true
				m.play_sfx(str(m.FOE_SOUNDS.get(foe["kind"], "growl")), 0.12)
			_move_foe(foe, to_player.normalized() * float(st["chase"]) * delta)
			if dist < m.PX * 0.6 and float(foe["cool"]) <= 0.0:
				foe["cool"] = float(st["cool"])
				_foe_attack(foe)
		else:
			if dist > float(st["aggro"]) * m.PX * 1.6:
				foe["noticed"] = false
			foe["wander_t"] = float(foe["wander_t"]) - delta
			if float(foe["wander_t"]) <= 0.0:
				foe["wander_t"] = randf_range(1.0, 3.0)
				foe["dir"] = Vector2.from_angle(randf() * TAU) if randf() < 0.7 else Vector2.ZERO
			var wander_dir: Vector2 = foe["dir"]
			var home: Vector2 = foe["home"]
			if pos.distance_to(home) > m.PX * 2.5:
				wander_dir = (home - pos).normalized()
			_move_foe(foe, wander_dir * float(st["speed"]) * delta)
	m.queue_redraw()


# Moves one axis at a time so a foe slides along walls.
func _move_foe(foe: Dictionary, step: Vector2) -> void:
	var pos: Vector2 = foe["pos"]
	var nx := pos + Vector2(step.x, 0)
	if _foe_free(nx):
		pos = nx
	var ny := pos + Vector2(0, step.y)
	if _foe_free(ny):
		pos = ny
	# Kept for drawing: whether it actually moved this frame, and which way it last moved sideways.
	foe["moving"] = pos != foe["pos"]
	if absf(pos.x - float(foe["pos"].x)) > 0.01:
		foe["face"] = signf(pos.x - float(foe["pos"].x))
	foe["pos"] = pos


func _foe_free(p: Vector2) -> bool:
	var t := Vector2i(floori(p.x / m.PX), floori(p.y / m.PX))
	return not m.BLOCKING.has(m._kind_at(t))


func _foe_attack(foe: Dictionary) -> void:
	if m.invuln > 0.0:
		return
	# A held block turns aside a blow from the front.
	if m.blocking and (foe["pos"] - m.player.position).normalized().dot(m.player.facing) > 0.3:
		m.invuln = m.INVULN_TIME * 0.5
		m.play_sfx("block", 0.06)
		return
	var st: Dictionary = m.FOES[foe["kind"]]
	var dmg := maxi(1, int(st["dmg"]) - m._defense())
	m.hp -= dmg
	m.invuln = m.INVULN_TIME
	m.play_sfx("hurt", 0.06)
	# Knock the player back a little, if there's room.
	var away: Vector2 = (m.player.position - foe["pos"]).normalized()
	var np: Vector2 = m.player.position + away * m.PX * 0.5
	if not m._is_blocked_world(np):
		m.player.position = np
	if m.hp <= 0:
		m._fallen()
		return
	m._show_message("The %s strikes you for %d. HP %d/%d" % [str(foe["kind"]).capitalize(), dmg, m.hp, m.max_hp()])


func _kill_foe(foe: Dictionary) -> void:
	var st: Dictionary = m.FOES[foe["kind"]]
	m.foes.erase(foe)
	m.play_sfx("foe_die", 0.1)
	m.stats["defeated"] += 1
	m.progression._grant_xp("Combat", int(st["xp"]))
	var note := "+%d Combat XP" % int(st["xp"])
	var drop := str(st["drop"])
	if randf() < 0.6:
		m.materials[drop] += 1
		note += ", 1 %s" % drop
	m._show_message("The %s falls. %s" % [str(foe["kind"]), note])


func _weapon_damage() -> int:
	var item := str(m.equipment["hand_r"])
	if item == "":
		return 1
	return int(m.GEAR_ITEMS[item]["dmg"])
