extends Node2D

# Drag your two Marker2D nodes in here
@onready var marker_left = $SpawnMarkerLeft 
@onready var marker_right = $SpawnMarkerRight
@onready var choice_label = $ChoiceLabel

# We will store the actual items here once they spawn
var item_left = null
var item_right = null
var choice_made = false

func _ready():
	# 1. Spawn your two items here! 
	# (Replace these paths with however your game normally spawns random loot)
	var random_item_1 = load("res://scenes/weapons/sword_pickup.tscn").instantiate()
	var random_item_2 = load("res://scenes/weapons/gun_pickup.tscn").instantiate()
	
	# 2. Add them to the markers
	marker_left.add_child(random_item_1)
	marker_right.add_child(random_item_2)
	
	# 3. Save them to our variables so the referee can watch them
	item_left = random_item_1
	item_right = random_item_2

func _process(_delta):
	# Stop checking if the choice is made, or if the items haven't spawned yet
	if choice_made or item_left == null or item_right == null:
		return
		
	# Check if Lonk took the LEFT item
	if not is_instance_valid(item_left) and is_instance_valid(item_right):
		item_right.queue_free() # Delete the other item!
		choice_label.text = "A wise choice..."
		choice_made = true
		
	# Check if Lonk took the RIGHT item
	elif not is_instance_valid(item_right) and is_instance_valid(item_left):
		item_left.queue_free() # Delete the other item!
		choice_label.text = "A wise choice..."
		choice_made = true
