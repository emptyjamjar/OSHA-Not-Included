## Audio slider script that changes volume(db) of given audio bus.
## Loads slider/button values from current audio bus values or settings.cfg file
## Must be given a config file to prevent opening multiple at the same time
class_name AudioSlider extends HBoxContainer

signal mute_toggled(section: String, state: bool)
signal volume_changed(section: String, val: float)

## Set to corresponding audio bus.
## Defaults to index 0 which is the master bus.
@export var audioBusIndex : int = 0
@export var volumeSlider : HSlider
@export var muteBtn : CheckBox
@export var sliderLabel : Label

# Config file section to save to
var section : String


func _ready() -> void:
	muteBtn.button_pressed = not AudioServer.is_bus_mute(audioBusIndex)
	volumeSlider.value = db_to_linear(AudioServer.get_bus_volume_db(audioBusIndex))
	sliderLabel.text = str(roundi(volumeSlider.ratio * 100))
	section = AudioServer.get_bus_name(audioBusIndex) + "_Audio"
	# Connect Signals
	muteBtn.toggled.connect(_on_check_box_toggled)
	volumeSlider.value_changed.connect(_on_slider_value_changed)
	volumeSlider.drag_ended.connect(_on_drag_ended)


func _on_check_box_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(audioBusIndex, not toggled_on)
	Audio.play_click()
	mute_toggled.emit(section, toggled_on)


func _on_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(audioBusIndex, linear_to_db(value))
	sliderLabel.text = str(roundi(volumeSlider.ratio * 100))
	volume_changed.emit(section, value)


func _on_drag_ended(_value_changed: bool) -> void:
	Audio.play_click()
