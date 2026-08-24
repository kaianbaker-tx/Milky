extends CanvasLayer

# The panel that appears when you touch the star at the end of a level.

# Which level the NEXT LEVEL button goes to.
# Leave it empty and the button says there's nothing there yet.
@export_file("*.tscn") var next_level: String = ""

@onready var panel: PanelContainer = $Panel
@onready var next_button: Button = $Panel/Margin/Rows/NextButton
@onready var stay_button: Button = $Panel/Margin/Rows/StayButton


func _ready():
	# Join the "level_end" group so the star knows how to reach us.
	add_to_group("level_end")
	panel.hide()
	next_button.pressed.connect(_on_next)
	stay_button.pressed.connect(_on_stay)


# The star calls this when you touch it.
func show_complete():
	if panel.visible:
		return

	# No next level built yet? Say so instead of leading you nowhere.
	if next_level == "":
		next_button.text = "MORE COMING SOON"
		next_button.disabled = true

	panel.show()
	get_tree().paused = true


func _on_next():
	# Unpause BEFORE switching, or the new level starts frozen.
	get_tree().paused = false
	get_tree().change_scene_to_file(next_level)


func _on_stay():
	panel.hide()
	get_tree().paused = false
