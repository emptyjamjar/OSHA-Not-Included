extends Node
class_name Storage

## Generic storage class to use
## for anything with an inventory.


signal storage_full
signal storage_empty
signal content_added(content: Node)
signal content_removed(content: Node)
signal storage_updated

@export var max_capacity : int
@export var current_capacity : int
enum STORED_TYPE {
	NONE,
	ITEM, 
	PACKAGE,
}
@export var stored_type: STORED_TYPE
@export var contents: Array[Node]

# these two are kinda not useful
@export var is_full: bool
@export var is_empty: bool


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Append new item to the end of the contents list.
# Returns whether or not it succeeded.

# This expects the programmer to set capacity,
# not the user.
func set_capacity(capacity: int) -> bool:
	if capacity < current_capacity:
		return false
	max_capacity = capacity
	return true
	
# Add an item into the list of contents.
func add(content: Node) -> bool: 
	if current_capacity < max_capacity:
		contents.insert(-1, content)
		content_added.emit()
		if current_capacity == max_capacity:
			storage_full.emit()
		current_capacity += 1
		return true
		
	storage_full.emit()
	return false

# Remove an item from the list of contents.

func remove(content: Node) -> bool: 
	# UML specs demand finding before erasing();
	# use remove_at instead
	var index = contents.find(content)
	if index == -1:
		return false
	contents.remove_at(index)
	content_removed.emit()
	current_capacity -= 1
	if contents.is_empty():
		storage_empty.emit()
	return true

# Get remaining storage space.
func get_remaining() -> int:
	return max_capacity - current_capacity

# Find an item in the list of contents.
func contains(content: Node) -> bool: 
	# UML specs demand finding before erasing();
	# use remove_at instead
	var index = contents.find(content)
	if index == -1:
		return false
	return true
# Find an item in the list of contents by their string name.
func contains_type(content_type: String) -> bool: 
	for item in contents:
		if item.name == content_type:
			return true
	return false

# Find the number of items in the list of contents by their string name.
func count(content_type: String) -> int: 
	var count = 0
	for item in contents:
		if item.name == content_type:
			count += 1
	return count

# Get everything in the inventory.
func get_all() -> Array[Node]:
	return contents

# Find an item in the list of contents by their string name.
# Then get it.
func get_by_type(content_type: String) -> Array[Node]:
	var items : Array[Node]
	for item in contents:
		if item.name == content_type:
			items.insert(-1, item)
	return items
