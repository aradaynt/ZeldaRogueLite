extends Area2D

@export_file("*.tscn") var next_room_path: String
@export var promised_reward = "sword_upgrade" 
@export var is_back_door = false

var is_locked = true
@onready var door_sprite = $DoorSprite
@onready var loot_icon = $LootIcon

func _ready():
	if is_back_door:
		loot_icon.visible = false
		
	door_sprite.modulate = Color(0.3, 0.3, 0.3) 

func unlock():
	is_locked = false
	door_sprite.modulate = Color(1, 1, 1) 

func _on_body_entered(body):
	if not is_locked and body.is_in_group("player"):
		if next_room_path != "":
			if not is_back_door:
				GameManager.pending_reward = promised_reward
			else:
				GameManager.pending_reward = ""
			get_tree().call_deferred("change_scene_to_file", next_room_path)
		else:
			print("oops")
