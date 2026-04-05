extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_pressed() -> void:
	get_tree().paused = false
	Audio.play_click()
	Ticket_Manager.reset()
	Level_Manager.reset()
	get_tree().change_scene_to_file("res://ui/menus/main_menu/main_menu.tscn")
