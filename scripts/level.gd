extends Node

onready var thrower_class = preload("res://scripts/thrower.gd")
onready var ui = get_node("ui_layer")
onready var player = get_node("player")

func _ready():
	ui.set_score(0)
	ui.set_morale(player.morale)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	for c in get_children():
		if c extends thrower_class:
			c.connect("spawn_throwable", self, "_on_spawn_throwable")
	player.connect("morale_change", self, "_on_morale_change")
	
func _on_spawn_throwable(throwable, pos, velocity):
	add_child(throwable)
	throwable.set_pos(pos)
	throwable.set_velocity(velocity)
	throwable.set_z(1)

func _on_morale_change(new):
	ui.set_morale(new)