extends AnimatedSprite2D
class_name  RightAttack

signal right_attack_impacted
signal right_attack_finished

func _ready() -> void:
	G.right_attack = self

func animate_attack(speed) -> void:
	frame = randi_range(0, sprite_frames.get_frame_count("default"))
	var spr := self
	var start_pos := spr.position
	var start_scale := spr.scale
	var start_rot := spr.rotation

	# старт за кадром
	spr.scale = start_scale * 0.7
	#spr.modulate.a = 0
	spr.position = start_pos + Vector2(-20, 10)
	spr.rotation = start_rot + deg_to_rad(10)

	spr.visible = true

	# Вылет
	var t = create_tween()
	t.set_parallel(true)

	t.tween_property(spr, "modulate:a", 1.0, 0.1  * speed )
	t.tween_property(spr, "scale", start_scale * 0.75, 0.1 * speed).set_trans(Tween.TRANS_BACK)
	t.tween_property(spr, "position", start_pos, 0.1 * speed).set_trans(Tween.TRANS_SINE)
	t.tween_property(spr, "rotation", start_rot, 0.1 * speed)

	await t.finished
	
	var t2 = create_tween()
	t2.set_parallel(true)

	t2.tween_property(spr, "scale", start_scale * 0.15, 0.04 * speed).set_trans(Tween.TRANS_SPRING)
	t2.tween_property(spr, "rotation", start_rot + deg_to_rad(randf_range(-3, 3)), 0.04 * speed)
	
	await t2.finished
	
	emit_signal("right_attack_impacted")

	var t3 = create_tween()
	t3.set_parallel(true)

	t3.tween_property(spr, "scale", start_scale * 0.9, 0.15 * speed)
	t3.tween_property(spr, "modulate:a", 0.0, 0.15 * speed)
	t3.tween_property(spr, "position", start_pos + Vector2(10, -10), 0.15 * speed).set_trans(Tween.TRANS_SINE)

	await t3.finished

	spr.position = start_pos
	spr.scale = start_scale
	spr.rotation = start_rot
	spr.visible = false
	
	emit_signal("right_attack_finished")
