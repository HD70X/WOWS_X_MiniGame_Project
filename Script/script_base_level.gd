extends Node2D

var submarine_scene = preload("res://Scenes/Enemy/enemySubmaraine.tscn")
var spawn_timer = 0
var spawn_interval = 3.0  # 每3秒生成一艘潜艇
var score = 0
var vectory_score = 1000

@onready var score_label = $HUDCanvasLayer/ScoreLabel

func _ready():
	# 确保舰船在"player"组中
	$ShipCharacterNode.add_to_group("player")
	
	# 连接hp变化信号，关联到函数
	$ShipCharacterNode.hp_changed.connect(_on_ship_hp_changed)
	# 连接舰船被摧毁信号
	$ShipCharacterNode.ship_destroyed.connect(_on_ship_destroyed)
	
	# 初始换舰船hp显示
	$HUDCanvasLayer/ShipHPProgressBar.max_value = $ShipCharacterNode.current_max_hp
	$HUDCanvasLayer/ShipHPProgressBar.value = $ShipCharacterNode.hp
	
	update_score_display()

func _process(delta):
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_submarine()
		spawn_timer = 0

func spawn_submarine():
	var submarine = submarine_scene.instantiate()
	submarine.position.y = randf_range(500, 900)  # 设置潜艇的深度位置
	add_child(submarine)
	# 在添加后立即连接信号
	submarine.sub_destroyed.connect(_on_submarine_destroyed)
	return submarine

# 更新舰船的hp条显示
func _on_ship_hp_changed(new_hp):
	$HUDCanvasLayer/ShipHPProgressBar.value = new_hp

# 如果舰船被摧毁，使用失败结束界面
func _on_ship_destroyed():
	# 游戏结束弹窗
	$GameOverUI.show_defeat(score)

# 如果潜艇被摧毁进行加分，如果加分结果大于关卡需求，则关卡胜利
func _on_submarine_destroyed(score_value):
	score += score_value
	update_score_display()
	# 胜利检查
	if score >= vectory_score:
		$GameOverUI.show_victory(score)

# 刷新分数显示
func update_score_display():
	score_label.text = "Score: " + str(score)

# 如果玩家使用ESC案件，则呼叫出暂停菜单
func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC键
		$PanelPuse.show_puse()
