extends CharacterBody2D

# A fireball. It flies forward, bounces off the ground, and squashes
# any mushroom it touches. It burns out after a few seconds.

const SPEED = 190.0
const GRAVITY = 700.0
const BOUNCE = -230.0
const HOW_LONG_IT_LASTS = 2.5
const SPIN_SPEED = 14.0

# 1 = flying right, -1 = flying left. The cat sets this when it shoots.
var direction := 1

var age := 0.0


func _ready():
	# Joining a group is how the cat counts how many fireballs
	# are already flying about.
	add_to_group("fireballs")
	$Hitbox.body_entered.connect(_hit_something)


func _physics_process(delta):
	age += delta
	if age > HOW_LONG_IT_LASTS:
		queue_free()
		return

	velocity.y += GRAVITY * delta
	velocity.x = SPEED * direction
	move_and_slide()

	# Boing! Fireballs bounce along the floor.
	if is_on_floor():
		velocity.y = BOUNCE

	# Smacked into a wall? That's the end of it.
	if is_on_wall():
		queue_free()
		return

	$Sprite.rotation += delta * SPIN_SPEED * direction


func _hit_something(who):
	if who.has_method("hit_by_fireball"):
		who.hit_by_fireball()
		queue_free()
