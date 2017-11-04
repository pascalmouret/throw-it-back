extends "thrower.gd"

onready var ball = preload("res://ball.tscn")

func _ready():
	throw(ball)

func _on_throw_timer_timeout():
	throw(ball)
