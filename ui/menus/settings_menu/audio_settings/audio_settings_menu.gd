# Handles saving audio settings to settings.cfg
extends VBoxContainer

@export var Master : AudioSlider
@export var SFX : AudioSlider
@export var Music : AudioSlider

var config : ConfigFile


func _ready() -> void:
	if config == null:
		printerr("No config file given")
	Master.mute_toggled.connect(_on_mute_toggled)
	SFX.mute_toggled.connect(_on_mute_toggled)
	Music.mute_toggled.connect(_on_mute_toggled)
	
	Master.volume_changed.connect(_on_volume_changed)
	SFX.volume_changed.connect(_on_volume_changed)
	Music.volume_changed.connect(_on_volume_changed)


func _on_mute_toggled(section: String, state: bool):
	config.set_value(section, "toggle", state)
	config.save("user://settings.cfg")


func _on_volume_changed(section: String, val: float):
	config.set_value(section, "volume", val)
	config.save("user://settings.cfg")
