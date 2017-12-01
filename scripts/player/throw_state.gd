extends "player_state.gd"

const IdleState = preload("res://scripts/player/idle_state.gd")

var escape_vector = null

func _init(player, vector).(player):
	escape_vector = vector

func enter():
	player.current_catch.set_velocity(escape_vector)
	player.current_catch.rethrown = true

func fixed_process(delta):
	pass

func play_animation(delta):
	player.sprite.set_animation(THROW_ANIMATION)

func animation_done():
	var direction_multiplier = 1
	if !player.is_potential_catch_right:
		direction_multiplier = -1
	player.rotate(PI * direction_multiplier)
	player.current_catch = null	
	return IdleState.new(player)
	
func on_hit(throwable):
	if throwable != player.current_catch:
		player.change_morale(-throwable.damage)
		throwable.queue_free()
		return IdleState.new(player)
	