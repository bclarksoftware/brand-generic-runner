extends TextureRect

var scroll_speed = 200  # Speed of scrolling

func _process(delta):
	position.y += scroll_speed * delta
	if position.y >= 600:  # Reset to create loop effect
		position.y = 0
