class_name Inventory extends Node

signal held_item_changed(prev: ItemData, new: ItemData)
signal add_held_item_failed

var held_item : ItemData:
	set = add_held_item


func _ready() -> void:
	held_item = null


func has_item() -> bool:
	return held_item != null


func add_held_item(item: ItemData) -> bool:
	if has_item():
		add_held_item_failed.emit()
		return false
	else:
		held_item_changed.emit(held_item, item)
		held_item = item
		return true


func remove_held_item() -> ItemData:
	var item := held_item
	held_item = null
	return item
