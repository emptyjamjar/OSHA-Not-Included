extends Area2D

@export var boxes = null
@onready var animated_sprite = $AnimatedSprite2D
@onready var timer = $ArriveTimer

var shipped:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$InteractionArea.interact = Callable(self, "_on_interact")
	$ArriveTimer.start(5.0)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
func _on_body_entered(body:Node2D) -> void:
	if (body.is_in_group("player") and timer.is_stopped()):
		animated_sprite.play("open")
		shipped = false
	
func _on_body_exited(body:Node2D) -> void:
	if (body.is_in_group("player") and !shipped and timer.is_stopped()):
		animated_sprite.play("close")

			
func _on_interact():
	boxes = get_overlapping_bodies()
	for box in boxes:
		if box.is_in_group("Shippable"):
			box.free()
			animated_sprite.play("drive_away")
			shipped = true
			timer.start()

func _on_arrive_timer_timeout() -> void:
	animated_sprite.play("drive_up")
