extends Area2D

# The finish flag. Touch it and you win the level.

func _ready():
	body_entered.connect(_someone_touched_me)


func _someone_touched_me(who):
	if who.has_method("win"):
		who.win()
