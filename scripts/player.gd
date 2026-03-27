extends CharacterBody2D

const SPEED = 200.0

enum Weapon {NONE, SWORD, MACE, GUN}
var current_weapon = Weapon.NONE

var base_damage = 1.0
var weapon_upgrades = GameManager.player_weapon_upgrades

var max_ammo = 6
var current_ammo = max_ammo
var is_reloading = false
var is_attacking = false 

var facing_direction = Vector2.DOWN

var max_hp = GameManager.player_max_hp
var current_hp = GameManager.player_current_hp
var is_invincible = false

var knockback = Vector2.ZERO


var bullet_scene = preload("res://scenes/bullet.tscn")

@onready var weapon_pivot = $WeaponPivot
@onready var sword_collision = $WeaponPivot/SwordHitbox/CollisionShape2D
@onready var mace_collision = $MaceHitbox/CollisionShape2D

func _ready():
	if GameManager.equipped_weapon != "":
		equip_weapon(GameManager.equipped_weapon)
	sword_collision.disabled = true
	mace_collision.disabled = true


func _physics_process(delta) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction != Vector2.ZERO:
		facing_direction = direction.normalized()
		weapon_pivot.rotation = facing_direction.angle()

	var current_speed = SPEED
	if current_weapon == Weapon.MACE and is_attacking:
		current_speed = SPEED * 0.2
	
	if direction:
		match current_weapon:
			Weapon.NONE:
				$AnimatedSprite2D.play("walking_base")
			Weapon.SWORD:
				$AnimatedSprite2D.play("walking_sword")
			Weapon.MACE:
				$AnimatedSprite2D.play("walking_mace")
			Weapon.GUN:
				$AnimatedSprite2D.play("walking_gun")
		velocity = direction * current_speed
	else:
		match current_weapon:
			Weapon.NONE:
				$AnimatedSprite2D.play("default")
			Weapon.SWORD:
				$AnimatedSprite2D.play("still_sword")
			Weapon.MACE:
				$AnimatedSprite2D.play("still_mace")
			Weapon.GUN:
				$AnimatedSprite2D.play("still_gun")
		velocity = velocity.move_toward(Vector2.ZERO,current_speed)
	
	velocity += knockback
	knockback = knockback.move_toward(Vector2.ZERO, 2000 * delta)
		
	move_and_slide()
		
	if Input.is_action_just_pressed("attack") and not is_reloading and not is_attacking:
		attack()

	if Input.is_action_just_pressed("reload") and current_weapon == Weapon.GUN and not is_reloading:
		reload()

func equip_weapon(new_weapon):
	match new_weapon.to_lower():
		"sword":
			current_weapon = Weapon.SWORD
		"mace":
			current_weapon = Weapon.MACE
		"gun":
			current_weapon = Weapon.GUN
		_:
			current_weapon = Weapon.NONE
	
	match current_weapon:
		Weapon.NONE:
			$AnimatedSprite2D.play("walking_base")
		Weapon.SWORD:
			$AnimatedSprite2D.play("walking_sword")
		Weapon.MACE:
			$AnimatedSprite2D.play("walking_mace")
		Weapon.GUN:
			$AnimatedSprite2D.play("walking_gun")
			
	
func get_total_damage():
	return base_damage + (weapon_upgrades * 0.5)
	
func attack():
	if current_weapon == Weapon.NONE:
		return
	
	is_attacking = true
	
	match current_weapon:
		Weapon.SWORD:
			print("Swung sword in direction ", facing_direction, " for ", get_total_damage(), " damage")
			sword_collision.disabled = false
			$WeaponPivot/SwordHitbox/WeaponAnim.visible = true
			$WeaponPivot/SwordHitbox/WeaponAnim.play("sword")
			await get_tree().create_timer(0.2).timeout
			$WeaponPivot/SwordHitbox/WeaponAnim.visible = false
			sword_collision.disabled = true
		Weapon.MACE:
			print("Slammed mace around Lonk for ", get_total_damage(), " damage")
			mace_collision.disabled = false
			$MaceHitbox/MaceAnim.visible = true
			$MaceHitbox/MaceAnim.play("mace")
			await get_tree().create_timer(0.5).timeout
			$MaceHitbox/MaceAnim.visible = false
			mace_collision.disabled = true
		Weapon.GUN:
			if current_ammo > 0:
				current_ammo -= 1
				print("Shot bullet in direction ", facing_direction, "! Ammo left ", current_ammo)
				var new_bullet = bullet_scene.instantiate()
				
				new_bullet.global_position = global_position
				
				new_bullet.direction = facing_direction
				new_bullet.damage = get_total_damage()
				get_tree().root.add_child(new_bullet)
				await get_tree().create_timer(0.2).timeout
			else:
				print("Out of Ammo.")
				await get_tree().create_timer(0.1).timeout
				
	# await get_tree().create_timer(0.5).timeout
	is_attacking = false
	
func reload():
	is_reloading = true
	print("Reloading...")
	await get_tree().create_timer(1).timeout
	current_ammo = max_ammo
	print("Reloaded! Ammo: ", current_ammo)
	is_reloading = false


func _on_sword_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.take_damage(get_total_damage(), global_position)


func _on_mace_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.take_damage(get_total_damage(), global_position)

func take_damage(amount, source_position):
	if is_invincible:
		return
	
	current_hp -= amount
	print("Lonk took Damage! HP left: ", current_hp)
	
	var knockback_direction = (global_position - source_position).normalized()
	knockback = knockback_direction * 800
	
	if current_hp<= 0:
		print("Game Over! Lonk Died.")
	
	is_invincible = true
	$AnimatedSprite2D.modulate = Color(1,0,0,0.5)
	await get_tree().create_timer(0.1).timeout
	$AnimatedSprite2D.modulate = Color(1,1,1,1)
	await get_tree().create_timer(0.1).timeout
	$AnimatedSprite2D.modulate = Color(1,0,0,0.5)
	await get_tree().create_timer(0.1).timeout
	$AnimatedSprite2D.modulate = Color(1,1,1,1)
	await get_tree().create_timer(0.1).timeout
	$AnimatedSprite2D.modulate = Color(1,0,0,0.5)
	await get_tree().create_timer(0.2).timeout
	$AnimatedSprite2D.modulate = Color(1,1,1,1)
	is_invincible = false
