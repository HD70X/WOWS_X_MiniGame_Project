extends Area2D

var speed = 50
var direction = 1  # 1向右，-1向左
var torpedo_scene = preload("res://Scenes/Enemy/EnemyWeapon/projectorEnemyTorpedo.tscn")
var shoot_cooldown = 2.0  # 发射间隔
var can_shoot_topedo = true
var hp = 2
var sub_score = 100

signal sub_destroyed(score_value)

func _ready():
	add_to_group("submarine")
	body_entered.connect(_on_body_entered_sub)
	$TextureProgressBar.max_value = hp
	$TextureProgressBar.value = hp
	# 随机从左或右出现
	if randf() > 0.5:
		position.x = 0
		direction = 1
		$Sprite2D.flip_h = false # 向右移动，不翻转
	else:
		position.x = get_viewport_rect().size.x
		direction = -1
		$Sprite2D.flip_h = true # 向左移动，翻转精灵

func _physics_process(delta):
	# 水平移动
	position.x += speed * direction * delta
	
	# 检测是否在舰船下方
	check_and_shoot()
	
	# 超出屏幕则删除
	if position.x < -100 or position.x > get_viewport_rect().size.x + 100:
		queue_free()

func check_and_shoot():
	var ship = get_tree().get_first_node_in_group("player")
	if ship and can_shoot_topedo:
		# 检测潜艇是否在舰船正下方（允许一定误差范围）
		if abs(position.x - ship.position.x) < 50:
			shoot_torpedo()

func shoot_torpedo():
	can_shoot_topedo = false
	var torpedo = torpedo_scene.instantiate()
	
	# 根据方向调整发射位置（从船头发射）
	var offset = 130  # 船头偏移距离
	torpedo.position = position + Vector2(offset * direction, 0)
	torpedo.direction = direction
	
	get_parent().add_child(torpedo)
	
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot_topedo = true

func take_damage_sunmarine(damage):
	hp -= 1
	$TextureProgressBar.value = hp
	if hp <= 0:
		sub_destroyed.emit(sub_score)
		queue_free() #潜艇被摧毁

func _on_body_entered_sub(body):
	if body.is_in_group("depth_charge"):
		take_damage_sunmarine(1)
		body.queue_free()
