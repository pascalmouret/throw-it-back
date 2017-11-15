extends KinematicBody2D

signal spawn_throwable(throwable, pos, velocity)

export var throw_offset = Vector2(0, 0)
export var throw_velocity = 30

func throw(throwable_scene):
	emit_signal(
		"spawn_throwable",
		throwable_scene.instance(), 
		throw_offset.rotated(get_global_rot()) + get_global_pos(),
		Vector2(0, throw_velocity).rotated(get_global_rot())
	)
