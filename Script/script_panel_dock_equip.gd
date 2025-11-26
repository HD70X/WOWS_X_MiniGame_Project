extends Panel

# 预设一些按钮组，以便更好的实现点击切换显示效果
var weapon_button_group = ButtonGroup.new()
# 预设一些数组，用于储存玩家的装备信息，并用于展示
var weapon_list: Array
var hull_list: Array
var bridge_list: Array
var engine_list: Array

var empty_weapon = {
	"instance_id": "EMPTY_WEAPON_I",
	"template_id": "EMPTY_WEAPON_T",
	"equip_type": ItemUnstackable.ItemType.WEAPON
}

func _ready() -> void:
	pass

# 检查玩家仓储，获知玩家拥有的道具，并将其中的武器等组件识别出来存入相应的数组中
func load_inventory():
	for instance_dict in PlayerData.inventory["equipment_instances"]:
		# 将字典还原为实例对象
		var instance = ItemUnstackableInstance.from_dict(instance_dict)
		# 通过instance中的template_id确定对应的武器是什么，并加入数组，这里只写入temple即可
		# 将获得的装备分类，并将其写入相应的List
		if instance.ItemType == ItemUnstackable.ItemType.WEAPON:
			weapon_list.append(instance)
		elif instance.ItemType == ItemUnstackable.ItemType.BRIDGE:
			bridge_list.append(instance)
		elif instance.ItemType == ItemUnstackable.ItemType.HULL:
			hull_list.append(instance)
		elif instance.ItemType == ItemUnstackable.ItemType.ENGINE:
			engine_list.append(instance)
		else:
			pass

# 通用方法，基于输入的实例ID，在
func create_equip_button(equip_data):
	
