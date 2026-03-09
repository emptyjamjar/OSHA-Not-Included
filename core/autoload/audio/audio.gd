extends Node

## Script for accessing playable children of the audio node

## @tutorial: https://youtu.be/8RECF55sK_o?si=6f7m7FGJyVX0WbDt
## Some sounds attained from https://freesound.org/

# Plays the click sound used for buttons or other click selections
func play_click():
	var click = $Click
	click.play()
	
# Plays the click sound used for exit buttons
func play_exit_click():
	var exit_click = $ExitClick
	exit_click.play()

# Plays the sound used for menus opening
func play_open_menu():
	var open_menu = $OpenMenu
	open_menu.play()

# Plays the sound used for menus closing
func play_close_menu():
	var close_menu = $CloseMenu
	close_menu.play()
	
# Plays the toilet flushing sound
func play_toilet():
	var toilet = $Toilet
	toilet.play()

### Plays the background music of the game
#func play_music():
	#var music = $Music
	#music.stream.loop = true
	#music.play()
