extends CanvasLayer

func _ready():
	hide()

func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()
	if event.is_action_pressed("reload"):
		_on_restart_button_pressed()

func toggle_pause():
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	
	if new_pause_state:
		show()
	else:
		hide()

func _on_continue_button_pressed() -> void:
	toggle_pause()

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
