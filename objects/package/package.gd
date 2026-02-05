class_name Package extends Node2D

var inventory : Array[Item]
var capacity : int
var curCapacity : int :
	get:
		var cap
		for item in inventory:
			cap += item.size
		return cap

# Used to differentiate between modifying contents and holding
var isHoldable : bool

@onready var iArea := $InteractionArea
@onready var hitboxShape := $Hitbox/CollisionShape2D

func _ready() -> void:
	iArea.interact = Callable(self, "_on_interact")
	isHoldable = true

func disable():
	# Disable Collision
	hitboxShape.disabled = not hitboxShape.disabled
	# Disable Interaction
	iArea.monitoring = not iArea.monitoring
	iArea.monitorable = not iArea.monitoring

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
	if (curCapacity + item.size > capacity):
		inventory.append(item)
