extends Area2D

@export var inside := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# rebind controls in editor -> editor settings -> shortcuts
	if inside and Input.is_action_pressed("ui_page_up"):
		for box in get_tree().get_nodes_in_group("guards"):
			box.boxed = true
