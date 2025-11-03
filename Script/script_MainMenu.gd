extends Control

func _ready():
	# $UIControl/MenuVBoxContainer/StartButton.pressed.connect(_on_start_button_pressed)
	# $UIControl/MenuVBoxContainer/LevelChoiceButton.pressed.connect(_on_level_choice_button_pressed)
	# $UIControl/MenuVBoxContainer/SettingButton.pressed.connect(_on_setting_button_pressed)
	# $UIControl/MenuVBoxContainer/ExitButton.pressed.connect(_on_exit_button_pressed)
	pass
func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/levelScene_level1.tscn")

func _on_level_choice_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/LevelChoiceMenu.tscn")

func _on_setting_button_pressed():
	get_tree().paused = true
	get_tree().paused = false

func _on_exit_button_pressed():
	get_tree().quit()
