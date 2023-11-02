extends CharacterBody2D


@export var SPEED := 100


func _process(delta:float) -> void:
	if owner.state != owner.States.MOVE:
		return

	var direction := Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))

	velocity = direction.normalized()*SPEED*delta*50

	if direction.x != 0:
		$Sprite.flip_h = direction.x < 0

	move_and_slide()


func zoom_in() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Camera2D, "zoom", Vector2(6,6), 1)


func zoom_out() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Camera2D, "zoom", Vector2(5,5), 1).set_ease(Tween.EASE_IN_OUT)
