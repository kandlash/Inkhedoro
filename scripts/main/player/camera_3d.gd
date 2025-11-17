extends Camera3D
class_name Camera

var shake_strength := 0.0
var shake_time := 0.0
var shake_timer := 0.0

func _ready() -> void:
	G.camera = self

func shake(strength: float, duration: float) -> void:
	shake_strength = strength
	shake_time = duration
	shake_timer = duration


func _process(delta: float) -> void:
	if shake_timer > 0.0:
		shake_timer -= delta

		var fade := shake_timer / shake_time

		var offset_strength = shake_strength * fade

		var offset = Vector3(
			randf_range(-offset_strength, offset_strength),
			randf_range(-offset_strength, offset_strength),
			randf_range(-offset_strength * 0.5, offset_strength * 0.5)
		)

		var rot = Vector3(
			randf_range(-offset_strength * 0.6, offset_strength * 0.6),
			randf_range(-offset_strength * 0.6, offset_strength * 0.6),
			randf_range(-offset_strength * 0.3, offset_strength * 0.3)
		)

		global_transform = get_parent().global_transform
		global_transform.origin += offset
		rotate_object_local(Vector3(1,0,0), rot.x)
		rotate_object_local(Vector3(0,1,0), rot.y)
		rotate_object_local(Vector3(0,0,1), rot.z)
	else:
		global_transform = global_transform.interpolate_with(get_parent().global_transform, delta * 8)
