extends KinematicBody2D

const MAX_ROTATION = 30
const MIN_MOUSE_VECTOR = 5

export var acceleration = 500
export var friction = 500
export var max_velocity = 500

var velocity = Vector2(0, 0)

func _ready():
	set_process_input(true)
	set_fixed_process(true)

func _fixed_process(delta):
	movement(delta)
	
func movement(delta):
	var input = Vector2(
		Input.is_action_pressed("ui_right") - Input.is_action_pressed("ui_left"),
		Input.is_action_pressed("ui_down") - Input.is_action_pressed("ui_up")
	)
	
	if input.length() == 0:
		if velocity.x > 0:
			velocity.x -= clamp(friction, 0, velocity.x)
		if velocity.x < 0:
			velocity.x += clamp(friction, 0, velocity.x*-1)
		if velocity.y > 0:
			velocity.y -= clamp(friction, 0, velocity.y)
		if velocity.y < 0:
			velocity.y += clamp(friction, 0, velocity.y*-1)
	else:
		velocity = (velocity + acceleration * input * delta).clamped(max_velocity)
	
	move(velocity)
	
func _input(ev):
	if ev.type == InputEvent.MOUSE_MOTION:
		if ev.relative_pos.length() > MIN_MOUSE_VECTOR:
			rotate(clamp(Vector2(0, 0).angle_to_point(ev.relative_pos) - get_rot(), -MAX_ROTATION, MAX_ROTATION))