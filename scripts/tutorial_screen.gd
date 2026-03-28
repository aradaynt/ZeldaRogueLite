extends CanvasLayer

func _input(event):
	if event.is_action_pressed("ui_accept"):
		AudioManager.play_select()
		start_journey()

func start_journey():
	if Hud.has_node("CanvasLayer"):
		Hud.get_node("CanvasLayer").visible = true
		
	get_tree().call_deferred("change_scene_to_file", "res://scenes/start_room.tscn")
