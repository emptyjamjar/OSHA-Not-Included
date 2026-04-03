extends Node2D
class_name Level4Manager

@onready var hud: CanvasLayer = $Camera2D/HUD
@onready var money := 0
@onready var conveyor = $Conveyor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Ticket_Manager.on_game_start()
	conveyor.conveyor_speed = 60
	conveyor.output_speed = 1.25

func _on_shipper_get_money() -> void:
	money += 10
	hud.update_money(money)
	
