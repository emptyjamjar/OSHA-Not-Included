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

var ticket_manager: TicketManager

var active := false 
var ticket_counter := 0 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ticket_manager = get_tree().get_first_node_in_group("Ticket Manager")
	
	interaction_area.interact = Callable(self, "_on_interact")
	ticket_manager.register_queue_ui(ticket_queue_ui)
	# Force TicketManager to refresh the queue UI now that it has the reference
	#Ticket_Manager.update_queue_ui()

	ticket_queue_ui.visible = false 

	
func _on_interact(): 
	if not active:
		if game.is_tut:
			if first_interact == false && game.game_state == 0:
				emit_signal("ticket_dialogue")
				first_interact = true
		active = true
		print("Terminal activated")
		
		print("Templates at interact:", ticket_manager.ticket_templates.size())
		
		#Set up ticket manager for the next level.
		ticket_manager.tick_up_level()
		ticket_manager.reset()
		
		ticket_queue_ui.visible = true 
		ticket_manager.update_queue_ui()
		activated.emit()
		
	elif ticket_manager.visible_queue.is_empty():
			print("Terminal closed")
			active = false 
			ticketsEmpty.emit()
		

	
