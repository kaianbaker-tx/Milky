extends Node

# THE FOOD LOCKER
#
# Keeps track of three things for the whole game:
#   1. which refrigerator friends you've found
#   2. who you're playing as right now
#   3. which hats you've earned, and which one you're wearing
#
# It's an "autoload", which means it's always running and every
# other script can talk to it just by saying "Locker".


# ---- CHARACTERS ----
# Every character, and the drawing that goes with them.
# To add a new friend, make a look scene and add one line here.
const LOOKS := {
	"Milky": "res://scenes/looks/look_milky.tscn",
	"Watermelon": "res://scenes/looks/look_watermelon.tscn",
	"Macaroon": "res://scenes/looks/look_macaroon.tscn",
	"Ice Cream": "res://scenes/looks/look_icecream.tscn",
	"Popsicle": "res://scenes/looks/look_popsicle.tscn",
}

# ---- HATS ----
# Every hat, where its drawing lives, and where it sits on a head.
#   "Head" = on top of the head
#   "Face" = over the eyes, like sunglasses
const HATS := {
	"Sunglasses": {"scene": "res://scenes/hats/hat_sunglasses.tscn", "mount": "Face"},
	"Sweet Treat Cap": {"scene": "res://scenes/hats/hat_sweet_treat.tscn", "mount": "Head"},
	"Cone Hat": {"scene": "res://scenes/hats/hat_cone.tscn", "mount": "Head"},
	"Stick Hat": {"scene": "res://scenes/hats/hat_popsicle_stick.tscn", "mount": "Head"},
}

# Finding a friend also earns you their hat.
const HAT_FROM_FRIEND := {
	"Watermelon": "Sunglasses",
	"Macaroon": "Sweet Treat Cap",
	"Ice Cream": "Cone Hat",
	"Popsicle": "Stick Hat",
}

# Who you've unlocked. You always start with Milky.
var unlocked := ["Milky"]

# Which hats you've earned. "No Hat" is always allowed.
var unlocked_hats := ["No Hat"]

# Who you're playing as right now.
var current := "Milky"

# Which hat you're wearing right now.
var current_hat := "No Hat"

# Shouted whenever anything changes, so the player and the
# menu know to update themselves.
signal locker_changed


func _ready():
	# Make the L key open the locker.
	if not InputMap.has_action("open_locker"):
		InputMap.add_action("open_locker")
		var key := InputEventKey.new()
		key.keycode = KEY_L
		InputMap.action_add_event("open_locker", key)


# Called when you walk into a friend.
func unlock(who: String) -> void:
	if who in unlocked:
		return
	if not LOOKS.has(who):
		push_warning("Locker has no look for '%s' — add one to LOOKS." % who)
		return

	unlocked.append(who)

	# Their hat comes with them.
	if HAT_FROM_FRIEND.has(who):
		var hat = HAT_FROM_FRIEND[who]
		if not hat in unlocked_hats:
			unlocked_hats.append(hat)

	locker_changed.emit()


# Called when you pick somebody in the FOODS tab.
func become(who: String) -> void:
	if not who in unlocked:
		return
	current = who
	locker_changed.emit()


# Called when you pick a hat in the HATS tab.
func wear(hat: String) -> void:
	if not hat in unlocked_hats:
		return
	current_hat = hat
	locker_changed.emit()


# Hands back the drawing for whoever you're playing as.
func current_look() -> PackedScene:
	return load(LOOKS[current])


# Hands back the hat you're wearing, or null if you're bare-headed.
func current_hat_scene() -> PackedScene:
	if not HATS.has(current_hat):
		return null
	return load(HATS[current_hat]["scene"])


# Which mount point the current hat belongs on: "Head" or "Face".
func current_hat_mount() -> String:
	if not HATS.has(current_hat):
		return ""
	return HATS[current_hat]["mount"]
