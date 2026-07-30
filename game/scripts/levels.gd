extends Node

# THE LIST. Every level in the game, in unlock order.
# Adding a level = adding a folder in levels/ + one line here.
var all_levels := [
	{"name": "Fireballs", "folder": "fireballs", "target": 30},
]


func find(folder: String) -> Dictionary:
	for entry in all_levels:
		if entry.folder == folder:
			return entry
	# Asked for a level that doesn't exist.
	return {}


func next_after(folder: String) -> Dictionary:
	# The last level has no "next", so stop one short of the end.
	for i in range(all_levels.size() - 1):
		if all_levels[i].folder == folder:
			return all_levels[i + 1]
	return {}


func first_folder() -> String:
	return all_levels[0].folder


func scene_path(folder: String) -> String:
	return "res://levels/%s/level.tscn" % folder
