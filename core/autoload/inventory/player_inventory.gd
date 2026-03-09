## Inventory system used by the Player.
##
## This is effectively the Storage class with max capacity 2.
## 
## Change current selection using buttons [1] and [2] or the scroll wheel.
## Drop current selection using [Q].
##
## Signals item_dropped after dropping an item with drop_item, contains the spawned item base
## node rather than ItemData from item_removed.
extends Storage

signal item_dropped(item: ItemBase)

var selectedIndex : int = 0:
	set(val):
		# Clamp selectedIndex between 0 and max_capacity
		selectedIndex = clampi(val, 0, max_capacity-1)
		storage_updated.emit()


func _ready() -> void:
	set_capacity(2)
	contents.fill(null)


func get_item() -> ItemData:
	return contents[selectedIndex]


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory_up"):
		scroll_inventory(-1)
		return
	if event.is_action_pressed("inventory_down"):
		scroll_inventory(1)
		return
	if event.is_action_pressed("inventory_1"):
		selectedIndex = 0
		return
	if event.is_action_pressed("inventory_2"):
		selectedIndex = 1
		return
	if event.is_action_pressed("drop"):
		drop_item()
		return


func scroll_inventory(val: int) -> void:
	if (val == -1) and (selectedIndex <= 0):
		selectedIndex = max_capacity-1
	elif (val == 1) and (selectedIndex >= max_capacity-1):
		selectedIndex = 0
	else:
		selectedIndex += val


func drop_item() -> bool:
	return drop_item_at(InteractionManager.player.global_position)


func drop_item_at(coordinate: Vector2):
	if contents[selectedIndex] == null:
		return false
	var item = ItemSpawner.spawn_with_data(contents[selectedIndex])
	item_dropped.emit(item)
	item.global_position = coordinate
	var game := get_tree().get_first_node_in_group("game")
	game.add_child(item)
	remove_at(selectedIndex)
	return true


# OVERRIDE
## Add an item to the inventory
func add(content : ItemData) -> bool:
	for i in max_capacity:
		if contents[i] == null:
			contents[i] = content
			current_capacity += 1
			content_added.emit(content)
			storage_updated.emit()
			return true
	return false


## Remove an item from the inventory at given index
func remove_at(index : int) -> bool:
	if index >= max_capacity or index < 0:
		return false
	if contents[index] != null:
		current_capacity -= 1
	var content = contents[index]
	contents[index] = null
	content_removed.emit(content)
	storage_updated.emit()
	return true

func reset():
	contents.fill(null)
