extends Node2D

@export var room_name = "room_1"
var enemies_left = 0

var reward_scene = preload("res://scenes/reward_pedistal.tscn")

func _ready():
	if GameManager.cleared_rooms.has(room_name):
		print("Room already cleared. Opening doors.")
		var enemies = get_tree().get_nodes_in_group("enemy")
		for enemy in enemies:
			enemy.queue_free()
		unlock_all_doors()
	else:
		enemies_left = get_tree().get_nodes_in_group("enemy").size()
		print("Enemies to defeat: ", enemies_left)

func enemy_defeated():
	enemies_left -= 1
	if enemies_left <= 0:
		call_deferred("room_cleared")

func room_cleared():
	print("Room Cleared!")
	GameManager.cleared_rooms.append(room_name)
	
	if GameManager.pending_reward != "":
		print("Spawning reward: ", GameManager.pending_reward)
		var new_pedestal = reward_scene.instantiate()
		new_pedestal.global_position = Vector2(500,300)
		add_child(new_pedestal)
	unlock_all_doors()

func unlock_all_doors():
	var doors = get_tree().get_nodes_in_group("door")
	for door in doors:
		if door.has_method("unlock"):
			door.unlock()
