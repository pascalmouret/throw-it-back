extends KinematicBody2D

onready var player_class = preload("res://scripts/player.gd")

export var acceleration = 50
export var friction = 50
export var max_velocity = 50
export var min_distance = 300

var player = null
var velocity = Vector2(0, 0)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	rotate_towards_player()
	move_towards_player(delta)

func rotate_towards_player():
	set_rot(player.get_global_pos().angle_to_point(get_global_pos()))
	
func move_towards_player(delta):
	var distance = get_global_pos().distance_to(player.get_global_pos())
	var vector = (player.get_global_pos() - get_global_pos()).normalized()
	if distance - min_distance > 1:
		velocity = (velocity + (vector * acceleration)).clamped(max_velocity)
	else:
		velocity = (velocity + (vector * -1 * friction)).clamped(0)

	move(velocity)

func _on_detector_body_enter( body ):
	print(body)
	if body extends player_class:
		print("yaaay")
		set_process(true)
		player = body
