extends Control


var current_contact :String = ""
var chat_histories := {}

func _ready():
	fade(true)
	Dialogic.Settings.text_speed = 0
	ProjectSettings.set_setting('dialogic/layout/end_behaviour', 2)
	ProjectSettings.set_setting('dialogic/choices/reveal_by_input', true)
#	Dialogic.Text.set_skippable(false)
	Dialogic.Styles.load_style('Smartphone_Style')
	Dialogic.signal_event.connect(_on_dialogic_signal_event)
	Dialogic.clear()


func exit():
	Dialogic.Settings.reset_setting('text_speed')
	ProjectSettings.set_setting('dialogic/layout/end_behaviour', 0)
	ProjectSettings.set_setting('dialogic/choices/reveal_by_input', false)
	ProjectSettings.save()


func _on_dialogic_signal_event(argument:String):
	if argument.begins_with('reveal->') and $VBox/Contacts.has_node(argument.trim_prefix('reveal->')):
		$VBox/Contacts.get_node(argument.trim_prefix('reveal->')).show()


func save_history():
	if Dialogic.Styles.has_active_layout_node() and !current_contact.is_empty():
		var layout :Node = Dialogic.Styles.get_layout_node()
		chat_histories[current_contact] = layout.get_history()
		chat_histories[current_contact]['dialogic_info'] = Dialogic.get_full_state()


func load_history(contact:String):
	if Dialogic.Styles.has_active_layout_node() and !contact.is_empty():
		var layout :Node = Dialogic.Styles.get_layout_node()
		if chat_histories.has(contact):
			layout.load_history(chat_histories[current_contact])
		else:
			layout.load_history({'previous_messages':[]})


func open_conversation(contact:String):
	if contact == current_contact:
		return
	save_history()
	current_contact = contact
	Dialogic.clear()
	Dialogic.Styles.get_layout_node().set_title(contact)
	load_history(contact)
	if !chat_histories.has(current_contact):
		await get_tree().create_timer(0.5).timeout
		Dialogic.start('res://Smartphone/Timelines'.path_join(current_contact)+'.dtl')


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		exit()


func _input(event):
	if Input.is_action_just_pressed("dialogic_default_action"):
		if Dialogic.current_timeline == null and !current_contact.is_empty():
			if chat_histories.has(current_contact):
				Dialogic.load_full_state(chat_histories[current_contact].dialogic_info)
				get_viewport().set_input_as_handled()


func _on_contact_pressed(contact:String):
	open_conversation(contact)
	get_viewport().set_input_as_handled()
	for node in $VBox/Contacts.get_children():
		node.selected = false
	$VBox/Contacts.get_node(contact).selected = true

func fade(fade_in:= false):
	var tween := create_tween().set_parallel()
	if fade_in:
		self.modulate = Color.TRANSPARENT
		tween.tween_property(self, 'modulate', Color.WHITE, 0.2)
	else:
		self.modulate = Color.WHITE
		tween.tween_property(self, 'modulate', Color.TRANSPARENT, 0.2)
	await tween.finished
	await get_tree().create_timer(0.3).timeout


func _on_quit_pressed():
	exit()
	Dialogic.get_layout_node().queue_free()
	await fade()
	get_tree().change_scene_to_file("res://MainMenu/Menu.tscn")
