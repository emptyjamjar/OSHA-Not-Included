extends Node
class_name SanityComponent

## Player's sanity controller. Stores information about
## the current sanity level.

@export var MAX_SANITY := 100.0 
var sanity : float 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sanity = MAX_SANITY

func regain_sanity() -> void: 
	pass 

func sanity_deduct() -> void: 
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
