extends CanvasLayer

# The FOOD LOCKER menu.
# Press L to open it, click a friend to become them.

@onready var panel: PanelContainer = $Panel
@onready var list: VBoxContainer = $Panel/Margin/Rows/List


func _ready():
	panel.hide()
	# Rebuild the buttons whenever you find someone new.
	Locker.locker_changed.connect(rebuild)
	rebuild()


func _unhandled_input(event):
	if event.is_action_pressed("open_locker"):
		if panel.visible:
			close()
		else:
			open()


func open():
	rebuild()
	panel.show()
	# Freeze the game so you don't fall off a shelf while choosing.
	get_tree().paused = true


func close():
	panel.hide()
	get_tree().paused = false


# Makes one button for every friend you've unlocked.
func rebuild():
	for old in list.get_children():
		list.remove_child(old)
		old.queue_free()

	for who in Locker.unlocked:
		var button := Button.new()
		if who == Locker.current:
			button.text = "★  " + who + "  (this is you)"
		else:
			button.text = who
		button.custom_minimum_size = Vector2(280, 46)
		# .bind(who) means "when this button is pressed,
		# call _on_pick and hand it this friend's name".
		button.pressed.connect(_on_pick.bind(who))
		list.add_child(button)


func _on_pick(who: String):
	Locker.become(who)
	close()
