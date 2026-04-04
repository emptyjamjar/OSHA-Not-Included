## Controls main menu buttons
extends Control


func _on_play_pressed() -> void:
	# So play cannot be pressed if other menu is open
	if (get_node_or_null("SettingsMenu") != null):
		return
	Audio.play_click()
	PlayerInventory.reset()
	get_tree().change_scene_to_file("res://game.tscn")


func _on_settings_pressed() -> void:
	if get_node_or_null("SettingsMenu") != null: # To prevent multiple instances being available
		return
	
	var scene = preload("res://ui/menus/settings_menu/settings_menu.tscn")
	var instance = scene.instantiate() as SettingsMenu
	add_child(instance)


func _on_tutorial_pressed() -> void:
	if get_node_or_null("SettingsMenu") != null: # To prevent multiple instances being available
		return
	
	var scene = preload("res://ui/menus/tutorial_menu/tutorial_menu.tscn")
	var instance = scene.instantiate() as TutorialMenu
	add_child(instance)


func _on_quit_pressed() -> void:
	get_tree().quit()
