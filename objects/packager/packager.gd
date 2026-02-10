extends Area2D

@export var scanner = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$InteractionArea.interact = Callable(self, "_on_interact")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
# on interacting with the box, energy decreases: 
func _on_interact():
	# DO NOT TAKE THE BOX MASK OFF LEVEL 3
	scanner = get_overlapping_bodies()
	# rebind controls in editor -> editor settings -> shortcuts. remapped to E here
	print(scanner)
	for box in scanner:
		if box.is_in_group("Boxes"):
			box.add_to_group("Shippable")
			print("Box is boxed")
			break
