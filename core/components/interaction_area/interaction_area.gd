class_name InteractionArea extends Area2D


@export var action_name: String = "interact"
@export var ticket: Ticket

# Will be overriden by scenes that instantiate InteractionArea
var interact: Callable = func():
	pass


func _on_body_entered(body: Node2D) -> void:
	InteractionManager.register_area(self)
	#if ticket.ticket_status == ticket.TicketStatus.available:
		#ticket.start_ticket()
	#if ticket.ticket_status == ticket.TicketStatus.reached_goal:
		#ticket.finish_ticket()


func _on_body_exited(body: Node2D) -> void:
	InteractionManager.unregister_area(self)
