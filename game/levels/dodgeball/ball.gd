extends RigidBody2D

# One dodgeball. It bounces off the walls forever — the level
# never cleans balls up, that's the whole point.

# TWEAK ME: how fast a ball can get thrown in.
@export var min_speed: float = 200.0
@export var max_speed: float = 320.0

# TWEAK ME: how much the snowflake slows balls down.
@export var slow_factor: float = 0.5

# TWEAK ME: how much a ball puffs up when it bounces (1.0 = not at all).
@export var squish: float = 1.25

# TWEAK ME: how quickly it shrinks back to normal size.
@export var unsquish_speed: float = 8.0

var slowed: bool = false


func _ready() -> void:
	# Every ball comes in with its own little spin.
	$Sprite2D.rotation = randf_range(0, TAU)
	angular_velocity = randf_range(-2.0, 2.0)


func _process(delta: float) -> void:
	# After a bounce, ease back down to normal size. lerp() moves
	# a little of the way there every frame, which looks springy.
	$Sprite2D.scale = $Sprite2D.scale.lerp(Vector2.ONE, unsquish_speed * delta)


func _on_body_entered(_body: Node) -> void:
	# Puff up on impact — it reads as "boing".
	$Sprite2D.scale = Vector2(squish, squish)


func set_slow(slow: bool) -> void:
	# Same guard as the fireballs: only the balls that actually
	# slowed down get their speed back when time's up.
	if slow and not slowed:
		slowed = true
		linear_velocity *= slow_factor
		$Sprite2D.modulate = Color(0.7, 0.85, 1.0)
	elif not slow and slowed:
		slowed = false
		linear_velocity /= slow_factor
		$Sprite2D.modulate = Color(1, 1, 1)
