class_name ToiletPaper extends Item


func _ready() -> void:
	iArea.interact = Callable(self, "_on_interact")
	iArea.action_name = "pickup"


func _on_interact():
	# Uncomment code when player inventory is made global
	#PlayerInventory.add_held_item(self)
	pass
