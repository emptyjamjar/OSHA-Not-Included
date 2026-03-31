class_name VideoSettingsMenu extends VBoxContainer

@export var resolutionBtn : OptionButton
@export var fullscreenBtn : CheckButton

var config : ConfigFile
const _WINDOW_SIZES : Array[Vector2i] = [
	Vector2i(1920, 1080),
	Vector2i(1600, 900),
	Vector2i(1280, 720),
	Vector2i(768, 432),
]


func _ready() -> void:
	var windowMode = DisplayServer.window_get_mode()
	print(windowMode)
	if windowMode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		fullscreenBtn.button_pressed = true
	else:
		fullscreenBtn.button_pressed = false


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		
	config.set_value("Video", "Fullscreen", toggled_on)
	config.save("user://settings.cfg")
