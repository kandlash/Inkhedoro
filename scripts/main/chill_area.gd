extends Node3D


@export var upgrade_cells: bool = false
@onready var omni_light_3d: OmniLight3D = $OmniLight3D
@onready var flicker_timer: Timer = $FlickerTimer
@onready var chill_area: Node3D = $"."
@onready var label: Label = $CanvasLayer/Label

var base_energy := 1.0
var base_range := 2.524

var healed = false

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var rest_button: Button = $CanvasLayer/Control/rest_button

func _ready() -> void:
	canvas_layer.visible = false
	rest_button.pressed.connect(_on_rest_button_pressed)
	
	omni_light_3d.visible = false
	flicker_timer.wait_time = 0.08
	flicker_timer.one_shot = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and !healed:
		omni_light_3d.visible = true
		canvas_layer.visible = true
		flicker_timer.start()
		G.player.arm_base.visible = false
		G.player.set_physics_process(false)
		G.player.velocity = Vector3.ZERO

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

func _on_rest_button_pressed():
	rest_button.disabled = true
	healed = true
	G.player.heal(G.player.max_hp)
	
	if upgrade_cells:
		G.grid.current_grid_level += 1
		label.text = "The scars on your arm are healing.\nAvailable cells: " + str(G.grid.current_grid_level)
		await get_tree().create_timer(3.5).timeout
	canvas_layer.visible = false
	G.player.arm_base.visible = true
	G.player.set_physics_process(true)
