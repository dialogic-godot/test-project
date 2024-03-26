extends Node2D

enum States {MOVE, DIALOG, CUT_SCENE}

var state := States.MOVE


func _ready():
	fade(true)


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


func _input(_event:InputEvent) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		if Dialogic.Styles.has_active_layout_node():
			Dialogic.Styles.get_layout_node().queue_free()
		await fade()
		get_tree().change_scene_to_file("res://MainMenu/Menu.tscn")
