extends Node

# 经济计算常量
const SCORE_TO_CREDITS: float = 0.2
const SCORE_TO_EXPERIENCE: float = 0.1

# 玩家基础信息
var player_name: String = "新玩家"

# 游戏货币/资源
var credits: int = 0 # 创建银币，并赋值初始单位1000枚
var total_exp: int = 0 # 玩家经验
var current_exp: int = 0 # 玩家经验

# 关卡进度
var level_progress: int = 1  # 已解锁的关卡

# 舰船改装
var equipped_hull: int = 0
var equipped_engine: int = 0
var equipped_bridge: int = 0
var equipped_weapons: Array = [0,0,0]

# 游戏设置
var sound_volume: float = 1.0
var music_volume: float = 1.0
var language: String = "zh_CN"

# 保存文件路径
const SAVE_PATH = "user://wowsAVX_player_data.save"

func _ready():
	load_data()

# 战斗结算
func complete_battle(score: int):
	var earned_credits = int(score * SCORE_TO_CREDITS)
	credits += earned_credits
	var earned_experience = int(score * SCORE_TO_EXPERIENCE)
	current_exp += earned_experience
	save_game()
	return {
		"credits": earned_credits,
		"experience": earned_experience
	}

# 储存数据
func save_game():
	var save_data = {
		"player_name": player_name,
		"total_exp": total_exp,
		"current_exp": current_exp,
		"credits": credits,
		"level_progress": level_progress,
		"equipped_hull": equipped_hull,
		"equipped_engine": equipped_engine,
		"equipped_bridge": equipped_bridge,
		"equipped_weapons": equipped_weapons
	}
	# 转换数据为json格式
	var json_string = JSON.stringify(save_data)
	
	#写入文件
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data = {
		"credits": credits,
		"experience": experience
	}
	save_file.store_var(data)

func load_data():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = save_file.get_var()
	
	credits = data.get("credits", 1000)
	experience = data.get("experience", 0)
