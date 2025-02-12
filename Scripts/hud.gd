extends CanvasLayer

func display_time(time: float)-> void:
	%TimeLabel.text = "Remaining Time " +str(floor(time/60.0)) +":"+str(snapped(fmod(time, 60.0), 0.01)).pad_zeros(2).pad_decimals(2)

func display_items_in_inventory(items: Array[Texture2D]) -> void:
	var slot_nodes: Array[Node] = %InventoryContainer.get_children()
	for i in slot_nodes.size():
		var slot_texturerect = slot_nodes[i].get_node("TextureRect")
		slot_texturerect.texture = null if i >= items.size() else items[i]
