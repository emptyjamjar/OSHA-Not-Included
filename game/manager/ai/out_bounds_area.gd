extends Area2D
# manager.gd will handle the signal when the manager exited the game screen
signal agent_exited(agent) # signal send to manager.gd 
signal agent_entered(agent)

func _on_area_entered(agent):
	print("Entered polygon:", agent)
	if agent.is_in_group("agents"):
		emit_signal("agent_entered", agent)


func _on_area_exited(agent):
	print("Area exited by: ", agent)
	if agent.is_in_group("agents"):
		emit_signal("agent_exited", agent)
