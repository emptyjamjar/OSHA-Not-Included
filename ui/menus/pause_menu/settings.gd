## Settings button for pause menu.
extends TextureButton

signal settings_closed


func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


func _on_pressed() -> void:
	var scene = preload("res://ui/menus/settings_menu/settings_menu.tscn")
	var instance = scene.instantiate() as SettingsMenu
	instance.exit_pressed.connect(_on_settings_exited.bind(instance))
	add_child(instance)


func _on_settings_exited(menu: SettingsMenu) -> void:
	await menu.tree_exited
	settings_closed.emit()
