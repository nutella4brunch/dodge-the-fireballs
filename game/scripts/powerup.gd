extends Area2D

# This signal tells the main scene "the player grabbed me!"
# It also says which kind of power-up this was.
signal grabbed(type: String)

# TWEAK ME: how many seconds the power-up waits before vanishing.
@export var lifetime: float = 5.0

# Which power-up this one is. main.gd picks one at random when spawning.
@export_enum("star", "snowflake", "shield", "coin") var type: String = "star"


func _ready() -> void:
	# The scene starts with the star picture, so the
	# other kinds swap it out.
	match type:
		"snowflake":
			$Sprite2D.texture = load("res://assets/powerup_snowflake.svg")
		"shield":
			$Sprite2D.texture = load("res://assets/powerup_shield.svg")
		"coin":
			$Sprite2D.texture = load("res://assets/powerup_coin.svg")

	# Vanish if nobody grabs it in time.
	await get_tree().create_timer(lifetime).timeout
	queue_free()


func _on_area_entered(_area: Area2D) -> void:
	# Only the player can touch us — the collision layers
	# filter out the fireballs.
	grabbed.emit(type)
	queue_free()
