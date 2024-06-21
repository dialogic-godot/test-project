extends Control


func _ready() -> void:
	Dialogic.Styles.load_style("default_speaker_style")
	Dialogic.start("speaker_tml_1")
