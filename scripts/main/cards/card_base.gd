extends Sprite2D
class_name CardBase


@export var card_name: String
@export_multiline var description: String

@export var cells_to_feel: int
var self_areas: Array[Area2D] = []
var feeled_areas: Array[Area2D] = []

var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

const TATTOO_FRAME = preload("uid://0koxmjyxn077")
const TATTOO_FRAME_USED = preload("uid://clgs11mmp0mav")
const TATTOO_SELECETED = preload("uid://sg7qtxtecnsu")
@onready var card_ui: Control = $Card_UI
@onready var back: TextureRect = $Card_UI/Back
@onready var name_label: Label = $Card_UI/Name
@onready var desc_label: Label = $Card_UI/Desc

var start_position
var on_arm: bool = false
@onready var center: Node2D = $Center

signal card_taked
signal card_selected
signal card_dropped
signal card_deselected

var selected := false

@onready var cells: Node2D = $Cells

func _ready() -> void:
	name_label.text = card_name
	desc_label.text = description
	
	cells.visible = false
	start_position = global_position
	for child in get_children():
		if child is Area2D:
			var area: Area2D = child
			self_areas.append(area)
			area.connect("area_entered", _on_area_feel)
			area.connect("area_exited", _on_area_exit)

func _on_area_feel(area: Area2D):
	if !area.is_in_group("grid_cells"):
		return
	if G.used_grids.has(area):
		return
	if not feeled_areas.has(area):
		feeled_areas.append(area)
		var sprite: Sprite2D = area.get_parent()
		sprite.texture = TATTOO_SELECETED

func _on_area_exit(area: Area2D):
	if !area.is_in_group("grid_cells"):
		return
	if G.used_grids.has(area):
		return
	for a: Area2D in self_areas:
		if a.get_overlapping_areas().has(area):
			return
	feeled_areas.erase(area)
	var sprite: Sprite2D = area.get_parent()
	sprite.texture = TATTOO_FRAME
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		if back.get_rect().has_point(to_local(event.position)) and !selected:
			emit_signal("card_selected", self)
			selected = true
		elif !back.get_rect().has_point(to_local(event.position)) and selected:
			emit_signal("card_deselected", self)
			selected = false

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if back.get_rect().has_point(to_local(event.position)) and G.selected_card == null:
					G.selected_card = self
					card_ui.visible = false
					emit_signal("card_taked", self)
					cells.visible = true
					dragging = true
					drag_offset = position - event.position
					if on_arm:
						on_arm = false
						for area in feeled_areas:
							G.used_grids.erase(area)
			elif !event.pressed and dragging:
				dragging = false
				card_ui.visible = true
				cells.visible = false
				G.selected_card = null
				if (feeled_areas.size() >= cells_to_feel) and check_cells_for_other():
					var closest_distance = INF
					var closest_pos = Vector2.ZERO
					for area in feeled_areas:
						var cell_pos = area.get_child(0).global_position
						var dist = cell_pos.distance_to(center.global_position)  # расстояние до центра
						if dist < closest_distance:
							closest_distance = dist
							closest_pos = cell_pos
					global_position = closest_pos - (center.global_position - global_position)
					await get_tree().create_timer(0.1).timeout
					if feeled_areas.size() < cells_to_feel:
						global_position = start_position
						return
					for area: Area2D in feeled_areas:
						area.get_parent().texture = TATTOO_FRAME_USED
					G.used_grids.append_array(feeled_areas)
					on_arm = true
					card_ui.visible = false
				else:
					global_position = start_position
				emit_signal("card_dropped", self)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed and dragging:
				rotate(deg_to_rad(90))

func check_cells_for_other():
	for area in self_areas:
		for ao in area.get_overlapping_areas():
			if ao.is_in_group("tattoo_area"):
				return false
	return true

func _process(_delta: float) -> void:
	if dragging:
		position = get_global_mouse_position() + drag_offset
