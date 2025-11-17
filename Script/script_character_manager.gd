extends Node

const SAVE_PATH = "res://characters/"

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func get_all_character() -> Array:
	var characters = []
	# 检查目录，如果不存在返回空数组
	if not DirAccess.dir_exists_absolute(SAVE_PATH):
		DirAccess.make_dir_absolute(SAVE_PATH)

		return characters
	#打开目录
	var dir = DirAccess.open(SAVE_PATH)
	if not dir:
		push_error("无法打开存档目录: " + SAVE_PATH)
		return characters
	# 遍历目录文件
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		# 筛选save文件
		if file_name.end_with(".save"):
			# 不处理默认存档
			if file_name != "character_def.save":
				# 不打开字典的前提下提取角色ID（去掉扩展名和前缀，只要序号）
				var character_id_str = file_name.trim_prefix("character_").trim_suffix(".save")
				var character_id = character_id_str.to_int()
				var character_data = SaveManager.load_game(character_id)
				if character_data != null and not character_data.is_empty():
					characters.append(character_data)
		file_name = dir.get_next()
	dir.list_dir_end()
	# 按保存时间排序
	characters.sort_custom(func(a,b):
		return a.get("saving_time", 0) >= b.get("saving_time", 0)
	)
	return characters

# 创建新角色
func create_new_character(character_name) -> int:
	# 使用Unix时间戳作为ID，确保唯一性
	var character_id = Time.get_unix_time_from_system()
	if character_name.is_empty():
		character_name = "Captain Cap"
	PlayerData.reset_to_default(character_id, character_name)
	SaveManager.save_game(character_id)
	return character_id

func delete_character(character_id: int) -> bool:
	var file_path = SaveManager.get_character_file_path(character_id)
	if FileAccess.file_exists(file_path):
		var err = DirAccess.remove_absolute(file_path)
		return err == OK
	return false
