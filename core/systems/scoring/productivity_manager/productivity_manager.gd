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

##If the manager is watching. Turned on by the manager seeing the player in it's vision cone.
var is_watched: bool = false


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
	if is_watched:
		idles += 1
		add_productivity(-10)
		#print("Productivity: " + str(productivity))


func _on_ticket_terminal_tickets_empty() -> void:
	visible = true

	$VBoxContainer/Quota.text = "Tickets resolved: " + str(quota)
	$VBoxContainer/Breaks.text = "Breaks taken: " + str(breaks)
	$VBoxContainer/IdleDings.text = "Idle penalty: " + str(idles)
	$VBoxContainer/Productivity.text = "Overall performance: " + str(productivity)
	$VBoxContainer/Requirement.text = "Minimum score: " + str(Level_Manager.quota)
	
	if productivity >= Level_Manager.quota:
		$EndOfDayPayReport/LetterOfTermination.visible = false
		$Next.visible = true
		$TryAgain.visible = false
	else:
		$EndOfDayPayReport/LetterOfTermination.visible = true
		$Next.visible = false
		$TryAgain.visible = true
	get_tree().paused = true
