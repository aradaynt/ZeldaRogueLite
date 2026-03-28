extends CharacterBody2D

const SPEED = 130.0
var max_hp = 1.0
var current_hp = max_hp

var player = null
var is_active = false

@onready var anim = $AnimatedSprite2D

func _ready():
	player = get_tree().get_first_node_in_group("player")
	anim.play("appear")
	await anim.animation_finished
	is_active = true
	anim.play("idle")

func _physics_process(_delta):
	if not is_active or player == null or not is_instance_valid(player):
		return
	
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * SPEED
	anim.flip_h = direction.x < 0
	
	move_and_slide()

func take_damage(amount, _source_position):
	if not is_active: 
		return
		
	current_hp -= amount
	if current_hp <= 0:
		die()

func _on_hitbox_body_entered(body):
	if is_active and body.name == "Player":
		body.take_damage(1.0, global_position)
		die() 

func die():
	is_active = false
	velocity = Vector2.ZERO 
	$Hitbox.set_deferred("monitoring", false)
	$CollisionShape2D.set_deferred("disabled", true)
	anim.play("death")
	await anim.animation_finished
	queue_free()
