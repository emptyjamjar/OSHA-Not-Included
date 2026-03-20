# Light controller for the terminal.

extends PointLight2D
@onready var timer = $"../Timer"
@onready var tickets = Ticket_Manager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tickets.tickets_done.connect(_on_tickets_done)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_tickets_done() -> void:
	visible = true
	timer.start()


func _on_timer_timeout() -> void:
	visible = !visible
	timer.start()


func _on_ticket_terminal_activated() -> void:
	timer.paused = true
	visible = false
