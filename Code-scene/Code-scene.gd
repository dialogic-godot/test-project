extends Control

func _ready():
	var dia = Dialogic.start('Start')
	add_child(dia)
