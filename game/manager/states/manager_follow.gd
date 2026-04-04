extends State
class_name ManagerFollow

@export var manager: CharacterBody2D
var player: CharacterBody2D
@export var move_speed := 40.0

func Enter(): 
	player = get_tree().get_first_node_in_group("player")
	
func Physics_Update(delta: float) -> void:
	# get the direction between player and manager
	var direction = player.global_position - manager.global_position
	manager.velocity = direction.normalized() * move_speed
	#if direction.length() > 25: 
		## move manager towards the player
		#manager.velocity = direction.normalized() * move_speed
	#else: 
		## stands still
		#manager.velocity = Vector2()
		 #
	#if direction.length() > 50: 
		#transitioned.emit(self, "idle")
	 
	 
