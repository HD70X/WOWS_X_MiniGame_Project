extends CharacterBody2D

# 定义舰船的基础属性
var base_speed: float = 200.0
var base_hp: int = 100
var hp: int

# 模块化属性
var equipped_weapons: Array = [] # 储存装备的武器路径
var weapon_nodes: Array = []  # 存储实例化的武器节点
var equipped_defense: Node = null
var equipped_engine: Node = null

# 计算后的属性
var current_max_hp: int
var current_speed: float

# 需要发出的信号
signal hp_changed(new_hp)
signal ship_destroyed

func _ready():
	add_to_group("player")
	load_equipment_from_config()
	calculate_stats()
	instantiate_weapons()

# 从全局配置中读取玩家的装备
func load_equipment_from_config():
	# 从全局配置（PlayerData 单例）读取玩家在船坞中配置的装备
	equipped_weapons = PlayerData.equipped_weapons
	equipped_hull = PlayerData.equipped_hull
	equipped_engine = PlayerData.equipped_engine
	equipped_bridge = PlayerData.equipped_bridge

# 计算舰船正确属性
func calculate_stats():
	current_max_hp = base_hp
	current_speed = base_speed
	# 如果安装了组件，按照安装组件重新计算hp和速度
	if equipped_defense:
		current_max_hp += equipped_defense.hp_bonus
	if equipped_engine:
		current_speed *= equipped_engine.speed_multiplier
	hp = current_max_hp

# 实例化武器
func instantiate_weapons():
	# 在武器槽位置实例化武器
	var weapon_slots = $WeaponSlots.get_children()
	weapon_nodes.clear()
	
	for i in range(min(equipped_weapons.size(), weapon_slots.size())):
		var weapon_scene = load(equipped_weapons[i])
		# 将equipped_weapons中的组件创建为临时实例weapon
		var weapon = weapon_scene.instantiate()
		# 将实例写入slots
		weapon_slots[i].add_child(weapon)
		weapon_nodes.append(weapon) # 这里将武器添加到数组中

# 每时刻需要进行的运算
func _physics_process(delta):
	# 重置水平速度
	velocity.x = 0
	
	# 检测输入
	if Input.is_action_pressed("ui_left"):
		velocity.x = -current_speed
	if Input.is_action_pressed("ui_right"):
		velocity.x = current_speed
	# 应用移动
	move_and_slide()
	# 简化的发射逻辑
	if Input.is_action_just_pressed("ui_select"):
		fire_all_weapons()

func fire_all_weapons():
	for weapon in weapon_nodes:
		if weapon.has_method("fire"):
			weapon.fire()

func take_damage(damage):
	hp -= damage
	hp_changed.emit(hp)
	if hp <= 0:
		die()

func die():
	ship_destroyed.emit()
	queue_free() # 销毁舰船
