extends Area2D

# This signal tells the main scene "I got hit!"
signal hit

# TWEAK ME: how fast the player moves, in pixels per second.
@export var speed: float = 400.0

# TWEAK ME: how long the star's invincibility lasts, in seconds.
@export var invincible_time: float = 3.0

var screen_size: Vector2
var invincible: bool = false
var has_shield: bool = false


func _ready() -> void:
	screen_size = get_viewport_rect().size
	# Wear whichever skin was picked in the shop.
	var skin: Dictionary = Skins.find(SaveData.current_skin)
	$AnimatedSprite2D.modulate = skin.color
	hide()


func _process(delta: float) -> void:
	# Build a direction from whichever keys are held down.
	var velocity: Vector2 = Vector2.ZERO

	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	# Normalizing stops diagonal movement from being faster.
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta
	# Clamp keeps the player on screen.
	position = position.clamp(Vector2.ZERO, screen_size)

	# Face the direction we're moving.
	if velocity.x != 0:
		$AnimatedSprite2D.flip_h = velocity.x < 0


func start(start_position: Vector2) -> void:
	position = start_position
	# A new round always starts with no power-ups.
	invincible = false
	$InvincibilityTimer.stop()
	$AnimatedSprite2D.modulate.a = 1.0
	has_shield = false
	$ShieldRing.hide()
	show()
	$CollisionShape2D.disabled = false


func start_invincibility() -> void:
	invincible = true
	# Go a bit see-through so you can tell it's working.
	$AnimatedSprite2D.modulate.a = 0.5
	# start() also restarts the countdown if we grab a second
	# star while the first one is still going.
	$InvincibilityTimer.start(invincible_time)


func _on_invincibility_timer_timeout() -> void:
	invincible = false
	$AnimatedSprite2D.modulate.a = 1.0


func give_shield() -> void:
	has_shield = true
	$ShieldRing.show()


func _on_body_entered(body: Node2D) -> void:
	# The star is protecting us — ignore the hit.
	if invincible:
		return

	# The shield takes one hit for us, and the fireball
	# that hit it burns up.
	if has_shield:
		has_shield = false
		$ShieldRing.hide()
		body.queue_free()
		return

	hit.emit()
	hide()
	# Deferred because we can't disable a collision shape
	# in the middle of a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
