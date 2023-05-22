extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	Dialogic.start("res://VisualNovel/Timelines/vn_beginning.dtl")
	Dialogic.timeline_ended.connect(_on_dialogic_end)

func _on_dialogic_end():
	get_tree().change_scene_to_file("res://MainMenu/Menu.tscn")
