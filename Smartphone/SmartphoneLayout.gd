@tool
extends DialogicLayoutBase

## This layout showcases a possible implementation of a smartphone.
## It fakes a chat-like layout, by always adding new textboxes, whenever a new text is shown.

## These properties store information on the last text,
## so that a textbox that looks the same can be added, when the next text is revealed.
var last_text := ""
var last_text_size := Vector2()
var last_text_speaker: DialogicCharacter = null
var last_text_time := ""


func _ready() -> void:
	setup_background_image_logic()


## Handle UI things, when a new text starts revealing
func _on_dialog_text_started_revealing_text() -> void:
	# update the size of the box
	%DialogText.custom_minimum_size = get_message_size(%DialogText.text)

	# update the little time-label of the box
	var time := Time.get_datetime_dict_from_system()
	%DialogText.get_node('Time').text = str(time.hour)+":"+str(time.minute)

	# update the alignemnt (left/right) based on the events speaker
	# The time is not shown on messages the Player says
	var speaker: DialogicCharacter = Dialogic.Text.get_current_speaker()
	if speaker.display_name == "Player":
		%DialogText.size_flags_horizontal = Control.SIZE_SHRINK_END
		%DialogText.get_node('Time').hide()
	else:
		%DialogText.get_node('Time').show()
		%DialogText.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN


## Store all info about the textbox, when it finishes revealing.
## Also add a new textbox with all that info.
func _on_dialogic_node_dialog_text_finished_revealing_text() -> void:
	last_text = %DialogText.text
	last_text_size = %DialogText.custom_minimum_size
	last_text_speaker = Dialogic.Text.get_current_speaker()
	last_text_time = %DialogText.get_node('Time').text


	if last_text.is_empty():
		return

	add_message(last_text, last_text_size, last_text_speaker.get_character_name(), last_text_time)



## Helper method that calculates the size the textbox should have based on the text.
func get_message_size(text:String) -> Vector2:
	var font: Font = %DialogText.get_theme_font("normal_font", 'RichtTextLabel')
	var string_size :Vector2= font.get_string_size(text, 0, -1, 10)

	var max_width: int= %MessageList.size.x

	var smallest_line_amount := -1
	for i in range(1,10):
		if string_size.x/i+20 > max_width:
			continue
		else:
			smallest_line_amount = i
			break

	return Vector2(
		string_size.x / smallest_line_amount + 20,
		smallest_line_amount * string_size.y + 20
		)


## Adds a new textbox.
## These textboxes are purely visual and not DialogText nodes!
## Only the newest messages appears on the %DialogText node.
func add_message(text:String, size:Vector2, speaker_name:String, time:String) -> void:
	var message: Control = load("res://Smartphone/message_panel.tscn").instantiate()
	%MessageList.add_child(message)

	# make sure the %DialogText node and the choices are always at the bottom
	%MessageList.move_child(message, -3)

	message.text = text
	message.custom_minimum_size = size
	message.set_meta('speaker', speaker_name)
	message.get_node('Time').text = time

	if speaker_name == "Player":
		message.size_flags_horizontal = Control.SIZE_SHRINK_END
	else:
		message.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN

	await get_tree().process_frame

	# scroll down to the %DialogText node
	%MessageList.get_parent().ensure_control_visible(%DialogText)


## Allows changing the contact title
func set_title(title: String) -> void:
	%Title.text = title


## Returns a dictionary with all the previous messages infos in it.
## Together with [load_history()] this is used to allow switching between contacts/timelines
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


## Loads messages from a dictionary that was previously returned by [get_history()]
func load_history(history: Dictionary) -> void:
	clear()
	for message in history.previous_messages:
		if message[0].begins_with('res://'):
			add_image_message(load(message[0]), message[1], message[2], message[3])
		else:
			add_message(message[0], message[1], message[2], message[3])
	if %MessageList.get_child_count() > 2:
		%MessageList.get_parent().ensure_control_visible(%MessageList.get_child(-3))
	last_text = ""


## Removes all fake textboxes
func clear() -> void:
	for child in %MessageList.get_children():
		if child != %DialogText and child != %Choices:
			child.queue_free()


#region BACKGROUND/IMAGE LOGIC
################################################################################
## This code makes it so that a background event is instead interpreted as an
## image-message and the image can be clicked and "opened".

func setup_background_image_logic() -> void:
	Dialogic.Backgrounds.background_changed.connect(_on_background_changed)
	$Image.hide()


## Adds an image message (a custom scene)
func add_image_message(image:Texture2D, size:Vector2, speaker:String, time:String) -> void:
	var message: Control = load("res://Smartphone/image_message_panel.tscn").instantiate()
	message.open_image.connect(open_image)
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


## Adds a bigger texture that shows the given image
func open_image(image: TextureRect) -> void:
	%ImageReveal.texture = image.texture
	%ImageReveal.set_meta('image', image)
	var tween := create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(%ImageReveal, 'position', Vector2(0,0), 0.3).from(image.global_position-%ImageOpener.global_position)
	tween.tween_property(%ImageReveal, 'rotation', 0, 0.3).from(image.get_global_transform().get_rotation()-%ImageOpener.get_global_transform().get_rotation())
	tween.tween_property(%ImageReveal, 'size', %ImageOpener.size, 0.3).from(image.size)
	tween.tween_property($Image, 'self_modulate', Color.WHITE, 0.3).from(Color.TRANSPARENT)
	$Image.show()
	Dialogic.paused = true


## Closes the bigger image
func close_image() -> void:
	var image: TextureRect = %ImageReveal.get_meta('image')
	var tween := create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(%ImageReveal, 'position', image.global_position-%ImageOpener.global_position, 0.1)
	tween.tween_property(%ImageReveal, 'rotation', image.get_global_transform().get_rotation()-%ImageOpener.get_global_transform().get_rotation(), 0.1)
	tween.tween_property(%ImageReveal, 'size', image.size, 0.1)
	tween.tween_property($Image, 'self_modulate', Color.TRANSPARENT, 0.1)
	await tween.finished
	$Image.hide()
	Dialogic.paused = false


## Handles closing the bigger image preview when anything else is clicked
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if %ImageReveal.get_global_rect().has_point(%ImageOpener.get_global_mouse_position()):
			return
		if $Image.visible:
			close_image()
			get_viewport().set_input_as_handled()


## Handles adding an image message when a background event is encountered
func _on_background_changed(info: Dictionary) -> void:
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

#endregion
