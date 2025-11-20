extends AnimatedSprite2D

var eyes: Array[Sprite2D] = []
var shake_amount := 3.0

var base_position: Vector2

func _ready() -> void:
	base_position = position

	for child in get_children():
		if child is Sprite2D:
			eyes.append(child)

			# Сохраняем исходные параметры
			child.set_meta("base_scale", child.scale)
			child.set_meta("base_rot", child.rotation)

			# Рандомные параметры для каждого глаза
			child.set_meta("pulse_speed", randf_range(4.0, 10.0))
			child.set_meta("pulse_strength", randf_range(0.05, 0.15))
			child.set_meta("rot_strength", randf_range(0.01, 0.05))
			child.set_meta("phase_offset", randf_range(0.0, TAU))

func _process(delta: float) -> void:
	_apply_sprite_shake()
	_apply_eyes_effect()

func _apply_sprite_shake() -> void:
	# Дрожание без уплывания — всегда от base_position
	position = base_position + Vector2(
		randf_range(-shake_amount, shake_amount),
		randf_range(-shake_amount, shake_amount)
	)

func _apply_eyes_effect() -> void:
	var t = Time.get_ticks_msec() * 0.001

	for eye in eyes:
		var base_scale: Vector2 = eye.get_meta("base_scale")
		var base_rot: float = eye.get_meta("base_rot")

		var pulse_speed: float = eye.get_meta("pulse_speed")
		var pulse_strength: float = eye.get_meta("pulse_strength")
		var phase_offset: float = eye.get_meta("phase_offset")
		var rot_strength: float = eye.get_meta("rot_strength")

		# Индивидуальная пульсация размера
		var pulse = sin(t * pulse_speed + phase_offset) * pulse_strength
		eye.scale = base_scale * (1.0 + pulse)

		# Лёгкое индивидуальное дрожание вращением
		eye.rotation = base_rot + randf_range(-rot_strength, rot_strength)
