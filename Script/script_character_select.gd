extends Control

@onready var save_list_container = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SaveListContainer
@onready var creat_button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CreatButton
@onready var play_button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PlayButton
@onready var delete_button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/DeleteButton

const SAVE_SLOT_SCENE = preload("res://Scenes/UI/PanelSavesSlot.tscn")

var selected_character_id: int = -1
var save_slots: Array = []

func _ready() -> void:
	play_button.disabled = true
	delete_button.disabled = true
	
	refresh_save_list()

func refresh_save_list():
	# 清空当前列表
	for slot in save_slots:
		slot.queue_free()
	save_slots.clear()
	
	# 重置选中状态
	selected_character_id = -1
	play_button.disabled = true
	delete_button.disabled = true
	
	# 创建存档列表
	var characters = CharacterManager.get_all_character()
	for character_data in characters:
		var save_slot = SAVE_SLOT_SCENE.instantiate()
		save_list_container.add_child(save_slot)

func _on_slot_clicked(character_id: int):
	# 取消所有存档的选中状态
	for slot in save_slots:
		slot.set_selected(false)
	
	# 选中当前存档
	selected_character_id = character_id
	for slot in save_slots:
		if slot.character_id == character_id:
			slot.set_selected(true)
			break
	
	# 启用操作按钮
	play_button.disabled = false
	delete_button.disabled = false

func _on_play_pressed():
	if selected_character_id != -1:
		CharacterManager.select_character(selected_character_id)
		get_tree().change_scene_to_file("res://scenes/main_game.tscn")

func _on_delete_pressed():
	if selected_character_id != -1:
		CharacterManager.delete_character(selected_character_id)
		refresh_save_list()

func _on_create_pressed():
	var new_id = CharacterManager.create_new_character()
	refresh_save_list()
