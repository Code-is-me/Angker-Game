extends PickableInteractibleObject


@export var max_water_volume: float = 4.0
@export var water_amount_per_use: float = 0.75

var available_water_volume: float = 0.0

@rpc("call_local")
func set_water_volume(v: float) -> void:
	available_water_volume = v

func _on_used() -> void:
	for area: Area2D in get_overlapping_areas():
		if area is Bucket:
			var required_wv: float = max_water_volume - available_water_volume
			var available_wv_from_bucket: float = area.take_water_and_get(required_wv)
			set_water_volume.rpc(available_water_volume + available_wv_from_bucket)
			print("Mengisi pel dengan air di ember sebanyak ", available_wv_from_bucket)
			return
	if available_water_volume <= 0.0:
		return
	set_water_volume.rpc(maxf(available_water_volume - water_amount_per_use, 0.0))
	var cleaner: Area2D = load("res://Scenes/cleaner.tscn").instantiate()
	cleaner.global_position = global_position
	GameManager.instance.add_child(cleaner)
