# script_save_manager.gd
extends Node

const SAVE_DIR = "user://characters/"
const SAVE_FILE_PREFIX = "character_"
const SAVE_FILE_EXTENSION = ".tres"
const DEF_SAVE_PATH = "user://characters/character_def.tres"

func get_character_file_path(character_id: int) -> String:
	var global_path = SAVE_DIR
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(global_path))
	return SAVE_DIR + SAVE_FILE_PREFIX + str(character_id) + SAVE_FILE_EXTENSION

# 通用的储存脚本
func save_data(file_path: String, data: PlayerDataClass) -> bool:
	var temp_data: PlayerDataResource = data.to_resource()
	# print("转换存档数据：", temp_data)
	var err = ResourceSaver.save(temp_data, file_path)
	if err != OK:
		push_error("保存失败，错误码：" + str(err))
		return false
	# print("保存成功：", file_path)
	return true

# 通用读取
static func load_data(file_path: String) -> PlayerDataClass:
	if not FileAccess.file_exists(file_path):
		push_error("文件不存在：" + file_path)
		return null
	
	var resource_data: PlayerDataResource = ResourceLoader.load(file_path)
	# print("读取存档数据：", file_path, resource_data)
	
	if resource_data == null:
		push_error("加载 Resource 失败")
		return null
	
	var runtime_data = PlayerDataClass.new()  # 先创建新的 PlayerDataClass 实例
	runtime_data.from_resource(resource_data)  # 然后从 Resource 加载数据
	return runtime_data

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
	# print("尝试储存数据：", file_path, data)
	# 如果正式存档存在，先备份
	if FileAccess.file_exists(file_path):
		var old_data = load_data(file_path)
		if old_data:
			save_data(back_path, old_data)
	# 保存新数据到正式存档
	if save_data(file_path, data):
		# 成功后更新临时存档
		# print("存档成功，更新默认存档")
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
	# print("读取存档信息：", file_path, data)
	if data:
		return data
	# 如果主存档未返回，则尝试备用存档
	var back_path = file_path + ".bak"
	data = load_data(back_path)
	# print("原始存档不存在，采用备用存档：", back_path, data)
	if data:
		# push_waring("Using back up save.")
		return data
	# 如果上述都没有获取有效数据，则使用临时存档
	data = load_data(DEF_SAVE_PATH)
	if data:
		if data.character_id == character_id:
			# print("备用存档不存在，采用默认存档：", back_path, data)
			return data
		else:
			# print("默认存档不匹配，无法加载，创建新存档")
			return create_default_character_data(character_id) 
	else:
		# print("默认存档不存在，无法加载，创建新存档")
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
