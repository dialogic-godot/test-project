extends DialogicBackground


func _ready() -> void:
	$Image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	$Image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	
	$Image.anchor_right = 1
	$Image.anchor_bottom = 1


func _update_background(argument:String, time:float) -> void:
	$Image.texture = load(argument)
	$Particles.emitting = true
	var image := Image.load_from_file(argument)
	var colors :Array[Color]= []
	var ramp := Gradient.new()
	ramp.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	for x in range(0,5):
		for y in range(0, 5):
			colors.append(image.get_pixel(image.get_width()/5*x+10, image.get_height()/5*y+10))
			ramp.add_point(1.0/5.0*x+1.0/50.0*y, colors[-1])
	
	$Particles.color_initial_ramp = ramp

func _should_do_background_update(argument:String) -> bool:
	return false
