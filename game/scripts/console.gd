extends Node

# The "console". It shows the menu, starts a level ("cartridge")
# when you pick one, and writes down how each run went.

var menu_scene := preload("res://scenes/menu.tscn")


func _ready() -> void:
	# The first level is always playable, and targets beaten
	# in earlier sessions still count.
	SaveData.unlock(Levels.first_folder())
	SaveData.apply_unlocks(Levels.all_levels)
	show_menu()


func show_menu() -> void:
	_clear_screen()
	$TopBar/MenuButton.hide()
	var menu := menu_scene.instantiate()
	menu.level_chosen.connect(_on_level_chosen)
	$Screen.add_child(menu)


func _on_level_chosen(folder: String) -> void:
	_clear_screen()
	var level = load(Levels.scene_path(folder)).instantiate()
	# bind() tacks the folder name onto the signal, so the
	# handler knows which level is reporting in.
	level.finished.connect(_on_level_finished.bind(folder))
	$Screen.add_child(level)
	$TopBar/MenuButton.show()


func _on_level_finished(score: int, _coins: int, folder: String) -> void:
	if score > SaveData.get_best(folder):
		SaveData.set_best(folder, score)

	# Beat the target? The next level opens up.
	SaveData.apply_unlocks(Levels.all_levels)


func _on_menu_button_pressed() -> void:
	show_menu()


func _clear_screen() -> void:
	for child in $Screen.get_children():
		child.queue_free()
