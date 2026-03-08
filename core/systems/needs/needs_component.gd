extends Node
class_name NeedsComponent

#TODO: further desgin on this feature, did not finalize how this works: 
# Hungers ?
# Thirsts ?
# Washroom rest ? 

#This is essentially a copy of the energy component, just tweaked a little and goes up instead of down.
@export var MAX_NEEDS := 50.0 
var needs : float 



@export var regen_rate: float = 5.0
@export var drain_rate: float = 0.5
var rising := false 

signal needs_change

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	needs = 0

# function to help the player empty his/her needs
func empty_needs(delta: float) -> void: 
	needs = 0
	emit_signal("needs_change")
 
# raise player's needs based over time
func needs_increase(delta:float) -> void: 
	var amount := drain_rate * 1.1 * delta
	needs = needs + amount
	emit_signal("needs_change")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if rising: 
		needs_increase(delta)
	else: 
		empty_needs(delta)
		
func get_needs() -> float:
	return needs
	
func get_max_needs() -> float:
	return MAX_NEEDS
