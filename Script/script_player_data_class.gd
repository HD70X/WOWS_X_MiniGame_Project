# script_player_data_class.gd
extends Node
class_name PlayerDataClass

# 角色顺序标识
@export var character_id: int = 0

# 角色基本信息
@export var character_name: String = "Captain Cap"
@export var character_level: int = 1

# 进度
@export var level_unlock: int = 1  # 已解锁的关卡

# 游戏货币/资源
var credits: int = 0 # 创建银币，并赋值初始单位1000枚
@export var total_exp: int = 0 # 玩家经验
@export var current_exp: int = 0 # 玩家经验

# 经济计算常量
const SCORE_TO_CREDITS: float = 0.2
const SCORE_TO_EXPERIENCE: float = 0.1

# 储存时间
@export var saving_time: float

# 道具解锁/安装/库存
@export var unlocked_items: Array = []
@export var equiped_items: Dictionary = {
	"weapon_slot_1": null,
	"weapon_slot_2": null,
	"weapon_slot_3": null,
	"hull_type": null,
	"bridge_type": null,
	"engine_type": null
}
@export var inventory: Dictionary = {
	"stackable_items": {},  # 可堆叠物品 {item_id: quantity}
	"unstackable_instances": []  # 装备实例数组
}

# 游戏设置
@export var sound_volume: float = 1.0
@export var music_volume: float = 1.0
@export var language: String = "zh_CN"

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
	var weapon_ids = self.add_item("player_weapon_depth_charge", 10)
	var hull_ids = self.add_item("user_hull_default", 1)
	var engine_ids = self.add_item("user_engine_default", 1)
	var bridge_ids = self.add_item("user_bridge_default", 1)
	# 将其instanceid储存在装备物品字典中
	equiped_items = {
		"weapon_slot_1": null,
		"weapon_slot_2": weapon_ids[0],
		"weapon_slot_3": null,
		"bridge_type": bridge_ids[0],
		"hull_type": hull_ids[0],
		"engine_type": engine_ids[0]
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
		for i in item_quantity:
			var instance = item_data.create_instance()
			inventory["unstackable_instances"].append(instance)
			created_instance_ids.append(instance.instance_id)
			print("注册角色创建装备实例列表", created_instance_ids)
		return created_instance_ids
	return []
	
# 使用instance_id获取道具数据
func find_instance(instance_id: String) -> ItemUnstackableInstance:
	for item in inventory["unstackable_instances"]:
		if item.instance_id == instance_id:
			return item
	return null

# 添加一个方法，可以将PlayerDataClass数据转换为PlayerDataSaving
# 转换为可保存的 Resource
func to_resource() -> PlayerDataResource:
	var data = PlayerDataResource.new()
	data.character_id = character_id
	data.character_name = character_name
	data.character_level = character_level
	data.level_unlock = level_unlock
	data.current_exp = current_exp
	data.total_exp = total_exp
	data.credits = credits
	data.equiped_items = equiped_items.duplicate(true)
	data.unlocked_items = unlocked_items.duplicate(true)
	data.inventory = inventory.duplicate(true)
	data.saving_time = saving_time
	data.sound_volume = sound_volume
	data.music_volume = music_volume
	return data
	
# 从 Resource 加载数据
func from_resource(data: PlayerDataResource):
	character_id = data.character_id
	character_name = data.character_name
	character_level = data.character_level
	level_unlock = data.level_unlock
	current_exp = data.current_exp
	total_exp = data.total_exp
	credits = data.credits
	equiped_items = data.equiped_items.duplicate(true)
	unlocked_items = data.unlocked_items.duplicate(true)
	inventory = data.inventory.duplicate(true)
	saving_time = data.saving_time
	sound_volume = data.sound_volume
	music_volume = data.music_volume
	language = data.language
