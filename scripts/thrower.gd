extends KinematicBody2D

signal spawn_throwable(throwable, pos, velocity)
signal killed(thrower)

export var throw_offset = Vector2(0, 0)
export var throw_velocity = 30
export var value = 10

func throw(throwable_scene):
	emit_signal(
		"spawn_throwable",
		throwable_scene.instance(), 
		throw_offset.rotated(get_global_rot()) + get_global_pos(),
		Vector2(0, throw_velocity).rotated(get_global_rot())
	)

func register_hit(throwable):
	print("hit")
	if throwable.rethrown:
		print("HIT")
		emit_signal("killed", self)
		throwable.queue_free()
