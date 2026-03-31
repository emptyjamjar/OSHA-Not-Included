## Loads saved player settings from a config file.
## If the config file does not exist it will be created with default values.
extends Node


func _ready() -> void:
	var config = ConfigFile.new()
	config.load("user://settings.cfg")
	_load_video(config)
	_load_audio(config)
	_load_controls(config)
	config.save("user://settings.cfg")


func _load_controls(config: ConfigFile) -> void:
	# Default values
	for action in InputMap.get_actions():
		var events = InputMap.action_get_events(action)
		if (not events.is_empty()) and (not config.has_section_key("Controls", action)):
			config.set_value("Controls", action, events[0])
	
	# Load from config file
	var keys = config.get_section_keys("Controls")
	for action in keys:
		if InputMap.has_action(action):
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, config.get_value("Controls", action))


func _load_audio(config: ConfigFile) -> void:
	# Default values
	if not config.has_section("Master_Audio"):
		var volume = db_to_linear(AudioServer.get_bus_volume_db(0))
		var state = not AudioServer.is_bus_mute(0)
		config.set_value("Master_Audio", "toggle", state)
		config.set_value("Master_Audio", "volume", volume)
	if not config.has_section("SFX_Audio"):
		var volume = db_to_linear(AudioServer.get_bus_volume_db(1))
		var state = not AudioServer.is_bus_mute(1)
		config.set_value("SFX_Audio", "toggle", state)
		config.set_value("SFX_Audio", "volume", volume)
	if not config.has_section("Music_Audio"):
		var volume = db_to_linear(AudioServer.get_bus_volume_db(2))
		var state = not AudioServer.is_bus_mute(2)
		config.set_value("Music_Audio", "toggle", state)
		config.set_value("Music_Audio", "volume", volume)
	
	# Load from config file
	var sections = ["Master_Audio", "SFX_Audio", "Music_Audio"]
	for bus in range(AudioServer.bus_count):
		var state = config.get_value(sections[bus], "toggle", true)
		AudioServer.set_bus_mute(bus, not state)
		var value = config.get_value(sections[bus], "volume", 100.0)
		AudioServer.set_bus_volume_db(bus, linear_to_db(value))


func _load_video(config: ConfigFile) -> void:
	# Default values
	if not config.has_section("Video"):
		config.set_value("Video", "Resolution", 0)
		config.set_value("Video", "Fullscreen", true)
	
	# Load from config file
	var index = config.get_value("Video", "Resolution", 0)
	if index < 0 or index > VideoSettingsMenu._WINDOW_SIZES.size():
		index = 0
	DisplayServer.window_set_size(VideoSettingsMenu._WINDOW_SIZES[index])
	
	var windowMode = config.get_value("Video", "Fullscreen", true)
	if windowMode:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
