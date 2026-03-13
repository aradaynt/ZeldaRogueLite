extends CharacterBody2D

var hp = 3.0
var speed = 100.0
var player = null

var knockback = Vector2.ZERO
var is_stunned = false

func _physics_process(delta):
	if is_stunned:
		velocity = knockback
		knockback = knockback.move_toward(Vector2.ZERO, 2000 * delta)
	elif player != null:
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player > 25.0: 
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * speed
		else:
			velocity = Vector2.ZERO 
	else:
		velocity = Vector2.ZERO   
	move_and_slide()

func take_damage(amount, source_position):
	hp -=amount
	print("Enemy took ", amount, " damage. HP left: ", hp)
	var knockback_direction = (global_position - source_position).normalized()
	knockback = knockback_direction * 600 
	is_stunned = true
	if hp <= 0:
		print("Enemy defeated!")
		var main_room = get_tree().current_scene
		if main_room.has_method("enemy_defeated"):
			main_room.enemy_defeated()
		queue_free()
		return 
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
