extends Node

onready var thrower_class = preload("res://scripts/thrower.gd")
onready var ui = get_node("ui_layer")
onready var player = get_node("player")

var score = 0
var start_morale = 0

func _ready():
	start_morale = player.morale
	ui.set_score(score)
	ui.set_morale(start_morale)
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
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
	if new <= 0:
		reset()

func reset():
	player.morale = start_morale
	score = 0
	_ready()