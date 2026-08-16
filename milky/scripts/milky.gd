extends CharacterBody2D

# ---- Milky's settings ----
# Change these numbers and re-run the game to see what happens!

# How fast Milky walks. Bigger = faster.
const SPEED = 300.0

# How hard Milky jumps. This one is NEGATIVE because in games,
# up is a negative number. Bigger negative = higher jump.
const JUMP_STRENGTH = -600.0

# How hard Milky gets pulled back down to the ground.
const GRAVITY = 1400.0


# This runs over and over, about 60 times every second.
# "delta" is how much time passed since the last time it ran.
func _physics_process(delta):

	# Is Milky in the air? Then pull him down.
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Jump when you press Space — but only if he's standing on something,
	# so he can't jump again while already in the air.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_STRENGTH

	# Check the arrow keys.
	# Left gives -1, right gives 1, nothing pressed gives 0.
	var direction = Input.get_axis("ui_left", "ui_right")

	# Move that way, or stop if no key is held.
	velocity.x = direction * SPEED

	# Now actually move Milky, using everything we decided above.
	move_and_slide()
