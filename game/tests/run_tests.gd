extends SceneTree

# The game's tests. Run them from the command line:
#
#   godot --headless --path game --script res://tests/run_tests.gd
#
# Every check() line asks one question about the code. If the answer
# is ever "no", the test fails and tells you which question broke.

var passed := 0
var failed := 0


func check(question: String, ok: bool) -> void:
	if ok:
		passed += 1
	else:
		failed += 1
		print("  FAILED: ", question)


func _init() -> void:
	test_levels_list()
	test_save_data_starts_empty()
	test_save_data_remembers()
	test_old_high_score_migrates()

	print("%d passed, %d failed" % [passed, failed])
	quit(1 if failed > 0 else 0)


func test_levels_list() -> void:
	var levels = load("res://scripts/levels.gd").new()

	check("the first level is fireballs",
		levels.first_folder() == "fireballs")
	check("find() returns the fireballs entry",
		levels.find("fireballs").name == "Fireballs")
	check("find() returns empty for a made-up level",
		levels.find("made_up").is_empty())
	check("every level has a name, folder and target",
		levels.all_levels.all(func(e): return e.has("name") and e.has("folder") and e.has("target")))
	check("the level scene file really exists for every level",
		levels.all_levels.all(func(e): return ResourceLoader.exists(levels.scene_path(e.folder))))

	levels.free()


func _fresh_save_data():
	# A SaveData pointed at throwaway test files, so tests can
	# never touch the real save.
	var save_data = load("res://scripts/save_data.gd").new()
	save_data.save_path = "user://test_save.json"
	save_data.old_score_path = "user://test_old_score.txt"
	return save_data


func _delete(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func test_save_data_starts_empty() -> void:
	var save_data = _fresh_save_data()
	_delete(save_data.save_path)
	_delete(save_data.old_score_path)
	save_data.load_save()

	check("a brand new wallet is empty", save_data.wallet == 0)
	check("nothing is unlocked yet", not save_data.is_unlocked("fireballs"))
	check("an unplayed level's best is 0", save_data.get_best("fireballs") == 0)

	save_data.free()


func test_save_data_remembers() -> void:
	var first = _fresh_save_data()
	_delete(first.save_path)
	first.load_save()

	first.add_coin(3)
	first.set_best("fireballs", 42)
	first.unlock("dodgeball")

	# A second SaveData reading the same file stands in for
	# "closing the game and opening it again".
	var second = _fresh_save_data()
	second.load_save()

	check("the wallet survives a restart", second.wallet == 3)
	check("the best score survives a restart", second.get_best("fireballs") == 42)
	check("unlocks survive a restart", second.is_unlocked("dodgeball"))
	check("levels never unlocked stay locked", not second.is_unlocked("zombies"))

	_delete(first.save_path)
	first.free()
	second.free()


func test_old_high_score_migrates() -> void:
	var save_data = _fresh_save_data()
	_delete(save_data.save_path)

	# Fake the pre-levels save file: one number in a text file.
	var file := FileAccess.open(save_data.old_score_path, FileAccess.WRITE)
	file.store_string("36")
	file = null

	save_data.load_save()
	check("the old high score becomes the fireballs best",
		save_data.get_best("fireballs") == 36)

	_delete(save_data.save_path)
	_delete(save_data.old_score_path)
	save_data.free()
