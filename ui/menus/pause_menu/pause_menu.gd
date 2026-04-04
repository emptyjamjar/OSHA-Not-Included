## Pause menu for the game.
extends Control

var isSubMenuOpen := false
var volume:float


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if isSubMenuOpen:
		return
	if event.is_action_pressed("pause") and InteractionManager.can_interact:
		get_tree().paused = not get_tree().paused
		visible = not visible
		if visible:
			Dialogic.Text.hide_textbox()
			Audio.play_open_menu()
			Audio.lower_music()
		else:
			Dialogic.Text.show_textbox()
			Audio.play_close_menu()
			Audio.reset_music_volume()


func _on_sub_menu_opened() -> void:
	isSubMenuOpen = true


func _on_sub_menu_closed() -> void:
	isSubMenuOpen = false
