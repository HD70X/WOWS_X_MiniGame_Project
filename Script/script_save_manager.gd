extends Node

const SAVE_DIR = "user://characters/"
const SAVE_FILE_PREFIX = "character_"
const SAVE_FILE_EXTENSION = ".save"
const DEF_SAVE_PATH = "user://characters/character_def.save"

func get_character_file_path(character_id: int) -> String:
	var global_path = SAVE_DIR
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(global_path))
	return SAVE_DIR + SAVE_FILE_PREFIX + str(character_id) + SAVE_FILE_EXTENSION

# 通用的储存脚本
func save_data(file_path: String, data: Dictionary) -> bool:
	# print("保存时检查：", data)
	# 打开保存文件
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		# push_error("无法打开文件: " + file_path)
		return false
	# 将数据转换为Json格式
	file.store_var(data)
	file.close()
	return true

# 通用读取
func load_data(file_path: String):
	# 检查文件是否存在
	if not FileAccess.file_exists(file_path):
		return {}
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return {}
	# 使用二进制读取
	var data = file.get_var()
	file.close()
	# print("读取时检查：", data)
	return data if data != null else {}

# 默认储存的方法
func def_save(data):
	# 默认存储
	save_data(DEF_SAVE_PATH, data)

# 正式存档方法
func save_game(character_id: int):
	# 基于当前玩家游玩的角色，确定角色存档路径和所需的数据
	var file_path = get_character_file_path(character_id)
	var back_path = file_path + ".bak"
	var data = PlayerData.get_all_data()
	var data_to_save = data.duplicate()
	data_to_save["saving_time"] = Time.get_unix_time_from_system()
	# 如果正式存档存在，先备份
	if FileAccess.file_exists(file_path):
		var old_data = load_data(file_path)
		if not old_data.is_empty():
			save_data(back_path, old_data)
	# 保存新数据到正式存档
	if save_data(file_path, data_to_save):
		# 成功后更新临时存档
		def_save(data_to_save)
		return true
	return false

# 遍历存档
func get_all_save_files() -> Array:
	var saves = []
	var dir = DirAccess.open(SAVE_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.begins_with(SAVE_FILE_PREFIX):
				saves.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	return saves

func delete_save(character_id: int) -> bool:
	var file_path = get_character_file_path(character_id)
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)
		var back_path = file_path + ".bak"
		if FileAccess.file_exists(back_path):
			DirAccess.remove_absolute(back_path)
		return true
	return false

func load_game(character_id: int) -> Dictionary:
	var file_path = get_character_file_path(character_id)
	# 尝试自动加载正式存档
	var data = load_data(file_path)
	if not data.is_empty():
		return data
	# 如果主存档未返回，则尝试备用存档
	var back_path = file_path + ".bak"
	data = load_data(back_path)
	if not data.is_empty():
		# push_waring("Using back up save.")
		return data
	# 如果上述都没有获取有效数据，则使用临时存档
	data = load_data(DEF_SAVE_PATH)
	if not data.is_empty():
		if data.character_id == character_id:
			return data
		else:
			return create_default_character_data(character_id) 
	else:
		return create_default_character_data(character_id) 

func create_default_character_data(character_id) -> Dictionary:
	PlayerData.reset_to_default(character_id, "Captain Cap")
	var def_data = PlayerData.get_all_data()
	return def_data

# 获取当前玩家的player_id
func get_player_id() -> int:
	return PlayerData.character_id

func load_default() -> Dictionary:
	var data = load_data(DEF_SAVE_PATH)
	return data
