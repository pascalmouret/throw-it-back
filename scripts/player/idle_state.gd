extends "player_state.gd"

const ReachingState = preload("res://scripts/player/reaching_state.gd")
const WalkingState = preload("res://scripts/player/walking_state.gd")
	
func _init(player).(player):
	pass
	
func fixed_process(delta):
	if (player.action_pressed && player.action_pressed_changed):
		return ReachingState.new(player)
	if (player.movement_vector.length() > 0):
		return WalkingState.new(player)
		
func input(ev):
	player.rotation(ev)
	
func play_animation(delta):
	player.sprite.play(IDLE_ANIMATION)