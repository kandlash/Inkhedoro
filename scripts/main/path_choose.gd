extends Node3D
class_name PathChoose
@export var right_path_texture: Texture2D
@export var left_path_texture: Texture2D

@onready var right_path_icon: Sprite3D = $right_sign/path_icon
@onready var left_path_icon: Sprite3D = $left_sign/path_icon
@onready var control: Control = $Control

@export var point_left: Node3D
@export var point_right: Node3D

func _ready() -> void:
	right_path_icon.texture = right_path_texture
	left_path_icon.texture = left_path_texture
	control.visible = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		control.visible = true
		G.player.velocity = Vector3.ZERO
		G.player.set_physics_process(false)


func _on_left_pressed() -> void:
	control.visible = false
	var tween = create_tween()
	tween.tween_property(G.player,
		"global_position",
		Vector3(point_left.global_position.x, G.player.global_position.y, point_left.global_position.z),
		0.25
	)
	var tween2 = create_tween()
	tween2.tween_property(G.player,
		"global_rotation",
		point_left.global_rotation,
		0.25
	)
	await tween2.finished
	
	G.player.set_physics_process(true)


func _on_right_pressed() -> void:
	control.visible = false
	var tween = create_tween()
	tween.tween_property(G.player,
		"global_position",
		Vector3(point_right.global_position.x, G.player.global_position.y, point_right.global_position.z),
		0.25
	)
	var tween2 = create_tween()
	tween2.tween_property(G.player,
		"global_rotation",
		point_right.global_rotation,
		0.25
	)
	await tween2.finished
	G.player.set_physics_process(true)
