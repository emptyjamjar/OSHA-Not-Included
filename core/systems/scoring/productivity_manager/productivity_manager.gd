# Score manager for level.
# Depends on signals to washroom and shipper.

class_name ProductivityManager

extends Node2D

signal productivity_changed(change: int, new: int)

var active_areas : Array[InteractionArea] = []
var can_interact = false

var productivity : int = 0
var quota : int = 0
var breaks : int = 0
var idles : int = 0


func _ready() -> void:
	pass

func add_productivity(value : int) -> int:
	productivity += value
	productivity_changed.emit(value, productivity)
	print("Productivity: " + str(productivity))
	print(productivity)
	print(quota)
	print(breaks)
	print(idles)
	return productivity

func _on_shipper_get_money() -> void:
	quota += 1
	add_productivity(15)
	
func _on_washroom_washroom_used() -> void:
	breaks += 1
	add_productivity(-10)
	#print("Productivity: " + str(productivity))


func _on_idle_timer_timeout() -> void:
	idles += 1
	add_productivity(-5)
	#print("Productivity: " + str(productivity))


func _on_ticket_terminal_tickets_empty() -> void:
	visible = true

	$VBoxContainer/Quota.text = "Tickets resolved: " + str(quota)
	$VBoxContainer/Breaks.text = "Breaks taken: " + str(breaks)
	$VBoxContainer/IdleDings.text = "Idle penalty: " + str(idles)
	$VBoxContainer/Productivity.text = "Overall performance: " + str(productivity)
	get_tree().paused = true
