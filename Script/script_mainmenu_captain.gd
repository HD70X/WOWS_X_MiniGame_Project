extends Node2D

@onready var animation_player = $AnimationPlayer
var is_interacting = false  # 标记是否正在交互

func _ready() -> void:
	random_play()

func random_play():
	# 尝试等待随机时间后播放待机动画
	await get_tree().create_timer(randf_range(5.0, 15.0)).timeout
	if not is_interacting:
		# 判断是否被占用
		animation_player.play("captain_default_animation")
		# 再次重新开始等待随机播放
		random_play()

func _on_captain_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not is_interacting:
			animation_player.play("captain_use_telescope_animation", 0.2)
			is_interacting = true
			await animation_player.animation_finished
			await get_tree().create_timer(3.0).timeout
			is_interacting = false
			random_play()
