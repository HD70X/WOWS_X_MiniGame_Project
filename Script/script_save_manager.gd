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
func save_data(file_path: String, data: PlayerDataClass) -> bool:
	return ResourceSaver.save(data, file_path) == OK

# 通用读取
static func load_data(file_path: String) -> PlayerDataClass:
	return ResourceLoader.load(file_path) as PlayerDataClass

# 默认储存的方法
func def_save(data):
	# 默认存储
	save_data(DEF_SAVE_PATH, data)

# 正式存档方法
func save_game(data: PlayerDataClass):
	# 基于当前玩家游玩的角色，确定角色存档路径和所需的数据
	var file_path = get_character_file_path(data.character_id)
	var back_path = file_path + ".bak"
	data.saving_time = Time.get_unix_time_from_system()
	# 如果正式存档存在，先备份
	if FileAccess.file_exists(file_path):
		var old_data = load_data(file_path)
		if old_data:
			save_data(back_path, old_data)
	# 保存新数据到正式存档
	if save_data(file_path, data):
		# 成功后更新临时存档
		def_save(data)
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

func load_game(character_id: int) -> PlayerDataClass:
	var file_path = get_character_file_path(character_id)
	# 尝试自动加载正式存档
	var data = load_data(file_path)
	if data:
		return data
	# 如果主存档未返回，则尝试备用存档
	var back_path = file_path + ".bak"
	data = load_data(back_path)
	if data:
		# push_waring("Using back up save.")
		return data
	# 如果上述都没有获取有效数据，则使用临时存档
	data = load_data(DEF_SAVE_PATH)
	if data:
		if data.character_id == character_id:
			return data
		else:
			return create_default_character_data(character_id) 
	else:
		return create_default_character_data(character_id) 

func create_default_character_data(character_id) -> PlayerDataClass:
	var new_data = PlayerDataClass.new()
	new_data.reset_to_default(character_id, "Captain Cap")
	return new_data

# 获取当前玩家的player_id
func get_player_id() -> int:
	return PlayerData.character_id

func load_default() -> PlayerDataClass:
	var data = load_data(DEF_SAVE_PATH)
	return data
