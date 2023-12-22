extends Control


func _ready() -> void:
	Dialogic.Styles.load_style("VisualNovel_Style")
	Dialogic.start("t0_overview")


