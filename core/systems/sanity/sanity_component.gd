extends Node
class_name SanityComponent

## Player's sanity controller. Stores information about
## the current sanity level.

signal sanity_changed(new_value : int)
signal milestone_reached(threshold : int)

@export var sanity_cap := 100.0 
@export var value : int

# list of ongoing changes to sanity
@export var effects := []
# story checks
@export var milestones := {}
 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value = sanity_cap

func increase(amount: int) -> void: 
	value += amount
	sanity_changed.emit(value)

func decrease(amount: int) -> void: 
	value -= amount
	sanity_changed.emit(value)

# Add milestone to the story dictionary.
func set_milestone(threshold: int, effect_name: SanityChecker.Effects) -> void:
	milestones[threshold] = effect_name

# Remove a milestone from the story dictionary.
# Returns whether or not it succeeded.
func remove_milestone(threshold: int) -> bool:
	var success : bool = milestones.erase(threshold)
	return success

# Stub effect. Return the milestone dictionary for now.
func check_milestones() -> Dictionary:
	return milestones

# Stub effect. Intended to cause an effect to sanity.
func trigger_effect(node : Node) -> bool:
	return true

func get_max_sanity():
	return sanity_cap
	
func get_sanity():
	return value
