extends Area2D

var reward_type = ""

@onready var sprite = $Sprite2D

func _ready():
	reward_type = GameManager.pending_reward
	
	match reward_type:
		"sword_upgrade":
			sprite.modulate = Color(1, 0, 0)
		"heal":
			sprite.modulate = Color(0, 1, 0)
		"max_hp_up":
			sprite.modulate = Color(1, 0.8, 0)
		"":
			queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Lonk picked up the reward: ", reward_type)
		
		match reward_type:
			"sword_upgrade":
				body.weapon_upgrades += 1
				GameManager.player_weapon_upgrades = body.weapon_upgrades
				print("Damage upgraded! New total: ", body.get_total_damage())
			"heal":
				body.current_hp = body.max_hp
				print("Lonk fully healed!")
			"max_hp_up":
				body.max_hp += 1.0
				body.current_hp = body.max_hp
				print("Max HP increased! Current Max: ", body.max_hp)
				
		GameManager.pending_reward = ""
		
		queue_free()
