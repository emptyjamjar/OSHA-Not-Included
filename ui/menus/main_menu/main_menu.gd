## Controls main menu buttons
extends Control


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")


func _on_settings_pressed() -> void:
	var scene = preload("res://ui/menus/settings_menu/settings_menu.tscn")
	var instance = scene.instantiate() as SettingsMenu
	add_child(instance)


func _on_tutorial_pressed() -> void:
	var scene = preload("res://ui/menus/tutorial_menu/tutorial_menu.tscn")
	var instance = scene.instantiate() as TutorialMenu
	add_child(instance)
