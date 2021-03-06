extends KinematicBody2D

signal morale_change(new_morale)

onready var IdleState = preload("res://scripts/player/idle_state.gd")
onready var throwable_class = preload("res://scripts/throwable.gd")
onready var sprite = get_node("sprite")

export var morale = 100
export var acceleration = 200
export var friction = 200
export var max_velocity = 20

const MAX_ROTATION = 30
const MIN_MOUSE_VECTOR = 5

var current_state = null
var velocity = Vector2(0, 0)

var is_catch_right = true
var current_catch = null
var potential_catch = null
var is_potential_catch_right = false

var action_pressed = false
var action_pressed_changed = false
var movement_vector = Vector2(0, 0)

func _ready():
	current_state = IdleState.new(self)
	current_state.enter()
	set_fixed_process(true)
	set_process_input(true)

func _fixed_process(delta):
	update()
	set_action_pressed_status()
	movement_vector = get_input_vector()
	change_state(current_state.fixed_process(delta))
	current_state.play_animation(delta)
	
func _input(event):
	current_state.input(event)

func _draw():
	current_state.draw()
	
func change_state(new):
	if new != null && new != current_state:
		current_state.exit()
		current_state = new
		current_state.enter()
	
func get_input_vector():
	return Vector2(
		Input.is_action_pressed("ui_right") - Input.is_action_pressed("ui_left"),
		Input.is_action_pressed("ui_down") - Input.is_action_pressed("ui_up")
	)
	
func set_action_pressed_status():
	var old = action_pressed
	action_pressed = Input.is_action_pressed("ui_accept")
	action_pressed_changed = action_pressed != old

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
		
func register_hit(throwable):
	change_state(current_state.on_hit(throwable))

func change_morale(change):
	morale += change
	emit_signal("morale_change", morale)

func _on_catcher_right_area_enter(area):
	if area extends throwable_class:
		if potential_catch == null || potential_catch.get_global_pos().distance_to(get_global_pos()) > area.get_global_pos().distance_to(get_global_pos()):
			potential_catch = area
			is_potential_catch_right = true

func _on_catcher_left_area_enter(area):
	if area extends throwable_class:
		if potential_catch == null || potential_catch.get_global_pos().distance_to(get_global_pos()) > area.get_global_pos().distance_to(get_global_pos()):
			potential_catch = area
			is_potential_catch_right = false

func _on_catcher_right_area_exit(area):
	if potential_catch == area:
		potential_catch = null

func _on_catcher_left_area_exit(area):
	if potential_catch == area:
		potential_catch = null

func _on_sprite_finished():
	sprite.set_flip_h(false)
	change_state(current_state.animation_done())
