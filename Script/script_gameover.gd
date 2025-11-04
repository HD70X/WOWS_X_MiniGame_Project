extends CanvasLayer

@onready var victory_container = $ColorRect/Panel/VictoryContainer
@onready var defeat_container = $ColorRect/Panel/DefeatContainer

func _ready():
	# 初始隐藏弹窗
	hide()
	victory_container.hide()
	defeat_container.hide()
	
	# 按钮信号
	$ColorRect/Panel/DefeatContainer/RetryButton.pressed.connect(_on_retry_button_pressed)
	$ColorRect/Panel/DefeatContainer/BackButton.pressed.connect(_on_back_button_pressed)
	$ColorRect/Panel/VictoryContainer/BackButton.pressed.connect(_on_back_button_pressed)

func show_victory(score: int):
	defeat_container.hide()
	victory_container.show()
	# 使用Score更新界面信息
	var rewards = PlayerData.complete_battle(score)
	victory_container.get_node("ScoreLabel").text = "Score: %d" % score
	victory_container.get_node("ExpBoxContainer/ExperienceLabel").text = "Exp: %d" % rewards["experience"]
	victory_container.get_node("CreditsBoxContainer/CreditsLabel").text = "Credits: %d" % rewards["credits"]
	show()
	# 暂停游戏
	get_tree().paused = true

func show_defeat(score: int):
	defeat_container.show()
	victory_container.hide()
	# 使用Score更新界面信息
	victory_container.get_node("ScoreLabel").text = "Score: %d" % score
	show()
	# 暂停游戏
	get_tree().paused = true

func _on_retry_button_pressed():
	# 重新加载当前场景
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_back_button_pressed():
	get_tree().paused = false
	# 如果有主菜单
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
