extends Area2D

@export var scanner = null
@export var inside := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	inside = false
	scanner = get_overlapping_bodies()
	for object in scanner:
		if object == get_node("../Player"):
			print("Player is in")
			inside = true
			break
			
	# rebind controls in editor -> editor settings -> shortcuts. remapped to E here
	if inside and Input.is_action_pressed("ui_E"):
		print("Boxing")
		for box in scanner:
			if box.is_in_group("Boxes"):
				box.add_to_group("Shippable")
				print("Box is boxed")
