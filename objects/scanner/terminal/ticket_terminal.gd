extends Area2D
class_name TicketTerminal 

signal ticketsEmpty
signal activated
signal ticket_dialogue
@export var ticket: Ticket

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var player_collision = $StaticBody2D/PlayerCollision
@onready var ticket_queue_ui: CanvasLayer = $TicketQueueUI
@onready var game = get_tree().get_first_node_in_group("game")
@onready var player = get_tree().get_first_node_in_group("player")
var first_interact := false

var active := false 
var ticket_counter := 0 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	Ticket_Manager.register_queue_ui(ticket_queue_ui)
	# Force TicketManager to refresh the queue UI now that it has the reference
	Ticket_Manager.update_queue_ui()

	ticket_queue_ui.visible = false 

	
func _on_interact(): 
	if not active:
		if first_interact == false && game.game_state == 0:
			emit_signal("ticket_dialogue")
			first_interact = true
		active = true
		print("Terminal activated")
		print("Templates at interact:", Ticket_Manager.ticket_templates.size())
		#Ticket_Manager.generate_level_ticket(Ticket_Manager.ticket_available)
		Ticket_Manager.generate_level_ticket(6)
		# SET THE ACTIVE TICKET
		if !Ticket_Manager.visible_queue.is_empty():
			Ticket_Manager.active_ticket = Ticket_Manager.visible_queue[0]
		else:
			print("Ticket manager's visible queue is empty")
			ticketsEmpty.emit()

		ticket_queue_ui.visible = true 
		Ticket_Manager.update_queue_ui()
		activated.emit()
		
	else: 
		active = false 
		#ticket_queue_ui.visible = false 
		print("Terminal closed")
		

	
