extends CharacterBody2D

const SPEED = 80.0 
var max_hp = 30.0  
var current_hp = max_hp

var player = null

enum State {CHASE, TELEGRAPH, ATTACK, SUMMON}
var current_state = State.CHASE
var attack_range = 60.0 

var summon_cooldown_time = 8.0
var summon_timer = 0.0
var spirit_scene = preload("res://scenes/spirit.tscn") 
var reward_scene = preload("res://scenes/final_Reward.tscn")

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
		summon_timer += delta
		if summon_timer >= summon_cooldown_time:
			start_summon()
		
	match current_state:
		State.CHASE:
			anim.play("idle") 
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * SPEED
			anim.flip_h = direction.x < 0
			if anim.flip_h:
				$ScytheHitbox.position.x = -abs($ScytheHitbox.position.x)
			else:
				$ScytheHitbox.position.x = abs($ScytheHitbox.position.x)
			
			if global_position.distance_to(player.global_position) < attack_range:
				start_attack()
				
		State.TELEGRAPH:
			velocity = Vector2.ZERO
			
		State.ATTACK:
			velocity = Vector2.ZERO
			
		State.SUMMON:
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
	
	anim.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	anim.modulate = Color(1, 1, 1)
	
	if current_hp <= 0:
		die()

func die():
	scythe_collision.set_deferred("disabled", true)
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
