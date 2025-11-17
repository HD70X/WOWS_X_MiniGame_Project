extends Button

signal  slot_selected(character_id: int)

var character_id: int
var is_updating: bool = false

# 更新节点路径以匹配新结构
@onready var name_label = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/CharacterName
@onready var time_label = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/SavingTime
@onready var level_label = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/CharacterLevel
@onready var screenshot = $MarginContainer/HBoxContainer/Control/SaveScreenShot
@onready var point_icon = $MarginContainer/HBoxContainer/Control/PointIcon

func _ready():
	toggle_mode = true
	toggled.connect(_on_toggled)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	point_icon.visible = false  # 默认隐藏角标

func setup(data: Dictionary):
	character_id = data["character_id"]
	name_label.text = data["character_name"]
	
	# 格式化存档时间
	if data.has("saving_time"):
		var saving_time = data["saving_time"]
		# 如果是数字（Unix时间戳），转换为字典
		if typeof(saving_time) == TYPE_FLOAT or typeof(saving_time) == TYPE_INT:
			var time_dict = Time.get_datetime_dict_from_unix_time(int(saving_time))
			time_label.text = "%d-%02d-%02d %02d:%02d" % [
				time_dict["year"], time_dict["month"], time_dict["day"],
				time_dict["hour"], time_dict["minute"]
				]
		# 如果已经是字典格式
		elif typeof(saving_time) == TYPE_DICTIONARY:
			time_label.text = "%d-%02d-%02d %02d:%02d" % [
				saving_time["year"], saving_time["month"], saving_time["day"],
				saving_time["hour"], saving_time["minute"]
				]
	else:
		time_label.text = "未知时间"
	
	level_label.text = "Lv.%d" % data["character_level"]
	
	# 如果有截图数据可以在这里加载
	screenshot.texture = load("res://Art/Avatar/CaptainSprites/head.png")

func _on_toggled(toggled_state: bool):
	if is_updating:
		return
	if toggled_state:
		slot_selected.emit(character_id)

# 用于调整选定状态
func set_select_state(selected: bool):
	is_updating = true
	button_pressed = selected
	is_updating = false

# 控制鼠标悬停显示pointIcon指引
func _on_mouse_entered() -> void:
	point_icon.visible = true
func _on_mouse_exited() -> void:
	point_icon.visible = false
