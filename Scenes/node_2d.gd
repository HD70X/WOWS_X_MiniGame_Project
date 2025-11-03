extends Node2D
@onready var click_area = $Area2D

func _ready():
	print("Chimney 节点初始化")
	click_area.mouse_entered.connect(_on_mouse_entered)
	click_area.mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	print("🖱️ 鼠标进入烟囱区域")

func _on_mouse_exited():
	print("🖱️ 鼠标离开烟囱区域")
