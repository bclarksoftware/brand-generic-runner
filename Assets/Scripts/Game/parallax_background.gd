extends ParallaxBackground

@export var scroll_speed: float = 100.0

func _process(delta):
	scroll_offset.y += scroll_speed * delta
