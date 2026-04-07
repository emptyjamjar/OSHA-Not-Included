extends Node2D

const BLACK = preload("res://levels/cutscenes/BLACK.png")
const CUTSCENE = preload("res://levels/cutscenes/Cutscene.png")
@onready var background: TextureRect = $Background

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.signal_event.connect(cutscene02)
	Dialogic.start("cutscene02")
	background.texture = BLACK
	

func cutscene02(argument: String) -> void:
	if argument == "news":
		background.texture = CUTSCENE
	elif argument == "end":
		Level_Manager.next_level()
