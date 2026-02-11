extends Node
## The conveyor belt outputs items

## Affects how quickly items are moved/Animation speed
## (Default: 5)
@export var conveyor_speed:int = 5

## Affects how quickly items are output onto the conveyor belt
## (Default: 1)
@export var output_speed:int = 1

## Storage for the items yet to be put onto the conveyor belt
@onready var _queue:Array[Item]

@onready var animated_belt_h_01 := $StaticBody2D/Belt_Horizontal_01
@onready var animated_belt_h_02 := $StaticBody2D/Belt_Horizontal_02
@onready var animated_belt_h_03 := $StaticBody2D/Belt_Horizontal_03
@onready var animated_corner_01 := $StaticBody2D/Belt_Corner_01
@onready var animated_belt_v_01 := $StaticBody2D/Belt_Vertical_01

func _process(delta: float) -> void:
	animated_belt_h_01.play("Move_Right")
	animated_belt_h_02.play("Move_Right")
	animated_belt_h_03.play("Move_Right")
	animated_corner_01.play("Move_Right_to_Down")
	animated_belt_v_01.play("Move_Down")

## Adds an item to the conveyor
## @param item: item to be added
func input(item:Item)->void:
	self._queue.push_back(item)

## Returns the front-most item in the conveyor
func output()->Item:
	return self._queue.pop_front()
