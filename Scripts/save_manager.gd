extends Node


var coins: int = 0:
	set(value):
		coins_changed.emit()
		coins = value

signal coins_changed

const CFG_PATH = "user://config.cfg"
const CF2_PATH = "user://cf2.dat"


func _ready():
	load_config_file()

func load_config_file() -> void:
	var config: ConfigFile = ConfigFile.new()
	var error: int = config.load(CFG_PATH)
	if error != OK:
		if error != ERR_FILE_NOT_FOUND:
			printerr("Error loading config file. Error: " + error_string(error))

	coins = config.get_value("sv", "coins", 800)

func save_config_file():
	var config: ConfigFile = ConfigFile.new()
	config.set_value("sv", "coins", coins)
	var error: int = config.save(CFG_PATH)
	if error != OK:
		printerr("Error saving config file, error: " + error_string(error))
		
func load_cf2() -> Dictionary:
	var default: Dictionary = {"bought_items": {}}
	var file: FileAccess = FileAccess.open(CF2_PATH, FileAccess.READ)
	var open_error: int = FileAccess.get_open_error()
	if open_error != OK:
		if open_error != ERR_FILE_NOT_FOUND:
			printerr("Error loading cf2 file, error: ", error_string(open_error))
		return default
	var dict = file.get_var()
	if typeof(dict) == TYPE_DICTIONARY:
		return dict
	printerr("Invalid cf2 data")
	return default

func save_cf2(dict: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(CF2_PATH, FileAccess.WRITE)
	var open_error: int = FileAccess.get_open_error()
	if open_error != OK:
		printerr("Error saving cf2 file, error: ", error_string(open_error))
		return
	file.store_var(dict)
