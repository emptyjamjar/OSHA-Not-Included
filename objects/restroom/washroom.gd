## Washroom - Interactive bathroom facility
##
## Node2D that represents a washroom in the game world.
## Players can interact to reduce their bladder level.
##
## Usage:
## - Attach to a Node2D in your scene
## - Assign an InteractionArea child node for player interaction detection
## - Player must be in "player" group
## - Player must have a bladder property
##
## Behavior:
## - 1 second wait time when used
## - Reduces player bladder by 40 (minimum 0)
##
## Dependencies:
## - Requires InteractionArea component
## - Requires player node with bladder property in "player" group

extends Node2D

@export var interaction_area: InteractionArea


func _ready():
	interaction_area.action_name = "Use Washroom"
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():	
	print("Washroom interact triggered")
	
	# Simulate waiting time in washroom
	await get_tree().create_timer(1.0).timeout
	print("TIMER STOPPED")
	
	# apply effect
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.bladder = max(player.bladder - 40,0)
		print("bladder reduced to: ", player.bladder)
	
	
