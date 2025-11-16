extends CharacterBody3D
@onready var arm_base: Control = $CanvasLayer/ArmBase
@onready var tattoo_pose: Control = $CanvasLayer/TattooPose
@export var speed: float = 1.5
@onready var head: Node3D = $head
@onready var camera_3d: Camera3D = $head/Camera3D

@export var max_look_angle := 15.0

@export var mouse_sensitivity := 0.2

var rotation_x := 0.0 # вверх-вниз
var rotation_y := 0.0 # влево-вправо

var arm_base_start_pos := Vector2.ZERO
var tattoo_pose_start_pos := Vector2.ZERO
var sway_amount := 25.0  # пиксели, можно регулировать

var last_mouse_pos := Vector2.ZERO
var breathing_time := 0.0
@export var breathing_strength := 6.0   # пиксели
@export var breathing_speed := 1.5      # скорость дыхания


func _ready():
	await get_tree().process_frame
	center_mouse()

func center_mouse():
	var viewport := get_viewport()
	var size := viewport.get_visible_rect().size
	var center := size * 0.5
	Input.warp_mouse(center)
	arm_base_start_pos = arm_base.position
	tattoo_pose_start_pos = tattoo_pose.position
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		arm_base.visible = !arm_base.visible
		tattoo_pose.visible = !tattoo_pose.visible

	var viewport := get_viewport()
	var mouse_pos := viewport.get_mouse_position()
	var size := viewport.get_visible_rect().size
	
	var nx := (mouse_pos.x / size.x) * 2.0 - 1.0
	var ny := (mouse_pos.y / size.y) * 2.0 - 1.0


	var mouse_delta := (mouse_pos - last_mouse_pos).length()
	last_mouse_pos = mouse_pos

	var is_mouse_moving := mouse_delta > 0.5  

	var target_x := -ny * max_look_angle
	var target_y := -nx * max_look_angle

	var current := head.rotation_degrees
	current.x = lerp(current.x, target_x, delta * 8.0)
	current.y = lerp(current.y, target_y, delta * 8.0)
	head.rotation_degrees = current


	var mouse_sway := Vector2(nx, ny) * sway_amount

	if not is_mouse_moving:
		breathing_time += delta * breathing_speed
	else:
		breathing_time = lerp(breathing_time, 0.0, delta * 5.0)

	var breathing_offset := Vector2(
		sin(breathing_time) * breathing_strength,
		cos(breathing_time * 0.8) * breathing_strength * 0.7
	)

	var final_offset := mouse_sway + breathing_offset

	var final_pos_arm := arm_base_start_pos + final_offset
	var final_pos_tattoo := tattoo_pose_start_pos + final_offset/2

	arm_base.position = arm_base.position.lerp(final_pos_arm, delta * 2.0)
	tattoo_pose.position = tattoo_pose.position.lerp(final_pos_tattoo, delta * 2.0)


func _physics_process(delta: float) -> void:
	var direction := Vector3.ZERO

	# Движение вперёд (W)
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z

	# Движение назад (S)
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.z

	# Нормализация чтобы скорость была одинаковая
	if direction != Vector3.ZERO:
		direction = direction.normalized()

	velocity = direction * speed
	move_and_slide()
