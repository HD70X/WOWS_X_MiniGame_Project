extends Node2D

@onready var smoke_particles = $SmokeParticles
@onready var click_area = $ChimneyClickArea

func _ready():
	pass

func _on_chimney_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		smoke_particles.emitting = true
