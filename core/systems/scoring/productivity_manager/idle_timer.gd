extends Timer

@onready var player = get_tree().get_first_node_in_group("player")
@onready var score = $".."
var running = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player.idle == true:
		if running == false:
			start(2)
			set_paused(false)
			running = true
			#print("Started")
	else:
		if running == true:
			set_paused(true)
			running = false
			#print("Paused")

func _on_timeout() -> void:
	start(2)
	#print("Timed out")
