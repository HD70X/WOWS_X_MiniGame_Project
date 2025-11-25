extends Button

#signal  equip_selected(item_id: String)
#var item_id: String

@onready var item_name = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/ItemName
@onready var item_icon = $MarginContainer/HBoxContainer/Control/ItemIcon

func _ready() -> void:
	pass

func setup(item_id: String):
	# item_id = add_item_id
	var item = ItemDatabase.get_item(item_id)
	if item.item_name:
		item_name.text = item.item_name
	else:
		item_name.text = "Unknow Item"
	if item.icon:
		item_icon.texture = item.icon
	else:
		item_name.text = load("res://Art/UI/temp_place_holder_128.png")

#func _on_toggled(toggled_on: bool) -> void:
	#if toggled_on:
		#equip_selected.emit(item_id)
