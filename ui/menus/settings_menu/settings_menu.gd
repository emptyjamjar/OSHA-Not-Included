## Tab container for settings.
##
## Buttons will add corresponding menu scenes, found in folder structure, to the
## scroll container node. Signals exit_pressed when user is finished.
## 
## Settings will be saved/loaded to/from a config file called settings.cfg
class_name SettingsMenu extends Control

signal exit_pressed

@export var controlsBtn : TextureButton
@export var videoBtn : TextureButton
@export var audioBtn : TextureButton
@export var exitBtn : TextureButton
@export var scrollContainer : ScrollContainer

var curTab : int = -1
var config : ConfigFile

enum {
	CONTROL_TAB,
	VIDEO_TAB,
	AUDIO_TAB,
}

const scenes = [
	"res://ui/menus/settings_menu/controls_settings/controls_settings_menu.tscn",
	"res://ui/menus/settings_menu/video_settings/video_settings_menu.tscn",
	"res://ui/menus/settings_menu/audio_settings/audio_settings_menu.tscn",
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create settings config file if not created already
	config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err != OK:
		# Create sections with default values, Audio settings must go first
		# Audio
		var volume = db_to_linear(AudioServer.get_bus_volume_db(0))
		var state = not AudioServer.is_bus_mute(0)
		config.set_value("Master_Audio", "toggle", state)
		config.set_value("Master_Audio", "volume", volume)
		volume = db_to_linear(AudioServer.get_bus_volume_db(1))
		state = not AudioServer.is_bus_mute(1)
		config.set_value("SFX_Audio", "toggle", state)
		config.set_value("SFX_Audio", "volume", volume)
		volume = db_to_linear(AudioServer.get_bus_volume_db(2))
		state = not AudioServer.is_bus_mute(2)
		config.set_value("Music_Audio", "toggle", state)
		config.set_value("Music_Audio", "volume", volume)
		# Controls
		#TODO
		# Video
		#TODO
		# Save settings
		config.save("user://settings.cfg")
	
	_on_audio_pressed()


func _on_controls_pressed() -> void:
	_on_btn_toggle(controlsBtn)
	_change_scroll_container_child(CONTROL_TAB)


func _on_video_pressed() -> void:
	_on_btn_toggle(videoBtn)
	_change_scroll_container_child(VIDEO_TAB)


func _on_audio_pressed() -> void:
	_on_btn_toggle(audioBtn)
	_change_scroll_container_child(AUDIO_TAB)
	


## Scroll container should only ever have 1 child
func _change_scroll_container_child(tab: int):
	if tab == curTab:
		return
	Audio.play_click()
	curTab = tab
	if scrollContainer.get_child_count() > 0:
		scrollContainer.get_child(0).queue_free()
	var instance = load(scenes[tab]).instantiate()
	instance.config = config
	scrollContainer.add_child(instance)


## Sets all button labels to white, then sets toggled button label to dark grey.
func _on_btn_toggle(toggledBtn: TextureButton) -> void:
	var controlLabel = controlsBtn.get_child(0) as CanvasItem
	var videoLabel = videoBtn.get_child(0) as CanvasItem
	var audioLabel = audioBtn.get_child(0) as CanvasItem
	controlLabel.modulate.v = 1
	videoLabel.modulate.v = 1
	audioLabel.modulate.v = 1
	var toggledLabel = toggledBtn.get_child(0) as CanvasItem
	toggledLabel.modulate.v = 0.4


func _on_exit_pressed() -> void:
	Audio.play_exit_click()
	exit_pressed.emit()
	queue_free()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_on_exit_pressed()
