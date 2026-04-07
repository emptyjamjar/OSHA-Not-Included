class_name ItemBase extends Node2D

signal picked_up(item: ItemBase)

@export var iArea : InteractionArea
@export var sprite : Sprite2D
@export var data : ItemData
@export var body: StaticBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Setting interaction values
	iArea.interact = Callable(self, "_on_interact")
	iArea.action_name = "pickup"
	# Setting item data values
	sprite.texture = data.texture

func _on_interact():
	var result = PlayerInventory.add(data.duplicate(true))
	if result:
		picked_up.emit(self)
		self.queue_free()

##Removes the "Dropped Item" group from the body. Called when spawned by a conveyor. Otherwise keep the group.
func undrop_body():
	body.remove_from_group("Dropped Item")
