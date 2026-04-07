extends Node2D

const BLACK = preload("res://levels/cutscenes/BLACK.png")
const CUTSCENE = preload("res://levels/cutscenes/Cutscene.png")
@onready var background: TextureRect = $Background

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.signal_event.connect(cutscene00)
	Dialogic.start("cutscene00")
	background.texture = BLACK
	

func cutscene00(argument: String) -> void:
	if argument == "news":
		background.texture = CUTSCENE
	elif argument == "end":
		Level_Manager.next_level()
