extends Node2D

@export var room_name = "room_1"
@export var is_boss_room: bool = false

var reward_scene = preload("res://scenes/reward_pedistal.tscn")

func _ready():
	if not GameManager.visited_rooms.has(GameManager.current_room_coords):
		GameManager.visited_rooms.append(GameManager.current_room_coords)
	
	var coords = GameManager.current_room_coords
	room_name = "room_" + str(coords.x) + "_" + str(coords.y)
	
	setup_procedural_doors() 
	
	await get_tree().process_frame
	
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	if GameManager.cleared_rooms.has(room_name):
		for enemy in enemies:
			enemy.queue_free()
		unlock_all_doors()
	else:
		if enemies.size() > 0:
			lock_all_doors()
		else:
			if not GameManager.cleared_rooms.has(room_name):
				GameManager.cleared_rooms.append(room_name)
			unlock_all_doors()
			
	var player = $Player 
	
	if player:
		if GameManager.target_spawn_door != "":
			var spawn_door = get_node_or_null(GameManager.target_spawn_door)
			if spawn_door:
				player.global_position = spawn_door.global_position
				if GameManager.target_spawn_door == "DoorBottom":
					player.global_position.y -= 90
				elif GameManager.target_spawn_door == "DoorTop":
					player.global_position.y += 90
				elif GameManager.target_spawn_door == "DoorLeft":
					player.global_position.x += 90
				elif GameManager.target_spawn_door == "DoorRight":
					player.global_position.x -= 90

func check_room_cleared():
	await get_tree().process_frame
	var enemies = get_tree().get_nodes_in_group("enemy")
	print("Enemies left: ", enemies.size())
	
	if enemies.size() == 0:
		if not GameManager.cleared_rooms.has(room_name):
			GameManager.cleared_rooms.append(room_name)
		if GameManager.current_room_coords != Vector2.ZERO:
			call_deferred("spawn_reward")
		else:
			unlock_all_doors()

func spawn_reward():
	if get_node_or_null("RewardPedestal"): return 
	
	var new_pedestal = reward_scene.instantiate()
	new_pedestal.name = "RewardPedestal"
	
	var spawn_marker = get_node_or_null("RewardSpawn")
	new_pedestal.global_position = spawn_marker.global_position if spawn_marker else Vector2(500, 300)
	
	new_pedestal.picked_up.connect(_on_reward_picked_up)
	add_child(new_pedestal)

func _on_reward_picked_up():
	print("Reward collected! Doors opening...")
	call_deferred("unlock_all_doors")

func unlock_all_doors():
	var doors = [get_node_or_null("DoorTop"), get_node_or_null("DoorBottom"), get_node_or_null("DoorLeft"), get_node_or_null("DoorRight")]
	for door in doors:
		if door and door.is_active:
			door.is_locked = false
			if door.door_sprite:
				door.door_sprite.modulate = Color(1, 1, 1) 
			if door.solid_blocker:
				door.solid_blocker.set_deferred("disabled", true)
			
func lock_all_doors():
	var doors = [get_node_or_null("DoorTop"), get_node_or_null("DoorBottom"), get_node_or_null("DoorLeft"), get_node_or_null("DoorRight")]
	for door in doors:
		if door and door.is_active:
			door.is_locked = true
			if door.solid_blocker:
				door.solid_blocker.set_deferred("disabled", false)

func setup_procedural_doors():
	var grid = GameManager.map_grid
	var pos = GameManager.current_room_coords
	
	var door_map = {
		"DoorTop": Vector2.UP,
		"DoorBottom": Vector2.DOWN,
		"DoorLeft": Vector2.LEFT,
		"DoorRight": Vector2.RIGHT
	}
	
	for door_name in door_map:
		var door = get_node_or_null(door_name)
		if door:
			if is_boss_room:
				if door_name == GameManager.target_spawn_door:
					door.configure_door(true, "Entrance", false)
				else:
					door.configure_door(false, "", false)
				continue
			
			var target_pos = pos + door_map[door_name]
			if grid.has(target_pos):
				door.configure_door(true, grid[target_pos], false)
			else:
				door.configure_door(false, "", false)
