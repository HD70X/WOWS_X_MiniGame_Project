extends Panel

# 预设一些按钮组，以便更好的实现点击切换显示效果
var weapon_button_group = ButtonGroup.new()
var hull_button_group = ButtonGroup.new()
var bridge_button_group = ButtonGroup.new()
var engine_button_group = ButtonGroup.new()
# 预设一些数组，用于储存玩家的装备信息，并用于展示
var weapon_instances: Array
var hull_instances: Array
var bridge_instances: Array
var engine_instances: Array
var instance_list_array : Array = [weapon_instances, hull_instances, bridge_instances, engine_instances]

@onready var weapon_list = $MarginContainer/MarginContainer/HBoxContainer/LeftContainer/LeftSection/EquipTabContainer/WeaponTab/WeaponList
@onready var hull_list = $MarginContainer/MarginContainer/HBoxContainer/LeftContainer/LeftSection/EquipTabContainer/HullTab/HullList
@onready var bridge_list = $MarginContainer/MarginContainer/HBoxContainer/LeftContainer/LeftSection/EquipTabContainer/BridgeTab/BridgeList
@onready var engine_list = $MarginContainer/MarginContainer/HBoxContainer/LeftContainer/LeftSection/EquipTabContainer/EngineTab/EngineList

const ITEM_BUTTON_SCENE = preload("res://Scenes/UI/button_dock_equip_list_item.tscn")

var empty_weapon = {
	"instance_id": "EMPTY_WEAPON_I",
	"template_id": "EMPTY_WEAPON_T",
	"equip_type": ItemUnstackable.ItemType.WEAPON
}

func _ready() -> void:
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
func refresh_instance_list(list: VBoxContainer, instances_list: Array):
	# 清理可能的旧节点
	for child in list.get_children():
		child.queue_free()
	var _default_select_exist = false
	# 添加"卸载"按钮（仅武器需要）
	var empty_button = Button.new()
	empty_button.text = "卸载武器"
	empty_button.toggle_mode = true
	empty_button.button_group = weapon_button_group
	list.add_child(empty_button)
	# empty_button.pressed.connect(func(): on_unequip_weapon())
	# 实例化按钮，并加入节点
	for instance in instances_list:
		var instance_button = ITEM_BUTTON_SCENE.instantiate()
		list.add_child(instance_button)
		instance_button.setup(instance)
		if instance.equiped:
			_default_select_exist = true
			instance_button.button_pressed = true
	
