extends Resource
class_name ItemUnstackableInstance

# 实例唯一ID
var instance_id: String
# 原始数据模板
var template_id: String
var equiped: bool

# 动态属性
#var durability: float
#var max_durability: float
#var enhancement_level: int = 0

func _init(_template_id: String):
	self.instance_id = _generate_unique_id()
	self.template_id = _template_id
	self.equiped = false

func _generate_unique_id() -> String:
	return template_id + "_" + str(Time.get_unix_time_from_system())

func to_dict() -> Dictionary:
	return{
		"instance_id": instance_id,
		"template_id": template_id,
		"equiped": equiped
	}

func from_dict(data: Dictionary) -> ItemUnstackableInstance:
	var item_instance = ItemUnstackableInstance.new(data["template_id"])
	item_instance.instance_id = data["instance_id"]
	return item_instance
