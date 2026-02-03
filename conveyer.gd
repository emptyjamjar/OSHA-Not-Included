extends Area2D

@export var boxes = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	boxes = get_overlapping_bodies()
	for box in boxes:
		#print(box)
		if box.is_in_group("Boxable"):
			box.free()
