extends PanelContainer

signal slot_clicked(character_id: int)

var character_id: int
var is_selected: bool = false

# 更新节点路径以匹配新结构
@onready var name_label = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/CharacterName
@onready var time_label = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/SavingTime
@onready var level_label = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/CharacterLevel
@onready var screenshot = $MarginContainer/HBoxContainer/Control/SaveScreenShot
@onready var point_icon = $MarginContainer/HBoxContainer/Control/PointIcon

func _ready():
	gui_input.connect(_on_gui_input)
	point_icon.visible = false  # 默认隐藏角标

func setup(data: Dictionary):
	character_id = data["character_id"]
	name_label.text = data["character_name"]
	
	# 格式化存档时间
	if data.has("saving_time"):
		var time_dict = data["saving_time"]
		time_label.text = "%d-%02d-%02d %02d:%02d" % [
			time_dict["year"], time_dict["month"], time_dict["day"],
			time_dict["hour"], time_dict["minute"]
			]
	else:
		time_label.text = "未知时间"
	
	level_label.text = "Lv.%d" % data["level"]
	
	# 如果有截图数据可以在这里加载
	screenshot.texture = "res://Art/Avatar/CaptainSprites/head.png"

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			slot_clicked.emit(character_id)

func set_selected(selected: bool):
	is_selected = selected
	# 通过切换主题实现选中高亮（需要在编辑器中配置主题变体）
	if selected:
		add_theme_stylebox_override("panel", preload("res://Art/Theme Styles/selected_panel.tres"))
	else:
		remove_theme_stylebox_override("panel")
