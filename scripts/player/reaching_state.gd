extends "player_state.gd"

const REACH_TIME = 0.5
const IdleState = preload("res://scripts/player/idle_state.gd")
const SwingState = preload("res://scripts/player/swing_state.gd")

var timer = Timer.new()

func _init(player).(player):
	pass
	
func fixed_process(delta):
	if timer.get_time_left() == 0 || !player.action_pressed:
		return IdleState.new(player)
	if player.potential_catch != null && player.potential_catch.get_global_pos().distance_to(player.get_global_pos()) < 55:
		return SwingState.new(player)

func enter():
	timer.set_wait_time(REACH_TIME)
	timer.set_one_shot(true)
	player.add_child(timer)
	timer.start()
	player.sprite.set_animation(CATCH_ANIMATION)
	player.sprite.set_flip_h(!player.is_potential_catch_right)

func animation_done():
	if player.sprite.get_animation() == CATCH_ANIMATION:
		player.sprite.set_animation(SWING_ANIMATION)
		
func exit():
	player.remove_child(timer)