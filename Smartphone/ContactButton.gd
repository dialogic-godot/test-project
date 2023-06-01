extends VBoxContainer

@export var image : Texture = null

signal pressed(contact)

var selected := false:
	set(value):
		selected = value
		if get_global_rect().has_point(get_global_mouse_position()):
			_on_mouse_entered()
		else:
			_on_mouse_exited()


func _ready():
	%Image.texture = image
	$Name.text = name


func _gui_input(event):
	if Input.is_action_just_pressed("ui_accept"):
		pressed.emit(name)
		accept_event()


func _input(event):
	if visible and event is InputEventMouseButton and event.pressed and get_global_rect().has_point(get_global_mouse_position()):
		pressed.emit(name)


func _on_mouse_entered():
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	if selected:
		tween.tween_property(self, 'modulate', Color.DARK_ORANGE, 0.1)
	else:
		tween.tween_property(self, 'modulate', Color.LIGHT_SALMON, 0.1)


func _on_mouse_exited():
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	if selected:
		tween.tween_property(self, 'modulate', Color.ORANGE, 0.1)
	else:
		tween.tween_property(self, 'modulate', Color.WHITE, 0.1)


func _on_focus_entered():
	pass # Replace with function body.


func _on_focus_exited():
	pass # Replace with function body.
