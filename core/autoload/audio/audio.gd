extends Node

## Script for accessing playable children of the audio node

## @tutorial: https://youtu.be/8RECF55sK_o?si=6f7m7FGJyVX0WbDt
## Some sounds attained from https://freesound.org/

## Current background music
@onready var music:AudioStreamPlayer = $Music

## Current volume of the background music
var music_volume:float


func _ready() -> void:
	# Load from saved data
	var config = ConfigFile.new()
	config.load("user://settings.cfg")
	_load_defaults(config)
	var sections = ["Master_Audio", "SFX_Audio", "Music_Audio"]
	for bus in range(AudioServer.bus_count):
		var state = config.get_value(sections[bus], "toggle", true)
		AudioServer.set_bus_mute(bus, not state)
		var value = config.get_value(sections[bus], "volume", 100.0)
		AudioServer.set_bus_volume_db(bus, linear_to_db(value))


func _load_defaults(config: ConfigFile):
	if not config.has_section("Master_Audio"):
		var volume = db_to_linear(AudioServer.get_bus_volume_db(0))
		var state = not AudioServer.is_bus_mute(0)
		config.set_value("Master_Audio", "toggle", state)
		config.set_value("Master_Audio", "volume", volume)
	if not config.has_section("SFX_Audio"):
		var volume = db_to_linear(AudioServer.get_bus_volume_db(1))
		var state = not AudioServer.is_bus_mute(1)
		config.set_value("SFX_Audio", "toggle", state)
		config.set_value("SFX_Audio", "volume", volume)
	if not config.has_section("Music_Audio"):
		var volume = db_to_linear(AudioServer.get_bus_volume_db(2))
		var state = not AudioServer.is_bus_mute(2)
		config.set_value("Music_Audio", "toggle", state)
		config.set_value("Music_Audio", "volume", volume)
	config.save("user://settings.cfg")


## Plays the click sound used for buttons or other click selections
func play_click():
	var click = $Click
	click.play()

## Plays the click sound used for exit buttons
func play_exit_click():
	var exit_click = $ExitClick
	exit_click.play()

## Plays the sound used for menus opening
func play_open_menu():
	var open_menu = $OpenMenu
	open_menu.play()

## Plays the sound used for menus closing
func play_close_menu():
	var close_menu = $CloseMenu
	close_menu.play()
	
## Plays the toilet flushing sound
func play_toilet():
	var toilet = $Toilet
	toilet.play()

## Plays the vending machine sound
func play_vending_machine():
	var vm = $VendingMachine
	vm.play()

## Play invalid interaction sound when interacting with empty inventory slot.
func play_invalid_interaction():
	var invalid = $InvalidInteraction
	invalid.play()
	
func play_trash_open():
	var trash = $TrashOpen
	trash.play()
	
func play_trash_close():
	var trash = $TrashClose
	trash.play()
	
func play_trash_use():
	var trash = $TrashUse
	trash.play()
	
func play_shipped():
	var shipped = $ShippedSuccess
	shipped.play()
	
func play_tape_box():
	var tape = $TapeBox
	tape.play()

## Plays the background music of the game
func play_music():
	music.stream.loop = true
	music.process_mode = Node.PROCESS_MODE_ALWAYS
	music.play()

## Lowers the music volume by 10. Good for when paused, or anytime
## music should be a bit lower.
func lower_music():
	music_volume = music.volume_db
	music.volume_db = music_volume - 10

## Resets the music volume to it's original state. To be used after
## calling [method lower_music].
func reset_music_volume():
	music.volume_db = music_volume
	
