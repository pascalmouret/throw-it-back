extends CanvasLayer

onready var morale_label = get_node("ui/morale")
onready var score_label = get_node("ui/score")

func _ready():
	pass

func set_morale(morale):
	morale_label.set_text("Morale: " + str(morale))

func set_score(score):
	score_label.set_text("Score: " + str(score))
