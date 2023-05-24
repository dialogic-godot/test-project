extends CanvasLayer

## This layout won't do anything on it's own


enum SizingModes {AdjustAlways, AdjustOnStart, Fixed}
@export var sizing_mode: SizingModes = SizingModes.AdjustAlways

@export var max_width :float = 0
@export var max_lines := 10

var bubbles :Array[Dictionary] = []


func _ready():
	Dialogic.Text.about_to_show_text.connect(_on_dialogic_text_event)
	if max_width <= 0:
		max_width = get_viewport().size.x/2


func register_character(character:DialogicCharacter, node:Node2D):
	var new_bubble := preload("res://addons/dialogic/Modules/DefaultStyles/TextBubble/bubble.tscn").instantiate()
	new_bubble.speaker_node = node
	add_child(new_bubble)
	bubbles.append({'node':node, 'bubble':new_bubble, 'character':character})


func _on_dialogic_text_event(info:Dictionary):
	for b in bubbles:
		if b.character == info.character:
			b.bubble.open()
		else:
			b.bubble.close()
