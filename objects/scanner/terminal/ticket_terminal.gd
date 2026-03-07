extends Area2D
class_name TicketTerminal 

@export var ticket: Ticket

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var player_collision = $StaticBody2D/PlayerCollision
@onready var ticket_queue_ui: CanvasLayer = $TicketQueueUI
@onready var player = get_tree().get_first_node_in_group("player")

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
		active = true
		print("Terminal activated")
		Ticket_Manager.generate_level_ticket(12)
		ticket_queue_ui.visible = true 
		Ticket_Manager.update_queue_ui()
		
	else: 
		active = false 
		#ticket_queue_ui.visible = false 
		print("Terminal closed")
		

	
