extends KinematicBody2D

onready var throwable_class = preload("res://scripts/throwable.gd")
onready var sprite = get_node("sprite")

const WALK_ANIMATION = "walk"
const STRAFE_ANIMATION = "strafe"
const IDLE_ANIMATION = "idle"
const CATCH_ANIMATION = "catch"
const SWING_ANIMATION = "swing"
const THROW_ANIMATION = "throw"

const MAX_ROTATION = 30
const MIN_MOUSE_VECTOR = 5
const THROWABLE_OFFSET = Vector2(48, 0)

export var acceleration = 500
export var friction = 500
export var max_velocity = 500

var velocity = Vector2(0, 0)
var current_catch = null
var catch_velocity = Vector2(0, 0)
var remaining_rotation = 0

var potential_catch = null
var is_potential_catch_right = false

func _ready():
	set_process_input(true)
	set_fixed_process(true)

func _fixed_process(delta):
	if !is_input_blocked():
		movement(delta)
	animate(delta)
	if has_catch():
		handle_throw(delta)

func has_catch():
	return current_catch != null

func is_input_blocked():
	[CATCH_ANIMATION, THROW_ANIMATION].has(sprite.get_animation())

func rotation_direction():
	if remaining_rotation > 0: return -1
	else: return 1

func movement(delta):
	var input = Vector2(
		Input.is_action_pressed("ui_right") - Input.is_action_pressed("ui_left"),
		Input.is_action_pressed("ui_down") - Input.is_action_pressed("ui_up")
	)

	if input.length() == 0 || has_catch():
		if velocity.x > 0:
			velocity.x -= clamp(friction, 0, velocity.x)
		if velocity.x < 0:
			velocity.x += clamp(friction, 0, velocity.x*-1)
		if velocity.y > 0:
			velocity.y -= clamp(friction, 0, velocity.y)
		if velocity.y < 0:
			velocity.y += clamp(friction, 0, velocity.y*-1)
	elif !has_catch():
		velocity = (velocity + acceleration * input * delta).clamped(max_velocity)

	var motion = move(velocity)
	if is_colliding():
		var normal = get_collision_normal()
		motion = normal.slide(motion)
		velocity = normal.slide(motion)
		move(motion)

func animate(delta):
	if ![CATCH_ANIMATION, SWING_ANIMATION, THROW_ANIMATION].has(sprite.get_animation()):
		var real_vector = velocity.rotated(get_rot() * -1)
		if abs(real_vector.length()) > 1:
			if abs(real_vector.x) > abs(real_vector.y):
				sprite.play(STRAFE_ANIMATION)
				sprite.set_flip_h(real_vector.x < 0)
			else:
				sprite.play(WALK_ANIMATION)
		elif sprite.get_animation() != CATCH_ANIMATION:
			sprite.play(IDLE_ANIMATION)

func handle_throw(delta):
	update()
	if abs(remaining_rotation) < 0.1:
		throw()
	else:
		var rot = clamp(remaining_rotation, -catch_velocity * 1.5 * delta, catch_velocity * 1.5 * delta)
		rotate(rot)
		remaining_rotation -= rot
		set_throwable_pos()

func set_throwable_pos():
	current_catch.set_global_pos(
		(THROWABLE_OFFSET).rotated(get_rot()) * rotation_direction() + get_global_pos()
	)

func reach():
	sprite.play(CATCH_ANIMATION)
	if potential_catch != null:
		print(potential_catch)
		sprite.set_flip_h(!is_potential_catch_right)

func catch():
	if potential_catch != null && catch_comes_from_front():
		sprite.play(SWING_ANIMATION)
		current_catch = potential_catch
		remaining_rotation = PI
		if is_potential_catch_right:
			remaining_rotation *= -1
		catch_velocity = current_catch.get_velocity().length()
		current_catch.set_velocity(Vector2(0, 0))
		set_throwable_pos()
		potential_catch = null
	else:
		sprite.play(IDLE_ANIMATION)

func catch_comes_from_front():
	return potential_catch.get_velocity().rotated(get_rot()).y < 0

func throw():
	current_catch.set_velocity(global_release_vector())
	current_catch = null
	remaining_rotation = 0
	sprite.play(THROW_ANIMATION)

func release():
	rotate(PI * rotation_direction())
	sprite.set_animation(IDLE_ANIMATION)
	update()

func global_release_vector():
	return Vector2(0, catch_velocity).rotated(get_global_rot())

func _input(ev):
	if !is_input_blocked():
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
		reach()

func handle_catch_input(ev):
	if ev.is_action_pressed("ui_accept"):
		throw()

func _on_sprite_finished():
	if sprite.get_animation() == CATCH_ANIMATION:
		catch()
	elif sprite.get_animation() == THROW_ANIMATION:
		release()

func _draw():
	if has_catch():
		draw_line(
			current_catch.get_global_pos() - get_pos(),
			(global_release_vector().rotated(-get_rot())).normalized() * 1000, 
			Color(1, 1, 1),
			5
		)

func _on_catcher_right_area_enter(area):
	if area extends throwable_class && potential_catch == null:
		potential_catch = area
		is_potential_catch_right = true

func _on_catcher_left_area_enter(area):
	if area extends throwable_class && potential_catch == null:
		potential_catch = area
		is_potential_catch_right = false

func _on_catcher_right_area_exit(area):
	if potential_catch == area:
		potential_catch = null

func _on_catcher_left_area_exit(area):
	if potential_catch == area:
		potential_catch = null
