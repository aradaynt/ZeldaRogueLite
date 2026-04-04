extends Node2D

@export var weapon_name: String = "sword"

var sword = preload("res://assets/images/sword.png")
var mace = preload("res://assets/images/mace.png")
var gun = preload("res://assets/images/gun.png")

func _ready():
	if weapon_name != null:
		if weapon_name == "sword":
			$Area2D/Sprite2D.texture = sword
		if weapon_name == "gun":
			$Area2D/Sprite2D.texture = gun
		if weapon_name == "mace":
			$Area2D/Sprite2D.texture = mace


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Lonk swapped to: ", weapon_name)
		AudioManager.play_item()
		
		GameManager.equipped_weapon = weapon_name
		
		if body.has_method("equip_weapon"):
			body.equip_weapon(weapon_name)
			
		var all_pickups = get_tree().get_nodes_in_group("weapon_pickups")
		for pickup in all_pickups:
			if pickup == self:
				pickup.modulate = Color(0.3, 0.3, 0.3, 0.5) 
			else:
				pickup.modulate = Color(1, 1, 1, 1)
				
		var doors = get_tree().get_nodes_in_group("door")
		for door in doors:
			if door.has_method("unlock"):
				door.unlock()
