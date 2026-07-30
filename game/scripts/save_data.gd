extends Node

# The only script that reads or writes the save file. Everyone
# else asks SaveData instead of touching the disk themselves.
# "user://" is a private folder Godot gives every game for saving.

# Fires whenever the wallet changes, so the coin badge can update.
signal wallet_changed(coins: int)

var save_path := "user://save.json"
# Where the high score lived before levels existed.
var old_score_path := "user://high_score.txt"

var wallet: int = 0
var unlocked: Array = []
var best: Dictionary = {}
var owned_skins: Array = ["classic"]
var current_skin: String = "classic"


func _ready() -> void:
	load_save()


func add_coin(amount: int) -> void:
	wallet += amount
	save_game()
	wallet_changed.emit(wallet)


func spend(amount: int) -> bool:
	# Says no if you can't afford it — the shop relies on this.
	if amount > wallet:
		return false
	wallet -= amount
	save_game()
	wallet_changed.emit(wallet)
	return true


func own_skin(id: String) -> void:
	if not owns_skin(id):
		owned_skins.append(id)
		save_game()


func owns_skin(id: String) -> bool:
	return id in owned_skins


func wear_skin(id: String) -> void:
	current_skin = id
	save_game()


func get_best(folder: String) -> int:
	return int(best.get(folder, 0))


func set_best(folder: String, score: int) -> void:
	best[folder] = score
	save_game()


func unlock(folder: String) -> void:
	if not is_unlocked(folder):
		unlocked.append(folder)
		save_game()


func is_unlocked(folder: String) -> bool:
	return folder in unlocked


func apply_unlocks(all_levels: Array) -> void:
	# The rule of the game: beat a level's target and the next
	# one opens. Checking every level (not just the latest run)
	# means targets beaten in past sessions still count.
	for i in range(all_levels.size() - 1):
		if get_best(all_levels[i].folder) >= int(all_levels[i].target):
			unlock(all_levels[i + 1].folder)


func save_game() -> void:
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify({
		"wallet": wallet,
		"unlocked": unlocked,
		"best": best,
		"owned_skins": owned_skins,
		"current_skin": current_skin,
	}))


func load_save() -> void:
	if not FileAccess.file_exists(save_path):
		_migrate_old_high_score()
		return

	var file := FileAccess.open(save_path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	if data == null:
		# The file is damaged — start fresh rather than crash.
		return

	wallet = int(data.get("wallet", 0))
	unlocked = data.get("unlocked", [])
	best = data.get("best", {})
	# Older save files won't have these yet — .get() covers that.
	owned_skins = data.get("owned_skins", ["classic"])
	current_skin = data.get("current_skin", "classic")


func _migrate_old_high_score() -> void:
	# Bring the old one-number save file into the new format,
	# so nobody loses their best score from before levels existed.
	if not FileAccess.file_exists(old_score_path):
		return
	var file := FileAccess.open(old_score_path, FileAccess.READ)
	best["fireballs"] = int(file.get_as_text())
	save_game()
