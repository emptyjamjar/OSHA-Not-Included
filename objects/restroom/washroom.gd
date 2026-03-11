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

signal washroom_used

func _ready():
	interaction_area.action_name = "Use Washroom"
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():	
	print("Washroom interact triggered")
	var player := get_tree().get_first_node_in_group("player")
	player.process_mode = Node.PROCESS_MODE_DISABLED
	player.visible = false
	Audio.play_toilet()
	
	# Simulate waiting time in washroom
	await get_tree().create_timer(3.0).timeout
	player.process_mode = Node.PROCESS_MODE_INHERIT
	player.visible = true
	player.last_direction.x = -1
	
	# apply effect
	if player:
		player.player_needs = false
		await get_tree().create_timer(1).timeout
		player.player_needs = true
	
	washroom_used.emit()
	
	
