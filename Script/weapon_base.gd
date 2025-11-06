extends Node2D
class_name WeaponBase

# 定义武器基础属性
# 可以在编辑器中修改
@export var weapon_name: String = "Base Weapon"
@export var fire_cooldown: float = 0.1 # 武器释放间隔
@export var loading_cooldown: float = 0.3
@export var projector_num_max: int = 3
@export var projectile_scene: PackedScene # 弹药场景
@export var damage: int = 30

# 只能在代码中使用
var can_fire: bool = true
var projector_num: int
var is_loading: bool = false
var animation_player: AnimationPlayer
var projectile_spawn_point: Node2D

# 加载时需要进行的处理（武器弹药上膛之类）
func _ready():
	# 将武器弹药补充到最大值
	projector_num = projector_num_max
	# 检查武器是否拥有动画播放器，如果有，使用动画时长替换发射CD时间
	animation_player = get_node_or_null("AnimationPlayer")
	if animation_player and animation_player.has_animation("weapon_fire"):
		fire_cooldown = animation_player.get_animation("weapon_fire").length
	# 检查是否设置了投射物的生成位置（节点）
	projectile_spawn_point = get_node_or_null("ProjectileSpawnPoint")	

# 发射方法
func fire():
	# 判定是否允许发射,CD或者装填中
	if not can_fire or projector_num <= 0:
		return
	# 确认发射修改发射状态
	can_fire = false
	# 扣除一发弹药
	projector_num -= 1
	# 如果有动画就播放，没有就直接生成投射物
	if animation_player and animation_player.has_animation("weapon_fire"):
		animation_player.play("weapon_fire")
		# 不在这里生成投射物，由动画的函数调用轨道触发
	else:
		spawn_projectile()
	
	# 启动冷却
	await get_tree().create_timer(fire_cooldown).timeout
	can_fire = true
	
	# 如果弹药不满，则尝试启动弹药装填
	if projector_num < projector_num_max and not is_loading:
		start_loading()
	
# 弹药管理
func start_loading():
	is_loading = true
	
	# 循环装填弹药
	while projector_num < projector_num_max:
		# 等待装填时间
		await get_tree().create_timer(loading_cooldown).timeout
		# 装填完成，弹药总数加1
		projector_num += 1
	
	# 循环装填完成，弹药已满
	is_loading = false

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
	# 传递方向信息（如果投射物需要）
	if projectile.has_method("set_direction"):
		# 可以根据武器朝向或玩家输入确定方向
		var direction = Vector2.DOWN  # 深水炸弹默认向下
		projectile.set_direction(direction)
	get_tree().root.add_child(projectile)
