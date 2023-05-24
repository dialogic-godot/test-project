extends Control

enum SizingModes {AdjustAlways, AdjustOnStart, Fixed}
var sizing_mode: SizingModes = SizingModes.AdjustOnStart

var max_width :float= 0
var max_lines : int= 10

@onready var tail : Line2D = $Tail
@onready var bubble : Control = $Background
var speaker_node : Node = null

signal letter_appeared(letter : String, index : int)
signal vowel_appeared
signal speech_ended

var _is_open := false
var _text_tween : Tween = null
var _last_pos := -1

var bubble_rect : Rect2 = Rect2(0.0, 0.0, 2.0, 2.0)
var bubble_ratio = Vector2.ONE
var base_position = Vector2.ZERO

var base_direction = Vector2(1.0, -1.0).normalized()
var safe_zone = 50.0

func _ready() -> void:
#	%DialogText.resized.connect(_resize_bubble)
	scale = Vector2.ZERO
	modulate.a = 0.0
	if speaker_node: 
		position = speaker_node.get_global_transform_with_canvas().origin

func _process(delta):
	if speaker_node: 
		base_position = speaker_node.get_global_transform_with_canvas().origin
	
	var center = get_viewport_rect().size / 2.0
	
	var dist_x = abs(base_position.x - center.x)
	var dist_y = abs(base_position.y - center.y)
	var x_e = center.x - bubble_rect.size.x
	var y_e = center.y - bubble_rect.size.y
	var influence_x = remap(clamp(dist_x, x_e, center.x), x_e, center.x * 0.8, 0.0, 1.0)
	var influence_y = remap(clamp(dist_y, y_e, center.y), y_e, center.y * 0.8, 0.0, 1.0)
	if base_position.x > center.x: influence_x = -influence_x
	if base_position.y > center.y: influence_y = -influence_y
	var edge_influence = Vector2(influence_x, influence_y)
	
	var direction = (base_direction + edge_influence).normalized()
	
	var p : Vector2 = base_position + direction * (safe_zone + lerp(bubble_rect.size.y, bubble_rect.size.x, abs(direction.x)) * 0.4)
	p = p.clamp(bubble_rect.size / 2.0, get_viewport_rect().size - bubble_rect.size / 2.0)
	
#	position = base_position
	position = lerp(position, p, 10.0 * delta)
	
	var point_a : Vector2 = Vector2.ZERO
	var point_b : Vector2 = (base_position - position) * 0.5
	
	var offset = Vector2.from_angle(point_a.angle_to_point(point_b)) * bubble_rect.size * abs(direction.x) * 0.4
	
	point_a += offset
	point_b += offset * 0.5
	
	var curve = Curve2D.new()
	var direction_point = Vector2(0, (point_b.y - point_a.y))
	curve.add_point(point_a, Vector2.ZERO, direction_point * 0.5)
	curve.add_point(point_b)
	tail.points = curve.tessellate(5)
	tail.width = bubble_rect.size.x * 0.15


func open() -> void:
	show()
	_is_open = true
	%DialogText.enabled = true
	var open_tween := create_tween().set_parallel(true)
	open_tween.tween_property(self, "scale", Vector2.ONE, 0.1).from(Vector2.ZERO)
	open_tween.tween_property(self, "modulate:a", 1.0, 0.1).from(0.0)
	


func close() -> void:
	_is_open = false
	%DialogText.enabled = false
	var close_tween := create_tween().set_parallel(true)
	close_tween.tween_property(self, "scale", Vector2.ONE * 0.8, 0.1)
	close_tween.tween_property(self, "modulate:a", 0.0, 0.1)
	await close_tween.finished
	hide()

func _resize_bubble() -> void:
	var bubble_size = %DialogText.size+Vector2(20,20)
	var half_size = (bubble_size / 2.0)
	%DialogText.pivot_offset = half_size
	bubble.pivot_offset = half_size
	
	bubble_rect = Rect2(position, bubble_size * Vector2(1.1, 1.1))
	
	var t := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	t.tween_property(bubble, "custom_minimum_size", bubble_rect.size, 0.2)
	
	# set bubble's ratio
	bubble_ratio = Vector2.ONE
	if bubble_rect.size.x < bubble_rect.size.y:
		bubble_ratio.y = bubble_rect.size.y / bubble_rect.size.x
	else:
		bubble_ratio.x = bubble_rect.size.x / bubble_rect.size.y
	
	bubble.material.set("shader_parameter/ratio", bubble_ratio)



func _on_DialogText_continued_revealing_text(new_character = ""):
	if sizing_mode == SizingModes.AdjustAlways:
		var font = %DialogText.get_theme_font("normal_font")
		var line_height = font.get_height()
		
		%DialogText.size = font.get_string_size(%DialogText.text.substr(0, %DialogText.visible_characters))
#		var longest_line_len = 0
#		var lines = 0
#		for line in %DialogText.text.substr(0, %DialogText.visible_characters).split("\n"):
#			longest_line_len = font.get_string_size(line).x if font.get_string_size(line).x > longest_line_len else longest_line_len
#			if font.get_string_size(line).x > max_width-60:
#				lines += ceil(font.get_string_size(line).x/(max_width-60))-1
#			lines += 1
#
#		print(longest_line_len)
#		print(lines)
#
#		# because there is a margin and a number inside the stylebox (especially to the left) this needs to be added 
#		longest_line_len += 100
#		if sizing_mode == SizingModes.AdjustAlways:
#			%DialogText.size.x = min(max_width, longest_line_len)
#			# a margin has to be added vertically as well because of the stylebox
#			%DialogText.size.y = line_height*min(lines, max_lines)+20
#			# Enable Scroll bar when more then max lines
#			%DialogText.scroll_active = lines > max_lines
#
#		elif lines*line_height+40 > %DialogText.size.y:
#			%DialogText.scroll_active = true

	if %DialogText.scroll_active:
#		$DialogText.get_v_scroll_bar().position.x = $DialogText.size.x-20
#		$DialogText.get_v_scroll_bar().margin_right = -20
		%DialogText.scroll_to_line(%DialogText.get_line_count())
	_resize_bubble()


func _on_dialog_text_started_revealing_text():
	if sizing_mode == SizingModes.AdjustOnStart:
		var font = %DialogText.get_theme_font("normal_font")
		var line_height = font.get_height()
		%DialogText.size = font.get_string_size(%DialogText.get_parsed_text())
		if Dialogic.Choices.is_question(Dialogic.current_event_idx):
			%DialogText.size.y += 30
		%DialogText.position = -%DialogText.size/2
		
#		var longest_line_len = 0
#		var lines = 0
#		for line in %DialogText.text.split("\n"):
#			longest_line_len = font.get_string_size(line).x if font.get_string_size(line).x > longest_line_len else longest_line_len
#			if font.get_string_size(line).x > max_width-60:
#				lines += ceil(font.get_string_size(line).x/(max_width-60))-1
#			lines += 1
#
#		# because there is a margin and a number inside the stylebox (especially to the left) this needs to be added 
#		longest_line_len += 100
#		%DialogText.size.x = min(max_width, longest_line_len)
#		# a margin has to be added vertically as well because of the stylebox
#		%DialogText.size.y = line_height*min(lines, max_lines)
#		if Dialogic.Choices.is_question(Dialogic.current_event_idx):
#			%DialogText.size.y += 80
#			%DialogText.offset_bottom = -25
#
#		# Enable Scroll bar when more then max lines
#		%DialogText.scroll_active = lines > max_lines
#
#		if lines*line_height+40 > %DialogText.size.y:
#			%DialogText.scroll_active = true
	else:
		%DialogText.offset_bottom = -7
	_resize_bubble()

func _on_dialog_text_finished_revealing_text():
	if sizing_mode == SizingModes.AdjustAlways:
		if Dialogic.Choices.is_question(Dialogic.current_event_idx):
			%DialogText.offset_bottom = -25
		else:
			%DialogText.offset_bottom = -7
