extends Node

# THE FOOD LOCKER
#
# Keeps track of everything for the whole game:
#   1. which refrigerator friends have been found (shared by both players)
#   2. who EACH player is playing as
#   3. which hats have been earned, and which one each player wears
#
# It's an "autoload", which means it's always running and every
# other script can talk to it just by saying "Locker".


# ---- CHARACTERS ----
# Every character, and the drawing that goes with them.
const LOOKS := {
	"Milky": "res://scenes/looks/look_milky.tscn",
	"Watermelon": "res://scenes/looks/look_watermelon.tscn",
	"Macaroon": "res://scenes/looks/look_macaroon.tscn",
	"Ice Cream": "res://scenes/looks/look_icecream.tscn",
	"Popsicle": "res://scenes/looks/look_popsicle.tscn",
	"Strawberry": "res://scenes/looks/look_strawberry.tscn",
	"Cheese Block": "res://scenes/looks/look_cheese.tscn",
}

# ---- HATS ----
#   "Head" = on top of the head
#   "Face" = over the eyes, like sunglasses
const HATS := {
	"Sunglasses": {"scene": "res://scenes/hats/hat_sunglasses.tscn", "mount": "Face"},
	"Sweet Treat Cap": {"scene": "res://scenes/hats/hat_sweet_treat.tscn", "mount": "Head"},
	"Cone Hat": {"scene": "res://scenes/hats/hat_cone.tscn", "mount": "Head"},
	"Stick Hat": {"scene": "res://scenes/hats/hat_popsicle_stick.tscn", "mount": "Head"},
	"Leaf Hat": {"scene": "res://scenes/hats/hat_leaf.tscn", "mount": "Head"},
}

# Finding a friend also earns you their hat.
const HAT_FROM_FRIEND := {
	"Watermelon": "Sunglasses",
	"Macaroon": "Sweet Treat Cap",
	"Ice Cream": "Cone Hat",
	"Popsicle": "Stick Hat",
	"Strawberry": "Leaf Hat",
}

# Found friends and earned hats are SHARED — either player can
# pick up a friend and both players can wear the hat.
var unlocked := ["Milky"]
var unlocked_hats := ["No Hat"]

# These are per player. Player 1 and Player 2 each get their own.
var current := {1: "Milky", 2: "Milky"}
var current_hat := {1: "No Hat", 2: "No Hat"}

# Did you pick MULTIPLAYER on the title screen?
# The title screen sets this before the level loads.
var two_players := false

# Which level you are playing. The title screen sets it to 1,
# and the NEXT LEVEL button counts it up.
var level_number := 1

signal locker_changed


func _ready():
	# The locker key.
	_add_key("open_locker", KEY_L)

	# Player 1 — arrow keys and space.
	_add_key("p1_left", KEY_LEFT)
	_add_key("p1_right", KEY_RIGHT)
	_add_key("p1_jump", KEY_SPACE)
	_add_key("p1_respawn", KEY_R)

	# Player 2 — A and D to move, W to jump.
	_add_key("p2_left", KEY_A)
	_add_key("p2_right", KEY_D)
	_add_key("p2_jump", KEY_W)
	_add_key("p2_respawn", KEY_Q)


# Makes one key do one thing, if it isn't set up already.
func _add_key(action: String, keycode: Key) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action)
	var key := InputEventKey.new()
	key.keycode = keycode
	InputMap.action_add_event(action, key)


# Wipes everything back to the start. The title screen calls this
# so a new game doesn't remember the last one.
func reset() -> void:
	unlocked = ["Milky"]
	unlocked_hats = ["No Hat"]
	current = {1: "Milky", 2: "Milky"}
	current_hat = {1: "No Hat", 2: "No Hat"}
	locker_changed.emit()


# Called when either player walks into a friend.
func unlock(who: String) -> void:
	if who in unlocked:
		return
	if not LOOKS.has(who):
		push_warning("Locker has no look for '%s' — add one to LOOKS." % who)
		return

	unlocked.append(who)

	if HAT_FROM_FRIEND.has(who):
		var hat = HAT_FROM_FRIEND[who]
		if not hat in unlocked_hats:
			unlocked_hats.append(hat)

	locker_changed.emit()


# Called when you pick somebody in the FOODS tab.
func become(who: String, player: int = 1) -> void:
	if not who in unlocked:
		return
	current[player] = who
	locker_changed.emit()


# Called when you pick a hat in the HATS tab.
func wear(hat: String, player: int = 1) -> void:
	if not hat in unlocked_hats:
		return
	current_hat[player] = hat
	locker_changed.emit()


# The drawing for whoever this player is.
func look_for(player: int) -> PackedScene:
	return load(LOOKS[current[player]])


# The hat this player is wearing, or null if bare-headed.
func hat_scene_for(player: int) -> PackedScene:
	var hat = current_hat[player]
	if not HATS.has(hat):
		return null
	return load(HATS[hat]["scene"])


# Which mount the hat belongs on: "Head" or "Face".
func hat_mount_for(player: int) -> String:
	var hat = current_hat[player]
	if not HATS.has(hat):
		return ""
	return HATS[hat]["mount"]
