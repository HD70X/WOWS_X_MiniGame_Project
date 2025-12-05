extends Button

signal slot_selected(slot_index: int, equipment_type: String)
@export var slot_index: int = 0
@export_enum("weapon", "bridge", "hull", "engine") var equipment_type: String = "weapon"
@onready var slot_icon: TextureRect = $IconContainer/ItemIcon
@onready var empty_icon: TextureRect = $IconContainer/EmptyIcon
@onready var slot_frame: NinePatchRect = $IconContainer/SelectedRect
@onready var icon_container: MarginContainer = $IconContainer
@onready var hover_frame: NinePatchRect = $PointedRect

# 尺寸配置
@export var normal_icon_size := Vector2(138, 138)
@export var hover_icon_size := Vector2(156, 156)
@export var animation_duration := 0.2

var is_selected := false

var tween: Tween
var is_highlighted := false

func _ready():
	add_to_group("dock_ship_slots_group")  # 不需要全局分组
	
	# 初始化显示状态
	hover_frame.visible = false

	# 连接信号
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

# 设置物品数据
func update_slot(item_instance: ItemUnstackableInstance):
	# item_id = add_item_id
	if item_instance:
		var item_template = ItemDatabase.get_item(item_instance.template_id)
		slot_icon.texture = item_template.icon
		empty_icon.visible = false
	else:
		slot_icon.texture = null
		empty_icon.visible = true

# 鼠标悬浮事件
func _on_mouse_entered():
	hover_frame.visible = true
	_animate_icon_size(hover_icon_size)

func _on_mouse_exited():
	hover_frame.visible = false
	_animate_icon_size(normal_icon_size)

# 图标缩放动画
func _animate_icon_size(target_size: Vector2):
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(slot_icon, "custom_minimum_size", target_size, animation_duration)
	tween.tween_property(slot_icon, "size", target_size, animation_duration)
	tween.tween_property(empty_icon, "custom_minimum_size", target_size, animation_duration)
	tween.tween_property(empty_icon, "size", target_size, animation_duration)

# 设置选中状态
func set_selected(selected: bool):
	is_selected = selected
	slot_frame.visible = selected

func _on_pressed():
	slot_selected.emit(slot_index, equipment_type)
