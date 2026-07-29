extends Area2D

# This signal tells the main scene "the player grabbed me!"
signal grabbed

# TWEAK ME: how many seconds the power-up waits before vanishing.
@export var lifetime: float = 5.0


func _ready() -> void:
	# Vanish if nobody grabs it in time.
	await get_tree().create_timer(lifetime).timeout
	queue_free()


func _on_area_entered(_area: Area2D) -> void:
	# Only the player can touch us — the collision layers
	# filter out the fireballs.
	grabbed.emit()
	queue_free()
