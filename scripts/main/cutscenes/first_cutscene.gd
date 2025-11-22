extends Node3D
@onready var blink_rect: ColorRect = $CanvasLayer/BlinkRect
@onready var cut_self: AnimatedSprite2D = $CanvasLayer/arm_base/CutSelf
@onready var right_arm: AnimatedSprite2D = $CanvasLayer/arm_base/RightArm
@onready var eye: Sprite3D = $Eye
@onready var dialogue: RichTextLabel = $CanvasLayer/Dialogue
@onready var continue_tip: Label = $CanvasLayer/ContinueTip
@onready var animation_player: AnimationPlayer = $CanvasLayer/AnimationPlayer
var cut_frame = 0
@export var cut_frame_to_effect = 5
@onready var intro_music: AudioStreamPlayer = $IntroMusic
@onready var world_environment: WorldEnvironment = $WorldEnvironment

var skip_time = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	cut_self.connect("frame_changed", _on_cut_frame_changed)
	continue_tip.visible = false
	dialogue.connect("dialogue_ended", _on_dialogue_end)
	var tween = create_tween()
	tween.tween_property(world_environment.environment, "fog_density", 0.1, 15.0)
	
	
func _process(_delta: float) -> void:
	if cut_frame >= cut_frame_to_effect and cut_frame > 0:
		cut_frame = -1
		G.camera.shake(0.25, 0.4)
	if Input.is_action_pressed("skip"):
		skip_time += _delta
	if Input.is_action_just_released("skip"):
		skip_time = 0
	if skip_time >= 2.5:
		get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")

func _on_dialogue_end():
	continue_tip.visible = false
	animation_player.play("fade_out")
	right_arm.visible = false
	cut_self.visible = true
	world_environment.environment.fog_density = 0.2
	G.camera.shake(0.07, 1.0)
	await animation_player.animation_finished
	
	cut_self.start_shake(2.0)
	await cut_self.shake_finished
	cut_self.play("cut")
	await cut_self.animation_finished
	animation_player.play("blink")
	var tween2 = create_tween()
	tween2.tween_property(intro_music, "volume_db", -80.0, 1.0)
	await animation_player.animation_finished
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "blinking":
		await get_tree().create_timer(1.5).timeout
		continue_tip.visible = true
		dialogue.start_dialogue()
	
func _on_cut_frame_changed():
	cut_frame += 1
