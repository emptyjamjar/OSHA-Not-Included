extends Node
## The conveyor belt outputs items

## Affects how quickly items are moved/Animation speed
## (Default: 5)
@export var conveyor_speed:int = 5

## Affects how quickly items are output onto the conveyor belt
## (Default: 1)
@export var output_speed:int = 1

## Storage for the items yet to be put onto the conveyor belt
var _queue:Array[Item] = []

## Belt slots, each slot can hold at most one item
var _belt_capacity:int = 5

## Belt slot positions
var _slot_positions: Array[int]

# PLACEHOLDER: slot markers and slots
var _slot_markers: Array[Marker2D] = []
# PLACEHOLDER: holds spawned item nodes
var _slots: Array[Node2D] = []

# PLACEHOLDER: item component scene
@export var item_scene:PackedScene

## Timer for output speed control
var _output_timer: float = 0.0

## Animation nodes for conveyor belt
@onready var animated_belt_h_01 := $StaticBody2D/Belt_Horizontal_01
@onready var animated_belt_h_02 := $StaticBody2D/Belt_Horizontal_02
@onready var animated_belt_h_03 := $StaticBody2D/Belt_Horizontal_03
@onready var animated_corner_01 := $StaticBody2D/Belt_Corner_01
@onready var animated_belt_v_01 := $StaticBody2D/Belt_Vertical_01

func _ready() -> void:
	
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
	
	# Test
	var tp = preload("res://objects/items/toilet_paper/toilet_paper.tscn").instantiate() as ToiletPaper
	input(tp)
	
func _process(delta: float) -> void:
	# Process queue and spawn items onto belt at output_speed rate
	_output_timer += delta
	var output_interval = 1.0 / output_speed
	
	while _output_timer >= output_interval and _queue.size() > 0:
		_output_timer -= output_interval
		var item = _queue.pop_front()
		_spawn_into_first_slot(item)

## Adds an item to the conveyor
## @param item: item to be added
func input(item:Item)->void:
	_queue.push_back(item)

## Returns the front-most item in the conveyor
func output()->Item:
	return self._queue.pop_front()

func _spawn_into_first_slot(item: Item) -> void:
	for i in _slots.size():
		if _slots[i] == null:
			var ent := item_scene.instantiate() as Node2D
			add_child(ent)
			ent.global_position = _slot_markers[i].global_position
			_slots[i] = ent
			# Pass the item data to the visual node if it has a set_item method
			if ent.has_method("set_item"):
				ent.set_item(item)
			print("Spawned item in slot ", i)
			return
	print("No free slot on belt")
