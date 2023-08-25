extends Control


func _ready():
	Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
	Dialogic.signal_event.connect(_on_dialogic_signal)

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


func _on_dialogic_signal(argument:String) -> void:
	Dialogic.Portraits.get_character_info(load("res://VisualNovel/Characters/Leon.dch")).node.get_child(0).call(argument)
