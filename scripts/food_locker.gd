extends CanvasLayer

# The FOOD LOCKER menu.
# Press L to open it. Two tabs:
#   FOODS — pick who you want to be
#   HATS  — pick what you want to wear
# They're separate, so you can put ANY hat on ANY character.

@onready var panel: PanelContainer = $Panel
@onready var list: VBoxContainer = $Panel/Margin/Rows/List
@onready var foods_button: Button = $Panel/Margin/Rows/Tabs/FoodsTab
@onready var hats_button: Button = $Panel/Margin/Rows/Tabs/HatsTab
@onready var p1_button: Button = $Panel/Margin/Rows/Players/P1Tab
@onready var p2_button: Button = $Panel/Margin/Rows/Players/P2Tab

# Which tab you're looking at: "foods" or "hats".
var tab := "foods"

# Which player you're dressing: 1 or 2.
var who_for := 1


func _ready():
	panel.hide()
	foods_button.pressed.connect(show_tab.bind("foods"))
	hats_button.pressed.connect(show_tab.bind("hats"))
	p1_button.pressed.connect(pick_player.bind(1))
	p2_button.pressed.connect(pick_player.bind(2))
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


func show_tab(which: String):
	tab = which
	rebuild()


# Switch between dressing Player 1 and Player 2.
func pick_player(number: int):
	who_for = number
	rebuild()


# Fills the panel with buttons for whichever tab you're on.
func rebuild():
	# Mark whichever tab you're looking at with an arrow.
	# (Greying it out looked broken, so we use a marker instead.)
	foods_button.text = "▶ FOODS" if tab == "foods" else "FOODS"
	hats_button.text = "▶ HATS" if tab == "hats" else "HATS"
	p1_button.text = "▶ PLAYER 1" if who_for == 1 else "PLAYER 1"
	p2_button.text = "▶ PLAYER 2" if who_for == 2 else "PLAYER 2"

	for old in list.get_children():
		list.remove_child(old)
		old.queue_free()

	if tab == "foods":
		for who in Locker.unlocked:
			_add_button(who, who == Locker.current[who_for], _on_pick_food)
	else:
		for hat in Locker.unlocked_hats:
			_add_button(hat, hat == Locker.current_hat[who_for], _on_pick_hat)


func _add_button(label: String, is_current: bool, handler: Callable):
	var button := Button.new()
	if is_current:
		button.text = "★  " + label
	else:
		button.text = label
	button.custom_minimum_size = Vector2(290, 42)
	# .bind(label) means "when pressed, call handler and hand it this name".
	button.pressed.connect(handler.bind(label))
	list.add_child(button)


func _on_pick_food(who: String):
	Locker.become(who, who_for)
	# Stay open so you can pick a hat next.
	rebuild()


func _on_pick_hat(hat: String):
	Locker.wear(hat, who_for)
	rebuild()
