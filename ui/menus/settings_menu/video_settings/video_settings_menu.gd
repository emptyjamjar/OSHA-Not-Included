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
	var windowSize = DisplayServer.window_get_size()
	var index = _WINDOW_SIZES.find(windowSize)
	resolutionBtn.select(index)
	
	var windowMode = DisplayServer.window_get_mode()
	if windowMode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		fullscreenBtn.set_pressed_no_signal(true)
	elif windowMode == DisplayServer.WINDOW_MODE_WINDOWED:
		fullscreenBtn.set_pressed_no_signal(false)


func _on_resolution_item_selected(index: int) -> void:
	DisplayServer.window_set_size(_WINDOW_SIZES[index])
	config.set_value("Video", "Resolution", index)
	config.save("user://settings.cfg")


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	config.set_value("Video", "Fullscreen", toggled_on)
	config.save("user://settings.cfg")
