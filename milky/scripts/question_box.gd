extends StaticBody2D

# ============================================================
#   A ? BOX
#
#   Bump it from UNDERNEATH — jump up into it — and something
#   pops out. One bump uses it up, and then it's just a plain
#   block for the rest of the level, same as in Mario.
# ============================================================

# What's inside. Either "coin" or "coffee".
# The level decides: ? gives a coin, ! gives a cup of coffee.
@export var gives := "coin"

const TILE = 18

# Picture numbers out of assets/sprites/pixel_tiles.png.
const PICTURE_FULL = 10      # gold box with a ?
const PICTURE_USED = 11      # plain gold box, already bumped
const PICTURE_COIN = 151

var used := false

var tiles_picture = preload("res://assets/sprites/pixel_tiles.png")
var coffee_scene = preload("res://scenes/coffee.tscn")


# Works out where a picture lives on the tile sheet, which is
# 20 pictures across.
func picture_at(number):
	return Rect2((number % 20) * TILE, floori(number / 20.0) * TILE, TILE, TILE)


func _ready():
	$Sprite.region_rect = picture_at(PICTURE_FULL)


# The cat calls this when it whacks its head on us.
func bumped(cat):
	if used:
		return

	used = true
	$Sprite.region_rect = picture_at(PICTURE_USED)
	$BumpSound.play()
	nudge()

	if gives == "coffee":
		pop_out_a_coffee()
	else:
		pop_out_a_coin(cat)


# The little jolt the box gives when you hit it.
func nudge():
	var jolt = create_tween()
	jolt.tween_property($Sprite, "position:y", -5.0, 0.07)
	jolt.tween_property($Sprite, "position:y", 0.0, 0.09)


# The coin goes straight into your score, and a picture of one
# flies up out of the box so you can see where it came from.
func pop_out_a_coin(cat):
	if cat != null and cat.has_method("collect_coin"):
		cat.collect_coin()

	var sparkle = Sprite2D.new()
	sparkle.texture = tiles_picture
	sparkle.region_enabled = true
	sparkle.region_rect = picture_at(PICTURE_COIN)
	sparkle.position = Vector2(0, -TILE)
	add_child(sparkle)

	var fly_up = create_tween()
	fly_up.tween_property(sparkle, "position:y", -TILE * 2.3, 0.35)
	fly_up.parallel().tween_property(sparkle, "modulate:a", 0.0, 0.35)
	fly_up.tween_callback(sparkle.queue_free)


# A real cup of coffee pops out and sits on top of the box,
# waiting for you to come and get it.
func pop_out_a_coffee():
	var cup = coffee_scene.instantiate()
	cup.position = position + Vector2(0, -TILE)
	get_parent().add_child.call_deferred(cup)
