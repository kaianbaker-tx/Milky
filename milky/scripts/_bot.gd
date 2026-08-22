extends Node2D

var world
var cat
var t := 0.0
var furthest := 0.0
var stuck := 0.0
var log_next := 0.0

func _ready():
	world = load("res://scenes/cat_world.tscn").instantiate()
	add_child(world)
	await get_tree().process_frame
	cat = world.get_node("Cat")

func square_of(pos):
	return Vector2i(int(pos.x / 18.0), int(pos.y / 18.0))

func _physics_process(delta):
	if cat == null:
		return
	t += delta
	Input.action_press("ui_right")

	var here = square_of(cat.global_position)
	var foot_row = here.y + 1

	# Look ahead: a wall in the way, or a hole in the floor?
	var wall = world.is_solid(here.x + 1, here.y) or world.is_solid(here.x + 2, here.y)
	var hole = not world.is_solid(here.x + 2, foot_row) and not world.is_solid(here.x + 3, foot_row)
	if cat.is_on_floor() and (wall or hole):
		Input.action_press("ui_accept")
	else:
		Input.action_release("ui_accept")

	if cat.global_position.x > furthest + 1.0:
		furthest = cat.global_position.x
		stuck = 0.0
	else:
		stuck += delta

	if cat.has_won:
		print("BOT WON	t=%.1f	coins=%d" % [t, cat.coins])
		get_tree().quit()
	if stuck > 8.0:
		print("BOT STUCK at square %d,%d  t=%.1f coins=%d" % [here.x, here.y, t, cat.coins])
		get_tree().quit()
	if t > 150.0:
		print("BOT TIMEOUT square %d,%d coins=%d" % [here.x, here.y, cat.coins])
		get_tree().quit()
