extends Node2D
class_name TicketTerminal 

signal ticket_issued(ticket_id: int)

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var ui: CanvasLayer = $TicketUI
@onready var player = get_tree().get_first_node_in_group("player")

var active := false 
var ticket_counter := 0 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	ui.visible = false 
	
func _on_interact(): 
	if not active: 
		active = true
		ui.visible = true 
		print("Terminal activated")
	else: 
		active = false 
		ui.visible = false 
		print("Terminal closed")
		
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	ticket_counter += 1
	print("Ticket issued:", ticket_counter)

	emit_signal("ticket_issued", ticket_counter)


func _on_interaction_area_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_interaction_area_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
