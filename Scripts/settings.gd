extends CanvasLayer
@onready var sound_effect: Button = %SoundEffect
@onready var music: Button = %Music

func _ready() -> void:
	%Music.button_pressed = SaveManager.music_on
	%SoundEffect.button_pressed = SaveManager.sfx_on

func _on_sound_effect_toggled(toggled_on: bool) -> void:
	SaveManager.sfx_on = toggled_on

func _on_music_toggled(toggled_on: bool) -> void:
	SaveManager.music_on = toggled_on

func close() -> void:
	queue_free()
	SaveManager.save_config_file()
