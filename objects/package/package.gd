class_name Package extends Sprite2D

signal item_added(item: ItemData)

@export var iArea : InteractionArea

var inventory : Array[ItemData]
var maxCap : int
var curCap : int:
	get = get_cur_cap
# Used to differentiate between modifying contents and holding
var isHoldable : bool


func _ready() -> void:
	iArea.interact = Callable(self, "_on_interact")
	iArea.action_name = "pickup"


func _on_interact():
	# Uncomment code when player inventory is made global
	#PlayerInventory.add_held_item(self)
	pass


func add_item(item : ItemData):
	if (curCap + item.size < maxCap):
		item_added.emit(item)
		inventory.push_front(item)


func get_cur_cap():
	var cap = 0
	for item in inventory:
		cap += item.itemData.size
	return cap
