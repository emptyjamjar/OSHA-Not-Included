extends Path2D

@export var speed = 100 # Pixels per second
var state := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta):
	if state == 0:
		$PathFollow2D/Sprite2D.show()
	elif $PathFollow2D.progress <= 286 && state == 1:
		$PathFollow2D.progress += speed * delta   
	elif $PathFollow2D.progress <= 473 && state == 2:
		$PathFollow2D.progress += speed * delta
	elif $PathFollow2D.progress <= 1027 && state == 3:
		$PathFollow2D.progress += speed * delta
	elif $PathFollow2D.progress <= 1403 && state == 4:
		$PathFollow2D.progress += speed * delta
	elif $PathFollow2D.progress < 2039 && state == 5:
		$PathFollow2D.progress += speed * delta
	else:
		$PathFollow2D/Sprite2D.hide()
