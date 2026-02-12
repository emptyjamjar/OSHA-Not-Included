class_name ItemBase extends Node2D

signal picked_up(item: ItemBase)
signal dropped(item: ItemBase)

@export var iArea : InteractionArea
@export var sprite : Sprite2D
@export var data : ItemData

var isHeld := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	iArea.add_to_group("Boxes")
	
	# Setting interaction values
	iArea.interact = Callable(self, "_on_interact")
	iArea.action_name = "pickup"
	
	# Setting item data values
	sprite.texture = data.texture

func _on_interact():
	if isHeld:
		print(name + " dropped")
		isHeld = false
		dropped.emit(self)
		var game := get_tree().get_first_node_in_group("game")
		iArea.action_name = "pickup"
		reparent(game)
	else:
		print(name + " picked up")
		isHeld = true
		picked_up.emit(self)
		var player := get_tree().get_first_node_in_group("player")
		global_position = player.global_position
		iArea.action_name = "drop"
		reparent(player)
