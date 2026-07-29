extends RigidBody2D

# TWEAK ME: the slowest and fastest a fireball can travel.
@export var min_speed: float = 150.0
@export var max_speed: float = 350.0

# TWEAK ME: how much the snowflake slows fireballs down.
@export var slow_factor: float = 0.5

var slowed: bool = false


func set_slow(slow: bool) -> void:
	# The "slowed" check matters: fireballs that appear during
	# slow motion never got slowed, so they must not get a
	# speed boost when it ends.
	if slow and not slowed:
		slowed = true
		linear_velocity *= slow_factor
		# A blue tint so you can see which ones are slowed.
		$AnimatedSprite2D.modulate = Color(0.7, 0.85, 1.0)
	elif not slow and slowed:
		slowed = false
		linear_velocity /= slow_factor
		$AnimatedSprite2D.modulate = Color(1, 1, 1)


func _ready() -> void:
	# Spin the flame sprite so they don't all look identical.
	$AnimatedSprite2D.rotation = randf_range(0, TAU)
	# Vary the size a little, too.
	var scale_factor: float = randf_range(0.8, 1.3)
	$AnimatedSprite2D.scale = Vector2(scale_factor, scale_factor)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# Clean up fireballs once they leave the screen,
	# otherwise they pile up forever and the game slows down.
	queue_free()
