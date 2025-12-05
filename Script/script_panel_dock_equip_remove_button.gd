extends Button

signal  remove_equipment()

@onready var icon_container: MarginContainer = $IconContainer
@onready var item_icon: TextureRect = $IconContainer/ItemIcon
@onready var hover_frame: NinePatchRect = $NinePatchRect

@onready var name_container: MarginContainer = $NameContainer
@onready var name_label: Label = $NameContainer/Name

# 尺寸配置
@export var normal_icon_size := Vector2(138, 138)
@export var hover_icon_size := Vector2(156, 156)
@export var animation_duration := 0.2

var tween: Tween
var is_highlighted := false
var item_template_id: String
var item_instance_id: String

func _ready():
	# 初始化显示状态
	hover_frame.visible = false
	name_container.visible = false
	# 连接信号
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

# 鼠标悬浮事件
func _on_mouse_entered():
	hover_frame.visible = true
	name_container.visible = true
	_animate_icon_size(hover_icon_size)
	_animate_name_fade_in()

func _on_mouse_exited():
	hover_frame.visible = false
	name_container.visible = false
	_animate_icon_size(normal_icon_size)

# 图标缩放动画
func _animate_icon_size(target_size: Vector2):
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(item_icon, "custom_minimum_size", target_size, animation_duration)
	tween.tween_property(item_icon, "size", target_size, animation_duration)

# 名称淡入动画
func _animate_name_fade_in():
	name_container.modulate.a = 0
	var fade_tween = create_tween()
	fade_tween.tween_property(name_container, "modulate:a", 1.0, 0.15)


func _on_pressed() -> void:
	remove_equipment.emit() # Replace with function body.
