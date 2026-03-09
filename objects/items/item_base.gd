class_name ItemBase extends Node2D

signal picked_up(item: ItemBase)

@export var iArea : InteractionArea
@export var sprite : Sprite2D
@export var data : ItemData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	iArea.add_to_group("Boxes")
	# Setting interaction values
	iArea.interact = Callable(self, "_on_interact")
	iArea.action_name = "pickup"
	# Setting item data values
	sprite.texture = data.texture

func _on_interact():
	picked_up.emit(self)
	var result = PlayerInventory.add(data.duplicate(true))
	if result:
		self.queue_free()
