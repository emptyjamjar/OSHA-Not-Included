extends Node2D

const BLACK = preload("res://levels/cutscenes/BLACK.png")
const CUTSCENE = preload("res://levels/cutscenes/Cutscene.png")
@onready var background: TextureRect = $Background

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.signal_event.connect(cutscene01)
	Dialogic.start("cutscene01")
	background.texture = BLACK
	

func cutscene01(argument: String) -> void:
	if argument == "news":
		background.texture = CUTSCENE
	elif argument == "end":
		Level_Manager.next_level()
