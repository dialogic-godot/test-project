extends Control


func _ready() -> void:
	Dialogic.Styles.load_style("default_speaker_style")
	Dialogic.start("speaker_tml_1")

	Dialogic.timeline_ended.connect(_on_timeline_end)


func _on_timeline_end() -> void:
	await fade()
	get_tree().change_scene_to_file("res://MainMenu/Menu.tscn")


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
