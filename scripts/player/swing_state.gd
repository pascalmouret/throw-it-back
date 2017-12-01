extends "player_state.gd"

const OFFSET = Vector2(48, 0)

const ThrowState = preload("res://scripts/player/throw_state.gd")
const IdleState = preload("res://scripts/player/idle_state.gd")
 
var direction_multiplier = 1
var remaining_rotation = PI * 2
var catch_velocity = 0

func _init(player).(player):
	pass
	
func enter():
	print("swing")
	OS.set_time_scale(0.2)
	player.current_catch = player.potential_catch
	catch_velocity = player.current_catch.get_velocity().length()
	if !player.is_potential_catch_right:
		direction_multiplier = -1
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
		(OFFSET).rotated(player.get_rot()) * direction_multiplier + player.get_global_pos()
	)

func play_animation(delta):
	player.sprite.set_animation(SWING_ANIMATION)
	
func release_vector():
	return Vector2(0, catch_velocity).rotated(player.get_global_rot())
	
func draw():
	player.draw_line(
		player.current_catch.get_global_pos() - player.get_pos(),
		(release_vector().rotated(-player.get_rot())).normalized() * 1000, 
		Color(1, 1, 1),
		5
	)

func on_hit(throwable):
	if throwable != player.current_catch:
		player.change_morale(-throwable.damage)
		player.current_catch.queue_free()
		throwable.queue_free()	
		return IdleState.new(player)
