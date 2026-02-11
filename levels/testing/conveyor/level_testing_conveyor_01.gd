extends Node

func _ready():
	var conveyor := $Conveyor
	var tp1 := preload("res://objects/items/toilet_paper/toilet_paper.tscn").instantiate() as Item
	tp1._init(1)
	var tp2 := preload("res://objects/items/toilet_paper/toilet_paper.tscn").instantiate() as Item
	tp2._init(2)
	var tp3 := preload("res://objects/items/toilet_paper/toilet_paper.tscn").instantiate() as Item
	tp3._init(3)
	var tp4 := preload("res://objects/items/toilet_paper/toilet_paper.tscn").instantiate() as Item
	tp4._init(4)

	conveyor.input(tp1)
	conveyor.input(tp2)
	conveyor.input(tp3)
	conveyor.input(tp4)
