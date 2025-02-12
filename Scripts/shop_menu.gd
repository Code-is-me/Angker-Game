extends Control

var bought_items: Dictionary
var shop_items: Dictionary = {
	"costume": [
		{
			"id": 0,
			"name": "Bakso",
			"texture": null,
			"price": 200
		},
		{
			"id": 1,
			"name": "WPDH Sh",
			"texture": null,
			"price": 300
		},
		{
			"id": 2,
			"name": "19EN CI",
			"texture": null,
			"price": 375
		},
	],
	"mop": [
		{
			"id": 0,
			"name": "MOP3",
			"texture": null,
			"price": 120
		},
		{
			"id": 1,
			"name": "TsMop",
			"texture": null,
			"price": 750
		},
	],
	"screwdriver": [
		{
			"id": 0,
			"name": "ScrewDriver",
			"texture": null,
			"price": 100
		},
	],
	"bucket": [
		{
			"id": 0,
			"name": "Bucket of w82ebd",
			"texture": null,
			"price": 112
		},
	],
	"hammer": [
		{
			"id": 0,
			"name": "Palu",
			"texture": null,
			"price": 432
		},
	],
	"lamp": [
		{
			"id": 0,
			"name": "Flashlight",
			"texture": null,
			"price": 400
		},
	]
}

var selected_tab_idx: int = 0

const TAB_MAPPING: PackedStringArray = ["costume", "mop", "screwdriver", "bucket", "hammer", "lamp"]
@onready var tab_container: HBoxContainer = $MarginContainer/VSplitContainer/TopBarBG/TabContainer
@onready var grid_container: GridContainer = $MarginContainer/VSplitContainer/ColorRect2/ScrollContainer/GridContainer


func _ready():
	bought_items = SaveManager.load_cf2().get("bought_items", {})
	for i: int in tab_container.get_child_count():
		var button: Button = tab_container.get_child(i)
		button.toggle_mode = true
		button.button_pressed = false
		button.pressed.connect(change_to_tab.bind(i))

	change_to_tab(0)


func update_tab_button_pressed_status() -> void:
	for i in tab_container.get_child_count():
		var button: Button = tab_container.get_child(i)
		button.button_pressed = i == selected_tab_idx
		

func change_to_tab(tab_idx: int) -> void:
	selected_tab_idx = tab_idx
	update_tab_button_pressed_status()

	for child in grid_container.get_children():
		child.queue_free()

	var tab: String = TAB_MAPPING[tab_idx]
	var current_shop_item_list: Array = shop_items[tab]

	for i in current_shop_item_list.size():
		var current_item_data: Dictionary = current_shop_item_list[i]
		var shop_item: Control = preload("res://Scenes/shop_item.tscn").instantiate()
		
		shop_item.get_node("TextureRect").texture = current_item_data.texture
		shop_item.get_node("Label").text = current_item_data.name
		var buy_button: Button = shop_item.get_node("Button")
		update_buy_button(buy_button, is_item_bought(tab, current_item_data.id), current_item_data.price) 
		buy_button.pressed. connect(buy_item.bind(tab, current_item_data.id, shop_item))

		grid_container.add_child(shop_item)

func back_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	
func is_item_bought(tab: String, id: int) -> bool:
	if not bought_items.has(tab):
		return false
	return id in bought_items[tab]

func find_item_data_by_id(tab: String, id: int) -> Dictionary:
	var items_in_tab: Array = shop_items.get(tab, [])
	for item in items_in_tab:
		if item.id == id:
			return item
	return {}

func buy_item(tab: String, id: int, shop_item_control: Control) -> void:
	var item_data: Dictionary = find_item_data_by_id(tab, id)
	if item_data.is_empty():
		printerr("Can't find item with id '%d' in tab '%s'" % [id, tab])
		return

	var price: int = item_data.price
	if SaveManager.coins >= price:
		SaveManager.coins -= price
		if not bought_items.has(tab):
			bought_items[tab] = []

		bought_items[tab].append(id)
		var cf2: Dictionary = SaveManager.load_cf2()
		SaveManager.save_config_file()
		cf2.bought_items = bought_items
		SaveManager.save_cf2(cf2)
		update_buy_button(shop_item_control.get_node("Button"), true)

func update_buy_button(button: Button, item_bought: bool, price: int = 0) -> void:
	button.disabled = item_bought
	if item_bought:
		button.text = "√"
	else:
		button.text = "%d Coins" % price
