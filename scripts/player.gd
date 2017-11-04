extends KinematicBody2D

const MAX_ROTATION = 30
const MIN_MOUSE_VECTOR = 5
const THROWABLE_OFFSET = Vector2(32, 0)

export var acceleration = 500
export var friction = 500
export var max_velocity = 500

var velocity = Vector2(0, 0)
var current_catch = null
var catch_velocity = Vector2(0,0)
var remaining_rotation = 0

onready var catcher = get_node("catcher")
onready var throwable_class = preload("res://scripts/throwable.gd")

func _ready():
	set_process_input(true)
	set_fixed_process(true)

func _fixed_process(delta):
	movement(delta)
	if has_catch():
		print("handle")
		handle_throw(delta)
	
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
	
	var motion = move(velocity)
	if is_colliding():
		var normal = get_collision_normal()
		motion = normal.slide(motion)
		velocity = normal.slide(motion)
		move(motion)
		
func handle_throw(delta):
	if abs(remaining_rotation) < 0.1:
		throw()
	else:
		var rot = clamp(remaining_rotation, -catch_velocity * delta, catch_velocity * delta)
		rotate(rot)
		current_catch.set_pos(THROWABLE_OFFSET.rotated(get_rot()) + get_global_pos())
		remaining_rotation -= rot
		
func has_catch():
	return current_catch != null

func catch(throwable):
	OS.set_time_scale(0.5)
	current_catch = throwable
	remaining_rotation = 2.2 * PI
	catch_velocity = current_catch.get_velocity().length()
	current_catch.set_velocity(Vector2(0, 0))
	current_catch.set_pos(THROWABLE_OFFSET.rotated(get_rot()) + get_global_pos())
	
func throw():
	print(catch_velocity)
	OS.set_time_scale(1)
	remaining_rotation = 0
	current_catch.set_velocity(Vector2(0, catch_velocity).rotated(get_rot()))
	current_catch = null
	
func _input(ev):
	if has_catch():
		handle_catch_input(ev)
	else:
		handle_default_input(ev)
		
func handle_default_input(ev):
	if ev.type == InputEvent.MOUSE_MOTION && ev.relative_pos.length() > MIN_MOUSE_VECTOR:
		rotate(clamp(
			Vector2(0, 0).angle_to_point(ev.relative_pos) - get_rot(),
			-MAX_ROTATION,
			MAX_ROTATION
		))
	if ev.is_action_pressed("ui_accept"):
		for b in catcher.get_overlapping_areas():
			if b extends throwable_class:
				catch(b)
				break
				
func handle_catch_input(ev):
	if ev.is_action_pressed("ui_accept"):
		throw()
