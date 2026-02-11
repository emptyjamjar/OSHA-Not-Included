extends Area2D

@export var boxes = null
@onready var animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$InteractionArea.interact = Callable(self, "_on_interact")
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
func _on_body_entered(body:Node2D) -> void:
	if (body.is_in_group("player")):
		animated_sprite.play("open")
	
func _on_body_exited(body:Node2D) -> void:
	if (body.is_in_group("player")):
		animated_sprite.play("close")

			
func _on_interact():
	boxes = get_overlapping_bodies()
	for box in boxes:
		if box.is_in_group("Shippable"):
			box.free()
			animated_sprite.play("drive_away")
