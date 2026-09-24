extends Control

# The screen you see when the game starts.
# Pick one player or two, then Level 1 loads.

const FIRST_LEVEL = "res://scenes/level_map.tscn"

@onready var play_button: Button = $Rows/PlayButton
@onready var multi_button: Button = $Rows/MultiButton


func _ready():
	play_button.pressed.connect(start_game.bind(false))
	multi_button.pressed.connect(start_game.bind(true))

	# Put the keyboard on the first button so you can just hit Enter.
	play_button.grab_focus()


# two_players decides whether Player 2 shows up in the level.
func start_game(two_players: bool):
	Locker.two_players = two_players

	# Fresh start — forget any friends found in a previous go.
	Locker.reset()

	# Always start at level 1.
	Locker.level_number = 1

	get_tree().change_scene_to_file(FIRST_LEVEL)
