extends HBoxContainer

@export var audioBusIndex : int
@export var volumeSlider : HSlider
@export var muteBtn : CheckBox
@export var sliderLabel : Label

func _ready() -> void:
	muteBtn.button_pressed = not AudioServer.is_bus_mute(audioBusIndex)
	volumeSlider.value = AudioServer.get_bus_volume_db(audioBusIndex)
	sliderLabel.text = str(roundi(volumeSlider.ratio * 100))


func _on_check_box_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(audioBusIndex, not toggled_on)


func _on_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(audioBusIndex, value)
	sliderLabel.text = str(roundi(volumeSlider.ratio * 100))
