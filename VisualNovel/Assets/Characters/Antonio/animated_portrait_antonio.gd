@tool
extends DialogicPortrait

@export var animation := "idle"

func _update_portrait(character:DialogicCharacter, portrait:String) -> void:
	super._update_portrait(character, portrait)
	$Portrait.play(animation)
	$Portrait.animation_finished.connect(func(): $Portrait.frame = randi()%max($Portrait.sprite_frames.get_frame_count(animation), 1); $Portrait.play(animation))
	var texture :Texture2D = $Portrait.sprite_frames.get_frame_texture(animation, 0)
	if texture != null: 
		$Portrait.position = texture.get_size()*Vector2(-0.5, -1)


func _get_covered_rect() -> Rect2:
	var texture :Texture2D = $Portrait.sprite_frames.get_frame_texture(animation, 0)
	if texture == null: return Rect2()
	return Rect2($Portrait.position, texture.get_size())

func _set_mirror(mirrored:bool) -> void:
	$Portrait.flip_h = mirrored

func crazy():
	print("LOLOLOLOl")
