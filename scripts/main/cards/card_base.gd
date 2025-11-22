extends Node2D
class_name CardBase

@export_category("Data")
@export var card_name: String
@export_multiline var description: String
var description_template: String

@export var cells_to_feel: int

@export_category("Stats")
@export var basic_damage := 0
var extra_damage := 0


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
@onready var desc_label: RichTextLabel = $Card_UI/Desc

var start_position
var on_arm: bool = false
@onready var center: Node2D = $Center

signal card_taked
signal card_selected
signal card_dropped
signal card_deselected
signal card_grid_exited
signal card_grid_entered

var selected := false
var start_z: int
var start_scale: Vector2

var in_grid_area = false

signal on_arm_drawed

@onready var cells: Node2D = $Cells

@onready var neighbor_finder: Node2D = $NeighborFinder
@onready var texture: Sprite2D = $Texture

@export var synergy_texture: Texture2D
var standart_texture: Texture2D
var card_ui_get_back_position: Vector2

var extra_replacements := {}

var is_reward: = false
var reward_index: int
signal card_click

var _regex := RegEx.new()

func _ready():
	standart_texture = texture.texture
	if synergy_texture == null: synergy_texture = standart_texture
	name_label.text = card_name

	description_template = description
	_regex.compile(r"\{([a-zA-Z_0-9]+)\}")

	refresh_description()
	cells.visible = false
	start_position = global_position
	start_scale = scale
	for child in get_children():
		if child is Area2D:
			var area: Area2D = child
			self_areas.append(area)	
			area.connect("area_entered", _on_area_feel)
			area.connect("area_exited", _on_area_exit)



func refresh_description():
	desc_label.clear()
	desc_label.append_text(get_final_description())


func set_extra_value(key: String, value):
	extra_replacements[key] = value
	refresh_description()


func clear_extra_value(key: String):
	if key in extra_replacements:
		extra_replacements.erase(key)
	refresh_description()


func has_property_name(_name: String) -> bool:
	return get_property_list().any(func(p): return p.name == _name)


func get_final_description() -> String:
	var result := description_template

	var matches := _regex.search_all(description_template)
	for m in matches:
		var key := m.get_string(1)

		# 1. ПРИОРИТЕТ: extra_value
		if key in extra_replacements:
			var v = extra_replacements[key]
			result = result.replace("{" + key + "}", str(v))
			continue

		# 2. Свойства карточки (damage, block, turns, etc)
		if has_property_name(key):
			var value = get(key)
			result = result.replace("{" + key + "}", str(value))
			continue

		# 3. Если ключ не найден
		result = result.replace("{" + key + "}", "")

	return result

func use(speed):
	var tween = create_tween()
	var card_start_scale = scale
	tween.tween_property(self, "scale", card_start_scale * 1.5, 0.07 * speed).set_trans(Tween.TRANS_SPRING)
	await tween.finished

	var tween22 = create_tween()
	tween22.tween_property(self, "scale", card_start_scale, 0.15 * speed).set_trans(Tween.TRANS_SPRING)
	await tween22.finished
	await get_tree().create_timer(0.15 * speed).timeout

func make_effect():
	pass

func upgrage(_value):
	pass

func make_damage(speed):
	G.right_arm.visible = false
	G.hand.visible = false
	G.right_attack.animate_attack(speed)
	await G.right_attack.right_attack_impacted
	
	G.camera.shake(0.15, 0.1)
	G.current_enemy.take_damage(basic_damage + extra_damage)
	extra_damage = 0
	
	await G.right_attack.right_attack_finished
	G.right_arm.visible = true
	G.hand.visible = true

func on_arm_effect():
	pass

func on_synergy_ui_update(synergy: bool, value):
	texture.texture = synergy_texture if synergy else standart_texture

	synergy_popup(synergy)
	if synergy:
		var c = "+" if value > 0 else "-"
		var t = "[color=red]" + c + str(abs(value)) + "[/color]"
		set_extra_value("_extra_value", t)
	else:
		clear_extra_value("_extra_value")

func synergy_popup(synergy: bool):
	pass

func on_synergy_effect():
	pass

func find_neighbor_cards() -> Array[CardBase]:
	var neighbors: Array[CardBase] = []
	for area: Area2D in neighbor_finder.get_children():
		for overlap in area.get_overlapping_areas():
			if overlap.is_in_group("tattoo_area") and overlap.get_parent() != self:
				neighbors.append(overlap.get_parent())
	return neighbors

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
	@warning_ignore("incompatible_ternary")
	var check_rect = back if !on_arm else texture
	if event is InputEventMouse:
		if check_rect.get_rect().has_point(to_local(event.position)) \
			and !selected and G.selected_card == null:
			if !is_reward:
				G.selected_card = self
				emit_signal("card_selected", self)
				selected = true
				if self is SynergyCardBase and in_grid_area:
					neighbor_finder.visible = true
				start_z = z_index
				z_index = 100
				scale = start_scale * 1.1
				
				if !in_grid_area:
					position.y -= 80
				else:
					G.card_info_ui.show_data(card_name, get_final_description(), standart_texture)
			else:
				G.selected_card = self
				selected = true
				start_z = z_index
				z_index = 100
				scale = start_scale * 1.1
				
		elif !check_rect.get_rect().has_point(to_local(event.position)) \
			and selected and G.selected_card == self:
			if !is_reward:
				G.selected_card = null
				emit_signal("card_deselected", self)
				selected = false
				neighbor_finder.visible = false
				z_index = start_z
				scale = start_scale
				if !in_grid_area:
					position.y += 80
				else:
					G.card_info_ui.hide_data()
			else:
				G.selected_card = null
				selected = false
				z_index = start_z
				scale = start_scale
				

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if is_reward and event.pressed:
				emit_signal('card_click')
				return
			if event.pressed:
				if check_rect.get_rect().has_point(to_local(event.position)) and G.selected_card == self:
					global_position = event.global_position
					emit_signal("card_taked", self)
					if in_grid_area:
						cells.visible = true
					dragging = true
					drag_offset = position - event.position
					if on_arm:
						G.card_info_ui.hide_data()
						on_arm = false
						for area in feeled_areas:
							G.used_grids.erase(area)
			elif !event.pressed and dragging:
				dragging = false
				neighbor_finder.visible = false
				cells.visible = false
				G.selected_card = null
				selected = false
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
					on_arm_effect()
					emit_signal("on_arm_drawed")
					card_ui.visible = false
				else:
					global_position = start_position
				emit_signal("card_dropped", self)
				card_ui.visible = !on_arm
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

func _on_collide_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("grid_collide") and dragging:
		G.emit_signal("card_in_grid_arrived")
		emit_signal("card_grid_entered", self)
		card_ui.visible = false
		in_grid_area = true
		cells.visible = true
		if self is SynergyCardBase: neighbor_finder.visible = true


func _on_collide_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("grid_collide") and dragging:
		emit_signal("card_grid_exited", self)
		card_ui.visible = true
		in_grid_area = false
		cells.visible = false
		neighbor_finder.visible = false
