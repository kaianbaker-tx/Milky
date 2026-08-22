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


# Where you started. Pressing R sends you back here.
var start_position := Vector2.ZERO

# If you fall past this, you've fallen off the world.
const FELL_OFF_THE_WORLD = 900.0


func _ready():
	# Remember where we began, so redo knows where to put us.
	start_position = global_position

	# Make the R key the redo button.
	if not InputMap.has_action("respawn"):
		InputMap.add_action("respawn")
		var key := InputEventKey.new()
		key.keycode = KEY_R
		InputMap.action_add_event("respawn", key)

	# Draw whoever you're currently playing as.
	refresh_look()

	# The locker shouts whenever you switch characters.
	# When it does, redraw the body.
	Locker.locker_changed.connect(refresh_look)


# Puts you back at the start, standing still.
# You KEEP every friend and hat you found — this only moves you.
func respawn():
	global_position = start_position
	velocity = Vector2.ZERO


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

	# Then put your hat on top of it.
	put_hat_on(new_look)


# Sticks the hat you picked onto whoever you're currently playing as.
# Every character has a HeadMount (top of the head) and a FaceMount
# (over the eyes), so the same hat fits everybody.
func put_hat_on(body):
	var hat_scene = Locker.current_hat_scene()
	if hat_scene == null:
		return  # "No Hat" — nothing to do.

	var mount = body.get_node_or_null(Locker.current_hat_mount() + "Mount")
	if mount == null:
		return  # This character has nowhere to put it.

	mount.add_child(hat_scene.instantiate())


# This runs over and over, about 60 times every second.
# "delta" is how much time passed since the last time it ran.
func _physics_process(delta):

	# Pressed R? Go back to the start.
	if Input.is_action_just_pressed("respawn"):
		respawn()
		return

	# Fell off the bottom of the world? Put yourself back automatically,
	# so you're never stuck falling forever.
	if global_position.y > FELL_OFF_THE_WORLD:
		respawn()
		return

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
