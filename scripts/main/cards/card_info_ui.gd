extends Control
class_name CardInfo

@onready var back: TextureRect = $Back
@onready var image: TextureRect = $Image
@onready var name_label: Label = $Name
@onready var desc: RichTextLabel = $Desc


func _ready() -> void:
	visible = false
	G.card_info_ui = self

func show_data(_name, _desc, _texture: Texture2D):
	visible = true
	name_label.text = _name
	image.texture = _texture
	desc.clear()
	desc.append_text(_desc)

func hide_data():
	desc.clear()
	visible = false
