## Inventory system used by the Player.
##
## This is effectively the Storage class with max capacity 2.
## 
## Change current selection using buttons [1] and [2] or the scroll wheel.
## Drop current selection using [Q].
##
## Signals item_dropped after dropping an item, contains the spawned item base
## node rather than ItemData from item_removed.
class_name PlayerInventory extends Storage

var index : int = 0:
	set(val):
		if (val < 0) and (index <= 0):
			index = 1
		elif (val > 0) and (index >= max_capacity):
			index = 0
		else:
			index += val


func _ready() -> void:
	set_capacity(2)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory_up"):
		index -= 1
		return
	if event.is_action_pressed("inventory_down"):
		index += 1
		return
	if event.is_action_pressed("inventory_1"):
		index = 0
		return
	if event.is_action_pressed("inventory_2"):
		index = 1
		return
	if event.is_action_pressed("drop"):
		return
