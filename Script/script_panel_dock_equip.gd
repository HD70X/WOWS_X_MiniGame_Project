# script_panel_dock_equip.gd
extends Panel

# 预设一些按钮组，以便更好的实现点击切换显示效果
var equip_button_group = ButtonGroup.new()
# 预设一些数组，用于临时储存玩家的装备信息，并用于展示，玩家的装配修改将会保存到这些数据中，必要时进行丢弃（还原或者正式储存）
var weapon_instances: Array
var hull_instances: Array
var bridge_instances: Array
var engine_instances: Array
var current_slot: int
var current_equipment_type: String
# 一个临时的装备数据槽，用于储存玩家当前装备物品的信息
var temporary_player_equip: Dictionary

var _equiped_items: Array = []

var equip_type_enum = ["weapon", "bridge", "hull", "engine"]

@onready var equipment_list = $MarginContainer/HBoxContainer/LeftContainer/LeftSection/EquipTabContainer/EquipList

@onready var weapon_slot_1 = $MarginContainer/HBoxContainer/RightContainer/RightSection/HBoxContainer/WeaponSlotGroup/HBoxContainer/BowWeapon
@onready var weapon_slot_2 = $MarginContainer/HBoxContainer/RightContainer/RightSection/HBoxContainer/WeaponSlotGroup/HBoxContainer/MidWeapon
@onready var weapon_slot_3 = $MarginContainer/HBoxContainer/RightContainer/RightSection/HBoxContainer/WeaponSlotGroup/HBoxContainer/RareWeapon
@onready var bridge_slot_1 = $MarginContainer/HBoxContainer/RightContainer/RightSection/HBoxContainer/BridgeSlotGroup/HBoxContainer/BridgeSlot
@onready var hull_slot_1 = $MarginContainer/HBoxContainer/RightContainer/RightSection/HBoxContainer/HullSlotGroup/HBoxContainer/HullSlot
@onready var engine_slot_1 = $MarginContainer/HBoxContainer/RightContainer/RightSection/HBoxContainer/EngineSlotGroup/HBoxContainer/EngineSlot
var _equip_slot: Array = [] 

const ITEM_BUTTON_SCENE = preload("res://Scenes/UI/button_dock_equip_list_item.tscn")

var empty_weapon = {
	"instance_id": "EMPTY_WEAPON_I",
	"template_id": "EMPTY_WEAPON_T",
	"equip_type": ItemUnstackable.ItemType.WEAPON
}

func _ready() -> void:
	_equip_slot = [weapon_slot_1, weapon_slot_2, weapon_slot_3, bridge_slot_1, hull_slot_1, engine_slot_1] 
	# 等待子场景的按钮准备完毕
	await get_tree().process_frame
	# 初始化装备列表和舰船上安装的组件信息（从玩家数据获取）
	reflesh_temporary_player_equip()
	load_inventory()
	load_equip()
	# 初始化舰船槽位按钮信号
	_connect_ship_slot_button()
	# 将安装的组件同布到槽位（之后添加同步到舰船）
	refresh_ship_slot()

# 连接舰船槽位按钮的信号
func _connect_ship_slot_button():
	for btn in get_tree().get_nodes_in_group("dock_ship_slots_group"):
		btn.slot_selected.connect(_on_slot_selected.bind(btn))

# 连接玩家背包内对应装备的按钮信号
func _connect_player_equip_button():
	for btn in get_tree().get_nodes_in_group("dock_player_equip_group"):
		btn.equip_selected.connect(_on_equip_selected)

# 舰船槽位被点击的方法
func _on_slot_selected(slot_index: int, equipment_type: String, button: Node):
	var instance_id = null
	current_slot = slot_index
	current_equipment_type = equipment_type
	# 确定当前的槽位中是否安装了装备, 如果安装了，可以回传实例id，用于标记安装中的装备
	if _equiped_items[slot_index]:
		instance_id = _equiped_items[slot_index].instance_id
	# 首先刷新当前对应类型的装备列表
	refresh_equipment_list(equipment_type, instance_id, button)
	

# 背包物品被点击的方法
func _on_equip_selected(item_template_id: String, item_instance_id: String):
	pass

func reflesh_temporary_player_equip():
	temporary_player_equip = PlayerData.equiped_items

# 检查玩家仓储，获知玩家拥有的道具，并将其中的武器等组件识别出来存入相应的数组中
func load_inventory():
	# 清空列表
	weapon_instances.clear()
	bridge_instances.clear()
	hull_instances.clear()
	engine_instances.clear()
	# 重新读取玩家装备，并将装备实例加入列表
	for item_instance in PlayerData.inventory["unstackable_instances"]:
		# 将获得的装备分类，并将其写入相应的List
		var item_template = ItemDatabase.get_item(item_instance.template_id)
		if item_template.item_Type == ItemUnstackable.ItemType.WEAPON:
			weapon_instances.append(item_instance)
		elif item_template.item_Type == ItemUnstackable.ItemType.BRIDGE:
			bridge_instances.append(item_instance)
		elif item_template.item_Type == ItemUnstackable.ItemType.HULL:
			hull_instances.append(item_instance)
		elif item_template.item_Type == ItemUnstackable.ItemType.ENGINE:
			engine_instances.append(item_instance)
		else:
			pass

# 获取玩家的当前舰船上安装物品，并将实例按照默认顺序存入数组
func load_equip():
	_equiped_items.clear()  # 先清空
	# 按照固定顺序从字典中获取装备
	var slot_order = [
		"weapon_slot_1",
		"weapon_slot_2", 
		"weapon_slot_3",
		"bridge_type",
		"hull_type",
		"engine_type"
	]
	for slot_key in slot_order:
		var instance_id = temporary_player_equip[slot_key]
		if instance_id and instance_id != "":
			var equiped_instance = PlayerData.find_instance(instance_id)
			_equiped_items.append(equiped_instance if equiped_instance else null)
		else:
			_equiped_items.append(null)

# 使用临时的安装装备字典内内容刷新玩家的装备槽显示（后续追加舰船预览显示）
func refresh_ship_slot():
	for i in range(_equiped_items.size()):
		if _equiped_items[i]:
			_equip_slot[i].update_slot(_equiped_items[i])

# 刷新装备列表，更新背包显示
func refresh_equipment_list(equip_type: String, instance_id: String, button: Node):
	# 清理可能的旧节点
	for child in equipment_list.get_children():
		child.queue_free()
	# 添加"卸载"按钮
	var empty_button = Button.new()
	empty_button.text = "Remove"
	empty_button.toggle_mode = true
	empty_button.button_group = equip_button_group
	equipment_list.add_child(empty_button)
	# empty_button.pressed.connect(func(): on_unequip())
	# 确定装备类型展示对应的列表
	if equip_type == equip_type_enum[0]:
		for instance in weapon_instances:
			var instance_button = ITEM_BUTTON_SCENE.instantiate()
			equipment_list.add_child(instance_button)
			instance_button.setup(instance)
			if instance.equiped:
				instance_button.show_equipped_badge()
			if instance_id and instance_id == instance.instance_id:
				instance_button.set_highlight(true)
				# 可选：禁用按钮以防止重复选择
				instance_button.disabled = true
	elif equip_type == equip_type_enum[1]:
		for instance in bridge_instances:
			var instance_button = ITEM_BUTTON_SCENE.instantiate()
			equipment_list.add_child(instance_button)
			instance_button.setup(instance)
			if instance.equiped:
				instance_button.show_equipped_badge()
			if instance_id and instance_id == instance.instance_id:
				instance_button.set_highlight(true)
				# 可选：禁用按钮以防止重复选择
				instance_button.disabled = true
	elif equip_type == equip_type_enum[2]:
		for instance in hull_instances:
			var instance_button = ITEM_BUTTON_SCENE.instantiate()
			equipment_list.add_child(instance_button)
			instance_button.setup(instance)
			if instance.equiped:
				instance_button.show_equipped_badge()
			if instance_id and instance_id == instance.instance_id:
				instance_button.set_highlight(true)
				# 可选：禁用按钮以防止重复选择
				instance_button.disabled = true
	elif equip_type == equip_type_enum[3]:
		for instance in engine_instances:
			var instance_button = ITEM_BUTTON_SCENE.instantiate()
			equipment_list.add_child(instance_button)
			instance_button.setup(instance)
			if instance.equiped:
				instance_button.show_equipped_badge()
			if instance_id and instance_id == instance.instance_id:
				instance_button.set_highlight(true)
				# 可选：禁用按钮以防止重复选择
				instance_button.disabled = true
	button.set_selected(true)
