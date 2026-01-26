extends DialogicBackground


func _update_background(argument:String, _time:float) -> void:
	$Title.set_speed(0.08)
	$Title.reveal_text(argument)
	Dialogic.Text.active_textbox = "main"
