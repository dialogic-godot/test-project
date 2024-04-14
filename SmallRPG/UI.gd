extends CanvasLayer



func _on_save_pressed() -> void:
	Dialogic.Save.save('RPG_SLOT')
	Dialogic.Save.save_file('RPG_SLOT', 'game_info', get_info())


func _on_load_pressed() -> void:
	Dialogic.Save.load('RPG_SLOT')
	var info: Dictionary = Dialogic.Save.load_file('RPG_SLOT', 'game_info', get_info())
	%Player.global_position = info.player_pos
	%NPC.next_label = info.npc_next_label
	if Dialogic.VAR.RPG_Example.smiths_key:
		%Key.hide()


func get_info() -> Dictionary:
	return {
		"player_pos":%Player.global_position,
		"npc_next_label":%NPC.next_label
		}
