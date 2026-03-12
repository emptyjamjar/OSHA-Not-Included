extends Node
class_name EnergyComponent

## Energy Component can be placed on player and should
## degrade over time (as the level progresses). Consuming
## items should increase energy briefly, having an affect
## on player speed.

@export var MAX_ENERGY := 50.0 
var energy : float 



@export var regen_rate: float = 5.0  #energy per second
@export var drain_rate: float = 0.5 #base drain per second
var draining := false 
signal energy_change()

var hold_time: float = 0.0	# how long the player has been doing the work

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	energy = MAX_ENERGY

# function to help the player regain his/her energy
func regain_energy(delta: float) -> void: 
	energy= clamp(energy + regen_rate * delta, 0.0, MAX_ENERGY)
 
# deduct player's energy based on tasks/enemies/debuffs
func energy_deduction(delta:float) -> void: 
	# drains increases the longer the player holds the box 
	var multiplier := 1.0 + hold_time 
	var amount := drain_rate * multiplier * delta
	
	energy = clamp(energy - amount, 0.0, MAX_ENERGY)
	
func get_max_energy():
	return MAX_ENERGY

func get_energy():
	return energy

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if draining: 
		hold_time += delta
		energy_deduction(delta)
		energy_change.emit()
	else: 
		hold_time = 0.0
		regain_energy(delta)
		energy_change.emit()
