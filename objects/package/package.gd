class_name Package extends Node2D

signal picked_up
signal dropped

@export var iArea : InteractionArea

var inventory : Array[Item]
var maxCap : int
var curCap : int:
	get:
		var cap = 0
		for item in inventory:
			cap += item.size
		return cap

# Used to differentiate between modifying contents and holding
var isHoldable : bool
var isHeld : bool


func _ready() -> void:
	iArea.interact = Callable(self, "_on_interact")
	iArea.action_name = "pickup"


func _on_interact():
	if isHeld:
		drop()
	# Only allow pickup when possible
	elif isHoldable:
		pick_up()


func add_item(item : Item):
	if (curCap + item.size < maxCap):
		inventory.push_front(item)
	else:
		isHoldable = true


# Called when player tries to pick up package
func pick_up():
	isHeld = true
	picked_up.emit()


# Called when player tries to drop package
func drop():
	isHeld = false
	dropped.emit()

func get_cur_cap():
	var cap = 0
	for item in inventory:
		cap += item.size
	return cap
