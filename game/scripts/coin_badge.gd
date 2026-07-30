extends PanelContainer

# The always-visible wallet counter at the top of the screen.
# It listens to SaveData, so it updates the moment a coin lands.


func _ready() -> void:
	_show_amount(SaveData.wallet)
	SaveData.wallet_changed.connect(_show_amount)


func _show_amount(coins: int) -> void:
	$Row/Amount.text = str(coins)
