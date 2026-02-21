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
	add_to_group("ticket_manager")
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
			"time_min": 40, 
			"time_max": 60, 
			"min_items": 1, 
			"max_items": 1
		},
		{
			"name": "Scanner Malfunction",
			"desc": "Diagnose the broken scanner.\nShip the replacement parts!",
			"goal": "Parts fixed!",
			"reward": 30,
			"perf": 1, 
			"time_min": 30, 
			"time_max": 40, 
			"min_items": 1,
			"max_items": 1
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
	
	# Random required items 
	var item_db = get_tree().get_first_node_in_group("conveyor")
	var all_items = item_db.get_all_items()
	
	var count = randi_range(data.min_items, data.max_items)
	for i in count: 
		var item: ItemData = all_items.pick_random()
		var id = item.id
		t.required_items[id] = t.required_items.get(id, 0) + 1
	return t

# replace the standard text with ticket name and ticket description
func update_ui():
	if not active_ticket:
		return

	ticket_ui.visible = true
	title_label.text = active_ticket.ticket_name
	desc_label.text = active_ticket.ticket_description
	
	var container = ticket_ui.get_node("RequiredItemsContainer")
	# Clear old UI entries
	for child in container.get_children():
		child.queue_free()

	
	var item_db = get_tree().get_first_node_in_group("conveyor")
	
	for id in active_ticket.required_items.keys():
		var needed = active_ticket.required_items[id]
		var delivered = active_ticket.delivered_items.get(id, 0)

		var item_data: ItemData = item_db.get_item_by_id(id)

		var hbox = HBoxContainer.new()

		var icon = TextureRect.new()
		icon.texture = item_data.texture
		icon.custom_minimum_size = Vector2(32, 32)

		var label = Label.new()
		label.text = "%s: %d / %d" % [item_data.name, delivered, needed]

		hbox.add_child(icon)
		hbox.add_child(label)
		container.add_child(hbox)

	
# function to track the delivered items
func register_delivery(ticket_id: int):
	if not active_ticket:
		return

	var delivered := active_ticket.delivered_items
	delivered[ticket_id] = delivered.get(ticket_id, 0) + 1
	
	# Refresh UI so the player sees the updated counts
	update_ui()
	
	if _is_ticket_complete():
		reach_goal()
		print("Completed:")
		print(ticket_id)
		

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
		title_label.text = "COMPLETE!"
		desc_label.text = active_ticket.reached_goal_text
		
		ticket_timer.stop()
		var finish_timer := Timer.new()
		finish_timer.wait_time = 1.5
		finish_timer.one_shot = true
		finish_timer.timeout.connect(finish_ticket)
		add_child(finish_timer)
		finish_timer.start()

		
# make sure the ticket is finished, ticket box will disappear 
# will work on this further 
func finish_ticket():
	if active_ticket and active_ticket.status == Ticket.TicketStatus.REACHED_GOAL:
		active_ticket.finish()
		ticket_ui.visible = false
		# Clear active ticket so terminal can request a new one
		active_ticket = null
