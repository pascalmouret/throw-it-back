extends "thrower.gd"

onready var player_class = preload("res://scripts/player/player.gd")
onready var ball = preload("res://ball.tscn")

export var acceleration = 50
export var friction = 50
export var max_velocity = 50
export var min_distance = 300
export var throw_interval = 2

var player = null
var velocity = Vector2(0, 0)

func _ready():
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
	
func start_throw_timer():
	var timer = Timer.new()
	timer.connect("timeout", self, "_on_throw_timer_timeout")
	timer.set_wait_time(throw_interval)
	timer.start()
	add_child(timer)

func _on_detector_body_enter(body):
	print(body)
	if body extends player_class && player == null:
		set_process(true)
		player = body
		rotate_towards_player()
		throw(ball)
		start_throw_timer()

func _on_throw_timer_timeout():
	throw(ball)