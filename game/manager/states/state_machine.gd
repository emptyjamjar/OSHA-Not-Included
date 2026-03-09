extends Node
# COLLECTION OF STATES
@export var initial_state: State 
var current_state: State 
var states : Dictionary = {} # holds all the State nodes 

# Think about different mode: 
# Idle 
# Attack 
# Chase 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("StateMachine here!")
	for child in get_children(): 
		if child is State: 
			states[child.name.to_lower()] = child 
			child.transitioned.connect(on_child_transition)
	if initial_state:
		print(initial_state)
		initial_state.Enter()
		current_state = initial_state

# Called every frame. 'delta' is the elapsed time since the previous frame.
# check if there is a current state, then call it to update it
func _process(delta: float) -> void:
	if current_state: 
		current_state.Update(delta)
		
func _physics_process(delta: float) -> void:
	if current_state: 
		current_state.Physics_Update(delta)

# func to govern the transition between the old state and new state 
func on_child_transition(state, new_state_name) -> void: 
	if state != current_state: 
		return 
		
	var new_state = states.get(new_state_name.to_lower())
	if !new_state: 
		return
		
	if current_state: 
		current_state.Exit()
		
	new_state.Enter()
	current_state = new_state
