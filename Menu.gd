extends Control

func _ready():
	randomize()

func _on_DndTest_pressed():
	get_tree().change_scene_to_file("res://Drag-and-drop-scene/Drag-and-drop-scene.tscn")


func _on_CodeTest_pressed():
	get_tree().change_scene_to_file("res://Code-scene/Code-scene.tscn")
