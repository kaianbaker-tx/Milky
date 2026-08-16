extends Area2D

# A refrigerator friend that Milky can find.
# Every friend uses this same script — only the name and the
# shapes are different.

# Which friend is this? Set in each friend's scene.
@export var friend_name := "Friend"

# Have we already been found? Stops double-counting.
var found := false

# Used to make the friend bob up and down so they look alive.
var start_y := 0.0
var bob_time := 0.0


func _ready():
	start_y = position.y
	# When something walks into us, run _on_body_entered.
	body_entered.connect(_on_body_entered)


func _process(delta):
	# Float gently up and down.
	bob_time += delta
	position.y = start_y + sin(bob_time * 2.0) * 6.0


func _on_body_entered(body):
	# Already found? Do nothing.
	if found:
		return

	# Only Milky can pick up friends — not platforms or anything else.
	if not body.is_in_group("player"):
		return

	found = true

	# Put them in the food locker so you can play as them.
	Locker.unlock(friend_name)

	# Tell the counter at the top of the screen.
	get_tree().call_group("hud", "friend_found", friend_name)

	# Disappear.
	queue_free()
