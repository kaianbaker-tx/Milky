extends StaticBody2D

# ============================================================
#   A BRICK BLOCK
#
#   Whack it from underneath:
#     * a normal orange cat just makes it wobble — too tough
#     * a RED fire cat smashes it into four flying bits
# ============================================================

# Which way each of the four bits flies off, and how fast.
const BIT_THROWS = [
	Vector2(-40, -30), Vector2(40, -30),
	Vector2(-24, -14), Vector2(24, -14),
]

var chunk_picture = preload("res://assets/sprites/brick_chunk.png")


# The cat calls this when it whacks its head on us.
func bumped(cat):
	if cat != null and cat.has_fire:
		smash()
	else:
		$BumpSound.play()
		nudge()


# Too tough to break. Just a wobble.
func nudge():
	var jolt = create_tween()
	jolt.tween_property($Sprite, "position:y", -4.0, 0.06)
	jolt.tween_property($Sprite, "position:y", 0.0, 0.08)


func smash():
	$SmashSound.play()
	for throw in BIT_THROWS:
		throw_a_bit(throw)

	# The brick itself is gone straight away, so you can jump
	# through the hole it left.
	queue_free()


# One flying piece of broken brick. It arcs up, then falls away.
# The bits belong to the level, not to the brick — the brick is
# about to disappear and would take them with it.
func throw_a_bit(throw):
	var bit = Sprite2D.new()
	bit.texture = chunk_picture
	bit.position = position
	get_parent().add_child(bit)

	var start = bit.position

	var sideways = bit.create_tween()
	sideways.tween_property(bit, "position:x", start.x + throw.x * 2.2, 0.65)
	sideways.parallel().tween_property(bit, "rotation", 7.0 * signf(throw.x), 0.65)

	var up_then_down = bit.create_tween()
	up_then_down.tween_property(bit, "position:y", start.y + throw.y, 0.22) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	up_then_down.tween_property(bit, "position:y", start.y + 90.0, 0.45) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	up_then_down.tween_callback(bit.queue_free)
