extends Resource
class_name PlayerDataClass

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

# 储存时间
var saving_time: float

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
	"unstackable_instances": []  # 装备实例数组
}

# 游戏设置
var sound_volume: float = 1.0
var music_volume: float = 1.0
var language: String = "zh_CN"

# 获取所有数据的方法
#func get_all_data() -> Dictionary:
	#return {
		#"character_id": character_id,
		#"character_name": character_name,
		#"character_level": character_level,
		#"level_unlock": level_unlock,
		#"current_exp": current_exp,
		#"total_exp": total_exp,
		#"credits": credits,
		#"equiped_items": equiped_items,
		#"unlocked_items": unlocked_items,
		#"inventory": inventory
	#}

# 从字典加载数据（加载存档）
#func load_from_dict(data: Dictionary) -> void:
	## 定义需要处理的整数字段
	#var int_fields = ["character_id", "character_level", "level_unlock", "current_exp", "total_exp", "credits"]
	## 循环处理整数字段
	#for field in int_fields:
		#if data.has(field):
			#set(field, data[field])
			## set(field, int(data[field]))
	#
	## 字符串字段
	#if data.has("character_name"):
		#character_name = data["character_name"]
	#
	## 复杂类型字段(数组/字典)
	#var complex_fields = ["equiped_items", "unlocked_items", "inventory"]
	#for field in complex_fields:
		#if data.has(field):
			#set(field, data[field])

func load_from_resource(other: PlayerDataClass) -> void:
	character_id = other.character_id
	character_name = other.character_name
	character_level = other.character_level
	level_unlock = other.level_unlock
	current_exp = other.current_exp
	total_exp = other.total_exp
	credits = other.credits
	equiped_items = other.equiped_items.duplicate(true)
	unlocked_items = other.unlocked_items.duplicate(true)
	inventory = other.inventory.duplicate(true)
	saving_time = other.saving_time
	sound_volume = other.sound_volume
	music_volume = other.music_volume
	language = other.language

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
	# 创建基础武器，船体，引擎，舰桥实例
	var weapon_ids = self.add_item("player_weapon_depth_charge", 1)
	var hull_ids = self.add_item("user_hull_default", 1)
	var engine_ids = self.add_item("user_engine_default", 1)
	var bridge_ids = self.add_item("user_bridge_default", 1)
	# 将其instanceid储存在装备物品字典中
	equiped_items = {
		"weapon_slot_1": null,
		"weapon_slot_2": weapon_ids[0],
		"weapon_slot_3": null,
		"hull_type": hull_ids[0],
		"engine_type": engine_ids[0],
		"bridge_type": bridge_ids[0]
	}
	# 修改默认安装的装备的安装状态
	for equipment in equiped_items.values():
		if equipment:
			var equip_used = find_instance(equipment)
			var index = inventory["unstackable_instances"].find(equip_used)
			inventory["unstackable_instances"][index].equiped = true

# 仓库内新增物品
func add_item(item_id:String, item_quantity:int) -> Array:
	var created_instance_ids = []
	var item_data = ItemDatabase.get_item(item_id)
	if item_data is ItemStackable:
		# 可堆叠道具直接增加数量或新建
		if inventory["stackable_items"].has(item_id):
			inventory["stackable_items"][item_id] += item_quantity
		else:
			inventory["stackable_items"][item_id] = item_quantity
		# 可堆叠物品返回空数组
		return []
	elif  item_data is ItemUnstackable:
		# 不可堆叠道具，创建实例
		for i in range(item_quantity):
			var instance = item_data.create_instance()
			inventory["unstackable_instances"].append(instance)
			created_instance_ids.append(instance.instance_id)
			return created_instance_ids
	return []
	
# 使用instance_id获取道具数据
func find_instance(instance_id: String) -> ItemUnstackableInstance:
	for item in inventory["stackable_items"]:
		if item.instance_id == instance_id:
			return item
	return null
