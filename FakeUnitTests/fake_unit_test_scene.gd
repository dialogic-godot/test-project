extends Control


func _ready() -> void:
	Dialogic.Styles.add_layout_style("VisualNovel_Style")
	Dialogic.start("t0_overview")


