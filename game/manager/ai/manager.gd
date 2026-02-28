extends CharacterBody2D
class_name Manager


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
@export var patrol_points = [
	{"pos": Vector2(40, 50), "wait": 1.0},  # packing lines
	{"pos": Vector2(100, 50), "wait": 1.0},  # storage aisle
	{"pos": Vector2(600, 600), "wait": 1.0},  # break area
]

func _physics_process(delta: float) -> void:
	move_and_slide()
	if velocity.x > 0: 
		print(velocity.x)
		print(velocity.y)
