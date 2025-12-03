extends Control

@export var character_select_scene: PackedScene
@onready var containue_button = $UIControl/MenuVBoxContainer/ContainueButton

func _ready():
	# $UIControl/MenuVBoxContainer/StartButton.pressed.connect(_on_start_button_pressed)
	# $UIControl/MenuVBoxContainer/LevelChoiceButton.pressed.connect(_on_level_choice_button_pressed)
	# $UIControl/MenuVBoxContainer/SettingButton.pressed.connect(_on_setting_button_pressed)
	# $UIControl/MenuVBoxContainer/ExitButton.pressed.connect(_on_exit_button_pressed)
	# mouse_filter = Control.MOUSE_FILTER_IGNORE
	if FileAccess.file_exists("user://characters/character_def.save"):
		containue_button.disabled = false

func _on_start_button_pressed():
	PlayerData.load_from_dict(SaveManager.load_default())
	get_tree().change_scene_to_file("res://Scenes/Mainmenu/menu_dock.tscn")

func _on_level_choice_button_pressed():
	get_tree().change_scene_to_packed(character_select_scene)

func _on_setting_button_pressed():
	get_tree().paused = true
	get_tree().paused = false

func _on_exit_button_pressed():
	get_tree().quit()
