extends Control

func _ready():
	randomize()
	%VisualNovel.grab_focus()
	var plugin_cfg := ConfigFile.new()
	plugin_cfg.load("res://addons/dialogic/plugin.cfg")
	%Version.text = "Using "+plugin_cfg.get_value('plugin', 'version', 'unknown version')
	
	$AboutScreen.hide()
	$MainMenu.show()
	await fade(true)


func _on_visual_novel_pressed():
	display_button_ripple(%VisualNovel)
	await fade()
	get_tree().change_scene_to_file("res://VisualNovel/Menu/visual_novel_main.tscn")


func _on_small_rpg_pressed():
	display_button_ripple(%SmallRPG)
	await fade()
	get_tree().change_scene_to_file("res://SmallRPG/SmallRPG.tscn")

func _on_smartphone_pressed():
	display_button_ripple(%Smartphone)
	await fade()
	get_tree().change_scene_to_file("res://Smartphone/phone_example.tscn")


func _on_quit_pressed():
	display_button_ripple(%Quit)
	get_tree().quit()


func _on_about_pressed():
	display_button_ripple(%About)
	fade_menu($MainMenu, $AboutScreen)
	%Back.grab_focus()

func _on_back_pressed():
	display_button_ripple(%Back)
	fade_menu($AboutScreen, $MainMenu)
	%About.grab_focus()


func fade_menu(from:Node=null, to:Node = null):
	var tween := create_tween().set_parallel()
	
	if to != null:
		to.show()
		to.modulate = Color.TRANSPARENT
		tween.tween_property(to, 'modulate', Color.WHITE, 0.2)
	
	if from != null:
		tween.tween_property(from, 'modulate', Color.TRANSPARENT, 0.2)
		await tween.finished
		from.hide()


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

######### VFX ##################################################################

func display_button_ripple(button:CanvasItem):
	button.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	button.add_child(TextureRect.new())
	button.get_child(-1).size = button.size+Vector2(20,0)
	button.get_child(-1).position = -Vector2(20,0)/2
	button.get_child(-1).name = "Effect"
	button.get_child(-1).expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	button.get_child(-1).texture = load("res://icon.png")
	button.get_child(-1).material = load("res://VisualNovel/Menu/button_click_overlay.tres")
	button.get_node('Effect').material.set_shader_parameter('size', button.get_child(-1).size)
	button.get_node('Effect').material.set_shader_parameter('circle_center', button.get_child(0).get_local_mouse_position()/button.get_child(0).size)
	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(button.get_node('Effect').material,"shader_parameter/time",1.0,0.5).from(0.0)
	await tween.finished
	button.get_child(-1).queue_free()


