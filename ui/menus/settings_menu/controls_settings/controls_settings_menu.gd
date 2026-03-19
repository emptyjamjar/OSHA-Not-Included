extends VBoxContainer

signal changing_keybind(state: bool)

var config : ConfigFile


func _ready() -> void:
	# Connect Signals
	var children = get_children()
	for child in children:
		if child is HotkeyRebindButton:
			child.rebind_started.connect(_on_rebind_started)
			child.rebind_ended.connect(_on_rebind_ended)


func _on_rebind_started():
	changing_keybind.emit(true)


func _on_rebind_ended(action_name: String):
	var event = InputMap.action_get_events(action_name)[0]
	config.set_value("Controls", action_name, event)
	config.save("user://settings.cfg")
	changing_keybind.emit(false)
