extends Node2D


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
