extends DialogicBackground


func _ready() -> void:
	print("\nNEW TITLE SCENE")
	#_update_background("[fancy_in]WOWIEEEEE", 0.0)

func _update_background(argument:String, _time:float) -> void:
	await get_tree().create_timer(1).timeout
	print("showing title: ", argument)
	$Title.set_speed(0.08)
	$Title.reveal_text(argument)
	Dialogic.Text.active_textbox = "main"
