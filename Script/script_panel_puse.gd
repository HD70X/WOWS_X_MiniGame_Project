extends CanvasLayer

func _ready():
	# 初始隐藏弹窗
	hide()
	$ColorRect/Panel/VBoxContainer/ContinueButton.pressed.connect(_on_continue_button_pressed)
	$ColorRect/Panel/VBoxContainer/RetryButton.pressed.connect(_on_retry_button_pressed)
	$ColorRect/Panel/VBoxContainer/BackButton.pressed.connect(_on_back_button_pressed)

func show_puse():
	# 显示弹窗
	show()
	# 暂停游戏
	get_tree().paused = true

func _on_continue_button_pressed():
	# 重新加载当前场景
	get_tree().paused = false
	hide()

func _on_retry_button_pressed():
	# 重新加载当前场景
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_back_button_pressed():
	get_tree().paused = false
	# 如果有主菜单
	get_tree().change_scene_to_file("res://Scenes/Mainmenu/MainMenu.tscn")
