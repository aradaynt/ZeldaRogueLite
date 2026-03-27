extends Area2D

var tex_heal = preload("res://assets/images/heart.png")
var tex_max_hp = preload("res://assets/images/maxhp.png")
var tex_weapon = preload("res://assets/images/hammer.png")

var is_collected = false
signal picked_up

var reward_type = ""
@onready var sprite = $Sprite2D

func _ready():
	reward_type = GameManager.pending_reward
	if reward_type == "":
		var possible_rewards = ["heal", "max_hp_up", "weapon_upgrade"]
		reward_type = possible_rewards.pick_random()
	
	match reward_type:
		"weapon_upgrade":
			sprite.texture = tex_weapon
		"heal":
			sprite.texture = tex_heal
		"max_hp_up":
			sprite.texture = tex_max_hp

func _on_body_entered(body):
	if is_collected: return
	if body.name == "Player":
		if is_collected: return
		print("Lonk picked up the reward: ", reward_type)
		
		match reward_type:
			"weapon_upgrade":
				body.weapon_upgrades += 1
				GameManager.player_weapon_upgrades = body.weapon_upgrades
				
				print("Damage upgraded! New total: ", body.get_total_damage())
				
			"heal":
				body.current_hp = body.max_hp
				GameManager.player_current_hp = body.current_hp
				
				print("Lonk fully healed! Current HP: ", body.current_hp)
				
			"max_hp_up":
				body.max_hp += 1.0
				body.current_hp += 1.0 
				GameManager.player_max_hp = body.max_hp
				GameManager.player_current_hp = body.current_hp
				
				print("Max HP increased! Current Max: ", body.max_hp)
				
		GameManager.pending_reward = ""
		
		picked_up.emit()
		
		queue_free()
