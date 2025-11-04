extends Node2D

@onready var whistle_sound  = $HornSound

const MAX_WHISTLE_TIME = 4.79 # 音频最大播放时长
const RECHARGE_DELAY = 2.0 # 开始恢复播放时长的等待时间

var remaining_time = MAX_WHISTLE_TIME # 音频剩余时长
var is_pressing: bool = false # 汽笛是否被按下
var recharge_timer = 0.0 #充能等待计时器

func _on_button_button_down() -> void:
	if remaining_time > 0 and not is_pressing:
		is_pressing = true
		whistle_sound.play() # 打断充能等待
		recharge_timer = 0

func _on_button_button_up() -> void:
	is_pressing = false
	recharge_timer = 0  # 重新开始3秒等待
	whistle_sound.stop()

func _process(delta):
	if is_pressing == true:
		remaining_time -= delta
		if remaining_time <= 0:
			remaining_time = 0
			is_pressing = false
			whistle_sound.stop()
	else:
		if remaining_time < MAX_WHISTLE_TIME:
			recharge_timer += delta
			if recharge_timer >= RECHARGE_DELAY:
				remaining_time += delta
				remaining_time = min(remaining_time, MAX_WHISTLE_TIME)
	print("充能", recharge_timer)
