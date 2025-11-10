extends RigidBody2D

var fall_speed = 200

func _ready():
	# 初始化炸弹
	add_to_group("depth_charge")
	linear_velocity = Vector2(0, fall_speed)
	# body_entered.connect(_on_body_entered_depth_charger)

func _on_screen_exited():
	# 当炸弹离开屏幕时自动销毁
	queue_free()

# func _on_body_entered_depth_charger(body):
	# if body.is_in_group("submarine"):
	# 	body.take_damage_sunmarine(1)
	# 	queue_free() # 深水炸弹爆炸消失
