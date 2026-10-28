class_name GameSettings
extends RefCounted

# The player's settings, shared by the start screen and the pause menu. They live in
# user://settings.cfg, apart from the saves, so every slot uses the same ones.

const PATH := "user://settings.cfg"
const OLD_PATH := "user://hallowvale_settings.json"   # music and sound on or off, before settings.cfg
const STEPS := 10                                      # volumes run from 0 (silent) to 10 (full)
const WINDOW_SIZES := [Vector2i.ZERO, Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]   # ZERO fills the screen
const MESSAGE_SPEEDS := ["Short", "Normal", "Long"]
const MESSAGE_SCALE := [0.7, 1.0, 1.6]

static var music_volume := 8
static var sfx_volume := 8
static var fullscreen := false
static var window_size := 0        # an index into WINDOW_SIZES
static var screen_shake := true
static var message_speed := 1      # an index into MESSAGE_SPEEDS


static func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) == OK:
		music_volume = clampi(int(cfg.get_value("audio", "music", music_volume)), 0, STEPS)
		sfx_volume = clampi(int(cfg.get_value("audio", "sfx", sfx_volume)), 0, STEPS)
		fullscreen = bool(cfg.get_value("display", "fullscreen", fullscreen))
		window_size = clampi(int(cfg.get_value("display", "window_size", window_size)), 0, WINDOW_SIZES.size() - 1)
		screen_shake = bool(cfg.get_value("game", "screen_shake", screen_shake))
		message_speed = clampi(int(cfg.get_value("game", "message_speed", message_speed)), 0, MESSAGE_SPEEDS.size() - 1)
	elif FileAccess.file_exists(OLD_PATH):
		# The old file only knew on or off. Off becomes silent, and the new file takes over.
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(OLD_PATH))
		if typeof(parsed) == TYPE_DICTIONARY:
			if not bool(parsed.get("music", true)):
				music_volume = 0
			if not bool(parsed.get("sfx", true)):
				sfx_volume = 0
		save_settings()


static func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "music", music_volume)
	cfg.set_value("audio", "sfx", sfx_volume)
	cfg.set_value("display", "fullscreen", fullscreen)
	cfg.set_value("display", "window_size", window_size)
	cfg.set_value("game", "screen_shake", screen_shake)
	cfg.set_value("game", "message_speed", message_speed)
	cfg.save(PATH)


# Sets the volumes, and the window too unless a tool has sized it for a screenshot.
static func apply(display: bool) -> void:
	_set_bus("Music", music_volume)
	_set_bus("SFX", sfx_volume)
	if display and DisplayServer.get_name() != "headless":
		_apply_window()


static func _set_bus(bus_name: String, volume: int) -> void:
	var i := AudioServer.get_bus_index(bus_name)
	if i < 0:
		AudioServer.add_bus()
		i = AudioServer.bus_count - 1
		AudioServer.set_bus_name(i, bus_name)
		AudioServer.set_bus_send(i, "Master")
	AudioServer.set_bus_mute(i, volume <= 0)
	AudioServer.set_bus_volume_db(i, linear_to_db(maxf(volume, 1) / float(STEPS)))


static func _apply_window() -> void:
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		return
	var size: Vector2i = WINDOW_SIZES[window_size]
	if size == Vector2i.ZERO:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	# A size bigger than the screen shrinks to fit it, and the window is centred.
	var screen := DisplayServer.screen_get_usable_rect()
	size = Vector2i(mini(size.x, screen.size.x), mini(size.y, screen.size.y))
	DisplayServer.window_set_size(size)
	DisplayServer.window_set_position(screen.position + (screen.size - size) / 2)


static func message_scale() -> float:
	return MESSAGE_SCALE[message_speed]


# Changes one setting from its button, then saves and applies it. Returns false for an action that isn't a setting.
static func change(action: String) -> bool:
	match action:
		"set_music_down": music_volume = maxi(music_volume - 1, 0)
		"set_music_up": music_volume = mini(music_volume + 1, STEPS)
		"set_sfx_down": sfx_volume = maxi(sfx_volume - 1, 0)
		"set_sfx_up": sfx_volume = mini(sfx_volume + 1, STEPS)
		"set_fullscreen": fullscreen = not fullscreen
		"set_window": window_size = (window_size + 1) % WINDOW_SIZES.size()
		"set_shake": screen_shake = not screen_shake
		"set_messages": message_speed = (message_speed + 1) % MESSAGE_SPEEDS.size()
		_: return false
	save_settings()
	apply(action == "set_fullscreen" or action == "set_window")
	return true


static func _window_text() -> String:
	var size: Vector2i = WINDOW_SIZES[window_size]
	return "Fill the screen" if size == Vector2i.ZERO else "%d × %d" % [size.x, size.y]


# The rows both menus draw. A row's second button sits left of its first, so left and right step a volume.
static func rows() -> Array:
	return [
		{"section": "Sound"},
		{"name": "Music volume", "value": _bar(music_volume), "button2": "−", "action2": "set_music_down", "button": "+", "action": "set_music_up"},
		{"name": "Sound effects volume", "value": _bar(sfx_volume), "button2": "−", "action2": "set_sfx_down", "button": "+", "action": "set_sfx_up"},
		{"section": "Display"},
		{"name": "Screen", "value": "Fullscreen" if fullscreen else "Windowed", "button": "Change", "action": "set_fullscreen"},
		{"name": "Window size", "value": _window_text() + (" (when windowed)" if fullscreen else ""), "button": "Change", "action": "set_window"},
		{"name": "Screen shake", "value": "On" if screen_shake else "Off", "button": "Change", "action": "set_shake"},
		{"section": "Messages"},
		{"name": "How long messages stay", "value": MESSAGE_SPEEDS[message_speed], "button": "Change", "action": "set_messages"},
	]


static func _bar(volume: int) -> String:
	return "Off" if volume == 0 else "%d%%" % (volume * 10)
