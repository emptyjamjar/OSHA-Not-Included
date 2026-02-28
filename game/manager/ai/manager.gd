extends CharacterBody2D
class_name Manager


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.


func _physics_process(delta: float) -> void:
	print("Manager Running....\n")
	move_and_slide()
	if velocity.x > 0: 
		print("Manager value x value changed")
	else: 
		print("Something wrong here!")
