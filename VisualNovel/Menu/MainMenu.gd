extends Control


func _ready() -> void:
	open()


func open():
	get_parent().fade(true)
	get_parent().get_node('IngameUI').hide()
	show()
	%Continue.visible = !Dialogic.Save.get_latest_slot().is_empty()
	if %Continue.visible:
		%Continue.grab_focus()
	else:
		%NewGame.grab_focus()
	%Load.visible = !Dialogic.Save.get_slot_names().is_empty()
	%LoadMenu.hide()


## If the timeline actually ends on it's own, that can only mean that the player
## reached the end of the game. Thus we remove the "last save" entry, so the
## Continue button is hidden again.
func _on_dialogic_end() -> void:
	Dialogic.Save.set_latest_slot('')
	open()


func _on_menu_continue_pressed():
	display_button_ripple(%Continue)
	load_slot(Dialogic.Save.get_latest_slot())


func _on_new_game_pressed():
	display_button_ripple(%NewGame)
	await get_parent().fade()
	Dialogic.Styles.load_style('VisualNovel_Style')
	Dialogic.start("res://VisualNovel/Timelines/vn_beginning.dtl")
	Dialogic.timeline_ended.connect(_on_dialogic_end)
	hide()
	%IngameUI.enter_game()


func _on_load_pressed():
	display_button_ripple(%Load)
	if %LoadMenu.visible:
		%LoadMenu.hide()
	else:
		%LoadMenu.open()


func load_slot(slot_name:String) -> void:
	await get_parent().fade()
	Dialogic.Styles.load_style('VisualNovel_Style')
	Dialogic.Save.load(slot_name)
	if not Dialogic.timeline_ended.is_connected(_on_dialogic_end):
		Dialogic.timeline_ended.connect(_on_dialogic_end)
	hide()
	%IngameUI.enter_game()


func _on_back_pressed():
	display_button_ripple(%Back)
	await get_parent().fade()
	get_tree().change_scene_to_file("res://MainMenu/Menu.tscn")


######### VFX ##################################################################

func display_button_ripple(button:CanvasItem):
	button.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	button.add_child(TextureRect.new())
	button.get_child(0).size = button.size+Vector2(20,0)
	button.get_child(0).position = -Vector2(20,0)/2
	button.get_child(0).name = "Effect"
	button.get_child(0).expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	button.get_child(0).texture = load("res://icon.png")
	button.get_child(0).material = load("res://VisualNovel/Menu/button_click_overlay.tres")
	button.get_node('Effect').material.set_shader_parameter('size', button.get_child(0).size)
	button.get_node('Effect').material.set_shader_parameter('circle_center', button.get_child(0).get_local_mouse_position()/button.get_child(0).size)
	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(button.get_node('Effect').material,"shader_parameter/time",1.0,0.5).from(0.0)
	await tween.finished
	button.get_child(0).queue_free()
