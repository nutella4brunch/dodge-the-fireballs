extends Node

# THE SHOP SHELF. Every skin you can wear, with its price in coins.
# Adding a skin = one more line. The color tints the player sprite.
var all_skins := [
	{"name": "Classic", "id": "classic", "price": 0, "color": Color(1.0, 1.0, 1.0)},
	{"name": "Sunny", "id": "sunny", "price": 10, "color": Color(1.0, 0.85, 0.4)},
	{"name": "Frosty", "id": "frosty", "price": 25, "color": Color(0.6, 0.85, 1.0)},
	{"name": "Shadow", "id": "shadow", "price": 50, "color": Color(0.45, 0.4, 0.6)},
]


func find(id: String) -> Dictionary:
	for skin in all_skins:
		if skin.id == id:
			return skin
	# Unknown skin? Fall back to the first one so the game
	# never crashes over a missing costume.
	return all_skins[0]
