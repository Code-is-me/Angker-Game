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
var additional_item_data: Dictionary = {}

@onready var hud: CanvasLayer = $CanvasLayer

signal item_pressed(item: Item)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hud.inventory_slot_pressed.connect(on_inventory_slot_pressed)
	time_left = time_limit  # Pada awal  manage time_left to time_limit
	instance = self
	MultiplayerManager.players_spawn_node = $Players

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Setiap frame, kurangi waktu yang tersisa. delta adalah waktu (dalam detik) yang terlewati sejak frame sebelumnya
	time_left -= delta
	if time_left <= 0.0: #if time abis
		get_tree().reload_current_scene() # ulang secne jika waktu habis

func on_inventory_slot_pressed(idx: int) -> void:
	if idx < inventory.size():
		item_pressed.emit(inventory[idx])

func add_item_to_inventory(item: Item, additional_infos: Dictionary = {}) -> void:
	if not (item in inventory):
		inventory.append(item)
		additional_item_data[item] = additional_infos
		update_inventory_hud()

func has_item_in_inventory(item: Item) -> bool:
	return item in inventory

func remove_item_from_inventory(item: Item) -> void:
	
	for i: int in inventory.size():  
		if inventory[i] == item:
			inventory.remove_at(i)
			update_inventory_hud()  
			additional_item_data.erase(item)  
			break

func update_inventory_hud() -> void:
	var slot_textures: Array[Texture2D] = []
	for item: Item in inventory:
		slot_textures.append(load(item_data[item].inv_texture_path))
	hud.display_items_in_inventory(slot_textures)
