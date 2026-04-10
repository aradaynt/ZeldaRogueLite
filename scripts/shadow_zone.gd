extends Area2D

var damage = 2.0
var is_active = false

@onready var sprite = $Sprite2D
@onready var danger_icon = $DangerIcon

func _ready():
	danger_icon.visible = true
	sprite.modulate = Color(0, 0, 0, 0.4)
	
	await get_tree().create_timer(0.2).timeout
	is_active = true
	
	for body in get_overlapping_bodies():
		if body.name == "Player":
			body.speed_multiplier = 0.4
			
	await get_tree().create_timer(8.0).timeout 
	
	for body in get_overlapping_bodies():
		if body.name == "Player":
			body.speed_multiplier = 1.0
			
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if is_active and body.name == "Player":
		body.speed_multiplier = 0.4


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		body.speed_multiplier = 1.0
