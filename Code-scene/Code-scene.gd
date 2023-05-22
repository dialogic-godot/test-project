extends Control

var current_save_slot = ''
var dia

func _ready():
	dia = Dialogic.start('Start')
	add_child(dia)
	
	$UI/SaveLoad/MenuButton.get_popup().connect('index_pressed', Callable(self, 'save_slot_selected'))


func _on_Save_pressed():
	print("save ", current_save_slot)
	Dialogic.save(current_save_slot)

func _on_Load_pressed():
	print("load ", current_save_slot)
	dia.queue_free()
	Dialogic.load(current_save_slot)
	dia = Dialogic.start(Callable('', 'Start'))
	add_child(dia)

func _on_MenuButton_about_to_show():
	var popup = $UI/SaveLoad/MenuButton.get_popup()
	popup.clear()
	popup.add_item('Default')
	for slot_name in Dialogic.get_slot_names():
		popup.add_item(slot_name)

func save_slot_selected(index):
	current_save_slot = $UI/SaveLoad/MenuButton.get_popup().get_item_text(index)
	if current_save_slot == 'Default':
		current_save_slot = ''


func _on_Reset_pressed():
	print("reset ", current_save_slot)
	Dialogic.reset_saves(current_save_slot)
