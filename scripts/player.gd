extends CharacterBody2D

const SPEED = 200.0
var speed_multiplier = 1.0

enum Weapon {NONE, SWORD, MACE, GUN}
var current_weapon = Weapon.NONE

var base_damage = 1.0
var weapon_upgrades = GameManager.player_weapon_upgrades

var max_ammo = 6
var current_ammo = max_ammo
var is_reloading = false
var is_attacking = false 

var max_mace_stamina = 3
var current_mace_stamina = max_mace_stamina
var stamina_regen_time = 1.5
var stamina_timer = 0.0
signal out_of_stamina

var facing_direction = Vector2.DOWN

var max_hp = GameManager.player_max_hp
var current_hp = GameManager.player_current_hp
var is_invincible = false

var knockback = Vector2.ZERO

var bullet_scene = preload("res://scenes/bullet.tscn")

@export var attack_cooldown = 0.15

@onready var weapon_pivot = $WeaponPivot
@onready var sword_collision = $WeaponPivot/SwordHitbox/CollisionShape2D
@onready var mace_collision = $MaceHitbox/CollisionShape2D
@onready var sword_sound = $SwordSound
@onready var mace_sound = $MaceSound
@onready var gun_sound = $GunSound
@onready var hurt_sound = $HurtSound

func _ready():
	if GameManager.equipped_weapon != "":
		equip_weapon(GameManager.equipped_weapon)
	sword_collision.disabled = true
	mace_collision.disabled = true


func _physics_process(delta) -> void:
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction != Vector2.ZERO:
		if not is_attacking:
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
		velocity = direction * current_speed * speed_multiplier
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
		velocity = Vector2.ZERO
	
	velocity += knockback
	knockback = knockback.move_toward(Vector2.ZERO, 4000 * delta)
	
	if not is_attacking and current_mace_stamina < max_mace_stamina and current_weapon == Weapon.MACE:
		stamina_timer += delta
		if stamina_timer >= stamina_regen_time:
			current_mace_stamina += 1
			AudioManager.play_stamina()
			stamina_timer = 0.0
	elif is_attacking:
		stamina_timer = 0.0
		
	if current_weapon != Weapon.MACE:
		current_mace_stamina = max_mace_stamina
		
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
			sword_sound.play()
			print("Swung sword in direction ", facing_direction, " for ", get_total_damage(), " damage")
			sword_collision.disabled = false
			$WeaponPivot/SwordHitbox/WeaponAnim.visible = true
			$WeaponPivot/SwordHitbox/WeaponAnim.play("sword")
			await get_tree().create_timer(0.2).timeout
			$WeaponPivot/SwordHitbox/WeaponAnim.visible = false
			sword_collision.disabled = true
		Weapon.MACE:
			if current_mace_stamina <= 0:
				print("Not enough stamina!")
				AudioManager.play_outostamina()
				out_of_stamina.emit()
				is_attacking = false
				return
			current_mace_stamina -= 1
			mace_sound.play()
			print("Slammed mace around Lonk for ", get_total_damage(), " damage")
			mace_collision.disabled = false
			$MaceHitbox/MaceAnim.visible = true
			$MaceHitbox/MaceAnim.play("mace")
			get_viewport().get_camera_2d().apply_shake(15.0)
			await get_tree().create_timer(0.5).timeout
			$MaceHitbox/MaceAnim.visible = false
			mace_collision.disabled = true
		Weapon.GUN:
			if current_ammo > 0:
				current_ammo -= 1
				gun_sound.play()
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
				
	await get_tree().create_timer(attack_cooldown).timeout
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
	
	hurt_sound.play()
	get_viewport().get_camera_2d().apply_shake(10.0)
	current_hp -= amount
	print("Lonk took Damage! HP left: ", current_hp)
	GameManager.player_current_hp = current_hp
	
	var knockback_direction = (global_position - source_position).normalized()
	knockback = knockback_direction * 800
	
	if current_hp<= 0:
		print("Game Over! Lonk Died.")
		die()
	
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

func die():
	print("Lonk has fallen!")
	get_tree().call_deferred("change_scene_to_file", "res://scenes/game_over.tscn")
