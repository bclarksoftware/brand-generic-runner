class_name Player extends CharacterBody2D

signal player_answered(current_lane : int)

const NUM_LANES: int = 4

@export var lane_container : Node

var current_lane: int = 0

@onready var animated_sprite = $AnimatedSprite2D 


func _ready():
	update_position()
	animated_sprite.play("Run")


func _process(delta):
	if Input.is_action_just_pressed("move_left"):
		move_left()

	if Input.is_action_just_pressed("move_right"):
		move_right()

	if Input.is_action_just_pressed("select_answer"):
		player_answered.emit(current_lane)


func move_left():
	if current_lane > 0:
		current_lane -= 1
		update_position()
		animated_sprite.flip_h = true


func move_right():
	if current_lane < NUM_LANES - 1:
		current_lane += 1
		update_position()
		animated_sprite.flip_h = false


func update_position():
	var lane_nodes = lane_container.get_children()
	var target_lane = lane_nodes[current_lane]

	# ✅ Move to the center of the lane
	var lane_center_x = target_lane.global_position.x + (target_lane.get_rect().size.x / 2)
	global_position.x = lane_center_x
