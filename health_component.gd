extends Node2D

@export var MAX_HEALTH := 100
var health : int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = MAX_HEALTH

func is_dead() -> bool: 
	return false 

func get_health() -> int: 
	return health

func get_max_health() -> int: 
	return MAX_HEALTH
	
func damage() -> void: 
	pass 

func heal() -> void: 
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
