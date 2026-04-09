extends Control

@onready var hp_label = $CanvasLayer/HBoxContainer/HPLabel
@onready var stat_label = $CanvasLayer/HBoxContainer/StatLabel
@onready var ammo_label = $CanvasLayer/AmmoLabel

@onready var stamina_container = $CanvasLayer/StaminaContainer
@onready var stamina_icons = [
	$CanvasLayer/StaminaContainer/Icon1,
	$CanvasLayer/StaminaContainer/Icon2,
	$CanvasLayer/StaminaContainer/Icon3
]

var is_flashing = false
var connected_player = null

func _process(_delta):
	hp_label.text = str(GameManager.player_current_hp) + "/" + str(GameManager.player_max_hp)
	var damage = 1.0 + (GameManager.player_weapon_upgrades * 0.5)
	stat_label.text = "DMG: " + str(damage)
	
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		if player != connected_player:
			connected_player = player
			if not connected_player.out_of_stamina.is_connected(_on_out_of_stamina):
				connected_player.out_of_stamina.connect(_on_out_of_stamina)
				
		match player.current_weapon:
			player.Weapon.GUN:
				ammo_label.visible = true
				stamina_container.visible = false
				if player.is_reloading:
					ammo_label.text = "RELOADING..."
				else:
					ammo_label.text = "AMMO: " + str(player.current_ammo) + " / " + str(player.max_ammo)
					
			player.Weapon.MACE:
				ammo_label.visible = false
				stamina_container.visible = true
				
				if not is_flashing:
					for i in range(3):
						if i < player.current_mace_stamina:
							stamina_icons[i].modulate = Color(1, 1, 0, 1)
						else:
							stamina_icons[i].modulate = Color(0, 0, 0, 1)
						
			_:
				ammo_label.visible = false
				stamina_container.visible = false

func _on_out_of_stamina():
	if is_flashing:
		return
		
	is_flashing = true
	
	for icon in stamina_icons: icon.modulate = Color(1, 0, 0, 1)
	await get_tree().create_timer(0.15).timeout
	
	for icon in stamina_icons: icon.modulate = Color(0, 0, 0, 1)
	await get_tree().create_timer(0.15).timeout
	
	for icon in stamina_icons: icon.modulate = Color(1, 0, 0, 1)
	await get_tree().create_timer(0.15).timeout
	
	for icon in stamina_icons: icon.modulate = Color(0, 0, 0, 1)
	await get_tree().create_timer(0.15).timeout
	
	is_flashing = false
