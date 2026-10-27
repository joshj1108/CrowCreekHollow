class_name CombatSystem
extends RefCounted

var m: MainGame


func _init(main: MainGame) -> void:
	m = main


func _fire(weapon: String) -> void:
	if m.swing_cool > 0.0:
		return
	var item: Dictionary = m.GEAR_ITEMS[weapon]
	var ammo := str(item["ammo"])
	if int(m.materials[ammo]) < 1:
		m._show_message("You're out of %s. Make more from the Craft panel." % ammo)
		return
	m.materials[ammo] -= 1
	m.swing_cool = float(item["cool"])
	m.player.play_act("fire", 0.35)
	var dir: Vector2 = m.player.facing.normalized()
	m.shots.append({"pos": m.player.position, "vel": dir * m.SHOT_SPEED, "life": m.SHOT_LIFE, "dmg": int(item["dmg"])})
	m.queue_redraw()


func _update_shots(delta: float) -> void:
	if not m._in_village():
		m.shots.clear()
		return
	if m.shots.is_empty():
		return
	for shot in m.shots.duplicate():
		var pos: Vector2 = shot["pos"] + shot["vel"] * delta
		shot["pos"] = pos
		shot["life"] = float(shot["life"]) - delta
		var hit := false
		for foe in m.foes.duplicate():
			var gap: Vector2 = foe["pos"] - pos
			if gap.length() < m.PX * 0.45:
				_shot_hits(foe, int(shot["dmg"]))
				hit = true
				break
		if hit or float(shot["life"]) <= 0.0 or m._is_blocked_world(pos):
			m.shots.erase(shot)
	m.queue_redraw()


func _shot_hits(foe: Dictionary, amount: int) -> void:
	foe["hp"] = int(foe["hp"]) - amount
	foe["flash"] = 0.2
	m.progression._grant_xp("Combat", m.XP_HIT)
	if int(foe["hp"]) <= 0:
		_kill_foe(foe)
	else:
		m._show_message("Your shot hits the %s for %d." % [str(foe["kind"]), amount])


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
		return
	var origin := m._region_origin()
	if m.zone == m.Zone.VILLAGE:
		for spot in m.HOLLOW_SPAWNS:
			m.foes.append(_new_foe("hollow", origin + spot))
	elif m.zone == m.Zone.ASHFORD:
		for spot in m.STALKER_SPAWNS:
			m.foes.append(_new_foe("stalker", origin + spot))
	m.queue_redraw()


func _update_foes(delta: float) -> void:
	m.swing_cool = maxf(0.0, m.swing_cool - delta)
	m.swing_time = maxf(0.0, m.swing_time - delta)
	m.invuln = maxf(0.0, m.invuln - delta)
	if not (m._in_village() or m.in_cave):
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
			_move_foe(foe, to_player.normalized() * float(st["chase"]) * delta)
			if dist < m.PX * 0.6 and float(foe["cool"]) <= 0.0:
				foe["cool"] = float(st["cool"])
				_foe_attack(foe)
		else:
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
	return not m.BLOCKING.has(m._kind_at(t)) and m._npc_index(t) == -1 and not m._near_campsite(t)


func _foe_attack(foe: Dictionary) -> void:
	if m._at_campsite():
		return
	if m.invuln > 0.0:
		return
	# A held block turns aside a blow from the front.
	if m.blocking and (foe["pos"] - m.player.position).normalized().dot(m.player.facing) > 0.3:
		m.invuln = m.INVULN_TIME * 0.5
		m.play_sfx("tick", 0.05)
		return
	var st: Dictionary = m.FOES[foe["kind"]]
	var dmg := maxi(1, int(st["dmg"]) - m._defense())
	m.hp -= dmg
	m.invuln = m.INVULN_TIME
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
	m.stats["defeated"] += 1
	if foe["kind"] == "stalker":
		m.stats["stalkers"] += 1
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
