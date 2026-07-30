extends Control

# The pick-a-level screen. It builds one row per level in
# Levels.all_levels, so it never needs editing to show a new level.

signal level_chosen(folder: String)
signal shop_chosen


func _ready() -> void:
	for i in range(Levels.all_levels.size()):
		_add_row(i)

	var shop := Button.new()
	shop.text = "Shop"
	shop.pressed.connect(func(): shop_chosen.emit())
	$Rows.add_child(shop)


func _add_row(i: int) -> void:
	var entry: Dictionary = Levels.all_levels[i]
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)

	var name_label := Label.new()
	name_label.text = entry.name
	name_label.add_theme_font_size_override("font_size", 26)
	row.add_child(name_label)

	if SaveData.is_unlocked(entry.folder):
		var best: int = SaveData.get_best(entry.folder)
		if best > 0:
			var best_label := Label.new()
			best_label.text = "Best: %d" % best
			row.add_child(best_label)

		var play := Button.new()
		play.text = "Play"
		play.pressed.connect(_on_play_pressed.bind(entry.folder))
		row.add_child(play)
	else:
		# Locked: say what it takes to open it.
		var before: Dictionary = Levels.all_levels[i - 1]
		var lock_label := Label.new()
		lock_label.text = "Reach %d in %s" % [before.target, before.name]
		row.add_child(lock_label)

	$Rows.add_child(row)


func _on_play_pressed(folder: String) -> void:
	level_chosen.emit(folder)
