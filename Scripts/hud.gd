extends CanvasLayer


@onready var inventory_slot_count = %InventoryContainer.get_child_count()

signal inventory_slot_pressed(idx: int)


func _ready() -> void:
	for i in inventory_slot_count:
		var slot_node: Control = get_slot_node(i)
		var tsb: TouchScreenButton = slot_node.get_node(^"TouchScreenButton")
		tsb.shape_centered = false
		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = slot_node.size
		shape.size.y = %InventoryContainer.size.y
		tsb.shape = shape
		tsb.shape_centered = false
		tsb.pressed.connect(func(): inventory_slot_pressed.emit(i))

func display_time(time: float) -> void:
	%TimeLabel.text = "%02d:%02.2f" % [floor(time / 60.0), snapped(fmod(time, 60.0), 0.01)]

func get_slot_node(idx: int) -> Control:
	return %InventoryContainer.get_child(inventory_slot_count - idx - 1)

func display_items_in_inventory(items:Array[Texture2D],item_colors:PackedColorArray)->void:
	for i in inventory_slot_count:
		var slot_node: Control = get_slot_node(i)
		var slot_texturerect: TextureRect = slot_node.get_node(^"TextureRect")
		var slot_empty: bool = i >= items.size()
		slot_texturerect.texture = null if slot_empty else items[i]
		if !slot_empty:
			slot_texturerect.modulate = item_colors[i]
