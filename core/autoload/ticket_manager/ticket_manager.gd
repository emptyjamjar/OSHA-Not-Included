extends Node
class_name TicketManager

signal ticket_empty
signal tickets_done
signal ticket_timed_out
signal ticket_submitted
signal tickets_generated ##Used by components that care about the tickets being made.

@export_category("Setup")
@export var level: int = 1

var all_tickets: Array[Ticket] = [] ## All tickets for the level.
var visible_queue: Array[Ticket] = [] ## Tickets shown in the HUD.
var timers: Dictionary = {} # ticket --> Timer 
var max_visible: int = 4
var ticket_templates : Array = [] ##Ticket time, ticket title, description, etc.

#The icon and the lable indicating what items are needed for the ticket.
var item_ticket_display = preload("res://objects/scanner/terminal/item_ticket_display.tscn")

# each ticket will have different status
# available - ticket is ready to deploy through ticket_terminal 
# started - player pressed E to interact with the terminal and now starts a ticket 
# reached_goal - player satisfied the ticket requests
# finished - this ticket is done, do not come back to it when you press E through
# the terminal the next time
var active_ticket: Ticket = null
var active_ticket_index: int = 0

var queue_UI: CanvasLayer 




# when game scene is played, add this class to the group 
# this ensure that object is created at run time and not returning null 
func _ready():
	autoload_check()
	add_to_group("ticket_manager")


##Just in case you still have TicketManager as an autoload. Git forgets that it's supposed to be deleted now so yeah...
func autoload_check():
	for autoload in get_tree().root.get_children():
		if autoload.name == "TicketManager":
			assert(false, "Go to project settings -> Globals and delete TicketManager autoload (not just disabling it, deleting it from that menu too)")


## This is for changing which ticket is highlighted.
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		
		if event.keycode == KEY_RIGHT:
			active_ticket_index = min(active_ticket_index + 1, visible_queue.size() - 1)
		elif event.keycode == KEY_LEFT:
			active_ticket_index = max(active_ticket_index - 1, 0)
		else:
			return
		
		if visible_queue.size() > 0:
			active_ticket = visible_queue[active_ticket_index]
			update_queue_ui()


##This gets the ticket_template for this level.
func load_templates_for_level(_level: int):
	var path := "res://objects/scanner/terminal/level%d_tickets.gd" % _level
	var script = load(path)
	
	if script == null: 
		print("Cannot find path to the ticket files")
		return 
	
	var instance = script.new()
	
	ticket_templates = instance.get_templates()


##This only checks if there is a conveyor in the tree. MIGHT HAVE TO DELETE
##TODO: Delete
func on_game_start():
	var item_db = get_tree().get_first_node_in_group("conveyor")
	if item_db == null:
		push_error("Conveyor STILL not found. Check group assignment.")
		return


##Generates x amount of tickets where is count.
func generate_level_ticket(count: int): 
	#Get the conveyor and get the dictionary of all story items and where they're supposed to spawn in the queue.
	var item_db = get_tree().get_first_node_in_group("conveyor")
	var story_dict: Dictionary[int, ItemData] = item_db.get_all_story_items()
	
	#Generate count amount of tickets.
	for numb in range(count): 
		var ticket: Ticket
		
		#Get teh story item at the current numb.
		var story_item: ItemData = story_dict.get(numb)
		
		#Generate normal ticket.
		if story_item == null:
			ticket = generate_random_ticket()
		#Generate story ticket. If there is a story item at current numb.
		else:
			ticket = generate_story_ticket(story_item)
		
		if ticket != null: 
			all_tickets.append(ticket)
		else: 
			print("No more available!")
	
	fill_visible_queue()
	start_timers_for_visible_queue()
	update_queue_ui() 
	
	tickets_generated.emit() #Tell everything that cares that tickets have been made.


##Pops the all_tickets and puts them into visible_queue until visible_queue is full.
func fill_visible_queue(): 
	print("Fill tickets into visible queue")
	while visible_queue.size() < max_visible and all_tickets.size() > 0: 
		var next_ticket = all_tickets.pop_front()
		visible_queue.append(next_ticket)
	
	#Just sets the active ticket to the first in the queue.
	if !visible_queue.is_empty():
		active_ticket = visible_queue[0]
		active_ticket_index = 0
	#Signal emitted when there are no tickets left.
	else:
		tickets_done.emit()


##Start timers for all tickets in the visible queue.
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
	
	ticket_timed_out.emit() #mostly for UI animations.
	
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
		var highlight = slot.get_node("Highlight")
		# only update the slot's ticket if it changed
		if slot.ticket != t:
		# fix for the UI press to update the active ticket: 
			slot.set_ticket(t) # runs every time the UI updates, every timer tick, seconds

		slot.set_active(t == active_ticket)
		
		# Highlight active ticket
		if t == active_ticket:
			highlight.visible = true 
			slot.modulate = Color(1, 1, 1, 1) #bright
		else: 
			highlight.visible = false
			slot.modulate = Color(0.7, 0.7, 0.7, 1) #dim

		var bar = slot.get_node("AnimatedSprite2D/TimeCountDownBar")
		#slot.get_node("AnimatedSprite2D/TicketTitle").text = t.ticket_name
		#slot.get_node("AnimatedSprite2D/TicketDescription").text = t.ticket_description
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
		var story_ticket_sprite: Node2D = slot.get_node("AnimatedSprite2D/StoryTicket")
		
		for icon in req_container.get_children(): 
			icon.queue_free()
		var item_db = get_tree().get_first_node_in_group("conveyor")
		
		for id in t.required_items.keys(): 
			var needed = t.required_items[id]
			var delivered = t.delivered_items.get(id, 0)
			var item_data = item_db.get_item_by_id(id)
			
			#If it's a story item then set up the specific sprite for that.
			if item_data is ItemData:
				if item_data.type == ItemData.Type.ANOMALOUS:
					story_ticket_sprite.visible = true
				else:
					story_ticket_sprite.visible = false
			
			#This is the actual icon on the ticket. It has the sprite and a label.
			var ticket_icon = item_ticket_display.instantiate()
			
			ticket_icon.item_label.text = "%d/%d" % [delivered, needed]
			ticket_icon.item_icon.texture = item_data.uiTexture
			
			req_container.add_child(ticket_icon)


func _on_ticket_selected(ticket: Ticket):
	active_ticket = ticket
	active_ticket_index = visible_queue.find(ticket)
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
		
	# This created error during gameplay, if tickets are not spawned and you click main menu --> instance null
	#if item_db.get_all_items() == null: 
		#return 
		
	var all_items = item_db.get_all_items() # conveyor.gd to return the array
	
	# random number of the items required to complete the ticket
	var count = randi_range(data.min_items, data.max_items)
	
	# choose random items based on their unique id
	for i in count: 
		var item: ItemData = all_items.pick_random()
		var id = item.id
		t.required_items[id] = t.required_items.get(id, 0) + 1
		
	return t


func generate_story_ticket(ticket_data: ItemData) -> Ticket:
	var ticket: Ticket = Ticket.new()
	
	# assign ticket ui with the given title, description, request, time, etc.
	ticket.reward_money_amount = 30
	ticket.performance_increase = 1
	
	# Random time for each ticket 
	ticket.max_time = 600
	ticket.remaining_time = ticket.max_time
	
	var id = ticket_data.id
	ticket.required_items[id] = 1
	
	return ticket


# function to track the delivered items 
# this will check if the required items are shipped or not, does it match 
# check shipper.gd --> on_interact() 
func register_delivery(ticket_id: int) -> bool:
	print("Current ticket: ", active_ticket);
	if not active_ticket:
		return false
	if active_ticket.status == Ticket.TicketStatus.REACHED_GOAL:
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
		var ticket_to_finish = active_ticket
		ticket_to_finish.reach_goal()
		print("CHECKING 123")
		#title_label.text = "COMPLETE!"
		#desc_label.text = active_ticket.reached_goal_text
		print(timers)
		# Stop the timer for this ticket
		if timers.has(ticket_to_finish):
			timers[ticket_to_finish].stop()
		
		# this add extra time for the player to acknowledge that they have completed 
		# the ticket 
		var finish_timer := Timer.new()
		finish_timer.wait_time = 1
		finish_timer.one_shot = true
		finish_timer.timeout.connect(func(): finish_ticket(ticket_to_finish))
		add_child(finish_timer)
		finish_timer.start()
	else: 
		print("reach_goal() -- error happened here!")


# make sure the ticket is finished, ticket box will disappear 
# will work on this further 
func finish_ticket(ticket: Ticket = active_ticket):
	if ticket and ticket.status == Ticket.TicketStatus.REACHED_GOAL:
		
		ticket_submitted.emit() #This is for UI animations.
		ticket.finish()
		# Remove timer for this ticket
		if timers.has(ticket):
			timers[ticket].stop()
			timers.erase(ticket)

		# Remove from visible queue
		visible_queue.erase(ticket)

		# Refill queue with next ticket(s)
		fill_visible_queue()
		start_timers_for_visible_queue()

		# Update UI to reflect new queue
		update_queue_ui()

		# Set NEXT ticket as active
		if visible_queue.size() > 0:
			active_ticket = visible_queue[0]
			active_ticket_index = 0
		else:
			active_ticket = null
			print("All tickets completed!")
			# fallback option in case the fill visible queue
			# signaller fails
			tickets_done.emit()


##Resets all necessary parts and prepares for the next level. Is called by ticket_terminal.
func reset() -> void:
	all_tickets.clear()
	visible_queue.clear()
	active_ticket = null
	
	#Sets ticket_templates
	load_templates_for_level(level)
	
	# Regenerate
	generate_level_ticket(ticket_templates.size())


##Ticks up the level counter.
func tick_up_level():
	pass
	#if level < 5: 
		#level = Level_Manager.level + 1
	#else: 
		#level = 1 # RESET point (infinite levels)

func replay() -> void:
	all_tickets.clear()
	visible_queue.clear()
	timers.clear()
	active_ticket = null
	level = Level_Manager.level + 1
	load_templates_for_level(level)
	#ticket_available = ticket_templates.size()
