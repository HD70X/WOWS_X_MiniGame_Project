extends Resource
class_name PlayerDataResource

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
