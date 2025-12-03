extends CanvasLayer

signal character_created(character_id)  # 定义信号

func _on_create_button_pressed() -> void:
	var character_name = $Control/MarginContainer/VBoxContainer/InPutName.text
	var new_id = CharacterManager.create_new_character(character_name)
	# 发射信号通知主界面刷新
	character_created.emit(new_id)
	# 关闭弹窗
	hide()
	

func _on_cancel_button_pressed() -> void:
	hide()
