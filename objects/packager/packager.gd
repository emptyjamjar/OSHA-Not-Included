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
	if  data == null:
		return
	data.texture = load("res://objects/package/Temporary_Package.png")
	data.uiTexture = null
	data.type = ItemData.Type.PACKAGE
	data.description = data.description + "\nPACKAGED"
	PlayerInventory.drop_item()
