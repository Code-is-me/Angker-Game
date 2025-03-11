extends Label


func update_label() -> void:
	text = str(SaveManager.coins)

func _ready() -> void:
	update_label()
	SaveManager.coins_changed.connect(update_label)
