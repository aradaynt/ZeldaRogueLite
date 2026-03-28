extends CanvasLayer

@onready var stats_label = $CenterContainer/VBoxContainer/StatsLabel
func _ready():
	if Hud.has_node("CanvasLayer"):
		Hud.get_node("CanvasLayer").visible = false
	var score = GameManager.cleared_rooms.size()
	stats_label.text = "Room Cleared: " + str(score)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		return_to_menu()

func return_to_menu():
	print("Heading back to the main menu...")
	get_tree().call_deferred("change_scene_to_file", "res://scenes/main_menu.tscn")
