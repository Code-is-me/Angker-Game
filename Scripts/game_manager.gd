class_name GameManager
extends Node2D

enum Item {BROOM, COUNT}
# Time limit (in seconds)
@export var time_limit: float = 150.0
static var instance: GameManager

var item_data: Dictionary = {
	Item.BROOM: {
		"inv_texture_path": "res://icon.svg"
	}
}
# How much time left 
var time_left: float:
	set(value):
		hud.display_time(value)
		time_left = value

var inventory: Array[Item]

@onready var hud: CanvasLayer = $CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_left = time_limit	# Pada awal  manage time_left to time_limit
	instance = self
	MultiplayerManager.players_spawn_node = $Players

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Setiap frame, kurangi waktu yang tersisa. delta adalah waktu (dalam detik) yang terlewati sejak frame sebelumnya
	time_left -= delta
	if time_left <= 0.0: #if time abis 
		get_tree().reload_current_scene() # ulang secne jika waktu habis

func add_item_to_inventory(item: Item) -> void:
	if not (item in inventory):
		inventory.append(item)
		update_inventory_hud()

func has_item_in_inventory(item: Item) -> bool:
	return item in inventory

func update_inventory_hud():
	var slot_textures: Array[Texture2D] = []
	for item in inventory:
		slot_textures.append(load(item_data[item].inv_texture_path))
	hud.display_items_in_inventory(slot_textures)
