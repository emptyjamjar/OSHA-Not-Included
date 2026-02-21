extends Node
class_name TicketManager

var active_ticket: Ticket = null
var ticket_timer: Timer

# Reference to UI (assigned at runtime)
var ticket_ui: CanvasLayer
var title_label: RichTextLabel
var desc_label: RichTextLabel
var timer_label: RichTextLabel

func _ready():
	ticket_timer = Timer.new()
	ticket_timer.wait_time = 1.0
	ticket_timer.one_shot = false
	ticket_timer.timeout.connect(_on_ticket_tick)
	add_child(ticket_timer)

func _on_ticket_tick():
	if not active_ticket:
		return

	active_ticket.remaining_time -= 1

	if active_ticket.remaining_time <= 0:
		_on_ticket_time_expired()
	else:
		_on_ticket_time_updated(active_ticket.remaining_time)
		

		
#calling the user interface of the ticket box -- TicketUI in the Ticket Terminal.tscn
func register_ui(ui: CanvasLayer):
	ticket_ui = ui
	title_label = ui.get_node("TicketTile")
	desc_label = ui.get_node("TicketDescription")
	timer_label = ui.get_node("TimeCountdown")

func request_ticket() -> Ticket:
	if active_ticket and active_ticket.status != Ticket.TicketStatus.FINISHED:
		return active_ticket

	active_ticket = generate_random_ticket()
	# Connect timer signal
	active_ticket.time_updated.connect(_on_ticket_time_updated)
	active_ticket.time_expired.connect(_on_ticket_time_expired)

	active_ticket.start()
	ticket_timer.start()
	update_ui()
	return active_ticket
	
func _on_ticket_time_updated(time_left: float):
	# Update UI countdown (added a label)
	timer_label.text = str(time_left)


func _on_ticket_time_expired():
	print("Ticket expired!")
	active_ticket.status = Ticket.TicketStatus.FINISHED
	desc_label.text = "Ticket expired!"
	ticket_ui.visible = false
	ticket_timer.stop()

#create ticket function
func generate_random_ticket() -> Ticket:
	var t := Ticket.new()
	var templates = [
		{
			"name": "Lost Package",
			"desc": "Find the missing package in the warehouse.",
			"goal": "Package found!",
			"reward": 50,
			"perf": 1, 
			"time_min": 20, 
			"time_max": 60
		},
		{
			"name": "Scanner Malfunction",
			"desc": "Diagnose the broken scanner.",
			"goal": "Scanner fixed!",
			"reward": 30,
			"perf": 1, 
			"time_min": 15, 
			"time_max": 40
		}
	]

	var data = templates.pick_random()
	t.ticket_name = data.name
	t.ticket_description = data.desc
	t.reached_goal_text = data.goal
	t.reward_money_amount = data.reward
	t.performance_increase = data.perf
	
	# Random time for each ticket 
	t.max_time= randi_range(data.time_min, data.time_max)
	

	return t

# replace the standard text with ticket name and ticket description
func update_ui():
	if not active_ticket:
		return

	ticket_ui.visible = true
	title_label.text = active_ticket.ticket_name
	desc_label.text = active_ticket.ticket_description
	
	#var container = ticket_ui.get_node("RequiredItemsContainer")
	#container.queue_free_children()

	
	# Optional: show progress
	var progress := ""
	for id in active_ticket.required_items.keys():
		var req = active_ticket.required_items[id]
		var got = active_ticket.delivered_items.get(id, 0)
		progress += "Item %s: %d / %d\n" % [str(id), got, req]

	desc_label.text += "\n\n" + progress

	
# function to track the delivered items
func register_delivery(ticket_id: int):
	if not active_ticket:
		return

	var delivered := active_ticket.delivered_items
	delivered[ticket_id] = delivered.get(ticket_id, 0) + 1

	if _is_ticket_complete():
		reach_goal()
		

func _is_ticket_complete() -> bool:
	for req_id in active_ticket.required_items.keys():
		if active_ticket.delivered_items.get(req_id, 0) < active_ticket.required_items[req_id]:
			return false
	return true


# when ticket is satisfied, change the text to complete text and 
# guide to the next step
func reach_goal():
	if active_ticket and active_ticket.status == Ticket.TicketStatus.STARTED:
		active_ticket.reach_goal()
		desc_label.text = active_ticket.reached_goal_text
		
# make sure the ticket is finished, ticket box will disappear 
# will work on this further 
func finish_ticket():
	if active_ticket and active_ticket.status == Ticket.TicketStatus.REACHED_GOAL:
		active_ticket.finish()
		ticket_ui.visible = false
		
