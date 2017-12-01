extends Area2D

onready var player_class = preload("res://scripts/player/player.gd")
onready var thrower_class = preload("res://scripts/thrower.gd")

export var damage = 20
var velocity = Vector2(0,0)
var rethrown = false

func _ready():
	set_process(true)

func _process(delta):
	set_global_pos(get_global_pos() + velocity)

func set_velocity(v):
	velocity = v

func get_velocity():
	return velocity

func _on_ball_body_enter(body):
	if body extends player_class || body extends thrower_class:
		body.register_hit(self)