extends TextureRect

## Script that adds a paralax effect, depending on the mouse position

## The strength of the effect
@export var paralax_strength := 50
## If true, the movement is inverted
@export var invert := false

## Makes it so original position is respected
var original_position := Vector2()


func _ready() -> void:
	original_position = position


func _process(delta:float) -> void:
	## Calculate the mouse_offset from the center
	##  ranging from (-1 | -1) to (1 | 1)
	var relative_mouse_offset: Vector2 = get_global_mouse_position() / Vector2(get_viewport().size) - Vector2.ONE
	if invert:
		relative_mouse_offset *= -1

	## Lerp the position to avoid instant changes
	position = lerp(position, original_position + relative_mouse_offset * paralax_strength, delta*10)
