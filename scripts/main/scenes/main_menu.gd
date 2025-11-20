extends Control

@onready var texture_rect: TextureRect = $TextureRect
@onready var texture_rect_2: TextureRect = $TextureRect2

@export var scroll_speed: float = 200.0
@export var parallax_strength := 20.0  # насколько фон смещается от курсора

var viewport_center: Vector2

func _ready():
	var viewport := get_viewport()
	viewport_center = viewport.get_visible_rect().size * 0.5
	print(viewport_center)
	Input.warp_mouse(viewport_center)

func _process(delta: float) -> void:
	var viewport := get_viewport()
	var mouse_pos := viewport.get_mouse_position()

	# нормализованное смещение мыши от центра [-1, 1]
	var offset := (mouse_pos - viewport_center) / viewport_center
	offset.x = clamp(offset.x, -1, 1)
	offset.y = clamp(offset.y, -1, 1)

	# === Скроллим вниз ===
	texture_rect.position.y += scroll_speed * delta
	texture_rect_2.position.y += scroll_speed * delta

	var height = texture_rect.get_rect().size.y
	if texture_rect.position.y >= height:
		texture_rect.position.y = texture_rect_2.position.y - height
	if texture_rect_2.position.y >= height:
		texture_rect_2.position.y = texture_rect.position.y - height

	# === Параллакс по X (мышь вправо → фон чуть влево) ===
	var parallax_x := -offset.x * parallax_strength

	# плавное смещение
	texture_rect.position.x = lerp(texture_rect.position.x, parallax_x, delta * 5.0)
	texture_rect_2.position.x = lerp(texture_rect_2.position.x, parallax_x, delta * 5.0)

	# === Переход по клику ===
	if Input.is_action_just_pressed("left_click") or Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/levels/first_cutscene.tscn")
