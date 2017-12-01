extends "player_state.gd"

const ReachingState = preload("res://scripts/player/reaching_state.gd")
const IdleState = preload("res://scripts/player/idle_state.gd")

const IDLE_THRESHOLD = 0.5
	
func _init(player).(player):
	pass
	
func fixed_process(delta):
	player.movement(player.movement_vector, delta)
	if player.velocity.length() < IDLE_THRESHOLD:
		return IdleState.new(player)
	if (player.action_pressed && player.action_pressed_changed):
		return ReachingState.new(player)
		
func input(ev):
	player.rotation(ev)
	
func play_animation(delta):
	var real_vector = player.velocity.rotated(player.get_rot() * -1)
	if abs(real_vector.x) > abs(real_vector.y):
		player.sprite.set_animation(STRAFE_ANIMATION)
		player.sprite.set_flip_h(real_vector.x < 0)
	else:
		player.sprite.set_animation(WALK_ANIMATION)

func animation_done():
	player.sprite.set_flip_h(false)