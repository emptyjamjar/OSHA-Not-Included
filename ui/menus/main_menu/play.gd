extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_button_up() -> void:
	get_tree().change_scene_to_file("res://game.tscn") # Replace with function body.
