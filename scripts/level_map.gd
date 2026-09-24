extends Node2D

# THE LEVEL MAKER
#
# A level is a PICTURE MADE OF LETTERS, in a text file in the
# levels/ folder. This script reads the picture and builds it.
#
# Every letter is one square, 64 pixels across.
#   CAPITAL letters  = things you stand on
#   small letters    = friends you collect
#   @ = where you start     * = the star     . = empty air
#
# To make a new level: copy a text file in levels/ and give it the
# next number. The game finds it on its own.

const CELL = 64

# ---- THINGS YOU STAND ON ----
const BLOCKS := {
	"#": {"name": "Shelf",   "color": Color(0.68, 0.79, 0.85), "top": Color(0.84, 0.91, 0.94), "spot": Color(0, 0, 0, 0)},
	"B": {"name": "Butter",  "color": Color(0.98, 0.87, 0.45), "top": Color(1, 0.94, 0.66),    "spot": Color(0.96, 0.96, 0.93)},
	"C": {"name": "Cereal",  "color": Color(0.87, 0.36, 0.24), "top": Color(0.93, 0.47, 0.33), "spot": Color(0.99, 0.90, 0.66)},
	"S": {"name": "Soda",    "color": Color(0.80, 0.16, 0.21), "top": Color(0.78, 0.79, 0.82), "spot": Color(0.97, 0.95, 0.92)},
	"E": {"name": "Eggs",    "color": Color(0.76, 0.74, 0.71), "top": Color(0.86, 0.84, 0.81), "spot": Color(0.63, 0.61, 0.58)},
	"P": {"name": "Pizza",   "color": Color(0.78, 0.60, 0.40), "top": Color(0.86, 0.69, 0.48), "spot": Color(0.63, 0.47, 0.31)},
	"J": {"name": "Jam",     "color": Color(0.56, 0.24, 0.50), "top": Color(0.85, 0.72, 0.32), "spot": Color(0.97, 0.95, 0.89)},
	"H": {"name": "Cheese",  "color": Color(0.98, 0.78, 0.30), "top": Color(1, 0.88, 0.48),    "spot": Color(0.87, 0.65, 0.21)},
	"M": {"name": "Milk",    "color": Color(0.96, 0.97, 0.98), "top": Color(0.30, 0.55, 0.86), "spot": Color(0.62, 0.82, 0.95)},
	"G": {"name": "Pickles", "color": Color(0.55, 0.71, 0.34), "top": Color(0.72, 0.73, 0.76), "spot": Color(0.38, 0.55, 0.22)},
}

# ---- FRIENDS YOU COLLECT ----
const FRIENDS := {
	"w": "res://scenes/friend_watermelon.tscn",
	"m": "res://scenes/friend_macaroon.tscn",
	"i": "res://scenes/friend_icecream.tscn",
	"p": "res://scenes/friend_popsicle.tscn",
	"s": "res://scenes/friend_strawberry.tscn",
	"c": "res://scenes/friend_cheese.tscn",
}

const STAR := preload("res://scenes/star.tscn")

# Which level to build. The title screen and the LEVEL COMPLETE
# button set this through the Locker.
var level_number := 1


func _ready():
	level_number = maxi(Locker.level_number, 1)
	$HUD/LevelLabel.text = "LEVEL %d" % level_number
	build(read_map(level_number))


# Where level number n's text file lives.
func map_path(n: int) -> String:
	return "res://levels/%02d.txt" % n


# Reads the picture out of the text file, one line per row.
func read_map(n: int) -> Array:
	var path := map_path(n)
	if not FileAccess.file_exists(path):
		push_error("There is no level file at " + path)
		return []

	var rows := []
	for line in FileAccess.get_file_as_string(path).split("\n"):
		rows.append(line.replace("\r", ""))
	return rows


# Turns the picture into a real level.
func build(rows: Array) -> void:
	var start := Vector2(CELL, CELL)

	for row in rows.size():
		var line: String = rows[row]
		for col in line.length():
			var letter := line[col]
			var middle_x := col * CELL + CELL * 0.5
			var floor_y := float((row + 1) * CELL)

			if BLOCKS.has(letter):
				add_block(letter, col, row, rows)
			elif FRIENDS.has(letter):
				var friend = load(FRIENDS[letter]).instantiate()
				friend.position = Vector2(middle_x, floor_y - 30)
				add_child(friend)
			elif letter == "*":
				var star := STAR.instantiate()
				star.position = Vector2(middle_x, floor_y - 34)
				add_child(star)
			elif letter == "@":
				start = Vector2(middle_x, floor_y - 48)

	place_players(start)
	point_at_next_level()


# Builds one 64x64 square you can stand on.
func add_block(letter: String, col: int, row: int, rows: Array) -> void:
	var info: Dictionary = BLOCKS[letter]

	var block := StaticBody2D.new()
	block.name = "%s_%d_%d" % [info["name"], col, row]
	block.position = Vector2(col * CELL + CELL * 0.5, row * CELL + CELL * 0.5)

	block.add_child(make_rect(-CELL * 0.5, -CELL * 0.5, CELL * 0.5, CELL * 0.5, info["color"]))

	# Only draw the shiny top edge when nothing is sitting on top of us,
	# so a long row looks like one slab instead of a pile of bricks.
	if letter_at(rows, col, row - 1) != letter:
		block.add_child(make_rect(-CELL * 0.5, -CELL * 0.5, CELL * 0.5, -CELL * 0.5 + 9, info["top"]))

	# A little patch of detail so it isn't just a flat square.
	var spot: Color = info["spot"]
	if spot.a > 0.0:
		block.add_child(make_rect(-17.0, 3.0, 11.0, 21.0, spot))

	var hit := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(CELL, CELL)
	hit.shape = box
	block.add_child(hit)

	$Blocks.add_child(block)


func make_rect(left: float, top: float, right: float, bottom: float, colour: Color) -> ColorRect:
	var rect := ColorRect.new()
	rect.offset_left = left
	rect.offset_top = top
	rect.offset_right = right
	rect.offset_bottom = bottom
	rect.color = colour
	return rect


# What letter is at this spot? Empty string if it's off the edge.
func letter_at(rows: Array, col: int, row: int) -> String:
	if row < 0 or row >= rows.size():
		return ""
	var line: String = rows[row]
	if col < 0 or col >= line.length():
		return ""
	return line[col]


# Drops the players onto the @ square.
func place_players(start: Vector2) -> void:
	var spot := 0
	for player in get_tree().get_nodes_in_group("player"):
		player.global_position = start + Vector2(spot * 90, 0)
		# This is also where Redo sends them from now on.
		player.start_position = player.global_position
		spot += 1


# If there's a text file for the next number, the star leads there.
func point_at_next_level() -> void:
	var panel := get_node_or_null("LevelComplete")
	if panel == null:
		return

	if FileAccess.file_exists(map_path(level_number + 1)):
		panel.next_level = "res://scenes/level_map.tscn"
		panel.next_number = level_number + 1
	else:
		panel.next_level = ""
		panel.next_number = 0
