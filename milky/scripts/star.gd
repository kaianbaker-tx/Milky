extends Area2D

# The gold star at the end of a level.
# Touch it and the LEVEL COMPLETE panel comes up.

var touching := false
var spin := 0.0
var start_y := 0.0


func _ready():
	start_y = position.y
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta):
	spin += delta
	# Float up and down, and tilt slowly, so it looks important.
	position.y = start_y + sin(spin * 2.0) * 7.0
	rotation = sin(spin * 1.2) * 0.22


func _on_body_entered(body):
	if touching:
		return
	if not body.is_in_group("player"):
		return

	touching = true
	# Tell the LEVEL COMPLETE panel to show itself.
	get_tree().call_group("level_end", "show_complete")


func _on_body_exited(body):
	# Step off and back on and you can bring the panel up again.
	if body.is_in_group("player"):
		touching = false
