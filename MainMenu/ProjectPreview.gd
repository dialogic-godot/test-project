extends Panel

@export var image : Texture = null
@export var title := ""

signal pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Image.texture = image
	$ColorRect/Name.text = title
	await get_tree().process_frame
	$Image.pivot_offset = $Image.size/2


func _gui_input(_event:InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		pressed.emit()
		accept_event()

func _input(event:InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed \
		and get_global_rect().has_point(get_global_mouse_position()) \
		and is_visible_in_tree():
		pressed.emit()


func _on_color_rect_mouse_exited() -> void:
	var tween := create_tween()
	tween.tween_property($Image, 'scale', Vector2(1,1), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func _on_color_rect_mouse_entered() -> void:
	$Image.pivot_offset = $Image.size/2
	var tween := create_tween()
	tween.tween_property($Image, 'scale', Vector2(1.1,1.1), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func _on_focus_entered() -> void:
	_on_color_rect_mouse_entered()
	$ColorRect/Name.modulate = Color.ORANGE


func _on_focus_exited() -> void:
	_on_color_rect_mouse_exited()
	$ColorRect/Name.modulate = Color.WHITE

