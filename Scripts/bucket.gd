class_name Bucket
extends PickableInteractibleObject


@export var max_water: float = 50.0

var remaining_water_volume: float = max_water


func take_water_and_get(volume: float) -> float:
	var rem: float = minf(volume, remaining_water_volume)
	take_water.rpc(volume)
	return rem

@rpc("call_local")
func take_water(v: float) -> void:
	remaining_water_volume = maxf(remaining_water_volume - v, 0.0)
