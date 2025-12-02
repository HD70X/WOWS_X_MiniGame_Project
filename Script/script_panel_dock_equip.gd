extends Panel

# 预设一些按钮组，以便更好的实现点击切换显示效果
var equip_button_group = ButtonGroup.new()
# 预设一些数组，用于储存玩家的装备信息，并用于展示
var weapon_instances: Array
var hull_instances: Array
var bridge_instances: Array
var engine_instances: Array
var instance_list_array : Array = [weapon_instances, bridge_instances, hull_instances, engine_instances]
var current_slot: int
var current_equipment_type: String

var equip_type_enum = ["weapon", "bridge", "hull", "engine"]

@onready var equipment_list = $MarginContainer/HBoxContainer/LeftContainer/LeftSection/EquipTabContainer/EquipList

const ITEM_BUTTON_SCENE = preload("res://Scenes/UI/button_dock_equip_list_item.tscn")

var empty_weapon = {
	"instance_id": "EMPTY_WEAPON_I",
	"template_id": "EMPTY_WEAPON_T",
	"equip_type": ItemUnstackable.ItemType.WEAPON
}

func _ready() -> void:
	# 等待子场景的按钮准备完毕
	await get_tree().process_frame

# 连接舰船槽位按钮的信号
func _connect_ship_slot_button():
	for btn in get_tree().get_nodes_in_group("dock_ship_slots_group"):
		btn.slot_selected.connect(_on_slot_selected)

# 连接玩家背包内对应装备的按钮信号
func _connect_player_equip_button():
	for btn in get_tree().get_nodes_in_group("dock_player_equip_group"):
		pass
		# btn.slot_selected.connect()

func _on_slot_selected(slot_index: int, equipment_type: String):
	current_slot = slot_index
	current_equipment_type = equipment_type

func _on_equip_selected(item_template_id: String, item_instance_id: String):
	pass

# 检查玩家仓储，获知玩家拥有的道具，并将其中的武器等组件识别出来存入相应的数组中
func load_inventory():
	# 清空列表
	for instance_list in instance_list_array:
		for item in instance_list:
			item.queue_free()
		instance_list.clear()
	# 重新读取玩家装备，并将装备实例加入列表
	for item_instance in PlayerData.inventory["unstackable_instances"]:
		# 将获得的装备分类，并将其写入相应的List
		if item_instance.ItemType == ItemUnstackable.ItemType.WEAPON:
			weapon_instances.append(item_instance)
		elif item_instance.ItemType == ItemUnstackable.ItemType.BRIDGE:
			bridge_instances.append(item_instance)
		elif item_instance.ItemType == ItemUnstackable.ItemType.HULL:
			hull_instances.append(item_instance)
		elif item_instance.ItemType == ItemUnstackable.ItemType.ENGINE:
			engine_instances.append(item_instance)
		else:
			pass

# 将玩家的装备显示在列表中

# 通用方法，利用数组中的数据刷新UI的列表
func refresh_instance_list(instances_list: Array):
	# 清理可能的旧节点
	for child in equipment_list.get_children():
		child.queue_free()
	# 添加"卸载"按钮
	var empty_button = Button.new()
	empty_button.text = "Remove"
	empty_button.toggle_mode = true
	empty_button.button_group = equip_button_group
	equipment_list.add_child(empty_button)
	# empty_button.pressed.connect(func(): on_unequip_weapon())
	# 实例化按钮，并加入节点
	for instance in instances_list:
		var instance_button = ITEM_BUTTON_SCENE.instantiate()
		equipment_list.add_child(instance_button)
		instance_button.setup(instance)
		if instance.equiped:
			instance_button.button_pressed = true
	
func refresh_equipment_list(equip_type: String):
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
				instance_button.button_pressed = true
	elif equip_type == equip_type_enum[1]:
		for instance in bridge_instances:
			var instance_button = ITEM_BUTTON_SCENE.instantiate()
			equipment_list.add_child(instance_button)
			instance_button.setup(instance)
			if instance.equiped:
				instance_button.button_pressed = true
	elif equip_type == equip_type_enum[2]:
		for instance in hull_instances:
			var instance_button = ITEM_BUTTON_SCENE.instantiate()
			equipment_list.add_child(instance_button)
			instance_button.setup(instance)
			if instance.equiped:
				instance_button.button_pressed = true
	elif equip_type == equip_type_enum[3]:
		for instance in hull_instances:
			var instance_button = ITEM_BUTTON_SCENE.instantiate()
			equipment_list.add_child(instance_button)
			instance_button.setup(instance)
			if instance.equiped:
				instance_button.button_pressed = true
