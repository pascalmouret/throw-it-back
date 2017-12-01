extends Node

export var default_enemy = preload("res://enemy.tscn")

onready var thrower_class = preload("res://scripts/thrower.gd")
onready var throwable_class = preload("res://scripts/throwable.gd")
onready var ui = get_node("ui_layer")
onready var player = get_node("player")

var score = 0
var start_morale = 0

var enemy_count = 0
var start_enemies = 1
var inrease_after = 5
var killed = 0

var spawn_circle = 1500

func _ready():
	start_morale = player.morale
	ui.set_score(score)
	ui.set_morale(start_morale)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	spawn_enemies()
	player.connect("morale_change", self, "_on_morale_change")

func connect_thrower(thrower):
	thrower.connect("spawn_throwable", self, "_on_spawn_throwable")
	thrower.connect("killed", self, "_on_killed")
	
func spawn_enemies():
	var target = start_enemies + floor(killed / 5)
	if enemy_count < target:
		add_enemy(default_enemy.instance())
		spawn_enemies()
	
func add_enemy(enemy):
	var landingsite = get_random_position()
	if !is_landingsite_free(landingsite, enemy.get_node("collider").get_shape()):
		add_enemy(enemy)
	enemy.set_global_pos(landingsite)
	add_child(enemy)
	connect_thrower(enemy)
	enemy_count += 1

func get_random_position():
	var relative_pos = Vector2(
		floor(rand_range(0, spawn_circle)) - (spawn_circle / 2),
		floor(rand_range(0, spawn_circle)) - (spawn_circle / 2)
	)
	return player.get_global_pos() + relative_pos

func is_landingsite_free(pos, shape):
	var space = Physics2DServer.body_get_space(player.get_rid())
	var state = Physics2DServer.space_get_direct_state(space)

	var params = Physics2DShapeQueryParameters.new()
	params.set_shape(shape)

	var result = state.intersect_shape(params)
	if result.size() > 0:
		return false
	return true

func reset():
	player.morale = start_morale
	score = 0
	killed = 0
	enemy_count = 0
	for c in get_children():
		if c extends thrower_class || c extends throwable_class:
			c.queue_free()
	_ready()
	
func _on_spawn_throwable(throwable, pos, velocity):
	add_child(throwable)
	throwable.set_pos(pos)
	throwable.set_velocity(velocity)
	throwable.set_z(1)

func _on_morale_change(new):
	ui.set_morale(new)
	if new <= 0:
		reset()

func _on_killed(thrower):
	killed += 1
	enemy_count -= 1
	score += thrower.value
	thrower.queue_free()
	ui.set_score(score)
	spawn_enemies()