class_name Conveyor extends Node
## The conveyor belt outputs items

## All items that the conveyor can spawn are found here
## Connected to a list of String paths to resources
enum ItemDataList {
	TOILET_PAPER,
	BLACK_WATER_BOTTLE,
	BLUE_WATER_BOTTLE,
	PINK_WATER_BOTTLE,
}

## Preloaded resources of item data
var item_resources : Array[ItemData]

## Affects how quickly items are moved/Animation speed
## (Default: 5)
@export var conveyor_speed:int = 5

## Affects how quickly items are output onto the conveyor belt
## (Default: 1)
@export var output_speed:int = 1

## Storage for the items yet to be put onto the conveyor belt
var _queue:Array[ItemDataList] = []

## Belt slots, each slot can hold at most one item
var _belt_capacity:int = 5

## Belt slot positions
var _slot_positions: Array[int]

# PLACEHOLDER: slot markers and slots
var _slot_markers: Array[Marker2D] = []
# PLACEHOLDER: holds spawned item nodes
var _slots: Array[ItemBase] = []

# Item Base scene
@export var item_scene : PackedScene

## Timer for output speed control
var _output_timer: float = 0.0

## Animation nodes for conveyor belt
@onready var animated_belt_h_01 := $StaticBody2D/Belt_Horizontal_01
@onready var animated_belt_h_02 := $StaticBody2D/Belt_Horizontal_02
@onready var animated_belt_h_03 := $StaticBody2D/Belt_Horizontal_03
@onready var animated_corner_01 := $StaticBody2D/Belt_Corner_01
@onready var animated_belt_v_01 := $StaticBody2D/Belt_Vertical_01

func _ready() -> void:
	# Fill item_resources with needed item data
	# Items should follow the order presented in the enums
	item_resources.append(preload("res://objects/items/toilet_paper/toilet_paper.tres"))
	item_resources.append(preload("res://objects/items/water_bottles/black_water_bottle.tres"))
	item_resources.append(preload("res://objects/items/water_bottles/blue_water_bottle.tres"))
	item_resources.append(preload("res://objects/items/water_bottles/pink_water_bottle.tres"))
	
	# Used to instantiate new children
	item_scene = load("res://objects/items/item_base.tscn")
	
	# PLACEHOLDER: Set animations to run on start
	animated_belt_h_01.play("Move_Right")
	animated_belt_h_02.play("Move_Right")
	animated_belt_h_03.play("Move_Right")
	animated_corner_01.play("Move_Right_to_Down")
	animated_belt_v_01.play("Move_Down")
	
	# PLACEHOLDER: Build slot marker list in order
	_slot_markers = [
		$Marker_Pos_01,
		$Marker_Pos_02,
		$Marker_Pos_03,
		$Marker_Pos_04,
	]
	
	# PLACEHOLDER: belt capacity controls how many are used
	_slot_markers = _slot_markers.slice(0, min(_belt_capacity, _slot_markers.size()))
	
	_slots.resize(_slot_markers.size())
	for i in _slots.size():
		_slots[i] = null
		
	
func _process(delta: float) -> void:
	# Process queue and spawn items onto belt at output_speed rate
	_output_timer += delta
	var output_interval = 1.0 / output_speed
	
	# PLACEHOLDER: Below will move into method later
	# Continue processing while enough time has passed and items are waiting in queue
	while _output_timer >= output_interval and _queue.size() > 0:
		# Subtract the output interval from the timer (allows multiple spawns per frame if needed)
		_output_timer -= output_interval
		# Remove the first item from the queue
		var item = _queue.pop_front()
		# Attempt to spawn the item into the first available slot on the belt
		_spawn_into_first_slot(item)

## Adds an item to the conveyor
## @param item: item to be added
func input(item:ItemDataList)->void:
	_queue.push_back(item)

## Returns the front-most item in the conveyor
func output()->ItemDataList:
	return self._queue.pop_front()

## Spawns an item into the first available slot on the conveyor belt.
## Creates a visual representation of the item at the slot position and stores
## the reference in the slots array. If all slots are occupied, the item is not spawned.
## PLACEHOLDER: contains print statements for debug (remove later)
## @param item: The Item data to spawn onto the conveyor belt
func _spawn_into_first_slot(item: ItemDataList) -> void:
	for i in _slots.size():
		if _slots[i] == null:
			# Create sprite of texture
			var scene := item_scene.instantiate() as ItemBase
			# Connect to function to remove from list on pickup
			scene.picked_up.connect(_on_item_picked_up.bind(i))
			scene.data = item_resources[item].duplicate(true)
			add_child(scene)
			scene.global_position = _slot_markers[i].global_position
			_slots[i] = scene
			
			print("Spawned item in slot ", i)
			return
	print("No free slot on belt")
	# No free slots so add back to queue
	_queue.push_front(item)

## Removes item from conveyor slots using index
## Then disconnects the function from item signal
func _on_item_picked_up(item: ItemBase, index: int):
	_slots[index] = null
	item.picked_up.disconnect(_on_item_picked_up)
