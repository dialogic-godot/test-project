extends VBoxContainer


func _ready() -> void:
	hide()


func open() -> void:
	show()
	reload_slot_list()


func reload_slot_list() -> void:
	%SlotList.clear()
	for slot in Dialogic.Save.get_slot_names():
		%SlotList.add_item(slot)
	if %SlotList.item_count:
		%SlotList.select(0)
		_on_slot_list_item_selected(0)
	else:
		_on_slot_list_item_selected(-1)
		close()
		%Load.hide()


func _on_slot_list_item_selected(index:int) -> void:
	if index == -1:
		%SlotName.text = "No slots exists!"
		%PreviewTexture.texture = null
		return
	
	var slot_name :String = %SlotList.get_item_text(index)
	%SlotName.text = slot_name
	
	%PreviewTexture.texture = Dialogic.Save.get_slot_thumbnail(slot_name)
	
	var tween := create_tween().set_ease(Tween.EASE_OUT)
	$Top/Preview.pivot_offset = $Top/Preview.size/2
	tween.tween_property($Top/Preview, 'scale', Vector2(1,1), 0.2).set_trans(Tween.TRANS_BACK).from(Vector2(0.8,0.8))


func _on_slot_list_item_activated(index:int) -> void:
	_on_slot_list_item_selected(index)
	get_parent().load_slot(%SlotList.get_item_text(index))


func close() -> void:
	hide()


func _on_load_slot_button_pressed():
	get_parent().load_slot(%SlotList.get_item_text(%SlotList.get_selected_items()[0]))


func _on_delete_slot_button_pressed():
	Dialogic.Save.delete_slot(%SlotList.get_item_text(%SlotList.get_selected_items()[0]))
	%SlotList.remove_item(%SlotList.get_selected_items()[0])
	reload_slot_list()
