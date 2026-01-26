extends ScrollContainer


func _ready() -> void:
	close()


func open():
	show()
	pivot_offset_ratio = Vector2(0.5, 0.5)
	var tween:= create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1).from(Color.TRANSPARENT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1).from(Vector2(0.9, 0.9))


func close():
	pivot_offset_ratio = Vector2(0.5, 0.5)
	var tween:= create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.1)
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.1)
	tween.chain().tween_callback(hide)
