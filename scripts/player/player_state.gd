var player = null

const WALK_ANIMATION = "walk"
const STRAFE_ANIMATION = "strafe"
const IDLE_ANIMATION = "idle"
const CATCH_ANIMATION = "catch"
const SWING_ANIMATION = "swing"
const THROW_ANIMATION = "throw"

func _init(player):
	self.player = player
	
func enter():
	pass

func exit():
	pass
	
func fixed_process(delta):
	pass

func input(ev, delta):
	pass
	
func play_animation(delta):
	pass