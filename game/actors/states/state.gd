extends Node
class_name State

signal transitioned # when leaving the state 
var field 

# Think about what to do to this state, setting up variables 
func enter() -> void: 
	pass 
	
# Variable to set when leaving current state 
func exit() -> void: 
	pass 
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame. 
func _update(delta: float) -> void:
	pass
	
# what to do every physic tick while active, tied to the ingame physics 
func _physics_update(delta: float) -> void:
	pass 
