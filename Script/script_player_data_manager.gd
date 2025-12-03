# player_data_manager.gd
extends Node

# 持有实际的数据实例
var data: PlayerDataClass = PlayerDataClass.new()

# 保存路径
const SAVE_PATH = "user://player_data.tres"

# 提供便捷的属性访问（可选）
var character_id: int:
	get: return data.character_id
	set(value): data.character_id = value

var character_name: String:
	get: return data.character_name
	set(value): data.character_name = value

var level: int:
	get: return data.level
	set(value): data.level = value

# ... 为其他属性添加类似的 getter/setter

# 加载数据
func load_data() -> void:
	if ResourceLoader.exists(SAVE_PATH):
		var loaded_data = ResourceLoader.load(SAVE_PATH)
		if loaded_data is PlayerDataClass:
			data = loaded_data
			print("数据加载成功")
		else:
			print("数据格式错误，使用默认数据")
	else:
		print("没有找到存档，使用默认数据")

# 保存数据
func save_data() -> void:
	var error = ResourceSaver.save(data, SAVE_PATH)
	if error == OK:
		print("数据保存成功")
	else:
		print("数据保存失败: ", error)

# 重置数据
func reset_data() -> void:
	data = PlayerDataClass.new()

func _ready():
	load_data()
