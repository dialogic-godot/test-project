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
	await fade()
	get_tree().change_scene_to_file("res://VisualNovel/Menu/visual_novel_main.tscn")


func _on_text_bubble_pressed():
	await fade()
	get_tree().change_scene_to_file("res://SmallRPG/SmallRPG.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_about_pressed():
	fade_menu($MainMenu, $AboutScreen)

func _on_back_pressed():
	fade_menu($AboutScreen, $MainMenu)


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

