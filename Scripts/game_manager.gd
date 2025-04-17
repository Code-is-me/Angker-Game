class_name GameManager
extends Node2D


enum Item {BROOM, MOP, COUNT}
# Time limit (in seconds)
@export var time_limit: float = 150.0
static var instance: GameManager
var time_left_at_sync: float = 0.0
var msec_ticks_at_sync: int = 0

var item_data: Dictionary = {
	Item.BROOM: {
		"inv_texture_path": "res://icon.svg"
	},
	Item.MOP: {
		"inv_texture_path": "res://icon.svg",
		"inv_texture_color": Color.YELLOW
	}
}
var inventory: Array[Item]
var additional_item_data: Dictionary = {}
# How much time left 
var time_left: float:
	set(value):
		hud.display_time(value)
		time_left = value
		var time_left_at_sync: float = 0.0
		var msec_ticks_at_sync: int = 0



@onready var hud: CanvasLayer = $CanvasLayer

signal item_pressed(item: Item)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hud.inventory_slot_pressed.connect(on_inventory_slot_pressed)
	time_left = time_limit  # Pada awal  manage time_left to time_limit
	instance = self
	MultiplayerManager.players_spawn_node = $Players
	if multiplayer.is_server():
		sync_time_left.rpc(time_limit, false)
		var sync_tl_timer: Timer = Timer.new()
		add_child(sync_tl_timer)
		sync_tl_timer.timeout.connect(func(): sync_time_left.rpc(time_left, true))
		sync_tl_timer.start(1.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	time_left = maxf(time_left_at_sync - (Time.get_ticks_msec() - msec_ticks_at_sync) * 0.001, 0.0)
	if multiplayer.is_server():
			if time_left <= 0.0:
				game_over.rpc()

@rpc("call_local", "reliable")
func game_over() -> void:
	get_tree().reload_current_scene() # Right now we just reload the scene when the game is over.

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
	var colors: PackedColorArray = []
	for item: Item in inventory:
		slot_textures.append(load(item_data[item].inv_texture_path))
		colors.append(item_data[item].get("inv_texture_color", Color.WHITE))
	hud.display_items_in_inventory(slot_textures, colors)

@rpc("call_local", "reliable")
func sync_time_left(tl: float, smooth: bool) -> void:
	var current_msec_ticks: int = Time.get_ticks_msec()
	if smooth:
		var tween: Tween = create_tween()
		tween.set_parallel()
		tween.tween_property(self, ^"time_left_at_sync", tl, 0.5)
		tween.tween_property(self, ^"msec_ticks_at_sync", current_msec_ticks, 0.5)
	else:
		time_left_at_sync = tl
		msec_ticks_at_sync = current_msec_ticks
