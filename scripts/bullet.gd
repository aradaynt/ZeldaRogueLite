extends Area2D

var speed = 600.0
var direction = Vector2.ZERO
var damage = 1.0

func _physics_process(delta):
	position += direction *speed * delta



func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		return 
		
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage, global_position)
			
	queue_free()
