# Score manager for level.
# Depends on signals to washroom and shipper.

extends Node2D

signal productivity_changed(change: int, new: int)

var active_areas : Array[InteractionArea] = []
var can_interact = false

var productivity : int = 0


func _ready() -> void:
	pass

func add_productivity(value : int) -> int:
	productivity += value
	productivity_changed.emit(value, productivity)
	print("Productivity: " + str(productivity))
	return productivity

func _on_shipper_add_score() -> void:
	add_productivity(15)
	

func _on_washroom_washroom_used() -> void:
	add_productivity(-10)
	#print("Productivity: " + str(productivity))


func _on_idle_timer_timeout() -> void:
	add_productivity(-5)
	#print("Productivity: " + str(productivity))
