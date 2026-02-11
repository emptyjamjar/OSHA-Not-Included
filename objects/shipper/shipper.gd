extends Area2D

@export var boxes = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$InteractionArea.interact = Callable(self, "_on_interact")

			
func _on_interact():
	boxes = get_overlapping_bodies()
	for box in boxes:
		#print(box)
		if box.is_in_group("Shippable"):
			box.free()
