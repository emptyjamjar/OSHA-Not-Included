class_name Package extends Node2D

var inventory : Array[Item]
var maxCap : int
var curCap : int :
	get:
		var cap = 0
		for item in inventory:
			cap += item.size
		return cap

# Used to differentiate between modifying contents and holding
var isHoldable : bool

@onready var iArea := $InteractionArea

func _ready() -> void:
	iArea.interact = Callable(self, "_on_interact")
	isHoldable = false

func disable():
	iArea.monitorable = false
	iArea.monitoring = false

func _on_interact():
	# if the station changes holdable then pick it up
	if isHoldable:
		# temporary code until inventory is set up
		var player = get_tree().get_first_node_in_group("player")
		if player:
			disable()
			global_position = player.global_position
			reparent(player, true)

func add_item(item : Item):
	if (curCap + item.size < maxCap):
		inventory.append(item)
	else:
		isHoldable = true
