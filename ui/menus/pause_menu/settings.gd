## Settings button for menus.
extends TextureButton

signal settings_closed


func _on_pressed() -> void:
	var scene = preload("res://ui/menus/settings_menu/settings_menu.tscn")
	var instance = scene.instantiate() as SettingsMenu
	Audio.play_click()
	instance.global_position.y += 10
	instance.exit_pressed.connect(_on_settings_exited.bind(instance))
	add_child(instance)


func _on_settings_exited(settings: SettingsMenu) -> void:
	await settings.tree_exited
	settings_closed.emit()
