extends Control
signal ticket_selected(ticket)

var ticket: Ticket
var is_hovered : bool = false 
var is_active : bool = false 

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	if is_active: 
		modulate = Color(1, 1, 1, 1) #slight brighten
	else:
		modulate = Color(0.7, 0.7, 0.7, 1) # normal 
	
func update_hovered_visual() -> void:
	if is_active: 
		modulate = Color(1, 1, 1, 1)
	else: 
		if is_hovered: 
			modulate = Color(1, 1, 1, 1) #slight brighten
		else: 
			modulate = Color(0.7, 0.7, 0.7, 1) # normal
	

func _on_mouse_entered() -> void: 
	is_hovered = true 
	update_hovered_visual() 
	
func _on_mouse_exited() -> void: 
	is_hovered = false 
	update_hovered_visual() 

func set_ticket(t: Ticket): 
	ticket = t 
	
func set_active(state: bool) -> void: 
	is_active = state
	update_hovered_visual()
		
func _gui_input(event): 
	if event is InputEventMouseButton and event.pressed: 
		if event.button_index == MOUSE_BUTTON_LEFT: 
			print("Click-3") 
			ticket_selected.emit(ticket)
