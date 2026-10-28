class_name AnimalSystem
extends RefCounted

var m: MainGame


func _init(main: MainGame) -> void:
	m = main


func _can_feed_goats() -> bool:
	return m.goats > 0 and m.goats_fed_day != m.day and m.farm._crop_total() >= m.goats * m.GOAT_FEED_CROPS


func _feed_goats() -> void:
	if m.goats > 0 and m.goats_fed_day == m.day:
		m._show_message("The goats are fed for today.")
		return
	if not _can_feed_goats():
		m._show_message("The goats need %d crops." % (m.goats * m.GOAT_FEED_CROPS))
		return
	m.farm._spend_crops(m.goats * m.GOAT_FEED_CROPS)
	m.goats_fed_day = m.day
	m.play_sfx("feed", 0.06)
	m._show_message("You feed the goats.")


func _can_feed_hens() -> bool:
	return m.hens > 0 and m.hens_fed_day != m.day and m.farm._crop_total() >= m.hens * m.HEN_FEED_CROPS


func _feed_hens() -> void:
	if m.hens > 0 and m.hens_fed_day == m.day:
		m._show_message("The hens are fed for today.")
		return
	if not _can_feed_hens():
		m._show_message("The hens need %d crops." % (m.hens * m.HEN_FEED_CROPS))
		return
	m.farm._spend_crops(m.hens * m.HEN_FEED_CROPS)
	m.hens_fed_day = m.day
	m.play_sfx("feed", 0.06)
	m._show_message("You feed the hens.")


# --- Feed hoppers: built in the coop and the barn, filled with crops, they feed the animals each night ---

func _hopper_cost(which: String) -> Dictionary:
	return m.COOP_HOPPER_COST if which == "coop" else m.BARN_HOPPER_COST


func _hopper_built(which: String) -> bool:
	return m.coop_hopper_built if which == "coop" else m.barn_hopper_built


func _hopper_stock(which: String) -> int:
	return m.coop_hopper if which == "coop" else m.barn_hopper


# Crops the hopper's animals eat a day.
func _hopper_need(which: String) -> int:
	return m.hens * m.HEN_FEED_CROPS if which == "coop" else m.goats * m.GOAT_FEED_CROPS


func _can_build_hopper(which: String) -> bool:
	var cost := _hopper_cost(which)
	var house_ok := m.coop_built if which == "coop" else m.barn_built
	if not house_ok or _hopper_built(which) or m.progression._level("Carpentry") < int(cost["level"]):
		return false
	for key in cost:
		if key != "level" and int(m.materials[key]) < int(cost[key]):
			return false
	return true


func _build_hopper(which: String) -> void:
	if not _can_build_hopper(which):
		m._show_message("The feed hopper needs %s." % m.stall._price_text(_hopper_cost(which)))
		return
	var cost := _hopper_cost(which)
	for key in cost:
		if key != "level":
			m.materials[key] -= int(cost[key])
	if which == "coop":
		m.coop_hopper_built = true
	else:
		m.barn_hopper_built = true
	m.progression._grant_xp("Carpentry", m.XP_REPAIR)
	m.play_sfx("repair", 0.05)
	m._show_message("You build a feed hopper in the %s. Fill it with crops and it feeds the %s each night. +%d Carpentry XP" % [which, "hens" if which == "coop" else "goats", m.XP_REPAIR])


func _can_fill_hopper(which: String) -> bool:
	return _hopper_built(which) and _hopper_stock(which) < m.HOPPER_CAP and m.farm._crop_total() > 0


# Tips crops from the pack into the hopper, up to its capacity, turnips first.
func _fill_hopper(which: String) -> void:
	if not _can_fill_hopper(which):
		m._show_message("The hopper is full, or you have no crops." if _hopper_built(which) else "Build the feed hopper first.")
		return
	var amount := mini(m.HOPPER_CAP - _hopper_stock(which), m.farm._crop_total())
	m.farm._spend_crops(amount)
	if which == "coop":
		m.coop_hopper += amount
	else:
		m.barn_hopper += amount
	m.play_sfx("feed", 0.06)
	var need := _hopper_need(which)
	var days := (" That's about %d days of feed." % (_hopper_stock(which) / need)) if need > 0 else ""
	m._show_message("You tip %d crops into the hopper. It holds %d of %d.%s" % [amount, _hopper_stock(which), m.HOPPER_CAP, days])


# At the end of the day, a hopper feeds animals that weren't fed by hand, if it holds a full day's feed.
func _hopper_feed() -> String:
	var note := ""
	if m.hens > 0 and m.hens_fed_day != m.day and m.coop_hopper_built and m.coop_hopper >= _hopper_need("coop"):
		m.coop_hopper -= _hopper_need("coop")
		m.hens_fed_day = m.day
		if m.coop_hopper < _hopper_need("coop"):
			note += " The coop's hopper is empty."
	if m.goats > 0 and m.goats_fed_day != m.day and m.barn_hopper_built and m.barn_hopper >= _hopper_need("barn"):
		m.barn_hopper -= _hopper_need("barn")
		m.goats_fed_day = m.day
		if m.barn_hopper < _hopper_need("barn"):
			note += " The barn's hopper is empty."
	return note


func _sync_ages() -> void:
	while m.hen_ages.size() < m.hens:
		m.hen_ages.append(0)
	while m.hen_ages.size() > m.hens:
		m.hen_ages.pop_back()
	while m.goat_ages.size() < m.goats:
		m.goat_ages.append(0)
	while m.goat_ages.size() > m.goats:
		m.goat_ages.pop_back()


func _age_animals() -> void:
	_sync_ages()
	for i in m.hen_ages.size():
		m.hen_ages[i] = int(m.hen_ages[i]) + 1
	for i in m.goat_ages.size():
		m.goat_ages[i] = int(m.goat_ages[i]) + 1


func _grown_count(ages: Array, mature_days: int) -> int:
	var n := 0
	for a in ages:
		if int(a) >= mature_days:
			n += 1
	return n


func _grown_index(ages: Array, mature_days: int) -> int:
	for i in ages.size():
		if int(ages[i]) >= mature_days:
			return i
	return -1


func _sell_hen() -> void:
	_sync_ages()
	var i := _grown_index(m.hen_ages, m.HEN_MATURE_DAYS)
	if i < 0:
		m._show_message("No hen is grown yet. A grown hen sells for %d coins." % m.HEN_SELL)
		return
	m.hen_ages.remove_at(i)
	m.hens -= 1
	m.money += m.HEN_SELL
	m.stats["sold"] += 1
	_sync_ages()
	m.play_sfx("coin")
	m._show_message("You sell a grown hen for %d coins, %d more than you paid." % [m.HEN_SELL, m.HEN_SELL - m.HEN_PRICE])


func _sell_goat() -> void:
	_sync_ages()
	var i := _grown_index(m.goat_ages, m.GOAT_MATURE_DAYS)
	if i < 0:
		m._show_message("No goat is grown yet. A grown goat sells for %d coins." % m.GOAT_SELL)
		return
	m.goat_ages.remove_at(i)
	m.goats -= 1
	m.money += m.GOAT_SELL
	m.stats["sold"] += 1
	_sync_ages()
	m.play_sfx("coin")
	m._show_message("You sell a grown goat for %d coins, %d more than you paid." % [m.GOAT_SELL, m.GOAT_SELL - m.GOAT_PRICE])


func _int_list(values: Array) -> Array:
	var out: Array = []
	for v in values:
		out.append(int(v))
	return out


func _filled(n: int, value: int) -> Array:
	var out: Array = []
	for i in n:
		out.append(value)
	return out
