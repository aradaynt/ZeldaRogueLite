extends Control

const ROOM_SIZE = 12 
const SPACING = 18

func _process(_delta):
	queue_redraw()

func _draw():
	var center_x = size.x / 2.0
	var center_y = size.y / 2.0
	var current_coords = GameManager.current_room_coords
	for coords in GameManager.visited_rooms:
		var offset_x = (coords.x - current_coords.x) * SPACING
		var offset_y = (coords.y - current_coords.y) * SPACING
		var rect = Rect2(center_x + offset_x - (ROOM_SIZE / 2.0), center_y + offset_y - (ROOM_SIZE / 2.0), ROOM_SIZE, ROOM_SIZE)
		if coords == current_coords:
			draw_rect(rect, Color(0.2, 0.8, 0.2))
		elif coords == Vector2.ZERO:
			draw_rect(rect, Color(0.9, 0.9, 0.1))
		else:
			draw_rect(rect, Color(0.7, 0.7, 0.7))
