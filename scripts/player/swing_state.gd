extends "player_state.gd"

const OFFSET = Vector2(0, 48)

const ThrowState = preload("res://scripts/player/throw_state.gd")
const IdleState = preload("res://scripts/player/idle_state.gd")
 
var direction_multiplier = 1
var remaining_rotation = PI * 1.5
var catch_velocity = 0

func _init(player).(player):
	pass
	
func enter():
	OS.set_time_scale(0.05)
	player.current_catch = player.potential_catch
	player.is_catch_right = player.is_potential_catch_right
	catch_velocity = player.current_catch.get_velocity().length()
	if !player.is_catch_right:
		direction_multiplier = -1
	player.rotate(PI / 2 * direction_multiplier)
	remaining_rotation = remaining_rotation * direction_multiplier

func exit():
	OS.set_time_scale(1)

func fixed_process(delta):
	if !player.action_pressed || abs(remaining_rotation) < 0.1:
		return ThrowState.new(player, release_vector())
	var rot = clamp(remaining_rotation, -catch_velocity * 1.5 * delta, catch_velocity * 1.5 * delta)
	player.rotate(rot)
	remaining_rotation -= rot
	player.current_catch.set_global_pos(
		OFFSET.rotated(player.get_global_rot() + (PI / 2 * direction_multiplier)) + player.get_global_pos()
	)

func play_animation(delta):
	player.sprite.set_animation(SWING_ANIMATION)
	
func release_vector():
	return Vector2(0, catch_velocity).rotated(player.get_global_rot() + PI)
	
func draw():
	player.draw_line(
		OFFSET.rotated(player.get_global_rot() + (PI / 2 * direction_multiplier)),
		((release_vector()).normalized() * 1000).rotated(-player.get_global_rot()), 
		Color(1, 1, 1),
		5
	)
	
func on_hit(throwable):
	if throwable != player.current_catch:
		player.change_morale(-throwable.damage)
		player.current_catch.queue_free()
		throwable.queue_free()	
		return ThrowState.new(player, release_vector())
