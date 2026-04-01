extends CharacterBody2D

const SPEED = 80.0 
var max_hp = 30.0  
var current_hp = max_hp

var player = null

enum State {CHASE, TELEGRAPH, ATTACK, SUMMON, TELEPORT_OUT, TELEPORT_IN, BULLET_RING}
var current_state = State.CHASE
var attack_range = 60.0 

var knockback = Vector2.ZERO
var is_stunned = false

var summon_cooldown_time = 8.0
var summon_timer = 0.0

var special_attack_cooldown = 5.0
var special_timer = 0.0
var dash_direction = Vector2.ZERO

var spirit_scene = preload("res://scenes/spirit.tscn") 
var reward_scene = preload("res://scenes/final_Reward.tscn")
var bullet_scene = preload("res://scenes/bullet.tscn")
var is_dying = false

@onready var health_bar = $ProgressBar
@onready var anim = $AnimatedSprite2D
@onready var danger_icon = $DangerIcon
@onready var scythe_collision = $ScytheHitbox/CollisionShape2D
@onready var hurt_sound = $BossHurt


func _ready():
	player = get_tree().get_first_node_in_group("player")
	
	health_bar.max_value = max_hp
	health_bar.value = current_hp
	danger_icon.visible = false

func _physics_process(delta):
	if player == null or not is_instance_valid(player):
		return
		
	if current_state == State.CHASE:
		# Summon Logic
		summon_timer += delta
		if summon_timer >= summon_cooldown_time:
			start_summon()
			return
			
		special_timer += delta
		if special_timer >= special_attack_cooldown:
			trigger_special_attack()
			return
		
	match current_state:
		State.CHASE:
			anim.play("idle") 
			if is_stunned:
				velocity = knockback
				knockback = knockback.move_toward(Vector2.ZERO, 2000 * delta)
			else:
				var direction = (player.global_position - global_position).normalized()
				velocity = direction * SPEED
				anim.flip_h = direction.x < 0
				
				if anim.flip_h:
					$ScytheHitbox.position.x = -abs($ScytheHitbox.position.x)
				else:
					$ScytheHitbox.position.x = abs($ScytheHitbox.position.x)
				
				if global_position.distance_to(player.global_position) < attack_range:
					start_attack()
				
		State.TELEGRAPH, State.ATTACK, State.SUMMON, State.BULLET_RING, State.TELEPORT_OUT, State.TELEPORT_IN:
			velocity = Vector2.ZERO
			
	move_and_slide()

func start_attack():
	if current_hp <= 0:
		return
	current_state = State.TELEGRAPH
	danger_icon.visible = true
	
	await get_tree().create_timer(0.6).timeout 
	
	if current_state != State.TELEGRAPH: return
	
	danger_icon.visible = false
	current_state = State.ATTACK
	anim.play("attacking")
	
	await anim.animation_finished
	
	if current_state == State.ATTACK:
		current_state = State.CHASE

func trigger_special_attack():
	special_timer = 0.0
	if randf() > 0.5:
		start_teleport()
	else:
		start_bullet_ring()

func start_teleport():
	current_state = State.TELEPORT_OUT
	danger_icon.visible = true
	
	var tween = create_tween()
	tween.tween_property(anim, "modulate:a", 0.0, 0.4) 
	
	await tween.finished
	if current_hp <= 0 or current_state != State.TELEPORT_OUT: return
	
	danger_icon.visible = false
	
	var random_angle = randf() * PI * 2
	var teleport_offset = Vector2(cos(random_angle), sin(random_angle)) * 50.0 
	
	global_position = player.global_position + teleport_offset
	
	var direction_to_player = (player.global_position - global_position).normalized()
	anim.flip_h = direction_to_player.x < 0
	if anim.flip_h:
		$ScytheHitbox.position.x = -abs($ScytheHitbox.position.x)
	else:
		$ScytheHitbox.position.x = abs($ScytheHitbox.position.x)
	
	current_state = State.TELEPORT_IN
	
	var tween2 = create_tween()
	tween2.tween_property(anim, "modulate:a", 1.0, 0.2)
	
	await tween2.finished
	if current_hp <= 0 or current_state != State.TELEPORT_IN: return
	
	start_attack()

func start_bullet_ring():
	current_state = State.BULLET_RING
	danger_icon.visible = true
	
	await get_tree().create_timer(0.5).timeout 
	
	if current_hp <= 0 or current_state != State.BULLET_RING: return
	
	danger_icon.visible = false
	
	var num_bullets = 8
	var angle_step = (2 * PI) / num_bullets
	
	for i in range(num_bullets):
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.direction = Vector2.RIGHT.rotated(i * angle_step)
		bullet.damage = 1.0 
		
		bullet.is_enemy_bullet = true 
		
		get_tree().current_scene.add_child(bullet)
		
	await get_tree().create_timer(0.5).timeout 
	
	if current_hp <= 0 or current_state != State.BULLET_RING: return
	
	current_state = State.CHASE

func start_summon():
	current_state = State.SUMMON
	summon_timer = 0.0
	
	anim.play("summon")
	
	await get_tree().create_timer(0.3).timeout 
	spawn_spirits()
	
	await anim.animation_finished
	
	if current_state == State.SUMMON:
		current_state = State.CHASE

func spawn_spirits():
	for i in range(3):
		var new_spirit = spirit_scene.instantiate()
		
		var random_x = randf_range(-40, 40)
		var random_y = randf_range(-40, 40)
		new_spirit.global_position = global_position + Vector2(random_x, random_y)
		get_tree().current_scene.add_child(new_spirit)

func take_damage(amount, _source_position):
	hurt_sound.play()
	current_hp -= amount
	health_bar.value = current_hp
	print("Boss took damage! HP: ", current_hp)
	
	if GameManager.equipped_weapon == "mace":
		var knockback_direction = (global_position - _source_position).normalized()
		knockback = knockback_direction * 600
		is_stunned = true
		await get_tree().create_timer(0.3).timeout
		is_stunned = false
	
	anim.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	anim.modulate = Color(1, 1, 1)
	await get_tree().create_timer(0.1).timeout
	anim.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	anim.modulate = Color(1, 1, 1)
	await get_tree().create_timer(0.1).timeout
	anim.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	anim.modulate = Color(1, 1, 1)
	
	if current_hp <= 0:
		die()
	is_stunned = false

func die():
	if is_dying:
		return
	is_dying = true
	scythe_collision.set_deferred("disabled", true)
	get_tree().call_group("enemy", "die")
	print("The Boss is defeated!")
	current_state = State.TELEGRAPH
	velocity = Vector2.ZERO
	
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	scythe_collision.set_deferred("disabled", true)
	
	anim.play("death")
	await anim.animation_finished
	
	var reward = reward_scene.instantiate()
	reward.global_position = global_position
	get_tree().current_scene.add_child(reward)
	
	queue_free()

func _on_hitbox_body_entered(body):
	if body.name == "Player":
		body.take_damage(2.0, global_position)
		
func _on_animated_sprite_2d_frame_changed() -> void:
	if current_hp <=0:
		return
	if anim.animation == "attacking":
		if anim.frame >= 2 and anim.frame <= 10:
			scythe_collision.disabled = false
		else:
			scythe_collision.disabled = true
	else:
		scythe_collision.disabled = true
		
func _on_scythe_hitbox_body_entered(body: Node2D) -> void:
	if current_hp <= 0:
		return
	if body.name == "Player":
		body.take_damage(3.0, global_position)
