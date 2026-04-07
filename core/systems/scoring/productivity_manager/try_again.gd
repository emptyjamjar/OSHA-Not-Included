## Try again button for fail state of score report

extends TextureButton

var ticket_manager: TicketManager


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	ticket_manager = get_tree().get_first_node_in_group("Ticket Manager")


func _on_pressed() -> void:
	get_tree().paused = false
	Audio.play_click()
	ticket_manager.replay()
	Level_Manager.replay_level()
