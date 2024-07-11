extends Control

## This example shows how to interact with the custom "SmarphoneLayout" scene.
## It allows switching between different timelines with different "contacts".
## To do so, it stores previous messages in [chat_histories].

## This example does not support saving and loading.


## The name of the current contact
var current_contact := ""
## Stores chat histories so they can be loaded back when switching to a different contact.
var chat_histories := {}


func _ready() -> void:
	start_example_scene()

	Dialogic.Styles.load_style('Smartphone_Style')

	Dialogic.signal_event.connect(_on_dialogic_signal_event)

	Dialogic.clear()
	Dialogic.Settings.text_speed = 0
	ProjectSettings.set_setting('dialogic/layout/end_behaviour', 2)
	Dialogic.Choices.reveal_by_input = true


## Mainly allows the timeline to reveal a new contact with a signal event
func _on_dialogic_signal_event(argument: String) -> void:
	if argument.begins_with('reveal->') and $VBox/Contacts.has_node(argument.trim_prefix('reveal->')):
		$VBox/Contacts.get_node(argument.trim_prefix('reveal->')).show()


## Saves the chat history of the current contact
func save_history() -> void:
	if Dialogic.Styles.has_active_layout_node() and !current_contact.is_empty():
		var layout: Node = Dialogic.Styles.get_layout_node()
		chat_histories[current_contact] = layout.get_history()
		chat_histories[current_contact]['dialogic_info'] = Dialogic.get_full_state()


## Loads the chat history of the given contact
func load_history(contact: String) -> void:
	if Dialogic.Styles.has_active_layout_node() and !contact.is_empty():
		var layout: Node = Dialogic.Styles.get_layout_node()
		if chat_histories.has(contact):
			layout.load_history(chat_histories[current_contact])
		else:
			layout.load_history({'previous_messages':[]})


## Opens the conversation with the given contact
## Will save the chat history of the previous contact and load the new one
func open_conversation(contact: String) -> void:
	# ignore if same contact
	if contact == current_contact:
		return

	# save previous chat history
	save_history()


	# clears the layout and changes the contact name on the layout
	current_contact = contact
	Dialogic.clear()
	Dialogic.Styles.get_layout_node().set_title(contact)

	# load the chat history of the new contact
	load_history(contact)

	# start the timeline if this is the first time contacting with this person
	if not chat_histories.has(current_contact):
		await get_tree().create_timer(0.5).timeout
		Dialogic.start('res://Smartphone/Timelines'.path_join(current_contact)+'.dtl')


## This handles continuing a timeline that has a history and we just switched to.
## It loads the state_info that was previously stored when switching away from this contact.
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("dialogic_default_action"):
		if Dialogic.current_timeline == null and not current_contact.is_empty():
			if chat_histories.has(current_contact):
				Dialogic.load_full_state(chat_histories[current_contact].dialogic_info)
				get_viewport().set_input_as_handled()


## Starts/Continues the conversation when a contact is pressed
func _on_contact_pressed(contact: String) -> void:
	# start/continue conversation
	open_conversation(contact)
	get_viewport().set_input_as_handled()

	# change selected state
	for node in $VBox/Contacts.get_children():
		node.selected = false
	$VBox/Contacts.get_node(contact).selected = true


#region EXAMPLE SCENE SETUP
################################################################################
## These methods handle the setup of the example scene.

func start_example_scene() -> void:
	fade(true)


func exit() -> void:
	Dialogic.Settings.reset_setting('text_speed')
	ProjectSettings.set_setting('dialogic/layout/end_behaviour', 0)
	Dialogic.Choices.reveal_by_input = false
	ProjectSettings.save()


## Make sure before closing we reset the project settings!
## Needed because this project contains very different setups for different examples.
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		exit()


## A fade in animation for this example
func fade(fade_in:= false) -> void:
	var tween := create_tween().set_parallel()
	if fade_in:
		self.modulate = Color.TRANSPARENT
		tween.tween_property(self, 'modulate', Color.WHITE, 0.2)
	else:
		self.modulate = Color.WHITE
		tween.tween_property(self, 'modulate', Color.TRANSPARENT, 0.2)
	await tween.finished
	await get_tree().create_timer(0.3).timeout


## Handles the quit/back button of this example
func _on_quit_pressed() -> void:
	exit()
	Dialogic.Styles.get_layout_node().queue_free()
	await fade()
	get_tree().change_scene_to_file("res://MainMenu/Menu.tscn")

#endregion
