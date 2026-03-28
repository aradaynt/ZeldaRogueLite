extends Node2D

@onready var sprint_label = $MainMenu/CenterContainer/MainLayout/OptionsContainer/SprintLabel
@onready var delve_label = $MainMenu/CenterContainer/MainLayout/OptionsContainer/DelveLabel
@onready var labyrinth_label = $MainMenu/CenterContainer/MainLayout/OptionsContainer/LabryrinthLabel

var current_selection = 0

const COLOR_SELECTED = Color(1, 1, 1) 
const COLOR_NORMAL = Color(0,0, 0) 

func _ready():
	AudioManager.play_menu_music()
	GameManager.reset_run()
	update_selection_visuals()
	Hud.get_node("CanvasLayer").visible = false

func _input(event):
	if event.is_action_pressed("ui_down"):
		current_selection = (current_selection + 1) % 3
		update_selection_visuals()
	elif event.is_action_pressed("ui_up"):
		current_selection = (current_selection - 1)
		if current_selection < 0: current_selection = 2
		update_selection_visuals()
		
	if event.is_action_pressed("ui_accept"):
		AudioManager.play_select()
		start_selected_game()

func update_selection_visuals():
	sprint_label.modulate = COLOR_NORMAL
	delve_label.modulate = COLOR_NORMAL
	labyrinth_label.modulate = COLOR_NORMAL
	
	match current_selection:
		0: sprint_label.modulate = COLOR_SELECTED
		1: delve_label.modulate = COLOR_SELECTED
		2: labyrinth_label.modulate = COLOR_SELECTED

func start_selected_game():
	print("Choice made, starting run!")
	
	match current_selection:
		0: GameManager.generate_dungeon(8) 
		1: GameManager.generate_dungeon(15)
		2: GameManager.generate_dungeon(25)
		
	Hud.get_node("CanvasLayer").visible = true
	get_tree().call_deferred("change_scene_to_file", "res://scenes/tutorial.tscn")
