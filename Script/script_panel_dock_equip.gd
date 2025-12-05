# script_panel_dock_equip.gd
extends Panel

# 预设一些数组，用于临时储存玩家的装备信息，并用于展示，玩家的装配修改将会保存到这些数据中，必要时进行丢弃（还原或者正式储存）
var weapon_instances: Array
var bridge_instances: Array
var hull_instances: Array
var engine_instances: Array
var save_weapon_instances: Array
var save_bridge_instances: Array
var save_save_hull_instances: Array
var save_engine_instances: Array
# 储存当前控制的槽位相关信息
var current_slot: int
var current_equipment_type: String
var current_queipment_code: int
# 一个临时的装备数据槽，用于储存玩家当前装备物品的信息
var temporary_player_equip: Dictionary
var saved_player_equip: Dictionary
var _equiped_items: Array = []

var equip_type_enum = ["weapon", "bridge", "hull", "engine"]

@onready var equipment_list = $MarginContainer/HBoxContainer/LeftContainer/LeftSection/EquipTabContainer/EquipList
@onready var reset_button = $MarginContainer/HBoxContainer/RightContainer/RightSection/ButtonContainer/ResetButton
@onready var save_button = $MarginContainer/HBoxContainer/RightContainer/RightSection/ButtonContainer/SaveButton

@onready var weapon_slot_1 = $MarginContainer/HBoxContainer/RightContainer/RightSection/HBoxContainer/WeaponSlotGroup/HBoxContainer/BowWeapon
@onready var weapon_slot_2 = $MarginContainer/HBoxContainer/RightContainer/RightSection/HBoxContainer/WeaponSlotGroup/HBoxContainer/MidWeapon
@onready var weapon_slot_3 = $MarginContainer/HBoxContainer/RightContainer/RightSection/HBoxContainer/WeaponSlotGroup/HBoxContainer/RareWeapon
@onready var bridge_slot_1 = $MarginContainer/HBoxContainer/RightContainer/RightSection/HBoxContainer/BridgeSlotGroup/HBoxContainer/BridgeSlot
@onready var hull_slot_1 = $MarginContainer/HBoxContainer/RightContainer/RightSection/HBoxContainer/HullSlotGroup/HBoxContainer/HullSlot
@onready var engine_slot_1 = $MarginContainer/HBoxContainer/RightContainer/RightSection/HBoxContainer/EngineSlotGroup/HBoxContainer/EngineSlot
var _equip_slot: Array = [] 
var slot_order = [
	"weapon_slot_1",
	"weapon_slot_2", 
	"weapon_slot_3",
	"bridge_type",
	"hull_type",
	"engine_type"
]

const ITEM_BUTTON_SCENE = preload("res://Scenes/UI/button_dock_equip_list_item.tscn")
const REMOVE_BUTTON_SCENE = preload("res://Scenes/UI/button_dock_equip_list_remove.tscn")

func _ready() -> void:
	_equip_slot = [weapon_slot_1, weapon_slot_2, weapon_slot_3, bridge_slot_1, hull_slot_1, engine_slot_1] 
	# 等待子场景的按钮准备完毕
	await get_tree().process_frame
	# 初始化装备列表和舰船上安装的组件信息（从玩家数据获取）
	reflesh_temporary_player_equip()
	load_inventory()
	# 将安装的组件同布到槽位（之后添加同步到舰船）
	load_equip()
	refresh_ship_slot()
	# 初始化舰船槽位按钮信号
	_connect_ship_slot_button()
	# 初始化玩家装备按钮
	_connect_player_equip_button()

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
	# print("槽位序号：", slot_index, "装备类型：", equipment_type, "按钮：", button)
	var instance_id: String = ""
	current_slot = slot_index
	current_equipment_type = equipment_type
	var i = 0
	for type in equip_type_enum:
		if type == current_equipment_type:
			current_queipment_code = i
		i += 1
	# 确定当前的槽位中是否安装了装备, 如果安装了，可以回传实例id，用于标记安装中的装备
	if _equiped_items[slot_index]:
		instance_id = _equiped_items[slot_index].instance_id
	# 首先刷新当前对应类型的装备列表
	refresh_equipment_list(current_queipment_code, instance_id)
	# 将当前按钮槽位高亮
	for btn in get_tree().get_nodes_in_group("dock_ship_slots_group"):
		btn.set_selected(false)
	button.set_selected(true)

# 背包物品被点击的方法
func _on_equip_selected(_item_template_id: String, _item_instance_id: String):
	# 首先将当前槽位中的组件移除
	remove_current_equip()
	var temp_eqiup_list = [weapon_instances, bridge_instances, hull_instances, engine_instances]
	for instance in temp_eqiup_list[current_queipment_code]:
		if instance.instance_id == _item_instance_id:
			if instance.equiped == true:
				# 检查目标装备是否已经被安装，如果安装，则需要移动位置（修改字典）
				for slot_key in slot_order:
					if temporary_player_equip[slot_key] == _item_instance_id:
						temporary_player_equip[slot_key] = null
			else: 
				# 没安装，只需要简单标记安装即可
				instance.equiped = true
			temporary_player_equip[slot_order[current_slot]] = _item_instance_id
	# 更新装备信息，将安装的组件同布到槽位（之后添加同步到舰船）
	load_equip()
	refresh_ship_slot()
	# 初始化玩家装备按钮
	refresh_equipment_list(current_queipment_code, _item_instance_id)
	update_reset_button()

# 移除装备方法
func on_unequip():
	# 首先将当前槽位中的组件移除
	remove_current_equip()
	# 更新装备信息，将安装的组件同布到槽位（之后添加同步到舰船）
	load_equip()
	refresh_ship_slot()
	# 初始化玩家装备按钮
	refresh_equipment_list(current_queipment_code, "")
	update_reset_button()

# 刷新玩家临时装备
func reflesh_temporary_player_equip():
	temporary_player_equip = PlayerData.equiped_items.duplicate(true)
	# 同时保存一份作为基准
	saved_player_equip = temporary_player_equip.duplicate(true)

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
	for slot_key in slot_order:
		var instance_id = temporary_player_equip[slot_key]
		if instance_id and instance_id != "":
			var equiped_instance = PlayerData.find_instance(instance_id)
			_equiped_items.append(equiped_instance if equiped_instance else null)
		else:
			_equiped_items.append(null)
	# print("_equiped_items: ", _equiped_items)

# 使用临时的安装装备字典内内容刷新玩家的装备槽显示（后续追加舰船预览显示）
func refresh_ship_slot():
	# print("temporary_player_equip: ", temporary_player_equip)
	for i in range(_equiped_items.size()):
		_equip_slot[i].update_slot(_equiped_items[i])

# 刷新装备列表，更新背包显示
func refresh_equipment_list(equip_type_code: int, instance_id: String = ""):
	# 清理可能的旧节点
	for child in equipment_list.get_children():
		child.queue_free()
	# 添加"卸载"按钮
	var empty_button = REMOVE_BUTTON_SCENE.instantiate()
	equipment_list.add_child(empty_button)
	empty_button.remove_equipment.connect(on_unequip)
	# 确定装备类型展示对应的列表
	var temp_eqiup_list = [weapon_instances, bridge_instances, hull_instances, engine_instances]
	for instance in temp_eqiup_list[equip_type_code]:
		var instance_button = ITEM_BUTTON_SCENE.instantiate()
		equipment_list.add_child(instance_button)
		instance_button.setup(instance)
		if instance.equiped:
			instance_button.show_equipped_badge()
		if instance_id and instance_id == instance.instance_id:
			instance_button.set_highlight(true)
			# 可选：禁用按钮以防止重复选择
			instance_button.disabled = true
	_connect_player_equip_button()

func remove_current_equip():
	# 确定当前的槽位中是否安装了装备
	if _equiped_items[current_slot]:
		# 如果安装
		# 更新临时字典，将该槽位记为空
		temporary_player_equip[slot_order[current_slot]] = null
		# 将组件标记为未装备
		var temp_eqiup_list = [weapon_instances, bridge_instances, hull_instances, engine_instances]
		for instance in temp_eqiup_list[current_queipment_code]:
			if instance.instance_id == _equiped_items[current_slot].instance_id:
				instance.equiped = false

func has_unsaved_changes() -> bool:
	return temporary_player_equip.hash() != saved_player_equip.hash()

func update_reset_button():
	reset_button.disabled = !has_unsaved_changes()
	save_button.disabled = !has_unsaved_changes()


func _on_reset_button_pressed() -> void:
	# 从基准恢复数据
	temporary_player_equip = saved_player_equip.duplicate(true)
	# 重置标记状态
	for item_instance in PlayerData.inventory["unstackable_instances"]:
		item_instance.equiped = false
	for slot_key in slot_order:
		var instance_id = saved_player_equip[slot_key]
		if instance_id:
			var instance = PlayerData.find_instance(instance_id)
			if instance:
				instance.equiped = true
	load_inventory()
	load_equip()
	refresh_ship_slot()
	var mark_instance_id: String
	if _equiped_items[current_slot]:
		mark_instance_id = _equiped_items[current_slot].instance_id
	refresh_equipment_list(current_queipment_code, mark_instance_id)
	update_reset_button()


func _on_save_button_pressed() -> void:
	# 将临时数据写回PlayerData
	PlayerData.equiped_items = temporary_player_equip.duplicate(true)
	# 更新基准
	saved_player_equip = temporary_player_equip.duplicate(true)
	SaveManager.save_game(PlayerData)
	update_reset_button()
