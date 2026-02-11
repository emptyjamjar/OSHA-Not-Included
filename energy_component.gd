extends Node

@export var MAX_ENERGY := 50.0 
var energy : float 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	energy = MAX_ENERGY

# function to help the player regain his/her energy
func regain_energy() -> void: 
	pass
 
# deduct player's energy based on tasks/enemies/debuffs
func energy_deduction() -> void: 
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
