## Packages player's currently held item
extends Area2D

@export var iArea : InteractionArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	iArea.interact = Callable(self, "_on_interact")
	iArea.action_name = "package item"
	


# on interacting with the box, energy decreases: 


func _on_interact():
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
