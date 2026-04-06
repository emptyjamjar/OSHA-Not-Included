# Light controller for the terminal.

extends PointLight2D
@onready var timer = $"../Timer"
var ticket_manager: TicketManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ticket_manager = get_tree().get_first_node_in_group("Ticket Manager")
	
	ticket_manager.tickets_done.connect(_on_tickets_done)


func _process(delta: float) -> void:
	texture.noise.offset.x = randf() * 1000.0


func _on_tickets_done() -> void:
	visible = true
	timer.start()


func _on_timer_timeout() -> void:
	visible = !visible
	timer.start()


func _on_ticket_terminal_activated() -> void:
	timer.paused = true
	visible = false
