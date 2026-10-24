class_name FirewoodSystem
extends RefCounted

var m: MainGame


func _init(main: MainGame) -> void:
	m = main


func _chop(tile: Vector2i) -> void:
	if int(m.tool_tier["hatchet"]) < 1:
		m.play_sfx("strike", 0.08)
		m._show_message("You need a hatchet. Craft a crude one from the Craft panel.")
		return
	# Chopping keeps rolling each tick until the tree falls. Moving away stops it.
	m.farm._start_harvest("chop", tile)
	m._show_message("You start chopping. Keep at it.")


func _finish_chop(tile: Vector2i) -> void:
	m.grove_felled[tile] = true
	m._apply_grove()
	m.materials["wood"] += 3
	var found := "3 wood"
	if int(m.tool_tier["hatchet"]) >= 3:
		m.materials["hardwood"] += 2
		found += ", 2 hardwood"
	m.stats["felled"] += 1
	m.progression._grant_xp("Forestry", m.XP_FELL)
	m._show_message("You fell the tree. +%s. +%d Forestry XP" % [found, m.XP_FELL])
	m.queue_redraw()


# Whether the hearth has a fire going.
func _fire_lit() -> bool:
	return m.fire_hours > 0.0


func _feed_fire() -> void:
	if int(m.inventory["firewood"]) <= 0:
		m._show_message("The hearth needs firewood. Take some from the firewood store at the workshop.")
		return
	if m.fire_hours >= m.FIRE_MAX_HOURS:
		m._show_message("The fire is already roaring.")
		return
	m.inventory["firewood"] -= 1
	m.fire_hours = minf(m.FIRE_MAX_HOURS, m.fire_hours + m.FIREWOOD_HOURS)
	m._show_message("You feed the fire. It will burn for about %d more hours." % ceili(m.fire_hours))


# Splits one wood into firewood at the chopping log. Needs the axe in hand and wood in the pack.
func _chop_firewood() -> void:
	if not m._need_tool("axe"):
		return
	if int(m.materials["wood"]) <= 0:
		m._show_message("You need wood to split. Gather some first.")
		return
	if m.firewood_store >= m.WOODSTORE_CAP:
		m._show_message("The firewood store is full. Take some firewood out first.")
		return
	m.materials["wood"] -= 1
	var made := mini(m.FIREWOOD_PER_WOOD, m.WOODSTORE_CAP - m.firewood_store)
	m.firewood_store += made
	m.progression._grant_xp("Forestry", m.XP_CHOP_LOG)
	m._show_message("You split the wood into %d firewood. %d in the store. +%d Forestry XP" % [made, m.firewood_store, m.XP_CHOP_LOG])


func _take_firewood(amount: int) -> void:
	var n := mini(amount, m.firewood_store)
	if n <= 0:
		m._show_message("The firewood store is empty.")
		return
	m.firewood_store -= n
	m.inventory["firewood"] += n
	m._show_message("You take %d firewood." % n)


func _store_firewood() -> void:
	var n := mini(int(m.inventory["firewood"]), m.WOODSTORE_CAP - m.firewood_store)
	if n <= 0:
		m._show_message("There is nothing to store, or the store is full.")
		return
	m.inventory["firewood"] -= n
	m.firewood_store += n
	m._show_message("You store %d firewood. %d in the store." % [n, m.firewood_store])
