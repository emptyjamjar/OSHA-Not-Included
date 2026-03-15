## Button used to rebind controls
class_name HotkeyRebindButton extends VBoxContainer

@export var label : Label
@export var button : Button

@export var action_name : String = "action"


func _ready() -> void:
	set_process_unhandled_key_input(false)
	set_text_for_key()
	label.text = action_name
	button.toggled.connect(_on_button_toggled)


func set_text_for_key() -> void:
	var action_events = InputMap.action_get_events(action_name)
	var action_event = action_events[0]
	var action_keycode = OS.get_keycode_string(action_event.physical_keycode)
	
	button.text = "%s" % action_keycode


func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		button.text = "Press any key..."
		set_process_unhandled_key_input(true)
	else:
		set_process_unhandled_key_input(false)


func _unhandled_key_input(event: InputEvent) -> void:
	# Pressing escape will cancel the hotkey rebind
	if not event.is_action_pressed("pause"):
		InputMap.action_erase_events(action_name)
		InputMap.action_add_event(action_name, event)
	set_process_unhandled_key_input(false)
	set_text_for_key()
	button.button_pressed = false
