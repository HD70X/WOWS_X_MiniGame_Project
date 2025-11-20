extends Node

var items: Dictionary = {}

func _ready() -> void:
	_load_all_items_from_directory("res://Resources/Items/")
	
func _load_all_items_from_directory(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			var full_path = path + file_name
			
			# 子目录递归扫描
			if dir.current_is_dir() and file_name != "." and file_name != "..":
				_load_all_items_from_directory(full_path + "/")
			elif file_name.ends_with(".tres"):
				var resource = load(full_path)
				if resource is ItemData:
					_register_item(resource)
				else:
					push_warning("文件不是 ItemData 类型: " + full_path)
					
			file_name = dir.get_next()
			
		dir.list_dir_begin()
	else:
		push_error("无法打开目录: " + path)


func _register_item(item_data: ItemData):
	if items.has(item_data.item_id):
		push_warning("道具 ID 重复: " + item_data.item_id)
	# 积极加载策略，将全部数据保存到缓存
	# 如果文件较多，请务必确保items作为路径储存字典，而不是data储存字典
	items[item_data.item_id] = item_data

func get_item(item_id: String) -> ItemData:
	if items.has(item_id):
		return items[item_id]
	push_error("未找到道具: " + item_id)
	return null

# 可选:获取所有道具列表
func get_all_items() -> Array:
	return items.values()
	
# 可选:按类型筛选道具
func get_items_by_type(item_type: String) -> Array:
	var filtered = []
	for item in items.values():
		if item.item_Type == item_type:
			filtered.append(item)
	return filtered
	
