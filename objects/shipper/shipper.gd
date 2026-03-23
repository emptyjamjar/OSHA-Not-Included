extends Area2D

signal get_money
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
		invalid_interaction()
		print("No ticket yet!")
		return 
	
	var item = PlayerInventory.get_item()
	var item_index = PlayerInventory.selectedIndex
	if item:
		if item.type == ItemData.Type.PACKAGE:
			if ticket_manager.active_ticket.required_items.has(item.id):
				ticket_manager.register_delivery(item.id)
				PlayerInventory.remove_at(item_index)
				get_money.emit()
				animated_sprite.play("close")
				shipped = true
				player_collision.disabled = true
			else:
				# Wrong item shipped — ignore for now
				# TODO: Add penalty or feedback later
				pass
	else:
		invalid_interaction()
		printerr("No item currently available")


##What happens when an invalid (no ticket/ no package in hand) interaction happens.
func invalid_interaction():
	#Interaction manager calls the HUD to shake.
	InteractionManager.invalid_interaction()
	#Play a sound to indicate the interaction can't be done.
	Audio.play_invalid_interaction()


func _on_arrive_timer_timeout() -> void:
	animated_sprite.play("drive_up")
	player_collision.disabled = false
