extends Node2D
class_name Level0Manager

@onready var hud: CanvasLayer = $Camera2D/HUD
@onready var money := 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.signal_event.connect(tut_cutscene)
	var conveyor := $Conveyor
	Ticket_Manager.on_game_start()
	$Manager.hide()
	Dialogic.start("timeline")
	

func _on_shipper_get_money() -> void:
	money += 10
	hud.update_money(money)
	
func tut_cutscene(argument:String) -> void:
	if argument == "1":
		$CutscenePath.state = 1
	elif argument == "2":
		$CutscenePath.state = 2
	elif argument == "3":
		$CutscenePath.state = 3
	elif argument == "4":
		$CutscenePath.state = 4
	elif argument == "5":
		$CutscenePath.state = 5
