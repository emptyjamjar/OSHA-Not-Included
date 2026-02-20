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
	
	
