extends TextureButton

## Back to main menu button for fail state

var ticket_manager: TicketManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	ticket_manager = get_tree().get_first_node_in_group("Ticket Manager")

func _on_pressed() -> void:
	get_tree().paused = false
	Audio.play_click()
	ticket_manager.reset()
	Level_Manager.reset()
	get_tree().change_scene_to_file("res://ui/menus/main_menu/main_menu.tscn")
