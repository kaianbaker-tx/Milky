extends Node

# THE FOOD LOCKER
#
# This one keeps track of two things for the whole game:
#   1. which refrigerator friends you've found
#   2. who you're playing as right now
#
# It's an "autoload", which means it's always running and every
# other script can talk to it just by saying "Locker".


# Every character in the game, and the drawing that goes with them.
# To add a new friend, make a look scene and add one line here.
const LOOKS := {
	"Milky": "res://scenes/looks/look_milky.tscn",
	"Watermelon": "res://scenes/looks/look_watermelon.tscn",
	"Macaroon": "res://scenes/looks/look_macaroon.tscn",
	"Ice Cream": "res://scenes/looks/look_icecream.tscn",
	"Popsicle": "res://scenes/looks/look_popsicle.tscn",
}

# Who you've unlocked. You always start with Milky.
var unlocked := ["Milky"]

# Who you're playing as right now.
var current := "Milky"

# Shouted whenever the locker changes, so the player and the
# menu know to update themselves.
signal locker_changed


func _ready():
	# Make the L key open the locker.
	# Doing it here means we never have to touch project settings.
	if not InputMap.has_action("open_locker"):
		InputMap.add_action("open_locker")
		var key := InputEventKey.new()
		key.keycode = KEY_L
		InputMap.action_add_event("open_locker", key)


# Called when Milky walks into a friend.
func unlock(who: String) -> void:
	if who in unlocked:
		return
	if not LOOKS.has(who):
		push_warning("Locker has no look for '%s' — add one to LOOKS." % who)
		return

	unlocked.append(who)
	locker_changed.emit()


# Called when you pick somebody in the locker menu.
func become(who: String) -> void:
	if not who in unlocked:
		return
	current = who
	locker_changed.emit()


# Hands back the drawing for whoever you're playing as.
func current_look() -> PackedScene:
	return load(LOOKS[current])
