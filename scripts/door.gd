extends Area2D

@export var is_active = true
@export_file("*.tscn") var next_room_path: String 
@export var promised_reward = "sword_upgrade" 
@export var is_back_door = false 

var is_locked = true

@onready var door_sprite = $DoorSprite
@onready var loot_icon = $LootIcon
@onready var fake_wall_map = $FakeWallTileMap
@onready var solid_blocker = $SolidBlocker/WallCollision
@export_enum("Top", "Bottom", "Left", "Right") var door_direction = "Top"

var tex_heal = preload("res://assets/images/heart.png")
var tex_max_hp = preload("res://assets/images/maxhp.png")
var tex_weapon = preload("res://assets/images/hammer.png")

func _ready():
	if not is_active:
		door_sprite.visible = false
		if loot_icon:
			loot_icon.visible = false
		fake_wall_map.visible = true
		solid_blocker.set_deferred("disabled", false) 
	else:
		fake_wall_map.visible = false
		
		if is_back_door and loot_icon:
			loot_icon.visible = false
		door_sprite.modulate = Color(0.3, 0.3, 0.3)
		
		if is_locked:
			solid_blocker.set_deferred("disabled", false)
		else:
			solid_blocker.set_deferred("disabled", true)

func unlock():
	if not is_active:
		return 
		
	is_locked = false
	door_sprite.modulate = Color(1, 1, 1) 
	solid_blocker.set_deferred("disabled", true)

func _on_body_entered(body):
	if not is_locked and body.is_in_group("player"):
		if next_room_path != "":
			match door_direction:
				"Top": GameManager.target_spawn_door = "DoorBottom"
				"Bottom": GameManager.target_spawn_door = "DoorTop"
				"Left": GameManager.target_spawn_door = "DoorRight"
				"Right": GameManager.target_spawn_door = "DoorLeft"
				
			if not is_back_door:
				GameManager.pending_reward = promised_reward
				GameManager.current_floor += 1
			else:
				GameManager.pending_reward = ""
				GameManager.current_floor -= 1
				
			get_tree().call_deferred("change_scene_to_file", next_room_path)
		else:
			print("oops")

func configure_door(make_active: bool, path: String, back_door: bool):
	is_active = make_active
	next_room_path = path
	is_back_door = back_door
	
	if not is_active:
		door_sprite.visible = false
		if loot_icon: loot_icon.visible = false
		fake_wall_map.visible = true
		solid_blocker.set_deferred("disabled", false) 
	else:
		fake_wall_map.visible = false
		door_sprite.visible = true
		door_sprite.modulate = Color(0.3, 0.3, 0.3)
		
		if is_locked:
			solid_blocker.set_deferred("disabled", false)
		else:
			solid_blocker.set_deferred("disabled", true)
		if is_back_door:
			if loot_icon: loot_icon.visible = false
		else:
			var target_floor = GameManager.current_floor + 1
			if GameManager.floor_rewards.has(target_floor):
				promised_reward = GameManager.floor_rewards[target_floor]
			else:
				var possible_rewards = ["heal", "max_hp_up", "weapon_upgrade"]
				promised_reward = possible_rewards.pick_random()
				GameManager.floor_rewards[target_floor] = promised_reward
			if loot_icon:
				loot_icon.visible = true
				match promised_reward:
					"weapon_upgrade":
						loot_icon.texture = tex_weapon
					"heal":
						loot_icon.texture = tex_heal
					"max_hp_up":
						loot_icon.texture = tex_max_hp
