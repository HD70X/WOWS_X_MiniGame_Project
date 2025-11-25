extends Node

# 角色顺序标识
var character_id: int = 0

# 角色基本信息
var character_name: String = "Captain Cap"
var character_level: int = 1

# 进度
var level_unlock: int = 1  # 已解锁的关卡

# 游戏货币/资源
var credits: int = 0 # 创建银币，并赋值初始单位1000枚
var total_exp: int = 0 # 玩家经验
var current_exp: int = 0 # 玩家经验

# 经济计算常量
const SCORE_TO_CREDITS: float = 0.2
const SCORE_TO_EXPERIENCE: float = 0.1

# 道具解锁/安装/库存
@export var unlocked_items: Array = []
@export var equiped_items: Dictionary = {
	"weapon_slot_1": null,
	"weapon_slot_2": null,
	"weapon_slot_3": null,
	"hull_type": null,
	"engine_type": null,
	"bridge_type": null
}
@export var inventory: Dictionary = {
	"stackable_items": {},  # 可堆叠物品 {item_id: quantity}
	"equipment_instances": []  # 装备实例数组
}

## 舰船武器
#var weapons: Dictionary = {
	#"weapon_slot_1": EquipmentManager.WeaponType.NONE,
	#"weapon_slot_2": EquipmentManager.WeaponType.DEPTH_CHARGE_DEF,
	#"weapon_slot_3": EquipmentManager.WeaponType.NONE
#}
#
## 舰船改装
#var ship_upgrades: Dictionary = {
	#"hull_type": EquipmentManager.HullTyep.DEFAULT,
	#"engine_type": EquipmentManager.EngineTyep.DEFAULT,
	#"bridge_type": EquipmentManager.BridgeTyep.DEFAULT
#}

# 游戏设置
var sound_volume: float = 1.0
var music_volume: float = 1.0
var language: String = "zh_CN"

# 获取所有数据的方法
func get_all_data() -> Dictionary:
	return {
		"character_id": character_id,
		"character_name": character_name,
		"character_level": character_level,
		"level_unlock": level_unlock,
		"current_exp": current_exp,
		"total_exp": total_exp,
		"credits": credits,
		"equiped_items": equiped_items,
		"unlocked_items": unlocked_items,
		"inventory": inventory
	}

# 从字典加载数据（加载存档）
func load_from_dict(data: Dictionary) -> void:
	# 定义需要处理的整数字段
	var int_fields = ["character_id", "character_level", "level_unlock", "current_exp", "total_exp", "credits"]
	# 循环处理整数字段
	for field in int_fields:
		if data.has(field):
			set(field, data[field])
			# set(field, int(data[field]))
	
	# 字符串字段
	if data.has("character_name"):
		character_name = data["character_name"]
	
	# 复杂类型字段(数组/字典)
	var complex_fields = ["equiped_items", "unlocked_items", "inventory"]
	for field in complex_fields:
		if data.has(field):
			set(field, data[field])

# 设置为默认数据
func reset_to_default(new_character_id: int, player_input_name: String) -> void:
	character_id = new_character_id
	if not player_input_name.is_empty():
		character_name = player_input_name
	else:
		character_name = "Captain Cap"
	level_unlock = 1
	total_exp = 0
	current_exp = 0
	credits = 0
	unlocked_items = []
	equiped_items = {
		"weapon_slot_1": null,
		"weapon_slot_2": "player_weapon_depth_charge",
		"weapon_slot_3": null,
		"hull_type": "user_hull_default",
		"engine_type": "user_engine_default",
		"bridge_type": "user_bridge_default"
	}

func add_item(item_id:String, item_quntity:int):
	var item_data = ItemDatabase.get_item(item_id)
	if item_data is ItemMultiple:
		pass
