extends Node2D

signal spawn_throwable(throwable, pos, velocity)

export var throw_offset = Vector2(0, 0)
export var throw_velocity = 30

func throw(scene):
	emit_signal(
		"spawn_throwable",
		scene.instance(), 
		throw_offset + get_global_pos(),
		Vector2(0, throw_velocity).rotated(get_global_rot())
	)
	