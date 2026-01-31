extends RigidBody2D

@export var weight := 10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if linear_velocity.x > 0:
		linear_velocity.x -= weight * 1 * delta
	elif linear_velocity.x < 0:
		linear_velocity.x += weight * 1 * delta
	if linear_velocity.y > 0:
		linear_velocity.y -= weight * 1 * delta
	elif linear_velocity.y < 0:
		linear_velocity.y += weight * 1 * delta
