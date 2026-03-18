# Level selector.
# Checks what the last level was and loads the next.

extends Node2D

var levels : Array[NodePath] = [
	"res://levels/warehouse_01/layout/game.tscn",
	"res://levels/warehouse_02/game.tscn"]
	
var level = 0

func next_level():
	get_tree().change_scene_to_file(levels[level])
	level += 1

func reset():
	level = 0
