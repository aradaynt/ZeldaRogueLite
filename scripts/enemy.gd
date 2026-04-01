extends CharacterBody2D

var hp = 3.0
var speed = 80.0
var player = null

var knockback = Vector2.ZERO
var is_stunned = false
@onready var hurt_sound = $HurtSound

@onready var nav_agent = $NavigationAgent2D 

var particle_scene = preload("res://scenes/death_particles.tscn")

func _physics_process(delta):
	if is_stunned:
		velocity = knockback
		knockback = knockback.move_toward(Vector2.ZERO, 2000 * delta)
	elif player != null:
		$AnimatedSprite2D.play("walking")
		
		nav_agent.target_position = player.global_position
		
		var next_path_position = nav_agent.get_next_path_position()
		
		var direction = global_position.direction_to(next_path_position)
		velocity = direction * speed
		
		if velocity.x < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.play("still")
		velocity = Vector2.ZERO   
		
	move_and_slide()

func take_damage(amount, source_position):
	hurt_sound.play()
	hp -= amount
	print("Enemy took ", amount, " damage. HP left: ", hp)
	var knockback_direction = (global_position - source_position).normalized()
	knockback = knockback_direction * 600 
	is_stunned = true
	
	if hp <= 0:
		print("Enemy defeated!")
		die()
		return 
		
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
	await get_tree().create_timer(0.3).timeout
	is_stunned = false

func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body

func _on_detection_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null

func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(1.0, global_position)

func die():
	var splat = particle_scene.instantiate()
	player = get_tree().get_first_node_in_group("player")
	
	if player != null:
		var hit_direction = (global_position - player.global_position).normalized()
		
		splat.global_position = global_position + (hit_direction * 20.0)
		
		splat.rotation = hit_direction.angle()
	else:
		splat.global_position = global_position
		
	get_tree().current_scene.add_child(splat)
	
	remove_from_group("enemy")
	
	var main_node = get_tree().current_scene 
	if main_node.has_method("check_room_cleared"):
		main_node.check_room_cleared()
		
	queue_free()
