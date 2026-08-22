extends Label

# Counts how many refrigerator friends Milky has found.

var found := 0
var total := 0


func _ready():
	# Join the "hud" group so friends know how to reach us.
	add_to_group("hud")

	# Wait one frame so every friend has been added to the level,
	# then count them. That way the total is always right, even
	# when you add more friends later.
	await get_tree().process_frame

	total = get_tree().get_nodes_in_group("friend").size()
	update_text()


# A friend calls this when Milky walks into them.
func friend_found(name_of_friend):
	found += 1
	update_text()
	print("You found ", name_of_friend, "!")


func update_text():
	text = "Friends found: %d / %d     [L] Food Locker     [R] Redo" % [found, total]
