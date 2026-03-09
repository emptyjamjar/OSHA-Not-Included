extends Node
class_name State
# STATE MANAGER 
# Condition: No Target -- Behaviour: Wander 

# Wander 
# Direction: float, float
# Speed: int 
# Time: float
# _update() will countdown the tiner. When reached zero, randomized these variables again 


signal transitioned # when leaving the state 
var field 

# Think about what to do to this state, setting up variables 
func Enter() -> void: 
	pass 
	
# Variable to set when leaving current state 
func Exit() -> void: 
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame. 
func Update(delta: float) -> void:
	pass
	
# what to do every physic tick while active, tied to the ingame physics 
func Physics_Update(delta: float) -> void:
	pass 
