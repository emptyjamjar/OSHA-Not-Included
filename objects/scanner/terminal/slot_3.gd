extends Control
signal ticket_selected(ticket)

var ticket: Ticket

func set_ticket(t: Ticket): 
	ticket = t 
	
func _gui_input(event): 
	if event is InputEventMouseButton and event.pressed: 
		if event.button_index == MOUSE_BUTTON_LEFT: 
			ticket_selected.emit(ticket)
