## Tab container for tutorial.
## Buttons will add corresponding menu scenes, found in folder structure, to the
## scroll container node. Signals exit_pressed when user is finished.

## Currently uses the same structure as the settings menu until new UI is found.
class_name TutorialMenu extends Control

signal exit_pressed

@export var controlsBtn : TextureButton
@export var videoBtn : TextureButton
@export var audioBtn : TextureButton
@export var exitBtn : TextureButton
@export var scrollContainer : ScrollContainer

var curTab : int = -1

enum {
	CONTROL_TAB,
	VIDEO_TAB,
	AUDIO_TAB,
}

const scenes = [
	"res://ui/menus/tutorial_menu/controls/controls.tscn",
	"res://ui/menus/tutorial_menu/objectives/objectives.tscn",
	"res://ui/menus/tutorial_menu/credits/credits.tscn",
	
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_controls_pressed()


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
	curTab = tab
	if scrollContainer.get_child_count() > 0:
		scrollContainer.get_child(0).queue_free()
	var instance = load(scenes[tab]).instantiate()
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
	exit_pressed.emit()
	queue_free()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_on_exit_pressed()
