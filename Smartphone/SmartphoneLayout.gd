@tool
extends DialogicLayoutBase

var last_text :String = ""
var last_text_size := Vector2()
var last_text_speaker :DialogicCharacter = null
var last_text_time :String = ""


func _ready():
	Dialogic.Backgrounds.background_changed.connect(_on_background_changed)
	$Image.hide()

func _on_background_changed(info:Dictionary) -> void:
	if info.argument.is_empty():
		return

	if last_text.is_empty():
		return

	add_message(last_text, last_text_size, last_text_speaker.get_character_name(), last_text_time)

	last_text = ""
	%DialogText.hide()
	var time := Time.get_datetime_dict_from_system()
	var image := load(info.argument)
	add_image_message(image, Vector2(%MessageList.size.x*2/3, image.get_height()*%MessageList.size.x*2/3/image.get_width()+20), last_text_speaker.get_character_name(), str(time.hour)+":"+str(time.minute))


func _on_dialogic_node_dialog_text_finished_revealing_text() -> void:
	last_text = %DialogText.text
	last_text_size = %DialogText.custom_minimum_size
	last_text_speaker = Dialogic.Text.get_current_speaker()
	last_text_time = %DialogText.get_node('Time').text


func _on_dialog_text_started_revealing_text():
	%DialogText.custom_minimum_size = get_message_size(%DialogText.text)


	var time := Time.get_datetime_dict_from_system()
	%DialogText.get_node('Time').text = str(time.hour)+":"+str(time.minute)
	var speaker :DialogicCharacter = Dialogic.Text.get_current_speaker()
	if speaker.display_name == "Player":
		%DialogText.size_flags_horizontal = Control.SIZE_SHRINK_END
		%DialogText.get_node('Time').hide()
	else:
		%DialogText.get_node('Time').show()
		%DialogText.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN


	if last_text.is_empty():
		return


	add_message(last_text, last_text_size, last_text_speaker.get_character_name(), last_text_time)


func get_message_size(text:String) -> Vector2:
	var font :Font = %DialogText.get_theme_font("normal_font", 'RichtTextLabel')
	var string_size :Vector2= font.get_string_size(text, 0, -1, 10)

	var max_width :int= %MessageList.size.x

	var smallest_line_amount = -1
	for i in range(1,10):
		if string_size.x/i+20 > max_width:
			continue
		else:
			smallest_line_amount = i
			break

	return Vector2(string_size.x/smallest_line_amount+20,smallest_line_amount*string_size.y+20)


func add_message(text:String, size:Vector2, speaker_name:String, time:String):
	var message :Control = load("res://Smartphone/message_panel.tscn").instantiate()

	message.text = text
	message.custom_minimum_size = size

	%MessageList.add_child(message)
	%MessageList.move_child(message, -3)
	message.set_meta('speaker', speaker_name)
	message.get_node('Time').text = time
	if speaker_name == "Player":
		message.size_flags_horizontal = Control.SIZE_SHRINK_END
	else:
		message.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	await get_tree().process_frame
	%MessageList.get_parent().ensure_control_visible(%DialogText)


func add_image_message(image:Texture2D, size:Vector2, speaker:String, time:String) -> void:
	var message :Control = load("res://Smartphone/image_message_panel.tscn").instantiate()
	message.open_image.connect(_on_image_message_open_image)
	message.custom_minimum_size = size
	message.get_node('Image').texture = image

	%MessageList.add_child(message)
	%MessageList.move_child(message, -3)
	message.set_meta('speaker', speaker)
	message.get_node('Time').text = time
	if speaker == "Player":
		message.size_flags_horizontal = Control.SIZE_SHRINK_END
	else:
		message.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	await get_tree().process_frame
	%MessageList.get_parent().ensure_control_visible(message)


func _on_image_message_open_image(image:TextureRect):
	%ImageReveal.texture = image.texture
	%ImageReveal.set_meta('image', image)
	var tween := create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(%ImageReveal, 'position', Vector2(0,0), 0.3).from(image.global_position-%ImageOpener.global_position)
	tween.tween_property(%ImageReveal, 'rotation', 0, 0.3).from(image.get_global_transform().get_rotation()-%ImageOpener.get_global_transform().get_rotation())
	tween.tween_property(%ImageReveal, 'size', %ImageOpener.size, 0.3).from(image.size)
	tween.tween_property($Image, 'self_modulate', Color.WHITE, 0.3).from(Color.TRANSPARENT)
	$Image.show()
	Dialogic.paused = true


func close_image():
	var image :TextureRect = %ImageReveal.get_meta('image')
	var tween := create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(%ImageReveal, 'position', image.global_position-%ImageOpener.global_position, 0.1)
	tween.tween_property(%ImageReveal, 'rotation', image.get_global_transform().get_rotation()-%ImageOpener.get_global_transform().get_rotation(), 0.1)
	tween.tween_property(%ImageReveal, 'size', image.size, 0.1)
	tween.tween_property($Image, 'self_modulate', Color.TRANSPARENT, 0.1)
	await tween.finished
	$Image.hide()
	Dialogic.paused = false


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if !%ImageReveal.get_global_rect().has_point(%ImageOpener.get_global_mouse_position()):
			if $Image.visible:
				close_image()
				get_viewport().set_input_as_handled()



func get_history() -> Dictionary:
	var history := {'previous_messages':[]}
	# saves text, size, speaker and time of each send message
	for message in %MessageList.get_children():
		if message == %Choices:
			continue
		elif message == %DialogText:
			if !%DialogText.revealing:
				history.previous_messages.append([%DialogText.text, %DialogText.size, last_text_speaker.get_character_name(), %DialogText.get_node('Time').text])
		else:
			if message is RichTextLabel:
				history.previous_messages.append([message.text, message.size, message.get_meta('speaker'), message.get_node('Time').text])
			elif message is Panel:
				history.previous_messages.append([message.get_node('Image').texture.resource_path, message.size, message.get_meta('speaker'), message.get_node('Time').text])

	return history


func set_title(title:String) -> void:
	%Title.text = title

func load_history(history) -> void:
	clear()
	for message in history.previous_messages:
		if message[0].begins_with('res://'):
			add_image_message(load(message[0]), message[1], message[2], message[3])
		else:
			add_message(message[0], message[1], message[2], message[3])
	%MessageList.get_parent().ensure_control_visible(%MessageList.get_child(-3))
	last_text = ""


func clear() -> void:
	for child in %MessageList.get_children():
		if child != %DialogText and child != %Choices:
			child.queue_free()
