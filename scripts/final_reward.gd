extends Area2D

func _ready():
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		print("Lonk touched the Fiforce! YOU WIN!")
		get_tree().call_deferred("change_scene_to_file","res://scenes/Victory.tscn")
		queue_free()
