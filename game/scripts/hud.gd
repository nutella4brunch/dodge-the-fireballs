extends CanvasLayer

signal start_game

# The level sets this from SaveData when it loads. Saving to disk
# is SaveData's job now — the HUD only displays things.
var high_score: int = 0

# TWEAK ME: how fast points pour into the wallet, per second.
@export var bank_rate: float = 40.0

# Points still waiting to be poured into the wallet.
var banking_left: int = 0


func bank_score(amount: int) -> void:
	# Start pouring: one point leaves the score, one coin lands
	# in the wallet, over and over until the score runs dry.
	banking_left = amount
	$BankTimer.start(1.0 / bank_rate)


func finish_banking() -> void:
	# A new round is starting mid-pour — bank the rest instantly
	# so no coins get lost.
	$BankTimer.stop()
	if banking_left > 0:
		SaveData.add_coin(banking_left)
		banking_left = 0


func _on_bank_timer_timeout() -> void:
	if banking_left <= 0:
		$BankTimer.stop()
		return
	banking_left -= 1
	SaveData.add_coin(1)
	update_score(banking_left)


func _exit_tree() -> void:
	# Leaving for the menu mid-pour? You still earned it all.
	finish_banking()


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
