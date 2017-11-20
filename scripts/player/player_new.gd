extends KinematicBody2D

onready var IdleState = preload("res://scripts/player/idle_state.gd")
onready var throwable_class = preload("res://scripts/throwable.gd")
onready var sprite = get_node("sprite")

export var acceleration = 200
export var friction = 200
export var max_velocity = 20

const MAX_ROTATION = 30
const MIN_MOUSE_VECTOR = 5

var current_state = null
var velocity = Vector2(0, 0)

var potential_catch = null
var is_potential_catch_right = false

var action_pressed = false
var movement_vector = Vector2(0, 0)	

func _ready():
	current_state = IdleState.new(self)
	current_state.enter()
	set_fixed_process(true)
	set_process_input(true)

func _fixed_process(delta):
	action_pressed = Input.is_action_pressed("ui_accept")
	movement_vector = get_input_vector()
	var new_state = current_state.fixed_process(delta)
	if new_state != null && new_state != current_state:
		current_state.exit()
		current_state = new_state
		current_state.enter()
	current_state.play_animation(delta)
	
func _input(event):
	current_state.input(event)
	
func get_input_vector():
	return Vector2(
		Input.is_action_pressed("ui_right") - Input.is_action_pressed("ui_left"),
		Input.is_action_pressed("ui_down") - Input.is_action_pressed("ui_up")
	)

func movement(vector, delta):
	var normal = vector.normalized()
	if vector.length() > 0:
		velocity = (velocity + (normal * acceleration)).clamped(max_velocity)
	else:
		velocity = (velocity + (normal * -1 * friction)).clamped(0)
	
	var motion = move(velocity)
	if is_colliding():
		var normal = get_collision_normal()
		motion = normal.slide(motion)
		velocity = normal.slide(motion)
		move(motion)

func rotation(ev):
	if ev.type == InputEvent.MOUSE_MOTION && ev.relative_pos.length() > MIN_MOUSE_VECTOR:
		rotate(clamp(
			Vector2(0, 0).angle_to_point(ev.relative_pos) - get_rot(),
			-MAX_ROTATION,
			MAX_ROTATION
		))

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