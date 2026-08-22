extends StaticBody2D

# ============================================================
#   A PIPE
#
#   Stand on top of it and press the DOWN arrow. It takes you
#   to wherever its partner pipe is — usually a secret room
#   full of coins.
# ============================================================

# Where this pipe sends you. The level fills this in when it
# matches the two pipes up.
var goes_to := Vector2.ZERO

var cat_is_standing_on_me := false


func _ready():
	$Top.body_entered.connect(_someone_stepped_on)
	$Top.body_exited.connect(_someone_stepped_off)


func _someone_stepped_on(who):
	if who.has_method("go_down_a_pipe"):
		cat_is_standing_on_me = true


func _someone_stepped_off(who):
	if who.has_method("go_down_a_pipe"):
		cat_is_standing_on_me = false


func _process(_delta):
	if not cat_is_standing_on_me:
		return
	if goes_to == Vector2.ZERO:
		return          # this pipe has no partner, so it goes nowhere
	if not Input.is_action_just_pressed("ui_down"):
		return

	var cat = get_tree().get_first_node_in_group("cat")
	if cat != null:
		cat.go_down_a_pipe(goes_to)
	cat_is_standing_on_me = false


# Where the cat should pop out if it comes here: on top of us.
func where_you_come_out():
	return global_position + Vector2(9, -32)
