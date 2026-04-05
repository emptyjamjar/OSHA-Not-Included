extends Sprite2D
class_name SanityEyeball

@export var irisSprite : Sprite2D
@export var iris : CharacterBody2D
@export var hitbox : CollisionPolygon2D

var enabled : bool = false
var player : Player
var speed : int = 25

func _process(_delta: float) -> void:
	if player and enabled:
		iris.velocity = iris.global_position.direction_to(player.global_position)
		iris.velocity *= speed
		iris.move_and_slide()
