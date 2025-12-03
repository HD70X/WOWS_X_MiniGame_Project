extends CharacterBody2D

# 定义舰船的基础属性
var base_speed: float = 200.0
var base_hp: int = 100
var hp: int

# 模块化属性
var equipped_weapons: Array = [] # 储存装备的武器路径
var weapon_nodes: Array = []  # 存储实例化的武器节点
var equipped_hull: String
var equipped_engine: String
var equipped_bridge: String

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
	var equiped_items = PlayerData.equiped_items
	equipped_weapons = [
		equiped_items["weapon_slot_1"],
		equiped_items["weapon_slot_2"],
		equiped_items["weapon_slot_3"]
	]
	equipped_hull = equiped_items["hull_type"]
	equipped_engine = equiped_items["engine_type"]
	equipped_bridge = equiped_items["bridge_type"]

# 计算舰船正确属性
func calculate_stats():
	current_max_hp = base_hp
	current_speed = base_speed
	# 按照安装组件重新计算hp和速度
	if equipped_hull:
		current_max_hp *= 1 + ItemDatabase.get_item(equipped_hull).health_bonus
	if equipped_engine:
		current_speed *= 1 + ItemDatabase.get_item(equipped_engine).speed_bonus
	hp = current_max_hp

# 实例化武器
func instantiate_weapons():
	var weapon_slots = $WeaponSlots.get_children()
	weapon_nodes.clear()
	# 遍历每个武器槽位
	for i in range(weapon_slots.size()):
		if equipped_weapons[i]:
			var temp_weapon_scene = ItemDatabase.get_item(equipped_weapons[i]).scene_path
			var weapon = temp_weapon_scene.instantiate()

			# 挂载到对应槽位
			weapon_slots[i].add_child(weapon)
			weapon_nodes.append(weapon)

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
