extends Area2D

@export var boxes = null
signal get_money
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$InteractionArea.interact = Callable(self, "_on_interact")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	boxes = get_overlapping_bodies()
	for box in boxes:
		#print(box)
		if box.is_in_group("Shippable"):
			print("box in me")
			get_money.emit()
			box.free()
func _on_interact():
	pass
