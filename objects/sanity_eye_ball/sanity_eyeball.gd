extends Sprite2D
class_name SanityEyeball

@export var irisSprite : Sprite2D
@export var iris : CharacterBody2D
@export var player : Player

var speed : int = 25

func _process(_delta: float) -> void:
	if player:
		iris.velocity = iris.global_position.direction_to(player.global_position)
		iris.velocity *= speed
		iris.move_and_slide()
