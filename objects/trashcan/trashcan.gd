extends Area2D

signal get_money
@onready var animated_sprite = $AnimatedSprite2D
@onready var player_collision = $StaticBody2D/PlayerCollision

var shipped:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$InteractionArea.interact = Callable(self, "_on_interact")
	$InteractionArea.action_name = "trash item"
	player_collision.disabled = false

			
func _on_interact():
	
	var item = PlayerInventory.get_item()
	var item_index = PlayerInventory.selectedIndex
	if item:
		PlayerInventory.remove_at(item_index)
		Audio.play_trash_use()
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
