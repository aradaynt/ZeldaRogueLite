extends Control

@onready var hp_label = $CanvasLayer/HBoxContainer/HPLabel
@onready var stat_label = $CanvasLayer/HBoxContainer/StatLabel
@onready var ammo_label = $CanvasLayer/AmmoLabel

func _process(_delta):
	hp_label.text = str(GameManager.player_current_hp) + "/" + str(GameManager.player_max_hp)
	var damage = 1.0 + (GameManager.player_weapon_upgrades * 0.5)
	stat_label.text = "DMG: " + str(damage)
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		if player.current_weapon == player.Weapon.GUN:
			ammo_label.visible = true
			
			if player.is_reloading:
				ammo_label.text = "RELOADING..."
			else:
				ammo_label.text = "AMMO: " + str(player.current_ammo) + " / " + str(player.max_ammo)
		else:
			ammo_label.visible = false
