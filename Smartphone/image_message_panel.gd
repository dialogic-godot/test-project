extends Panel

signal open_image(image)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if $Image.get_global_rect().has_point(get_global_mouse_position()):
			open_image.emit($Image)
			get_viewport().set_input_as_handled()
