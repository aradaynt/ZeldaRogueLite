extends Area2D

var speed = 600.0
var direction = Vector2.ZERO
var damage = 1.0

var is_enemy_bullet = false 

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if is_enemy_bullet:
		if body.is_in_group("enemy"):
			return
			
		if body.name == "Player":
			if body.has_method("take_damage"):
				body.take_damage(damage, global_position)
	else:
		if body.name == "Player":
			return
			
		if body.is_in_group("enemy"):
			if body.has_method("take_damage"):
				body.take_damage(damage, global_position)
			
	queue_free()
