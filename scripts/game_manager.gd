extends Node

var pending_reward = ""
var cleared_rooms: Array = []
var floor_rewards: Dictionary = {}

var player_max_hp = 3.0
var player_current_hp = 3.0
var player_weapon_upgrades = 0
var equipped_weapon = ""

var target_spawn_door = ""
var map_grid: Dictionary = {} 
var current_room_coords: Vector2 = Vector2.ZERO
var visited_rooms: Array[Vector2] = []

var combat_rooms = [
	"res://scenes/combat_room_1.tscn",
	"res://scenes/combat_room_2.tscn",
	"res://scenes/combat_room_3.tscn",
	"res://scenes/combat_room_4.tscn",
	"res://scenes/combat_room_5.tscn",
	"res://scenes/combat_room_6.tscn",
	"res://scenes/combat_room_7.tscn"
]
var start_room = "res://scenes/start_room.tscn"
var treasure_room = "res://scenes/treasure_room_1.tscn"

func _ready():
	generate_dungeon(10) 

func generate_dungeon(target_rooms):
	map_grid.clear()
	cleared_rooms.clear()
	current_room_coords = Vector2.ZERO 
	
	var walker_pos = Vector2.ZERO
	map_grid[walker_pos] = start_room
	
	var rooms_placed = 1
	var farthest_pos = walker_pos
	var max_dist = 0.0
	
	var last_placed_room = ""
	
	while rooms_placed < target_rooms:
		var direction = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT].pick_random()
		walker_pos += direction

		if not map_grid.has(walker_pos):
			var available_rooms = combat_rooms.duplicate()
			
			if last_placed_room != "":
				available_rooms.erase(last_placed_room)
				
			var chosen_room = available_rooms.pick_random()
			map_grid[walker_pos] = chosen_room
			last_placed_room = chosen_room
			
			rooms_placed += 1
			
			var dist = walker_pos.length_squared()
			if dist > max_dist:
				max_dist = dist
				farthest_pos = walker_pos
				
	if farthest_pos != Vector2.ZERO:
		map_grid[farthest_pos] = treasure_room
		
	print("New Branching Dungeon Generated! Total rooms: ", map_grid.size())
	print("Map looks like this: ", map_grid)

func reset_run():
	player_max_hp = 3.0
	player_current_hp = 3.0
	player_weapon_upgrades = 0
	equipped_weapon = ""
	visited_rooms.clear()
	pending_reward = ""
	cleared_rooms.clear()
	floor_rewards.clear()
	map_grid.clear()
	current_room_coords = Vector2.ZERO
	target_spawn_door = ""
	print("Run reset! Ready for a new adventure.")
