extends Control

func _ready():
	Hud.get_node("CanvasLayer").visible = false

func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		AudioManager.play_select()
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main_menu.tscn")
