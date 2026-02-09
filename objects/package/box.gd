class_name Box extends RigidBody2D

@export var weight := 10
@onready var interaction_area: InteractionArea = $InteractionArea
@onready var picked_up = false
@onready var player = get_tree().get_first_node_in_group("player")
@onready var game = get_tree().get_first_node_in_group("game")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#if linear_velocity.x > 0:
		#linear_velocity.x -= weight * 1 * delta
	#elif linear_velocity.x < 0:
		#linear_velocity.x += weight * 1 * delta
	#if linear_velocity.y > 0:
		#linear_velocity.y -= weight * 1 * delta
	#elif linear_velocity.y < 0:
		#linear_velocity.y += weight * 1 * delta
	#else:
		#linear_velocity.y = 0
	
	if picked_up:
		self.freeze = true
		self.global_position = player.global_position
		reparent(player)
	else:
		self.freeze = false
		reparent(game)

func _on_interact():
	if picked_up != true:
		picked_up = true
		print("You picked me up!")
	else:
		picked_up = false
		print("You dropped me!")
