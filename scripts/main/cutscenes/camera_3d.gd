extends Camera

@onready var arm_base: Control = $"../../CanvasLayer/arm_base"

# Параметры вращения камеры
@export var max_look_angle := 8.0
@export var look_lerp_speed := 8.0

# Параметры UI sway
@export var sway_amount := 25.0
@export var breathing_strength := 6.0
@export var breathing_speed := 1.5

var arm_base_start_pos: Vector2
var last_mouse_pos := Vector2.ZERO
var breathing_time := 0.0

func _ready():
	super._ready()
	arm_base_start_pos = arm_base.position

func _process(delta):
	super._process(delta)
	# === Мышь и нормализованные координаты ===
	var viewport := get_viewport()
	var mouse_pos := viewport.get_mouse_position()
	var size := viewport.get_visible_rect().size

	var nx := (mouse_pos.x / size.x) * 2.0 - 1.0
	var ny := (mouse_pos.y / size.y) * 2.0 - 1.0

	# === Поворот камеры ===
	var target_x := -ny * max_look_angle
	var target_y := -nx * max_look_angle

	var current_rot := rotation_degrees
	current_rot.x = lerp(current_rot.x, target_x, delta * look_lerp_speed)
	current_rot.y = lerp(current_rot.y, target_y, delta * look_lerp_speed)
	rotation_degrees = current_rot

	# === Эффект "дыхания" для интерфейса ===
	var mouse_delta := (mouse_pos - last_mouse_pos).length()
	var is_mouse_moving := mouse_delta > 0.5
	last_mouse_pos = mouse_pos

	if not is_mouse_moving:
		breathing_time += delta * breathing_speed
	else:
		breathing_time = lerp(breathing_time, 0.0, delta * 5.0)

	var breathing_offset := Vector2(
		sin(breathing_time) * breathing_strength,
		cos(breathing_time * 0.8) * breathing_strength * 0.7
	)

	# === Смещение UI за мышью ===
	var mouse_sway := Vector2(nx, ny) * sway_amount

	var final_offset := breathing_offset + mouse_sway

	arm_base.position = arm_base.position.lerp(
		arm_base_start_pos + final_offset,
		delta * 6.0
	)
