extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_pressed() -> void:
	get_tree().paused = false
	Audio.play_click()
	Ticket_Manager.reset(5)
	get_tree().change_scene_to_file("res://levels/warehouse_01/layout/game.tscn")
