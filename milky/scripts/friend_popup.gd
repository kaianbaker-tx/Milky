extends CanvasLayer

# The big "YOU GOT MELON!" message that flashes up when
# you walk into a refrigerator friend.

@onready var message: Label = $Message

# How long the message stays up, in seconds.
const HOLD_TIME = 1.6

# How long it takes to fade away at the end.
const FADE_TIME = 0.6

var time_left := 0.0
var pop := 0.0


func _ready():
	# Join the "popup" group so friends know how to reach us.
	add_to_group("popup")
	message.modulate.a = 0.0


# A friend calls this when you find them.
func show_friend(nickname: String):
	message.text = "YOU GOT %s!" % nickname
	message.modulate.a = 1.0
	time_left = HOLD_TIME + FADE_TIME
	pop = 1.0


func _process(delta):
	# Nothing showing? Nothing to do.
	if time_left <= 0.0:
		return

	time_left -= delta

	# Little bounce when it first appears.
	if pop > 0.0:
		pop = maxf(pop - delta * 5.0, 0.0)
		message.scale = Vector2.ONE * (1.0 + pop * 0.25)
		# Keep it centred while it grows.
		message.pivot_offset = message.size * 0.5

	# Fade out at the end instead of just vanishing.
	if time_left < FADE_TIME:
		message.modulate.a = maxf(time_left / FADE_TIME, 0.0)
