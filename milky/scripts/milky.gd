extends CharacterBody2D

# One player. The SAME script runs both of them — the only
# difference is player_number, which decides which keys you listen
# to and which character the locker gives you.

# 1 = arrow keys + Space + R
# 2 = A / D + W + Q
@export var player_number: int = 1

# ---- Movement settings ----
# Change these numbers and re-run the game to see what happens!
const SPEED = 300.0
const JUMP_STRENGTH = -600.0
const GRAVITY = 1400.0

# Where you started. Your respawn key sends you back here.
var start_position := Vector2.ZERO

# Fall past this and you've fallen off the world.
const FELL_OFF_THE_WORLD = 900.0

# The names of this player's keys, worked out from player_number.
var key_left := "p1_left"
var key_right := "p1_right"
var key_jump := "p1_jump"
var key_respawn := "p1_respawn"


func _ready():
	# One-player game? Then Player 2 shouldn't be here at all.
	if player_number == 2 and not Locker.two_players:
		remove_from_group("player")
		queue_free()
		return

	# Work out which keys are mine.
	key_left = "p%d_left" % player_number
	key_right = "p%d_right" % player_number
	key_jump = "p%d_jump" % player_number
	key_respawn = "p%d_respawn" % player_number

	start_position = global_position

	# Put my name tag above my head.
	$NameTag.text = "P%d" % player_number

	refresh_look()
	Locker.locker_changed.connect(refresh_look)


# Swaps the drawing without touching anything else — you keep
# your position, your speed, and your jump.
func refresh_look():
	for old in $Look.get_children():
		$Look.remove_child(old)
		old.queue_free()

	var new_look = Locker.look_for(player_number).instantiate()
	$Look.add_child(new_look)

	put_hat_on(new_look)


# Sticks this player's hat onto whoever they're playing as.
# Every character has a HeadMount (top of the head) and a FaceMount
# (over the eyes), so the same hat fits everybody.
func put_hat_on(body):
	var hat_scene = Locker.hat_scene_for(player_number)
	if hat_scene == null:
		return  # "No Hat" — nothing to do.

	var mount = body.get_node_or_null(Locker.hat_mount_for(player_number) + "Mount")
	if mount == null:
		return  # This character has nowhere to put it.

	mount.add_child(hat_scene.instantiate())


# Puts you back at the start, standing still.
# You KEEP every friend and hat — this only moves you.
func respawn():
	global_position = start_position
	velocity = Vector2.ZERO


# This runs over and over, about 60 times every second.
func _physics_process(delta):

	# Pressed your redo key? Go back to the start.
	if Input.is_action_just_pressed(key_respawn):
		respawn()
		return

	# Fell off the bottom of the world? Put yourself back automatically.
	if global_position.y > FELL_OFF_THE_WORLD:
		respawn()
		return

	# In the air? Get pulled down.
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Jump — but only if you're standing on something, so you
	# can't jump again in mid-air.
	if Input.is_action_just_pressed(key_jump) and is_on_floor():
		velocity.y = JUMP_STRENGTH

	# Check your left/right keys.
	# Left gives -1, right gives 1, nothing pressed gives 0.
	var direction = Input.get_axis(key_left, key_right)
	velocity.x = direction * SPEED

	move_and_slide()

	# Swing the hands and feet to match what we just did.
	if $Look.get_child_count() > 0:
		var look = $Look.get_child(0)
		if look.has_method("animate"):
			look.animate(velocity, is_on_floor(), delta)
