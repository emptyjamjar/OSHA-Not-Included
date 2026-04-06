# Level selector.
# Checks what the last level was and loads the next.

extends Node2D

var levels : Array[NodePath] = [
	"res://game.tscn",
	"res://levels/warehouse_01/layout/game.tscn",
	"res://levels/warehouse_01/layout/game_2.tscn",
	"res://levels/warehouse_02/game.tscn",
	"res://levels/warehouse_02/game_2.tscn"]

var quota = 15
var level = 0

func next_level():
	var max_levels = levels.size()
	PlayerInventory.reset()
	quota += 15
	if level == max_levels:
		level = 0
		get_tree().change_scene_to_file(levels[0])
	else:
		level += 1
		get_tree().change_scene_to_file(levels[level])
		

func replay_level() -> void:
	PlayerInventory.reset()
	get_tree().change_scene_to_file(levels[level])

	

func reset():
	level = 0
	quota = 0
