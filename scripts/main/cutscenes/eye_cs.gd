extends Sprite3D

@export var shake_amount: float = 0.15
@export var shake_speed: float = 25.0
@export var move_duration: float = 15.0   # за сколько секунд доехать

var start_position = Vector3(-1.471, 75.943, -38.104)
var end_position   = Vector3(-1.471, 22.034,  -6.253)

var t := 0.0
var time_offset := randf() * 200.0

func _ready():
	position = start_position

func _process(delta):
	if t < 1.0:
		t += delta / move_duration
		t = clamp(t, 0.0, 1.0)

	var base_pos := start_position.lerp(end_position, t)

	var tt = Time.get_ticks_msec() * 0.001

	var shake := Vector3(
		sin(tt * shake_speed + time_offset * 1.1),
		sin(tt * shake_speed * 1.4 + time_offset * 0.3),
		sin(tt * shake_speed * 0.7 + time_offset * 2.2)
	) * shake_amount

	position = base_pos + shake
