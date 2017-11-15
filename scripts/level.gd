extends Node

onready var thrower_class = preload("res://scripts/thrower.gd")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	for c in get_children():
		if c extends thrower_class:
			c.connect("spawn_throwable", self, "_on_spawn_throwable")
	
func _on_spawn_throwable(throwable, pos, velocity):
	add_child(throwable)
	throwable.set_pos(pos)
	throwable.set_velocity(velocity)
	throwable.set_z(1)
