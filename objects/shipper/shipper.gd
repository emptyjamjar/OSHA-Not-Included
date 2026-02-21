extends Area2D

signal get_money
@export var boxes = null
@onready var animated_sprite = $AnimatedSprite2D
@onready var timer = $ArriveTimer
@onready var player_collision = $StaticBody2D/PlayerCollision

var shipped:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$InteractionArea.interact = Callable(self, "_on_interact")
	$ArriveTimer.start(5.0)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	player_collision.disabled = true
	
func _on_body_entered(body:Node2D) -> void:
	if (body.is_in_group("player") and timer.is_stopped()):
		animated_sprite.play("open")
		shipped = false
	
func _on_body_exited(body:Node2D) -> void:
	if (body.is_in_group("player") and !shipped and timer.is_stopped()):
		animated_sprite.play("close")

			
func _on_interact():
	boxes = get_overlapping_areas()
	for box in boxes:
		if box.is_in_group("Shippable"):
			box.get_parent().queue_free()
			get_money.emit()
			animated_sprite.play("drive_away")
			shipped = true
			player_collision.disabled = true
			timer.start()
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
