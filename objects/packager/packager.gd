## Packages player's currently held item
extends Area2D

@export var iArea : InteractionArea

signal packager_dialogue

var first_package := false

@onready var game = get_tree().get_first_node_in_group("game")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	iArea.interact = Callable(self, "_on_interact")
	iArea.action_name = "package item"
	


# on interacting with the box, energy decreases: 


func _on_interact():
	if first_package == false && game.game_state == 2:
		emit_signal("packager_dialogue")
		first_package = true
	var data : ItemData = PlayerInventory.get_item()
	if  data == null or data.type == ItemData.Type.PACKAGE:
		#Play a sound to say that nothing happens.
		InteractionManager.invalid_interaction()
		Audio.play_invalid_interaction()
		return
	data.uiTexture = data.texture
	data.texture = load("res://objects/package/Temporary_Package.png")
	data.type = ItemData.Type.PACKAGE
	data.description = data.description + "\nPACKAGED"
	PlayerInventory.drop_item()
