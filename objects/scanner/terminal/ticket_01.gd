class_name Ticket extends TicketManager

func start_ticket() -> void: 
	if ticket_status == TicketStatus.available: 
		ticket_status = TicketStatus.started
		# update ticket to become visible 
		TicketBox.visible = true 
		TicketTitle.text = ticket_name
		TicketDescription.text = ticket_description
		
func reached_goal() -> void: 
	if ticket_status == TicketStatus.started: 
		ticket_status = TicketStatus.reached_goal
		TicketDescription.text = reached_goal_text
		
func finish_ticket() -> void:
	if ticket_status == TicketStatus.reached_goal: 
		ticket_status = TicketStatus.finished
		TicketBox.visible = false 
