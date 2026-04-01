extends Area2D

var speed = 600.0
var direction = Vector2.ZERO
var damage = 1.0

# ADDED: This tells the bullet who it belongs to
var is_enemy_bullet = false 

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if is_enemy_bullet:
		# BOSS BULLET LOGIC
		if body.is_in_group("enemy"):
			return # Pass safely right through the boss and minions!
			
		if body.name == "Player":
			if body.has_method("take_damage"):
				body.take_damage(damage, global_position)
	else:
		# PLAYER BULLET LOGIC
		if body.name == "Player":
			return # Pass safely through Lonk!
			
		if body.is_in_group("enemy"):
			if body.has_method("take_damage"):
				body.take_damage(damage, global_position)
			
	# Destroy the bullet after hitting its valid target (or a wall)
	queue_free()
