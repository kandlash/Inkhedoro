extends AnimatedSprite2D

signal shake_finished

@export var shake_amount := 3.0

var base_position: Vector2
var shake_timer := 0.0

func _ready() -> void:
	base_position = position

# Запускаем дрожание на определённое время
func start_shake(duration: float) -> void:
	shake_timer = duration

func _process(delta: float) -> void:
	if shake_timer > 0.0:
		_apply_sprite_shake()
		shake_timer -= delta
		if shake_timer <= 0.0:
			position = base_position   # возвращаем в исходное положение
			emit_signal("shake_finished")

# Применение дрожания
func _apply_sprite_shake() -> void:
	position = base_position + Vector2(
		randf_range(-shake_amount, shake_amount),
		randf_range(-shake_amount, shake_amount)
	)
