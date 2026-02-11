extends Node

func _ready():
	var conveyor := $Conveyor
	var tp1 = preload("res://objects/items/toilet_paper/toilet_paper.tscn").instantiate() as ToiletPaper
	var tp2 = preload("res://objects/items/toilet_paper/toilet_paper.tscn").instantiate() as ToiletPaper
	var tp3 = preload("res://objects/items/toilet_paper/toilet_paper.tscn").instantiate() as ToiletPaper
	var tp4 = preload("res://objects/items/toilet_paper/toilet_paper.tscn").instantiate() as ToiletPaper
	
	conveyor.input(tp1)
	conveyor.input(tp2)
	conveyor.input(tp3)
	conveyor.input(tp4)
