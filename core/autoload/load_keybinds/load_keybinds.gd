extends Node

func _ready() -> void:
	var config = ConfigFile.new()
	config.load("user://settings.cfg")
	_load_defaults(config)
	var keys = config.get_section_keys("Controls")
	for action in keys:
		if InputMap.has_action(action):
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, config.get_value("Controls", action))


func _load_defaults(config: ConfigFile):
	for action in InputMap.get_actions():
		var events = InputMap.action_get_events(action)
		if (not events.is_empty()) and (not config.has_section_key("Controls", action)):
			config.set_value("Controls", action, events[0])
	config.save("user://settings.cfg")
