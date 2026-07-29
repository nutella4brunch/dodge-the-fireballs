extends Area2D

# This signal tells the main scene "I got hit!"
signal hit

# TWEAK ME: how fast the player moves, in pixels per second.
@export var speed: float = 400.0

var screen_size: Vector2


func _ready() -> void:
	screen_size = get_viewport_rect().size
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
	show()
	$CollisionShape2D.disabled = false


func _on_body_entered(_body: Node2D) -> void:
	hit.emit()
	hide()
	# Deferred because we can't disable a collision shape
	# in the middle of a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
