extends CanvasLayer


func _ready():
	Dialogic.Save.saved.connect(_on_dialogic_saved)

func enter_game() -> void:
	show()
	$InGameMenu.hide()
	$SaveLoadMenu.hide()
	$WarningScreen.hide()
	$SaveIndicator.hide()


func _on_in_game_menu_button_pressed():
	if $InGameMenu.visible:
		var tween := create_tween()
		$InGameMenu.pivot_offset = $InGameMenu.size
		tween.tween_property($InGameMenu, 'scale', Vector2(0,0), 0.2).set_trans(Tween.TRANS_ELASTIC)
		
		await tween.finished
		
		get_tree().paused = false
		$InGameMenu.hide()
	
	else:
		# Call this here to make sure there is no menus in the thumbnail
		Dialogic.Save.take_thumbnail()
		
		$InGameMenu.show()
		$InGameMenu/VBox/QuickSaveButton.grab_focus()
		get_tree().paused = true
	
		var tween := create_tween()
		$InGameMenu.pivot_offset = $InGameMenu.size
		tween.tween_property($InGameMenu, 'scale', Vector2(1,1), 0.2).from(Vector2()).set_trans(Tween.TRANS_ELASTIC)


func _on_quick_save_button_pressed():
	Dialogic.Save.save(Dialogic.Save.get_latest_slot(), false, Dialogic.Save.THUMBNAIL_MODE.STORE_ONLY)
	_on_in_game_menu_button_pressed()


func _on_menu_button_pressed():
	$WarningScreen.show()
	%WithSavingButton.grab_focus()


func _on_with_saving_button_pressed():
	Dialogic.Save.save(Dialogic.Save.get_latest_slot(), false, Dialogic.Save.THUMBNAIL_MODE.STORE_ONLY)
	Dialogic.clear()
	Dialogic.get_layout_node().queue_free()
	$WarningScreen.hide()
	hide()
	get_tree().paused = false
	get_parent().get_node('Menu').open()


func _on_without_saving_button_pressed():
	Dialogic.clear()
	Dialogic.get_layout_node().queue_free()
	$WarningScreen.hide()
	hide()
	get_tree().paused = false
	get_parent().get_node('Menu').open()


func _on_cancel_button_pressed():
	$WarningScreen.hide()
	%MenuButton.grab_focus()


####### SAVE/LOAD POPUP ########################################################
################################################################################

func _on_save_load_button_pressed():
	if $SaveLoadMenu.visible:
		var tween := create_tween()
		$SaveLoadMenu.pivot_offset = $SaveLoadMenu.size
		tween.tween_property($SaveLoadMenu, 'scale', Vector2(0,0), 0.2).set_trans(Tween.TRANS_ELASTIC)
		await tween.finished
		$SaveLoadMenu.hide()
	else:
		$SaveLoadMenu.show()
		reload_slot_list()
		var tween := create_tween()
		$SaveLoadMenu.pivot_offset = $SaveLoadMenu.size
		tween.tween_property($SaveLoadMenu, 'scale', Vector2(1,1), 0.2).from(Vector2()).set_trans(Tween.TRANS_ELASTIC)
		await tween.finished

func reload_slot_list():
	%InGameSlotList.clear()
	for slot_name in Dialogic.Save.get_slot_names():
		%InGameSlotList.add_item(slot_name)


func _on_save_tab_toggled(button_pressed):
	if button_pressed:
		%NewSlotButton.show()
		%NewSlotEdit.hide()


func _on_load_tab_toggled(button_pressed):
	if button_pressed:
		%NewSlotButton.hide()
		%NewSlotEdit.hide()



func _on_new_slot_button_pressed():
	%NewSlotButton.hide()
	%NewSlotEdit.show()
	%NewSlotEdit.grab_focus()


func _on_new_slot_edit_text_submitted(new_text:String) -> void:
	if !new_text.is_empty() and !new_text in Dialogic.Save.get_slot_names():
		Dialogic.Save.add_empty_slot(new_text)
		%InGameSlotList.select(%InGameSlotList.add_item(new_text))
		%InGameSlotList.ensure_current_is_visible()
	%NewSlotEdit.hide()
	%NewSlotButton.show()


func _on_in_game_slot_list_item_activated(index:int) -> void:
	if $SaveLoadMenu/VBox/HBox/SaveTab.button_pressed:
		Dialogic.Save.save(%InGameSlotList.get_item_text(index), false, Dialogic.Save.THUMBNAIL_MODE.STORE_ONLY)
	else:
		Dialogic.Save.load(%InGameSlotList.get_item_text(index))
	await _on_save_load_button_pressed()
	_on_in_game_menu_button_pressed()
	

func _on_dialogic_saved(info:Dictionary) -> void:
	if info.get('is_autosave', false):
		$SaveIndicator/Label.text = ""
	else:
		$SaveIndicator/Label.text = "Saved to "+info.get('slot_name').to_upper()
	
	$SaveIndicator.show()
	var tween := create_tween()
	tween.tween_property($SaveIndicator, 'modulate', Color.WHITE, 0.3).set_ease(Tween.EASE_OUT).from(Color.TRANSPARENT)
	tween.tween_interval(1)
	tween.tween_property($SaveIndicator, 'modulate', Color.TRANSPARENT, 2)
	await tween.finished
	$SaveIndicator.hide()
