extends Node
class_name HealthComponent

## TODO: decide if we need this component, or if we
## just want to rename.

signal health_change(diff:float)
signal max_health_change(diff:float)


@export var MAX_HEALTH := 100.0 : set = set_max_health, get = get_max_health
var health : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = MAX_HEALTH
	health_change.emit(health)

# check if the player is still alive or not. Return bool value 
func is_dead() -> bool: 
	return health <= 0.0
	
	
# function to manipulate the player's health 	
func set_health(value: float) -> void:
	var old_value = health 
	health = clamp(value, 0.0, MAX_HEALTH)
	
	var diff = health - old_value 
	if diff != 0.0: 
		emit_signal("health_change", diff)
		print(diff)
	
# return the current health 
func get_health() -> float: 
	return health
	
# for later use, if we want to change the value of MAX_HEALTH to a different value
func set_max_health(value: float) -> void: 
	var old_value = MAX_HEALTH
	MAX_HEALTH = max(value, 1.0)
	
	var diff = MAX_HEALTH - old_value 
	if diff != 0.0: 
		emit_signal("max_health_change", diff)

# return the current MAX_HEALTH value 
func get_max_health() -> float: 
	return MAX_HEALTH
	
# health got deducted due to damage from monsters
func damage(amount: float) -> void: 
	if amount <= 0.0: 
		return 
	set_health(health - amount)

# heal the player by an amount that based on special items
func heal(amount: float) -> void: 
	if amount <= 0.0: 
		return 
	elif health + amount >= MAX_HEALTH: 
		set_health(MAX_HEALTH)
	set_health(health + amount)
	
