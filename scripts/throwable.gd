extends Area2D

var velocity = Vector2(0,0)

func _ready():
	set_process(true)

func _process(delta):
	set_global_pos(get_global_pos() + velocity)

func set_velocity(v):
	velocity = v

func get_velocity():
	return velocity