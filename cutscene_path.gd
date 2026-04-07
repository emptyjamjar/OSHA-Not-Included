extends Path2D

@export var speed = 100 # Pixels per second
var state := 0

@export var animated_sprite_2d: AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta):
	if state == 0:
		animated_sprite_2d.play("Idle_down")
		#animated_sprite_2d.show()
	elif $PathFollow2D.progress <= 286 && state == 1:
		#384, 351
		animated_sprite_2d.flip_h = true
		animated_sprite_2d.play("Move_side")
		$PathFollow2D.progress += speed * delta   
	elif $PathFollow2D.progress <= 407 && state == 2:
		#197, 351
		animated_sprite_2d.play("Move_side")
		$PathFollow2D.progress += speed * delta
	elif $PathFollow2D.progress <= 473 && state == 3:
		#197, 285
		animated_sprite_2d.play("Move_up")
		$PathFollow2D.progress += speed * delta
	elif $PathFollow2D.progress <= 897 && state == 3:
		#621, 285
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play("Move_side")
		$PathFollow2D.progress += speed * delta
	elif $PathFollow2D.progress <= 961 && state == 3:
		#621, 221
		animated_sprite_2d.play("Move_up")
		$PathFollow2D.progress += speed * delta
	elif $PathFollow2D.progress <= 1027 && state == 3:
		animated_sprite_2d.flip_h = true
		animated_sprite_2d.play("Move_side")
		$PathFollow2D.progress += speed * delta
	elif $PathFollow2D.progress <= 1337 && state == 4:
		#245, 221
		animated_sprite_2d.flip_h = true
		animated_sprite_2d.play("Move_side")
		$PathFollow2D.progress += speed * delta
	elif $PathFollow2D.progress <= 1403 && state == 4:
		#245, 333
		animated_sprite_2d.play("Move_down")
		$PathFollow2D.progress += speed * delta
	elif $PathFollow2D.progress <= 1543 && state == 5:
		#385, 333
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play("Move_down")
		$PathFollow2D.progress += speed * delta
	elif $PathFollow2D.progress <= 1815 && state == 5:
		#657, 333
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play("Move_side")
		$PathFollow2D.progress += speed * delta
	elif $PathFollow2D.progress < 2194 && state == 5:
		animated_sprite_2d.play("Move_down")
		$PathFollow2D.progress += speed * delta
	elif state == 1:
		animated_sprite_2d.play("Idle_down")
		Dialogic.paused = false
		Dialogic.Text.show_textbox()
	else:
		animated_sprite_2d.play("Idle_down")
