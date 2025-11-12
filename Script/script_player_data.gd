extends Node

# 角色顺序标识
var character_id: int = 0

# 角色基本信息
var character_name: String = "Captain Cap"

# 进度
var level_unlock: int = 1  # 已解锁的关卡
var unlocked_achievements: Array = ["first_kill", "depth_master", "survivor"]
var unlocked_tech: Array = ["torpedo_mk2", "reinforced_hull", "sonar_upgrade"]

# 游戏货币/资源
var credits: int = 0 # 创建银币，并赋值初始单位1000枚
var total_exp: int = 0 # 玩家经验
var current_exp: int = 0 # 玩家经验

# 经济计算常量
const SCORE_TO_CREDITS: float = 0.2
const SCORE_TO_EXPERIENCE: float = 0.1

# 舰船武器
var weapons: Dictionary = {
	"weapon_slot_1": null,
	"weapon_slot_2": null,
	"weapon_slot_3": null
}

# 舰船改装
var ship_upgrades: Dictionary = {
	"hull_level": 1,
	"engine_level": 1,
	"bridge_level": 1
}

# 游戏设置
var sound_volume: float = 1.0
var music_volume: float = 1.0
var language: String = "zh_CN"

# 获取所有数据的方法
func get_all_data() -> Dictionary:
	return {
		"character_id": character_id,
		"character_name": character_name,
		"level_unlock": level_unlock,
		"current_exp": current_exp,
		"total_exp": total_exp,
		"credits": credits,
		"weapons": weapons,
		"ship_upgrades": ship_upgrades,
		"unlocked_achievements": unlocked_achievements,
		"unlocked_tech": unlocked_tech
	}

# 从字典加载数据（加载存档）
#func load_from_dict(data: Dictionary) -> void:
	#if data.has("character_id"):
		#character_id = data["character_id"]
	#if data.has("character_name"):
		#character_name = data["character_name"]
	#if data.has("level_unlock"):
		#level_unlock = data["level_unlock"]
	#if data.has("current_exp"):
		#current_exp = data["current_exp"]
	#if data.has("total_exp"):
		#total_exp = data["total_exp"]
	#if data.has("credits"):
		#credits = data["credits"]
	#if data.has("weapons"):
		#weapons = data["weapons"]
	#if data.has("ship_upgrades"):
		#ship_upgrades = data["ship_upgrades"]
	#if data.has("unlocked_achievements"):
		#unlocked_achievements = data["unlocked_achievements"]
	#if data.has("unlocked_tech"):
		#unlocked_tech = data["unlocked_tech"]

func load_from_dict(data: Dictionary) -> void:
	var fields = {
		"character_id": "character_id",
		"character_name": "character_name",
		"level_unlock": "level_unlock",
		"current_exp": "current_exp",
		"total_exp": "total_exp",
		"credits": "credits",
		"weapons": "weapons",
		"ship_upgrades": "ship_upgrades",
		"unlocked_achievements": "unlocked_achievements",
		"unlocked_tech": "unlocked_tech"
	}
	
	for key in fields:
		if data.has(key):
			set(fields[key], data[key])

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
	weapons = {
		"weapon_slot_1": null,
		"weapon_slot_2": null,
		"weapon_slot_3": null
	}
	ship_upgrades = {
		"hull_level": 1,
		"engine_level": 1,
		"bridge_level": 1
	}
	unlocked_achievements = []
	unlocked_tech = []
