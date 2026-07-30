extends Node

# The Dodgeball level. Balls bounce off the walls and NEVER go
# away, so the gym slowly fills up until there's nowhere to stand.
signal finished(score: int)

# The Ball scene gets loaded here so we can make copies of it.
@export var ball_scene: PackedScene
@export var powerup_scene: PackedScene

# TWEAK ME: how often a new ball gets thrown in, in seconds.
@export var ball_every: float = 4.0

# TWEAK ME: the most balls allowed at once, so the game stays smooth.
@export var max_balls: int = 50

# TWEAK ME: how many seconds between power-ups.
@export var powerup_every: float = 8.0

# TWEAK ME: how long the snowflake's slow motion lasts, in seconds.
@export var slowmo_time: float = 4.0

# TWEAK ME: how many points a coin is worth.
@export var coin_points: int = 10

var score: int = 0


func _ready() -> void:
	randomize()
	$HUD.start_game.connect(_on_start_game)
	$Player.hit.connect(_on_player_hit)
	$HUD.high_score = SaveData.get_best("dodgeball")
	$HUD.show_message("Dodgeball!")


func new_game() -> void:
	score = 0
	$BallTimer.wait_time = ball_every
	$PowerupTimer.wait_time = powerup_every

	$Player.start($StartPosition.position)
	$StartTimer.start()

	$HUD.update_score(score)
	$HUD.show_message("Get Ready!")

	# Clear any leftovers from the last round.
	get_tree().call_group("balls", "queue_free")
	get_tree().call_group("powerups", "queue_free")


func game_over() -> void:
	$ScoreTimer.stop()
	$BallTimer.stop()
	$PowerupTimer.stop()
	$SlowmoTimer.stop()
	$HUD.show_game_over(score)
	# Report the run to the console, which banks the coins,
	# saves the best, and unlocks.
	finished.emit(score)


func _on_start_game() -> void:
	new_game()


func _on_player_hit() -> void:
	$HitSound.play()
	game_over()


func _on_start_timer_timeout() -> void:
	$BallTimer.start()
	$ScoreTimer.start()
	$PowerupTimer.start()


func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)


func _on_ball_timer_timeout() -> void:
	# A full gym is full — stop throwing balls in.
	if get_tree().get_nodes_in_group("balls").size() >= max_balls:
		return

	var ball := ball_scene.instantiate()
	ball.add_to_group("balls")

	# Throw it in from the top, aimed somewhere downward.
	ball.position = Vector2(randf_range(40, 440), 30)
	var direction := randf_range(PI / 4, 3 * PI / 4)
	var speed := randf_range(ball.min_speed, ball.max_speed)
	ball.linear_velocity = Vector2(speed, 0).rotated(direction)

	add_child(ball)


func _on_powerup_timer_timeout() -> void:
	var powerup := powerup_scene.instantiate()
	powerup.add_to_group("powerups")
	powerup.type = ["star", "snowflake", "shield", "coin"].pick_random()

	# Somewhere random on screen, but not right at the edge.
	var screen_size: Vector2 = get_viewport().get_visible_rect().size
	powerup.position = Vector2(
		randf_range(60, screen_size.x - 60),
		randf_range(60, screen_size.y - 60)
	)

	powerup.grabbed.connect(_on_powerup_grabbed)
	add_child(powerup)


func _on_powerup_grabbed(type: String) -> void:
	$PickupSound.play()
	match type:
		"star":
			$Player.start_invincibility()
		"snowflake":
			start_slowmo()
		"shield":
			$Player.give_shield()
		"coin":
			# Free points — and points become coins when the run ends.
			score += coin_points
			$HUD.update_score(score)


func start_slowmo() -> void:
	get_tree().call_group("balls", "set_slow", true)
	$SlowmoTimer.start(slowmo_time)


func _on_slowmo_timer_timeout() -> void:
	get_tree().call_group("balls", "set_slow", false)
