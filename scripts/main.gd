extends Node2D

@export var room_name = "room_1"
var reward_scene = preload("res://scenes/reward_pedistal.tscn")

func _ready():
	room_name = "floor_" + str(GameManager.current_floor)
	setup_procedural_doors() 
	
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	if GameManager.cleared_rooms.has(room_name):
		print("DEBUG: Room already cleared! Deleting enemies.")
		for enemy in enemies:
			enemy.queue_free()
		unlock_all_doors()
	else:
		if enemies.size() > 0:
			print("DEBUG: Enemies found! LOCKING DOORS.")
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
	var enemies = get_tree().get_nodes_in_group("enemy")
	print("Enemies left in group: ", enemies.size())
	
	if enemies.size() == 0:
		call_deferred("spawn_reward")

func spawn_reward():
	if get_node_or_null("RewardPedestal"): return 
	if not GameManager.cleared_rooms.has(room_name):
		GameManager.cleared_rooms.append(room_name)
	
	if GameManager.current_floor > 0:
		var new_pedestal = reward_scene.instantiate()
		new_pedestal.name = "RewardPedestal"
		
		var spawn_marker = get_node_or_null("RewardSpawn")
		new_pedestal.global_position = spawn_marker.global_position if spawn_marker else Vector2(500, 300)
		new_pedestal.picked_up.connect(_on_reward_picked_up)
		
		add_child(new_pedestal)
		print("Enemies defeated! Reward spawned.")
	else:
		unlock_all_doors()

func _on_reward_picked_up():
	print("Reward collected! Doors unlocking...")
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
	var map = GameManager.dungeon_map
	var floor_num = GameManager.current_floor
	
	var door_top = get_node_or_null("DoorTop")
	var door_bottom = get_node_or_null("DoorBottom")
	var door_left = get_node_or_null("DoorLeft")
	var door_right = get_node_or_null("DoorRight")
	
	if door_left: door_left.configure_door(false, "", false)
	if door_right: door_right.configure_door(false, "", false)
	
	if door_top:
		if floor_num < map.size() - 1:
			door_top.configure_door(true, map[floor_num + 1], false)
		else:
			door_top.configure_door(false, "", false)
			
	if door_bottom:
		if floor_num > 0:
			door_bottom.is_locked = false 
			door_bottom.configure_door(true, map[floor_num - 1], true)
		else:
			door_bottom.configure_door(false, "", false)
