extends Button

#signal  equip_selected(item_id: String)
@onready var icon_container: MarginContainer = $IconContainer
@onready var item_icon: TextureRect = $IconContainer/ItemIcon
@onready var hover_frame: NinePatchRect = $NinePatchRect

# 尺寸配置
@export var normal_icon_size := Vector2(138, 138)
@export var hover_icon_size := Vector2(156, 156)
@export var animation_duration := 0.2

var tween: Tween
var is_highlighted := false

func _ready():
	# 初始化显示状态
	hover_frame.visible = false

	# 连接信号
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

# 设置物品数据
func setup(item_instance: ItemUnstackableInstance):
	# item_id = add_item_id
	var item_template = ItemDatabase.get_item(item_instance.template_id)


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

	tween.tween_property(item_icon, "custom_minimum_size", target_size, animation_duration)
	tween.tween_property(item_icon, "size", target_size, animation_duration)
