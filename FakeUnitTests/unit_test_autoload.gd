extends Node

var var_float := 2.0
var var_string := "Hello World"
var var_array := ["One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine"]


func set_container_debug_draw(enabled:bool):
	Dialogic.PortraitContainers.debug_draw = enabled
