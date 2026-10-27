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
	m._show_message("You feed the hens.")


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
