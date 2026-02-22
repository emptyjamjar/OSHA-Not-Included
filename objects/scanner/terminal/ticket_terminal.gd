extends Area2D
class_name TicketTerminal 

@export var ticket: Ticket

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var player_collision = $StaticBody2D/PlayerCollision
@onready var ticket_ui: CanvasLayer = $TicketUI
@onready var player = get_tree().get_first_node_in_group("player")

var active := false 
var ticket_counter := 0 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	Ticket_Manager.register_ui(ticket_ui)
	ticket_ui.visible = false 

	
func _on_interact(): 
	if not active: 
		active = true
		print("Terminal activated")
		Ticket_Manager.request_ticket()
		ticket_ui.visible = true 
		
	else: 
		active = false 
		ticket_ui.visible = false 
		print("Terminal closed")
		

	
