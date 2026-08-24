extends Camera2D

# One camera for everybody.
#
# It sits halfway between the players and zooms out when they run
# apart, so nobody gets left off the edge of the screen.

# How much empty space to leave around the players.
const MARGIN = 460.0

# How far out and how far in it's allowed to go.
const FURTHEST_OUT = 0.62
const CLOSEST_IN = 1.6

# How wide the game window is, in game pixels.
const VIEW_WIDTH = 1152.0


func _ready():
	make_current()


func _process(delta):
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return

	# Find the middle of everybody, and how spread out they are.
	var middle := Vector2.ZERO
	var left := INF
	var right := -INF
	for p in players:
		middle += p.global_position
		left = minf(left, p.global_position.x)
		right = maxf(right, p.global_position.x)
	middle /= players.size()

	# Glide to the middle instead of snapping there.
	global_position = global_position.lerp(middle, 1.0 - pow(0.0008, delta))

	# The further apart they are, the further out we zoom.
	var spread := right - left
	var wanted := clampf(VIEW_WIDTH / maxf(spread + MARGIN, 1.0), FURTHEST_OUT, CLOSEST_IN)
	zoom = zoom.lerp(Vector2(wanted, wanted), 1.0 - pow(0.02, delta))
