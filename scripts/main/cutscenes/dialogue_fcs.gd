extends RichTextLabel

@export_multiline var dialogue: Array[String]
var current_index = 0
var dialogue_started = false

signal dialogue_ended

func _ready() -> void:
	clear()

func start_dialogue():
	dialogue_started = true
	show_dialogue()

func _process(_delta: float) -> void:
	if !dialogue_started:
		return
	if Input.is_action_just_pressed("ui_accept"):
		show_dialogue()

func show_dialogue():
	if current_index >= dialogue.size():
		clear()
		emit_signal("dialogue_ended")
		dialogue_started = false
		return
	
	clear()
	visible_ratio = 0
	append_text(dialogue[current_index])

	var tween = create_tween()
	tween.tween_property(self, "visible_ratio", 1.0, 0.35)

	current_index += 1
