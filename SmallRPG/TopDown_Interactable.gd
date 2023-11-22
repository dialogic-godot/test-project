extends Area2D

@export var timeline : DialogicTimeline
@export var next_label := ""
@export var indicator_color := Color.SANDY_BROWN
@export var character :DialogicCharacter = null

var _player :CharacterBody2D = null


# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body:PhysicsBody2D) -> void:
	if body is CharacterBody2D:
		var indicator := Sprite2D.new()
		indicator.name = "InteractionIndicator"
		indicator.texture = preload("res://SmallRPG/Assets/interaction.png")
		indicator.modulate = indicator_color
		indicator.scale = Vector2(10,10)/indicator.texture.get_size()
		add_child(indicator)
		indicator.position = Vector2(0,-10)

		_player = body


func _on_body_exited(body:PhysicsBody2D) -> void:
	if body is CharacterBody2D:
		if has_node('InteractionIndicator'):
			get_node('InteractionIndicator').queue_free()


func _input(_event:InputEvent):
	if Input.is_action_just_pressed("interact"):
		if !has_node("InteractionIndicator"):
			return
		get_node('InteractionIndicator').queue_free()

		if has_node('Sprite') and _player:
			get_node('Sprite').flip_h = _player.position.x < position.x
			_player.get_node('Sprite').flip_h =  _player.position.x > position.x
			_player.get_node('Camera2D').align()
			_player.get_node('Camera2D').position = global_position-_player.global_position
			_player.zoom_in()

		if timeline:
			owner.state = owner.States.DIALOG
			get_viewport().set_input_as_handled()
			Dialogic.Styles.add_layout_style('SmallRPG_Style')
			var node := Dialogic.start(timeline, next_label)
			if _player:
				node.register_character(load("res://SmallRPG/Timelines/Player.dch"), _player.get_node('BubbleMarker'))

			if character:
				node.register_character(character, $BubbleMarker)


			Dialogic.timeline_ended.connect(_on_dialog_end)
			if not Dialogic.signal_event.is_connected(_on_dialogic_signal_event):
				Dialogic.signal_event.connect(_on_dialogic_signal_event)


func _on_dialog_end():
	owner.state = owner.States.MOVE
	Dialogic.timeline_ended.disconnect(_on_dialog_end)
	Dialogic.signal_event.disconnect(_on_dialogic_signal_event)
	if _player:
		_player.zoom_out()


func _on_dialogic_signal_event(argument:String):
	if argument.begins_with('next->'):
		next_label = argument.trim_prefix('next->').strip_edges()
	if argument.begins_with('collect'):
		hide()
