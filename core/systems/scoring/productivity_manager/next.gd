extends TextureButton

var ticket_manager: TicketManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	ticket_manager = get_tree().get_first_node_in_group("Ticket Manager")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_pressed() -> void:
	get_tree().paused = false
	Audio.play_click()
	ticket_manager.reset()
	Level_Manager.next_level()
