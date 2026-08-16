extends Node2D

## Smoke test for the Milky setup. Safe to delete once real work starts.

func _ready() -> void:
	var info := Engine.get_version_info()
	print("Milky is running.")
	print("Godot %s (%s)" % [info.string, info.status])
	print("Main scene: %s" % scene_file_path)
