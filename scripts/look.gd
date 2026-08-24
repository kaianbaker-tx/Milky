extends Node2D

# Makes a character's hands and feet move.
#
# Every "look" scene uses this. It finds the hands and feet by name,
# remembers where they started, and nudges them around from there.
# If a character doesn't have hands or feet, it just skips them.

const PARTS := ["FootLeft", "FootRight", "HandLeft", "HandRight"]

# Where each part sits when standing still.
var home := {}

# Counts up while walking, to swing the legs back and forth.
var step_time := 0.0


func _ready():
	for part in PARTS:
		if has_node(part):
			home[part] = get_node(part).position


# The player script calls this every frame and hands over
# how fast we're going and whether we're on the ground.
func animate(velocity: Vector2, on_floor: bool, delta: float) -> void:
	var walking := absf(velocity.x) > 10.0

	# Only count up while actually walking on the ground.
	if walking and on_floor:
		step_time += delta * 13.0
	else:
		step_time = 0.0

	# sin() goes smoothly from -1 to 1 and back, over and over.
	# That's what makes the legs swing instead of jerking.
	var swing := sin(step_time) * 8.0

	if on_floor:
		_move_part("FootLeft", Vector2(swing, 0))
		_move_part("FootRight", Vector2(-swing, 0))
		_move_part("HandLeft", Vector2(-swing * 0.6, 0))
		_move_part("HandRight", Vector2(swing * 0.6, 0))
	else:
		# In the air — tuck the feet up and throw the hands out.
		_move_part("FootLeft", Vector2(3, -6))
		_move_part("FootRight", Vector2(-3, -6))
		_move_part("HandLeft", Vector2(-3, -10))
		_move_part("HandRight", Vector2(3, -10))

	# Face the way you're walking.
	if velocity.x > 10.0:
		scale.x = absf(scale.x)
	elif velocity.x < -10.0:
		scale.x = -absf(scale.x)


func _move_part(part: String, offset: Vector2) -> void:
	if home.has(part):
		get_node(part).position = home[part] + offset
