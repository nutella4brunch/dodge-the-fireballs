extends RigidBody2D

# One dodgeball. It bounces off the walls forever — the level
# never cleans balls up, that's the whole point.

# TWEAK ME: how fast a ball can get thrown in.
@export var min_speed: float = 200.0
@export var max_speed: float = 320.0

# TWEAK ME: how much the snowflake slows balls down.
@export var slow_factor: float = 0.5

# TWEAK ME: how much a ball puffs up when it hits a wall (1.0 = not at all).
@export var squish: float = 1.25

# TWEAK ME: how quickly it shrinks back to normal size.
@export var unsquish_speed: float = 8.0

# The game is seen from above, so a ball bouncing "up" off the
# floor comes closer to your eye — we fake that by drawing it
# bigger the higher it is.
# TWEAK ME: how hard the ball springs off the floor.
@export var floor_bounce: float = 260.0

# TWEAK ME: how strongly the pretend gravity pulls it back down.
@export var floor_gravity: float = 400.0

# TWEAK ME: how much bigger the ball looks at the top of a bounce.
@export var bounce_grow: float = 0.35

var slowed: bool = false
var height: float = 0.0        # how far off the floor it is right now
var height_speed: float = 0.0  # how fast it's rising (negative = falling)
var impact_squish: float = 1.0 # extra puff from hitting a wall


func _ready() -> void:
	# Every ball comes in with its own little spin...
	$Sprite2D.rotation = randf_range(0, TAU)
	angular_velocity = randf_range(-2.0, 2.0)
	# ...and its own first hop, so they don't bounce in unison.
	height_speed = floor_bounce * randf_range(0.3, 1.0)


func _process(delta: float) -> void:
	# Pretend up-and-down physics: gravity pulls, the floor pushes back.
	height_speed -= floor_gravity * delta
	height += height_speed * delta
	if height <= 0.0:
		height = 0.0
		# Each hop is a little different, so the ball lands
		# in a new spot every time as it travels.
		height_speed = floor_bounce * randf_range(0.7, 1.3)

	# The highest a normal hop can reach (a physics classic: v²/2g).
	var peak := floor_bounce * floor_bounce / (2.0 * floor_gravity)
	var size := 1.0 + bounce_grow * height / peak

	# The wall-hit puff fades back to nothing over time. lerpf()
	# moves a little of the way there every frame — springy.
	impact_squish = lerpf(impact_squish, 1.0, unsquish_speed * delta)

	$Sprite2D.scale = Vector2.ONE * size * impact_squish


func _on_body_entered(_body: Node) -> void:
	# Puff up on wall impact — it reads as "boing".
	impact_squish = squish


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
