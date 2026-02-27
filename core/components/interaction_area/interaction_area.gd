class_name InteractionArea extends Area2D


@export var action_name: String = "interact"


# Will be overriden by scenes that instantiate InteractionArea
var interact: Callable = func():
	pass


func _on_body_entered(_body: Node2D) -> void:
	InteractionManager.register_area(self)


func _on_body_exited(_body: Node2D) -> void:
	InteractionManager.unregister_area(self)
