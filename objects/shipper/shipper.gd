extends Area2D

signal get_money
@export var boxes = null
@onready var animated_sprite = $AnimatedSprite2D
@onready var player_collision = $StaticBody2D/PlayerCollision

var shipped:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$InteractionArea.interact = Callable(self, "_on_interact")
	animated_sprite.set_animation("open")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	player_collision.disabled = true
	
func _on_body_entered(body:Node2D) -> void:
	if (body.is_in_group("player")):
		animated_sprite.play("open")
		shipped = false
	
func _on_body_exited(body:Node2D) -> void:
	if (body.is_in_group("player") and !shipped):
		animated_sprite.play("close")

			
func _on_interact():
	var ticket_manager = get_tree().get_first_node_in_group("ticket_manager")
	if ticket_manager == null: 
		print("WARNING: TicketManager not found yet")
		return
	if ticket_manager.active_ticket == null: 
		print("No ticket yet!")
		return 

	boxes = get_overlapping_areas()
	for box in boxes:
		if box.is_in_group("Shippable"):
			var area = box.get_parent()
			var item_data = area.data #ItemBase.data
			if ticket_manager.active_ticket.required_items.has(item_data.id):
				ticket_manager.register_delivery(item_data.id)
			else:
				# Wrong item shipped — ignore for now
				# TODO: Add penalty or feedback later
				pass

			area.queue_free()

			get_money.emit()
			animated_sprite.play("close")
			shipped = true
			player_collision.disabled = true
			#timer.start()

	# #animate truck only when ticket is complete
	#if ticket_manager.active_ticket.status == Ticket.TicketStatus.REACHED_GOAL:
		#get_money.emit()
		#animated_sprite.play("drive_away")
		#shipped = true
		#player_collision.disabled = true
		#timer.start()


func _on_arrive_timer_timeout() -> void:
	animated_sprite.play("drive_up")
	player_collision.disabled = false
