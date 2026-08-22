extends Area2D

# A fish. Eat it and you get one extra life.

const BOB_HEIGHT = 2.5
const BOB_SPEED = 3.0

var resting_y := 0.0
var clock := 0.0


func _ready():
	resting_y = position.y
	body_entered.connect(_someone_touched_me)


func _process(delta):
	clock += delta * BOB_SPEED
	position.y = resting_y + sin(clock) * BOB_HEIGHT


func _someone_touched_me(who):
	if who.has_method("eat_a_fish"):
		who.eat_a_fish()
		queue_free()
