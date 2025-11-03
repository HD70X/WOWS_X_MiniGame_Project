extends Control

func _ready():
	# $VBoxContainer/Level_1_Button.pressed.connect(_on_level_1_button_pressed)
	# $BackButton.pressed.connect(_on_back_button_pressed)
	pass

func _on_level_1_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/levelScene_level1.tscn")

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
