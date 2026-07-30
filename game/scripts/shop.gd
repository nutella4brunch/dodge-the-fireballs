extends Control

# The shop. One row per skin on the shelf in Skins.all_skins.
# Buying auto-wears the new skin; you can switch back any time.

signal back_pressed


func _ready() -> void:
	_rebuild()


func _rebuild() -> void:
	# Throw away the old rows and build fresh ones, so the
	# buttons always match what you own and what you can afford.
	for child in $Rows.get_children():
		if child.name != "Title":
			child.queue_free()

	for skin in Skins.all_skins:
		_add_row(skin)

	var back := Button.new()
	back.text = "Back"
	back.pressed.connect(func(): back_pressed.emit())
	$Rows.add_child(back)


func _add_row(skin: Dictionary) -> void:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)

	# A little square showing the skin's color.
	var swatch := ColorRect.new()
	swatch.custom_minimum_size = Vector2(24, 24)
	swatch.color = skin.color
	row.add_child(swatch)

	var name_label := Label.new()
	name_label.text = skin.name
	name_label.add_theme_font_size_override("font_size", 22)
	row.add_child(name_label)

	if skin.id == SaveData.current_skin:
		var wearing := Label.new()
		wearing.text = "Wearing"
		row.add_child(wearing)
	elif SaveData.owns_skin(skin.id):
		var wear := Button.new()
		wear.text = "Wear"
		wear.pressed.connect(_on_wear_pressed.bind(skin.id))
		row.add_child(wear)
	else:
		var buy := Button.new()
		buy.text = "Buy: %d coins" % skin.price
		# Can't afford it? The button shows the price but won't press.
		buy.disabled = SaveData.wallet < skin.price
		buy.pressed.connect(_on_buy_pressed.bind(skin.id))
		row.add_child(buy)

	$Rows.add_child(row)


func _on_buy_pressed(id: String) -> void:
	var skin: Dictionary = Skins.find(id)
	# spend() only says yes if the wallet covers it.
	if SaveData.spend(skin.price):
		SaveData.own_skin(id)
		SaveData.wear_skin(id)
	_rebuild()


func _on_wear_pressed(id: String) -> void:
	SaveData.wear_skin(id)
	_rebuild()
