extends CharacterBody2D

# ============================================================
#    THE CAT
#    Change any number below, press play, and feel what happens.
# ============================================================

# How fast the cat runs. Bigger = faster.
const SPEED = 135.0

# How quickly it gets up to full speed, and how quickly it stops.
# Small numbers feel slippery, like ice.
const SPEEDING_UP = 900.0
const SLOWING_DOWN = 1100.0

# How hard the jump pushes. NEGATIVE, because in games up is negative.
const JUMP_STRENGTH = -330.0

# Gravity while you are going UP, and while you are coming DOWN.
# Falling faster than you rise is the secret trick that makes
# Mario jumps feel snappy instead of floaty.
const GRAVITY_GOING_UP = 950.0
const GRAVITY_COMING_DOWN = 1500.0

# Let go of the jump key early and the cat stops rising here.
# That is how you get little hops AND big jumps from one button.
const SHORT_JUMP = -90.0

# A tiny bit of extra time to jump after you walk off a ledge.
# Real Mario does this too. Nobody notices, it just feels fair.
const COYOTE_TIME = 0.1

# How big the bounce is when you land on a baddie's head.
const STOMP_BOUNCE = 0.7


# ---- Things the cat remembers while the game runs ----

signal coins_changed(total)      # shouts the new number to the score board
signal finished                  # shouts once, when you eat the sandwich

var coins := 0
var facing := 1                  # 1 = looking right, -1 = looking left
var start_position := Vector2.ZERO
var time_since_on_floor := 0.0
var walk_timer := 0.0
var has_finished := false

# Fall below this line and you've fallen out of the world.
# The level sets this for us when the game starts.
var bottom_of_the_world := 400.0

# The four pictures of the cat.
var picture_idle  = preload("res://assets/sprites/cat_idle.png")
var picture_walk1 = preload("res://assets/sprites/cat_walk1.png")
var picture_walk2 = preload("res://assets/sprites/cat_walk2.png")
var picture_jump  = preload("res://assets/sprites/cat_jump.png")


func _ready():
	# Remember the starting spot.
	start_position = global_position

	# Make R the restart key.
	if not InputMap.has_action("restart"):
		InputMap.add_action("restart")
		var key := InputEventKey.new()
		key.keycode = KEY_R
		InputMap.action_add_event("restart", key)


func _physics_process(delta):
	# R starts the whole level over.
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		return

	# Once you've eaten the sandwich, the cat takes a rest.
	if has_finished:
		velocity.x = move_toward(velocity.x, 0.0, SLOWING_DOWN * delta)
		move_and_slide()
		return

	fall(delta)
	jump()
	run(delta)

	move_and_slide()
	choose_picture(delta)

	# Fell off the bottom? Go back to the start.
	if global_position.y > bottom_of_the_world:
		ouch()


# Gravity pulls you down, harder on the way down than on the way up.
func fall(delta):
	if is_on_floor():
		time_since_on_floor = 0.0
		return

	time_since_on_floor += delta
	if velocity.y < 0:
		velocity.y += GRAVITY_GOING_UP * delta
	else:
		velocity.y += GRAVITY_COMING_DOWN * delta


func jump():
	# You can jump if you're on the floor, or only just left it.
	if Input.is_action_just_pressed("ui_accept") and time_since_on_floor < COYOTE_TIME:
		velocity.y = JUMP_STRENGTH
		# Use up the coyote time so you can't jump twice.
		time_since_on_floor = COYOTE_TIME
		$JumpSound.play()

	# Let go of the key while still rising? Cut the jump short.
	if Input.is_action_just_released("ui_accept") and velocity.y < SHORT_JUMP:
		velocity.y = SHORT_JUMP


func run(delta):
	# Left arrow gives -1, right arrow gives 1, nothing gives 0.
	var direction = Input.get_axis("ui_left", "ui_right")

	if direction == 0:
		# Nothing held: slide to a stop.
		velocity.x = move_toward(velocity.x, 0.0, SLOWING_DOWN * delta)
	else:
		# Build up to full speed instead of snapping to it.
		velocity.x = move_toward(velocity.x, direction * SPEED, SPEEDING_UP * delta)
		facing = 1 if direction > 0 else -1


# Picks which of the four cat pictures to show right now.
func choose_picture(delta):
	$Body.flip_h = facing < 0

	if not is_on_floor():
		$Body.texture = picture_jump
	elif absf(velocity.x) > 5.0:
		# Flip between the two walking pictures. Faster running,
		# faster flipping.
		walk_timer += delta * absf(velocity.x) * 0.05
		$Body.texture = picture_walk1 if int(walk_timer) % 2 == 0 else picture_walk2
	else:
		$Body.texture = picture_idle


# ---- Things the rest of the world asks the cat to do ----

# A coin calls this when you touch it.
func collect_coin():
	coins += 1
	$CoinSound.play()
	coins_changed.emit(coins)


# A mushroom calls this when you land on its head.
func stomp():
	velocity.y = JUMP_STRENGTH * STOMP_BOUNCE
	$StompSound.play()


# A checkpoint flag calls this when you run past it.
# From now on, getting hurt sends you back HERE instead of all
# the way to the beginning of the level.
func touch_checkpoint(where):
	start_position = where
	$CheckpointSound.play()


# Called when a baddie gets you, or you fall off the world.
func ouch():
	if has_finished:
		return
	$HurtSound.play()
	global_position = start_position
	velocity = Vector2.ZERO


# The sandwich calls this. Level over — you did it!
func finish_level():
	if has_finished:
		return
	has_finished = true
	$WinSound.play()
	finished.emit()
