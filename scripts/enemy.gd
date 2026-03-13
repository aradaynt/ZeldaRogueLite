extends CharacterBody2D

var hp = 3.0

func take_damage(amount):
	hp -=amount
	print("Enemy took ", amount, " damage. HP left: ", hp)
	
	if hp <=0:
		print("Enemy Defeated")
		queue_free()
