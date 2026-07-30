extends CanvasLayer

signal start_game

# The level sets this from SaveData when it loads. Saving to disk
# is SaveData's job now — the HUD only displays things.
var high_score: int = 0


func show_message(text: String) -> void:
	$Message.text = text
	$Message.show()
	$MessageTimer.start()


func update_score(value: int) -> void:
	$ScoreLabel.text = str(value)


func show_game_over(final_score: int) -> void:
	if final_score > high_score:
		high_score = final_score
		show_message("New Best: %d!" % final_score)
	else:
		show_message("Game Over")

	# Wait for the message to finish before showing the title.
	await $MessageTimer.timeout

	$Message.text = "Dodge the Fireballs!"
	$Message.show()

	$HighScoreLabel.text = "Best: %d" % high_score
	$HighScoreLabel.show()

	# A short pause so the player doesn't restart by accident.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()


func _on_start_button_pressed() -> void:
	$StartButton.hide()
	$HighScoreLabel.hide()
	start_game.emit()


func _on_message_timer_timeout() -> void:
	$Message.hide()


func _unhandled_input(event: InputEvent) -> void:
	# Let the player hit Space instead of clicking the button.
	if event.is_action_pressed("start_game") and $StartButton.visible:
		_on_start_button_pressed()
