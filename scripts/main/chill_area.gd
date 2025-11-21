extends Node3D

@onready var omni_light_3d: OmniLight3D = $OmniLight3D
@onready var flicker_timer: Timer = $FlickerTimer

var base_energy := 1.0
var base_range := 2.524

func _ready() -> void:
	omni_light_3d.visible = false
	flicker_timer.wait_time = 0.08
	flicker_timer.one_shot = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		omni_light_3d.visible = true
		flicker_timer.start()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		omni_light_3d.visible = false
		flicker_timer.stop()
		omni_light_3d.light_energy = base_energy
		omni_light_3d.omni_range = base_range


func _on_flicker_timer_timeout() -> void:
	var e = base_energy + randf_range(-0.7, 0.8)
	var r = base_range + randf_range(-0.7, 0.7)

	omni_light_3d.light_energy = e
	omni_light_3d.omni_range = r
