extends "player_state.gd"

const IdleState = preload("res://scripts/player/idle_state.gd")

var escape_vector = null
var done = false

func _init(player, vector).(player):
	escape_vector = vector

func enter():
	player.current_catch.set_velocity(escape_vector)
	player.current_catch = null

func fixed_process(delta):
	if done:
		return IdleState.new(player)

func play_animation(delta):
	player.sprite.set_animation(THROW_ANIMATION)

func animation_done():
	var direction_multiplier = 1
	if !player.is_potential_catch_right:
		direction_multiplier = -1
	player.rotate(PI * direction_multiplier)
	done = true