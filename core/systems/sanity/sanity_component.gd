extends Node
class_name SanityComponent

## Player's sanity controller. Stores information about
## the current sanity level.

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

func decrease(amount: int) -> void: 
	value -= amount

# Add milestone to the story dictionary.
func set_milestone(threshold: int, effect_name: String) -> void:
	milestones[threshold] = effect_name

# Remove a milestone from the story dictionary.
# Returns whether or not it succeeded.
func remove_milestone(threshold: int) -> bool:
	var success : bool = milestones.erase(threshold)
	return success
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
