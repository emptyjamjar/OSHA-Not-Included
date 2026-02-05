class_name InteractionArea extends Area2D

@export var action_name : String = "interact"

# Will be overriden by scenes that instantiate InteractionArea
var interact: Callable = func():
	pass
