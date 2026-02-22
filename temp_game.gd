extends Node2D
class_name GameManager

@onready var hud: CanvasLayer = $Camera2D/HUD
@onready var money := 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var conveyor := $Conveyor
	conveyor.input(Conveyor.ItemDataList.TOILET_PAPER)
	conveyor.input(Conveyor.ItemDataList.PINK_WATER_BOTTLE)
	conveyor.input(Conveyor.ItemDataList.BLACK_WATER_BOTTLE)
	conveyor.input(Conveyor.ItemDataList.TOILET_PAPER)
	conveyor.input(Conveyor.ItemDataList.BLUE_WATER_BOTTLE)
	conveyor.input(Conveyor.ItemDataList.TOILET_PAPER)
	conveyor.input(Conveyor.ItemDataList.PINK_WATER_BOTTLE)
	conveyor.input(Conveyor.ItemDataList.BLACK_WATER_BOTTLE)
	conveyor.input(Conveyor.ItemDataList.TOILET_PAPER)
	conveyor.input(Conveyor.ItemDataList.BLUE_WATER_BOTTLE)


func _on_shipper_get_money() -> void:
	money += 10
	hud.update_money(money)
	
