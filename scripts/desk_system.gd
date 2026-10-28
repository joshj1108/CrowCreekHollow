class_name DeskSystem
extends RefCounted

var m: MainGame


func _init(main: MainGame) -> void:
	m = main


func _read_desk() -> void:
	if not m.diary_found:
		m._find_diary()
		return
	for letter in m.desk_mail:
		letter["unread"] = false
	m._toggle_tab("Desk")


func _desk_action(action_id: String) -> void:
	if action_id == "pay_tax":
		_pay_tax()
	elif action_id == "pay_deed":
		m.estate._pay_deed()
	elif action_id == "diary":
		m._open_diary()
		return
	elif action_id == "mail_clear":
		_clear_read_mail()
	elif action_id.begins_with("pastime:"):
		_play_pastime(action_id.trim_prefix("pastime:"))
	elif action_id.begins_with("order:"):
		_order(action_id.trim_prefix("order:"))
	m._refresh_panel()


# --- Pastimes ---
# Solitaire and sudoku are not played out: a game just passes the time, and the day's first does you good
# (HomesteadRewards). Each game uses up one game from the pack of cards or one puzzle from the book.

func _hours_text(hours: float) -> String:
	var mins := roundi(hours * 60.0)
	if mins % 60 == 0:
		return "%d hour%s" % [mins / 60, "" if mins == 60 else "s"]
	return "%d h %d min" % [mins / 60, mins % 60]


func _pastime_hours(kind: String) -> float:
	return m.SUDOKU_HOURS if kind == "sudoku" else m.SOLITAIRE_HOURS


func _pastime_left(kind: String) -> int:
	return m.sudoku_puzzles if kind == "sudoku" else m.card_games


func _can_pastime(kind: String) -> bool:
	return _pastime_left(kind) > 0 and m.current_hour + _pastime_hours(kind) <= m.PASTIME_LAST_HOUR


func _play_pastime(kind: String) -> void:
	var hours := _pastime_hours(kind)
	if _pastime_left(kind) <= 0:
		m._show_message("The sudoku book is full. Order a new one from the catalog." if kind == "sudoku" else "The cards are too worn to play. Order a new pack from the catalog.")
		return
	if m.current_hour + hours > m.PASTIME_LAST_HOUR:
		m._show_message("It is too late for that. Get some sleep.")
		return
	# Time passes as if you had stood here for it: needs drop and the fire burns down.
	m.clock += hours * m.DAY_LENGTH / (m.DAY_END_HOUR - m.START_HOUR)
	m.current_hour += hours
	m._update_needs(hours)
	# One game a day does you good: sanity, and some of the lost limit back. A second does nothing more.
	var gain := m.rewards._pastime_done() if m.entertained_day != m.day else ""
	m.entertained_day = m.day
	m._close_panel()
	if kind == "sudoku":
		m.sudoku_puzzles -= 1
		m._show_message("You work through a sudoku over %s.%s%s" % [_hours_text(hours), gain, " That was the last puzzle in the book." if m.sudoku_puzzles == 0 else ""])
	else:
		m.card_games -= 1
		m._show_message("You play solitaire for %s.%s%s" % [_hours_text(hours), gain, " The cards are worn out now." if m.card_games == 0 else ""])


# --- The catalog ---
# Everything bought for the farm is ordered here: paid at once, delivered with the next morning's post.

func _catalog() -> Array:
	var items: Array = [
		{"id": "cards", "section": "Pastimes", "name": "Pack of cards", "price": m.CARDS_PRICE, "detail": "%d games of solitaire" % m.CARDS_GAMES, "ok": true, "why": ""},
		{"id": "oil", "section": "Supplies", "name": "Lamp oil", "price": m.LAMP_OIL_PRICE, "detail": "%d held, for treks" % int(m.materials["lamp_oil"]), "ok": true, "why": ""},
		{"id": "sudoku", "section": "Pastimes", "name": "Sudoku book", "price": m.SUDOKU_BOOK_PRICE, "detail": "%d puzzles" % m.SUDOKU_BOOK_PUZZLES, "ok": true, "why": ""},
	]
	# A pack of each crop's seeds, from CROPS. Seeds can be ordered out of season, to plant when it comes.
	for kind in m.CROPS:
		var c: Dictionary = m.CROPS[kind]
		var pack := int(c["pack"])
		items.append({"id": "seeds_" + kind, "section": "Seeds", "name": "%d %s seeds" % [pack, str(c["label"]).to_lower()],
			"price": int(c["seed_price"]) * pack, "detail": "%d held, grows in %s" % [int(m.inventory[c["seed"]]), m.farm._seasons_text(kind)],
			"ok": m.farm._crop_unlocked(kind), "why": "needs Farming %d" % int(c["level"])})
	var hens_coming := m.hens + _on_order("hen")
	items.append({"id": "hen", "section": "Livestock", "name": "Hen", "price": m.HEN_PRICE, "detail": "%d of %d in the coop" % [hens_coming, m.COOP_HENS_MAX],
		"ok": m.coop_built and hens_coming < m.COOP_HENS_MAX, "why": "build the coop first" if not m.coop_built else "the coop is full"})
	var goats_coming := m.goats + _on_order("goat")
	items.append({"id": "goat", "section": "Livestock", "name": "Goat", "price": m.GOAT_PRICE, "detail": "%d of %d in the barn" % [goats_coming, m.BARN_GOATS_MAX],
		"ok": m.barn_built and goats_coming < m.BARN_GOATS_MAX, "why": "build the barn first" if not m.barn_built else "the barn is full"})
	return items


func _catalog_item(id: String) -> Dictionary:
	for item in _catalog():
		if str(item["id"]) == id:
			return item
	return {}


func _on_order(id: String) -> int:
	return m.desk_orders.count(id)


# The orders as a list, with repeats counted: "5 turnip seeds, hen (x2)".
func _orders_text() -> String:
	var counts := {}
	for id in m.desk_orders:
		counts[id] = int(counts.get(id, 0)) + 1
	var parts: Array = []
	for id in counts:
		var label := str(_catalog_item(str(id)).get("name", id)).to_lower()
		parts.append(label if int(counts[id]) == 1 else "%s (x%d)" % [label, int(counts[id])])
	return ", ".join(PackedStringArray(parts))


func _order(id: String) -> void:
	var item := _catalog_item(id)
	if item.is_empty():
		return
	if not bool(item["ok"]):
		m._show_message("You can't order that: %s." % str(item["why"]))
		return
	var price := int(item["price"])
	if m.money < price:
		m._show_message("That costs %d coins. You have %d." % [price, m.money])
		return
	m.play_sfx("coin")
	m.money -= price
	m.desk_orders.append(id)
	m._show_message("You order %s for %d coins. It comes with the morning post." % [str(item["name"]).to_lower(), price])


# Opens the morning's parcels. Returns what came, or an empty string.
func _deliver_orders() -> String:
	if m.desk_orders.is_empty():
		return ""
	var list := _orders_text()
	for id in m.desk_orders:
		match str(id):
			"cards":
				m.card_games = m.CARDS_GAMES
			"oil":
				m.materials["lamp_oil"] += 1
			"sudoku":
				m.sudoku_puzzles = m.SUDOKU_BOOK_PUZZLES
			"hen":
				m.hens += 1
			"goat":
				m.goats += 1
				m.stats["goats_bought"] += 1
			var other:
				var kind := str(other).trim_prefix("seeds_")
				if str(other).begins_with("seeds_") and m.CROPS.has(kind):
					m.inventory[m.CROPS[kind]["seed"]] += int(m.CROPS[kind]["pack"])
	m.desk_orders = []
	_add_letter("Delivery", "Your catalog order came: %s. Any animals are already in their pens." % list)
	return " Your catalog order came: %s." % list


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
	m._show_message("You put the read letters away in the drawer.")


func _date_text(day_number: int) -> String:
	var d := m._calendar_date(day_number)
	return "%s %d" % [m.MONTH_NAMES[int(d["month"])], int(d["day"])]


func _tax_text() -> String:
	if m.tax_owed <= 0:
		return "paid up for this quarter"
	return "%d coins owed, due %s" % [m.tax_owed, _date_text(m.tax_due_day)]


# Buildings on the farm, for the property value.
func _building_count() -> int:
	var n := 0
	for built in [m.coop_built, m.barn_built, m.cellar_built, m.cooler_built, m.smokehouse_built, m.furnace_built, m.woodshed_built]:
		if built:
			n += 1
	return n


# Lamp posts and sprinklers on the farm, for the property value.
func _fixture_count() -> int:
	return m.projects._count("lamp") + m.projects._count("sprinkler") + m.projects._count("sprinkler_big")


# The property value: the quarterly bill, from the house and its extensions, the buildings, the plots, the
# livestock and the fixtures. Keeping the farm well doesn't raise it. Nothing is billed once the deed is bought.
func _property_value() -> int:
	var house_mult := pow(m.PROPERTY_HOUSE_GROWTH, m.house_stage)
	var building_mult := 1.0 + m.PROPERTY_PER_BUILDING * _building_count() + m.estate.EXTENSION_VALUE * m.estate.built.size()
	var plot_mult := 1.0 + m.PROPERTY_PER_PLOT * (int(m.plot_two_open) + int(m.plot_three_open))
	var stock := m.PROPERTY_PER_HEN * m.hens + m.PROPERTY_PER_GOAT * m.goats + m.PROPERTY_PER_FIXTURE * _fixture_count()
	return roundi(m.PROPERTY_TAX * house_mult * building_mult * plot_mult) + stock


func _property_text() -> String:
	if m.estate._deed_owned():
		return "The deed is yours: no tax is owed on the farm."
	return "%d coins a quarter. Starts at %d; x%.1f per house upgrade, +%d%% per building (%d), +%d%% per extension (%d), +%d%% per farm plot past the first (%d), and %d a hen, %d a goat, %d a lamp post or sprinkler." % [
		_property_value(), m.PROPERTY_TAX, m.PROPERTY_HOUSE_GROWTH, int(m.PROPERTY_PER_BUILDING * 100), _building_count(),
		int(m.estate.EXTENSION_VALUE * 100), m.estate.built.size(),
		int(m.PROPERTY_PER_PLOT * 100), int(m.plot_two_open) + int(m.plot_three_open), m.PROPERTY_PER_HEN, m.PROPERTY_PER_GOAT, m.PROPERTY_PER_FIXTURE]


func _tax_evicts() -> bool:
	return m.tax_owed > 0 and m.day - m.tax_due_day >= m.TAX_EVICT_DAYS


# Each morning: a new quarterly bill, then reminders for any unpaid tax. Returns a note for the morning message.
func _mail_day() -> String:
	var note := _deliver_orders()
	var date := m._calendar_date(m.day)
	if int(date["day"]) == 1 and m.TAX_MONTHS.has(int(date["month"])) and m.day > 1 and not m.estate._deed_owned():
		if m.tax_owed == 0:
			m.tax_due_day = m.day + m.TAX_GRACE_DAYS
			m.tax_stage = 0
		var bill := _property_value()
		m.tax_owed += bill
		_add_letter("Property tax bill", "Your quarterly property tax is %d coins, based on the value of the farm. Pay it at this desk by %s, or the land will be taken." % [bill, _date_text(m.tax_due_day)])
		note += " Post came through the mail slot, and a property tax bill is on the desk."
	if m.tax_owed > 0:
		var late := m.day - m.tax_due_day
		if late >= m.TAX_FINAL_DAYS and m.tax_stage < 2:
			m.tax_stage = 2
			_add_letter("Final notice", "You still owe %d coins in property tax. Pay within %d days or the land will be taken." % [m.tax_owed, m.TAX_EVICT_DAYS - late])
			note += " A final notice is on the desk."
		elif late >= 1 and m.tax_stage < 1:
			m.tax_stage = 1
			_add_letter("Payment overdue", "The property tax of %d coins was due %s. Please pay at this desk." % [m.tax_owed, _date_text(m.tax_due_day)])
			note += " A payment reminder is on the desk."
	return note


func _pay_tax() -> void:
	if m.tax_owed <= 0:
		m._show_message("Nothing is owed on the property tax.")
		return
	if m.money < m.tax_owed:
		m._show_message("You need %d coins to pay the property tax." % m.tax_owed)
		return
	var paid := m.tax_owed
	m.money -= paid
	m.tax_owed = 0
	m.tax_due_day = 0
	m.tax_stage = 0
	_add_letter("Receipt", "Property tax of %d coins paid in full. The land is yours for another quarter." % paid)
	m._show_message("You pay the property tax of %d coins." % paid)


# The land is lost: the save is removed and the start screen says why.
func _evict() -> void:
	SaveSystem.delete_save(m._save_path())
	TitleMenu.notice = "The farm was taken. The property tax went unpaid, and you lost the land."
	m._quit_to_title()


# Blinks red once a second while the player is in the house and there is unread post, or the diary
# is still in the drawer.
func _update_desk_light() -> void:
	if m.desk_light == null:
		return
	var blinking := m.inside and (_unread_count() > 0 or not m.diary_found)
	m.desk_light.enabled = blinking
	if blinking:
		m.desk_light.energy = 1.4 if fmod(Time.get_ticks_msec() / 1000.0, 1.0) < 0.5 else 0.0
