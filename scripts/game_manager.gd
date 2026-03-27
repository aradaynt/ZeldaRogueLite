extends Node

var pending_reward = ""

var cleared_rooms: Array = []
var floor_rewards: Dictionary = {}

var player_max_hp = 3.0
var player_current_hp = 3.0
var player_weapon_upgrades = 0

var equipped_weapon = ""

var target_spawn_door = ""

var combat_rooms = [
	"res://scenes/combat_room_1.tscn",
	"res://scenes/combat_room_2.tscn",
	"res://scenes/combat_room_3.tscn",
	"res://scenes/combat_room_4.tscn"
]

var start_room = "res://scenes/start_room.tscn"
var treasure_room = "res://scenes/treasure_room_1.tscn"

var dungeon_map = [] 

var current_floor = 0

func _ready():
	generate_dungeon()

func generate_dungeon():
	dungeon_map.clear()
	current_floor = 0
	cleared_rooms.clear()
	dungeon_map.append(start_room)
	var shuffled_combat = combat_rooms.duplicate()
	shuffled_combat.shuffle()
	for i in range(4):
		dungeon_map.append(shuffled_combat[i])
	dungeon_map.append(treasure_room)
	
	print("New Dungeon Generated! Map looks like this:")
	print(dungeon_map)
