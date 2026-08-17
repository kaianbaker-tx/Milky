extends CharacterBody2D

# ---- Movement settings ----
# Change these numbers and re-run the game to see what happens!

# How fast you walk. Bigger = faster.
const SPEED = 300.0

# How hard you jump. This one is NEGATIVE because in games,
# up is a negative number. Bigger negative = higher jump.
const JUMP_STRENGTH = -600.0

# How hard gravity pulls you back down.
const GRAVITY = 1400.0


func _ready():
	# Draw whoever you're currently playing as.
	refresh_look()

	# The locker shouts whenever you switch characters.
	# When it does, redraw the body.
	Locker.locker_changed.connect(refresh_look)


# Swaps the drawing without touching anything else — you keep
# your position, your speed, and your jump.
func refresh_look():
	# Take out the old drawing.
	for old in $Look.get_children():
		$Look.remove_child(old)
		old.queue_free()

	# Put in the new one.
	var new_look = Locker.current_look().instantiate()
	$Look.add_child(new_look)


# This runs over and over, about 60 times every second.
# "delta" is how much time passed since the last time it ran.
func _physics_process(delta):

	# In the air? Get pulled down.
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Jump when you press Space — but only if you're standing on
	# something, so you can't jump again in mid-air.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_STRENGTH

	# Check the arrow keys.
	# Left gives -1, right gives 1, nothing pressed gives 0.
	var direction = Input.get_axis("ui_left", "ui_right")

	# Move that way, or stop if no key is held.
	velocity.x = direction * SPEED

	# Now actually move, using everything we decided above.
	move_and_slide()

	# Swing the hands and feet to match what we just did.
	if $Look.get_child_count() > 0:
		var look = $Look.get_child(0)
		if look.has_method("animate"):
			look.animate(velocity, is_on_floor(), delta)
