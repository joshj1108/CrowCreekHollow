class_name DeskSystem
extends RefCounted

var m: MainGame


func _init(main: MainGame) -> void:
	m = main


func _read_desk() -> void:
	for letter in m.desk_mail:
		letter["unread"] = false
	m._toggle_tab("Desk")


func _boredom_check() -> String:
	# Paused while the desk games are reworked. Flip BOREDOM_ENABLED to restore the drain.
	if not m.BOREDOM_ENABLED or m.entertained_day == m.day:
		return ""
	var before := m._sanity_max()
	m.boredom_loss = minf(m.boredom_loss + m.BOREDOM_DRAIN, m.BOREDOM_MAX_LOSS)
	m.sanity = minf(m.sanity, m._sanity_max())
	if m._sanity_max() < before:
		return " Nothing to occupy you today, so your sanity limit slips to %d." % int(m._sanity_max())
	return ""


func _desk_action(action_id: String) -> void:
	if action_id == "pay_tax":
		_pay_tax()
	elif action_id == "mail_clear":
		_clear_read_mail()
	elif action_id.begins_with("game_new:"):
		if action_id.ends_with("sudoku"):
			_start_sudoku()
		else:
			_start_solitaire()
	elif action_id == "game_quit":
		m.desk_game = {}
	elif m.desk_game.get("kind", "") == "sudoku":
		if action_id.begins_with("sudoku_next:"):
			_sudoku_next(int(action_id.trim_prefix("sudoku_next:")))
		elif action_id == "sudoku_check":
			_sudoku_check()
	elif m.desk_game.get("kind", "") == "solitaire":
		if action_id == "sol_draw":
			_sol_draw()
		elif action_id == "sol_play":
			_sol_play()
	m._refresh_panel()


func _finish_game(result: String) -> void:
	m.entertained_day = m.day
	m.desk_game = {}
	m._show_message("%s You are entertained for the day." % result)


func _zeros(n: int) -> Array:
	var out: Array = []
	for i in n:
		out.append(0)
	return out


func _start_sudoku() -> void:
	# Relabelling the digits of a valid grid still gives a valid grid, so each game differs.
	var digits := [1, 2, 3, 4]
	digits.shuffle()
	var solution: Array = []
	for r in 4:
		for c in 4:
			solution.append(digits[m.SUDOKU_BASE[r][c] - 1])
	var puzzle: Array = solution.duplicate()
	var order: Array = range(16)
	order.shuffle()
	# Clear cells one at a time, keeping any clear that would leave more than one answer.
	for i in order:
		var keep: int = puzzle[i]
		puzzle[i] = 0
		if _sudoku_solutions(puzzle, 2) != 1:
			puzzle[i] = keep
	m.desk_game = {"kind": "sudoku", "solution": solution, "puzzle": puzzle, "guess": _zeros(16)}


func _sudoku_solutions(board: Array, limit: int) -> int:
	var idx := board.find(0)
	if idx == -1:
		return 1
	var found := 0
	for v in range(1, 5):
		if _sudoku_fits(board, idx / 4, idx % 4, v):
			board[idx] = v
			found += _sudoku_solutions(board, limit - found)
			board[idx] = 0
			if found >= limit:
				break
	return found


func _sudoku_fits(board: Array, r: int, c: int, v: int) -> bool:
	for k in 4:
		if int(board[r * 4 + k]) == v or int(board[k * 4 + c]) == v:
			return false
	var br := r / 2 * 2
	var bc := c / 2 * 2
	for dr in 2:
		for dc in 2:
			if int(board[(br + dr) * 4 + bc + dc]) == v:
				return false
	return true


func _sudoku_next(i: int) -> void:
	var guess: Array = m.desk_game["guess"]
	guess[i] = (int(guess[i]) + 1) % 5


func _sudoku_check() -> void:
	var puzzle: Array = m.desk_game["puzzle"]
	var guess: Array = m.desk_game["guess"]
	var solution: Array = m.desk_game["solution"]
	var right := 0
	var wrong := 0
	for i in 16:
		if int(puzzle[i]) != 0 or int(guess[i]) == 0:
			continue
		if int(guess[i]) == int(solution[i]):
			puzzle[i] = solution[i]
			right += 1
		else:
			wrong += 1
		guess[i] = 0
	if right == 0 and wrong == 0:
		m._show_message("Choose some numbers first, then check them.")
		return
	if not puzzle.has(0):
		_finish_game("The sudoku is solved.")
		return
	m._show_message("%d right and locked in, %d wrong and cleared." % [right, wrong])


func _start_solitaire() -> void:
	var stock: Array = []
	for card in 52:
		stock.append(card)
	stock.shuffle()
	# A card is 0 to 51: suit = card / 13, rank = card % 13 + 1.
	m.desk_game = {"kind": "solitaire", "stock": stock, "waste": [], "found": [0, 0, 0, 0], "passes": 0}


func _card_name(card: int) -> String:
	return "%s of %s" % [m.DESK_RANKS[card % 13], m.DESK_SUITS[card / 13]]


func _sol_can_play() -> bool:
	var waste: Array = m.desk_game["waste"]
	if waste.is_empty():
		return false
	var card := int(waste.back())
	var found: Array = m.desk_game["found"]
	return int(found[card / 13]) == card % 13


func _sol_can_turn() -> bool:
	var stock: Array = m.desk_game["stock"]
	var waste: Array = m.desk_game["waste"]
	if not stock.is_empty():
		return true
	return not waste.is_empty() and int(m.desk_game["passes"]) < m.SOL_PASSES


func _sol_draw() -> void:
	if not _sol_can_turn():
		m._show_message("Nothing left to turn over.")
		return
	var stock: Array = m.desk_game["stock"]
	var waste: Array = m.desk_game["waste"]
	if not stock.is_empty():
		waste.append(stock.pop_back())
	else:
		# The waste goes back face down: one more pass through the deck.
		var back: Array = waste.duplicate()
		back.reverse()
		m.desk_game["stock"] = back
		m.desk_game["waste"] = []
		m.desk_game["passes"] = int(m.desk_game["passes"]) + 1
	_sol_check_end()


func _sol_play() -> void:
	if not _sol_can_play():
		m._show_message("That card cannot go up yet.")
		return
	var waste: Array = m.desk_game["waste"]
	var card := int(waste.pop_back())
	var found: Array = m.desk_game["found"]
	found[card / 13] = int(found[card / 13]) + 1
	_sol_check_end()


func _sol_check_end() -> void:
	var found: Array = m.desk_game["found"]
	var total := 0
	for n in found:
		total += int(n)
	if total == 52:
		_finish_game("You built all four foundations. Solitaire won.")
	elif _sol_stuck():
		_finish_game("No card can move. Solitaire is over with %d of 52 played." % total)


func _sol_stuck() -> bool:
	var stock: Array = m.desk_game["stock"]
	return stock.is_empty() and not _sol_can_turn() and not _sol_can_play()


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


# The property value: the quarterly bill, from the house, the buildings, the plots and how clean the farm is kept.
func _property_value() -> int:
	var house_mult := pow(m.PROPERTY_HOUSE_GROWTH, m.house_stage)
	var building_mult := 1.0 + m.PROPERTY_PER_BUILDING * _building_count()
	var plot_mult := 1.0 + m.PROPERTY_PER_PLOT * (int(m.plot_two_open) + int(m.plot_three_open))
	var clean_mult := 1.0 + m.PROPERTY_PER_CLEAN_NIGHT * mini(m.clean_nights, m.PROPERTY_CLEAN_NIGHTS_MAX)
	return roundi(m.PROPERTY_TAX * house_mult * building_mult * plot_mult * clean_mult)


func _property_text() -> String:
	return "%d coins a quarter. Starts at %d; x%.1f per house upgrade, +%d%% per building (%d), +%d%% per farm plot past the first (%d), +%d%% for %d clean nights in a row (up to %d)." % [
		_property_value(), m.PROPERTY_TAX, m.PROPERTY_HOUSE_GROWTH, int(m.PROPERTY_PER_BUILDING * 100), _building_count(),
		int(m.PROPERTY_PER_PLOT * 100), int(m.plot_two_open) + int(m.plot_three_open),
		int(m.PROPERTY_PER_CLEAN_NIGHT * 100), m.clean_nights, m.PROPERTY_CLEAN_NIGHTS_MAX]


func _tax_evicts() -> bool:
	return m.tax_owed > 0 and m.day - m.tax_due_day >= m.TAX_EVICT_DAYS


# Each morning: a new quarterly bill, then reminders for any unpaid tax. Returns a note for the morning message.
func _mail_day() -> String:
	var note := ""
	var date := m._calendar_date(m.day)
	if int(date["day"]) == 1 and m.TAX_MONTHS.has(int(date["month"])) and m.day > 1:
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
	DirAccess.remove_absolute(ProjectSettings.globalize_path(m._save_path()))
	TitleMenu.notice = "The farm was taken. The property tax went unpaid, and you lost the land."
	m._quit_to_title()


# Blinks red once a second while there is unread post and the player is in the house.
func _update_desk_light() -> void:
	if m.desk_light == null:
		return
	var blinking := m.inside and _unread_count() > 0
	m.desk_light.enabled = blinking
	if blinking:
		m.desk_light.energy = 1.4 if fmod(Time.get_ticks_msec() / 1000.0, 1.0) < 0.5 else 0.0
