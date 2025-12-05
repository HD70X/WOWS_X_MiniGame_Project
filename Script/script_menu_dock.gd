extends Control

func _on_play_pressed() -> void:
	print("Yes")
	get_tree().change_scene_to_file("res://Scenes/Mainmenu/LevelChoiceMenu.tscn")
