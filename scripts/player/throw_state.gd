extends "player_state.gd"

const IdleState = preload("res://scripts/player/idle_state.gd")

var escape_vector = null

func _init(player, vector).(player):
	escape_vector = vector

func enter():
	player.current_catch.set_velocity(escape_vector)
	player.current_catch.rethrown = true

func play_animation(delta):
	player.sprite.set_animation(THROW_ANIMATION)
	player.sprite.set_flip_h(!player.is_catch_right)

func animation_done():
	player.current_catch = null
	return IdleState.new(player)
	
func on_hit(throwable):
	if throwable != player.current_catch:
		player.change_morale(-throwable.damage)
		throwable.queue_free()
		return IdleState.new(player)
	