extends Node
class_name TicketManager

signal ticket_empty
signal tickets_done
var all_tickets: Array[Ticket] = [] # 12 tickets for the level - can update it later
var visible_queue: Array[Ticket] = [] # max 4 tickets 
var timers: Dictionary = {} # ticket --> Timer 
var max_visible: int = 4
var level: int = 1
var ticket_templates : Array = []
var ticket_available: int 

# each ticket will have different status
# available - ticket is ready to deploy through ticket_terminal 
# started - player pressed E to interact with the terminal and now starts a ticket 
# reached_goal - player satisfied the ticket requests
# finished - this ticket is done, do not come back to it when you press E through
# the terminal the next time
var active_ticket: Ticket = null

var queue_UI: CanvasLayer 

func _init() -> void:
	load_templates_for_level(level)
	print("TicketManager READY, templates loaded:", ticket_templates.size())
	ticket_available = ticket_templates.size()

# when game scene is played, add this class to the group 
# this ensure that object is created at run time and not returning null 
func _ready():
	add_to_group("ticket_manager")
	

func load_templates_for_level(level: int): 
	var path := "res://objects/scanner/terminal/level%d_tickets.gd" % level
	var script = load(path)
	if script == null: 
		print("Cannot find path to the ticket files")
		return 
	var instance = script.new()
	ticket_templates = instance.get_templates()
	ticket_available = ticket_templates.size()
	print("Loaded", ticket_available, "ticket templates for level", level)
	


func on_game_start():
	var item_db = get_tree().get_first_node_in_group("conveyor")
	if item_db == null:
		push_error("Conveyor STILL not found. Check group assignment.")
		return


func generate_level_ticket(count: int): 
	print("Generate Tickets")
	for numb in range(count): 
		var ticket = generate_random_ticket()
		print(ticket)
		if ticket != null: 
			all_tickets.append(ticket)
		else: 
			print("No more available!")
	print(all_tickets)
	fill_visible_queue()
	start_timers_for_visible_queue()
	update_queue_ui() 

func fill_visible_queue(): 
	print("Fill tickets into visible queue")
	while visible_queue.size() < max_visible and all_tickets.size() > 0: 
		var next_ticket = all_tickets.pop_front()
		visible_queue.append(next_ticket)
	if !visible_queue.is_empty():
		active_ticket = visible_queue[0]
	else:
		tickets_done.emit()
	print(visible_queue)
		
func start_timers_for_visible_queue(): 
	for t in visible_queue: 
		if timers.has(t): 
			continue
		var timer := Timer.new()
		timer.wait_time = 1.0
		timer.one_shot = false 
		timer.timeout.connect(func(): _on_ticket_tick(t))
		add_child(timer)
		timers[t] = timer 
		timer.start()
		
# func that keep track of the availability of the ticket 
# when ticket is still available, subtract the remaining time by 1 
# when ticket is expired --> deducts the player's performance (EXPAND FROM THIS LOGIC) 

func _on_ticket_tick(ticket: Ticket):
	ticket.remaining_time -= 1
	update_queue_ui()
	if ticket.remaining_time <= 0:
		_on_ticket_expired(ticket)
		return	

# This is where you expand the logic --> further development 
# PERFORMANCE LOGIC 
# For now, when ticket is expired, the function print to the console output 
# ticket is expired, turn off the ticket box, mark the ticket as FINISHED 
func _on_ticket_expired(ticket: Ticket):
	print("Ticket expired!")
	ticket.status = Ticket.TicketStatus.FINISHED
	#desc_label.text = "Ticket expired!"
	# stops and remove timer
	timers[ticket].stop()
	timers.erase(ticket)
	
	# remove from the queue
	visible_queue.erase(ticket)
	
	# refill queue
	fill_visible_queue()
	start_timers_for_visible_queue()
	update_queue_ui()

func complete_ticket(ticket: Ticket): 
	ticket.status = Ticket.TicketStatus.FINISHED
	timers[ticket].stop()
	timers.erase(ticket)
	visible_queue.erase(ticket)
	fill_visible_queue()
	start_timers_for_visible_queue()
	update_queue_ui()

func update_queue_ui(): 
	#var queue_ui = get_node("TicketQueueUI")
	if queue_UI == null: 
		push_error("Queue UI not registered in update_queue_ui")
		return 
	var hbox_parent = queue_UI.get_node("HBoxContainer")
	for i in range(max_visible):
		var slot = hbox_parent.get_child(i)
		# hide unused slots 
		if i >= visible_queue.size(): 
			slot.visible = false 
			continue
		slot.visible = true 
		var t = visible_queue[i]
		# only update the slot's ticket if it changed
		if slot.ticket != t:
		# fix for the UI press to update the active ticket: 
			slot.set_ticket(t) # runs every time the UI updates, every timer tick, seconds

		# Highlight active ticket
		if t == active_ticket:
			slot.modulate = Color(1, 1, 1, 1) # bright
		else:
			slot.modulate = Color(0.7, 0.7, 0.7, 1) # dim

		var bar = slot.get_node("AnimatedSprite2D/TimeCountDownBar")
		slot.get_node("AnimatedSprite2D/TicketTitle").text = t.ticket_name
		slot.get_node("AnimatedSprite2D/TicketDescription").text = t.ticket_description
		bar.max_value = t.max_time
		bar.value = t.remaining_time
		# color change based on time left
		var ratio = float(t.remaining_time) / float(t.max_time)
		if ratio < 0.25:
			bar.modulate = Color('#ff0044', 0.25) # red
		elif ratio < 0.5:
			bar.modulate = Color('#ffc300', 0.25) # yellow
		else:
			bar.modulate = Color('#00b515', 0.25) # green

	
		# Required items
		var req_container = slot.get_node("AnimatedSprite2D/RequiredItemsContainer")
		
		for icon in req_container.get_children(): 
			icon.queue_free()
		var item_db = get_tree().get_first_node_in_group("conveyor")
		for id in t.required_items.keys(): 
			var needed = t.required_items[id]
			var delivered = t.delivered_items.get(id, 0)
			var item_data = item_db.get_item_by_id(id)
			var hbox = HBoxContainer.new()
			hbox.custom_minimum_size = Vector2(-5, 55)

			var icon = TextureRect.new()
			icon.texture = item_data.texture
			icon.custom_minimum_size = Vector2(16, 16)
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			# Prevent container from overriding size
			icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			
			
			var label = Label.new()
			label.text = "%d / %d" % [delivered, needed]
			label.add_theme_color_override("font_color", Color.DIM_GRAY)
			label.add_theme_font_size_override("font_size", 8)

			hbox.add_child(icon)
			hbox.add_child(label)
			req_container.add_child(hbox)
	

			
		
func _on_ticket_selected(ticket: Ticket):
	active_ticket = ticket
	update_queue_ui()

func register_queue_ui(ui: CanvasLayer): 
	queue_UI = ui 
	# alternative fix with ticket signal connection not being stable 
	var hbox = queue_UI.get_node("HBoxContainer")
	if hbox == null: 
		print("HBOX error in ready() ticket_manager.gd")
	else: 
		for slot in hbox.get_children(): 
			slot.connect("ticket_selected", Callable(self, "_on_ticket_selected"))
		

# player request_ticket() 
#create ticket function
func generate_random_ticket() -> Ticket:
	if ticket_templates.is_empty(): 
		print("No more ticket templates available!")
		ticket_empty.emit()
		return 
	var t := Ticket.new() # set new timer 
	# ticket layout
	
	
	# this will pick random templates, fix this point if you want make the ticket 
	# truly unique 
	var index := randi() % ticket_templates.size()
	var data = ticket_templates[index]
	ticket_templates.remove_at(index)
	ticket_available = ticket_templates.size()
	
	
	# assign ticket ui with the given title, description, request, time, etc.
	t.ticket_name = data.name
	t.ticket_description = data.desc
	t.reached_goal_text = data.goal
	t.reward_money_amount = data.reward
	t.performance_increase = data.perf
	
	# Random time for each ticket 
	t.max_time= randi_range(data.time_min, data.time_max)
	t.remaining_time = t.max_time
	
	# Random required items 
	# call conveyor array --> this hold all the items that it generated
	var item_db = get_tree().get_first_node_in_group("conveyor")
	if item_db == null: 
		print("Return null on item database")
	var all_items = item_db.get_all_items() # conveyor.gd to return the array
	
	# random number of the items required to complete the ticket
	var count = randi_range(data.min_items, data.max_items)
	
	# choose random items based on their unique id
	for i in count: 
		var item: ItemData = all_items.pick_random()
		var id = item.id
		t.required_items[id] = t.required_items.get(id, 0) + 1
		
	return t

	
# function to track the delivered items 
# this will check if the required items are shipped or not, does it match 
# check shipper.gd --> on_interact() 
func register_delivery(ticket_id: int) -> bool:
	print("Current ticket: ", active_ticket);
	if not active_ticket:
		return false
	

	var delivered := active_ticket.delivered_items
	
	delivered[ticket_id] = delivered.get(ticket_id, 0) + 1
	
	# Refresh UI so the player sees the updated counts
	update_queue_ui()
	if _is_ticket_complete():
		reach_goal()
		print("Completed:")
		print(ticket_id)
	return true

# related to register_delivery() 
func _is_ticket_complete() -> bool:
	# check if the id of item shipped match with required number
	for req_id in active_ticket.required_items.keys():
		if active_ticket.delivered_items.get(req_id, 0) < active_ticket.required_items[req_id]:
			return false
		#else: 
			#active_ticket.delivered_items.get(req_id,0) = active.required_items[req_id]
	return true


# when ticket is satisfied, change the text to complete text and 
# guide to the next step
func reach_goal():
	if active_ticket:
		active_ticket.reach_goal()
		print("CHECKING 123")
		#title_label.text = "COMPLETE!"
		#desc_label.text = active_ticket.reached_goal_text
		print(timers)
		# Stop the timer for this ticket
		if timers.has(active_ticket):
			timers[active_ticket].stop()
		
		# this add extra time for the player to acknowledge that they have completed 
		# the ticket 
		var finish_timer := Timer.new()
		finish_timer.wait_time = 1
		finish_timer.one_shot = true
		finish_timer.timeout.connect(finish_ticket)
		add_child(finish_timer)
		finish_timer.start()
	else: 
		print("reach_goal() -- error happened here!")

		
# make sure the ticket is finished, ticket box will disappear 
# will work on this further 
func finish_ticket():
	if active_ticket and active_ticket.status == Ticket.TicketStatus.REACHED_GOAL:
		active_ticket.finish()
		# Remove timer for this ticket
		if timers.has(active_ticket):
			timers[active_ticket].stop()
			timers.erase(active_ticket)

		# Remove from visible queue
		visible_queue.erase(active_ticket)

		# Refill queue with next ticket(s)
		fill_visible_queue()
		start_timers_for_visible_queue()

		# Update UI to reflect new queue
		update_queue_ui()

		# Set NEXT ticket as active
		if visible_queue.size() > 0:
			active_ticket = visible_queue[0]
		else:
			active_ticket = null
			print("All tickets completed!")
			# fallback option in case the fill visible queue
			# signaller fails
			tickets_done.emit()
			
			
func reset() -> void:
	all_tickets.clear()
	visible_queue.clear()
	active_ticket = null
	if level < 5: 
		level += 1
	else: 
		level = 1 # RESET point (infinite levels)
	load_templates_for_level(level)
	ticket_available = ticket_templates.size()

	# Regenerate
	generate_level_ticket(ticket_available)
