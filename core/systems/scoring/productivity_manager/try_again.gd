## Try again button for fail state of score report

extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_pressed() -> void:
	get_tree().paused = false
	Audio.play_click()
	Ticket_Manager.replay()
	Level_Manager.replay_level()
