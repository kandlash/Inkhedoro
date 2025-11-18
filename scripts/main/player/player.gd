extends CharacterBody3D
class_name Player
@onready var arm_base: Control = $CanvasLayer/ArmBase
@onready var tattoo_pose: Control = $CanvasLayer/TattooPose
@onready var head: Node3D = $head
@onready var camera_3d: Camera3D = $head/Camera3D


@export_category("Stats")
@export var hp : int = 10
var max_hp: int
@export var base_damage: int = 1
@export var block: int = 0

@export var bleed_turns: int = 0
var bleed_damage: int = 0

var vulnarable_turns: int = 0
@export var vulnarable_damage: float = 0.0

signal hp_updated

@export_category("Movement")
@export var speed: float = 1.5
@export var max_look_angle := 15.0
@export var mouse_sensitivity := 0.2

var rotation_x := 0.0
var rotation_y := 0.0

var arm_base_start_pos := Vector2.ZERO
var tattoo_pose_start_pos := Vector2.ZERO
var sway_amount := 25.0

var last_mouse_pos := Vector2.ZERO
var breathing_time := 0.0
@export var breathing_strength := 6.0
@export var breathing_speed := 1.5

var walk_time := 0.0
@export var walk_strength := 12.0
@export var walk_speed := 8.0

func _ready():
	G.player = self
	max_hp = hp
	await get_tree().process_frame
	center_mouse()
	G.emit_signal("player_spawned")

func center_mouse():
	var viewport := get_viewport()
	var size := viewport.get_visible_rect().size
	var center := size * 0.5
	Input.warp_mouse(center)
	arm_base_start_pos = arm_base.position
	tattoo_pose_start_pos = tattoo_pose.position

func take_damage(amount: int):
	hp -= amount
	if hp < 0:
		hp = 0
	emit_signal("hp_updated")

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

	if not is_mouse_moving and velocity.length() < 0.1:
		breathing_time += delta * breathing_speed
	else:
		breathing_time = lerp(breathing_time, 0.0, delta * 5.0)

	var breathing_offset := Vector2(
		sin(breathing_time) * breathing_strength,
		cos(breathing_time * 0.8) * breathing_strength * 0.7
	)

	var walk_offset := Vector2.ZERO
	if velocity.length() > 0.1:
		walk_time += delta * walk_speed
		walk_offset = Vector2(
			sin(walk_time) * walk_strength,      # влево / вправо
			abs(cos(walk_time)) * walk_strength  # вверх / вниз
		)
	else:
		walk_time = lerp(walk_time, 0.0, delta * 3.0)

	var mouse_sway := Vector2(nx, ny) * sway_amount
	var final_offset := breathing_offset + mouse_sway + walk_offset
	arm_base.position = arm_base.position.lerp(arm_base_start_pos + final_offset, delta * 6.0)
	tattoo_pose.position = tattoo_pose.position.lerp(tattoo_pose_start_pos + final_offset/2, delta * 6.0)

func _physics_process(delta: float) -> void:
	var direction := Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.z

	if direction != Vector3.ZERO:
		direction = direction.normalized()

	velocity = direction * speed
	move_and_slide()
