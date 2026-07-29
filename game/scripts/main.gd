extends Node

# The Fireball scene gets loaded here so we can make copies of it.
@export var fireball_scene: PackedScene
@export var powerup_scene: PackedScene

# TWEAK ME: how quickly the game gets harder.
@export var spawn_speedup: float = 0.985
@export var fastest_spawn: float = 0.25

# TWEAK ME: how many seconds between power-ups.
@export var powerup_every: float = 8.0

# TWEAK ME: how long the snowflake's slow motion lasts, in seconds.
@export var slowmo_time: float = 4.0

var score: int = 0
var base_spawn_time: float = 1.0


func _ready() -> void:
	randomize()
	$HUD.start_game.connect(_on_start_game)
	$Player.hit.connect(_on_player_hit)
	$HUD.show_message("Dodge the Fireballs!")


func new_game() -> void:
	score = 0
	base_spawn_time = 1.0
	$FireballTimer.wait_time = base_spawn_time

	$Player.start($StartPosition.position)
	$StartTimer.start()

	$PowerupTimer.wait_time = powerup_every

	$HUD.update_score(score)
	$HUD.show_message("Get Ready!")

	# Clear any leftovers from the last round.
	get_tree().call_group("fireballs", "queue_free")
	get_tree().call_group("powerups", "queue_free")


func game_over() -> void:
	$ScoreTimer.stop()
	$FireballTimer.stop()
	$PowerupTimer.stop()
	$SlowmoTimer.stop()
	$HUD.show_game_over(score)


func _on_start_game() -> void:
	new_game()


func _on_player_hit() -> void:
	game_over()


func _on_start_timer_timeout() -> void:
	$FireballTimer.start()
	$ScoreTimer.start()
	$PowerupTimer.start()


func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)

	# Every second, fireballs spawn a little faster.
	base_spawn_time = max(base_spawn_time * spawn_speedup, fastest_spawn)
	$FireballTimer.wait_time = base_spawn_time


func _on_fireball_timer_timeout() -> void:
	var fireball := fireball_scene.instantiate()
	fireball.add_to_group("fireballs")

	# Pick a random spot along the path around the screen edge.
	var spawn_location: PathFollow2D = $FireballPath/FireballSpawnLocation
	spawn_location.progress_ratio = randf()

	# Aim roughly toward the middle, with some wobble.
	var direction: float = spawn_location.rotation + PI / 2
	direction += randf_range(-PI / 4, PI / 4)

	fireball.position = spawn_location.position
	fireball.rotation = direction

	var velocity := Vector2(randf_range(fireball.min_speed, fireball.max_speed), 0.0)
	fireball.linear_velocity = velocity.rotated(direction)

	add_child(fireball)


func _on_powerup_timer_timeout() -> void:
	var powerup := powerup_scene.instantiate()
	powerup.add_to_group("powerups")
	powerup.type = ["star", "snowflake"].pick_random()

	# Somewhere random on screen, but not right at the edge.
	var screen_size: Vector2 = get_viewport().get_visible_rect().size
	powerup.position = Vector2(
		randf_range(60, screen_size.x - 60),
		randf_range(60, screen_size.y - 60)
	)

	powerup.grabbed.connect(_on_powerup_grabbed)
	add_child(powerup)


func _on_powerup_grabbed(type: String) -> void:
	match type:
		"star":
			$Player.start_invincibility()
		"snowflake":
			start_slowmo()


func start_slowmo() -> void:
	get_tree().call_group("fireballs", "set_slow", true)
	# start() also restarts the countdown if we grab a second
	# snowflake while the first one is still going.
	$SlowmoTimer.start(slowmo_time)


func _on_slowmo_timer_timeout() -> void:
	get_tree().call_group("fireballs", "set_slow", false)
