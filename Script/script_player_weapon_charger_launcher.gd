extends WeaponBase

# 创建投射物
func spawn_projectile():
	# 检测是否存在投射物场景
	if projectile_scene == null:
		return
	# 创建投射物实体，但尚未加入场景树
	var projectile = projectile_scene.instantiate()
	# 计算生成位置
	var spawn_offset = Vector2.ZERO
	if projectile_spawn_point:
		spawn_offset = projectile_spawn_point.position
	projectile.global_position = global_position + spawn_offset
	## 传递方向信息（如果投射物需要）
	#if projectile.has_method("set_direction"):
		## 可以根据武器朝向或玩家输入确定方向
		#var direction = Vector2.DOWN  # 深水炸弹默认向下
		#projectile.set_direction(direction)
	# 给投射物（深水炸弹）添加初始的速度
	if projectile is RigidBody2D:
		# 设置初始速度
		projectile.linear_velocity = Vector2(0,-200)
	get_tree().root.add_child(projectile)
